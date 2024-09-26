3184 constant oldlen                    \ old file length
h# 80 constant gwidths                  \ size of glyph widths area
h# 100 gwidths - constant gwpad         \ required size of glyph widths area
h# a0 constant glyphs                   \ offset at which the glyphs actually start
h# 20 constant spacechar                \ offset again to add in a 'space' character
h# 20 spacechar * constant specialarea  \ 32 blank chars to fill up the symbol area other fonts use
gwidths gwpad + specialarea + spacechar + oldlen glyphs - + constant newlen \ new file length

\ read in font
variable oldfont oldlen allot
" cream12.bin" filename
oldfont oldlen fileread drop

\ create space for new version
variable newfont newlen allot

oldfont newfont gwidths cmove \ copy glyph widths to start of new font
oldfont glyphs + newfont gwidths gwpad specialarea spacechar + + + + oldlen glyphs - cmove \ copy actual glyphs to appropriate offset in new font

\ write file out
" cream12.uf2" filename
newfont newlen filewrite
bye
