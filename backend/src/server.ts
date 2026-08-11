import { buildApp } from './app.js';
import { loadEnv } from './config/env.js';

const env = loadEnv();
const app = await buildApp({ env });

await app.listen({ host: env.HOST, port: env.PORT });
