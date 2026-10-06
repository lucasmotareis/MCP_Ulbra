# MCP_Ulbra

MCP local para consultar o Canvas da Ulbra pelo Codex. Usa o servidor [canvas-lms-mcp](https://github.com/bruchris/canvas-lms-mcp), incluído como submódulo, com perfil de estudante e apenas ferramentas de consulta.

## Requisitos

- Windows e Windows PowerShell.
- Node.js 22 ou superior, instalado em `C:\Program Files\nodejs`.
- Git e pnpm 10.11.0 disponíveis no terminal.
- Codex instalado.
- Token de acesso à API do Canvas da sua conta na Ulbra.

## Instalação

No PowerShell:

```powershell
git clone --recurse-submodules https://github.com/lucasmotareis/MCP_Ulbra.git
Set-Location MCP_Ulbra
pnpm --dir canvas-lms-mcp install --frozen-lockfile
pnpm --dir canvas-lms-mcp build
node .\ulbra-mcp\verificar.mjs --offline
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ulbra-mcp\configurar.ps1
```

Se já clonou sem os submódulos, execute `git submodule update --init --recursive` antes de instalar as dependências.

O configurador pede o token com entrada oculta, valida o acesso ao perfil e às disciplinas e registra `canvas-ulbra` no Codex. Reinicie o Codex para carregar o MCP. Para renovar um token, execute `configurar.ps1` novamente.

## Credenciais e outras máquinas

O token é salvo em `ulbra-mcp/token.dpapi`, criptografado com DPAPI do Windows. Esse arquivo é ignorado pelo Git e só pode ser descriptografado pela mesma conta do Windows na mesma máquina.

Em outro computador, repita a instalação e configure o token localmente. A configuração do Codex guarda o caminho do launcher, sem guardar o token. Este projeto usa STDIO e roda localmente; ele não disponibiliza um endpoint HTTP remoto.

## Estrutura

- `ulbra-mcp/`: configurador, launcher, servidor adaptado à Ulbra e verificação do protocolo.
- `canvas-lms-mcp/`: submódulo do servidor original, fixado na revisão usada nesta instalação. A licença MIT e os créditos do projeto original estão nesse diretório.

`verificar.mjs --offline` verifica a conexão MCP e confirma que as ferramentas expostas são de consulta, sem acessar a API do Canvas.
