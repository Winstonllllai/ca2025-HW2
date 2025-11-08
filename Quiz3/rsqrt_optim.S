.text
.globl  main
main:
    addi   sp, sp, -16
    sw     ra, 0(sp)
    sw     s0, 4(sp)
    sw     s1, 8(sp)
    sw     s2, 12(sp)
    li a7, 0x40         # syscall: write
    li a0, 1            # file descriptor (stdout)
    la a1, str1         # Load address of
    li a2, 23           # length
    ecall
    la t0, test_data
    lw a0, 0(t0)
    jal print_dec
    li a0, 1
    la a1, str2         # Load address of
    li a2, 6            # length
    ecall
    jal get_cycles
    mv s0, a0           # s0 = start_cycles
    jal get_instret
    mv s1, a0           # s1 = start_instret
    la a0, test_data
    lw a0, 0(a0)
    jal fast_rsqrt
    mv s2, a0           # s2 = result
    jal get_cycles
    sub s0, a0, s0      # s0 = end_cycles - start
    jal get_instret
    sub s1, a0, s1      # s1 = end_instret - start
    mv a0, s2           # a0 = result
    jal print_dec
    li a0, 1
    la a1, str3         # Load address of
    li a2, 16           # length
    ecall
    li a7, 0x40         # syscall: write
    li a0, 1            # file descriptor (stdout)
    la a1, str4         # Load address of
    li a2, 14           # length
    ecall
    mv a0, s0           # a0 = cycle count
    jal print_dec
    li a7, 0x40         # syscall: write
    li a0, 1            # file descriptor (stdout)
    la a1, str5         # Load address of
    li a2, 16           # length
    ecall
    mv a0, s1           # a0 = instret count
    jal print_dec
    li a7, 0x40         # syscall: write
    li a0, 1            # file descriptor (stdout)
    la a1, str6         # Load address of
    li a2, 1            # length
    ecall
    lw     s2, 12(sp)
    lw     s1, 8(sp)
    lw     s0, 4(sp)
    lw     ra, 0(sp)
    addi   sp, sp, 16
    ret
# ============================================================
# function: fast_rsqrt
# ============================================================
newton_step:
    # Input: a0 = *rec_inv_sqrt (uint32_t pointer)
    #        a1 = x (uint32_t)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    mv s0, a0          # s0 = rec_inv_sqrt
    mv s1, a1          # s1 = x
    lw s2, 0(s0)       # s2 = *rec_inv_sqrt
    mv a0, s2       # a0 = invsqrt
    mv a1, s2       # a1 = invsqrt
    jal ra, mul32      # invsqrt^2, a1 = invsqrt2 = y^2_hi = invsqrt^2 >> 32
    mv a0, s1       # a0 = x
    jal ra, mul32      # prod = x * invsqrt2
    li t0, 3
    beqz a0, newton_step.zero_prod_lo
    sub a0, zero, a0  # a0 = val_lo = 0 - prod_lo
    addi t0, t0, -1     # t0 = 2
newton_step.zero_prod_lo:
    sub a1, t0, a1  # a1 = val_hi = 3 - prod_hi
    andi t1, a1, 0x3  # t1 = val_hi & 0x3, lower 2 bits
    slli t1, t1, 30    # t1 = (val_hi & 0x3) << 30
    srli a0, a0, 2     # a0 = val_lo >> 2
    or a0, a0, t1   # a0 = (val_hi & 0x3) << 30 | (val_lo >> 2)
    srli a1, a1, 2     # a1 = val_hi >> 2
    mv s1, a1      # s1 = val_hi
    mv a1, s2       # a1 = invsqrt
    jal ra, mul32      # new_val_lo = val * invsqrt
    mv t0, a0      # a0 = new_val_lo_lo
    mv a0, s1      # a0 = val_hi
    mv s1, a1     # s1 = new_val_lo_hi
    mv a1, s2       # a1 = invsqrt
    mv s2, t0      # s2 = new_val_lo_lo
    jal ra, mul32      # new_val_hi = invsqrt * val_hi
    add a0, s1, a0   # a0 = new_val_lo_hi + new_val_hi_lo
    slli a0, a0, 1 
    srli s2, s2, 31    # new_val_lo_lo >> 31
    or a0, a0, s2   # a0 = new_val_hi + (new_val_lo_lo >> 31)
    sw a0, 0(s0)      # *rec_inv_sqrt = new_val_lo
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret

# ============================================================
# function: clz
# ============================================================
clz:
    # Input: a0 = x (uint32_t)
    # Output: a0 = clz(x) (uint32_t)
    bnez a0, clz.not_zero
    li a0, 32           # return 32 for x == 0
    ret
clz.not_zero:
    li t0, 0            # n = 0
    lui t1, 0xFFFF0      # mask = 0xFFFF0000
    and t2, a0, t1
    bnez t2, clz.skip1 
    addi t0, t0, 16     # n += 16
    slli a0, a0, 16
clz.skip1:
    lui t1, 0xFF000       # mask = 0xFF000000
    and t2, a0, t1
    bnez t2, clz.skip2
    addi t0, t0, 8      # n += 8
    slli a0, a0, 8
clz.skip2:
    lui t1, 0xF0000       # mask = 0xF0000000
    and t2, a0, t1
    bnez t2, clz.skip3
    addi t0, t0, 4      # n += 4
    slli a0, a0, 4
clz.skip3:
    lui t1, 0xC0000       # mask = 0xC0000000
    and t2, a0, t1
    bnez t2, clz.skip4
    addi t0, t0, 2      # n += 2
    slli a0, a0, 2
clz.skip4:
    lui t1, 0x80000       # mask = 0x80000000
    and t2, a0, t1
    bnez t2, clz.end
    addi t0, t0, 1      # n += 1
clz.end:
    mv a0, t0           # return n
    ret

# ============================================================
# function: mul32_split (Unrolled)
# ============================================================
mul32:
    # Input: a0 = a (uint32_t)
    #        a1 = b (uint32_t)
    # Output: a0 = r_lo (low 32), a1 = r_hi (high 32)
    li t2, 0            # r_lo = 0
    li t3, 0            # r_hi = 0
    li t4, 1            # bitmask = 1

# for i = 0
    slli t5, t4, 0     # bitmask = 1 << 0
    and t5, a1, t5     # check if b's 0-th bit
    beqz t5, mul32.skip1_0  # if bit is 0, skip
    slli t5, a0, 0     # add_lo = a << 0
    li t6, 0           # add_hi = 0
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_0  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_0:

# for i = 1
    slli t5, t4, 1     # bitmask = 1 << 1
    and t5, a1, t5     # check if b's 1-th bit
    beqz t5, mul32.skip1_1  # if bit is 0, skip
    slli t5, a0, 1     # add_lo = a << 1
    li t6, 31          # 32 - 1
    srl t6, a0, t6     # add_hi = a >> (32 - 1)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_1  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_1:

# for i = 2
    slli t5, t4, 2     # bitmask = 1 << 2
    and t5, a1, t5     # check if b's 2-th bit
    beqz t5, mul32.skip1_2  # if bit is 0, skip
    slli t5, a0, 2     # add_lo = a << 2
    li t6, 30          # 32 - 2
    srl t6, a0, t6     # add_hi = a >> (32 - 2)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_2  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_2:

# for i = 3
    slli t5, t4, 3     # bitmask = 1 << 3
    and t5, a1, t5     # check if b's 3-th bit
    beqz t5, mul32.skip1_3  # if bit is 0, skip
    slli t5, a0, 3     # add_lo = a << 3
    li t6, 29          # 32 - 3
    srl t6, a0, t6     # add_hi = a >> (32 - 3)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_3  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_3:

# for i = 4
    slli t5, t4, 4     # bitmask = 1 << 4
    and t5, a1, t5     # check if b's 4-th bit
    beqz t5, mul32.skip1_4  # if bit is 0, skip
    slli t5, a0, 4     # add_lo = a << 4
    li t6, 28          # 32 - 4
    srl t6, a0, t6     # add_hi = a >> (32 - 4)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_4  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_4:

# for i = 5
    slli t5, t4, 5     # bitmask = 1 << 5
    and t5, a1, t5     # check if b's 5-th bit
    beqz t5, mul32.skip1_5  # if bit is 0, skip
    slli t5, a0, 5     # add_lo = a << 5
    li t6, 27          # 32 - 5
    srl t6, a0, t6     # add_hi = a >> (32 - 5)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_5  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_5:

# for i = 6
    slli t5, t4, 6     # bitmask = 1 << 6
    and t5, a1, t5     # check if b's 6-th bit
    beqz t5, mul32.skip1_6  # if bit is 0, skip
    slli t5, a0, 6     # add_lo = a << 6
    li t6, 26          # 32 - 6
    srl t6, a0, t6     # add_hi = a >> (32 - 6)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_6  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_6:

# for i = 7
    slli t5, t4, 7     # bitmask = 1 << 7
    and t5, a1, t5     # check if b's 7-th bit
    beqz t5, mul32.skip1_7  # if bit is 0, skip
    slli t5, a0, 7     # add_lo = a << 7
    li t6, 25          # 32 - 7
    srl t6, a0, t6     # add_hi = a >> (32 - 7)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_7  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_7:

# for i = 8
    slli t5, t4, 8     # bitmask = 1 << 8
    and t5, a1, t5     # check if b's 8-th bit
    beqz t5, mul32.skip1_8  # if bit is 0, skip
    slli t5, a0, 8     # add_lo = a << 8
    li t6, 24          # 32 - 8
    srl t6, a0, t6     # add_hi = a >> (32 - 8)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_8  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_8:

# for i = 9
    slli t5, t4, 9     # bitmask = 1 << 9
    and t5, a1, t5     # check if b's 9-th bit
    beqz t5, mul32.skip1_9  # if bit is 0, skip
    slli t5, a0, 9     # add_lo = a << 9
    li t6, 23          # 32 - 9
    srl t6, a0, t6     # add_hi = a >> (32 - 9)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_9  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_9:

# for i = 10
    slli t5, t4, 10    # bitmask = 1 << 10
    and t5, a1, t5     # check if b's 10-th bit
    beqz t5, mul32.skip1_10  # if bit is 0, skip
    slli t5, a0, 10    # add_lo = a << 10
    li t6, 22          # 32 - 10
    srl t6, a0, t6     # add_hi = a >> (32 - 10)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_10  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_10:

# for i = 11
    slli t5, t4, 11    # bitmask = 1 << 11
    and t5, a1, t5     # check if b's 11-th bit
    beqz t5, mul32.skip1_11  # if bit is 0, skip
    slli t5, a0, 11    # add_lo = a << 11
    li t6, 21          # 32 - 11
    srl t6, a0, t6     # add_hi = a >> (32 - 11)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_11  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_11:

# for i = 12
    slli t5, t4, 12    # bitmask = 1 << 12
    and t5, a1, t5     # check if b's 12-th bit
    beqz t5, mul32.skip1_12  # if bit is 0, skip
    slli t5, a0, 12    # add_lo = a << 12
    li t6, 20          # 32 - 12
    srl t6, a0, t6     # add_hi = a >> (32 - 12)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_12  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_12:

# for i = 13
    slli t5, t4, 13    # bitmask = 1 << 13
    and t5, a1, t5     # check if b's 13-th bit
    beqz t5, mul32.skip1_13  # if bit is 0, skip
    slli t5, a0, 13    # add_lo = a << 13
    li t6, 19          # 32 - 13
    srl t6, a0, t6     # add_hi = a >> (32 - 13)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_13  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_13:

# for i = 14
    slli t5, t4, 14    # bitmask = 1 << 14
    and t5, a1, t5     # check if b's 14-th bit
    beqz t5, mul32.skip1_14  # if bit is 0, skip
    slli t5, a0, 14    # add_lo = a << 14
    li t6, 18          # 32 - 14
    srl t6, a0, t6     # add_hi = a >> (32 - 14)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_14  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_14:

# for i = 15
    slli t5, t4, 15    # bitmask = 1 << 15
    and t5, a1, t5     # check if b's 15-th bit
    beqz t5, mul32.skip1_15  # if bit is 0, skip
    slli t5, a0, 15    # add_lo = a << 15
    li t6, 17          # 32 - 15
    srl t6, a0, t6     # add_hi = a >> (32 - 15)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_15  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_15:

# for i = 16
    slli t5, t4, 16    # bitmask = 1 << 16
    and t5, a1, t5     # check if b's 16-th bit
    beqz t5, mul32.skip1_16  # if bit is 0, skip
    slli t5, a0, 16    # add_lo = a << 16
    li t6, 16          # 32 - 16
    srl t6, a0, t6     # add_hi = a >> (32 - 16)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_16  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_16:

# for i = 17
    slli t5, t4, 17    # bitmask = 1 << 17
    and t5, a1, t5     # check if b's 17-th bit
    beqz t5, mul32.skip1_17  # if bit is 0, skip
    slli t5, a0, 17    # add_lo = a << 17
    li t6, 15          # 32 - 17
    srl t6, a0, t6     # add_hi = a >> (32 - 17)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_17  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_17:

# for i = 18
    slli t5, t4, 18    # bitmask = 1 << 18
    and t5, a1, t5     # check if b's 18-th bit
    beqz t5, mul32.skip1_18  # if bit is 0, skip
    slli t5, a0, 18    # add_lo = a << 18
    li t6, 14          # 32 - 18
    srl t6, a0, t6     # add_hi = a >> (32 - 18)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_18  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_18:

# for i = 19
    slli t5, t4, 19    # bitmask = 1 << 19
    and t5, a1, t5     # check if b's 19-th bit
    beqz t5, mul32.skip1_19  # if bit is 0, skip
    slli t5, a0, 19    # add_lo = a << 19
    li t6, 13          # 32 - 19
    srl t6, a0, t6     # add_hi = a >> (32 - 19)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_19  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_19:

# for i = 20
    slli t5, t4, 20    # bitmask = 1 << 20
    and t5, a1, t5     # check if b's 20-th bit
    beqz t5, mul32.skip1_20  # if bit is 0, skip
    slli t5, a0, 20    # add_lo = a << 20
    li t6, 12          # 32 - 20
    srl t6, a0, t6     # add_hi = a >> (32 - 20)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_20  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_20:

# for i = 21
    slli t5, t4, 21    # bitmask = 1 << 21
    and t5, a1, t5     # check if b's 21-th bit
    beqz t5, mul32.skip1_21  # if bit is 0, skip
    slli t5, a0, 21    # add_lo = a << 21
    li t6, 11          # 32 - 21
    srl t6, a0, t6     # add_hi = a >> (32 - 21)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_21  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_21:

# for i = 22
    slli t5, t4, 22    # bitmask = 1 << 22
    and t5, a1, t5     # check if b's 22-th bit
    beqz t5, mul32.skip1_22  # if bit is 0, skip
    slli t5, a0, 22    # add_lo = a << 22
    li t6, 10          # 32 - 22
    srl t6, a0, t6     # add_hi = a >> (32 - 22)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_22  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_22:

# for i = 23
    slli t5, t4, 23    # bitmask = 1 << 23
    and t5, a1, t5     # check if b's 23-th bit
    beqz t5, mul32.skip1_23  # if bit is 0, skip
    slli t5, a0, 23    # add_lo = a << 23
    li t6, 9           # 32 - 23
    srl t6, a0, t6     # add_hi = a >> (32 - 23)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_23  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_23:

# for i = 24
    slli t5, t4, 24    # bitmask = 1 << 24
    and t5, a1, t5     # check if b's 24-th bit
    beqz t5, mul32.skip1_24  # if bit is 0, skip
    slli t5, a0, 24    # add_lo = a << 24
    li t6, 8           # 32 - 24
    srl t6, a0, t6     # add_hi = a >> (32 - 24)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_24  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_24:

# for i = 25
    slli t5, t4, 25    # bitmask = 1 << 25
    and t5, a1, t5     # check if b's 25-th bit
    beqz t5, mul32.skip1_25  # if bit is 0, skip
    slli t5, a0, 25    # add_lo = a << 25
    li t6, 7           # 32 - 25
    srl t6, a0, t6     # add_hi = a >> (32 - 25)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_25  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_25:

# for i = 26
    slli t5, t4, 26    # bitmask = 1 << 26
    and t5, a1, t5     # check if b's 26-th bit
    beqz t5, mul32.skip1_26  # if bit is 0, skip
    slli t5, a0, 26    # add_lo = a << 26
    li t6, 6           # 32 - 26
    srl t6, a0, t6     # add_hi = a >> (32 - 26)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_26  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_26:

# for i = 27
    slli t5, t4, 27    # bitmask = 1 << 27
    and t5, a1, t5     # check if b's 27-th bit
    beqz t5, mul32.skip1_27  # if bit is 0, skip
    slli t5, a0, 27    # add_lo = a << 27
    li t6, 5           # 32 - 27
    srl t6, a0, t6     # add_hi = a >> (32 - 27)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_27  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_27:

# for i = 28
    slli t5, t4, 28    # bitmask = 1 << 28
    and t5, a1, t5     # check if b's 28-th bit
    beqz t5, mul32.skip1_28  # if bit is 0, skip
    slli t5, a0, 28    # add_lo = a << 28
    li t6, 4           # 32 - 28
    srl t6, a0, t6     # add_hi = a >> (32 - 28)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_28  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_28:

# for i = 29
    slli t5, t4, 29    # bitmask = 1 << 29
    and t5, a1, t5     # check if b's 29-th bit
    beqz t5, mul32.skip1_29  # if bit is 0, skip
    slli t5, a0, 29    # add_lo = a << 29
    li t6, 3           # 32 - 29
    srl t6, a0, t6     # add_hi = a >> (32 - 29)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_29  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_29:

# for i = 30
    slli t5, t4, 30    # bitmask = 1 << 30
    and t5, a1, t5     # check if b's 30-th bit
    beqz t5, mul32.skip1_30  # if bit is 0, skip
    slli t5, a0, 30    # add_lo = a << 30
    li t6, 2           # 32 - 30
    srl t6, a0, t6     # add_hi = a >> (32 - 30)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_30  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_30:

# for i = 31
    slli t5, t4, 31    # bitmask = 1 << 31
    and t5, a1, t5     # check if b's 31-th bit
    beqz t5, mul32.skip1_31  # if bit is 0, skip
    slli t5, a0, 31    # add_lo = a << 31
    li t6, 1           # 32 - 31
    srl t6, a0, t6     # add_hi = a >> (32 - 31)
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1_31  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1_31:

mul32.end:
    mv a0, t2          # return r_lo
    mv a1, t3          # return r_hi
    ret


# ============================================================
# function: fast_rsqrt (Loop Unrolled)
# ============================================================
fast_rsqrt:
    # Input: a0 = x (uint32_t)
    # Output: a0 = fast_rsqrt(x) (uint32_t)
    bnez a0, fast_rsqrt.not_zero
    li a0, 0xFFFFFFFF  # return 0xFFFFFFFF for x == 0
    ret
fast_rsqrt.not_zero:
    li t0, 1
    bne a0, t0, fast_rsqrt.not_one
    li a0, 65536       # return 65536 for x == 1
    ret
fast_rsqrt.not_one:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    
    mv s0, a0          # s0 = x
    jal ra, clz
    li t0, 31
    sub s1, t0, a0     # s1 = exp = 31 - clz(x)
    la s2, rsqrt_table
    slli t0, s1, 1     # t0 = exp * 2
    add t0, t0, s2     # t0 = &rsqrt_table[exp]
    lhu s3, 0(t0)       # s3 = y (initial guess)
    li t0, 1           # t0 = 1
    sll t0, t0, s1     # t0 = 1 << exp
    bge t0, s0, fast_rsqrt.skip_interpolation # if (1<<exp >= x) skip
    li t0, 31
    li t1, 0         # t1 = y_next = 0
    bge s1, t0, fast_rsqrt.skip1_1
    addi t1, s1, 1
    slli t1, t1, 1     # t1 = (exp + 1) * 2
    add t1, t1, s2     # t1 = &rsqrt_table[exp + 1]
    lhu t1, 0(t1)       # t1 = rsqrt_table[exp + 1]
fast_rsqrt.skip1_1:
    sub t2, s3, t1   # t2 = delta = y - y_next
    li t0, 1
    sll t0, t0, s1     # t0 = 1 << exp
    sub t0, s0, t0     # t0 = x - (1 << exp)
    slli t0, t0, 16    # t0 = (x - (1 << exp)) << 16
    srl t0, t0, s1    # t0 = frac = ((x - (1 << exp)) << 16)/(1 << exp)
    mv a0, t2       # a0 = delta
    mv a1, t0       # a1 = frac
    jal ra, mul32      # prod = delta * frac
    srli t0, a0, 16    # t0 = prod_lo >> 16
    slli t1, a1, 16    # t1 = prod_hi << 16
    or t0, t1, t0   # a0 = prod_hi << 16 | (prod_lo >> 16)
    sub s3, s3, t0   # y -= prod >> 16
fast_rsqrt.skip_interpolation:
    mv a0, s3      # a0 = y
    mv a1, s3      # a1 = y
    jal ra, mul32      # y^2, a0 = y^2_lo, a1 = y^2_hi
    or a1, a1, a0   # a1 = y2 = y^2 >> 16
    mv a0, s0      # a0 = x
    jal ra, mul32      # prod = x * y2
    slli a1, a1, 16
    srli a0, a0, 16
    or a1, a1, a0   # a1 = xy2 = x * y2 >> 16
    li t0, 3
    slli t0, t0, 16    # t0 = 3 << 16
    sub a1, t0, a1 
    mv a0, s3      # a0 = y
    jal ra, mul32      # new_y = y * (3 << 16 - xy2)
    srli a0, a0, 17  # new_y_lo >> 17
    slli a1, a1, 15  # new_y_hi << 15
    or s3, a1, a0   # s3 = new_y_hi << 15 | (new_y_lo >> 17)
    mv a0, s3      # a0 = y
    mv a1, s3      # a1 = y
    jal ra, mul32      # y^2, a0 = y^2_lo, a1 = y^2_hi
    or a1, a1, a0   # a1 = y2 = y^2 >> 16
    mv a0, s0      # a0 = x
    jal ra, mul32      # prod = x * y2
    slli a1, a1, 16
    srli a0, a0, 16
    or a1, a1, a0   # a1 = xy2 = x * y2 >> 16
    li t0, 3
    slli t0, t0, 16    # t0 = 3 << 16
    sub a1, t0, a1 
    mv a0, s3      # a0 = y
    jal ra, mul32      # new_y = y * (3 << 16 - xy2)
    srli a0, a0, 17  # new_y_lo >> 17
    slli a1, a1, 15  # new_y_hi << 15
    or s3, a1, a0   # s3 = new_y_hi << 15 | (new_y_lo >> 17)

fast_rsqrt.end_loop:
    mv a0, s3      # return y
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20
    ret

# ============================================================
# Data Section
# ============================================================
.data
inv_sqrt_cache: .word  0xFFFFFFFF, 0xFFFFFFFF, 3037000500, 2479700525
                .word   2147483647, 1920767767, 1753413056, 1623345051
                .word   1518500250, 1431655765, 1358187914, 1294981364
                .word   1264197512, 1220703125, 1181116006, 1145324612

rsqrt_table: .half 65535, 46341, 32768, 23170, 16384
            .half 11585, 8192, 5793, 4096, 2896
            .half 2048, 1448, 1024, 724, 512
            .half 362, 256, 181, 128, 90
            .half 64, 45, 32, 23, 16
            .half 11, 8, 6, 4, 3
            .half 2, 1

test_data: .word 4

str1:      .asciz  "Reverse Square Root of "
str2:      .asciz  " is: "
str3:      .asciz  " in fp32 encoding"
str4: .string "\nCycle count: "
str5: .string "\nInstret count: "
str6: .string "\n"