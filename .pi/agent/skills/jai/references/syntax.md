# JAI syntax, verified against beta 0.2.030

Every snippet below either compiled and ran here (probes in `/tmp/jai_probe`,
binary output quoted where it matters) or is copied from a file in
`~/.local/opt/jai`. Nothing here is remembered from another JAI version.

## Declarations

```jai
a    : int  = 5;      // typed and initialized
b    : int;           // declared, default-initialized
c    := 6;            // type inferred from value
d    : int : 7;       // constant
e, f : float;         // compound declaration
WIDTH  :: 1280;       // compile-time constant (modules/Input/examples/input_test.jai)
my_window: Window_Type;
```

No implicit ints, no untyped literals: `how_to/002_number_types.jai`,
`085_default_types_for_literals.jai`.

## Procedures

```jai
add  :: (x: int, y: int) -> int { return x + y; }

// named multiple returns
get_strings :: (x: int) -> (success: bool, result: [] string) {
    if x & 1 return true, .["odd", "words"];
    return false, string.[];
}

sq :: x => x * x;                     // procedure literal
poly :: (x: $T) -> T { return x * x; }   // polymorphic: $T bakes a type
```

Call with named arguments by `name = value`: `create_window(1280, 720, "T", wanted_msaa = 4)`.
Comma-comma shorthand for temporary context changes (allocator swaps): `how_to/225_comma_comma.jai`.
Polymorphic gotchas: `100_polymorphic_procedures.jai`, `110_polymorphic_arguments.jai`,
`115_auto_bakes.jai`, `120_polymorphic_structs.jai`.

## Arrays

```jai
numbers := int.[1, 3, 5, 7, 9];              // fixed [5] int
res     : [..] int;                          // resizable ("dynamic")
fixed   : [20] int;                          // fixed 20
view    : [] int = res;                      // array view; .count, .data
ramp    := ([3] float).[.[0,0,0], .[0,1,1]]; // array of arrays
teas    := string.["Earl Gray", "Hot Cinnamon Spice"];
empty   := string.[];                        // empty, typed

array_add(*res, 42);                         // append to [..]
for 1 .. 3 array_add(*res, it);
for res if (it & 1) == 0 remove it;          // 'remove' is [..] only
```

Ran here from `int.[1,3,5,7,9]` and appends: `view [42, 1, 2, 3, 4], count 5, fixed count 20`.
Docs: `004_arrays.jai`, `015_array_literals.jai`, `094_array_operators.jai`.

## Looping

```jai
for numbers print("% = %\n", it_index, it);   // implicit 'it' + 'it_index'
for value, i: numbers print("%: %\n", i, value);
for 1 .. 3 { print(it); }                     // integer range, INCLUSIVE
for i: 0..10 { if i == 3 continue; if i == 5 break; }
for number: 1..7 { }                          // named iterator
for a..b { }                                  // endpoints are expressions, evaluated once
for < b..a { }                                // reverse order (019)
for * teas { it.* = split(it.*, " ")[0]; }    // iterate pointers, mutate in place
for j: 1..4 { for i: 11..14 { break j; } }    // break out of the named outer loop
```

`for i: 0, 10 { }` does not parse. Reverse-rule from `019_looping.jai`: with `<`,
"b still must be less than a for any iterations to happen".

## if / case / ifx

```jai
if a > 4 { } else if a == 4 { } else { }
ifx a > 100 then "huge" else "not huge";      // expression, 'then' is required
msg := ifx a > 100 then "huge" else "small";

f : Fruit = .BANANA;
if f == {                                      // 'if_case' is gone in this beta
    case .BANANA; print("banana\n");          // one value per case, then ';'
    case .APPLE;  print("apple\n");
    case;         print("other\n");           // 'case;' = default
}
```

`case .APPLE, .KIWI;` → `';' expected`. `case .APPLE { }` → `';' expected`.
Fall through with `#through`. Type-matched arms are required for `ifx`.
Docs: `022_if.jai`, `025_ifx.jai`, `027_if_case.jai`, `095_static_if.jai` (`#if`).

## Structs and enums

```jai
Ice_Cream :: struct {                 // ':= ' in a field = default value
    temperature := -10.0;
    flavor      := "vanilla";
    num_scoops  := 2;
}

order1 := Ice_Cream.{flavor = "chocolate", num_scoops = 3};   // field names, no leading dot
order2 : Ice_Cream = .{};                                      // all defaults
v      := Math.Vector3.{1, 2, 3};                              // positional

Fruit :: enum u32 { BANANA :: 5; APPLE; KIWI; }
f : Fruit = .BANANA;                    // unary '.' needs a known type
```

Printed here: `chocolate 2 3`. Docs: `006_structs.jai`, `007_struct_literals.jai`
(nested field syntax like `Body.{name = "Ginger", values[1] = 7}` appears there),
`013_enums.jai`, `014_enum_unary_dot.jai`, `180_type_variants.jai`.

## Pointers

```jai
x := 3;
p : *int = *x;          // address-of is a prefix '*'
p.* += 1;               // dereference is '.*'  ( '*p += 1' does not parse )
print(p.*);             // x is 4 as well
array.*[0] = 1;         // indexing through an array-of-pointers declaration
```

## Memory, allocators, context

```jai
array := New([3] int);  // Basic provides New / NewArray
defer free(array);

pool: Pool;
new_context := context;
new_context.allocator.proc = pool_allocator_proc;
new_context.allocator.data = *pool;
set_allocators(*pool);                 // Pool needs a source of backing memory
push_context new_context {
    n   := New(int);                   // this New comes from the Pool
    n.* = 99;
}
print(pool.memblock_size - pool.bytes_left);   // 16 bytes here
release(*pool);

#add_context silly_number: int = 33;   // file-level context extension
// ...
context.silly_number += 1;             // readable as context.silly_number
```

`Pool` has no `init_pool`; its header says `Flat_Pool` is the simpler choice
(`modules/Pool.jai`, `modules/Flat_Pool.jai`). Docs: `011_context.jai`,
`012_temporary_storage.jai`, `200_memory_management.jai`, `800_allocators.jai`.

## Strings, printing, logging

```jai
sb : String_Builder;
init_string_builder(*sb);
print_to_builder(*sb, "n=%\n", add(a, c));
append(*sb, "more\n");
print(builder_to_string(*sb));                    // n=11 / more

print(join(.. .["foo", "bar"], ", "));            // joined foo, bar
print(split("a b", " ")[1]);                      // b
print(formatFloat(1/3.0, width=4, trailing_width=3, zero_removal=.NO));  // 0.333
print(tprint("count %\n", 3));                    // formatted string, no output
log("a log line %\n", 5);                         // goes through context logger
```

`print` takes `%` placeholders positionally; the compiler checks the argument
count for you via the `Check` plugin unless you pass `-no_check`. Full list of
print-family procedures in `018_print_functions.jai` (it documents `sprint`,
`read_line` etc. — I did not compile each one). Logging conventions
(`Context_Base.logger`): `350_logging.jai`. Strings are array views (`[] u8`),
see `005_strings.jai`.

## Compile-time execution

```jai
#assert size_of(int) == 8;             // int is 64-bit
#run print("compile-time print\n");    // printed during compilation
#run build();                          // call a procedure at compile-time

#if OS == {                            // compile-time OS switch, switch form
    case .WINDOWS; #load "windows.jai";
    case .LINUX;   #load "x11.jai";
    case .MACOS;   #load "macos.jai";
    case .ANDROID; #load "android.jai";
}
#if OS == .LINUX print("on linux\n");
```

`OS` values seen in this install: `.WINDOWS .LINUX .MACOS .ANDROID .PS5 .NN_SWITCH2`
(`modules/Input/module.jai`). `#print` does not exist. Global compile-time state
does not leak into runtime — `560_no_reset.jai`. Constness rules:
`550_is_constant.jai`, `551_things_that_are_constant.jai`. Rewriting and expansion:
`170_modify.jai` (`#modify`), `600_insert.jai` (`#insert`), `730_for_expansions.jai`,
`497_caller_code.jai` (`#caller_location` / caller code), `900_inline_assembly.jai`.

## Directives present in this tree

Counts are `grep -rhoE '#[a-z_]+' --include=*.jai . | sort | uniq -c` over
`~/.local/opt/jai` (whole tree), so they measure presence, not meaning. "core" =
measured over `how_to` plus `Basic`, `String`, `File`, `Debug` only.

| Directive | Count | Directive | Count |
|---|---|---|---|
| `#foreign` | 11011 | `#insert` | 120 |
| `#type` | 3571 | `#define` | 96 |
| `#overlay` | 779 | `#modify` | 69 |
| `#run` | 657 | `#complete` | 61 |
| `#as` | 586 | `#module_parameters` | 41 |
| `#through` | 524 | `#this` | 25 |
| `#no_context` | 343 | `#placeholder` | 23 |
| `#expand` | 292 | `#deprecated` | 23 |
| `#asm` | 202 | `#program_export` | 21 |
| `#dynamic_specialize` | 4 | `#symmetric` | 19 |
| `#dynamic` | 4 | `#specified` | 12 |
| `#ifx` | 6 | `#place` | 3 |
| `#line` | 2 | `#file` | 7 |

core-only set: `#char` 185, `#if` 236, `#import` 231, `#load` 43, `#string` 28,
`#scope_file` 31, `#assert` 21, `#procedure_of_call` 20, `#scope_module` 19,
`#caller_location` 18, `#library` 12, `#scope_export` 12, `#no_reset` 10,
`#filepath` 10, `#c_call` 10, `#no_debug` 8, `#no_abc` 8, `#no_aoc` 7,
`#add_context` 8, `#code` 7, `#bake_arguments` 7, `#dump` 6.

Zero occurrences anywhere in this install — do not use them:

```
#packed  #optional  #from  #generated_from  #polymorphic
#foreign_library  #breakpoint  #require  #defers
```

Probe any claim yourself:

```sh
grep -rho --include=*.jai -F '#overlay' ~/.local/opt/jai | wc -l
```

Foreign-function form seen in `modules/Basic/posix.jai` and `linux.jai`:

```jai
libc_exit :: (status: s32) #foreign libc "exit";   // rename to the C symbol
c_free    :: (memory: *void) #foreign crt "free";
syscall   :: (__sysno: s64, __args: ..Any) -> s64 #foreign libc;
```
