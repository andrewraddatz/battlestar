" File              : battlestar.vim
" Author            : Andrew Raddatz <andrewraddatz@gmail.com>G
" Date              : 07 Feb 2019
" Last Modified Date: 03 Mar 2020
" Last Modified By  : Andrew Raddatz <andrewraddatz@gmail.com>

highlight clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = "battlestar"


call battlestar#colorset(battlestar#setpalette())
" call battlestar#airlinecolorset(s:airlinecolors)
