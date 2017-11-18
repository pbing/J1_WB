\ Application

module[ application"

h# 4000 constant a
h# 4002 constant b

\ 10th fibonacci
: main ( -- 55 )
    d# 1 a !  d# 1 b !
    d# 8 0do
       a @  b @  tuck +  b !  a !
    loop
    b @
    begin again ;

]module
