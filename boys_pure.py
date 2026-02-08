import math
import time
from typing import List


def boys_ref(m: int, T: float, eps: float = 1e-10) -> float:
    """
    Compute Boys function using asymptotic summation (MacLaurin series).
    This is efficient for T < 117.
    """
    if T < 1e-14:
        return 1.0 / (2.0 * m + 1.0)

    half = 0.5
    denom = m + half
    term = math.exp(-T) / (2.0 * denom)
    old_term = 0.0
    sum_val = term
    eps_div_10 = eps / 10.0

    while term > sum_val * eps_div_10 or old_term < term:
        denom += 1.0
        old_term = term
        term = old_term * T / denom
        sum_val += term

    return sum_val


def boys_recur_array(mmax: int, T: float) -> List[float]:
    """
    Compute Boys function using upward recursion.
    This is efficient for T >= 117.
    """
    K = 0.5 * math.sqrt(math.pi)
    T2 = 2.0 * T
    eT = math.exp(-T)
    sqrt_T = math.sqrt(T)

    Fm = [0.0] * (mmax + 1)
    Fm[0] = K * math.erf(sqrt_T) / sqrt_T

    for m in range(mmax):
        Fm[m + 1] = ((2.0 * m + 1.0) * Fm[m] - eT) / T2

    return Fm


def boys_fast(m: int, T: float, eps: float = 1e-10) -> float:
    """
    Compute Boys function using optimal algorithm based on T value.
    Uses asymptotic summation for T < 117, upward recursion for T >= 117.
    """
    if T < 117.0:
        return boys_ref(m, T, eps)
    else:
        Fm_arr = boys_recur_array(m, T)
        return Fm_arr[m]


def boys_fast_array(mmax: int, T: float, eps: float = 1e-10) -> List[float]:
    """
    Compute Boys function values F_0 to F_mmax using optimal algorithm.
    """
    if T < 117.0:
        return [boys_ref(m, T, eps) for m in range(mmax + 1)]
    else:
        return boys_recur_array(mmax, T)


def main():
    print("Boys Function Fast Implementation (Pure Python)")
    print("=================================================\n")

    test_cases = [
        (0, 0.1),
        (1, 1.0),
        (2, 5.0),
        (3, 10.0),
        (0, 50.0),
        (1, 100.0),
        (2, 150.0),
        (5, 200.0),
    ]

    print("Single value tests:")
    for m, T in test_cases:
        result = boys_fast(m, T)
        print(f"  F_{m}({T}) = {result:.10f}")

    print("\nArray tests:")
    T = 5.0
    mmax = 10
    Fm_array = boys_fast_array(mmax, T)
    print(f"  F_m({T}) for m = 0..{mmax}:")
    print(f"  {[f'{x:.6f}' for x in Fm_array]}")

    print("\nPerformance test:")
    n_tests = 100000
    m = 2
    T = 5.0

    start = time.time()
    for _ in range(n_tests):
        boys_fast(m, T)
    elapsed = time.time() - start
    print(
        f"  Single value: {n_tests} evaluations in {elapsed:.4f}s ({n_tests / elapsed:.0f} evals/s)"
    )

    print("\nAccuracy comparison with small T (asymptotic):")
    for m, T in [(0, 0.1), (1, 1.0), (2, 5.0), (3, 10.0)]:
        ref = boys_ref(m, T)
        fast = boys_fast(m, T)
        error = abs(ref - fast)
        print(f"  F_{m}({T}): ref={ref:.10f}, fast={fast:.10f}, error={error:.2e}")

    print("\nAccuracy comparison with large T (recursion):")
    for m, T in [(0, 120.0), (1, 150.0), (2, 200.0), (5, 250.0)]:
        fast = boys_fast(m, T)
        print(f"  F_{m}({T}): {fast:.10f}")


if __name__ == "__main__":
    main()
