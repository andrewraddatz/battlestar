" File              : condition1.vim
" Author            : Andrew Raddatz <andrewraddatz@gmail.com>
" Date              : 16 Jun 2021
" Last Modified Date: 16 Jun 2021
" Last Modified By  : Andrew Raddatz <andrewraddatz@gmail.com>

highlight clear
if exists('syntax_on')
  syntax reset
endif

let g:battlestar_theme = "condition one"
let g:colors_name = "battlestar"

call battlestar#colorset(battlestar#setpalette())
" call battlestar#airlinecolorset(s:airlinecolors)
