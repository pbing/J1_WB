\ Application

module[ application"


0 [IF]
\ 10th fibonacci
\ with no memory access
\ 179 cycles
: main ( --- 55 )
    d# 1 d# 1
    d# 8 0do  tuck +  loop
    nip
    begin again ;
[THEN]

0 [IF]
\ 10th fibonacci
\ with memory access
\ 301 cycles
h# 4000 constant a
h# 4002 constant b

: main ( -- 55 )
    d# 1 a !  d# 1 b !
    d# 8 0do
       a @  b @  tuck +  b !  a !
    loop
    b @
    begin again ;
[THEN]

0 [IF]
h# 6000 constant sw
h# 7000 constant led

: main ( --- )
    begin
        sw @  led !
    again ;
[THEN]

1 [IF]
h# 6000 constant sw
h# 7000 constant led
d# 15 constant #leds

: >thermometer  ( u1 -- u2 )  d# 1 swap lshift  1- ;

: 1ms ( -- )   d# 25000 begin dup while 1- repeat drop ;
: ms ( u -- )   begin dup while 1- 1ms repeat drop ;
: wait ( -- )   d# 50 ms ;

\ ----
\ ---*
\ --**
\ -***
\ ****
: blink-left+ ( -- )
    #leds 0do
       wait       
       i >thermometer
       led !
    loop ;


\ ****
\ ***-
\ **--
\ *---
\ ----
: blink-left- ( -- )
    #leds 0do
       wait
       i >thermometer invert
       led !
    loop ;

\ ----
\ *---
\ **--
\ ***-
\ ****
: blink-right+ ( -- )
    #leds 0do
       wait
       #leds 1- i -  >thermometer
       led !
    loop ;

\ ****
\ -***
\ --**
\ ---*
\ ----
: blink-right- ( -- )
    #leds 0do
       wait
       #leds 1- i -  >thermometer invert
       led !
    loop ;

: main ( -- )
    begin
        blink-left+
        blink-left-
        blink-right-
        blink-right+
    again ;
[THEN]

]module
