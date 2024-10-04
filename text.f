\ set system colours
h# 0f0f h# 0ff0 h# 0fff colors

\ prepare 'cream12' font
3200 constant cream12len \ font file length
h# 80 constant glyphs    \ offset at which glyph data begins
h#  8 constant tilewidth \ width of 1 tile in memory
h# 20 constant charwidth \ width of 1 character in memory
variable cream12 cream12len allot
" cream12.bin" filename
cream12 cream12len fileread drop

\ neater position management
variable posx 1 cells allot \ current x coordinate
variable posy 1 cells allot \ current y coordinate
\ set x coordinate
: set-x ( x -- )
    posx ! ;
\ set y coordinate
: set-y ( x -- )
    posy ! ;
\ increment x coordinate
: inc-x ( x -- )
    posx @ + posx ! ;
\ increment y coordinate
: inc-y ( x -- )
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
\ render one character tile at address a in sprite mode x
: render-char-tile ( a x -- )
    swap spritedata sprite ;
\ render character c in sprite mode x
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
    drop drop drop ;
\ render string at address a with length u in sprite mode x
: render-string ( a u x -- )
    .s cr
    swap 0 do          \ a x
      ." => enter loop " i . cr .s cr cr
      ." swap dup " cr .s cr cr
      swap dup i + c@  \ x a c
      ." rot dup " .s cr cr
      rot dup          \ a c x x
      ." 2swap " .s cr cr
      2swap            \ x x a c
      ." rot " .s cr cr
      rot              \ x a c x
      ." render " .s cr cr
      render-character \ x a
      ." swap " .s cr cr
      swap             \ a x
      ." next loop " .s cr cr
    loop ;
    ." exit loop " .s cr cr
    drop drop ;
\ render string with line breaks at set no. of characters

h# 57 h# 44 render-character
h# 4d h# 44 render-character
h# 47 h# 44 render-character
h# 65 h# 44 render-character
" Foo bar baz quux" h# 41 render-string
brk
