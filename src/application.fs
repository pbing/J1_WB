\ Application

module[ application"

: main ( --)
    begin
	h# 0123 h# 1000 !
        h# 1234 h# 1002 !
        h# 2345 h# 1004 !
        h# 3456 h# 1006 !          

        h# 1000 @
        h# 1002 @
        h# 1004 @
        h# 1006 @
	drop drop drop drop     
    again ;

]module
