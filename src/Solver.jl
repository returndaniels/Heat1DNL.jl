module Solver

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

using LinearAlgebra, SparseArrays

export solve_heat_equation_serial, solve_heat_equation_vectorized

"""
    solve_heat_equation_serial(option=1) -> (Vector{Float64}, Float64)

Resolve a equação do calor usando implementação serial (laço explícito).

# Argumentos
- `option`: Opção de inicialização de C0 (padrão: 1)

# Retorno
Tupla contendo:
- Vetor com os coeficientes da solução final
- Erro L2 entre a solução exata e aproximada no tempo final
"""
function solve_heat_equation_serial(option::Int64=1)
    # Monta estrutura local global
    EQoLG = Discretization.monta_EQ(Config.ne)[Discretization.monta_LG(Config.ne)]
    
    # Estruturas externas usadas pelas funções
    x = Config.h*(Config.P .+ 1)/2 .+ Config.a
    F_ext_serial = zeros(Float64, Config.ne)
    G_ext_serial = zeros(Float64, Config.ne)

    # Pré-aloca memória para o lado direito do sistema linear
    B = zeros(Float64, Config.ne-1)
    
    # Montando o sistema linear
    M = Serialization.K_serial(Config.ne, Config.m, Config.h, Config.npg, 0.0, 1.0, 0.0, EQoLG)[1:Config.ne-1, 1:Config.ne-1]
    K = Serialization.K_serial(Config.ne, Config.m, Config.h, Config.npg, Config.alpha, Config.beta, Config.gamma, EQoLG)[1:Config.ne-1, 1:Config.ne-1]
    
    MK = M/Config.tau - K/2
    # Decomposição LU para resolução de múltiplos sistemas
    LU_dec = lu(M/Config.tau + K/2)
    
    # Aproximação de U0
    C0_ext = [InitialConditions.C0_options(option, Discretization.u0, Config.a, Config.ne, Config.m, Config.h, Config.npg, EQoLG); 0]
    C0 = @view C0_ext[1:Config.ne-1]
    MKC0 = MK*C0
    
    # Aproximação de U1
    Serialization.F_serial!(F_ext_serial, x, x -> Discretization.f(x, Config.tau*0.5), Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    F = @view F_ext_serial[1:Config.ne-1]
    Serialization.G_serial!(G_ext_serial, C0_ext, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    G = @view G_ext_serial[1:Config.ne-1]
    C1_ext_tiu = zeros(Float64, Config.ne)
    B .= F
    B .+= MKC0
    B .-= G
    C1_ext_tiu[1:Config.ne-1] .= LU_dec\B
    
    Serialization.G_serial!(G_ext_serial, (C0_ext + C1_ext_tiu)/2, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    G = @view G_ext_serial[1:Config.ne-1]
    C1_ext = zeros(Float64, Config.ne)
    B .= F
    B .+= MKC0
    B .-= G
    C1_ext[1:Config.ne-1] = LU_dec\B

    # Pré-aloca memória para operações repetidas
    Cn_ext = zeros(Float64, Config.ne)
    G_C_ext = zeros(Float64, Config.ne)
    MKC1 = zeros(Float64, Config.ne-1)
    B = zeros(Float64, Config.ne-1)
    
    @views @simd for n in 2:Config.N
        ############ Cálculo sem consumo extra de memória ############
        Serialization.F_serial!(F_ext_serial, x, x -> Discretization.f(x, Config.tau*(n-0.5)), Config.ne, Config.m, Config.h, Config.npg, EQoLG)
        F = F_ext_serial[1:Config.ne-1]

        MKC1 .= MK*(C1_ext[1:Config.ne-1])
        
        G_C_ext[1:Config.ne-1] .= 3*(C1_ext[1:Config.ne-1])
        G_C_ext[1:Config.ne-1] .-= C0_ext[1:Config.ne-1]
        G_C_ext[1:Config.ne-1] ./= 2
        Serialization.G_serial!(G_ext_serial, G_C_ext, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
        G = G_ext_serial[1:Config.ne-1]

        B .= F
        B .+= MKC1
        B .-= G
        ##############################################################
        # Calcula o próximo coeficiente e atualiza
        Cn_ext[1:Config.ne-1] .= LU_dec\B
        C0_ext[1:Config.ne-1] .= C1_ext[1:Config.ne-1]
        C1_ext[1:Config.ne-1] .= Cn_ext[1:Config.ne-1]
    end
    
    # Calcula o erro final
    C_final = C1_ext[1:Config.ne-1]
    erro_final = Serialization.erro_serial(x -> Discretization.u(x, Config.T), x, Config.ne, Config.m, Config.h, Config.npg, C_final, EQoLG)
    
    return C_final, erro_final
end

"""
    solve_heat_equation_vectorized(option=1) -> (Vector{Float64}, Float64)

Resolve a equação do calor usando implementação vetorizada.

# Argumentos
- `option`: Opção de inicialização de C0 (padrão: 1)

# Retorno
Tupla contendo:
- Vetor com os coeficientes da solução final
- Erro L2 entre a solução exata e aproximada no tempo final
"""
function solve_heat_equation_vectorized(option::Int64=1)
    # Monta estrutura local global
    EQoLG = Discretization.monta_EQ(Config.ne)[Discretization.monta_LG(Config.ne)]
    
    # Estruturas externas usadas pelas funções
    X = ((Config.h/2)*(Config.P .+ 1) .+ Config.a)' .+ range(Config.a, step=Config.h, stop=Config.b-Config.h)
    f_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    g_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    u_eval = Matrix{Float64}(undef, Config.ne, Config.npg)
    values = Matrix{Float64}(undef, Config.ne, 2)
    F_ext_vectorized = zeros(Float64, Config.ne)
    G_ext_vectorized = zeros(Float64, Config.ne)

    # Pré-aloca memória para o lado direito do sistema linear
    B = zeros(Float64, Config.ne-1)

    # Montando o sistema linear
    M = Vectorization.K_vectorized(Config.ne, Config.m, Config.h, Config.npg, 0.0, 1.0, 0.0, EQoLG)[1:Config.ne-1, 1:Config.ne-1]
    K = Vectorization.K_vectorized(Config.ne, Config.m, Config.h, Config.npg, Config.alpha, Config.beta, Config.gamma, EQoLG)[1:Config.ne-1, 1:Config.ne-1]
    
    MK = M/Config.tau - K/2
    # Decomposição LU para resolução de múltiplos sistemas
    LU_dec = lu(M/Config.tau + K/2)
    
    # Aproximação de U0
    C0_ext = [InitialConditions.C0_options(option, Discretization.u0, Config.a, Config.ne, Config.m, Config.h, Config.npg, EQoLG); 0]
    C0 = @view C0_ext[1:Config.ne-1]
    MKC0 = MK*C0

    # Aproximação de U1
    Vectorization.F_vectorized!(F_ext_vectorized, X, f_eval, values, x -> Discretization.f(x, Config.tau*0.5), Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    F = @view F_ext_vectorized[1:Config.ne-1]
    Vectorization.G_vectorized!(G_ext_vectorized, g_eval, values, C0_ext, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    G = @view G_ext_vectorized[1:Config.ne-1]
    C1_ext_tiu = zeros(Float64, Config.ne)
    B .= F
    B .+= MKC0
    B .-= G
    C1_ext_tiu[1:Config.ne-1] .= LU_dec\B
    
    Vectorization.G_vectorized!(G_ext_vectorized, g_eval, values, (C0_ext + C1_ext_tiu)/2, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
    G = @view G_ext_vectorized[1:Config.ne-1]
    C1_ext = zeros(Float64, Config.ne)
    B .= F
    B .+= MKC0
    B .-= G
    C1_ext[1:Config.ne-1] = LU_dec\B
    
    # Pré-aloca memória para operações repetidas
    Cn_ext = zeros(Float64, Config.ne)
    G_C_ext = zeros(Float64, Config.ne)
    MKC1 = zeros(Float64, Config.ne-1)
    
    @views @simd for n in 2:Config.N
        ############ Cálculo sem consumo extra de memória ############
        Vectorization.F_vectorized!(F_ext_vectorized, X, f_eval, values, x -> Discretization.f(x, Config.tau*(n-0.5)), Config.ne, Config.m, Config.h, Config.npg, EQoLG)
        F = F_ext_vectorized[1:Config.ne-1]

        MKC1 .= MK*(C1_ext[1:Config.ne-1])
        
        G_C_ext[1:Config.ne-1] .= 3*(C1_ext[1:Config.ne-1])
        G_C_ext[1:Config.ne-1] .-= C0_ext[1:Config.ne-1]
        G_C_ext[1:Config.ne-1] ./= 2
        Vectorization.G_vectorized!(G_ext_vectorized, g_eval, values, G_C_ext, Config.ne, Config.m, Config.h, Config.npg, EQoLG)
        G = G_ext_vectorized[1:Config.ne-1]

        B .= F
        B .+= MKC1
        B .-= G
        ##############################################################
        # Calcula o próximo coeficiente e atualiza
        Cn_ext[1:Config.ne-1] .= LU_dec\B
        C0_ext[1:Config.ne-1] .= C1_ext[1:Config.ne-1]
        C1_ext[1:Config.ne-1] .= Cn_ext[1:Config.ne-1]
    end
    
    # Calcula o erro final
    C_final = C1_ext[1:Config.ne-1]
    erro_final = Vectorization.erro_vectorized(x -> Discretization.u(x, Config.T), X, u_eval, Config.ne, Config.m, Config.h, Config.npg, C_final, EQoLG)
    
    return C_final, erro_final
end

end # module 