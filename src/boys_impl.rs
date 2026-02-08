pub struct BoysFunction {
    epsilon: f64,
}

impl BoysFunction {
    pub fn new(epsilon: Option<f64>) -> Self {
        BoysFunction {
            epsilon: epsilon.unwrap_or(1e-10),
        }
    }

    pub fn eval(&self, m: i32, t: f64) -> f64 {
        if t < 117.0 {
            self.eval_asymptotic(m, t)
        } else {
            self.eval_recur(m, t)
        }
    }

    pub fn eval_array(&self, mmax: i32, t: f64) -> Vec<f64> {
        if t < 117.0 {
            self.eval_asymptotic_array(mmax, t)
        } else {
            self.eval_recur_array(mmax, t)
        }
    }

    fn eval_asymptotic(&self, m: i32, t: f64) -> f64 {
        if t < 1e-14 {
            return 1.0 / (2.0 * m as f64 + 1.0);
        }

        let half = 0.5_f64;
        let mut denom = m as f64 + half;
        let mut term = (-t).exp() / (2.0 * denom);
        let mut old_term = 0.0_f64;
        let mut sum = term;
        let eps_div_10 = self.epsilon / 10.0;

        while term > sum * eps_div_10 || old_term < term {
            denom += 1.0;
            old_term = term;
            term = old_term * t / denom;
            sum += term;
        }

        sum
    }

    fn eval_asymptotic_array(&self, mmax: i32, t: f64) -> Vec<f64> {
        let mut fm = Vec::with_capacity((mmax + 1) as usize);
        for m in 0..=mmax {
            fm.push(self.eval_asymptotic(m, t));
        }
        fm
    }

    fn eval_recur(&self, m: i32, t: f64) -> f64 {
        let fm_array = self.eval_recur_array(m, t);
        fm_array[m as usize]
    }

    fn eval_recur_array(&self, mmax: i32, t: f64) -> Vec<f64> {
        let k = 0.5 * std::f64::consts::PI.sqrt();
        let t2 = 2.0 * t;
        let et = (-t).exp();
        let sqrt_t = t.sqrt();

        let mut fm = vec![0.0_f64; (mmax + 1) as usize];
        fm[0] = k * libm::erf(sqrt_t) / sqrt_t;

        for m in 0..mmax {
            fm[(m + 1) as usize] =
                ((2.0 * m as f64 + 1.0) * fm[m as usize] - et) / t2;
        }

        fm
    }
}

pub struct BoysFunctionCached {
    boys: BoysFunction,
}

 impl BoysFunctionCached {
    pub fn new(_mmax: i32, epsilon: Option<f64>) -> Self {
        BoysFunctionCached {
            boys: BoysFunction::new(epsilon),
        }
    }

    pub fn eval(&self, m: i32, t: f64) -> f64 {
        self.boys.eval(m, t)
    }

    pub fn eval_array(&self, mmax: i32, t: f64) -> Vec<f64> {
        self.boys.eval_array(mmax, t)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_small_t() {
        let boys = BoysFunction::new(None);
        let result = boys.eval(0, 0.1);
        assert!((result - 0.9676433126).abs() < 1e-6);
    }

    #[test]
    fn test_medium_t() {
        let boys = BoysFunction::new(None);
        let result = boys.eval(1, 5.0);
        assert!((result - 0.0388974363).abs() < 1e-6);
    }

    #[test]
    fn test_large_t() {
        let boys = BoysFunction::new(None);
        let result = boys.eval(2, 150.0);
        assert!((result - 0.0000024120).abs() < 1e-6);
    }

    #[test]
    fn test_array() {
        let boys = BoysFunction::new(None);
        let results = boys.eval_array(5, 5.0);
        assert!(results.len() == 6);
        assert!((results[0] - 0.3957123096).abs() < 1e-6);
        assert!((results[1] - 0.0388974363).abs() < 1e-6);
    }

    #[test]
    fn test_near_zero() {
        let boys = BoysFunction::new(None);
        let result = boys.eval(1, 1e-15);
        assert!((result - 0.3333333).abs() < 1e-6);
    }
}
