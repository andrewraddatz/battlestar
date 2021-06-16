" Things that are helpful
" H values and their colors{{{
"     0 -> Red
"    30 -> Orange
"    60 -> Yellow
"    90 -> Lime
"    120 -> Green
"    150 -> Teal
"    180 -> Cyan
"    210 -> Sky Blue
"    240 -> Blue
"    270 -> Purple
"    300 -> Pink
"    330 -> Red Pink
"}}}
" Helper function to set up highlight executions{{{
function! battlestar#highlight(group, fg, bg, style)
    exec  "highlight "  . a:group
                \ . " ctermfg="   . a:fg[0]
                \ . " ctermbg="   . a:bg[0]
                \ . " cterm="     . a:style[0]
                \ . " guifg="     . a:fg[1]
                \ . " guibg="     . a:bg[1]
                \ . " gui="       . a:style[1]
endfunction

function! battlestar#setgroup(fg, bg, style)
    let s:fg = a:fg
    let s:bg = a:bg
    let s:style = a:style
endfunction
"}}}

" Borrowed from Odyssey by Ludovic Koenig
function! battlestar#hsv2rgb(hue, saturation, value)"{{{
    let l:s = a:saturation / 100.0
    let l:v = a:value / 100.0

    let l:c = l:v * l:s
    let l:h = a:hue / 60.0
    let l:x = l:c * (1.0 - abs(fmod(l:h, 2) - 1.0))

    if 0 <= l:h && l:h <= 1
        let l:l = [l:c, l:x, 0.0]
    elseif 1 < l:h && l:h <= 2
        let l:l = [l:x, l:c, 0.0]
    elseif 2 < l:h && l:h <= 3
        let l:l = [0.0, l:c, l:x]
    elseif 3 < l:h && l:h <= 4
        let l:l = [0.0, l:x, l:c]
    elseif 4 < l:h && l:h <= 5
        let l:l = [l:x, 0.0, l:c]
    elseif 5 < l:h && l:h <= 6
        let l:l = [l:c, 0.0, l:x]
    endif

    let l:m = l:v - l:c

    let l:l = [l:l[0] + l:m, l:l[1] + l:m, l:l[2] + l:m]
    let l:l = [l:l[0] * 255, l:l[1] * 255, l:l[2] * 255]
    let l:l = [round(l:l[0]), round(l:l[1]), round(l:l[2])]
    let l:l = [float2nr(l:l[0]), float2nr(l:l[1]), float2nr(l:l[2])]

    return l:l
endfunction"}}}
function! battlestar#rgb2hex(rgb)"{{{
    let l:f = "%02x"
    return printf(l:f, a:rgb[0]) . printf(l:f, a:rgb[1]) . printf(l:f, a:rgb[2])
endfunction"}}}
function! battlestar#rgb2short(rgb)"{{{
    " 216 colors + 24 greys = 240 total ( - 16 because ignoring system color )
    function! s:xterm2rgb(key, val)
        let l:incs = [0, 95, 135, 175, 215, 255]

        if a:val < 216
            return [l:incs[a:val / 36], l:incs[(a:val % 36) / 6], l:incs[a:val % 6]]
        else
            let l:coordinate = a:val * 10 - 2152
            return [l:coordinate, l:coordinate, l:coordinate]
        endif
    endfunction

    function! s:distance(lhs, rhs)
        return abs(a:lhs[0] - a:rhs[0])
                    \ + abs(a:lhs[1] - a:rhs[1])
                    \ + abs(a:lhs[2] - a:rhs[2])
    endfunction

    let l:xterm = range(0, 239)
    let l:xterm = map(l:xterm, function('s:xterm2rgb'))

    let l:distances = []
    for l:value in l:xterm
        let l:distances += [s:distance(l:value, a:rgb)]
    endfor

    let l:index = index(l:distances, min(l:distances)) + 16

    return l:index
endfunction"}}}
function! battlestar#colorize(hue, saturation, value)"{{{
    let l:rgb = battlestar#hsv2rgb(a:hue, a:saturation, a:value)
    let l:gui = battlestar#rgb2hex(l:rgb)
    let l:cterm = battlestar#rgb2short(l:rgb)
    let l:res = [l:cterm, "#".l:gui]
    return l:res
endfunction"}}}
function! battlestar#colorize_rgb(r, g, b)"{{{
    let l:rgb = [float2nr(a:r), float2nr(a:g), float2nr(a:b)]
    let l:gui = battlestar#rgb2hex(l:rgb)
    let l:cterm = battlestar#rgb2short(l:rgb)
    let l:res = [l:cterm, "#".l:gui]
    return l:res
endfunction"}}}

" Actual color generation
function! battlestar#theme_color_palette_disparate(colors)"{{{
    let l:colors = { 
    \   'neutralcolor' : battlestar#colorize(a:colors[0][0], a:colors[0][1], a:colors[0][2]),
    \   'brightcolor'  : battlestar#colorize(a:colors[1][0], a:colors[1][1], a:colors[1][2]),
    \   'accentcolor'  : battlestar#colorize(a:colors[2][0], a:colors[2][1], a:colors[2][2]),
    \   'lightcolor'   : battlestar#colorize(a:colors[3][0], a:colors[3][1], a:colors[3][2]),
    \   'darkcolor'    : battlestar#colorize(a:colors[4][0], a:colors[4][1], a:colors[4][2]),
    \   }

    return l:colors
endfunction"}}}
function! battlestar#theme_color_palette_homogeneous(h, s, v)"{{{
    let l:colors = { 
    \   'neutralcolor' : battlestar#colorize(a:h[0], a:s, a:v),
    \   'brightcolor'  : battlestar#colorize(a:h[1], a:s, a:v),
    \   'accentcolor'  : battlestar#colorize(a:h[2], a:s, a:v),
    \   'lightcolor'   : battlestar#colorize(a:h[3], a:s, a:v),
    \   'darkcolor'    : battlestar#colorize(a:h[4], a:s, a:v),
    \   }

    return l:colors
endfunction"}}}
function! battlestar#filler_colors(bg, fg)"{{{
    let l:bgr = a:bg[0] | let l:bgg = a:bg[1] | let l:bgb = a:bg[2]
    let l:fgr = a:fg[0] | let l:fgg = a:fg[1] | let l:fgb = a:fg[2]

    let l:steps = 7.0
    let l:rint = (l:fgr-l:bgr)/l:steps
    let l:gint = (l:fgg-l:bgg)/l:steps
    let l:bint = (l:fgb-l:bgb)/l:steps

    let l:colors = { 
    \   'background'   : battlestar#colorize_rgb(l:bgr         , l:bgg         , l:bgb         ),
    \   'grey01'       : battlestar#colorize_rgb(l:bgr+l:rint*1, l:bgg+l:gint*1, l:bgb+l:bint*1),
    \   'grey02'       : battlestar#colorize_rgb(l:bgr+l:rint*2, l:bgg+l:gint*2, l:bgb+l:bint*2),
    \   'grey03'       : battlestar#colorize_rgb(l:bgr+l:rint*3, l:bgg+l:gint*3, l:bgb+l:bint*3),
    \   'grey04'       : battlestar#colorize_rgb(l:bgr+l:rint*4, l:bgg+l:gint*4, l:bgb+l:bint*4),
    \   'grey05'       : battlestar#colorize_rgb(l:bgr+l:rint*5, l:bgg+l:gint*5, l:bgb+l:bint*5),
    \   'grey06'       : battlestar#colorize_rgb(l:bgr+l:rint*6, l:bgg+l:gint*6, l:bgb+l:bint*6),
    \   'foreground'   : battlestar#colorize_rgb(l:fgr         , l:fgg         , l:fgb         ),
    \   }

    return l:colors
endfunction"}}}
function! battlestar#misc_color_palette_homogeneous(h, s, v)"{{{
    let l:colors = { 
    \   'delete'       : battlestar#colorize(a:h[0], a:s, a:v),
    \   'change'       : battlestar#colorize(a:h[1], a:s, a:v),
    \   'add'          : battlestar#colorize(a:h[2], a:s, a:v),
    \   }
    return l:colors
endfunction"}}}
function! battlestar#misc_color_palette_disparate(colors)"{{{
    let l:colors = { 
    \   'delete'       : battlestar#colorize(a:colors[0][0], a:colors[0][1], a:colors[0][2]),
    \   'change'       : battlestar#colorize(a:colors[1][0], a:colors[1][1], a:colors[1][2]),
    \   'add'          : battlestar#colorize(a:colors[2][0], a:colors[2][1], a:colors[2][2]),
    \   }
    return l:colors
endfunction"}}}

" Main functions you call
function! battlestar#colorset(colors) "{{{
    " Syntax highlighting groups
    "
    " For reference on what each group does, please refer to this:
    " vimdoc.sourceforge.net/htmldoc/syntax.html

    " Text Styles
    let s:clear         = ['NONE'    ,  'NONE'     ]
    let s:none          = ['NONE'    ,  'NONE'     ]
    let s:reverse       = ['reverse' ,  'reverse'  ]
    let s:none_italic   = ['NONE'    ,  'italic'   ]
    let s:italicg       = ['NONE'    ,  'italic'   ]
    let s:bold          = ['NONE'    ,  'bold'     ]
    let s:underline     = ['NONE'    ,  'underline']

    call battlestar#setgroup(a:colors.grey05, s:clear, s:none)"{{{
    " call battlestar#highlight('Comment',               s:fg,  s:bg,  s:style)
    call battlestar#highlight('Pmenu',                 s:fg, s:bg, s:style)
    call battlestar#highlight('PMenuThumb',            s:fg, s:bg, s:style)
    call battlestar#highlight('PMenuSbar',             s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.grey04, s:clear, s:none)"{{{
    call battlestar#highlight('Special',               s:fg, s:bg, s:style)
    call battlestar#highlight('SpecialChar',           s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(s:clear, a:colors.grey01, s:none)"{{{
    call battlestar#highlight('CursorLine',            s:fg, s:bg, s:style)
    call battlestar#highlight('CursorColumn',          s:fg, s:bg, s:style)
    call battlestar#highlight('ColorColumn',           s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.brightcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Constant',              s:fg, s:bg, s:style)
    call battlestar#highlight('String',                s:fg, s:bg, s:style)
    call battlestar#highlight('Character',             s:fg, s:bg, s:style)
    call battlestar#highlight('Number',                s:fg, s:bg, s:style)
    call battlestar#highlight('Boolean',               s:fg, s:bg, s:style)
    call battlestar#highlight('Float',                 s:fg, s:bg, s:style)
    call battlestar#highlight('PMenuSel',              s:fg, s:bg, s:style)
    call battlestar#highlight('MatchParen',            s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.darkcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Identifier',            s:fg, s:bg, s:style)
    call battlestar#highlight('Function',              s:fg, s:bg, s:style)
    call battlestar#highlight('Statement',             s:fg, s:bg, s:style)
    call battlestar#highlight('Conditional',           s:fg, s:bg, s:style)
    call battlestar#highlight('Repeat',                s:fg, s:bg, s:style)
    call battlestar#highlight('Label',                 s:fg, s:bg, s:style)
    call battlestar#highlight('Operator',              s:fg, s:bg, s:style)
    call battlestar#highlight('Keyword',               s:fg, s:bg, s:style)
    call battlestar#highlight('Exception',             s:fg, s:bg, s:style)
    call battlestar#highlight('Directory',             s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.background, a:colors.darkcolor, s:none)"{{{
    call battlestar#highlight('Search',                s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.background, a:colors.neutralcolor, s:none)"{{{
    call battlestar#highlight('IncSearch',             s:fg, s:bg, s:style)
    "}}}

    call battlestar#setgroup(a:colors.lightcolor, s:clear, s:none)"{{{
    call battlestar#highlight('PreProc',               s:fg, s:bg, s:style)
    call battlestar#highlight('Include',               s:fg, s:bg, s:style)
    call battlestar#highlight('Define',                s:fg, s:bg, s:style)
    call battlestar#highlight('Macro',                 s:fg, s:bg, s:style)
    call battlestar#highlight('PreCondit',             s:fg, s:bg, s:style)
    call battlestar#highlight('Title',                 s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.accentcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Type',                  s:fg, s:bg, s:style)
    call battlestar#highlight('StorageClass',          s:fg, s:bg, s:style)
    call battlestar#highlight('Structure',             s:fg, s:bg, s:style)
    call battlestar#highlight('Typedef',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.neutralcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Comment',               s:fg,  s:bg,  s:style)
"}}}
    call battlestar#setgroup(a:colors.grey03, s:clear, s:none)"{{{
    call battlestar#highlight('SpecialKey',            s:fg, s:bg, s:style)
    call battlestar#highlight('SpecialComment',        s:fg, s:bg, s:style)
    call battlestar#highlight('Debug',                 s:fg, s:bg, s:style)
    call battlestar#highlight('Underlined',            s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.grey06, s:clear, s:none)"{{{
    call battlestar#highlight('Delimiter',             s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.brightcolor, a:colors.grey02, s:none)"{{{
    call battlestar#highlight('Error',                 s:fg, s:bg, s:style)
    call battlestar#highlight('Todo',                  s:fg, s:bg, s:style)
    "}}}

    " Figure these out
    " call battlestar#highlight('ErrorMsg',              s:fg, s:bg, s:style)
    " call battlestar#highlight('ModeMsg',               s:fg, s:bg, s:style)
    " call battlestar#highlight('MoreMsg',               s:fg, s:bg, s:style)
    " call battlestar#highlight('Question',              s:fg, s:bg, s:style)

    " User Colors{{{
    " for status lines
    call battlestar#highlight('User1', a:colors.grey02, a:colors.grey01, s:none) " faint
    call battlestar#highlight('User2', a:colors.grey03, a:colors.grey01, s:none) "   |
    call battlestar#highlight('User3', a:colors.grey04, a:colors.grey01, s:none) "   |
    call battlestar#highlight('User4', a:colors.grey05, a:colors.grey01, s:none) "   v
    call battlestar#highlight('User5', a:colors.grey06, a:colors.grey01, s:none) " distinct

    call battlestar#highlight('ins_nor', s:colors.grey01, s:colors.add,    s:none) " insert
    call battlestar#highlight('rep_nor', s:colors.grey01, s:colors.delete, s:none) " replace
    call battlestar#highlight('vis_nor', s:colors.grey01, s:colors.change, s:none) " visual
    call battlestar#highlight('nor_nor', s:colors.grey01, s:colors.neutralcolor, s:none) " normal
    call battlestar#highlight('com_nor', s:colors.grey01, s:colors.grey04, s:none) " command
    call battlestar#highlight('git_nor', s:colors.grey06, s:colors.grey01, s:none) " git

    call battlestar#highlight('ins_rev', s:colors.add,    s:colors.grey01, s:none) " insert-reverse
    call battlestar#highlight('rep_rev', s:colors.delete, s:colors.grey01, s:none) " replace-reverse
    call battlestar#highlight('vis_rev', s:colors.change, s:colors.grey01, s:none) " visual-reverse
    call battlestar#highlight('nor_rev', s:colors.neutralcolor, s:colors.grey01, s:none) " normal-reverse
    call battlestar#highlight('com_rev', s:colors.grey04, s:colors.grey01, s:none) " command-reverse
    call battlestar#highlight('git_rev', s:colors.grey01, s:colors.grey06, s:none) " git-reverse
    call battlestar#highlight('sta_rev', a:colors.grey01, a:colors.grey06, s:none) " status-rev

"}}}
    
    " Interface highlighting
    call battlestar#setgroup(a:colors.foreground, a:colors.background, s:none)"{{{
    call battlestar#highlight('Normal',                s:fg, s:bg, s:style)
    call battlestar#highlight('EndOfBuffer',           s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.background, a:colors.grey05, s:none)"{{{
    call battlestar#highlight('Cursor',                s:fg, s:bg, s:style)
    call battlestar#highlight('iCursor',               s:fg, s:bg, s:style)
    call battlestar#highlight('vCursor',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.neutralcolor, s:clear, s:none)"{{{
    call battlestar#highlight('LineNr',                s:fg, s:bg, s:style)
    call battlestar#highlight('NonText',               s:fg, s:bg, s:style)
    call battlestar#highlight('VertSplit',             s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.brightcolor, s:clear, s:none)"{{{
    call battlestar#highlight('CursorLineNr',          s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.darkcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Folded',                s:fg, s:bg, s:style)
    call battlestar#highlight('FoldColumn',            s:fg, s:bg, s:style)
    call battlestar#highlight('Conceal',               s:fg, s:bg, s:style)
    call battlestar#highlight('TabLineSel',            s:fg, s:bg, s:style)
"}}}
    call battlestar#setgroup(s:none, s:clear, s:reverse)"{{{
    call battlestar#highlight('Visual',                s:fg, s:bg, s:style)
    call battlestar#highlight('iCursor',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.grey06, a:colors.grey01, s:none)"{{{
    call battlestar#highlight('StatusLine',            s:fg, s:bg, s:style)
    call battlestar#highlight('StatusLineTerm',        s:fg, s:bg, s:style)
    call battlestar#highlight('TabLine',               s:fg, s:bg, s:style)
    call battlestar#highlight('TabLineFill',           s:fg, s:bg, s:style)

"}}}
    call battlestar#setgroup(a:colors.grey03, a:colors.grey01, s:none)"{{{
    call battlestar#highlight('StatusLineNC',          s:fg, s:bg, s:style)
    call battlestar#highlight('StatusLineTermNC',      s:fg, s:bg, s:style)
"}}}

    " Managing Diffs
    call battlestar#setgroup(a:colors.change, a:colors.grey01, s:none)"{{{
    call battlestar#highlight('DiffText',              s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.foreground, a:colors.grey01, s:none)"{{{
    call battlestar#highlight('DiffChange',            s:fg, s:bg, s:style)
    "}}}

    " Git
    call battlestar#setgroup(a:colors.add, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterAdd',          s:fg, s:bg, s:style)
    call battlestar#highlight('DiffAdd',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.change, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterChange',       s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.delete, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterDelete',       s:fg, s:bg, s:style)
    call battlestar#highlight('DiffDelete',            s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.grey05, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterChangeDelete', s:fg, s:bg, s:style)
    call battlestar#highlight('SignColumn',            s:fg, s:bg, s:style)
    "}}}
    
    " Vimscript syntax highlighting
    call battlestar#setgroup(a:colors.grey03, s:clear, s:none)"{{{
    call battlestar#highlight('vimOption',             s:fg, s:bg, s:style)
    "}}}

    " Spelling
"{{{
    if has("gui_running")
        call battlestar#highlight('SpellBad',              [a:colors.delete[0],       'NONE'],  s:clear, ['NONE', 'undercurl guisp=' . a:colors.delete[1]])
        call battlestar#highlight('SpellCap',              [a:colors.neutralcolor[0], 'NONE'],  s:clear, ['NONE', 'undercurl guisp=' . a:colors.neutralcolor[1]])
        call battlestar#highlight('SpellLocal',            [a:colors.add[0],          'NONE'],  s:clear, ['NONE', 'undercurl guisp=' . a:colors.add[1]])
        call battlestar#highlight('SpellRare',             [a:colors.accentcolor[0],  'NONE'],  s:clear, ['NONE', 'undercurl guisp=' . a:colors.accentcolor[1]])
    else
        call battlestar#highlight('SpellBad',              a:colors.delete, s:clear, ['NONE', 'undercurl guisp=' . a:colors.delete[1]])
        call battlestar#highlight('SpellCap',              a:colors.neutralcolor, s:clear, ['NONE', 'undercurl guisp=' . a:colors.neutralcolor[1]])
        call battlestar#highlight('SpellLocal',            a:colors.add, s:clear, ['NONE', 'undercurl guisp=' . a:colors.add[1]])
        call battlestar#highlight('SpellRare',             a:colors.accentcolor, s:clear, ['NONE', 'undercurl guisp=' . a:colors.accentcolor[1]])
    end
    "}}}

endfunction "}}}
function! battlestar#airlinecolorset(colors) "{{{

    let s:palette = {}

    " Pattern
    " 1 -> A/Z
    " 2 -> B/Y
    " 2 -> C/X
    " FG GUI, BG GUI, FG TERM, BG TERM

    " Everything
    let s:L2   = [ a:colors.00[1], a:colors.01[1], a:colors.00[0], a:colors.01[0] ]
    let s:L3   = [ a:colors.02[1], a:colors.03[1], a:colors.02[0], a:colors.03[0] ]

    " Normal
    let s:N1   = [ a:colors.04[1], a:colors.05[1], a:colors.04[0], a:colors.05[0] ]
    let s:palette.normal = airline#themes#generate_color_map(s:N1, s:L2, s:L3)

    " Insert
    let s:I1   = [ a:colors.06[1], a:colors.07[1], a:colors.06[0], a:colors.07[0] ]
    let s:palette.insert = airline#themes#generate_color_map(s:I1, s:L2, s:L3)

    " Replace
    let s:R1   = [ a:colors.08[1], a:colors.09[1], a:colors.08[0], a:colors.09[0] ]
    let s:palette.replace = airline#themes#generate_color_map(s:R1, s:L2, s:L3)

    " Visual
    let s:V1   = [ a:colors.0A[1], a:colors.0B[1], a:colors.0A[0], a:colors.0B[0] ]
    let s:palette.visual = airline#themes#generate_color_map(s:V1, s:L2, s:L3)

    " Inactive
    let s:A1   = [ a:colors.0C[1], a:colors.0D[1], a:colors.0C[0], a:colors.0D[0] ]
    let s:palette.inactive = airline#themes#generate_color_map(s:A1, s:L2, s:L3)

    return s:palette

endfunction "}}}
function! battlestar#lightlinecolorset(colors) "{{{

    let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

    " Pattern
    " 1 -> A/Z
    " 2 -> B/Y
    " 2 -> C/X
    " FG GUI, BG GUI, FG TERM, BG TERM

    " Everything
    let s:L2   = [ [a:colors.00[1], a:colors.01[1]], [a:colors.00[0], a:colors.01[0] ]]
    let s:L3   = [ [a:colors.02[1], a:colors.03[1]], [a:colors.02[0], a:colors.03[0] ]]

    " Normal
    let s:N1   = [ a:colors.04[1], a:colors.05[1], a:colors.04[0], a:colors.05[0] ]

    " Insert
    let s:I1   = [ a:colors.06[1], a:colors.07[1], a:colors.06[0], a:colors.07[0] ]

    " Replace
    let s:R1   = [ a:colors.08[1], a:colors.09[1], a:colors.08[0], a:colors.09[0] ]

    " Visual
    let s:V1   = [ a:colors.0A[1], a:colors.0B[1], a:colors.0A[0], a:colors.0B[0] ]

    " Inactive
    let s:A1   = [ a:colors.0C[1], a:colors.0D[1], a:colors.0C[0], a:colors.0D[0] ]

    let s:nord0 = ["#2E3440", "NONE"]
    let s:nord1 = ["#3B4252", 0]
    let s:nord2 = ["#434C5E", "NONE"]
    let s:nord3 = ["#4C566A", 8]
    let s:nord4 = ["#D8DEE9", "NONE"]
    let s:nord5 = ["#E5E9F0", 7]
    let s:nord6 = ["#ECEFF4", 15]
    let s:nord7 = ["#8FBCBB", 14]
    let s:nord8 = ["#88C0D0", 6]
    let s:nord9 = ["#81A1C1", 4]
    let s:nord10 = ["#5E81AC", 12]
    let s:nord11 = ["#BF616A", 1]
    let s:nord12 = ["#D08770", 11]
    let s:nord13 = ["#EBCB8B", 3]
    let s:nord14 = ["#A3BE8C", 2]
    let s:nord15 = ["#B48EAD", 5]

    let s:p.normal.left = [ [ s:nord1, s:nord8 ], [ s:nord5, s:nord1 ] ]
    let s:p.normal.middle = [ [ s:nord5, s:nord3 ] ]
    let s:p.normal.right = [ [ s:nord5, s:nord1 ], [ s:nord5, s:nord1 ] ]
    let s:p.normal.warning = [ [ s:nord1, s:nord13 ] ]
    let s:p.normal.error = [ [ s:nord1, s:nord11 ] ]

    let s:p.inactive.left =  [ [ s:nord1, s:nord8 ], [ s:nord5, s:nord1 ] ]
    let s:p.inactive.middle = g:nord_uniform_status_lines == 0 ? [ [ s:nord5, s:nord1 ] ] : [ [ s:nord5, s:nord3 ] ]
    let s:p.inactive.right = [ [ s:nord5, s:nord1 ], [ s:nord5, s:nord1 ] ]

    let s:p.insert.left = [ [ s:nord1, s:nord6 ], [ s:nord5, s:nord1 ] ]
    let s:p.replace.left = [ [ s:nord1, s:nord13 ], [ s:nord5, s:nord1 ] ]
    let s:p.visual.left = [ [ s:nord1, s:nord7 ], [ s:nord5, s:nord1 ] ]

    let s:p.tabline.left = [ [ s:nord5, s:nord3 ] ]
    let s:p.tabline.middle = [ [ s:nord5, s:nord3 ] ]
    let s:p.tabline.right = [ [ s:nord5, s:nord3 ] ]
    let s:p.tabline.tabsel = [ [ s:nord1, s:nord8 ] ]

    return lightline#colorscheme#flatten(s:p)

endfunction "}}}
function! battlestar#palette(theme, filler, misc)"{{{
    if len(a:theme) == 3
        let l:theme =  battlestar#theme_color_palette_homogeneous(a:theme[0], a:theme[1], a:theme[2])
    else
        let l:theme =  battlestar#theme_color_palette_disparate(a:theme)
    endif

    if len(a:misc[1]) == 2
        call extend(l:theme, battlestar#misc_color_palette_homogeneous(a:misc[0], a:misc[1], a:misc[2]))
    else
        call extend(l:theme, battlestar#misc_color_palette_disparate(a:misc))
    endif
    call extend(l:theme, 
                \    battlestar#filler_colors(
                \        battlestar#hsv2rgb(a:filler[0][0], a:filler[0][1], a:filler[0][2]), 
                \        battlestar#hsv2rgb(a:filler[1][0], a:filler[1][1], a:filler[1][2])
                \    )
                \ )

    return l:theme
endfunction"}}}
function! battlestar#setpalette()"{{{
    " if has("win32") && !has("gui_running")"{{{
    "     let g:battlestar_theme="term"
    " endif"}}}
    if !exists('g:battlestar_theme')"{{{
        let g:battlestar_theme="condition two init"
    endif"}}}
    if !exists('g:battlestar_shade')"{{{
        let g:battlestar_shade=1
    endif"}}}
    if g:battlestar_shade == 1"{{{
        set background=dark
        let s:v = 100
        let s:red = 0
    else
        set background=light
        let s:v = 60
        let s:red = 20
    endif"}}}

    let g:battlestar#generated = 0
    if g:battlestar_theme ==? 'condition one'"{{{
        let g:battlestar#generated = 1
        let s:theme = [[20, 50, 290, 350, 110], 50, s:v]
        let s:bg = [12.6, 30, 6]
        let s:fg = [12.6, 10, 90]
        let s:misc = [[314, 50, 110], 50, 50]
        "}}}
    elseif g:battlestar_theme ==? 'condition two init'"{{{
        " color defs Generated two
        let g:battlestar#generated = 0
        " I was getting annoyed at waiting for it to calculate
        " these colors when starting up vim.
        "
        " These colors are equivalent to Condtion2
        " retrieved via battlestar#printscheme()
        
        let s:colors = {
        \ 'lightcolor'   : ['120' , '#80ff95'],
        \ 'brightcolor'  : ['156' , '#aaff80'],
        \ 'darkcolor'    : ['222' , '#ffd480'],
        \ 'accentcolor'  : ['192' , '#eaff80'],
        \ 'neutralcolor' : ['81' , '#33ddff'],
        \
        \ 'background'   : ['232' , '#0b0f0b'],
        \ 'foreground'   : ['252' , '#cfe6cf'],
        \
        \ 'grey01'       : ['235' , '#272d27'],
        \ 'grey02'       : ['238' , '#434c43'],
        \ 'grey03'       : ['59' , '#5f6b5f'],
        \ 'grey04'       : ['244' , '#7b897b'],
        \ 'grey05'       : ['247' , '#97a897'],
        \ 'grey06'       : ['249' , '#b3c7b3'],
        \
        \ 'add'          : ['113' , '#77cc66'],
        \ 'change'       : ['179' , '#ccbb66'],
        \ 'delete'       : ['167' , '#cc6670'],
        \ }
        
        let s:airlinecolors = {
        \ '00' : ['235' , '#272d27'],
        \ '01' : ['247' , '#97a897'],
        \
        \ '02' : ['249' , '#b3c7b3'],
        \ '03' : ['235' , '#272d27'],
        \
        \ '04' : ['249' , '#b3c7b3'],
        \ '05' : ['238' , '#434c43'],
        \
        \ '06' : ['238' , '#434c43'],
        \ '07' : ['156' , '#aaff80'],
        \
        \ '08' : ['238' , '#434c43'],
        \ '09' : ['179' , '#ccbb66'],
        \
        \ '0A' : ['238' , '#434c43'],
        \ '0B' : ['192' , '#eaff80'],
        \
        \ '0C' : ['244' , '#7b897b'],
        \ '0D' : ['235' , '#272d27'],
        \ }
        "}}}
    elseif g:battlestar_theme ==? 'condition two'"{{{
        " color defs Generated two
        let g:battlestar#generated = 1
        let s:theme = [
            \   [190, 80, s:v], 
            \   [100, 50, s:v], 
            \   [ 70, 50, s:v], 
            \   [130, 50, s:v], 
            \   [ 40, 50, s:v]]
        let s:bg = [120.6, 30, 6]
        let s:fg = [120.6, 10, 90]
        let s:misc = [
            \   [354, 50, s:v-20], 
            \   [ 50, 50, s:v-20], 
            \   [110, 50, s:v-20]]
        "}}}
    elseif g:battlestar_theme ==? 'condition three'"{{{
        let g:battlestar#generated = 1
        let s:theme = [[220, 190,  100, 160, 130], 50, s:v]
        let s:bg = [214.6, 50, 6]
        let s:fg = [214.6, 10, 90]
        let s:misc = [[320, 50, 110], 50, 50]
        "}}}
    elseif g:battlestar_theme ==? 'pegasus'"{{{
        let g:battlestar#generated = 1
            " red
            " \   [351.6, 60.9, 51.7-s:red],
        let s:theme = [
            \   [144.5, 37.7, 68.6-s:red], 
            \   [192.1, 54.3, 87.1-s:red], 
            \   [ 44.8, 68.9, 89.9-s:red],
            \   [214.6, 65.3, 80.6-s:red],
            \   [150.7, 22.2, 81.1-s:red], 
            \ ]
        let s:bg = [247.1, 80.3, 15.3]
        " let s:bg = [247.1, 80.3, 10.3]
        let s:fg = [208.8, 16.6, 100]
        let s:misc = [
            \   [354, 50, s:v-20], 
            \   [ 50, 50, s:v-20], 
            \   [110, 50, s:v-20]]
        "}}}
    elseif g:battlestar_theme ==? 'galactica'"{{{
        let g:battlestar#generated = 1
            " \   [334.6, 55.3, 85.3-s:red], 
        let s:theme = [
            \   [  2.5, 71.8, 66.2-s:red], 
            \   [143.1, 36.1, 86.7-s:red], 
            \   [115.6, 43.7, 61.6-s:red], 
            \   [193.6, 43.7, 100 -s:red], 
            \   [ 32.9, 32.7, 98.4-s:red],
            \ ]
        let s:bg = [242.9, 50.9, 15.7]
        let s:fg = [347.1, 13.0, 100]
        let s:misc = [
            \   [354, 50, s:v-20], 
            \   [ 50, 50, s:v-20], 
            \   [110, 50, s:v-20]]
        "}}}
    elseif g:battlestar_theme ==? 'hard six'"{{{
        let g:battlestar#generated = 1
        let s:theme = [
            \   [180.0, 29.6, 52.9-s:red], 
            \   [189.4, 100 , 100 -s:red], 
            \   [283.5, 84.4, 90.0-s:red], 
            \   [198.8, 100 , 100 -s:red], 
            \   [208.2, 100 , 100 -s:red],
            \ ]
        let s:bg = [  0  ,  0  ,   0]
        let s:fg = [  0  ,  0  , 100]
        let s:misc = [
            \   [354, 50, s:v-20], 
            \   [ 50, 50, s:v-20], 
            \   [110, 50, s:v-20]]
        "}}}
    elseif g:battlestar_theme ==? 'hard eight'"{{{
        let g:battlestar#generated = 1
        let s:theme = [
            \   [200.0, 100 , 100 -s:red], 
            \   [162.2, 100 , 52.9-s:red], 
            \   [180.0, 29.6, 52.9-s:red], 
            \   [120.0, 45.7, 68.6-s:red], 
            \   [152.6, 100 , 68.6-s:red],
            \ ]
        let s:bg = [  0  ,  0  ,   0]
        let s:fg = [  0  ,  0  , 100]
        let s:misc = [
            \   [354, 50, s:v-20], 
            \   [ 50, 50, s:v-20], 
            \   [110, 50, s:v-20]]
        "}}}
    elseif g:battlestar_theme ==? 'term'"{{{
    " grey01 -> close to background
    " grey06 -> far from background
    let s:colors = { 
        \   'lightcolor'   : ['10'  , '#00ff00'],
        \   'brightcolor'  : ['10'  , '#00ff00'],
        \   'darkcolor'    : ['2'   , '#008000'],
        \   'accentcolor'  : ['12'  , '#0000ff'],
        \   'neutralcolor' : ['6'   , '#008080'],
        \
        \   'background'   : ['0'   , '#000000'],
        \   'foreground'   : ['15'  , '#ffffff'],
        \
        \   'grey01'       : ['0'   , '#000000'],
        \   'grey02'       : ['8'   , '#808080'],
        \   'grey03'       : ['8'   , '#808080'],
        \   'grey04'       : ['7'   , '#c0c0c0'],
        \   'grey05'       : ['7'   , '#c0c0c0'],
        \   'grey06'       : ['15'  , '#ffffff'],
        \
        \   'add'          : ['2'   , '#008000'],
        \   'change'       : ['3'   , '#808000'],
        \   'delete'       : ['1'   , '#800000'],
        \   }
    let s:airlinecolors = {
        \   '00' : s:colors.grey06,
        \   '01' : s:colors.grey01,
        \
        \   '02' : s:colors.grey06,
        \   '03' : s:colors.grey01,
        \
        \   '04' : s:colors.grey06,
        \   '05' : s:colors.grey02,
        \
        \   '06' : s:colors.grey05,
        \   '07' : s:colors.brightcolor,
        \
        \   '08' : s:colors.grey01,
        \   '09' : s:colors.change,
        \
        \   '0A' : s:colors.grey01,
        \   '0B' : s:colors.accentcolor,
        \
        \   '0C' : s:colors.grey02,
        \   '0D' : s:colors.grey01,
        \ }
    "}}}
    endif
    
    " Flip Colors{{{
    if g:battlestar#generated > 0
        if g:battlestar_shade > 0
            let s:colors = battlestar#palette(s:theme, [s:bg, s:fg], s:misc)
        else
            let s:colors = battlestar#palette(s:theme, [s:fg, s:bg], s:misc)
        endif
    endif
    "}}}

    if g:battlestar#generated > 0
    " airline settings{{{
    " 00 -> fg of B/Y
    " 01 -> bg of B/Y
    " 02 -> fg of C/X
    " 03 -> bg of C/X
    " 04 -> fg of A in Normal
    " 05 -> bg of A in Normal
    " 06 -> fg of A in Insert
    " 07 -> bg of A in Insert
    " 08 -> fg of A in Replace 
    " 09 -> bg of A in Replace 
    " 0A -> fg of A in Visual 
    " 0B -> bg of A in Visual 
    " 0C -> fg of A in Inactive
    " 0D -> bg of A in Inactive
    let s:airlinecolors = {
        \   '00' : s:colors.grey01,
        \   '01' : s:colors.grey05,
        \
        \   '02' : s:colors.grey06,
        \   '03' : s:colors.grey01,
        \
        \   '04' : s:colors.grey06,
        \   '05' : s:colors.grey02,
        \
        \   '06' : s:colors.grey02,
        \   '07' : s:colors.brightcolor,
        \
        \   '08' : s:colors.grey02,
        \   '09' : s:colors.change,
        \
        \   '0A' : s:colors.grey02,
        \   '0B' : s:colors.accentcolor,
        \
        \   '0C' : s:colors.grey04,
        \   '0D' : s:colors.grey01,
        \ }
    "}}}
    endif

    call extend(s:colors, {
       \ 'airlinecolors' : s:airlinecolors,})

    return s:colors
endfunction"}}}
function! battlestar#printscheme()"{{{
    let s:colors = battlestar#setpalette()

    let s:string = ""
        \   .  "let g:battlestar#generated = 0\n"
        \   .  "let s:colors = {\n"
        \   .  "\\ 'lightcolor'   : ['" . s:colors.lightcolor[0]   . "' , '" . s:colors.lightcolor[1]   . "'],\n" 
        \   .  "\\ 'brightcolor'  : ['" . s:colors.brightcolor[0]  . "' , '" . s:colors.brightcolor[1]  . "'],\n"
        \   .  "\\ 'darkcolor'    : ['" . s:colors.darkcolor[0]    . "' , '" . s:colors.darkcolor[1]    . "'],\n"
        \   .  "\\ 'accentcolor'  : ['" . s:colors.accentcolor[0]  . "' , '" . s:colors.accentcolor[1]  . "'],\n"
        \   .  "\\ 'neutralcolor' : ['" . s:colors.neutralcolor[0] . "' , '" . s:colors.neutralcolor[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ 'background'   : ['" . s:colors.background[0]   . "' , '" . s:colors.background[1]   . "'],\n"
        \   .  "\\ 'foreground'   : ['" . s:colors.foreground[0]   . "' , '" . s:colors.foreground[1]   . "'],\n"
        \   .  "\\\n"
        \   .  "\\ 'grey01'       : ['" . s:colors.grey01[0]       . "' , '" . s:colors.grey01[1]       . "'],\n"
        \   .  "\\ 'grey02'       : ['" . s:colors.grey02[0]       . "' , '" . s:colors.grey02[1]       . "'],\n"
        \   .  "\\ 'grey03'       : ['" . s:colors.grey03[0]       . "' , '" . s:colors.grey03[1]       . "'],\n"
        \   .  "\\ 'grey04'       : ['" . s:colors.grey04[0]       . "' , '" . s:colors.grey04[1]       . "'],\n"
        \   .  "\\ 'grey05'       : ['" . s:colors.grey05[0]       . "' , '" . s:colors.grey05[1]       . "'],\n"
        \   .  "\\ 'grey06'       : ['" . s:colors.grey06[0]       . "' , '" . s:colors.grey06[1]       . "'],\n"
        \   .  "\\\n"
        \   .  "\\ 'add'          : ['" . s:colors.add[0]          . "' , '" . s:colors.add[1]          . "'],\n"
        \   .  "\\ 'change'       : ['" . s:colors.change[0]       . "' , '" . s:colors.change[1]       . "'],\n"
        \   .  "\\ 'delete'       : ['" . s:colors.delete[0]       . "' , '" . s:colors.delete[1]       . "'],\n"
        \   .  "\\ }\n\n"
        \   .  "let s:airlinecolors = {\n"
        \   .  "\\ '00' : ['" . s:colors.airlinecolors.00[0] . "' , '" . s:colors.airlinecolors.00[1] . "'],\n"
        \   .  "\\ '01' : ['" . s:colors.airlinecolors.01[0] . "' , '" . s:colors.airlinecolors.01[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '02' : ['" . s:colors.airlinecolors.02[0] . "' , '" . s:colors.airlinecolors.02[1] . "'],\n"
        \   .  "\\ '03' : ['" . s:colors.airlinecolors.03[0] . "' , '" . s:colors.airlinecolors.03[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '04' : ['" . s:colors.airlinecolors.04[0] . "' , '" . s:colors.airlinecolors.04[1] . "'],\n"
        \   .  "\\ '05' : ['" . s:colors.airlinecolors.05[0] . "' , '" . s:colors.airlinecolors.05[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '06' : ['" . s:colors.airlinecolors.06[0] . "' , '" . s:colors.airlinecolors.06[1] . "'],\n"
        \   .  "\\ '07' : ['" . s:colors.airlinecolors.07[0] . "' , '" . s:colors.airlinecolors.07[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '08' : ['" . s:colors.airlinecolors.08[0] . "' , '" . s:colors.airlinecolors.08[1] . "'],\n"
        \   .  "\\ '09' : ['" . s:colors.airlinecolors.09[0] . "' , '" . s:colors.airlinecolors.09[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '0A' : ['" . s:colors.airlinecolors.0A[0] . "' , '" . s:colors.airlinecolors.0A[1] . "'],\n"
        \   .  "\\ '0B' : ['" . s:colors.airlinecolors.0B[0] . "' , '" . s:colors.airlinecolors.0B[1] . "'],\n"
        \   .  "\\\n"
        \   .  "\\ '0C' : ['" . s:colors.airlinecolors.0C[0] . "' , '" . s:colors.airlinecolors.0C[1] . "'],\n"
        \   .  "\\ '0D' : ['" . s:colors.airlinecolors.0D[0] . "' , '" . s:colors.airlinecolors.0D[1] . "'],\n"
        \   .  "\\ }\n"

    echo s:string
    return s:string
endfunction"}}}

