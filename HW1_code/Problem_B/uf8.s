.data
str1: .string ": produces value "
str2: .string " but encodes back to "
str3: .string ": value "
str4: .string " <= previous_value "
str5: .string "All tests passed.\n"
str6: .string "\n"
str7: .string "\nCycle count: "
str8: .string "\nInstret count: "


.text
.globl main
# ======================================
# Function: main
# ======================================
main:
    # Input: void
    # Output: a0 = exit code
    addi sp, sp, -12  # Allocate stack space
    sw ra, 0(sp)     # Save return address
    sw s0, 4(sp)    # Save s0
    sw s1, 8(sp)    # Save s1
    sw s2, 12(sp)   # Save s2
    jal get_cycles  # Get starting cycle count
    mv s0, a0       # s0 = old_cycles (lower 32 bits)
    jal get_instret # Get starting instruction count
    mv s1, a0       # s1 = old_insts (lower 32 bits)
    jal test     # a0 = test()
    mv s2, a0       # s2 = test result
    jal get_cycles  # Get ending cycle count
    sub s0, a0, s0   # s0 = new_cycles - old_cycles
    jal get_instret # Get ending instruction count
    sub s1, a0, s1   # s1 = new_insts - old_insts
    beq s2, zero, main.end  # if (a0 == 0) goto main.end
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str5  # Load address of str5
    li a2, 18  # length = 18
    ecall
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str7  # Load address of str7
    li a2, 14  # length = 14
    ecall
    mv a0, s0  # a0 = cycle count
    jal print_dec  # print cycle count
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str8  # Load address of str8
    li a2, 16  # length = 16
    ecall
    mv a0, s1  # a0 = instruction count
    jal print_dec  # print instruction count
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str6  # Load address of str6
    li a2, 1  # length = 1
    ecall
main.end:
    lw s2, 12(sp)   # Restore s2
    lw s1, 8(sp)    # Restore s1
    lw s0, 4(sp)    # Restore s0
    lw ra, 0(sp)     # Restore return address
    addi sp, sp, 16  # Deallocate stack space
    ret

# ======================================
# Function: clz
# ======================================
clz:
    # Input: a0 = 32-bit unsigned integer.
    # Output: a0 = number of leading zeros in x's binary representation
    li t0, 32    # n = t0 = 32
    li t1, 16    # c = t1 = 16
clz.loop:
    srl t2, a0, t1    # y = t2 = x >> c
    beq t2, zero, clz.skip    # if (y == 0) goto clz.skip
    sub t0, t0, t1    # n -= c
    mv a0, t2   # x = y
clz.skip:
    srli t1, t1, 1
    bne t1, zero, clz.loop # while (c != 0) goto clz.loop
    sub a0, t0, a0    # return n - x
    ret    # End of clz function
    
# ======================================
# Function: uf8_decode
# ======================================
uf8_decode:
    # Input: a0 = 8-bit unsigned integer
    # Output: a0 = 32-bit unsigned integer
    andi t0, a0, 0x0f  # mantissa = t0 = fl & 0x0f
    srli t1, a0, 4     # exponent = t1 = fl >> 4
    li t2, 0x7fff   # offset = t2 = 0x7fff
    li t3, 15      # t3 dummy = 15
    sub t3, t3, t1  # t3 = 15 - exponent
    srl t2, t2, t3  # offset >>= (15 - exponent)
    slli t2, t2, 4  # offset <<= 4
    sll t0, t0, t1  # mantissa <<= exponent
    add a0, t0, t2  # return mantissa + offset
    ret # End of uf8_decode function

# ======================================
# Function: uf8_encode
# ======================================
uf8_encode:
    # Input: a = 32-bit unsigned integer
    # Output: a0 = 8-bit unsigned integer
    li t0, 16    # t0 dummy = 16
    blt a0, t0, uf8_encode.end    # if (value < 16) return value
    addi sp, sp, -8  # Allocate stack space
    sw ra, 4(sp)     # Save return address
    sw a0, 0(sp)     # Save input value
    jal clz      # Call clz function
    mv t1, a0        # lz = t1 = clz(value)
    lw a0, 0(sp)     # Restore input value
    lw ra, 4(sp)     # Restore return address
    addi sp, sp, 8   # Deallocate stack space
    li t2, 31   # msb = t2 = 31
    sub t2, t2, t1  # msb = 31 - lz
    li t3, 0    # exponent = t3 = 0
    li t4, 0    # overflow = t4 = 24
    li t0, 5   # t0 dummy = 5
    blt t2, t0, uf8_encode.loop3    # if (msb < 5) goto loop
    addi t3, t2, -4  # exponent = msb - 4
    li t0, 15  # t0 dummy = 15
    bge t0, t3, uf8_encode.skip1    # if (exponent <= 15) goto skip1
    li t3, 15  # exponent = 15
uf8_encode.skip1:
    li t0, 0  # e = t0 = 0
uf8_encode.loop1:
    bge t0, t3, uf8_encode.loop2
    slli t4, t4,1  # overflow <<= 1
    addi t4, t4, 16 # overflow += 16
    addi t0, t0, 1 # e += 1
    j uf8_encode.loop1
uf8_encode.loop2:
    bge zero, t3, uf8_encode.loop2_end # if (0 >= exponent) goto loop2_end
    bge a0, t4, uf8_encode.loop2_end  # if (value >= overflow) goto loop2_end
    addi t4, t4, -16 # overflow -= 16
    srli t4, t4, 1  # overflow >>= 1
    addi t3, t3, -1  # exponent -= 1
    j uf8_encode.loop2
uf8_encode.loop2_end:
    li t0, 15 # t0 dummy = 15
uf8_encode.loop3:
    bge t3, t0, uf8_encode.skip2  # if (exponent >= 15) goto skip1
    slli t2, t4, 1  # next_overflow = overflow << 1
    addi t2, t2, 16 # next_overflow += 16
    blt a0, t2, uf8_encode.skip2  # if (value < next_overflow) goto skip1
    mv t4, t2 # overflow = next_overflow
    addi t3, t3, 1  # exponent += 1
    j uf8_encode.loop3
uf8_encode.skip2:
    sub t2, a0, t4  # mantissa = value - overflow
    srl t2, t2, t3 # mantissa >>= exponent
    slli a0, t3,4  # a0 = exponent << 4
    or a0, a0, t2  # a0 |= mantissa
uf8_encode.end:
    ret # End of uf8_encode function

# ======================================
# Function: Test
# ======================================
test:
    # Input: void
    # Output: a0 = boolean (1 = pass, 0 = fail)
    addi sp, sp, -20  # Allocate stack space
    sw ra, 0(sp)  # Save return address
    sw s0, 4(sp)  # Save previous_value
    sw s1, 8(sp)  # Save passed
    sw s2, 12(sp)  # Save i
    sw s3, 16(sp)  # Save max
    li s0, -1   # previous_value = -1
    li s1, 1    # s1 = passed = 1
    li s2, 0    # s2 = i = 0
    li s3, 256  # s3 = max = 256
test.loop:
    bge s2, s3, test.end   # if (i >= max) goto end
    mv a0, s2  # a0 = fl
    jal uf8_decode  # a0 = uf8_decode(fl)
    mv t5, a0  # value = t5 = uf8_decode(fl)
    jal uf8_encode  # a0 = uf8_encode(value)
    mv t6, a0  # fl2 = t6 = uf8_encode(value)
    mv t4, s2  # fl = t4 = i
    beq t4, t6, test.skip1  # if (fl == fl2) goto skip1
    mv a0, t4  # a0 = fl
    jal print_dec  # print fl
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str1  # Load address of str1
    li a2, 17  # length = 17
    ecall
    mv a0, t5  # a0 = value
    jal print_dec  # print value
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str2  # Load address of str2
    li a2, 21  # length = 21
    ecall
    mv a0, t6  # a0 = fl2
    jal print_dec  # print fl2
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str6  # Load address of str6
    li a2, 1  # length = 1
    ecall
    li s1, 0  # passed = 0
test.skip1:
    blt s0, t5, test.skip2  # if (previous_value < value) goto skip2
    mv a0, t4  # a0 = fl
    jal print_dec  # print fl
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str3  # Load address of str3
    li a2, 8  # length = 8
    ecall
    mv a0, t5  # a0 = value
    jal print_dec  # print value
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str4  # Load address of str4
    li a2, 19  # length = 19
    ecall
    mv a0, s0  # a0 = previous_value
    jal print_dec  # print previous_value
    li a7, 0x40  # syscall: write
    li a0, 1  # stdout
    la a1, str6  # Load address of str6
    li a2, 1  # length = 1
    ecall
    li s1, 0  # passed = 0
    mv a0, s1  # return passed
test.skip2:
    mv s0, t5  # previous_value = value
    addi s2, s2, 1  # i++
    j test.loop
test.end:
    lw s3, 16(sp)  # Restore max
    lw s2, 12(sp)  # Restore i
    lw s1, 8(sp)   # Restore passed
    lw s0, 4(sp)   # Restore previous_value
    lw ra, 0(sp)   # Restore return address
    addi sp, sp, 20  # Deallocate stack space
    ret  # End of test function
