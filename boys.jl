"""\
# Libint suite of methods

What follows is as close to a transcription of [what libint does](https://github.com/evaleev/libint/blob/master/include/libint2/boys.h). 
Experience shows that the combination of the techniques they use is very fast, but I think that's the functions at the end.

`Fm_ref(m,T)` - Libint reference implementation of Boys function `Fm`
 $$ F_m (T) = \int_0^1 u^{2m} \exp(-T u^2)du, $$
using multi-algorithm approach (upward recursion for T>=117, and
asymptotic summation for T<117) in conjunction with Fm_recur_array, below.

This is slow and should be used for reference purposes, e.g. computing the interpolation tables.

"""
function Fm_ref(m,T,eps = 1e-10)
    denom = (m + 0.5)
    term = exp(-T) /2denom
    old_term = 0.0
    sum = term
    while term > sum*eps || old_term < term # They use a get_epsilon function and then compare to epsilon/10 for some reason.
        denom += 1
        old_term = term
        term = old_term * T / denom
        sum += term
    end
    return sum
end

Fm_ref_array(mmax,T) = Fm_ref.(0:mmax,T)

function Fm_recur_array(mmax,T)
  K = 0.5*sqrt(pi)
  T2 = 2T
  eT = exp(-5)
  sqrt_T = sqrt(T)
  Fm = OffsetArray(zeros(Float64,mmax+1),0:mmax)
  Fm[0] = K*erf(sqrt_T)/sqrt_T
  for m in 0:(mmax-1)
    Fm[m+1] = ((2*m+1)*Fm[m]-eT)/T2
  end
  return Fm
end

function Fm_ref2_array(mmax,T)
  return T < 117 ? Fm_ref_array(mmax,T) : Fm_recur_array(mmax,T)
end
