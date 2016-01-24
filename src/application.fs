\ Application

module[ application"

: main ( --)
    begin
	h# 0123 h# 4000 !
        h# 1234 h# 4002 !
        h# 2345 h# 4004 !
        h# 3456 h# 4006 !          

        h# 4000 @
        h# 4002 @
        h# 4004 @
        h# 4006 @
	drop drop drop drop     
    again ;

]module
