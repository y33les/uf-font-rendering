3184 constant oldlen \ old file length
h# a3 constant offset   \ where do the characters start in cream12.rom
" cream12.rom" filename
variable font oldlen allot
font oldlen fileread drop
" cream_trim.uf2" filename
font offset + oldlen offset - filewrite
variable trimmed oldlen offset - h# 520 + allot
trimmed h# 520 + oldlen offset - fileread
: add-header
  h# 100 0 do
    i u.
    h# 10 trimmed i + c!
  loop ;
add-header
" cream12.uf2" filename
trimmed oldlen offset - h# 520 + filewrite
bye
