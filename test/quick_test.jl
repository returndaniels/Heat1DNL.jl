#!/usr/bin/env julia

# Teste minimalista do Heat1DNL.jl
println("🔬 Teste Minimalista do Heat1DNL.jl")

# Teste 1: Carregamento do pacote
print("1. Carregando Heat1DNL... ")
try
    using Heat1DNL
    println("✅")
catch e
    println("❌ Erro: $e")
    exit(1)
end

# Teste 2: Funções matemáticas básicas
print("2. Testando funções matemáticas... ")
try
    using Heat1DNL.Discretization
    @assert abs(u(0.5, 0.0) - sin(π*0.5)/(π^2)) < 1e-15
    @assert abs(u0(0.5) - sin(π*0.5)/(π^2)) < 1e-15
    @assert abs(g(0.0)) < 1e-15
    println("✅")
catch e
    println("❌ Erro: $e")
    exit(1)
end

# Teste 3: Configuração
print("3. Testando configuração... ")
try
    using Heat1DNL.Config
    @assert Config.ne > 0
    @assert Config.m == Config.ne - 1
    @assert Config.h > 0
    @assert length(Config.P) == Config.npg
    println("✅")
catch e
    println("❌ Erro: $e")
    exit(1)
end

# Teste 4: Discretização
print("4. Testando discretização... ")
try
    using Heat1DNL.Discretization
    LG = monta_LG(5)
    EQ = monta_EQ(5)
    @assert size(LG) == (5, 2)
    @assert length(EQ) == 6
    println("✅")
catch e
    println("❌ Erro: $e")
    exit(1)
end

# Teste 5: Simulação básica (versão muito reduzida)
print("5. Testando simulação básica... ")
try
    # Teste com configuração muito pequena
    using Heat1DNL.InitialConditions
    ne_test = 8
    m_test = ne_test - 1
    h_test = 1.0 / ne_test
    EQoLG_test = monta_EQ(ne_test)[monta_LG(ne_test)]
    
    C0_test = C0_options(1, u0, 0.0, ne_test, m_test, h_test, 5, EQoLG_test)
    @assert length(C0_test) == ne_test - 1
    @assert all(isfinite.(C0_test))
    println("✅")
catch e
    println("❌ Erro: $e")
    exit(1)
end

println("\n🎉 Todos os testes básicos passaram!")
println("O pacote Heat1DNL.jl está funcionando corretamente.") 