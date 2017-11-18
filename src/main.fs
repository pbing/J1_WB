\ Compile the firmware

include crossj1.fs
include basewords.fs

target
4 org

module[ everything"

include nuc.fs
include application.fs

]module

0 org

code 0jump
    main ubranch
end-code

\ **********************************************************************

meta
hex

: create-output-file w/o create-file throw to outfile ;

s" j1.hex" create-output-file
:noname
    2000 0 do
       i t@ s>d <# # # # # #> type cr
    2 +loop
; execute

s" j1.lst" create-output-file
0 2000 disassemble-block

bye
