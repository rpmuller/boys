use boys::boys_impl::BoysFunction;

fn main() {
    println!("Boys Function Rust Implementation");
    println!("====================================\n");

    let boys = BoysFunction::new(None);

    let test_cases = [
        (0, 0.1),
        (1, 1.0),
        (2, 5.0),
        (3, 10.0),
        (0, 50.0),
        (1, 100.0),
        (2, 150.0),
        (5, 200.0),
    ];

    println!("Single value tests:");
    for (m, t) in test_cases.iter() {
        let result = boys.eval(*m, *t);
        println!("  F_{}({}) = {:.10}", m, t, result);
    }

    println!("\nArray tests:");
    let t = 5.0;
    let mmax = 10;
    let fm_array = boys.eval_array(mmax, t);
    println!("  F_m({}) for m = 0..{}:", t, mmax);
    println!("  {:?}", fm_array);

    println!("\nPerformance test:");
    let n_tests = 100_000;
    let m = 2;
    let t = 5.0;

    use std::time::Instant;
    let start = Instant::now();
    for _ in 0..n_tests {
        boys.eval(m, t);
    }
    let elapsed = start.elapsed();
    let evals_per_sec = n_tests as f64 / elapsed.as_secs_f64();
    println!(
        "  Single value: {} evaluations in {:.4}s ({:.0} evals/s)",
        n_tests,
        elapsed.as_secs_f64(),
        evals_per_sec
    );
}
