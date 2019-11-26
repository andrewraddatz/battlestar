Because this packages relies on autloading to generate colors for both
the main theme and for airline, you'll need to force loading in your
.vimrc if you want to use it immediately

    packadd! battlestar
    color battlestar

Colors are set with HSV values are are calculated on the fly rather than
being pre-specified, but they can be produced and saved in [cterm, gui]
format and read in that way.
