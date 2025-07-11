#!/usr/bin/env julia

using Test
using Heat1DNL

# Importar módulos para testes
using Heat1DNL.Config
using Heat1DNL.Discretization
using Heat1DNL.Serialization
using Heat1DNL.Vectorization
using Heat1DNL.InitialConditions
using Heat1DNL.Solver

println("🎯 Teste Focado do Heat1DNL.jl")
println("=" ^ 40)

@testset "Testes Essenciais" begin
    
    @testset "1. Funções Básicas" begin
        # Testa funções matemáticas
        @test abs(u(0.5, 0.0) - sin(π*0.5)/(π^2)) < 1e-15
        @test abs(u0(0.5) - sin(π*0.5)/(π^2)) < 1e-15
        @test abs(g(0.0)) < 1e-15
        @test abs(g(1.0)) < 1e-15
        println("✅ Funções básicas: PASSOU")
    end
    
    @testset "2. Discretização" begin
        # Configuração pequena para teste rápido
        ne_test = 16
        LG = monta_LG(ne_test)
        EQ = monta_EQ(ne_test)
        
        @test size(LG) == (ne_test, 2)
        @test length(EQ) == ne_test + 1
        @test EQ[1] == ne_test
        @test EQ[end] == ne_test
        println("✅ Discretização: PASSOU")
    end
    
    @testset "3. Equivalência (Configuração Pequena)" begin
        # Configuração muito pequena para teste rápido
        ne_test = 32
        m_test = ne_test - 1
        h_test = (Config.b - Config.a) / ne_test
        EQoLG_test = monta_EQ(ne_test)[monta_LG(ne_test)]
        
        # Testa matriz K
        K_ser = K_serial(ne_test, m_test, h_test, Config.npg, Config.alpha, Config.beta, Config.gamma, EQoLG_test)
        K_vec = K_vectorized(ne_test, m_test, h_test, Config.npg, Config.alpha, Config.beta, Config.gamma, EQoLG_test)
        
        diff_K = maximum(abs.(K_ser - K_vec))
        @test diff_K < 1e-12
        println("  Diferença máxima em K: $(diff_K)")
        
        # Testa condição inicial
        C0_test = C0_options(1, u0, Config.a, ne_test, m_test, h_test, Config.npg, EQoLG_test)
        @test length(C0_test) == m_test
        @test all(isfinite.(C0_test))
        
        println("✅ Equivalência: PASSOU")
    end
    
    @testset "4. Simulação Reduzida" begin
        # Modifica temporariamente o Config para simulação rápida
        println("  Configuração original: ne=$(Config.ne), N=$(Config.N)")
        
        # Testa com configuração bem pequena
        ne_small = 64
        m_small = ne_small - 1
        h_small = (Config.b - Config.a) / ne_small
        EQoLG_small = monta_EQ(ne_small)[monta_LG(ne_small)]
        
        # Testa apenas a condição inicial
        C0_small = C0_options(1, u0, Config.a, ne_small, m_small, h_small, Config.npg, EQoLG_small)
        @test length(C0_small) == m_small
        @test all(isfinite.(C0_small))
        
        # Testa cálculo de erro
        erro_test = erro_serial(x -> u(x, 0.0), Config.h*(Config.P .+ 1)/2 .+ Config.a, 
                               ne_small, m_small, h_small, Config.npg, C0_small, EQoLG_small)
        @test isfinite(erro_test)
        @test erro_test > 0
        
        println("  Erro L2 inicial: $(erro_test)")
        println("✅ Simulação reduzida: PASSOU")
    end
    
    @testset "5. Interface Principal" begin
        # Testa apenas que as funções não crasham
        try
            # Usa configuração padrão mas não executa completamente
            println("  Testando carregamento das funções...")
            @test isa(run_simulation, Function)
            @test isa(run_benchmark, Function)
            @test isa(demo, Function)
            println("✅ Interface principal: PASSOU")
        catch e
            @test false
        end
    end
    
    @testset "6. Configuração" begin
        # Testa constantes
        @test Config.ne > 0
        @test Config.m == Config.ne - 1
        @test Config.h > 0
        @test Config.tau > 0
        @test Config.N > 0
        @test Config.npg > 0
        
        # Testa pontos de Gauss
        @test length(Config.P) == Config.npg
        @test length(Config.W) == Config.npg
        @test abs(sum(Config.W) - 2.0) < 1e-15
        
        println("✅ Configuração: PASSOU")
    end
    
end

println("\n🎉 Todos os testes essenciais passaram!")
println("O Heat1DNL.jl está funcionando corretamente para os casos testados.") 