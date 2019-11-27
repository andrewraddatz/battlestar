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
command! Condition1     :call ConditionOne()
command! Condition2     :call ConditionTwo()
command! Condition3     :call ConditionThree()

function! HardSix()"{{{
    let g:battlestar_theme = 'hard six'
    color battlestar
endfunction"}}}
function! HardEight()"{{{
    let g:battlestar_theme = 'hard eight'
    color battlestar
endfunction"}}}
command! HardSix        :call HardSix()
command! HardEight      :call HardEight()

function! Galactica()"{{{
    let g:battlestar_theme = 'galactica'
    color battlestar
endfunction"}}}
function! Pegasus()"{{{
    let g:battlestar_theme = 'pegasus'
    color battlestar
endfunction"}}}
command! Galactica      :call Galactica()
command! Pegasus        :call Pegasus()

function! ActionStations()"{{{
    let g:battlestar_shade = 0
    color battlestar
endfunction"}}}
function! StandDown()"{{{
    let g:battlestar_shade = 1
    color battlestar
endfunction"}}}
command! ActionStations :call ActionStations()
command! StandDown      :call StandDown()

