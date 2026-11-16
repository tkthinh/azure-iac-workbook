# Repository Guidelines

## Purpose
This repository is an Azure Infrastructure-as-Code library built with Bicep. Contributions should produce reusable, production-ready Azure modules that can be consumed by environment stacks such as dev, test, and prod. Design for composability and consistency, not maximum configurability.

## Required Module Structure
Create one folder per resource using lowercase names with no spaces, for example `vm`, `vnet`, or `storage`. Inside each folder include:

- `main.bicep`: the production-ready module
- `parameters.json`: JSON example inputs for Azure CLI and automation consumers
- `main.bicepparam`: equivalent native Bicep example inputs
- `usage.txt`: Azure CLI deployment examples for both parameter formats

Keep `parameters.json` and `main.bicepparam` semantically equivalent. Keep secrets empty or as placeholders in both files.

Use both command formats in `usage.txt`:

```text
# JSON parameters
az deployment group create \
  --resource-group <rg-name> \
  --template-file ./<resource-folder>/main.bicep \
  --parameters @./<resource-folder>/parameters.json

# Bicep parameters
az deployment group create \
  --resource-group <rg-name> \
  --parameters ./<resource-folder>/main.bicepparam
```

## Parameterization Rules
Expose parameters only for values that vary by environment or are needed for composition. Valid parameters include resource names, SKUs, sizes, address spaces, tags, IDs, and optional features reused across environments.

Do not parameterize naming conventions, secure defaults, baseline security settings, standard monitoring behavior, common NSG rules, or standard OS/image choices unless variability is clearly required.

## Bicep Design Standards
Keep modules focused, minimal, and environment-agnostic. Prefer strong defaults over flexibility. Use clear parameter names, stable outputs, and comments only for key sections. Follow Azure naming constraints, use current stable API versions, and ensure deployments are idempotent.

Apply secure-by-default settings wherever possible, including HTTPS-only access, least privilege, encryption, and private access patterns when appropriate to the resource type.

## Outputs & Composition
Every module should return the values needed by downstream modules and stacks, such as resource IDs, names, principal IDs, endpoints, or subnet references. Avoid verbose or redundant outputs.

## Workflow
Wait for the resource requirement first. Then generate the full module folder, file contents, and deployment examples. Keep secrets empty or as placeholders in both parameter files, and output only the folder structure and file contents when fulfilling a generation request.

### Build Validation
Before handing off a module, compile its `main.bicep` into a sibling `main.json` file. This validates the Bicep syntax and leaves the generated ARM template available for inspection:

```text
az bicep build --file ./<resource-folder>/main.bicep --outfile ./<resource-folder>/main.json
```

Treat `main.json` as generated validation output. Rebuild it whenever `main.bicep` changes, and resolve all Bicep compiler errors before handoff. Do not use `main.json` as the source of truth; make changes in `main.bicep`.
