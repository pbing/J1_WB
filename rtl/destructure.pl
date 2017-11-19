# Destructure complex data type because Altera/Intel Quartus II
# compiler can not synthesize unions.

use warnings;
use strict;

while (<>) {
    s/instr_t/logic [15:0]/;
    s/\.lit\.tag/[15]/;
    s/\.lit\.immediate/[14:0]/;

    s/\.bra\.tag/[15:13]/;
    s/\.bra\.address/[12:0]/;

    s/\.alu\.tag/[15:13]/;
    s/\.alu\.r_to_pc/[12]/;
    s/\.alu\.op/[11:8]/;
    s/\.alu\.t_to_n/[7]/;
    s/\.alu\.t_to_r/[6]/;
    s/\.alu\.n_to_mem/[5]/;
    s/\.alu\.reserved/[4]/;
    s/\.alu\.rstack/[3:2]/;
    s/\.alu\.dstack/[1:0]/;

    s/(is_alu\s+:\s+op = )(.*);/$1op_t'($2);/;

    print;
}

