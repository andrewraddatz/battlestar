command! Condition1     :color condition1
command! Condition2     :color condition2
command! Condition3     :color condition3

command! HardSix        :color hardsix
command! HardEight      :color hardeight

command! Galactica      :color galactica
command! Pegasus        :color pegasus

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

