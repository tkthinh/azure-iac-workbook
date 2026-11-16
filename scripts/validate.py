"""Non-deploying workbook checks. Never print candidate secret values."""

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SENSITIVE = re.compile(
    r"password|secret|token|api_?key|accountkey|sharedaccesskey|masterkey|saltkey|connectionstring",
    re.IGNORECASE,
)
PATTERNS = {
    "private-key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    "provider-token": re.compile(
        r"gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|"
        r"AKIA[A-Z0-9]{16}|sk-[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{30,}"
    ),
    "subscription-id": re.compile(
        r"/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        re.IGNORECASE,
    ),
    "personal-ssh-public-key": re.compile(r"ssh-(?:rsa|ed25519)\s+[A-Za-z0-9+/]{32,}"),
    "connection-secret": re.compile(
        r"(?:AccountKey|SharedAccessKey|client_secret|sig)\s*[=:]\s*[A-Za-z0-9+/%_-]{16,}",
        re.IGNORECASE,
    ),
}


def placeholder(value):
    return (
        not value or "<" in value or value.startswith("[") or "${" in value
    )


def run(command):
    # Compiler diagnostics are printed only if compilation fails. No deployment.
    result = subprocess.run(
        command, cwd=ROOT, capture_output=True, text=True, timeout=90,
    )
    if result.returncode:
        raise RuntimeError("Compiler command failed: " + result.stderr)
    if result.stderr.strip():
        print(result.stderr.strip())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compile", action="store_true")
    parser.add_argument("--bicep", help="Optional standalone Bicep executable path")
    args = parser.parse_args()
    # Scan tracked source files when in Git; copied pre-init trees are supported.
    if (ROOT / ".git").exists():
        names = subprocess.check_output(
            ["git", "ls-files", "-z"], cwd=ROOT,
        ).decode().split("\0")
        paths = [ROOT / name for name in names if name]
    else:
        paths = [path for path in ROOT.rglob("*") if path.is_file()]
    failures = []
    modules = sorted(ROOT.rglob("main.bicep"))
    for path in paths:
        relative = path.relative_to(ROOT).as_posix()
        if "z_owui-deploy" in path.parts or "owui-deploy" in path.parts:
            failures.append(f"{relative}: private stack must not be published")
        if path.name.startswith(".env") and path.name != ".env.example":
            failures.append(f"{relative}: environment file must not be tracked")
            continue  # Never inspect local environment files.
        if path.suffix.lower() in {".pem", ".key", ".pfx", ".p12"}:
            failures.append(f"{relative}: potential credential file")
            continue
        try:
            text = path.read_text(encoding="utf-8-sig")
        except UnicodeError:
            failures.append(f"{relative}: unexpected binary requires manual review")
            continue
        for number, line in enumerate(text.splitlines(), 1):
            for label, pattern in PATTERNS.items():
                if pattern.search(line):
                    failures.append(f"{relative}:{number}: {label} [redacted]")
            if path.suffix in {".bicep", ".bicepparam"}:
                match = re.search(r"\bparam\s+(\w+)(?:\s+\w+)?\s*=\s*'([^']*)'", line)
                if match and SENSITIVE.search(match[1]) and not placeholder(match[2]):
                    failures.append(f"{relative}:{number}: sensitive literal [redacted]")
        if path.suffix == ".json":
            try:
                data = json.loads(text)
            except ValueError:
                failures.append(f"{relative}: invalid JSON")
                continue
            if isinstance(data, dict):
                for name, item in data.get("parameters", {}).items():
                    if SENSITIVE.search(name) and isinstance(item, dict):
                        value = item.get("value", item.get("defaultValue"))
                        if isinstance(value, str) and not placeholder(value):
                            failures.append(f"{relative}: sensitive parameter {name} [redacted]")
    for module in modules:
        for name in ("parameters.json", "main.bicepparam", "usage.txt", "main.json"):
            if not (module.parent / name).is_file():
                failures.append(f"{module.parent.relative_to(ROOT)}: missing {name}")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"PASS disclosure/structure checks: {len(paths)} files, {len(modules)} modules")
    if args.compile:
        azure_cli = shutil.which("az") if not args.bicep else None
        if not args.bicep and not azure_cli:
            raise RuntimeError("Azure CLI not found; install it or supply --bicep")
        command = [args.bicep] if args.bicep else [azure_cli, "bicep"]
        with tempfile.TemporaryDirectory(prefix="iac-params-") as temporary:
            for index, module in enumerate(modules):
                relative = module.relative_to(ROOT).as_posix()
                file_args = [] if args.bicep else ["--file"]
                run(command + ["build"] + file_args + [str(module), "--outfile", str(module.with_suffix(".json"))])
                param_output = Path(temporary) / f"{index}.json"
                run(command + ["build-params"] + file_args + [str(module.parent / "main.bicepparam"), "--outfile", str(param_output)])
                expected = json.loads((module.parent / "parameters.json").read_text())["parameters"]
                actual = json.loads(param_output.read_text())["parameters"]
                if actual != expected:
                    print(f"FAIL {relative}: JSON/native parameters differ (values withheld)", file=sys.stderr)
                    return 1
                print(f"PASS compile and parameter equivalence: {relative}", flush=True)
        print(f"PASS compiled {len(modules)} modules; all example parameter pairs equivalent")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f"Validation failed: {error}", file=sys.stderr)
        sys.exit(1)
