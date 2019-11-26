function! ConditionOne()"{{{
    let g:battlestar_theme = 'condition one'
    color battlestar
endfunction"}}}
function! ConditionTwo()"{{{
    let g:battlestar_theme = 'condition two'
    color battlestar
endfunction"}}}
function! ConditionThree()"{{{
    let g:battlestar_theme = 'condition three'
    color battlestar
endfunction"}}}
function! ActionStations()"{{{
    let g:old_battlestar_theme = g:battlestar_theme
    let g:battlestar_theme = 'the line'
    if g:battlestar_shade > 0
        set background=dark
    else
        set background=light
    endif
    let g:battlestar_shade = -1
    color battlestar
endfunction"}}}
function! HardSix()"{{{
    let g:battlestar_theme = 'hard six'
    color battlestar
endfunction"}}}
function! HardEight()"{{{
    let g:battlestar_theme = 'hard eight'
    color battlestar
endfunction"}}}
function! BattlestarFlip()"{{{
    if g:battlestar_shade > 0
        set background=dark
    else
        set background=light
    endif
    let g:battlestar_shade = g:battlestar_shade * -1
    color battlestar
endfunction"}}}
function! StandDown()"{{{
    if !exists('g:old_battlestar_theme')
        let g:old_battlestar_theme='condition three'
    endif
    let g:battlestar_theme=g:old_battlestar_theme
    set background=dark
    let g:battlestar_shade = 1
    color battlestar
endfunction"}}}

command! Condition1     :call ConditionOne()
command! Condition2     :call ConditionTwo()
command! Condition3     :call ConditionThree()
command! HardSix        :call HardSix()
command! HardEight      :call HardEight()
command! ActionStations :call ActionStations()
command! StandDown      :call StandDown()
command! Pegasus        :call battlestarFlip()

