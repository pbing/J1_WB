module[ application"

\ calculate
: main ( --- )
    decimal
    d# 89. <# # # #>
    drop @  led !
    begin again ;

]module
