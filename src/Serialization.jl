module Serialization

include("Config.jl")
using .Config

using LinearAlgebra, SparseArrays, StaticArrays

export K_serial, F_serial!, G_serial!, erro_serial

"""
    K_serial(ne, m, h, npg, alpha, beta, gamma, EQoLG)

Assemble and return the global stiffness matrix `K` for a 1D finite element method,
using scalar (serial) implementation.

# Arguments
- `ne`: Number of finite elements.
- `m`: Number of internal nodes.
- `h`: Step size in the spatial domain.
- `npg`: Number of Gauss points.
- `alpha`, `beta`, `gamma`: Coefficients from the PDE.
- `EQoLG`: Local-to-global mapping matrix.

# Returns
A sparse matrix `K` of size `(ne, ne)`.
"""
function K_serial(ne::Int64, m::Int64, h::Float64, npg::Int64,
                  alpha::Float64, beta::Float64, gamma::Float64, EQoLG::Matrix{Int64})::SparseMatrixCSC{Float64, Int64}
    @views begin
        K_local = @SMatrix [
            dot(Config.W, 2alpha*(Config.dφ1P .* Config.dφ1P)/h + gamma*(Config.φ1P .* Config.dφ1P) + beta*h*(Config.φ1P .* Config.φ1P)/2),
            dot(Config.W, 2alpha*(Config.dφ1P .* Config.dφ2P)/h + gamma*(Config.φ1P .* Config.dφ2P) + beta*h*(Config.φ1P .* Config.φ2P)/2);
            dot(Config.W, 2alpha*(Config.dφ2P .* Config.dφ1P)/h + gamma*(Config.φ2P .* Config.dφ1P) + beta*h*(Config.φ2P .* Config.φ1P)/2),
            dot(Config.W, 2alpha*(Config.dφ2P .* Config.dφ2P)/h + gamma*(Config.φ2P .* Config.dφ2P) + beta*h*(Config.φ2P .* Config.φ2P)/2)
        ]

        I, J, V = Vector{Int64}(undef, 4ne), Vector{Int64}(undef, 4ne), Vector{Float64}(undef, 4ne)
        pos = 1
        for e in 1:ne
            eq = EQoLG[e, :]
            for a in 1:2, b in 1:2
                I[pos] = eq[a]
                J[pos] = eq[b]
                V[pos] = K_local[a, b]
                pos += 1
            end
        end
        return sparse(I, J, V, ne, ne)
    end
end

"""
    F_serial!(F_ext_serial, x, f, ne, m, h, npg, EQoLG)

Compute the force vector `F_ext_serial` using numerical quadrature (Gauss method),
with a scalar/serial implementation.

# Arguments
- `F_ext_serial`: Preallocated force vector (output).
- `x`: Vector with Gauss points in the domain.
- `f`: Source term function.
- `ne`: Number of finite elements.
- `m`: Number of internal nodes.
- `h`: Step size.
- `npg`: Number of Gauss points.
- `EQoLG`: Local-to-global mapping matrix.
"""
function F_serial!(F_ext_serial::Vector{Float64}, x::Vector{Float64},
                   f::Function, ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})
    @views begin
        fill!(F_ext_serial, 0.0)
        @simd for e in 1:ne
            offset = (e - 1) * h
            i = EQoLG[e, 1]
            j = EQoLG[e, 2]
            @simd for g in 1:npg
                f_eval = h * f(x[g] + offset) / 2
                F_ext_serial[i] += Config.Wφ1P[g] * f_eval
                F_ext_serial[j] += Config.Wφ2P[g] * f_eval
            end
        end
    end
end

"""
    G_serial!(G_ext_serial, C_ext, ne, m, h, npg, EQoLG)

Compute the nonlinear vector `G_ext_serial` using a scalar/serial implementation.

# Arguments
- `G_ext_serial`: Preallocated nonlinear vector (output).
- `C_ext`: Vector with approximate solution coefficients.
- `ne`: Number of finite elements.
- `m`: Number of internal nodes.
- `h`: Step size.
- `npg`: Number of Gauss points.
- `EQoLG`: Local-to-global mapping matrix.
"""
function G_serial!(G_ext_serial::Vector{Float64}, C_ext::Vector{Float64},
                   ne::Int64, m::Int64, h::Float64, npg::Int64, EQoLG::Matrix{Int64})
    @views begin
        fill!(G_ext_serial, 0.0)
        @simd for e in 1:ne
            i = EQoLG[e, 1]
            j = EQoLG[e, 2]
            c1 = C_ext[i]
            c2 = C_ext[j]
            @simd for p in 1:npg
                g_eval = h * Config.g(c1 * Config.φ1P[p] + c2 * Config.φ2P[p]) / 2
                G_ext_serial[i] += Config.Wφ1P[p] * g_eval
                G_ext_serial[j] += Config.Wφ2P[p] * g_eval
            end
        end
    end
end

"""
    erro_serial(u, x, ne, m, h, npg, C, EQoLG)

Compute the L2 norm of the error between the exact solution `u` and the approximate
solution represented by the coefficient vector `C`, using scalar/serial implementation.

# Arguments
- `u`: Exact solution function.
- `x`: Vector with Gauss points.
- `ne`: Number of finite elements.
- `m`: Number of internal nodes.
- `h`: Step size.
- `npg`: Number of Gauss points.
- `C`: Coefficients of the approximate solution.
- `EQoLG`: Local-to-global mapping matrix.

# Returns
The L2 error norm between the exact and approximate solutions.
"""
function erro_serial(u::Function, x::Vector{Float64}, ne::Int64, m::Int64, h::Float64, npg::Int64,
                     C::Vector{Float64}, EQoLG::Matrix{Int64})::Float64
    @views begin
        C_ext = [C; 0.0]
        sum_er = 0.0
        @simd for e in 1:ne
            C1 = C_ext[EQoLG[e, 1]]
            C2 = C_ext[EQoLG[e, 2]]
            offset = (e - 1) * h
            @simd for g in 1:npg
                approx = C1 * Config.φ1P[g] + C2 * Config.φ2P[g]
                exact = u(x[g] + offset)
                sum_er += Config.W[g] * (exact - approx)^2
            end
        end
        return sqrt(h * sum_er / 2)
    end
end

end # module
