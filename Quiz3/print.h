# ifndef PRINT_H
# define PRINT_H
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#define printstr(ptr, length)                   \
    do {                                        \
        asm volatile(                           \
            "add a7, x0, 0x40;"                 \
            "add a0, x0, 0x1;" /* stdout */     \
            "add a1, x0, %0;"                   \
            "mv a2, %1;" /* length character */ \
            "ecall;"                            \
            :                                   \
            : "r"(ptr), "r"(length)             \
            : "a0", "a1", "a2", "a7");          \
    } while (0)

#define TEST_OUTPUT(msg, length) printstr(msg, length)

#define TEST_LOGGER(msg)                     \
    {                                        \
        char _msg[] = msg;                   \
        TEST_OUTPUT(_msg, sizeof(_msg) - 1); \
    }

extern uint64_t get_cycles(void);
extern uint64_t get_instret(void);

void *memcpy(void *dest, const void *src, size_t n);
unsigned long udiv(unsigned long dividend, unsigned long divisor);
unsigned long umod(unsigned long dividend, unsigned long divisor);
uint32_t umul(uint32_t a, uint32_t b);
uint32_t __mulsi3(uint32_t a, uint32_t b);
void print_hex(unsigned long val);
void print_hex_byte(uint8_t val);
void print_dec(unsigned long val);

#endif