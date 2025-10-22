# include <stdint.h>

#define REC_INV_SQRT_CACHE (16)

static const uint32_t inv_sqrt_cache[REC_INV_SQRT_CACHE] = {
    ~0U,        ~0U,        3037000500, 2479700525,
    2147483647, 1920767767, 1753413056, 1623345051,
    1518500250, 1431655765, 1358187914, 1294981364,
    1239850263, 1191209601, 1147878294, 1108955788
};

static int clz(uint32_t x){
    if(!x)return 32;
    int n = 0;
    if(!(x & 0xFFFF0000)) {n += 16; x <<= 16;}
    if(!(x & 0xFF000000)) {n += 8; x <<= 8;}
    if(!(x & 0xF0000000)) {n += 4; x <<= 4;}
    if(!(x & 0xC0000000)) {n += 2; x <<= 2;}
    if(!(x & 0x80000000)) {n += 1;}
    return n;
}

static const uint16_t rsqrt_table[32] = {
65536, 46341, 32768, 23170, 16384, /* 2^0 to 2^4 */
11585, 8192, 5793, 4096, 2896,     /* 2^5 to 2^9 */
2048, 1448, 1024, 724, 512,        /* 2^10 to 2^14 */
362, 256, 181, 128, 90,            /* 2^15 to 2^19 */
64, 45, 32, 23, 16,                /* 2^20 to 2^24 */
11, 8, 6, 4, 3,                    /* 2^25 to 2^29 */
2, 1,                              /* 2^30 to 2^31 */
};

/*
 * Newton iteration: new_y = y * (3/2 - x * y^2 / 2)
 * Here, y is a Q0.32 fixed-point number (< 1.0)
 */
static void newton_step(uint32_t *rec_inv_sqrt, uint32_t x){
    uint32_t invsqrt, invsqrt2;
    uint64_t val;

    invsqrt = *rec_inv_sqrt;  /* Dereference pointer */
    invsqrt2 = ((uint64_t)invsqrt * invsqrt) >> 32;
    val = (3LL << 32) - ((uint64_t)x * invsqrt2);

    val >>= 2; /* Avoid overflow in following multiply */
    val = (val * invsqrt) >> 31;  /* Right shift by 31 = (32 - 2 + 1) */

    *rec_inv_sqrt = (uint32_t)val;
}

static uint64_t mul32(uint32_t a, uint32_t b){
    uint64_t r=0;

    for(int i=0; i<32; i++){
        if(b & (1U<<i))
            r += (uint64_t)a<<i;
    }

    return r;
}

uint32_t fast_rsqrt(uint32_t x){
    if(x==0) return 0xffffffff;
    if(x==1) return 65536;

    int exp = 31 - clz(x);
    uint32_t y = rsqrt_table[exp];

    if(x > (1U << exp)){
        uint32_t y_next = (exp < 31)? rsqrt_table[exp+1]: 0;
        uint32_t delta = y - y_next;
        uint32_t frac = ((x - (1U << exp)) << 16) / (1u << exp);
        y -= (uint32_t) ((delta * frac) >> 16);
    }

    for (int iter = 0; iter < 2; iter++){
        uint32_t y2 = (uint32_t)(mul32(y, y) >> 16);
        uint32_t xy2 = (uint32_t)(mul32(x, y2) >> 16);
        y = (uint32_t)(mul32(y, (3u << 16) - xy2) >> 17);
    }

    return y;
}