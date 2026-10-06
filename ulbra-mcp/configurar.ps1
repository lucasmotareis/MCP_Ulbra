param([switch]$VerificarInstalacao)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1') -ErrorAction Stop
$nodePath = 'C:\Program Files\nodejs\node.exe'
$codexCommand = Get-Command codex.exe -ErrorAction SilentlyContinue
if ($codexCommand) {
    $codexPath = $codexCommand.Source
} else {
    $codexInstallRoot = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'OpenAI\Codex\bin'
    $codexExecutable = if (Test-Path -LiteralPath $codexInstallRoot) {
        Get-ChildItem -LiteralPath $codexInstallRoot -Filter 'codex.exe' -Recurse -File |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
    }
    if (-not $codexExecutable) {
        throw 'Nao foi possivel localizar codex.exe no PATH ou na instalacao do aplicativo.'
    }
    $codexPath = $codexExecutable.FullName
}
if ($VerificarInstalacao) {
    Write-Host ('Codex encontrado: ' + $codexPath)
    & $codexPath mcp add --help
    if ($LASTEXITCODE -ne 0) { throw 'O executavel encontrado nao conseguiu iniciar.' }
    return
}
$secureToken = Read-Host 'Cole o token do Canvas da Ulbra (o valor ficara oculto)' -AsSecureString
if ($secureToken.Length -eq 0) { throw 'Token vazio. Nenhuma configuracao foi alterada.' }
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$previousToken = $env:CANVAS_API_TOKEN
try {
    $env:CANVAS_API_TOKEN = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    & $nodePath (Join-Path $PSScriptRoot 'verificar.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'O teste do Canvas falhou. O token nao foi salvo.' }
    $tokenPath = Join-Path $PSScriptRoot 'token.dpapi'
    $encryptedToken = ConvertFrom-SecureString -SecureString $secureToken
    [IO.File]::WriteAllText($tokenPath, $encryptedToken, [Text.Encoding]::ASCII)
    & $codexPath mcp add canvas-ulbra -- powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'iniciar.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'O token foi salvo, mas o registro no Codex falhou.' }
    Write-Host 'Canvas Ulbra configurado. Reinicie o Codex para carregar o MCP.'
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    $env:CANVAS_API_TOKEN = $previousToken
    $secureToken.Dispose()
}
