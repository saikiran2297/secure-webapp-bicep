# Secure Web App Deployment (Azure + Bicep + PowerShell)

This project deploys a secure Azure Web App foundation using **Bicep (IaC)** and **PowerShell**.

## What it deploys
- App Service Plan (Premium v3)
- Web App (HTTPS-only, TLS 1.2+, FTP disabled, Always On)
- System Assigned Managed Identity
- Application Insights + Log Analytics
- Key Vault (Public access disabled, RBAC enabled)
- Private Endpoint for Key Vault + Private DNS Zone
- Web App VNet Integration (Swift)
- RBAC assignment: Web App identity -> Key Vault Secrets User

---

## Prerequisites
- Azure subscription
- Azure CLI installed
- PowerShell 7+ recommended

---

## Deploy (PowerShell)

From repo root:

```powershell
cd .\infra\scripts
.\01-login.ps1
.\02-deploy.ps1 -Location "uksouth" -RgName "rg-secureweb-dev"
.\03-validate.ps1 -RgName "rg-secureweb-dev"
