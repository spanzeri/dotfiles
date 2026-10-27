/**
 * pi-exit: /exit as an alias for the built-in /quit.
 *
 * ctx.shutdown() only takes effect once the agent settles, so /exit typed
 * during a run would otherwise do nothing until the run finished. Aborting
 * first makes the run settle, so shutdown happens immediately.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Exit pi (alias for /quit)",
    handler: async (_args, ctx) => {
      if (!ctx.isIdle()) ctx.abort();
      ctx.shutdown();
    },
  });
}
