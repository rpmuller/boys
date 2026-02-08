"""
Fast Julia implementation of Boys Function
Based on libint multi-algorithm approach
"""

using SpecialFunctions
using BenchmarkTools

function Fm_asymptotic(m::Int, T::Float64, eps::Float64=1e-10)
    """
    Compute F_m(T) using asymptotic summation (MacLaurin series)
    Efficient for T < 117
    """
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

function Fm_recur_array(mmax::Int, T::Float64)
    """
    Compute F_0 to F_mmax(T) using upward recursion
    Efficient for T >= 117
    """
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

function Fm_fast(m::Int, T::Float64, eps::Float64=1e-10)
    """
    Compute F_m(T) using optimal algorithm based on T value
    - T < 117: Asymptotic summation
    - T >= 117: Upward recursion
    """
    if T < 117.0
        return Fm_asymptotic(m, T, eps)
    else
        Fm_arr = Fm_recur_array(m, T)
        return Fm_arr[m + 1]
    end
end

function Fm_fast_array(mmax::Int, T::Float64, eps::Float64=1e-10)
    """
    Compute F_0 to F_mmax(T) using optimal algorithm
    """
    if T < 117.0
        return [Fm_asymptotic(m, T, eps) for m in 0:mmax]
    else
        return Fm_recur_array(mmax, T)
    end
end

# Type-stable version for better performance
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

println("Boys Function Fast Julia Implementation")
println("====================================\n")

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

println("Single value tests:")
for (m, T) in test_cases
    result = Fm_fast(m, T)
    println("  F_{$m}($T) = $(round(result, digits=10))")
end

println("\nArray tests:")
T = 5.0
mmax = 10
Fm_array = Fm_fast_array(mmax, T)
println("  F_m($T) for m = 0..$mmax:")
println("  ", [round(x, digits=6) for x in Fm_array])

println("\nPerformance test:")
using BenchmarkTools
m = 2
T = 5.0

println("  Small T (asymptotic):")
@btime Fm_fast_typed($m, $T)

println("  Large T (recursion):")
@btime Fm_fast_typed($m, 150.0)

println("\nArray performance:")
println("  Small T (asymptotic):")
@btime Fm_fast_array(10, $T)

println("  Large T (recursion):")
@btime Fm_recur_array(10, 150.0)
