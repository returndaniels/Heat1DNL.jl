"""
    benchmark(func, args, samples; evals=1)

Run a benchmark test for the given `func` using `BenchmarkTools.@benchmark`, with `samples`
as the number of samples and `evals` as the number of evaluations per sample (default is `1`).

The function `func` is first called once with `args...` to compile it before benchmarking.

# Arguments
- `func`: The function to benchmark.
- `args`: Arguments to be passed to `func`.
- `samples`: Number of samples to collect during the benchmark.
- `evals`: (Optional) Number of evaluations per sample. Default is `1`.

# Returns
A `BenchmarkTools.Trial` object containing the performance results.
"""
function benchmark(func::Function, args::Any, samples::Int64; evals=1)
    func(args...)  # Compila a função antes de começar para ignorar tempo de compilação
    resultado = @benchmark ($func($args...)) samples=samples seconds=1e9 evals=evals
    return resultado
end
