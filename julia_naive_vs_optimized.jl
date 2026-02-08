"""
Compare naive Julia implementation vs optimized Julia implementation
"""

using SpecialFunctions
using BenchmarkTools

# Original naive implementation (from boys.jl)
function Fm_ref_naive(m,T,eps = 1e-10)
    denom = (m + 0.5)
    term = exp(-T) / (2*denom)
    old_term = 0.0
    sum = term
    while term > sum*eps || old_term < term
        denom += 1
        old_term = term
        term = old_term * T / denom
        sum += term
    end
    return sum
end

function Fm_recur_array_naive(mmax,T)
  K = 0.5*sqrt(pi)
  T2 = 2*T
  eT = exp(-T)  # Fixed bug: was exp(-5)
  sqrt_T = sqrt(T)
  Fm = zeros(Float64,mmax+1)  # Removed OffsetArray for fair comparison
  Fm[1] = K*erf(sqrt_T)/sqrt_T
  for m in 0:(mmax-1)
    Fm[m+2] = ((2*m+1)*Fm[m+1]-eT)/T2
  end
  return Fm
end

function Fm_ref2_array_naive(mmax,T)
  return T < 117 ? Fm_ref_naive.(0:mmax,T) : Fm_recur_array_naive(mmax,T)
end

function Fm_naive(m,T,eps = 1e-10)
    return T < 117 ? Fm_ref_naive(m,T,eps) : Fm_recur_array_naive(m,T)[m+1]
end

# Optimized implementation (from boys_fast.jl)
function Fm_asymptotic_opt(m::Int, T::Float64, eps::Float64=1e-10)
    if T < 1e-14
        return 1.0 / (2.0 * m + 1.0)
    end
    
    half = 0.5
    denom = m + half
    term = exp(-T) / (2.0 * denom)
    old_term = 0.0
    sum_val = term
    eps_div_10 = eps / 10.0
    
    while term > sum_val * eps_div_10 || old_term < term
        denom += 1.0
        old_term = term
        term = old_term * T / denom
        sum_val += term
    end
    
    return sum_val
end

function Fm_recur_array_opt(mmax::Int, T::Float64)
    K = 0.5 * sqrt(pi)
    T2 = 2.0 * T
    eT = exp(-T)
    sqrt_T = sqrt(T)
    
    Fm = zeros(Float64, mmax + 1)
    Fm[1] = K * erf(sqrt_T) / sqrt_T
    
    for m in 0:(mmax-1)
        Fm[m + 2] = ((2.0 * m + 1.0) * Fm[m + 1] - eT) / T2
    end
    
    return Fm
end

function Fm_fast_opt(m::Int, T::Float64, eps::Float64=1e-10)
    if T < 117.0
        return Fm_asymptotic_opt(m, T, eps)
    else
        Fm_arr = Fm_recur_array_opt(m, T)
        return Fm_arr[m + 1]
    end
end

# Type-stable optimized version
function Fm_fast_typed(m::Int, T::Float64, eps::Float64=1e-10)::Float64
    if T < 117.0
        if T < 1e-14
            return 1.0 / (2.0 * m + 1.0)
        end
        
        half = 0.5
        denom = m + half
        term = exp(-T) / (2.0 * denom)
        old_term = 0.0
        sum_val = term
        eps_div_10 = eps / 10.0
        
        while term > sum_val * eps_div_10 || old_term < term
            denom += 1.0
            old_term = term
            term = old_term * T / denom
            sum_val += term
        end
        
        return sum_val
    else
        K = 0.5 * sqrt(pi)
        T2 = 2.0 * T
        eT = exp(-T)
        sqrt_T = sqrt(T)
        
        F0 = K * erf(sqrt_T) / sqrt_T
        
        if m == 0
            return F0
        end
        
        Fm_prev = F0
        for m_idx in 0:(m-1)
            Fm_curr = ((2.0 * m_idx + 1.0) * Fm_prev - eT) / T2
            Fm_prev = Fm_curr
        end
        
        return Fm_prev
    end
end

println("Julia: Naive vs Optimized Comparison")
println("="^60)
println()

# Test accuracy
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

println("Accuracy Check:")
println("-"^60)
for (m, T) in test_cases
    result_naive = Fm_naive(m, T)
    result_opt = Fm_fast_typed(m, T)
    diff = abs(result_naive - result_opt)
    println("  F_{$m}($(round(T, digits=1))) naive=$(round(result_naive, digits=10)) opt=$(round(result_opt, digits=10)) diff=$(round(diff, sigdigits=2))")
end

println()
println("Performance Benchmarks:")
println("-"^60)
# Single value benchmarks
println("\nSmall T (asymptotic): T=5.0, m=2")
@btime Fm_naive(2, 5.0)
@btime Fm_fast_typed(2, 5.0)

println("\nLarge T (recursion): T=150.0, m=2")
@btime Fm_naive(2, 150.0)
@btime Fm_fast_typed(2, 150.0)

# Array benchmarks
println("\nArray - Small T: mmax=10, T=5.0")
@btime Fm_ref2_array_naive(10, 5.0)
@btime Fm_fast_opt(10, 5.0)

println("\nArray - Large T: mmax=10, T=150.0")
@btime Fm_ref2_array_naive(10, 150.0)
@btime Fm_recur_array_opt(10, 150.0)

println()
println("="^60)
println("Summary:")
println("-"^60)

# Get actual benchmark times
println("\nExtracting detailed timing information...")

# Run more detailed benchmarks
n_tests = 1_000_000

println("\nDetailed Timing - Small T (T=5.0, m=2):")
naive_time = @elapsed for _ in 1:n_tests
    Fm_naive(2, 5.0)
end
opt_time = @elapsed for _ in 1:n_tests
    Fm_fast_typed(2, 5.0)
end

println("  Naive:    $(naive_time/n_tests*1e9) ns ($(n_tests/naive_time) evals/s)")
println("  Optimized: $(opt_time/n_tests*1e9) ns ($(n_tests/opt_time) evals/s)")
println("  Speedup:  $(naive_time/opt_time)x")

println("\nDetailed Timing - Large T (T=150.0, m=2):")
naive_time_large = @elapsed for _ in 1:n_tests
    Fm_naive(2, 150.0)
end
opt_time_large = @elapsed for _ in 1:n_tests
    Fm_fast_typed(2, 150.0)
end

println("  Naive:    $(naive_time_large/n_tests*1e9) ns ($(n_tests/naive_time_large) evals/s)")
println("  Optimized: $(opt_time_large/n_tests*1e9) ns ($(n_tests/opt_time_large) evals/s)")
println("  Speedup:  $(naive_time_large/opt_time_large)x")

println("\nDetailed Timing - Array - Small T (mmax=10, T=5.0):")
naive_array_time = @elapsed for _ in 1:100_000
    Fm_ref2_array_naive(10, 5.0)
end
opt_array_time = @elapsed for _ in 1:100_000
    Fm_fast_opt(10, 5.0)
end

println("  Naive:    $(naive_array_time/100000*1e9) ns ($(100000/naive_array_time) arrays/s)")
println("  Optimized: $(opt_array_time/100000*1e9) ns ($(100000/opt_array_time) arrays/s)")
println("  Speedup:  $(naive_array_time/opt_array_time)x")

println("\nDetailed Timing - Array - Large T (mmax=10, T=150.0):")
naive_array_time_large = @elapsed for _ in 1:100_000
    Fm_ref2_array_naive(10, 150.0)
end
opt_array_time_large = @elapsed for _ in 1:100_000
    Fm_recur_array_opt(10, 150.0)
end

println("  Naive:    $(naive_array_time_large/100000*1e9) ns ($(100000/naive_array_time_large) arrays/s)")
println("  Optimized: $(opt_array_time_large/100000*1e9) ns ($(100000/opt_array_time_large) arrays/s)")
println("  Speedup:  $(naive_array_time_large/opt_array_time_large)x")
