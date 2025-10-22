.text
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
    lui t1, 0xFFFF      # mask = 0xFFFF0000
    and t2, a0, t1
    bnez t2, clz.skip1 
    addi t0, t0, 16     # n += 16
    slli a0, a0, 16
clz.skip1:
    lui t1, 0xFF00       # mask = 0xFF000000
    and t2, a0, t1
    bnez t2, clz.skip2
    addi t0, t0, 8      # n += 8
    slli a0, a0, 8
clz.skip2:
    lui t1, 0xF000       # mask = 0xF0000000
    and t2, a0, t1
    bnez t2, clz.skip3
    addi t0, t0, 4      # n += 4
    slli a0, a0, 4
clz.skip3:
    lui t1, 0xC000       # mask = 0xC0000000
    and t2, a0, t1
    bnez t2, clz.skip4
    addi t0, t0, 2      # n += 2
    slli a0, a0, 2
clz.skip4:
    lui t1, 0x8000       # mask = 0x80000000
    and t2, a0, t1
    bnez t2, clz.end
    addi t0, t0, 1      # n += 1
clz.end:
    mv a0, t0           # return n
    ret

# ============================================================
# function: mul32_split
# ============================================================
mul32:
    # Input: a0 = a (uint32_t)
    #        a1 = b (uint32_t)
    # Output: a0 = r_lo (low 32), a1 = r_hi (high 32)
    li t0, 0            # i = 0
    li t1, 32           # constant 32
    li t2, 0            # r_lo = 0
    li t3, 0            # r_hi = 0
    li t4, 1            # bitmask = 1
mul32.loop:
    bge t0, t1, mul32.end   # if i >= 32, end loop
    sll t5, t4, t0     # bitmask = 1 << i
    and t5, a1, t5     # check if b's i-th bit
    beqz t5, mul32.skip1  # if bit is 0, skip
    sll t5, a0, t0     # add_lo = a << i
    li t6,0
    beqz t0, mul32.skip2  # if i == 0, skip
    li t6, 32
    sub t6, t6, t0     # 32 - i
    srl t6, a0, t6     # add_hi = a >> (32 - i)
mul32.skip2:
    add t2, t2, t5     # r_lo += add_lo
    add t3, t3, t6     # r_hi += add_hi
    bgeu t2, t5, mul32.skip1  # if no overflow, skip carry
    addi t3, t3, 1     # if overflow, add carry to high part
mul32.skip1:
    addi t0, t0, 1     # i++
    j mul32.loop
mul32.end:
    mv a0, t2          # return r_lo
    mv a1, t3          # return r_hi
    ret

# ============================================================
# function: fast_rsqrt
# ============================================================
fast_rsqrt:
    # Input: a0 = x (uint32_t)
    # Output: a0 = fast_rsqrt(x) (uint32_t)
    bnez a0, fast_rsqrt.not_zero
    li a0, 0xFFFFFFFF  # return 0xFFFFFFFF for x ==
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
    lhu s3, 0(t0)       # s3 = y
    li t0, 1           # t0 = 1
    sll t0, t0, s1     # t0 = 1 << exp
    bge t0, s0, fast_rsqrt.skip1
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
fast_rsqrt.skip1:
    li s1, 0     # s1 = i = 0
    li s2, 2     # s2 = 2
fast_rsqrt.loop:
    bge s1, s2, fast_rsqrt.end_loop
    mv a0, s3      # a0 = y
    mv a1, s3      # a1 = y
    jal ra, mul32      # y^2, a0 = y^2_lo, a1 = y^2_hi
    slli a1, a1, 16 
    srli a0, a0, 16
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
    addi s1, s1, 1     # i++
    j fast_rsqrt.loop
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

rsqrt_table: .half 65536, 46341, 32768, 23170, 16384
            .half 11585, 8192, 5793, 4096, 2896
            .half 2048, 1448, 1024, 724, 512
            .half 362, 256, 181, 128, 90
            .half 64, 45, 32, 23, 16
            .half 11, 8, 6, 4, 3
            .half 2, 1