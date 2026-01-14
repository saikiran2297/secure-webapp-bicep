param(
  [string]$Location = "uksouth",
  [string]$RgName   = "rg-secureweb-dev",
  [string]$Template = "..\main.bicep",
  [string]$Params   = "..\main.parameters.json"
)

$ErrorActionPreference = "Stop"

Write-Host "Creating Resource Group: $RgName in $Location"
az group create --name $RgName --location $Location -o table

Write-Host "Deploying Bicep..."
az deployment group create `
  --resource-group $RgName `
  --template-file $Template `
  --parameters @$Params `
  --output table

Write-Host "Deployment completed."
