module Discretization

include("Config.jl")
using .Config

export u, u0, du0, g, f
export monta_LG, monta_EQ

"""
    u(x, t) -> Float64

Solução exata `u(x, t)` da equação diferencial utilizada para validação numérica.

# Argumentos
- `x`: Ponto no domínio espacial.
- `t`: Ponto no domínio temporal.

# Retorno
Valor da função `u(x, t)` no ponto especificado.
"""
function u(x::Float64, t::Float64)
    return sin(pi*x) * exp(-t) / (pi^2)
end

"""
    u0(x) -> Float64

Condição inicial da solução no instante `t = 0`.

# Argumentos
- `x`: Ponto no domínio espacial.

# Retorno
Valor da função `u0(x) = u(x, 0)` no ponto `x`.
"""
function u0(x::Float64)
    return sin(pi*x) / (pi^2)
end

"""
    du0(x) -> Float64

Derivada da condição inicial `u0` em relação a `x`.

# Argumentos
- `x`: Ponto no domínio espacial.

# Retorno
Valor da derivada de `u0(x)` no ponto `x`.
"""
function du0(x::Float64)
    return cos(pi*x) / pi
end

"""
    g(s) -> Float64

Função não-linear do problema.

# Argumentos
- `s`: Valor no domínio da função `g`.

# Retorno
Valor de `g(s)` no ponto `s`.
"""
function g(s::Float64)
    return s^3 - s
end

"""
    f(x, t) -> Float64

Termo fonte da equação, depende de `x` e `t`.

# Argumentos
- `x`: Ponto no domínio espacial.
- `t`: Ponto no domínio temporal.

# Retorno
Valor da função `f(x, t)` no ponto `(x, t)`.
"""
function f(x::Float64, t::Float64)
    func = ((alpha*(pi^2) + beta - 1)*sin(pi*x) + gamma*pi*cos(pi*x)) * exp(-t) / (pi^2)
    return func + g(u(x, t))
end

"""
    monta_LG(ne) -> Matrix{Int}

Monta a matriz de conectividade local-para-global `LG`, que associa os índices locais
dos elementos aos índices globais da malha.

# Argumentos
- `ne`: Número de elementos finitos.

# Retorno
Matriz `LG` de dimensão `(ne, 2)` com os índices globais associados a cada elemento.
"""
function monta_LG(ne::Int)::Matrix{Int}
    return hcat(1:ne, 2:ne+1)
end

"""
    monta_EQ(ne) -> Vector{Int}

Monta o vetor `EQ` que representa a ordenação das funções de base para as equações de contorno.

# Argumentos
- `ne`: Número de elementos finitos.

# Retorno
Vetor `EQ` com os índices das funções de base, incluindo condições de contorno.
"""
function monta_EQ(ne::Int)::Vector{Int}
    return vcat(ne, 1:(ne - 1), ne)
end

end # module
