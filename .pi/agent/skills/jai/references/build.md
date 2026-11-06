# Building JAI (beta 0.2.030, Linux)

## One file, no build system

```sh
jai-linux main.jai -quiet     # compile + link; objects go to .build/
./main                        # Linux binary is named after the source file
jai-linux main.jai -quiet -exe mygame   # custom name
```

Without `-quiet` the compiler prints the full `lld-linux` link line plus lexer,
parser, type-check and code-gen stats with timings. The link line is where you
see what the compiler actually does: `-L /home/sam/.local/opt/jai/modules/` plus
crt paths — the default module import path is baked in, no env var needed.

Artifacts: `.build/<file>_<n>_w<workspace>.o` (e.g. `main_0_w2.o`), and the
executable. `file main` on a debug build reports ELF 64-bit, dynamically linked,
`with debug_info`, `not stripped`. Gitignore `.build/` and the binary.

## Several files: `#load`, then `build.jai`

Local files in one program are pulled in with `#load` (semicolon required).
Verified layout:

```
proj/  main.jai  helper.jai
```

```jai
// main.jai
#import "Basic";
#load "helper.jai";
main :: () { helper(); }
```

Compile `main.jai` and the whole program builds. For a bigger tree, this install
aggregates in a `build.jai` — `examples/treemap/build.jai` is the real pattern:
it `#load`s each source, `#import "Simp"` and `#import "Window_Creation"`, and
ends with `#import "Basic"; #import "System"; // For path_strip_filename`.

`#import "String"` is needed for `path_strip_filename`: without it a starter file
fails with `Undeclared identifier 'path_strip_filename'`.

## build.jai metaprogram (verified template)

Build a named executable with its own options:

```jai
// build.jai  ->  jai-linux build.jai -quiet
#import "Basic";
#import "Compiler";

#run build();

build :: () {
    w := compiler_create_workspace("Target");
    options := get_build_options();
    options.output_executable_name = "mygame";
    set_optimization(*options, .DEBUG);
    set_build_options(options, w);
    add_build_file("src/main.jai", w);
    set_build_options_dc(.{do_output = false});   // the metaprogram file itself is not the program
}
```

Compiled here and produced `mygame` from `src/main.jai`. Verified API names from
`modules/Compiler/Compiler.jai`:

- `get_build_options :: (w: Workspace = -1) -> Build_Options`
- `set_build_options :: (options: Build_Options, w: Workspace = -1, loc := #caller_location)` — relative import paths resolve against the caller's file
- `set_build_options_dc :: (options: Build_Options_During_Compile, w: Workspace = -1)` (`_dc` = "during compile")
- `set_optimization :: (using build_options: *Build_Options, type: Optimization_Type, preserve_debug_info := true)`
- `Optimization_Type`: `DEBUG VERY_DEBUG OPTIMIZED OPTIMIZED_SMALL OPTIMIZED_VERY_SMALL`
- `compiler_create_workspace`, `add_build_file` (verified by use, declared `#compiler` intrinsics)
- `Build_Options.stack_trace` defaults to `true` (`Compiler.jai:107`) — user-space stack traces are compiled in unless you turn this off; `-no_backtrace_on_crash` suppresses the crash backtrace.

`how_to/400_workspaces.jai` explains workspaces, `420_command_line.jai` how to drive the build from CLI args, `450_basic_metaprogram/` and `470_running_hooks_in_the_target_workspace/` are worked examples (`first.jai` + `target.jai` pairs), `480_custom_checks/` shows custom analyses over the target's syntax trees, `630_compiler_get_nodes.jai` and `460_code_browsing_and_generation/` + `490_browsing_by_module/` cover reading a program as data.

## Flags

Accepted here (no diagnostics emitted; effect not individually measured unless noted):

| Flag | Observed |
|---|---|
| `-quiet` | hides link line + stats |
| `-verbose` | accepted |
| `-o` `-od` `-very_debug` | accepted; the enum they correspond to is `Optimization_Type` (`DEBUG VERY_DEBUG OPTIMIZED VERY_OPTIMIZED OPTIMIZED_SMALL OPTIMIZED_VERY_SMALL`) |
| `-exe NAME` | writes `NAME` (verified: `-exe mybin` → `mybin`) |
| `-output_path DIR` | verified `out/t`; **the directory must already exist** or `lld-linux: error: cannot open output file ...` |
| `-import_dir DIR` | accepted (modules already resolve by default) |
| `-add 'CODE'` | injects code; lands in `.build/.added_strings_w2.jai` as `X :: 42;;`. Quote it whole: broken quoting turns `42;` into filenames — `Unable to open file '/tmp/jai_probe/42;"'` |
| `-no_color` `-msvc_format` `-natvis` | accepted. `-msvc_format` is the `file(line): error` form for IDE parsing. `-natvis` pairs with `~/.local/opt/jai/editor_support/msvc/` (`jai.natvis`, `jai.natstepfilter`): the README there says copy both to `%USERPROFILE%\Documents\Visual Studio 2022\Visualizers`, then compile with `jai first.jai -natvis` for nicer watch-window views of arrays, strings, Type_Infos and some Math types |
| `-x64` `-llvm` | accepted; `modules/linux_build.jai` sets `options.backend = .X64` with the comment "No LLVM support yet" |
| `-no_check` | skips `modules/Check`; without it you get augmented checks, e.g. `print()` argument counts |
| `-no_check_bindings` | documented in `-help` |
| `-no_dce` `-no_split` `-no_inline` | accepted |
| `-context_size 2048` | accepted |
| `-debugger` `-debug_for` | accepted |
| `-no_backtrace_on_crash` | accepted |

Rejected in this build, despite appearing in docs: `-meta NAME` and `-plug NAME`
both give `Unknown argument`. Live forms:

```sh
jai-linux main.jai --- meta Minimal_Metaprogram   # three dashes
jai-linux main.jai +Program_Print                 # plugin, by name
jai-linux main.jai +Codex                          # verified: builds program.json, build.json, .codex/
```

`how_to/495_default_metaprogram.jai:36` (`jai my_file.jai -plug Plugin_Module_Name`)
and the header of `modules/Program_Print/module.jai:4` (`// -plug Program_Print`)
still document `-plug`; both are stale relative to 0.2.030. `CHANGELOG.txt:1147` is
the change itself: "Instead of -plug, now arguments that start with + are the names
of plugins", and `:1173` removed the `-plugin` alias. `-ext ttf` appears in a
comment in `modules/Input/examples/input_test.jai:165` for Android builds
(`+Android/Toolchain -ext ttf`) — I did not probe it.

Plugins and metaprograms in this install: `modules/Default_Metaprogram.jai`
(the default front end for `#import`), `modules/Minimal_Metaprogram.jai`,
`modules/Check/module.jai` (auto-imported unless `-no_check`),
`modules/Example_Plugin.jai`, `modules/Metaprogram_Plugins.jai`,
`modules/linux_build.jai`, `modules/Performance_Report.jai`,
`modules/Project_Generator.jai`, `modules/Autorun.jai`, `modules/Subtitles.jai`,
`modules/Treemap` (`CHANGELOG.txt:3927`: "Added modules/Treemap, for generating
squarified treemaps; and examples/treemap, showing how to use these"). I did not
probe `+Treemap` on a command line.

`modules/linux_build.jai` is for **cross-compiling Windows → Linux** with the
Unreal Engine v21 Clang 15.0.1 toolchain (set `LINUX_MULTIARCH_ROOT` if installed
elsewhere). Do not run it on a native Linux box: the native compiler already
links with `lld-linux`. Cross-compiling rules, host vs target, and what a
toolchain is: `how_to/950_cross-compiling/` (`first.jai`, `simple.jai`,
`do_things_at_compile_time*.jai`); Android toolchain use appears in
`modules/Input/examples/input_test.jai` (`+Android/Toolchain`) and
`examples/invaders` (`+Nintendo/Toolchain`).

## Module parameters

Two slots on an import. Compile-time parameters go in the first group; program
parameters go after `()`:

A module declares them as `#module_parameters (compile-time group) (program group)`.
An import mirrors those two slots: `#import "X"(ct-params)(program-params)`.
Which slot a parameter lives in is not optional — read the module's own line
(`grep -n "#module_parameters" <module>/module.jai`).

```jai
Simp   :: #import "Simp"(render_api = .NONE);          // compile-time slot
Win    :: #import "Window_Creation"(DEFAULT_MSAA = 8); // compile-time slot
Check  :: #import "Check"(CHECK_BINDINGS = false);     // compile-time slot
Debug  :: #import "Debug"(USE_GRAPHICS = false);       // compile-time slot
#import "Basic"()(MEMORY_DEBUGGER = true);             // program slot (Basic's ct group is empty)
#if OS == .ANDROID  #import "Android"()(main);         // program slot, in real code
```

`#import "Window_Creation"()(DEFAULT_MSAA = 8);` →
`Error: This module has an empty program parameter list, but it was called with
parameters`. The import that defines the parameters must come before any other
import of that module in the program (stated in `how_to/380_module_parameters/`).

Verified parameter declarations (`grep -n "#module_parameters" <module>/module.jai`):

| Module | Line in `<module>/module.jai` | Slot |
|---|---|---|
| `Simp` | `(render_api := Render_API.OPENGL)()` — `Render_API`: `NONE SOFTWARE OPENGL METAL NVN` | compile-time |
| `Window_Creation` | `(DEFAULT_MSAA: s32 = 4)` | compile-time |
| `Check` | `(CHECK_BINDINGS := true)` | compile-time |
| `Debug` | `(USE_GRAPHICS := true)` | compile-time |
| `Basic` | `() (MEMORY_DEBUGGER := false, ENABLE_ASSERT := true, REPLACEMENT_INTERFACE: $I/interface Memory_Debugger_Interface, VISUALIZE_MEMORY_DEBUGGER := true, TEMP_ALLOCATOR_OVERWRITE_MEMORY := false)` | program (ct group empty; the last two only matter when `MEMORY_DEBUGGER` is true) |
| `Input` | `()(X11_ENABLE_TOUCH_INPUT := false)` | program |
| `GetRect` | `()(Type_Indicator: Type = void)` | program |

`File` and `Socket` have no `#module_parameters` line in their `module.jai`.

Module parameters vs program parameters: `how_to/380_module_parameters/`
(`first.jai` + `local_modules/`).

## Leaks, asserts, checks

```jai
#import "Basic"()(MEMORY_DEBUGGER = true);
#import "Debug";
leak := New(int);
report_memory_leaks();
```

Prints the leak with its allocation site (`New .../modules/Basic/module.jai:364`,
`main /tmp/.../md2.jai:4`) and totals. `assert(cond, "message")` is runtime;
`#assert(cond)` is compile-time (`Error: Compile-time assertion failed.`).
`assert(false)` aborts with `Assertion failed!` and a stack trace.

## Tests and doc comments (as they actually appear in this install)

There is no test runner and no test flag: `jai-linux -help` mentions only
`-no_check` and `-no_check_bindings`. Tests in shipped modules are plain
procedures of asserts, some closed with the code attribute `@test`, then called
by a local runner — `modules/Basic/tests.jai` (713 lines, ends with a `main` and
a commented `// #run main();`) and `modules/Math/tests.jai` (ends with
`log("ALL OK")`). `@test` compiles; so does an invented `@bogusthing` — this beta
emitted no diagnostic for it, so attributes are not a correctness gate. Assert
your own invariants and run the binary.

Doc comments are `/** ... */` with javadoc-ish tags, used heavily by the shipped
generated bindings (`modules/Android/bindings.jai:17`:
`/** Available access modes for opening assets with {@link AAssetManager_open} */`).
Counts in this tree: `@link` 902, `@param` 796, `@return` 430, `@description` 405,
`@note` 315, `@struct` 138, `@fields` 110, `@function` 107, `@see` 84.
`@deprecated` also appears inside doc comments (`modules/Android/bindings.jai:1647`:
`* @deprecated These constants are deprecated. Use {@link AMOTION_EVENT_AXIS
AMOTION_EVENT_AXIS_*}`); `#deprecated` as a directive appears 23 times in module
sources. `how_to/README.txt` in this install does not document them.

## Project shape for a game

```
mygame/
  build.jai        # metaprogram, or a #load aggregator
  src/             # #load'd or add_build_file'd sources
  data/            # fonts, images, audio
  .build/          # scratch, gitignore
```

Fonts and assets are read at runtime by path. The shipped examples put the
`.ttf` next to the source and do
`set_working_directory(path_strip_filename(get_path_of_running_executable()));`
(`modules/Input/examples/input_test.jai`, which needs `#import "String"` for
`path_strip_filename`). `Simp.get_font_at_size(base_dir, file, height)` takes the
directory as its first argument. `modules/Simp/examples/` ships
`OpenSans-BoldItalic.ttf`; `Sound_Player/examples/` ships `click.wav` and
`lux_aeterna.ogg`.
