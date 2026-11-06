# JAI module map + graphics path

Lookup recipe (all of the lists below came from these commands):

```sh
ls ~/.local/opt/jai/modules                       # what actually exists
grep -n "#module_parameters" <M>/module.jai        # its parameters and their slot
head -30 ~/.local/opt/jai/modules/<M>/module.jai   # its own header/API notes
ls ~/.local/opt/jai/modules/<M>/examples           # per-module examples
ls ~/.local/opt/jai/examples                        # top-level examples
```

## Inventory (61 directories, 57 single-file modules)

| Area | Modules |
|---|---|
| Language core / runtime | `Preload` `Runtime_Support` `Runtime_Support_Crash_Handler` `Compiler` `Jai_Lexer` `Code_Visit` `Reflection` `Rewrite` `Relative_Pointers` `Soa` `SIMD` `Machine_X64` `debug_info` `executable_formats` `generate_c_header` `telemetry3` `Iprof` `rpmalloc` |
| Build & metaprogram | `Default_Metaprogram.jai` `Minimal_Metaprogram.jai` `Metaprogram_Plugins.jai` `Example_Plugin.jai` `Autorun.jai` `Check` `Codex` `Program_Print` `Print_Color` `Print_Vars` `Performance_Report.jai` `Project_Generator.jai` `Treemap` `linux_build.jai` `MacOS_Bundler.jai` `BuildCpp` `Bindings_Generator` `Simple_Package` `Xar` |
| Basic building blocks | `Basic` (has `tests.jai`, `Print.jai`, `Array.jai`, `String_Builder.jai`, `Simple_String.jai`, `Int128.jai`, `Memory_Debugger.jai`, `Temporary_Storage_Flat_Pool.jai`, `Temporary_Storage_Paged_Alloc.jai`, `posix.jai`, `linux.jai`, `windows.jai`, `osx.jai`, `Apollo_Time.jai`, `float_to_string.jai`, `string_to_float.jai`, `examples`) `String` `System` `File` `File_Utilities` `File_Watcher` `Text_File_Handler` `Hash` `Hash_Table.jai` `xxHash` `meow_hash` `Crc.jai` `md5.jai` `Base64.jai` `Sort.jai` `IntroSort.jai` `RadixSort.jai` `Bit_Operations.jai` `Bit_Array.jai` `Bucket_Array.jai` `Random.jai` `PCG.jai` `Math` `Sloppy_Math.jai` `Float16.jai` `Unicode` `Deep_Copy.jai` `Color_Interpolation.jai` `Srgb.jai` `Ico_File.jai` `Icon.jai` `lz4` `Zip_File_Directory.jai` `Adpcm.jai` `Wav_File.jai` `Mail.jai` `Curl` `Command_Line.jai` `Protocol_For_Memory_Visualization.jai` `Memory` `Debug` |
| Allocators | `Default_Allocator` `Overwriting_Allocator` `Unmapping_Allocator` `Remap_Context.jai` `Pool.jai` `Flat_Pool.jai` (Basic's temp storage backends above) |
| Concurrency / OS services | `Thread` `Atomics.jai` `Shared_Memory_Channel.jai` `Process` `Socket` `POSIX` `Clipboard` `Subtitles.jai` `Keymap` |
| Imaging / media | `stb_image` `stb_image_resize` `stb_image_write` `stb_vorbis` `pl_mpeg` `freetype` (`freetype-2.12.1` is the vendored source tree) `meshoptimizer` `nvtt` `Sound_Player` |
| Graphics | `Simp` `Window_Creation` `Window_Type.jai` `Input` `ImGui` `GetRect` `GetRect_LeftHanded` `GL` `SDL` `Vulkan` `MojoShader` `Metal` `d3d11` `d3d12` `d3d_compiler` `dxgi` `dxc_compiler` `nvidia_aftermath` `Gamepad` |
| OS layers | `Windows.jai` `Windows_Registry.jai` `Windows_Resources.jai` `Windows_Utf8.jai` `Linux` `X11` `macOS` `Objective_C` `iOS` `Android` `POSIX` |

`System.jai`, `Sort.jai`, `Treemap`, `Subtitles.jai` are single files. `#import
"System"` compiled here with `get_path_of_running_executable` and
`set_working_directory` called from my own file; `seconds_since_init` appears in
`modules/Input/examples/input_test.jai` but I did not compile it myself.

## OS split (from `ls` of each module directory)

| Only meaningful on | Modules |
|---|---|
| Windows | `d3d11` `d3d12` `d3d_compiler` `dxgi` `dxc_compiler` `nvidia_aftermath` `nvtt` `Windows_Registry` `Windows_Resources` `Windows_Utf8` `BuildCpp` `modules/*/windows.jai` |
| macOS / iOS | `Metal` `Objective_C` `iOS` `macOS` `MacOS_Bundler.jai` `modules/*/macos.jai` |
| Android | `Android` (with `bindings.jai`, `Toolchain/`) |
| Linux | `X11` `Linux` `modules/*/linux.jai`, `modules/Input/x11.jai`, `modules/Socket/generated_linux.jai`, `modules/Vulkan/generated_linux.jai`, `modules/ImGui/linux`, `modules/SDL/linux`, `modules/Gamepad/linux.jai` |
| Cross-platform, per-OS `#load` | `Input` (`windows/macos/x11/android/ps5?/nintendo/android` files switched by `#if OS == { case ... }`), `Window_Creation` (`linux.jai` `windows.jai` `macos.jai` `android.jai`), `ImGui` (`linux` `macos` `windows` `unix.jai`), `SDL` (`linux` `macos`), `Socket`, `Sound_Player` (`os/{alsa,core_audio,aaudio,win32}.jai`), `MojoShader` (`linux` `mac` `win`), `Gamepad` (`evdev.jai` `IOHID.jai` `windows.jai` `macos.jai`) |

`Simp` has `backend/` plus `render_api` as a module parameter
(`NONE SOFTWARE OPENGL METAL NVN`) — pick the API at import time.

## Path A — Simp + Window_Creation + Input (compiles and links here)

```jai
#import "Basic";
#import "Math";
#import "System";
#import "String";              // path_strip_filename lives here
#import "Window_Creation";
Simp  :: #import "Simp";
Input :: #import "Input";

WIDTH :: 1280;  HEIGHT :: 720;
the_window: Window_Type;      // from modules/Window_Type.jai

main :: () {
    set_working_directory(path_strip_filename(get_path_of_running_executable()));
    the_window = create_window(WIDTH, HEIGHT, "Corvo", wanted_msaa = 4);
    Simp.set_render_target(the_window);
    font := Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", 32);  // *Simp.Dynamic_Font

    quit := false;
    while !quit {
        Input.update_window_events();
        for Input.events_this_frame {
            if it.type == .QUIT then quit = true;
            if it.type == {
                case .KEYBOARD; if it.key_pressed && it.key_code == .ESCAPE quit = true;
            }
        }

        reset_temporary_storage();                 // free the frame's temp allocator
        Simp.clear_render_target(0.3, 0.3, 0.35, 1);
        if font != null Simp.draw_text(font, 24, 24, tprint("hello jai %\n", 42));
        Simp.swap_buffers(the_window);
        sleep_milliseconds(8);
    }
}
```

`jai-linux main.jai -quiet` produced a 2.6 MB ELF with debug info. **I did not run
it** — running opens a window on the desktop. Notes verified while building it:

- `wanted_msaa` is passed to `create_window`, not to `prepare_window` only:
  `glx_create_context` gained a `window` argument so it can read GLX attributes
  at creation (CHANGELOG), and `Window_Creation`'s parameter is
  `DEFAULT_MSAA: s32 = 4`. `Simp.prepare_window(window, wanted_msaa) -> chosen_msaa: s32`.
- `Simp.set_render_target` has two forms: `(window: Window_Type, coords := Simp_Coordinate_System.RIGHT_HANDED)`
  and `(texture: *Texture, coords := ...)`. `Simp.get_render_dimensions(window) -> (s32, s32)`.
- `Simp.draw_text :: (font: *Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{1,1,1,1}, effects: Font_Effects = 0) -> width: s64`
  — the 5th argument is a `Vector4` color, not a number (passing `42` gave
  `Type mismatch. Type wanted: Vector4; type given: s64`).
- There is **no** argument-less `Simp.deinit()`: `deinit :: (bitmap: *Bitmap)`
  in `modules/Simp/bitmap.jai`. Calling `Simp.deinit()` gave
  `Not enough arguments: Wanted 1, got 0`.
- Font files are runtime data. Ship the `.ttf` next to the binary (the shipped
  examples do exactly this: `modules/Simp/examples/OpenSans-BoldItalic.ttf`,
  `modules/Input/examples/Skytree_by_MONTAGNA.ttf`).

Verified Simp entry points in use across the shipped examples (names confirmed by
grep of `Simp.<name>` usages, signatures only spot-checked where quoted above):
`clear_render_target` `clear_scissor` `disable_window` `draw_generated_quads`
`draw_prepared_text` `draw_text` `enable_window` `generate_quads_for_prepared_text`
`get_font_at_size` `get_image_bytes_per_texel` `get_render_dimensions`
`immediate_begin` `immediate_flush` `immediate_quad` `immediate_triangle`
`pixel_read_begin` `pixel_read_end` `prepare_text` `prepare_window`
`set_render_target` `set_scissor` `set_shader_for_color` `set_shader_for_images`
`set_shader_for_text` `swap_buffers` `texture_create_render_target`
`texture_load_from_file` `update_window`. Files: `module.jai` `font.jai`
`immediate.jai` `texture.jai` `texture_format.jai` `shader.jai` `bitmap.jai` `backend/`.

Verified `Input` surface: `update_window_events()`, `events_this_frame`,
`input_button_states` (indexed per key, test with `it & .DOWN`),
`mouse_delta_x|y|z`, `get_window_resizes()`, event fields `it.type`
(`.QUIT .KEYBOARD .TEXT_INPUT .MOUSE_WHEEL`; `input_test.jai:32` marks
`.WINDOW` with "@Incomplete: Event_Type.WINDOW events are not generated yet on any
of the platforms"), `it.key_pressed`, `it.key_code`,
`it.utf32`. `Key_Code` values start `UNKNOWN BACKSPACE TAB LINEFEED ENTER ESCAPE
SPACEBAR DELETE ARROW_UP ARROW_DOWN ARROW_LEFT ARROW_RIGHT …`. Program-slot
parameter: `X11_ENABLE_TOUCH_INPUT := false`.

## Path B — SDL + GL + ImGui (verified builds on this machine)

`modules/ImGui/examples/imgui_test.jai` and `imgui_inspector.jai` both compiled
and linked here: 4.7 MB and 4.47 MB executables. `imgui_sdl_gl.jai` is imported
as `ImGui :: #import "ImGui"; #import "SDL"; #import "Math"; #import "GL";` and
compiles clean in 0.2.030 (it has no `main`; it is meant to be `#load`ed — building
it alone gives `No program entry point was found`).

Verified ImGui call shapes: `ImGui.Begin(name, *show_inspector)`, `ImGui.End()`,
`ImGui.GetIO()` (its result has `DisplaySize` and `DisplayFramebufferScale`),
`ImGui.ImDrawData` with `ScaleClipRects`. ImGui is a binding layer over the C++
Dear ImGui sources in `modules/ImGui/linux` (a prebuilt `ImGui.a`).

**ImGui alone does not link on Linux.** A file that only imports `ImGui` fails at
the linker:

```
lld-linux: error: undefined symbol: cosf
>>> referenced by imgui_draw.cpp  imgui_draw.o:(ImDrawListSharedData::ImDrawListSharedData())
           in archive /home/sam/.local/opt/jai/modules/ImGui/linux/ImGui.a
```

`#library,system "m"` and `#library,system "libm"` in an import block did **not**
fix it. What worked, verified end to end (binary built, ran, exit 0):

```jai
// build.jai
#import "Basic";
#import "Compiler";
#run build();
build :: () {
    w := compiler_create_workspace("Target");
    o := get_build_options();
    o.output_executable_name = "withlm";
    o.additional_linker_arguments = string.["-lm"];   // Build_Options field
    set_build_options(o, w);
    add_build_file("prog.jai", w);                    // prog.jai imports ImGui
    set_build_options_dc(.{do_output = false});
}
```

`append_linker_arguments` is **not** a `Build_Options` member — it belongs to
`Build_Options_During_Compile` (`modules/Compiler/Compiler.jai:183` and `:205`), so
either set `additional_linker_arguments` on the options or pass
`set_build_options_dc(.{append_linker_arguments = string.["-lm"]})`.
`use_custom_link_command := false` (`:177`) plus the
`READY_FOR_CUSTOM_LINK_COMMAND` message is the "control linking completely" route
(`modules/Compiler/examples/compile_me.jai:93`).

Importing `SDL` brings its own link requirements with it, which is why the SDL+GL
examples link without extra arguments. From `modules/SDL/module.jai:67-75`:

```jai
SDL2 :: #library "windows/SDL2";
SDL2 :: #library "macos/libSDL2";
#library,system,link_always "libdl";
#library,system,link_always "libm";
SDL2 :: #library "linux/libSDL2";      // modules/SDL/linux/libSDL2.a and .so ship in the install
```

`modules/SDL/linux/` contains `libSDL2.a` and `libSDL2.so`, so the SDL path does
not need a system SDL2 dev package. `#library` forms seen in real code:
`#library "path"`, `#library,system "libc"` (`modules/Socket/generated_linux.jai:2301`),
`#library,system "libXi"` (`modules/Input/x11.jai:983`),
`#library,system,link_always "libm"`. `modules/Window_Creation/linux.jai:219` has a
commented-out `// libc :: #library,system "libc";`.

## Audio, gamepads, key maps

- `Sound_Player`: `#module_parameters (MAX_SOUND_CATEGORIES := DEFAULT_MAX_SOUND_CATEGORIES, VERBOSE := false)`
  (compile-time slot). Import it namespaced with `using`:
  `using Sound :: #import "Sound_Player"(VERBOSE = false);` (that exact line is
  `modules/Sound_Player/examples/audio_without_window.jai:61`). Linux backend is
  `os/alsa.jai`; others are `os/{core_audio,aaudio,win32}.jai`. Types seen in the
  examples: `Sound_Data`, `Sound_Category.GENERAL_SFX`, `Sound_Stream`; the
  examples call `Sound.update` each frame and write their own `stage_sound` helper.
  Example media ships alongside: `click.wav`, `lux_aeterna.ogg`. Read
  `module.jai` + `load.jai` + `cached_decoder.jai` + `async.jai` for the play API —
  the examples do not enumerate it.
- `Gamepad`: header documents `init_gamepad :: ()` once at startup and
  `update_gamepad :: ()` once per frame *after* `update_window_events()`; basic use
  is in `modules/Gamepad/example.jai`; Linux uses `evdev.jai` and bundles
  `libevdev.a` / `libevdev.so.2`; `SDL_Input_Map.jai` maps SDL controller inputs.
  macOS caveat from the module header: Apple's Game Controller framework, MFi-certified
  controllers only, and inputs only update inside an AppKit loop
  (`modules/Objective_C/examples/cocoa.jai`).
- `Keymap`: header's first line is literally `// To do: Document!` — read
  `module.jai` and `save.jai`; `Keymap_Set` holds `Bucket_Array(Keymap, 16, true)`
  and a `default_keymap`.

## Reading shipped code without being misled

- Top-level `~/.local/opt/jai/examples`: `add_build_string_into_specific_scope`
  `beta_key_mailer` `code_type.jai` `codex_view` `d3d11_example` `dll` `dump_binary_file.jai` `find_symbol.jai`
  `hash_table_test.jai` `here_string_detector.jai` `import_replacement` `invaders`
  `ios_library` `module_info.jai` `output_types` `reduce.jai`
  `runtime_global_data_search.jai` `self_inspect.jai` `skeletal-animation`
  `subtitles` `system_info` `treemap` `VR` `wasm`.
  `treemap/build.jai` builds here. `invaders` builds for Android/Switch with
  `+Android/Toolchain` / `+Nintendo/Toolchain` — not probed here.
- A module comment that says `examples/foo.jai` means **that module's** examples
  directory: `modules/Sound_Player` points at `examples/audio.jai`, which is
  `modules/Sound_Player/examples/audio.jai`.
- Module headers carry honest staleness notes. `modules/GetRect/module.jai` opens
  with a To-Do list: `widgets/text_display is not done`, "Don't require ui_init to
  be called (?)", "Input and event handling can use a substitute type rather than
  just modules/Input", "Example of not using Simp (Draw_Procs pluggability test)",
  "Make DPI-Aware easy". `GetRect` is a retained widget toolkit (widgets, popups,
  scissor/state bookkeeping: `draw_popups`, `stop_using_state`) with
  `GetRect_LeftHanded` as the left-handed variant; `Simp` is the low-level immediate
  renderer. Pick `Simp` first unless you want widgets.
- `#c_call` appears in the older SDL/GL ImGui port
  (`ImGui_ImplSdl_RenderDrawLists :: (draw_data: *ImGui.ImDrawData) #c_call`), and
  `xx` shows up as a cast helper in the same file (`glGetIntegerv(GL_ACTIVE_TEXTURE, xx *last_active_texture)`)
  — that file compiles in 0.2.030, but treat generated/ported bindings as
  unfamiliar code, not as style guidance.
