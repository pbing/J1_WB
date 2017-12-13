\ Compile the firmware

include crossj1.fs
include basewords.fs

target
\ low high  type          name
$0000 $3fff cdata section ROM  \ ROM
$4000 $4fff udata section URAM \ uninitalized RAM
\ ... ...   idata section IRAM \ initalized RAM

ROM
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

\ for RTL simulation
s" j1.hex" create-output-file
:noname
    4000 0 do
       i t@ s>d <# # # # # #> type cr
    2 +loop
; execute

\ for Quartus II synthesis
s" j1.mif" create-output-file
:noname
   s" -- Quartus II generated Memory Initialization File (.mif)" type cr
   s" WIDTH=16;" type cr
   s" DEPTH=8192;" type cr
   s" ADDRESS_RADIX=HEX;" type cr
   s" DATA_RADIX=HEX;" type cr
   s" CONTENT BEGIN" type cr

    4000 0 do
       4 spaces
       i 2/ s>d <# # # # # #> type s"  : " type
       i t@ s>d <# # # # # #> type [char] ; emit cr
    2 +loop

   s" END;" type cr
; execute

s" j1.lst" create-output-file
0 2000 disassemble-block

.s
bye
