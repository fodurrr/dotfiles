import { VERSION } from '@earendil-works/pi-coding-agent';
import { probeChannel } from './transport.mjs';

export default async function launchProbe() {
  try { await probeChannel(VERSION); }
  catch (error) {
    console.error(JSON.stringify({ experiment: 'pi-launch', status: 'probe-refused', reason: error.message }));
    throw error;
  }
}
