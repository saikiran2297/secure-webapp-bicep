param(
  [string]$RgName = "rg-secureweb-dev"
)

$ErrorActionPreference = "Stop"

Write-Host "Resources in RG:"
az resource list -g $RgName -o table

Write-Host "`nWeb App URL:"
$web = az webapp list -g $RgName --query "[0].defaultHostName" -o tsv
if ($web) {
  Write-Host "https://$web"
} else {
  Write-Host "Web app not found."
}

Write-Host "`nKey Vault:"
$kv = az keyvault list -g $RgName --query "[0].name" -o tsv
Write-Host $kv
