module Benchmark

include("Config.jl")
using .Config

include("Discretization.jl")
using .Discretization

include("Serialization.jl")
using .Serialization

include("Vectorization.jl")
using .Vectorization

include("InitialConditions.jl")
using .InitialConditions

include("Solver.jl")
using .Solver

using BenchmarkTools
using LinearAlgebra, SparseArrays

export benchmark_individual_functions, benchmark_complete_system, run_complete_benchmark

"""
    benchmark_individual_functions(samples=100) -> Dict

Executa benchmark das funções individuais (K, F, G) para comparar serial vs vetorizado.

# Argumentos
- `samples`: Número de amostras para o benchmark (padrão: 100)

# Retorno
Dicionário com os resultados dos benchmarks
"""
function benchmark_individual_functions(samples::Int64=100)
    # Monta estrutura local global
    EQoLG = Discretization.monta_EQ(Config.ne)[Discretization.monta_LG(Config.ne)]
    
    # Preparação para benchmarks seriais
    x = Config.h*(Config.P .+ 1)/2 .+ Config.a
    F_ext_serial = zeros(Float64, Config.ne)
    G_ext_serial = zeros(Float64, Config.ne)
    C0_ext = [InitialConditions.C0_options(1, Discretization.u0, Config.a, Config.ne, Config.m, Config.h, Config.npg, EQoLG); 0]
    
    # Preparação para benchmarks vetorizados
    X = ((Config.h/2)*(Config.P .+ 1) .+ Config.a)' .+ range(Config.a, step=Config.h, stop=Config.b-Config.h)
    f_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    g_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    u_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    values = Matrix{Float64}(undef, Config.ne, 2)
    F_ext_vectorized = zeros(Float64, Config.ne)
    G_ext_vectorized = zeros(Float64, Config.ne)
    
    println("=== Benchmark das Funções Individuais ===")
    
    # Benchmark K_serial
    println("\n1. Benchmark K_serial:")
    k_serial_result = @benchmark Serialization.K_serial($Config.ne, $Config.m, $Config.h, $Config.npg, $Config.alpha, $Config.beta, $Config.gamma, $EQoLG) samples=samples seconds=1e9
    println(k_serial_result)
    
    # Benchmark K_vectorized
    println("\n2. Benchmark K_vectorized:")
    k_vectorized_result = @benchmark Vectorization.K_vectorized($Config.ne, $Config.m, $Config.h, $Config.npg, $Config.alpha, $Config.beta, $Config.gamma, $EQoLG) samples=samples seconds=1e9
    println(k_vectorized_result)
    
    # Benchmark F_serial
    println("\n3. Benchmark F_serial:")
    f_serial_result = @benchmark Serialization.F_serial!($F_ext_serial, $x, x -> Discretization.f(x, 0.0), $Config.ne, $Config.m, $Config.h, $Config.npg, $EQoLG) samples=samples seconds=1e9
    println(f_serial_result)
    
    # Benchmark F_vectorized
    println("\n4. Benchmark F_vectorized:")
    f_vectorized_result = @benchmark Vectorization.F_vectorized!($F_ext_vectorized, $X, $f_eval, $values, x -> Discretization.f(x, 0.0), $Config.ne, $Config.m, $Config.h, $Config.npg, $EQoLG) samples=samples seconds=1e9
    println(f_vectorized_result)
    
    # Benchmark G_serial
    println("\n5. Benchmark G_serial:")
    g_serial_result = @benchmark Serialization.G_serial!($G_ext_serial, $C0_ext, $Config.ne, $Config.m, $Config.h, $Config.npg, $EQoLG) samples=samples seconds=1e9
    println(g_serial_result)
    
    # Benchmark G_vectorized
    println("\n6. Benchmark G_vectorized:")
    g_vectorized_result = @benchmark Vectorization.G_vectorized!($G_ext_vectorized, $g_eval, $values, $C0_ext, $Config.ne, $Config.m, $Config.h, $Config.npg, $EQoLG) samples=samples seconds=1e9
    println(g_vectorized_result)
    
    return Dict(
        "K_serial" => k_serial_result,
        "K_vectorized" => k_vectorized_result,
        "F_serial" => f_serial_result,
        "F_vectorized" => f_vectorized_result,
        "G_serial" => g_serial_result,
        "G_vectorized" => g_vectorized_result
    )
end

"""
    benchmark_complete_system(samples=200) -> Dict

Executa benchmark do sistema completo (serial vs vetorizado).

# Argumentos
- `samples`: Número de amostras para o benchmark (padrão: 200)

# Retorno
Dicionário com os resultados dos benchmarks do sistema completo
"""
function benchmark_complete_system(samples::Int64=200)
    println("\n=== Benchmark do Sistema Completo ===")
    
    # Benchmark do sistema serial
    println("\n1. Benchmark Sistema Serial:")
    serial_result = @benchmark Solver.solve_heat_equation_serial(1) samples=samples seconds=1e9 evals=1
    println(serial_result)
    
    # Benchmark do sistema vetorizado
    println("\n2. Benchmark Sistema Vetorizado:")
    vectorized_result = @benchmark Solver.solve_heat_equation_vectorized(1) samples=samples seconds=1e9 evals=1
    println(vectorized_result)
    
    return Dict(
        "sistema_serial" => serial_result,
        "sistema_vectorizado" => vectorized_result
    )
end

"""
    run_complete_benchmark(individual_samples=100, system_samples=200) -> Dict

Executa benchmark completo: funções individuais e sistema completo.

# Argumentos
- `individual_samples`: Número de amostras para benchmark das funções individuais (padrão: 100)
- `system_samples`: Número de amostras para benchmark do sistema completo (padrão: 200)

# Retorno
Dicionário com todos os resultados de benchmark
"""
function run_complete_benchmark(individual_samples::Int64=100, system_samples::Int64=200)
    println("🔥 Iniciando Benchmark Completo do Heat1DNL")
    println("=" ^ 50)
    println("Configuração:")
    println("  - Elementos: $(Config.ne)")
    println("  - Pontos de Gauss: $(Config.npg)")
    println("  - Passos de tempo: $(Config.N)")
    println("  - Amostras (funções): $individual_samples")
    println("  - Amostras (sistema): $system_samples")
    println("=" ^ 50)
    
    # Benchmark das funções individuais
    individual_results = benchmark_individual_functions(individual_samples)
    
    # Benchmark do sistema completo
    system_results = benchmark_complete_system(system_samples)
    
    # Análise dos resultados
    println("\n=== Análise dos Resultados ===")
    
    # Speedup das funções individuais
    k_speedup = BenchmarkTools.median(individual_results["K_serial"]).time / BenchmarkTools.median(individual_results["K_vectorized"]).time
    f_speedup = BenchmarkTools.median(individual_results["F_serial"]).time / BenchmarkTools.median(individual_results["F_vectorized"]).time
    g_speedup = BenchmarkTools.median(individual_results["G_serial"]).time / BenchmarkTools.median(individual_results["G_vectorized"]).time
    
    println("\nSpeedup das Funções Individuais:")
    println("  - K (matriz): $(round(k_speedup, digits=2))x")
    println("  - F (força): $(round(f_speedup, digits=2))x")
    println("  - G (não-linear): $(round(g_speedup, digits=2))x")
    
    # Speedup do sistema completo
    system_speedup = BenchmarkTools.median(system_results["sistema_serial"]).time / BenchmarkTools.median(system_results["sistema_vectorizado"]).time
    println("\nSpeedup do Sistema Completo: $(round(system_speedup, digits=2))x")
    
    # Teste de correção
    println("\n=== Verificação da Correção ===")
    C_serial, erro_serial = Solver.solve_heat_equation_serial(1)
    C_vectorized, erro_vectorized = Solver.solve_heat_equation_vectorized(1)
    
    diff_coeff = maximum(abs.(C_serial - C_vectorized))
    diff_erro = abs(erro_serial - erro_vectorized)
    
    println("Diferença máxima nos coeficientes: $(diff_coeff)")
    println("Diferença no erro L2: $(diff_erro)")
    println("Erro L2 (serial): $(erro_serial)")
    println("Erro L2 (vetorizado): $(erro_vectorized)")
    
    if diff_coeff < 1e-12 && diff_erro < 1e-12
        println("✅ Implementações são equivalentes!")
    else
        println("❌ Implementações apresentam diferenças!")
    end
    
    return Dict(
        "individual" => individual_results,
        "system" => system_results,
        "speedups" => Dict(
            "K" => k_speedup,
            "F" => f_speedup,
            "G" => g_speedup,
            "system" => system_speedup
        ),
        "verification" => Dict(
            "diff_coeff" => diff_coeff,
            "diff_erro" => diff_erro,
            "erro_serial" => erro_serial,
            "erro_vectorized" => erro_vectorized
        )
    )
end

end # module 