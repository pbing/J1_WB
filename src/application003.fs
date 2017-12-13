module[ application"

\ copy SW[9:0] and KEY[3:0] to LED arrays
: main ( --- )
    begin
        sw @  led !
    again ;

]module
