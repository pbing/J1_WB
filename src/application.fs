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

1 [IF]
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


]module
