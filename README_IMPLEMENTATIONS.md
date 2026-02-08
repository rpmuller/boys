# Boys Integral Fast Implementations

Fast implementations of the Boys Integral in Python and Rust, based on the libint library's multi-algorithm approach.

$$ F_m (T) = \int_0^1 u^{2m} \exp(-T u^2)du $$

## Algorithm

The implementation uses a multi-algorithm approach:

1. **Asymptotic summation (MacLaurin series)** for T < 117:
   - Converges quickly for small to moderate T values
   - Uses iterative approach with controlled precision

2. **Upward recursion** for T >= 117:
   - Computes F_0(T) directly using the error function
   - Recursively computes F_{m+1}(T) from F_m(T)
   - Very efficient for large T values

## Python Implementation

### Features

- Numba JIT compilation for high performance
- Vectorized operations for batch processing
- Single value and array evaluation methods
- Configurable precision

### Usage

```python
from boys_fast import boys_fast, boys_fast_array

# Single value evaluation
result = boys_fast(m=2, T=5.0)

# Array evaluation (compute F_0 to F_mmax)
results = boys_fast_array(mmax=10, T=5.0)

# Vectorized evaluation
import numpy as np
m_vals = np.array([0, 1, 2, 3, 4, 5])
T_vals = np.array([1.0, 5.0, 10.0, 20.0, 50.0, 100.0])
results = boys_vec(m_vals, T_vals)
```

### Performance

The Python implementation with Numba JIT achieves:
- ~1-10 million evaluations per second for single values
- ~5-50 million evaluations per second for vectorized operations (depending on T)

### Installation

```bash
pip install numpy numba
```

### Running Tests

```bash
python boys_fast.py
```

## Rust Implementation

### Features

- Zero-allocation for single value evaluation
- Minimal allocation for array evaluation
- Compile-time optimizations
- Comprehensive test suite

### Usage

```rust
use boys::boys_impl::BoysFunction;

let boys = BoysFunction::new(None);

// Single value evaluation
let result = boys.eval(2, 5.0);

// Array evaluation
let results = boys.eval_array(10, 5.0);
```

### Performance

The Rust implementation achieves:
- ~5-50 million evaluations per second for single values
- ~10-100 million evaluations per second for arrays (depending on mmax and T)

### Building

```bash
cargo build --release
```

### Running Tests

```bash
cargo test
```

### Running Benchmarks

```bash
cargo bench
```

### Running the Example

```bash
cargo run --release
```

## Accuracy

Both implementations maintain high accuracy:
- Absolute error < 1e-10 for all tested values
- Relative error < 1e-12 for typical use cases
- Consistent with libint reference implementation

## Comparison

| Implementation | Language | Single Value (eval/s) | Array (eval/s) |
|---------------|----------|---------------------|----------------|
| boys_fast.py  | Python+Numba | ~1M-10M | ~5M-50M |
| Rust          | Rust | ~5M-50M | ~10M-100M |
| boys.jl       | Julia | ~0.5M-1M | ~0.5M-1M |

## API Reference

### Python API

#### `boys_fast(m: int, T: float, eps: float = 1e-10) -> float`
Compute a single value of the Boys function.

#### `boys_fast_array(mmax: int, T: float, eps: float = 1e-10) -> np.ndarray`
Compute F_m(T) for m = 0 to mmax.

#### `boys_vec(m: np.ndarray, T: np.ndarray) -> np.ndarray`
Vectorized evaluation for batch processing.

### Rust API

#### `BoysFunction::new(epsilon: Option<f64>) -> BoysFunction`
Create a new Boys function evaluator.

#### `BoysFunction::eval(&self, m: i32, t: f64) -> f64`
Compute a single value of the Boys function.

#### `BoysFunction::eval_array(&self, mmax: i32, t: f64) -> Vec<f64>`
Compute F_m(T) for m = 0 to mmax.

## References

- [libint library](https://github.com/evaleev/libint/blob/master/include/libint2/boys.h)
- [A fast algorithm for computing the Boys function](https://pubs.aip.org/aip/jcp/article/155/17/174117/565590/A-fast-algorithm-for-computing-the-Boys-function)
- [Boys function for Gaussian integrals in ab initio calculations](https://chemistry.stackexchange.com/questions/41214/boys-function-for-gaussian-integrals-in-ab-initio-calculations)

## License

This project is provided as-is for educational and research purposes.
