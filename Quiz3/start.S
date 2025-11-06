.section .text._start
.globl _start
.type _start, @function

_start:
    la sp, __stack_top
    
    la t0, __bss_start
    la t1, __bss_end
clear_bss:
    bge t0, t1, bss_cleared
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss
bss_cleared:
    call main

    li a7, 93
    li a0, 0
    ecall
infinite_loop:
    j infinite_loop

.size _start, .-_start

.weak __bss_start
.weak __bss_end
.weak __stack_top