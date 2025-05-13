module Vectorization

include("Config.jl")
using .Config

using LinearAlgebra, SparseArrays

export K_vectorized, F_vectorized!, G_vectorized!, erro_vectorized, WφP

# Constantes pré-calculadas para quadratura
const WφP = [(Config.W .* Config.φ1P) (Config.W .* Config.φ2P)]

"""
    K_vectorized(ne, m, h, npg, alpha, beta, gamma, EQoLG) -> SparseMatrixCSC

Monta a matriz de rigidez global `K` usando uma implementação vetorizada.

# Argumentos
- `ne`: Número de elementos finitos.
- `m`: Número de nós internos.
- `h`: Tamanho do passo no domínio espacial.
- `npg`: Número de pontos de Gauss.
- `alpha`, `beta`, `gamma`: Coeficientes do problema diferencial.
- `EQoLG`: Matriz de correspondência local-para-global.

# Retorno
Matriz esparsa `K` do sistema linear global.
"""
function K_vectorized(ne::Int64, m::Int64, h::Float64, npg::Int64,
                      alpha::Float64, beta::Float64, gamma::Float64, EQoLG::Matrix{Int64})::SparseMatrixCSC{Float64, Int64}
    i = EQoLG[:, 1]
    j = EQoLG[:, 2]
    lin_idx = vcat(i, i, j, j)
    col_idx = vcat(i, j, i, j)

    k_values = vcat(
        fill(dot(Config.W, 2alpha*(Config.dφ1P .* Config.dφ1P)/h + gamma*(Config.φ1P .* Config.dφ1P) + beta*h*(Config.φ1P .* Config.φ1P)/2), ne),
        fill(dot(Config.W, 2alpha*(Config.dφ1P .* Config.dφ2P)/h + gamma*(Config.φ1P .* Config.dφ2P) + beta*h*(Config.φ1P .* Config.φ2P)/2), ne),
        fill(dot(Config.W, 2alpha*(Config.dφ2P .* Config.dφ1P)/h + gamma*(Config.φ2P .* Config.dφ1P) + beta*h*(Config.φ2P .* Config.φ1P)/2), ne),
        fill(dot(Config.W, 2alpha*(Config.dφ2P .* Config.dφ2P)/h + gamma*(Config.φ2P .* Config.dφ2P) + beta*h*(Config.φ2P .* Config.φ2P)/2), ne)
    )

    return sparse(lin_idx, col_idx, k_values, ne, ne)
end

"""
    F_vectorized!(F_ext, X, f_eval, values, f, ne, m, h, npg, EQoLG)

Calcula o vetor de forças externas `F_ext` via quadratura de Gauss com implementação vetorizada.

# Argumentos
- `F_ext`: Vetor de força externo (pré-alocado, saída).
- `X`: Matriz de coordenadas dos pontos de Gauss nos elementos.
- `f_eval`: Matriz para armazenar `f(X)` (pré-alocada).
- `values`: Matriz auxiliar para multiplicações (pré-alocada).
- `f`: Função de carga.
- `ne`, `m`, `h`, `npg`, `EQoLG`: Parâmetros do método de elementos finitos.
"""
function F_vectorized!(F_ext::Vector{Float64}, X::Matrix{Float64}, f_eval::Matrix{Float64}, values::Matrix{Float64},
                       f::Function, ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})
    fill!(F_ext, 0.0)
    @. f_eval = f(X)
    mul!(values, f_eval, WφP)
    @simd for i in 1:2
        F_ext[EQoLG[:, i]] .+= values[:, i]
    end
    F_ext .*= (h/2)
end

"""
    G_vectorized!(G_ext, g_eval, values, C_ext, ne, m, h, npg, EQoLG)

Calcula o vetor não-linear `G_ext` com implementação vetorizada.

# Argumentos
- `G_ext`: Vetor não-linear (pré-alocado, saída).
- `g_eval`: Matriz para armazenar avaliação da função `g` (pré-alocada).
- `values`: Matriz auxiliar para multiplicações (pré-alocada).
- `C_ext`: Vetor de coeficientes da solução aproximada.
- `ne`, `m`, `h`, `npg`, `EQoLG`: Parâmetros do método de elementos finitos.
"""
function G_vectorized!(G_ext::Vector{Float64}, g_eval::Matrix{Float64}, values::Matrix{Float64},
                       C_ext::Vector{Float64}, ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})
    fill!(G_ext, 0.0)
    @. g_eval = Config.g(Config.φ1P' * C_ext[EQoLG[:, 1]] + Config.φ2P' * C_ext[EQoLG[:, 2]])
    mul!(values, g_eval, WφP)
    @simd for i in 1:2
        G_ext[EQoLG[:, i]] .+= values[:, i]
    end
    G_ext .*= (h/2)
end

"""
    erro_vectorized(u, X, u_eval, ne, m, h, npg, C, EQoLG) -> Float64

Calcula o erro na norma L2 entre a solução exata `u` e a solução aproximada.

# Argumentos
- `u`: Função da solução exata.
- `X`: Matriz com pontos de Gauss para todos os elementos.
- `u_eval`: Matriz para armazenar os erros ponto-a-ponto (pré-alocada).
- `C`: Vetor de coeficientes da solução aproximada.
- `ne`, `m`, `h`, `npg`, `EQoLG`: Parâmetros do método de elementos finitos.

# Retorno
Erro L2 entre a solução exata e a aproximada.
"""
function erro_vectorized(u::Function, X::Matrix{Float64}, u_eval::Matrix{Float64},
                         ne::Int64, m::Int64, h::Float64, npg::Int64, C::Vector{Float64}, EQoLG::Matrix{Int64})::Float64
    C_ext = [C; 0]
    @. u_eval = u(X)
    @. u_eval -= C_ext[EQoLG[:, 1]] * (Config.φ1P')
    @. u_eval -= C_ext[EQoLG[:, 2]] * (Config.φ2P')
    @. u_eval *= Config.W'
    @. u_eval ^= 2
    return sqrt((h/2) * sum(u_eval))
end

end # module
