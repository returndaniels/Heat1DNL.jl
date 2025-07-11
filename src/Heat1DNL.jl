module Heat1DNL

# Importação dos módulos necessários
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

include("Benchmark.jl")
using .Benchmark

include("utils/benchmark.jl")

using LinearAlgebra, BenchmarkTools

# Exportar as principais funcionalidades
export run_simulation, run_benchmark, solve_heat_equation_serial, solve_heat_equation_vectorized
export run_complete_benchmark, benchmark_individual_functions, benchmark_complete_system

"""
    run_simulation(option=1, method=:vectorized) -> (Vector{Float64}, Float64)

Executa a simulação da equação do calor.

# Argumentos
- `option`: Opção de inicialização de C0 (padrão: 1)
- `method`: Método de solução (:serial ou :vectorized, padrão: :vectorized)

# Retorno
Tupla contendo:
- Vetor com os coeficientes da solução final
- Erro L2 entre a solução exata e aproximada no tempo final
"""
function run_simulation(option::Int64=1, method::Symbol=:vectorized)
    println("🔥 Heat1DNL - Simulação da Equação do Calor Transiente 1D")
    println("=" ^ 60)
    println("Configuração:")
    println("  - Domínio: [$(Config.a), $(Config.b)] × [0, $(Config.T)]")
    println("  - Elementos: $(Config.ne)")
    println("  - Pontos de Gauss: $(Config.npg)")
    println("  - Passo espacial: $(Config.h)")
    println("  - Passo temporal: $(Config.tau)")
    println("  - Passos de tempo: $(Config.N)")
    println("  - Método: $method")
    println("  - Opção C0: $option")
    println("=" ^ 60)
    
    if method == :serial
        println("Executando simulação com método serial...")
        C, erro = Solver.solve_heat_equation_serial(option)
    elseif method == :vectorized
        println("Executando simulação com método vetorizado...")
        C, erro = Solver.solve_heat_equation_vectorized(option)
    else
        error("Método inválido. Use :serial ou :vectorized")
    end
    
    println("\n✅ Simulação concluída!")
    println("Erro L2 final: $(erro)")
    
    return C, erro
end

"""
    run_benchmark(individual_samples=100, system_samples=200) -> Dict

Executa benchmark completo do sistema.

# Argumentos
- `individual_samples`: Número de amostras para benchmark das funções individuais (padrão: 100)
- `system_samples`: Número de amostras para benchmark do sistema completo (padrão: 200)

# Retorno
Dicionário com todos os resultados de benchmark
"""
function run_benchmark(individual_samples::Int64=100, system_samples::Int64=200)
    return Benchmark.run_complete_benchmark(individual_samples, system_samples)
end

"""
    demo() -> Nothing

Executa uma demonstração completa do Heat1DNL.
"""
function demo()
    println("🚀 Heat1DNL - Demonstração Completa")
    println("=" ^ 60)
    
    # Executa simulação
    println("\n1. Executando simulação...")
    C, erro = run_simulation()
    
    # Executa benchmark (com menos amostras para demo)
    println("\n2. Executando benchmark...")
    benchmark_results = run_benchmark(50, 100)
    
    println("\n🎉 Demonstração concluída!")
    println("Verifique os resultados acima para análise de performance.")
    
    return nothing
end

# Função principal para compatibilidade
function main()
    demo()
end

end # module
