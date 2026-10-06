param([string]$TokenPath = (Join-Path $PSScriptRoot 'token.dpapi'))
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1') -ErrorAction Stop
if (-not (Test-Path -LiteralPath $TokenPath)) {
    [Console]::Error.WriteLine('Execute ulbra-mcp\configurar.ps1 para salvar seu token localmente.')
    exit 1
}
$secureToken = (Get-Content -LiteralPath $TokenPath -Raw).Trim() | ConvertTo-SecureString
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$previousToken = $env:CANVAS_API_TOKEN
try {
    $env:CANVAS_API_TOKEN = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    & 'C:\Program Files\nodejs\node.exe' (Join-Path $PSScriptRoot 'server.mjs')
    $serverExitCode = $LASTEXITCODE
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    $env:CANVAS_API_TOKEN = $previousToken
    $secureToken.Dispose()
}
exit $serverExitCode
