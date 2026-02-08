#!/usr/bin/env julia

using SpecialFunctions

function Fm_ref(m,T,eps = 1e-10)
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

function Fm_recur_array(mmax,T)
  K = 0.5*sqrt(pi)
  T2 = 2*T
  eT = exp(-T)
  sqrt_T = sqrt(T)
  Fm = zeros(Float64,mmax+1)
  Fm[1] = K*erf(sqrt_T)/sqrt_T
  for m in 0:(mmax-1)
    Fm[m+2] = ((2*m+1)*Fm[m+1]-eT)/T2
  end
  return Fm
end

function Fm_ref2_array(mmax,T)
  return T < 117 ? Fm_ref.(0:mmax,T) : Fm_recur_array(mmax,T)
end

println("Boys Function Julia Implementation")
println("===================================\n")

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
    result = T < 117 ? Fm_ref(m,T) : Fm_recur_array(m,T)[m+1]
    println("  F_{$m}($T) = $(round(result, digits=10))")
end

println("\nArray tests:")
T = 5.0
mmax = 10
Fm_array = Fm_ref2_array(mmax,T)
println("  F_m($T) for m = 0..$mmax:")
println("  ", [round(x, digits=6) for x in Fm_array])

println("\nPerformance test:")
using BenchmarkTools
m = 2
T = 5.0

println("  Small T (asymptotic):")
@benchmark Fm_ref($m, $T)

println("  Large T (recursion):")
@benchmark Fm_recur_array($m, 150.0)
