" File              : battlestar.vim
" Author            : Andrew Raddatz <andrewraddatz@gmail.com>
" Date              : Thu  7 Feb 09:33:20 2019
" Last Modified Date: Thu  7 Feb 09:33:20 2019
" Last Modified By  : Andrew Raddatz <andrewraddatz@gmail.com>

highlight clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = "battlestar"

call battlestar#colorset(battlestar#setpalette())

