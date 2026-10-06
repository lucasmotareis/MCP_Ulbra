import { createRequire } from 'node:module';
import { fileURLToPath, pathToFileURL } from 'node:url';
const require = createRequire(new URL('../canvas-lms-mcp/package.json', import.meta.url));
const { Client } = await import(pathToFileURL(require.resolve('@modelcontextprotocol/sdk/client/index.js')).href);
const { StdioClientTransport } = await import(pathToFileURL(require.resolve('@modelcontextprotocol/sdk/client/stdio.js')).href);
const offline = process.argv.includes('--offline');
const launcherIndex = process.argv.indexOf('--launcher');
const launcherTokenFile = launcherIndex >= 0 ? process.argv[launcherIndex + 1] : null;
const env = Object.fromEntries(Object.entries(process.env).filter(([, value]) => value !== undefined));
if (offline) env.CANVAS_API_TOKEN = 'offline-protocol-check';
const client = new Client({ name: 'ulbra-setup-check', version: '1.0.0' });
const transport = new StdioClientTransport({
  command: launcherTokenFile ? 'powershell.exe' : process.execPath,
  args: launcherTokenFile
    ? ['-NoLogo', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', fileURLToPath(new URL('./iniciar.ps1', import.meta.url)), '-TokenPath', launcherTokenFile]
    : [fileURLToPath(new URL('./server.mjs', import.meta.url))],
  env,
  stderr: 'pipe',
});
let diagnostics = '';
if (offline) transport.stderr?.on('data', chunk => { diagnostics += chunk.toString(); });
try {
  await client.connect(transport);
  const { tools } = await client.listTools();
  if (!tools.length || tools.some(tool => tool.annotations?.readOnlyHint !== true)) {
    throw new Error('tool-policy');
  }
  for (const name of ['get_profile', 'get_my_courses']) {
    if (!tools.some(tool => tool.name === name)) throw new Error('missing-tool');
    if (!offline) {
      const result = await client.callTool({ name, arguments: {} });
      if (result.isError) throw new Error('canvas-access');
    }
  }
  console.log(offline
    ? `Protocolo MCP validado: ${tools.length} ferramentas de consulta, sem acessar a API.`
    : `Acesso ao perfil e disciplinas validado pelo MCP. ${tools.length} ferramentas de consulta.`);
} catch (error) {
  if (offline) console.error(diagnostics || error.message);
  console.error('Falha na validacao. Confira o token, a conexao de rede e a permissao de acesso a API da Ulbra. Nenhuma credencial foi exibida.');
  process.exitCode = 1;
} finally {
  await client.close().catch(() => {});
  await transport.close().catch(() => {});
}
