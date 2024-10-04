\ set system colours to classic CGA palette
h# 0f0f h# 0ff0 h# 0fff colors

\ prepare 'cream12' font
3200 constant cream12len  \ font file length
h# 80 constant glyphs     \ offset at which glyph data begins
h#  8 constant tilewidth  \ width of 1 tile in memory
h# 20 constant charwidth  \ width of 1 character in memory
16 constant maxcharwidth  \ 16x16 characters in UF2
16 constant maxcharheight \ 16x16 characters in UF2
variable cream12 cream12len allot
" cream12.bin" filename
cream12 cream12len fileread drop

\ neater position management
variable posx 1 cells allot \ current x coordinate
variable posy 1 cells allot \ current y coordinate
\ get x coordinate
: get-x ( -- x)
    posx @ ;
\ get y coordinate
: get-y ( -- y)
    posy @ ;
\ set x coordinate
: set-x ( x -- )
    posx ! ;
\ set y coordinate
: set-y ( y -- )
    posy ! ;
\ increment x coordinate
: inc-x ( x -- )
    posx @ + posx ! ;
\ increment y coordinate
: inc-y ( y -- )
    posy @ + posy ! ;
\ update position based on current values of posx and posy
: update-position ( -- )
    posx @ posy @ position ;

\ font rendering
\ get width of character at index x
: get-char-width ( x -- y )
    cream12 + c@ ;
\ get address a of tile y for character at index x
: get-char-tile-addr ( x y -- a )
    tilewidth *
    swap h# 20 - charwidth * \ glyphs start at ASCII 0x20
    cream12 glyphs + + + ;
\ render one character tile at address a in sprite mode x, leaving its width w (in pixels) on the stack
: render-char-tile ( a x -- w )
    swap spritedata sprite ;
\ render character c in sprite mode x, advancing x position by the character's width and leaving the y position untouched
: render-character ( c x -- )
    swap                      \ x c
    dup h# 20 < if
      ." ERROR (render-character): Only ASCII characters between 0x20 and 0x7F are supported" bye
    then
    dup h# 7f > if
      ." ERROR (render-character): Only ASCII characters between 0x20 and 0x7F are supported" bye
    then
    dup get-char-width        \ x c w
    dup 9 < if 2 else 4 then 0 do \ x c w
      rot rot 2dup            \ w x c x c
      i get-char-tile-addr    \ w x c x a
      swap render-char-tile   \ w x c
      rot                     \ x c w
      i 0 = if
        8 inc-y
      then
      i 1 = if
        -8 inc-y
        dup 9 < if dup else 8 then inc-x
      then
      i 2 = if
        8 inc-y
      then
      i 3 = if
        dup 8 - inc-x
        -8 inc-y
      then
      update-position
    loop
    nip nip ;                 \ w
\ render string at address a with length u in sprite mode x, leaving position untouched
: render-string ( a u x -- )
    0 get-x get-y 2rot 2rot drop \ back up old x and y values
    swap 0 do          \ a x (ignoring old x and y for clarity)
      swap dup i + c@  \ x a c
      rot dup          \ a c x x
      2swap            \ x x a c
      rot              \ x a c x
      render-character \ x a w
      drop swap        \ a x
    loop
    drop drop          \ old x and old y left on the stack
    set-y set-x update-position ; \ return to original position
\ render string at address a with length u in sprite mode x with line breaks at set width w (in pixels), leaving position untouched
: render-multiline-string ( a u x w -- )
    get-x get-y 2rot 2rot \ back up old x and y values
    2swap                 \ x w a u (ignoring old x and y for clarity)
    0                     \ x w a u acc (width accumulator)
    swap 0 do             \ x w a acc
      rot                 \ x a acc w
      2swap               \ acc w x a
      dup i + c@          \ acc w x a c
      rot                 \ acc w a c x
      dup                 \ acc w a c x x
      rot swap            \ acc w a x c x
      render-character    \ acc w a x cw (character width)
      0 2rot              \ a x cw 0 acc w (0 as dummy value to enable 2rot)
      rot drop            \ a x cw acc w
      rot rot             \ a x w cw acc
      +                   \ a x w acc
      swap                \ a x acc w
      2dup swap           \ a x acc w w acc
      maxcharwidth + < if \ a x acc w
        over -1 * inc-x
        maxcharheight inc-y
        update-position
        swap drop 0 swap  \ a x acc w (acc reset to 0)
      then
      rot                 \ a acc w x
      swap                \ a acc x w
      2swap               \ x w a acc
    loop
    drop drop drop drop   \ old x and old y left on the stack
    set-y set-x update-position ; \ return to original position

\ testing
\ newline function for test purposes
: test-newline ( -- )
    0 set-x
    16 inc-y
    update-position ;
\ tests
h# 57 h# 44 render-character \ wide character (W)
h# 4d h# 44 render-character \ wide character (M)
h# 47 h# 44 render-character \ asymmetric character (G)
h# 65 h# 44 render-character \ normal character (e)
drop drop drop drop
test-newline
" Foo bar baz quux" h# 42 render-string                   \ normal string
test-newline
" Where will Mike make his machines?" h# 43 render-string \ string with wide characters (W, M, w, m)
test-newline
test-newline
" Xyzzy" h# 01 500 render-multiline-string \ string that doesn't hit the width limit
1 inc-x 1 inc-y update-position
" Xyzzy" h# 4a 500 render-multiline-string \ string that doesn't hit the width limit
test-newline
test-newline
" Where will Mike make his machines?" h# 01 100 render-multiline-string \ string that does hit the width limit
1 inc-x 1 inc-y update-position
" Where will Mike make his machines?" h# 4f 100 render-multiline-string \ string that does hit the width limit
.s
brk
