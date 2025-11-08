import math
import numpy as np
import matplotlib.pyplot as plt

rsqrt_table = np.array([65535, 46341, 32768, 23170, 16384, 11585, 8192, 5793, 4096, 2896,
                        2048, 1448, 1024, 724, 512, 362, 256, 181, 128, 90,
                        64, 45, 32, 23, 16, 11, 8, 6, 4, 3, 2, 1], dtype=np.uint16)

def compute_initial_error(x):
    if x == 0:
        return np.nan
    clz = 32 - (int(x).bit_length() if x > 0 else 0)
    exp = 31 - clz
    if exp < 0 or exp >= 32:
        raise ValueError(f"Invalid exp {exp} for x={x}")
    y_init = rsqrt_table[exp]
    y_approx = y_init / 65536.0
    y_exact = 1.0 / math.sqrt(x)
    return abs(y_approx - y_exact) / y_exact

x_values = np.arange(1, 0x10000)  # 1 to 65535
errors = np.array([compute_initial_error(x) for x in x_values])

max_err = np.nanmax(errors)
min_err = np.nanmin(errors)
avg_err = np.nanmean(errors)
print(f"Maximum Relative Error: {max_err:.6f}")
print(f"Minimum Relative Error: {min_err:.6f}")
print(f"Average Relative Error: {avg_err:.6f}")

plt.figure(figsize=(10, 6))
plt.plot(x_values, errors, label='Relative Error', color='blue', alpha=0.7)
plt.xscale('log')
plt.xlabel('x Value (log scale)')
plt.ylabel('Relative Error')
plt.title('Distribution of Initial Relative Error in Fast Rsqrt Guess (x=1 to 65535)')
plt.grid(True)
plt.legend()
plt.savefig('rsqrt_initial_error_plot.png')
plt.show()