    .text
    .globl  main
main:
    addi    x2, x2, -36
    sw      x8, 0(x2)
    sw      x9, 4(x2)
    sw      x18, 8(x2)
    sw      x19, 12(x2)
    sw      x20, 16(x2)

    li      x5, 0x15
    sw      x5, 20(x2)
    sw      x5, 24(x2)
    sw      x5, 28(x2)
    sw      ra, 32(x2)

    sw      x0, 20(x2)

    sw      x0, 24(x2)

    sw      x0, 28(x2)

    addi    x8, x0, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_1

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_1

    addi    x9, x0, 2

disk_found_1:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_1
    jal     x0, continue_move_1
pattern_match_1:
continue_move_1:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_1

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_1
    sub     x19, x19, x6
    jal     x0, display_move_1

handle_large_1:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_1:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_2

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_2

    addi    x9, x0, 2

disk_found_2:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_2
    jal     x0, continue_move_2
pattern_match_2:
continue_move_2:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_2

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_2
    sub     x19, x19, x6
    jal     x0, display_move_2

handle_large_2:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_2:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_3

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_3

    addi    x9, x0, 2

disk_found_3:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_3
    jal     x0, continue_move_3
pattern_match_3:
continue_move_3:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_3

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_3
    sub     x19, x19, x6
    jal     x0, display_move_3

handle_large_3:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_3:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_4

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_4

    addi    x9, x0, 2

disk_found_4:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_4
    jal     x0, continue_move_4
pattern_match_4:
continue_move_4:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_4

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_4
    sub     x19, x19, x6
    jal     x0, display_move_4

handle_large_4:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_4:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_5

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_5

    addi    x9, x0, 2

disk_found_5:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_5
    jal     x0, continue_move_5
pattern_match_5:
continue_move_5:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_5

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_5
    sub     x19, x19, x6
    jal     x0, display_move_5

handle_large_5:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_5:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_6

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_6

    addi    x9, x0, 2

disk_found_6:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_6
    jal     x0, continue_move_6
pattern_match_6:
continue_move_6:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_6

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_6
    sub     x19, x19, x6
    jal     x0, display_move_6

handle_large_6:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_6:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

    srli    x5, x8, 1

    xor     x6, x8, x5

    addi    x7, x8, -1
    srli    x28, x7, 1

    xor     x7, x7, x28

    xor     x5, x6, x7

    addi    x9, x0, 0

    andi    x6, x5, 1

    bne     x6, x0, disk_found_7

    addi    x9, x0, 1

    andi    x6, x5, 2
    bne     x6, x0, disk_found_7

    addi    x9, x0, 2

disk_found_7:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match_7
    jal     x0, continue_move_7
pattern_match_7:
continue_move_7:

    slli    x5, x9, 2

    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large_7

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move_7
    sub     x19, x19, x6
    jal     x0, display_move_7

handle_large_7:
    lw      x6, 20(x2)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move_7:
    la      x20, obdata
    add     x5, x20, x18
    lbu     x11, 0(x5)
    li      x6, 0x6F
    xor     x11, x11, x6
    addi    x11, x11, -0x12

    add     x7, x20, x19
    lbu     x12, 0(x7)
    xor     x12, x12, x6
    addi    x12, x12, -0x12

    mv      t1, x11
    mv      t2, x12
    li a7, 0x40
    li a0, 1
    la a1, str1
    li a2, 10
    ecall

    addi    x10, x9, 1
    jal print_dec

    li a0, 1
    la a1, str2
    li a2, 6
    ecall

    la t0, char_buffer
    sb t1, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str3
    li a2, 4
    ecall

    la t0, char_buffer
    sb t2, 0(t0)
    li a0, 1
    mv a1, t0
    li a2, 1
    ecall

    li a0, 1
    la a1, str4
    li a2, 1
    ecall

    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    sw      x19, 0(x5)

    addi    x8, x8, 1

finish_game:
    lw      x8, 0(x2)
    lw      x9, 4(x2)
    lw      x18, 8(x2)
    lw      x19, 12(x2)
    lw      x20, 16(x2)
    lw      ra, 32(x2)
    addi    x2, x2, 36
    ret

    .data
obdata:     .byte   0x3c, 0x3b, 0x3a
str1:       .asciz  "Move Disk "
str2:       .asciz  " from "
str3:       .asciz  " to "
str4:       .asciz  "\n"
char_buffer: .space  1