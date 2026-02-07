**Goal:** Create fast implementations in Python and Rust of the Boys Integral:

$$ F_m (T) = \int_0^1 u^{2m} \exp(-T u^2)du, $$

There is a very fast version in the [libint library](https://github.com/evaleev/libint/blob/master/include/libint2/boys.h).
Because libint uses a lot of C++ code generation, I'm giving a link to the header file.

Libint uses a multi-algorithm approach, using upward recursion for T>=117, and
asymptotic summation for T<117. There are functions in the Julia boys.jl program that implement this.

I've also included some of the pyquante routines in boys.py.

Your goal is to read the libint implementation, and make fast versions of this in Python and Rust.

