// Tint the editor box and make its border follow input focus.
//
// pi has no editor background theme token, so the tint is painted here using the
// active theme's own panel background tokens. That keeps the tint readable on any
// theme: the auto system theme derives those tokens from the terminal's reported
// background, so a light terminal gets light tints and a dark terminal gets dark ones.
//
// States:
//   bash      text starts with "!" (pi's bash-mode rule)  -> bashMode border,  customMessageBg tint
//   focused   the editor owns input                        -> borderAccent,      selectedBg tint
//   unfocused an overlay or selector owns input            -> border,            toolPendingBg tint, mixed down
//
// pi assigns editor.borderColor for bash mode and thinking level
// (interactive-mode updateEditorBorderColor). Those writes are swallowed so the
// border color reports which input box has focus.
//
// The BTW composer is not pi's editor: pi-btw builds its own overlay from
// pi-tui's Input and draws the frame glyphs itself, so setEditorComponent() never
// sees it. TUI.showOverlay() is intercepted instead, and the overlay instance is
// given a focus-aware input row with the same tokens.

import {
	CustomEditor,
	type CustomEditorOptions,
	type ExtensionAPI,
	type KeybindingsManager,
	type Theme,
	type ThemeBg,
	type ThemeColor,
} from "@earendil-works/pi-coding-agent";
import {
	backgroundAnsi,
	mixColors,
	rgbColor,
	TuiAltScreen,
	TuiMainScreen,
	truncateToWidth,
	visibleWidth,
	type Component,
	type EditorTheme,
	type OverlayHandle,
	type OverlayOptions,
	type TUI,
} from "@earendil-works/pi-tui";

const RESET = "\x1b[0m";

type EditorState = "bash" | "focused" | "unfocused";

const TINT: Record<EditorState, ThemeBg> = {
	bash: "customMessageBg",
	focused: "selectedBg",
	unfocused: "toolPendingBg",
};

const BORDER: Record<EditorState, ThemeColor> = {
	bash: "bashMode",
	focused: "borderAccent",
	unfocused: "border",
};

// The stock unfocused token shares focused's lightness (dark: toolPendingBg #34383a vs
// selectedBg #213b49), so an inactive box reads as untinted. Mixing the token toward black
// drops it about 0.12 relative luminance below focused in both appearances.
const UNFOCUSED_MIX: Record<Theme["appearance"], number> = { dark: 0.4, light: 0.1 };
const BLACK = rgbColor(0, 0, 0);

/** Background sequence for a composer tint. Unfocused is mixed down so input focus reads on any theme. */
export function tintBgAnsi(theme: Theme, state: EditorState): string {
	const token = TINT[state];
	const plain = theme.getBgAnsi(token);
	if (state !== "unfocused" || !plain) return plain;
	const base = theme.colors?.[token];
	if (!base) return plain;
	const mix = UNFOCUSED_MIX[theme.appearance] ?? UNFOCUSED_MIX.dark;
	return backgroundAnsi(mixColors(base, BLACK, mix), theme.getColorMode());
}

let resolveTheme: () => Theme = () => {
	throw new Error("input-style: theme resolver installed on session_start");
};

class TintedEditor extends CustomEditor {
	constructor(
		tui: TUI,
		theme: EditorTheme,
		keybindings: KeybindingsManager,
		options: CustomEditorOptions | undefined,
	) {
		super(tui, theme, keybindings, options);
		Object.defineProperty(this, "borderColor", {
			configurable: true,
			get: () => (text: string) => resolveTheme().fg(BORDER[this.currentState()], text),
			set: () => {
				// Intentionally dropped: focus decides the border, not thinking level.
			},
		});
	}

	private currentState(): EditorState {
		if (this.getText().trimStart().startsWith("!")) return "bash";
		return this.focused ? "focused" : "unfocused";
	}

	override render(width: number): string[] {
		const bg = tintBgAnsi(resolveTheme(), this.currentState());
		const lines = super.render(width);
		if (!bg) return lines;
		// Re-open the background after each reset inside a line so the tint spans the whole row.
		return lines.map((line) => `${bg}${line.split(RESET).join(`${RESET}${bg}`)}`);
	}
}

/** The pi-btw overlay instance, seen through its private fields (TypeScript-only privacy). */
type BtwComposer = {
	borderless: boolean;
	focused: boolean;
	input: { focused: boolean; render: (width: number) => string[] };
	inputFrameLine: (width: number) => string;
	/** Marks the instance as decorated. Lives on the component so a reload cannot stack wrappers. */
	tintedComposerRow?: boolean;
};

/** Give a pi-btw overlay instance a tinted, focus-aware input row. */
function tintBtwComposer(component: unknown): void {
	const composer = component as (BtwComposer & { constructor?: { name?: string } }) | undefined;
	if (!composer || composer.constructor?.name !== "BtwOverlayComponent") return;
	if (typeof composer.inputFrameLine !== "function" || !composer.input) return;
	if (composer.tintedComposerRow) return;
	composer.tintedComposerRow = true;

	// Own property shadows the prototype method, and overlay.render() calls this.inputFrameLine().
	const original = composer.inputFrameLine;
	composer.inputFrameLine = function (this: BtwComposer, dialogWidth: number): string {
		const state: EditorState = this.focused ? "focused" : "unfocused";
		const theme = resolveTheme();
		const bg = tintBgAnsi(theme, state);
		// A theme with the terminal default background has nothing to paint.
		if (!bg) return original.call(this, dialogWidth);

		const targetWidth = Math.max(1, dialogWidth - (this.borderless ? 0 : 2));
		const previousFocused = this.input.focused;
		// pi-btw drops focus for this row so the cursor marker cannot change the row width.
		this.input.focused = false;
		try {
			const rendered = this.input.render(targetWidth)[0] ?? "";
			const line = truncateToWidth(rendered, targetWidth, "");
			const padding = " ".repeat(Math.max(0, targetWidth - visibleWidth(line)));
			const inner = `${bg}${line.split(RESET).join(`${RESET}${bg}`)}${padding}${RESET}`;
			if (this.borderless) return inner;
			const border = theme.fg(BORDER[state], "│");
			return `${border}${inner}${border}`;
		} finally {
			this.input.focused = previousFocused;
		}
	};
}

function tintLiveComposers(tui: TUI): void {
	// SAFETY: overlayStack is a TuiBase instance field that pi-tui marks private; TypeScript
	// privacy is compile-time only, so the field is present at runtime with that shape.
	const stack = (tui as unknown as { overlayStack?: { component: Component }[] }).overlayStack;
	for (const entry of stack ?? []) tintBtwComposer(entry.component);
}

type OverlayShow = (this: TUI, component: Component, options?: OverlayOptions) => OverlayHandle;
type OverlayShowHook = OverlayShow & { tintedComposerHook: true };

function installComposerHook(): void {
	for (const proto of [TuiMainScreen.prototype, TuiAltScreen.prototype]) {
		// SAFETY: showOverlay lives on the unexported TuiBase prototype and neither exported
		// TUI class overrides it, so the inherited value is the live method, and an own
		// property on each subclass prototype shadows it for every instance of that class.
		const original = proto.showOverlay as OverlayShow;
		if ((original as Partial<OverlayShowHook>).tintedComposerHook) continue;
		const wrapper = function (this: TUI, component: Component, options?: OverlayOptions): OverlayHandle {
			tintBtwComposer(component);
			return original.call(this, component, options);
		} as OverlayShowHook;
		wrapper.tintedComposerHook = true;
		proto.showOverlay = wrapper;
	}
}

export default function (pi: ExtensionAPI): void {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		// Dereference once here. ctx.ui is ctx-bound and throws once a session is
		// replaced or reloaded, while the theme proxy is global (globalThis) and keeps
		// reporting the current theme, so render paths never touch a captured ctx.
		const liveTheme = ctx.ui.theme;
		resolveTheme = () => liveTheme;
		installComposerHook();
		// The app re-applies its own editor factory after /reload and after extension UI
		// resets, so re-install on every session start.
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			// An overlay opened before this extension loaded still needs decorating.
			tintLiveComposers(tui);
			return new TintedEditor(tui, theme, keybindings, { embedWorkingStatus: true });
		});
	});
}
