module Config

"""
    module Config

Define constantes globais e parâmetros de configuração do problema a partir de variáveis de ambiente,
incluindo propriedades físicas, domínio, discretização, quadratura de Gauss e funções de forma para
elementos finitos 1D.

# Funcionalidade

- Carrega variáveis do arquivo `.env` usando `DotEnv.jl`.
- Define parâmetros físicos (`alpha`, `beta`, `gamma`) e de domínio (`a`, `b`, `T`).
- Define parâmetros de discretização espacial (`ne`, `m`, `h`) e temporal (`tau`, `N`).
- Inicializa quadratura de Gauss-Legendre com `npg` pontos (pesos `W` e abscissas `P`).
- Avalia funções de forma lineares (`φ1`, `φ2`) e suas derivadas (`dφ1`, `dφ2`) nos pontos de quadratura.
- Pré-calcula produtos úteis como `W .* φ1P` e `W .* φ2P` para acelerar montagens vetorizadas.

# Constantes Exportadas

- `samples`: Número de amostras para validações ou integrações (default: 10^6).
- `beta`, `alpha`, `gamma`: Coeficientes do problema.
- `a`, `b`, `T`: Limites do domínio espacial e tempo final.
- `npg`: Número de pontos de Gauss.
- `ne`, `m`, `h`: Número de elementos, nós internos e passo espacial.
- `tau`, `N`: Passo de tempo e número total de passos.
- `P`, `W`: Pontos e pesos de quadratura de Gauss-Legendre.
- `φ1P`, `φ2P`, `dφ1P`, `dφ2P`: Avaliações das funções de forma e derivadas nos pontos de Gauss.
- `Wφ1P`, `Wφ2P`: Produtos ponderados com Jacobiano para integração vetorizada.

# Dependências

- `DotEnv.jl` para carregar variáveis de ambiente.
- `FastGaussQuadrature.jl` para pontos e pesos de Gauss.
- `utils/env.jl` (inclusão local) para leitura segura das variáveis de ambiente.

# Uso

Este módulo deve ser carregado no início de qualquer execução para garantir que os parâmetros do
problema estejam configurados corretamente e acessíveis por outros módulos como `Discretization` e `Vectorization`.

"""


using FastGaussQuadrature
# Carrega funções auxiliares
include("utils/env.jl")  # Define getenv_int, getenv_float, etc

# Carrega variáveis de ambiente do arquivo `.env` do diretório atual
load_env_manual(joinpath(pwd(), ".env"))


# Exportação

export samples
export beta, alpha, gamma, a, b, T, npg
export ne, m, h, tau, N
export P, W, φ1P, φ2P, dφ1P, dφ2P, Wφ1P, Wφ2P


# Parâmetros físicos, espaciais, temporais e discretização

const samples = getenv_int("SAMPLES", 10^6)

# Lê variáveis com fallback padrão
const beta  = getenv_float("BETA", 1.0)
const alpha = getenv_float("ALPHA", 1.0)
const gamma = getenv_float("GAMMA", 1.0)

const a     = getenv_float("A_LIMITE", 0.0)
const b     = getenv_float("B_LIMITE", 1.0)
const T     = getenv_float("T_LIMITE", 1.0)

const npg   = getenv_int("NPG", 5)
const ne    = getenv_int("NE", 2^5)

const m     = ne - 1
const h     = (b - a) / ne

const tau   = getenv_float("TAU", T / 20)
const N     = trunc(Int, T / tau)


# Quadratura Gauss-Legendre

const P, W = gausslegendre(npg)


# Funções de forma lineares no elemento padrão e derivadas

const φ1(ξ) = (1 - ξ) / 2
const φ2(ξ) = (1 + ξ) / 2
const dφ1(ξ) = -0.5
const dφ2(ξ) = 0.5


# Avaliação das funções de forma nos pontos de Gauss

const φ1P = φ1.(P)
const φ2P = φ2.(P)
const dφ1P = dφ1.(P)
const dφ2P = dφ2.(P)


# Produtos ponderados com pesos para integração vetorizada

const Wφ1P = W .* φ1P
const Wφ2P = W .* φ2P

end
