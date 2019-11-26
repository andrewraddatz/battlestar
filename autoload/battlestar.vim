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
function! battlestar#theme_color_palette(h, s, v)"{{{
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
function! battlestar#misc_color_palette(h, s, v)"{{{
    let l:colors = { 
    \   'delete'       : battlestar#colorize(a:h[0], a:s, a:v),
    \   'change'       : battlestar#colorize(a:h[1], a:s, a:v),
    \   'add'          : battlestar#colorize(a:h[2], a:s, a:v),
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
    call battlestar#setgroup(a:colors.grey03, s:clear, s:none)"{{{
    call battlestar#highlight('Special',               s:fg, s:bg, s:style)
    call battlestar#highlight('SpecialKey',            s:fg, s:bg, s:style)
    call battlestar#highlight('SpecialChar',           s:fg, s:bg, s:style)
    call battlestar#highlight('Delimiter',             s:fg, s:bg, s:style)
    call battlestar#highlight('SpecialComment',        s:fg, s:bg, s:style)
    call battlestar#highlight('Debug',                 s:fg, s:bg, s:style)
    call battlestar#highlight('Underlined',            s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.background, a:colors.brightcolor, s:none)"{{{
    call battlestar#highlight('Error',                 s:fg, s:bg, s:style)
    call battlestar#highlight('Todo',                  s:fg, s:bg, s:style)
    "}}}
    "
    " call battlestar#highlight('MatchParen',            s:fg, s:bg, s:style)
    "
    " Figure these out
    " call battlestar#highlight('StatusLine',            s:fg, s:bg, s:style)
    " call battlestar#highlight('StatusLineNC',          s:fg, s:bg, s:style)
    " call battlestar#highlight('StatusLineTerm',        s:fg, s:bg, s:style)
    " call battlestar#highlight('StatusLineTermNC',      s:fg, s:bg, s:style)
    " call battlestar#highlight('DiffText',              s:fg, s:bg, s:style)
    " call battlestar#highlight('ErrorMsg',              s:fg, s:bg, s:style)
    " call battlestar#highlight('IncSearch',             s:fg, s:bg, s:style)
    " call battlestar#highlight('Search',                s:fg, s:bg, s:style)
    " call battlestar#highlight('ModeMsg',               s:fg, s:bg, s:style)
    " call battlestar#highlight('MoreMsg',               s:fg, s:bg, s:style)
    " call battlestar#highlight('Question',              s:fg, s:bg, s:style)
    "
    
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
    call battlestar#setgroup(s:none, s:clear, s:reverse)"{{{
    call battlestar#highlight('Visual',                s:fg, s:bg, s:style)
    call battlestar#highlight('iCursor',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.neutralcolor, s:clear, s:none)"{{{
    call battlestar#highlight('LineNr',                s:fg, s:bg, s:style)
    call battlestar#highlight('NonText',               s:fg, s:bg, s:style)
    call battlestar#highlight('VertSplit',             s:fg, s:bg, s:style)
    call battlestar#highlight('Comment',               s:fg,  s:bg,  s:style)
    "}}}
    call battlestar#setgroup(a:colors.brightcolor, s:clear, s:none)"{{{
    call battlestar#highlight('CursorLineNr',          s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.darkcolor, s:clear, s:none)"{{{
    call battlestar#highlight('Folded',                s:fg, s:bg, s:style)
    call battlestar#highlight('FoldColumn',            s:fg, s:bg, s:style)
    call battlestar#highlight('Conceal',               s:fg, s:bg, s:style)
"}}}

    " Git
    call battlestar#setgroup(a:colors.add, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterAdd',          s:fg, s:bg, s:style)
    call battlestar#highlight('DiffAdd',               s:fg, s:bg, s:style)
    "}}}
    call battlestar#setgroup(a:colors.change, s:clear, s:none)"{{{
    call battlestar#highlight('GitGutterChange',       s:fg, s:bg, s:style)
    call battlestar#highlight('DiffChange',            s:fg, s:bg, s:style)
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
    call battlestar#highlight('SpellBad',              a:colors.delete,         s:clear,        s:none)
    call battlestar#highlight('SpellCap',              a:colors.neutralcolor,   s:clear,        s:none)
    call battlestar#highlight('SpellLocal',            a:colors.add,            s:clear,        s:none)
    call battlestar#highlight('SpellRare',             a:colors.accentcolor,    s:clear,        s:none)
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
function! battlestar#palette(theme, filler, misc)"{{{
    let l:theme =  battlestar#theme_color_palette(a:theme[0], a:theme[1], a:theme[2])
    call extend(l:theme, battlestar#misc_color_palette(a:misc[0], a:misc[1], a:misc[2]))
    call extend(l:theme, 
                \    battlestar#filler_colors(
                \        battlestar#hsv2rgb(a:filler[0][0], a:filler[0][1], a:filler[0][2]), 
                \        battlestar#hsv2rgb(a:filler[1][0], a:filler[1][1], a:filler[1][2])
                \    )
                \ )

    return l:theme
endfunction"}}}
function! battlestar#setpalette()"{{{
    if has("win32") && !has("gui_running")"{{{
        let g:battlestar_theme="term"
    endif"}}}
    if !exists('g:battlestar_theme')"{{{
        let g:battlestar_theme="condition two"
    endif"}}}
    if !exists('g:battlestar_shade')"{{{
        let g:battlestar_shade=1
    endif"}}}
    if g:battlestar_shade == 1"{{{
        set background=dark
        let s:v = 90
    else
        set background=light
        let s:v = 60
    endif"}}}

    let g:battlestar#generated = 0
    if g:battlestar_theme ==? 'condition one'
        " color defs Generated Red{{{
        let g:battlestar#generated = 1
        let s:theme = [[20, 50, 290, 350, 110], 50, s:v]
        let s:bg = [12.6, 30, 6]
        let s:fg = [12.6, 10, 90]
        let s:misc = [[314, 50, 110], 50, 50]
        "}}}
    elseif g:battlestar_theme ==? 'condition two'
        " color defs Generated Green{{{
        let g:battlestar#generated = 1
        let s:theme = [[190, 100, 70, 130, 40], 50, s:v]
        let s:bg = [120.6, 30, 6]
        let s:fg = [120.6, 10, 90]
        let s:misc = [[354, 50, 110], 50, s:v-20]
        "}}}
    elseif g:battlestar_theme ==? 'condition three'
        " color defs Generated Blue{{{
        let g:battlestar#generated = 1
        let s:theme = [[220, 190,  100, 160, 130], 50, s:v]
        let s:bg = [214.6, 50, 6]
        let s:fg = [214.6, 10, 90]
        let s:misc = [[320, 50, 110], 50, 50]
        "}}}
    elseif g:battlestar_theme ==? 'hard six'
    " Picking Color Palette{{{
    " grey01 -> close to background
    " grey06 -> far from background
    let s:colors = { 
        \   'lightcolor'   : ['39'  , '#00afff'],
        \   'brightcolor'  : ['45'  , '#00d7ff'],
        \   'darkcolor'    : ['33'  , '#0087ff'],
        \   'accentcolor'  : ['93'  , '#8700ff'],
        \   'neutralcolor' : ['66'  , '#5f8787'],
        \
        \   'background'   : ['16'  , '#000000'],
        \   'foreground'   : ['15'  , '#ffffff'],
        \
        \   'grey01'       : ['234' , '#1c1c1c'],
        \   'grey02'       : ['239' , '#4e4e4e'],
        \   'grey03'       : ['242' , '#6c6c6c'],
        \   'grey04'       : ['245' , '#8a8a8a'],
        \   'grey05'       : ['247' , '#9e9e9e'],
        \   'grey06'       : ['253' , '#dadada'],
        \
        \   'add'          : ['196' , '#ff0000'],
        \   'change'       : ['154' , '#afff00'],
        \   'delete'       : ['22'  , '#005f00'],
        \   }
    let s:airlinecolors = {
        \   '00' : s:colors.grey06,
        \   '01' : s:colors.grey03,
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
        \   '0A' : s:colors.grey06,
        \   '0B' : s:colors.accentcolor,
        \
        \   '0C' : s:colors.grey02,
        \   '0D' : s:colors.grey01,
        \ }
    "}}}
    elseif g:battlestar_theme ==? 'hard eight'
    " Picking Color Palette{{{
    " grey01 -> close to background
    " grey06 -> far from background
    let s:colors = { 
        \   'lightcolor'   : ['71'  , '#5faf5f'],
        \   'brightcolor'  : ['29'  , '#00875f'],
        \   'darkcolor'    : ['35'  , '#00af5f'],
        \   'accentcolor'  : ['66'  , '#5f8787'],
        \   'neutralcolor' : ['39'  , '#00afff'],
        \
        \   'background'   : ['16'  , '#000000'],
        \   'foreground'   : ['15'  , '#ffffff'],
        \
        \   'grey01'       : ['234' , '#1c1c1c'],
        \   'grey02'       : ['239' , '#4e4e4e'],
        \   'grey03'       : ['242' , '#6c6c6c'],
        \   'grey04'       : ['245' , '#505050'],
        \   'grey05'       : ['247' , '#9e9e9e'],
        \   'grey06'       : ['253' , '#dadada'],
        \
        \   'add'          : ['196' , '#ff0000'],
        \   'change'       : ['154' , '#afff00'],
        \   'delete'       : ['22'  , '#005f00'],
        \   }
    let s:airlinecolors = {
        \   '00' : s:colors.grey06,
        \   '01' : s:colors.grey03,
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
        \   '0A' : s:colors.grey06,
        \   '0B' : s:colors.accentcolor,
        \
        \   '0C' : s:colors.grey02,
        \   '0D' : s:colors.grey01,
        \ }
    "}}}
    elseif g:battlestar_theme ==? 'term'
    " Picking Color Palette{{{
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
    elseif g:battlestar_theme ==? 'the line'
        " color defs Generated Saturated{{{
        let g:battlestar#generated = 1
        let s:theme = [[120, 30,  240, 0, 300], 100, 100]
        let s:bg = [214.6, 0, 0]
        let s:fg = [214.6, 0, 100]
        let s:misc = [[320, 50, 110], 50, 50]
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

