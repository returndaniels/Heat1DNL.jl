module InitialConditions

include("Config.jl")
using .Config

include("Discretization.jl")
using .Discretization

include("Serialization.jl")
using .Serialization

using LinearAlgebra, SparseArrays, FastGaussQuadrature

export C0_options

"""
    C0_options(op, u0, a, ne, m, h, npg, EQoLG) -> Vector{Float64}

Calcula a condição inicial C0 segundo diferentes opções de inicialização.

# Argumentos
- `op`: Opção de inicialização de C0 (1-4)
- `u0`: Função da condição inicial no tempo
- `a`: Limite inferior do domínio de u
- `ne`: Número de elementos finitos no domínio espacial
- `m`: Número de pontos no intervalo (a, b)
- `h`: Tamanho do passo no espaço
- `npg`: Número de pontos de Gauss
- `EQoLG`: Estrutura local global

# Retorno
C0 segundo a opção escolhida

# Opções disponíveis:
1. Interpolante de u0
2. Projeção L2 de u0
3. Projeção H de u0
4. Operador k(u, v) como projeção de u0
"""
function C0_options(op::Int64, u0::Function, a::Float64, ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})::Vector{Float64}
    # Interpolante de u0
    if op == 1
        @views begin
            C0 = zeros(Float64, ne-1)
            @simd for i in 1:(ne-1)
                C0[i] = u0(a + i*h)
            end
            return C0
        end
    
    # Projeção L2 de u0
    elseif op == 2
        M = K_QG(ne, m, h, 0, 1, 0, npg)
        return M \ F_QG(u0, a, ne, m, h, npg, EQoLG)
    
    # Projeção H de u0
    elseif op == 3
        # Gerando o vetor de termos independentes (notação local)
        vet_local = zeros(2)
        # Preenchendo o vetor global
        vet = zeros(ne)
        for e in 1:ne
            vet_local[1] = (u0(a + (e-1)*h) - u0(a + e*h))/h
            vet_local[2] = (u0(a + e*h) - u0(a + (e-1)*h))/h
            for a_idx in 1:2
                i = EQoLG[a_idx, e]
                vet[i] += vet_local[a_idx]
            end 
        end
        D = K_QG(ne, m, h, 1, 0, 0, npg)
        return D \ vet[1:(ne-1)]
    
    # Operador k(u, v) como projeção de u0
    elseif op == 4
        phi1(x) = (1-x)/2
        phi2(x) = (1+x)/2
        # Gerando o vetor de termos independentes (notação local)
        vet_local = zeros(2)
        # Quadratura gaussiana
        X, W = gausslegendre(npg)
        # Preenchendo o vetor global
        vet = zeros(ne)
        for e in 1:ne
            vet_local[1] = Config.alpha*(u0(a+(e-1)*h)-u0(a+e*h))/h + Config.gamma*W'*(du0.(h*(X .+ 1)/2 .+ (a+(e-1)*h)).*phi1.(X))*h/2 +
                           Config.beta*W'*(u0.(h*(X .+ 1)/2 .+ (a+(e-1)*h)).*(1 .- X)/2)*h/2
            vet_local[2] = Config.alpha*(u0(a+e*h)-u0(a+(e-1)*h))/h + Config.gamma*W'*(du0.(h*(X .+ 1)/2 .+ (a+(e-1)*h)).*phi2.(X))*h/2 +
                           Config.beta*W'*(u0.(h*(X .+ 1)/2 .+ (a+(e-1)*h)).*(1 .+ X)/2)*h/2
            for a_idx in 1:2
                i = EQoLG[a_idx, e]
                vet[i] += vet_local[a_idx]
            end
        end
        K = K_QG(ne, m, h, Config.alpha, Config.beta, Config.gamma, npg)
        return K \ vet[1:(ne-1)]
    else
        error("Opção inválida!")
    end
end

# Funções auxiliares para as opções 2 e 3 (implementação simplificada)
function K_QG(ne::Int64, m::Int64, h::Float64, alpha::Float64, beta::Float64, gamma::Float64, npg::Int64)
    # Implementação simplificada usando as funções já existentes
    EQoLG = Discretization.monta_EQ(ne)[Discretization.monta_LG(ne)]
    return Serialization.K_serial(ne, m, h, npg, alpha, beta, gamma, EQoLG)
end

function F_QG(u0::Function, a::Float64, ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})
    # Implementação simplificada para o vetor de força com u0
    F_ext = zeros(Float64, ne)
    x = h*(Config.P .+ 1)/2 .+ a
    Serialization.F_serial!(F_ext, x, u0, ne, m, h, npg, EQoLG)
    return F_ext[1:(ne-1)]
end

end # module 