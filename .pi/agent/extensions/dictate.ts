/**
 * pi-dictate: press alt+r to record, press again to stop.
 * The transcript is pasted into the editor. Nothing runs between utterances.
 *
 * Needs whisper-cli (whisper.cpp), ffmpeg, and the small.en + Silero VAD models.
 * On Arch:  sudo pacman -S whisper-cpp
 *           paru -S whisper.cpp-model-small.en-q5_1
 * Override paths with PI_DICTATE_WHISPER, PI_DICTATE_MODEL, PI_DICTATE_VAD.
 */
import { spawn, type ChildProcess } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { delimiter, join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

function findOnPath(name: string): string | undefined {
  for (const dir of (process.env.PATH ?? "").split(delimiter)) {
    if (!dir) continue;
    const path = join(dir, name);
    try {
      accessSync(path, constants.X_OK);
      return path;
    } catch {}
  }
  return undefined;
}

function firstExisting(paths: (string | undefined)[]): string | undefined {
  for (const path of paths) {
    if (!path) continue;
    try {
      accessSync(path, constants.R_OK);
      return path;
    } catch {}
  }
  return undefined;
}

function whisperPath(): string | undefined {
  return process.env.PI_DICTATE_WHISPER ?? findOnPath("whisper-cli");
}

function modelPath(): string | undefined {
  return firstExisting([
    process.env.PI_DICTATE_MODEL,
    join(homedir(), ".local/share/whisper/models/ggml-small.en-q5_1.bin"),
    "/usr/share/whisper.cpp-model-small.en-q5_1/ggml-small.en-q5_1.bin",
  ]);
}

function vadPath(): string | undefined {
  return firstExisting([
    process.env.PI_DICTATE_VAD,
    join(homedir(), ".local/share/whisper/models/ggml-silero-v6.2.0.bin"),
    "/usr/share/whisper-cpp/ggml-silero-v6.2.0.bin",
  ]);
}

const SOURCE = process.env.PI_DICTATE_SOURCE ?? "default";
const THREADS = process.env.PI_DICTATE_THREADS ?? "8";
const MAX_SECONDS = 300;

type Recording = { child: ChildProcess; dir: string; file: string };

export default function (pi: ExtensionAPI) {
  let recording: Recording | null = null;
  let busy = false;

  function preflight(ctx: ExtensionContext): boolean {
    if (!findOnPath("ffmpeg")) {
      ctx.ui.notify("ffmpeg not found. Install it: sudo pacman -S ffmpeg", "error");
      return false;
    }
    if (!whisperPath()) {
      ctx.ui.notify(
        "whisper-cli not found. Install it: sudo pacman -S whisper-cpp",
        "error",
      );
      return false;
    }
    if (!modelPath()) {
      ctx.ui.notify(
        "Whisper model not found. Install it: paru -S whisper.cpp-model-small.en-q5_1",
        "error",
      );
      return false;
    }
    if (!vadPath()) {
      ctx.ui.notify(
        "VAD model not found. mkdir -p ~/.local/share/whisper/models && curl -L -o ~/.local/share/whisper/models/ggml-silero-v6.2.0.bin https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v6.2.0.bin",
        "error",
      );
      return false;
    }
    return true;
  }

  function clean(text: string): string {
    const line = text.replace(/\s+/g, " ").trim();
    if (!/[a-z0-9]/i.test(line)) return ""; // silence, (typing), ♪ ♪
    if (/^\(?(silence|typing|keyboard[^)]*)\)?$/i.test(line)) return "";
    return line;
  }

  async function stop(ctx: ExtensionContext): Promise<void> {
    if (!recording || busy) return;
    busy = true;
    const rec = recording;
    recording = null;
    ctx.ui.setStatus("dictate", "transcribing…");

    try {
      if (rec.child.exitCode === null && rec.child.signalCode === null) {
        rec.child.kill("SIGINT");
        await new Promise<void>((resolve) => {
          const timer = setTimeout(() => {
            rec.child.kill("SIGKILL");
            resolve();
          }, 2000);
          rec.child.once("close", () => {
            clearTimeout(timer);
            resolve();
          });
        });
      }

      const whisper = whisperPath();
      const model = modelPath();
      const vad = vadPath();
      if (!whisper || !model || !vad) {
        ctx.ui.notify("Dictation install disappeared; check whisper-cli and models", "error");
        return;
      }

      const result = await pi.exec(
        whisper,
        [
          "-m", model, "-f", rec.file, "-t", THREADS,
          "-nt", "-np", "-sns", "-l", "en",
          "--vad", "-vm", vad,
        ],
        { timeout: 120_000 },
      );
      if (result.code !== 0) {
        ctx.ui.notify(`whisper failed: ${result.stderr.trim() || `exit ${result.code}`}`, "error");
        return;
      }
      const text = clean(result.stdout);
      if (!text) {
        ctx.ui.notify("Nothing transcribed", "warning");
        return;
      }
      ctx.ui.pasteToEditor(text + " ");
    } catch (error) {
      ctx.ui.notify(`dictate failed: ${(error as Error).message}`, "error");
    } finally {
      await rm(rec.dir, { recursive: true, force: true }).catch(() => {});
      ctx.ui.setStatus("dictate", undefined);
      busy = false;
    }
  }

  async function start(ctx: ExtensionContext): Promise<void> {
    if (recording || busy) return;
    const dir = await mkdtemp(join(tmpdir(), "pi-dictate-"));
    const file = join(dir, "in.wav");
    const child = spawn(
      "ffmpeg",
      [
        "-hide_banner", "-loglevel", "error",
        "-f", "pulse", "-i", SOURCE,
        "-t", String(MAX_SECONDS),
        "-ac", "1", "-ar", "16000", "-c:a", "pcm_s16le",
        "-y", file,
      ],
      { stdio: ["ignore", "ignore", "ignore"] },
    );

    const rec: Recording = { child, dir, file };
    recording = rec;
    ctx.ui.setStatus("dictate", "● recording — alt+r to stop");

    child.once("error", (error) => {
      if (recording === rec) recording = null;
      ctx.ui.setStatus("dictate", undefined);
      ctx.ui.notify(`ffmpeg failed: ${error.message}`, "error");
      void rm(dir, { recursive: true, force: true });
    });
    child.once("close", (code) => {
      // ffmpeg hit its own time limit or died; transcribe what exists.
      if (recording === rec) void stop(ctx).then(() => {
        if (code !== 0 && code !== 255) ctx.ui.notify(`ffmpeg exited ${code}`, "warning");
      });
    });
  }

  async function toggle(ctx: ExtensionContext): Promise<void> {
    if (recording) await stop(ctx);
    else if (preflight(ctx)) await start(ctx);
  }

  pi.registerShortcut("alt+r", {
    description: "Dictate: record speech and paste the transcript",
    handler: (ctx) => toggle(ctx),
  });

  pi.registerCommand("dictate", {
    description: "Record speech and paste the transcript (alt+r)",
    handler: (_args, ctx) => toggle(ctx),
  });

  pi.on("session_shutdown", async () => {
    if (!recording) return;
    recording.child.kill("SIGTERM");
    await rm(recording.dir, { recursive: true, force: true }).catch(() => {});
    recording = null;
  });
}
