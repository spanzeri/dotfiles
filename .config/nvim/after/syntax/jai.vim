" Convention-independent type highlighting for Jai.
"
" The bundled jai.vim guesses at types with `\v<[A-Z]\w+>` (CamelCase == type).
" That is a naming convention, not a language rule, so it mis-colours any
" codebase that doesn't follow it -- and it also shadows the plugin's own
" jaiFunction / jaiVariableDeclaration rules, since it is defined later.
"
" These rules instead find types by their *syntactic position*, which holds no
" matter how anything is spelled:
"
"   x: TYPE              declaration
"   x, y: *[..] TYPE     with type modifiers
"   -> TYPE              return type
"   cast(TYPE) x         cast / size_of / type_of / type_info
"   Name :: struct {}    type definition
"
" Flags:
"   g:jai_camel_case_types      keep the CamelCase == type guess   (default 0)
"   g:jai_uppercase_constants   keep the ALL_CAPS == constant guess (default 1)

if !get(g:, 'jai_camel_case_types', 0)
  syntax clear jaiClass
endif

" A type name, possibly dotted: `Foo`, `array.type`, `Basic.Allocator`.
let s:name = '<\h\w*>%(\.<\h\w*>)*'
" Leading type modifiers to skip over: `*`, `..`, `[4]`, `[..]`, `[$N]`.
" `[^\]]` rather than `.{-}`: inside a collection Vim treats `\]` as a literal
" `]`, and a plain collection backtracks far less than a lazy `.`.
let s:mods = '%(\*|\.\.|\[[^\]]*\]|\s)*'
" Words that can follow a `:` but are never a type name. This is the language's
" reserved-word list, not a naming convention, so it is safe to spell out.
let s:kw = '%(<%(using|cast|xx|struct|union|enum|enum_flags|if|ifx|then|else'
      \ . '|case|for|while|continue|break|remove|return|defer|inline|no_inline'
      \ . '|true|false|null|it|it_index|size_of|type_of|type_info|interface'
      \ . '|is_constant|context|push_context|operator|initializer_of|SOA|AOS)>)@!'

" `for elem: array` and `for a, b: map` -- the loop variables, *including* the
" colon. Claiming the colon here is what stops the type rule below from reading
" `array` as a type, and it is far cheaper than putting an unbounded `<for>`
" lookbehind on that rule, which would then run at every column of every line.
" Vim resolves overlapping items by which highlights first, and this one starts
" at the loop variable, i.e. before the colon.
" jaiForRange itself is unhighlighted and exists only to claim the text; the
" loop variables inside it keep the plugin's own Identifier colour.
syntax match jaiForRange
      \ "\v%(<for>%(\s*\<)?\s*)@40<=%(<\h\w*>\s*,\s*)*<\h\w*>\s*:"
      \ contains=jaiForVariableDeclaration display
syntax match jaiForVariableDeclaration "\v<\h\w*>" contained display

" `x: TYPE` -- but not `::` and not `:=`.
" This is a region rather than a `\zs` match because Vim resolves overlapping
" syntax items by which one *highlights* first: in `x: [4]f32` the jaiInteger
" rule starts at the `4` and would beat a match whose \zs lands on `f32`.
" Putting the modifiers in the region's start match makes them ours instead.
execute 'syntax region jaiTypeUse oneline keepend'
      \ . ' matchgroup=jaiTypeModifier start="\v'
      \ . ':@<!:[:=]@!\s*' . s:mods . s:kw . '%(\h)@="'
      \ . ' matchgroup=NONE end="\v' . s:name . '"'

" `-> TYPE` and `-> (TYPE, ...`
execute 'syntax match jaiTypeUse "\v-\>\s*\(?\s*' . s:mods . '\zs' . s:name . '" display'

" `cast(TYPE)`, `size_of(TYPE)`, ... -- anchored on the `(` because a keyword
" always outranks a match that starts at the same column.
execute 'syntax match jaiTypeUse "\v%(<%(cast|size_of|type_of|type_info|initializer_of)>\s*)@<='
      \ . '\(\s*%(,|\s)*' . s:mods . '\zs' . s:name . '" display'

" `Name :: struct {}` / `enum` / `enum_flags` / `union` / `#type`
execute 'syntax match jaiTypeDeclaration "\v' . s:name
      \ . '\ze\s*::\s*%(struct|union|enum|enum_flags|#type)>" display'

unlet s:name s:mods s:kw

" `.MEMBER` enum literal: a leading dot that is NOT preceded by an identifier,
" a closing bracket, or another dot -- those would be field access, `array[i].x`
" or a `..` range. Convention-free, and it catches lowercase enum members too.
syntax match jaiEnumLiteral "\v%([)\]}.]|\w)@<!\.\zs\h\w*" display

" Constant *declarations* are always `NAME :: value;`, and jaiConstantDeclaration
" already matches those positionally. Constant *uses* are not detectable without
" symbol information -- `VAO` and `GL_TRUE` are the same token to a highlighter --
" so ALL_CAPS is the only handle there, and it is kept on by default.
" Two fixes over upstream: its character class has a stray comma in it (so `A,B`
" colours as one constant), and an ALL_CAPS word in declaration position
" (`X, Y: f32;`) is a declaration, not a constant use -- the trailing lookahead
" rejects the latter so short uppercase field names keep their own colour.
syntax clear jaiConstant
if get(g:, 'jai_uppercase_constants', 1)
  syntax match jaiConstant "\v<[A-Z][A-Z0-9_]*>%(%(\s*,\s*\h\w*)*\s*:[:=]@!)@!" display
endif

highlight def link jaiTypeUse Type
highlight def link jaiTypeDeclaration Type
highlight def link jaiEnumLiteral Constant
