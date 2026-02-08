import numpy as np
from numba import njit, vectorize
from typing import Union


@njit(fastmath=True)
def boys_ref(m: int, T: float, eps: float = 1e-10) -> float:
    if T < 1e-14:
        return 1.0 / (2.0 * m + 1.0)

    half = 0.5
    denom = m + half
    term = np.exp(-T) / (2.0 * denom)
    old_term = 0.0
    sum_val = term
    eps_div_10 = eps / 10.0

    while term > sum_val * eps_div_10 or old_term < term:
        denom += 1.0
        old_term = term
        term = old_term * T / denom
        sum_val += term

    return sum_val


@njit(fastmath=True)
def boys_recur_array(mmax: int, T: float) -> np.ndarray:
    K = 0.5 * np.sqrt(np.pi)
    T2 = 2.0 * T
    eT = np.exp(-T)
    sqrt_T = np.sqrt(T)

    Fm = np.zeros(mmax + 1, dtype=np.float64)
    Fm[0] = K * np.erf(sqrt_T) / sqrt_T

    for m in range(mmax):
        Fm[m + 1] = ((2.0 * m + 1.0) * Fm[m] - eT) / T2

    return Fm


@njit(fastmath=True)
def boys_ref_array(mmax: int, T: float, eps: float = 1e-10) -> np.ndarray:
    Fm = np.zeros(mmax + 1, dtype=np.float64)
    for m in range(mmax + 1):
        Fm[m] = boys_ref(m, T, eps)
    return Fm


@njit(fastmath=True)
def boys_fast_array(mmax: int, T: float, eps: float = 1e-10) -> np.ndarray:
    if T < 117.0:
        return boys_ref_array(mmax, T, eps)
    else:
        return boys_recur_array(mmax, T)


@njit(fastmath=True)
def boys_fast(m: int, T: float, eps: float = 1e-10) -> float:
    if T < 117.0:
        return boys_ref(m, T, eps)
    else:
        Fm_arr = boys_recur_array(m, T)
        return Fm_arr[m]


@vectorize(["float64(int64, float64)"], target="parallel", fastmath=True)
def boys_vec(m: int, T: float) -> float:
    return boys_fast(m, T)


if __name__ == "__main__":
    import time

    print("Boys Function Fast Implementation")
    print("==================================\n")

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
    print(f"  {Fm_array}")

    print("\nVectorized test:")
    m_vals = np.array([0, 1, 2, 3, 4, 5])
    T_vals = np.array([1.0, 5.0, 10.0, 20.0, 50.0, 100.0])
    results = boys_vec(m_vals, T_vals)
    print(f"  Results: {results}")

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

    T_range = np.random.uniform(0.1, 200.0, n_tests)
    start = time.time()
    results = boys_vec(np.full(n_tests, m), T_range)
    elapsed = time.time() - start
    print(
        f"  Vectorized: {n_tests} evaluations in {elapsed:.4f}s ({n_tests / elapsed:.0f} evals/s)"
    )
