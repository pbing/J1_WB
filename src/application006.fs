module[ application"

\ number to string conversion
\ lots of division
: main ( --- )
    decimal
    d# 89. <# # # #>
    drop @  led !
    begin again ;

]module
