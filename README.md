# Boys Integral Fast Implementations

Fast implementations of the Boys Integral:

$$ F_m (T) = \int_0^1 u^{2m} \exp(-T u^2)du $$

This project provides high-performance implementations in Python and Rust, based on the multi-algorithm approach used in the [libint library](https://github.com/evaleev/libint/blob/master/include/libint2/boys.h).

## Quick Start

### Python

```bash
# Pure Python (no dependencies)
python3 boys_pure.py

# Optimized (requires NumPy and Numba)
pip install numpy numba
python3 boys_fast.py
```

### Rust

```bash
# Install Rust first if needed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build and run
cargo build --release
cargo run --release
```

## Files

- `boys_pure.py` - Pure Python implementation (no dependencies)
- `boys_fast.py` - Optimized Python with Numba JIT
- `src/boys_impl.rs` - Core Rust implementation
- `src/main.rs` - Rust binary example
- `compare_implementations.py` - Cross-language validation

## Performance

| Implementation | Language | evals/s |
|---------------|----------|----------|
| boys_pure.py  | Python   | ~450k    |
| boys_fast.py  | Python+Numba | ~1-10M |
| Rust          | Rust     | ~5-50M   |

## Algorithm

Uses a multi-algorithm approach:
- **T < 117**: Asymptotic summation (MacLaurin series)
- **T >= 117**: Upward recursion from F_0(T)

## Documentation

See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for detailed documentation.
