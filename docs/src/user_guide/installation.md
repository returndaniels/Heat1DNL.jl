# Instalação

## Requisitos

- **Julia**: Versão 1.8 ou superior
- **Sistema Operacional**: Windows, macOS, ou Linux
- **Memória**: Mínimo 8GB RAM (recomendado 16GB para problemas grandes)

## Instalação do Pacote

### Opção 1: Instalação via Git (Recomendada)

```julia
using Pkg
Pkg.add(url="https://github.com/seu-usuario/Heat1DNL.jl")
```

### Opção 2: Instalação Local

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/Heat1DNL.jl.git
cd Heat1DNL.jl
```

2. Ative o ambiente do projeto:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Verificação da Instalação

Para verificar se a instalação foi bem-sucedida:

```julia
using Heat1DNL
println("✅ Heat1DNL carregado com sucesso!")

# Teste básico
C, erro = Heat1DNL.run_simulation(1, :vectorized)
println("Erro L2: $erro")
```

## Dependências

O Heat1DNL.jl depende dos seguintes pacotes Julia:

- **LinearAlgebra**: Operações de álgebra linear
- **SparseArrays**: Matrizes esparsas
- **StaticArrays**: Arrays estáticos para performance
- **FastGaussQuadrature**: Quadratura de Gauss-Legendre
- **BenchmarkTools**: Ferramentas de benchmark
- **DotEnv**: Carregamento de variáveis de ambiente

Todas as dependências são instaladas automaticamente.

## Configuração Inicial

### Arquivo de Configuração (Opcional)

Crie um arquivo `.env` na raiz do projeto para personalizar os parâmetros:

```bash
# Parâmetros físicos
ALPHA=1.0
BETA=1.0
GAMMA=1.0

# Domínio
A_LIMITE=0.0
B_LIMITE=1.0
T_LIMITE=1.0

# Discretização
NE=262144          # Número de elementos (2^18)
NPG=5              # Pontos de Gauss
TAU=0.05           # Passo temporal

# Benchmark
SAMPLES=1000000    # Amostras para validação
```

### Variáveis de Ambiente

Se não houver arquivo `.env`, o sistema usará valores padrão apropriados.

## Solução de Problemas

### Erro de Compilação

Se encontrar erros durante a compilação:

```julia
using Pkg
Pkg.build("Heat1DNL")
```

### Problemas de Memória

Para problemas grandes (NE > 10⁶), considere:

1. Aumentar a memória disponível para Julia:

```bash
julia --heap-size-hint=8G
```

2. Reduzir o número de elementos:

```julia
ENV["NE"] = "65536"  # 2^16 elementos
```

### Verificação de Performance

Para verificar se o sistema está otimizado:

```julia
using Heat1DNL
results = Heat1DNL.run_benchmark(10, 20)  # Teste rápido
```

Speedups típicos:

- Sistema completo: 2-4x
- Funções individuais: 2-8x

## Próximos Passos

Após a instalação, consulte:

- [Uso Básico](basic_usage.md): Como usar o pacote
- [Configuração](configuration.md): Personalização avançada
- [Exemplos](examples.md): Exemplos práticos
