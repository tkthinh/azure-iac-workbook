# Azure IaC Workbook

A hands-on Azure Infrastructure-as-Code workbook using Bicep: focused resource
modules, equivalent JSON/native Bicep parameter examples, and Azure CLI usage.
This repository demonstrates module design and composition across compute,
networking, storage, identity, databases, monitoring, containers, and eventing.

**Status: learning and reference examples, not a production-certified library.**
Bicep compilation checks syntax and types; it does not prove that every example
will deploy successfully, securely, or within a particular subscription's quota.
Review the limitations below before using a module.

## Layout

| Area | Examples |
| --- | --- |
| Compute | App Service, Functions, Ubuntu 24.04 and Windows Server 2022 VMs |
| Containers | ACR, ACI, Container Apps, AKS |
| Network | VNet, NSG, private endpoints/DNS, NAT, public IP, Application Gateway, Front Door |
| Data | Storage, blob containers, file shares, SQL, PostgreSQL, MySQL, Redis, Cosmos DB |
| Identity/security | Managed identity, role assignments, Key Vault |
| Observability | Log Analytics, Monitor workspace, action groups, diagnostic settings, KQL |
| AI/eventing | AI Services, AI Search, Event Grid, Event Hubs, Service Bus |

Each resource folder includes `main.bicep`, `parameters.json`, `main.bicepparam`,
`usage.txt`, and generated `main.json`. Bicep is the source of truth. The separate
OpenWebUI/LiteLLM application stack is not part of this public workbook.

## Validate without deploying

Prerequisites: Python 3.10+, Azure CLI, and its Bicep CLI
(`az bicep install --version v0.46.1`, matching the CI/build-artifact version).
No Azure login is required for these local compilation checks.

```sh
# Check file structure, JSON, and common accidental disclosures
python scripts/validate.py

# Also rebuild every main.json and compare compiled native parameters to JSON
python scripts/validate.py --compile
```

CI runs these checks plus Gitleaks against the checked-out Git history. Secret
scanning is a guardrail, not a guarantee that all sensitive data will be detected.

## Use an example

1. Choose a resource folder and read `main.bicep` and `usage.txt`.
2. Copy the example inputs to an ignored `parameters.local.json` or
   `main.local.bicepparam` in the same folder. Replace resource names, IDs, and
   placeholders. The example files are not deployment-ready unchanged.
3. Supply secrets through a Key Vault parameter reference or an approved secret
   provisioning mechanism. Do not put real secrets in tracked example inputs.
4. Review cost, region availability, access controls, and prerequisites. Use an
   isolated sandbox resource group and review `what-if` before deployment.

```sh
az deployment group what-if \
  --resource-group <sandbox-resource-group> \
  --template-file ./network/vnet/main.bicep \
  --parameters @./network/vnet/parameters.local.json
```

The `usage.txt` commands show the tracked example paths: substitute your ignored
local parameter path before running them. They create billable resources; they
are not dry runs. Subscription-scoped modules such as `resourcegroup` use subscription
deployment commands instead. Clean up sandbox resources deliberately after use.

## Known limitations and review priorities

- Application Gateway currently has an HTTP-only listener/backend and incomplete
  backend configuration. Add TLS and a real backend before serving traffic.
- Redis and Application Gateway have SKU-related Bicep type warnings. Verify and
  correct the resource schema before deployment.
- Diagnostic settings declare an unused target resource ID and do not attach the
  extension resource to it. This example needs a scope/composition correction.
- AKS disables local accounts without an Entra `aadProfile`; configure and test
  administrative authentication before attempting a deployment.
- Some examples allow public ingress, public storage access with authentication,
  or shared-key authentication. Public reachability is not anonymous access, but
  these examples do not establish a universal private-access baseline.
- Arbitrary app settings and container environment values are not safe places to
  pass plaintext secrets through non-secure deployment parameters.
- Images using `latest` are illustrative, not reproducible; pin reviewed digests
  for controlled deployments.
- `vm/cloud-scripts/` contains historical SSH administration helpers. They can
  change firewall/SSH state and lock you out; they lack a complete dry-run,
  validation, and rollback workflow. Do not run them unreviewed.

No Azure deployment or end-to-end runtime validation is implied by this workbook.
Production use requires further security, operability, cost, and deployment tests.

## Contribution hygiene

Keep both parameter formats semantically equivalent. Use only example values,
empty secrets, or placeholders; never commit environment files, private keys,
personal subscription IDs, or local deployment outputs. Rebuild `main.json` after
editing Bicep and run validation before committing. See `AGENTS.md` for module
conventions. Configure GitHub secret scanning/push protection where available.
