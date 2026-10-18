import { demand } from './policy.mjs';

// Synthetic experiment only. No production adapter imports this gate.
export function sessionGate({ accepted, session, runtime, current, alive, invoke }) {
  let fresh = true, started = false, registered = false, valid = accepted === true;
  function check(ctx) {
    try { demand(valid && started && alive() && current() === runtime && ctx.sessionManager.getSessionId() === session && ctx.mode === 'tui', 'fixture-scope-refused'); }
    catch (error) { valid = false; throw error; }
  }
  return {
    install(adapter, pi) {
      for (const event of ['session_before_switch', 'session_before_fork', 'session_before_tree', 'session_shutdown']) pi.on(event, () => { valid = false; });
      adapter({ on(event, callback) {
        pi.on(event, async (value, ctx) => {
          if (event === 'session_start') {
            if (!fresh || value.reason !== 'startup' || ctx.sessionManager.getBranch().length) valid = false;
            fresh = false; started = true;
          }
          check(ctx); demand(event === 'session_start' || registered, 'fixture-not-registered');
          const result = await callback(value, ctx);
          if (event === 'session_start' && !registered) valid = false;
          return result;
        });
      } });
    },
    invoke(command, payload) {
      try { demand(valid && started && alive() && current() === runtime && payload.session === session && (registered || command === 'session'), 'fixture-scope-refused'); }
      catch (error) { valid = false; throw error; }
      const result = invoke(command, payload);
      if (command === 'session') { registered = result.status === 'registered'; if (!registered) valid = false; }
      return result;
    },
    revoke() { valid = false; },
  };
}
