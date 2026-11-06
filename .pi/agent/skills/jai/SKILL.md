---
name: jai
description: Write, build and debug JAI (.jai) with the local jai/jai-linux compiler. Beta-0.2 syntax traps, build.jai metaprograms, module map, Simp windowing. Load for any JAI task.
---

# JAI

Everything in this skill was checked against the local install. JAI is beta and
its surface moves every release, so **do not write JAI from memory of JAI**: read
the local doc for the construct, then let the compiler judge.

Version: `beta 0.2.030, 2 July 2026` — read it with `head -1 ~/.local/opt/jai/CHANGELOG.txt`.
`jai-linux -version` prints nothing (exit 0, zero bytes) on this build.

## Install

| What | Where |
|---|---|
| Linux compiler | `~/.local/bin/jai-linux` → `~/.local/opt/jai/bin/jai-linux` |
| Windows compiler | `jai.exe` on PATH, invoke as `jai` |
| Language tree | `~/.local/opt/jai/{bin,modules,how_to,examples,CHANGELOG.txt,README.txt}` |
| Linker | `~/.local/opt/jai/bin/lld-linux`, invoked for you |

`#import "Basic";` finds `~/.local/opt/jai/modules` with no env var and no
`-import_dir`: the path is baked into the binary (the link line contains
`-L /home/sam/.local/opt/jai/modules/` even when compiling from `/tmp`).

Prerequisites from `README.txt`: Windows needs a Windows SDK plus a Visual C++
Redistributable (`redist/` ships `winsdksetup.exe`); macOS needs libpthreads;
Linux binaries are built for Ubuntu 18.04.

## Build-and-check loop

```sh
jai-linux main.jai -quiet      # compile+link the whole program
./main                         # Linux output is named after the source, no .exe
```

There is no make, no build system, no link step to script: one compiler
invocation compiles the file you name plus everything `#load` pulls in. Object
files land in `.build/` next to the source (gitignore it; it is scratch).
`-quiet` hides the linker command line and the compile stats; without it you get
linker args, lexer counts, and per-phase timings.

For a multi-file project the pattern in this install is a `build.jai` that
`#load`s your files and imports modules (`examples/treemap/build.jai`), or a
`build.jai` metaprogram that creates a workspace. Both are in
`references/build.md`; the workspace form is the one that gives you a named
executable and per-target options.

## The compiler is your LSP

pi-lens ships tree-sitter grammars for bash, css, go, html, js, java, json,
python, rust, tsx, typescript, yaml — **not** for JAI, and no JAI language
server is on PATH. So `module_report`, `symbol_search` and cached diagnostics
will not help you on `.jai`. `jai-linux <file> -quiet` *is* the standing
instrument: run it after every edit batch, and check the exit rather than
assuming silence means clean. Compiler messages are good — they quote the
offending line, point at the column, and name the declaration site:

```
Error: Type mismatch. Type wanted: Vector4; type given: s64.
Info: ... in checking argument 5 of call to draw_text.
```

Runtime failures are also readable: `assert(false)` prints `Assertion failed!`
plus a `file:line function` stack trace (stack traces are compiled in by
default, `build_options.stack_trace`, see `how_to/700_stack_trace.jai`;
suppress the crash backtrace with `-no_backtrace_on_crash`). A constant
out-of-range subscript is caught at compile time:
`Subscript is out of array bounds. (The attempted index is 7, but the highest
valid index is 2.)`

## Read the local doc before writing syntax

`~/.local/opt/jai/how_to/README.txt`: read, compile and run these in numerical
order; directories sort with the files. `ls ~/.local/opt/jai/how_to | wc -l` = 67
entries (files and example directories together). Topics I have matched to
files:

| Topic | Files |
|---|---|
| First program, types, numbers, booleans | `001_first.jai` `002_number_types.jai` `003_booleans.jai` `008_types.jai` `020_type_info.jai` |
| Calling, parameters, `this`, variadics | `010_calling_procedures.jai` `250_how_parameters_are_passed.jai` `050_this.jai` `225_comma_comma.jai` |
| Arrays and array literals | `004_arrays.jai` `015_array_literals.jai` `094_array_operators.jai` |
| Structs, struct literals, type variants | `006_structs.jai` `007_struct_literals.jai` `180_type_variants.jai` `160_type_restrictions.jai` |
| Strings, printing, logging | `005_strings.jai` `018_print_functions.jai` `350_logging.jai` |
| Looping, `if`, `ifx`, `case` | `019_looping.jai` `022_if.jai` `025_ifx.jai` `027_if_case.jai` `095_static_if.jai` |
| Enums | `013_enums.jai` `014_enum_unary_dot.jai` |
| Context, allocators, temporary storage | `011_context.jai` `012_temporary_storage.jai` `800_allocators.jai` `200_memory_management.jai` |
| Pointers, any, scopes | `030_any.jai` `080_scopes.jai` `151_file_and_global_scopes/` `042_using.jai` `044_using_advanced/` |
| Polymorphic procedures and structs, auto-bake | `100_polymorphic_procedures.jai` `110_polymorphic_arguments.jai` `115_auto_bakes.jai` `120_polymorphic_structs.jai` |
| Operator overloading, typechecking | `093_operator_overloading.jai` `090_how_typechecking_works.jai` |
| `#run`, constants, compile-time traps | `500_use_of_compile_time_execution.jai` `550_is_constant.jai` `551_things_that_are_constant.jai` `560_no_reset.jai` `480_custom_checks/` |
| Compile-time code rewriting | `170_modify.jai` `600_insert.jai` `730_for_expansions.jai` `497_caller_code.jai` `900_inline_assembly.jai` |
| Module parameters | `380_module_parameters/` (`first.jai` + `local_modules/`); the real declarations are in each `<module>/module.jai` |
| Workspaces, build scripts, plugins, CLI | `400_workspaces.jai` `420_command_line.jai` `450_basic_metaprogram/` `470_running_hooks_in_the_target_workspace/` `495_default_metaprogram.jai` `480_custom_checks/` |
| Browsing the program as data | `460_code_browsing_and_generation/` `490_browsing_by_module/` `630_compiler_get_nodes.jai` |
| Cross-compiling | `950_cross-compiling/` (host vs target, toolchains) |
| Design stance | `999_temperance.jai` (why JAI avoids growing code) |

For a feature name, grep `CHANGELOG.txt` (9634 lines) before assuming it exists:
`grep -n "flat_pool" ~/.local/opt/jai/CHANGELOG.txt`. Some `how_to` text is
stale relative to this build — see the traps below.

## Traps in this beta (each one produced a real compiler error here)

- **Directives need `;`** — `#import "Basic"` bare → parse error. Same for `#load`, `#add_context`.
- **`int` is 64-bit.** `#assert size_of(int) == 4;` fails; `== 8` compiles.
- **`if_case` is gone.** Use `if value == { case .A; stmt; case .B; stmt; case; default_stmt; }`. One value per `case` (`case .A, .B;` → `';' expected`). `case;` is the default; `#through` falls through. The file is still named `027_if_case.jai`.
- **`ifx` is an expression and needs `then`.** `x := ifx cond then a else b;`. The statement-looking form `ifx cond print(...); else print(...);` → `'else' without 'if'`.
- **`remove it` needs a `[..]` array.** On a fixed array: `'remove' is not valid on a fixed-size array`.
- **Array literals are typed.** `int.[1,3,5]`, `string.["a","b"]`, `.[1,2,3]` when the type is known, nested `([3] float).[.[0,0,0], .[0,1,1]]`.
- **Pointer syntax is `*x` and `p.*`.** `*p += 1` does not parse. Arrays of pointers index as `arr.*[i]`.
- **Module symbols collide.** `#import "Math"` already declares `Vector3` → `Redeclaration of 'Vector3'`. Namespace it: `Math :: #import "Math";` then `Math.Vector3`.
- **Module parameters have two slots.** Compile-time params go in the first group: `Simp :: #import "Simp"(render_api = .NONE);`. Program params go after `()`: `#import "Basic"()(MEMORY_DEBUGGER = true);`. Wrong slot → `This module has an empty program parameter list, but it was called with parameters`. The parameter-defining import must come before any other import of that module.
- **`-meta` and `-plug` do not exist.** Live forms are `--- meta Minimal_Metaprogram` (three dashes) and `+Plugin_Name`. `how_to/495_default_metaprogram.jai` and the header of `modules/Program_Print` both still say `-plug`; they are stale.
- **`Simp.deinit` takes `*Bitmap`.** There is no global `Simp.deinit()` in this build → `Not enough arguments: Wanted 1, got 0`.
- **`Pool` has no `init_pool`.** Real API: `get(*pool, bytes)`, `set_allocators(*pool)`, `pool_allocator_proc`, `reset(*pool)`, `release(*pool)`. Its own header says prefer `modules/Flat_Pool.jai`.
- **No `#print` directive.** Compile-time printing is `#run print("...\n");`. Directives with zero occurrences in this tree: `#packed` `#optional` `#from` `#generated_from` `#polymorphic` `#foreign_library` `#breakpoint` `#require` `#defers`.
- **In module comments, `examples/foo.jai` means that module's own examples dir.** `modules/Sound_Player` points at `examples/audio.jai`; the file is really `modules/Sound_Player/examples/audio.jai`, not `~/.local/opt/jai/examples/audio.jai`.

## Memory and context, by default

Allocation goes through `context.allocator` (`proc` + `data`). `New(Type)` and
`NewArray` come from `Basic`; per `CHANGELOG`, `NewArray` now returns an empty
array and null when the allocation fails. `defer free(x)` cleans up on scope
exit. Temporary work uses the `temp` allocator and `reset_temporary_storage()`
at the top of a frame (`how_to/012_temporary_storage.jai`, `800_allocators.jai`).
Swap an allocator for a subtree with `new_context := context; new_context.allocator = ...; push_context new_context { }`.

Turn on the leak detector and print sites:

```jai
#import "Basic"()(MEMORY_DEBUGGER = true);
#import "Debug";
// ... at exit:
report_memory_leaks();
```

Output seen here: `----- 8 bytes in 1 allocation -----` with `New .../Basic/module.jai:364` and `main /tmp/.../md2.jai:4`.

## References (read on demand)

- `references/syntax.md` — declarations, arrays, `for`, `if`/`case`/`ifx`, structs, enums, pointers, strings, memory, directives. Every snippet compiled here.
- `references/build.md` — `build.jai` templates, verified vs rejected compiler flags, plugins, module parameters, workspaces, cross-compile.
- `references/modules.md` — module map from `ls ~/.local/opt/jai/modules`, OS-specific splits, and a Simp/Input windowed starter that compiles and links on this Linux box (it was not *run*: running it opens a window).
