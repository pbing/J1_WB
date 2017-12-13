module[ application"

16 constant #leds

: >thermometer  ( u1 -- u2 )  d# 1 swap lshift  1- ;

: 1ms ( -- )   d# 25000 begin dup while 1- repeat drop ;
: ms ( u -- )   begin dup while 1- 1ms repeat drop ;
: wait ( -- )   d# 50 ms ;

\ ---- ---* --** -*** ****
: blink-left+ ( -- )
    #leds 1+ 0do
       wait       
       i >thermometer
       led !
    loop ;


\ **** ***- **-- *--- ----
: blink-left- ( -- )
    #leds 1+ 0do
       wait
       i >thermometer invert
       led !
    loop ;

\ ---- *--- **-- ***- ****
: blink-right+ ( -- )
    #leds 1+ 0do
       wait
       #leds i -  >thermometer invert
       led !
    loop ;

\ **** -*** --** ---* ----
: blink-right- ( -- )
    #leds 1+ 0do
       wait
       #leds i -  >thermometer
       led !
    loop ;

: main ( -- )
    begin
        blink-left+
        blink-left-
        blink-right+
        blink-right-
    again ;

]module
