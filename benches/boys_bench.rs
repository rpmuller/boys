use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use boys::boys_impl::BoysFunction;

fn bench_boys_single(c: &mut Criterion) {
    let boys = BoysFunction::new(None);
    
    let mut group = c.benchmark_group("boys_single");
    
    for t in [0.1, 1.0, 5.0, 10.0, 50.0, 100.0, 150.0].iter() {
        group.bench_with_input(BenchmarkId::new("t", t), t, |b, &t| {
            b.iter(|| boys.eval(black_box(2), black_box(t)));
        });
    }
    
    group.finish();
}

fn bench_boys_array(c: &mut Criterion) {
    let boys = BoysFunction::new(None);
    
    let mut group = c.benchmark_group("boys_array");
    
    for mmax in [5, 10, 20].iter() {
        group.bench_with_input(BenchmarkId::new("mmax", mmax), mmax, |b, &mmax| {
            b.iter(|| boys.eval_array(black_box(mmax), black_box(5.0)));
        });
    }
    
    group.finish();
}

fn bench_boys_mixed(c: &mut Criterion) {
    let boys = BoysFunction::new(None);
    
    c.bench_function("boys_mixed_t", |b| {
        b.iter(|| {
            let t_values = [0.1, 5.0, 10.0, 50.0, 150.0];
            for &t in &t_values {
                black_box(boys.eval(black_box(2), black_box(t)));
            }
        });
    });
}

criterion_group!(benches, bench_boys_single, bench_boys_array, bench_boys_mixed);
criterion_main!(benches);
