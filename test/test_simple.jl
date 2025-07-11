#!/usr/bin/env julia

println("🧪 Teste Simples do Heat1DNL.jl")
println("=" ^ 40)

try
    println("1. Carregando o pacote...")
    using Heat1DNL
    println("✅ Heat1DNL carregado com sucesso!")
    
    println("\n2. Testando função demo...")
    demo()
    println("✅ Demo executado com sucesso!")
    
    println("\n3. Testando simulação rápida...")
    C, erro = run_simulation(1, :vectorized)
    println("✅ Simulação concluída!")
    println("   Erro L2: $(erro)")
    println("   Tamanho da solução: $(length(C))")
    
    println("\n🎉 Todos os testes básicos passaram!")
    
catch e
    println("❌ Erro durante o teste: $e")
    println("Stacktrace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end 