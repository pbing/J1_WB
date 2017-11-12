\ Application

module[ application"

: main ( --)
    begin
        \ RAM 
	h# 0123 h# 1000 !
        h# 1234 h# 1002 !
        h# 2345 h# 1004 !
        h# 3456 h# 1006 !
        h# 1000 @
        h# 1002 @
        h# 1004 @
        h# 1006 @
        drop drop drop drop

        \ I/O
        h# 1111 h# 4000 ! \ IO1
        h# 2222 h# 5000 ! \ IO2
        h# 3333 h# 6000 ! \ IO3
        h# 4444 h# 7000 ! \ IO4

        h# 1110 h# 4FFE ! \ IO1
        h# 2220 h# 5FFE ! \ IO2
        h# 3330 h# 6FFE ! \ IO3
        h# 4440 h# 7FFE ! \ IO4

        h# 4000 @ \ IO1
        h# 5000 @ \ IO2
        h# 6000 @ \ IO3
        h# 7000 @ \ IO4
        drop drop drop drop
    again ;

]module
