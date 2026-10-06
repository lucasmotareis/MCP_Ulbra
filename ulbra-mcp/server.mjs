import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import { createCanvasMCPServer } from '../canvas-lms-mcp/dist/server.js';

const require = createRequire(new URL('../canvas-lms-mcp/package.json', import.meta.url));
const { StdioServerTransport } = await import(pathToFileURL(require.resolve('@modelcontextprotocol/sdk/server/stdio.js')).href);
const token = process.env.CANVAS_API_TOKEN;
if (!token) {
  console.error('Token ausente. Execute configurar.ps1 primeiro.');
  process.exit(1);
}
const { server } = createCanvasMCPServer({
  token,
  baseUrl: 'https://ulbra.instructure.com',
  role: 'student',
  writeTools: 'block',
  destructiveTools: 'block',
  enableAssignmentSubmission: false,
  sharedAcrossCallers: false,
});
await server.connect(new StdioServerTransport());
