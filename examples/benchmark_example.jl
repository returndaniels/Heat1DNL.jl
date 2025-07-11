"""
Exemplo de uso do Heat1DNL para benchmark do problema do calor transiente 1D não-linear.

Este exemplo demonstra como usar o sistema completo implementado no Heat1DNL.jl,
incluindo a simulação da equação do calor e o benchmark das implementações
serial vs vetorizada.
"""

# Adicionar o caminho do projeto ao LOAD_PATH
push!(LOAD_PATH, "../src")

using Heat1DNL

function main()
    println("🔥 Heat1DNL - Exemplo de Benchmark")
    println("=" ^ 60)
    
    # 1. Executar simulação simples
    println("\n1. Executando simulação simples (método vetorizado)...")
    C_vec, erro_vec = Heat1DNL.run_simulation(1, :vectorized)
    
    println("\n2. Executando simulação simples (método serial)...")
    C_ser, erro_ser = Heat1DNL.run_simulation(1, :serial)
    
    # 2. Verificar se os resultados são equivalentes
    println("\n3. Verificando equivalência dos métodos...")
    diff_coeff = maximum(abs.(C_vec - C_ser))
    diff_erro = abs(erro_vec - erro_ser)
    
    println("Diferença máxima nos coeficientes: $(diff_coeff)")
    println("Diferença no erro L2: $(diff_erro)")
    
    if diff_coeff < 1e-12 && diff_erro < 1e-12
        println("✅ Métodos são equivalentes!")
    else
        println("❌ Métodos apresentam diferenças significativas!")
    end
    
    # 3. Executar benchmark completo
    println("\n4. Executando benchmark completo...")
    println("   (Isso pode demorar alguns minutos...)")
    
    # Usar menos amostras para exemplo rápido
    benchmark_results = Heat1DNL.run_benchmark(50, 100)
    
    # 4. Mostrar resumo dos resultados
    println("\n5. Resumo dos Speedups:")
    speedups = benchmark_results["speedups"]
    println("   - Matriz K: $(round(speedups["K"], digits=2))x")
    println("   - Vetor F: $(round(speedups["F"], digits=2))x")
    println("   - Vetor G: $(round(speedups["G"], digits=2))x")
    println("   - Sistema completo: $(round(speedups["system"], digits=2))x")
    
    # 5. Executar demonstração completa
    println("\n6. Executando demonstração completa...")
    Heat1DNL.demo()
    
    println("\n🎉 Exemplo concluído com sucesso!")
    return benchmark_results
end

# Executar o exemplo se o arquivo for executado diretamente
if abspath(PROGRAM_FILE) == @__FILE__
    results = main()
end 