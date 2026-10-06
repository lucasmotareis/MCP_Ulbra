# Canvas da Ulbra no Codex

Consulte o `README.md` na raiz para instalar as dependencias. Na raiz do repositorio, execute no PowerShell da sua conta do Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ulbra-mcp\configurar.ps1
```

Cole o token quando o comando pedir. O valor fica oculto. O script valida o perfil e as disciplinas usando o MCP, salva o token criptografado pela protecao DPAPI do Windows e registra `canvas-ulbra` no Codex. Depois, reinicie o Codex.

O servidor usa `canvas-lms-mcp` clonado em `../canvas-lms-mcp`, em modo local STDIO, perfil student e apenas ferramentas de consulta. A configuracao do Codex guarda o caminho do launcher, sem guardar o token. O arquivo `token.dpapi` so pode ser descriptografado pela mesma conta do Windows na mesma maquina; preserve a protecao da sua conta e nao publique esse arquivo.

Para trocar um token expirado, execute o mesmo comando novamente. Um token que falhar na validacao nao substitui o anterior.

Para verificar o protocolo sem acessar o Canvas:

```powershell
node .\ulbra-mcp\verificar.mjs --offline
```
