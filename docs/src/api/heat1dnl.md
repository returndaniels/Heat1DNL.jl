# Módulo Principal

## Visão Geral

O módulo principal `Heat1DNL` fornece as interfaces de alto nível para resolver o problema do calor transiente 1D não-linear.

## Funções Principais

### run_simulation

Executa a simulação da equação do calor.

**Sintaxe:**

```julia
C, erro = Heat1DNL.run_simulation(option=1, method=:vectorized)
```

**Parâmetros:**

- `option` (Int): Opção de inicialização de C0 (1-4, padrão: 1)
- `method` (Symbol): Método de solução (`:serial` ou `:vectorized`, padrão: `:vectorized`)

**Retorna:**

- `C` (Vector{Float64}): Vetor com os coeficientes da solução final
- `erro` (Float64): Erro L2 entre a solução exata e aproximada no tempo final

### run_benchmark

Executa benchmark completo do sistema.

**Sintaxe:**

```julia
results = Heat1DNL.run_benchmark(individual_samples=100, system_samples=200)
```

**Parâmetros:**

- `individual_samples` (Int): Número de amostras para benchmark das funções individuais
- `system_samples` (Int): Número de amostras para benchmark do sistema completo

**Retorna:**

- `results` (Dict): Dicionário com todos os resultados de benchmark

### demo

Executa uma demonstração completa do Heat1DNL.

```julia
Heat1DNL.demo()
```

## Exemplo de Uso

```julia
using Heat1DNL

# Simulação básica
C, erro = run_simulation()
println("Erro L2: $erro")

# Comparação de métodos
C_serial, erro_serial = run_simulation(1, :serial)
C_vectorized, erro_vectorized = run_simulation(1, :vectorized)

# Verificar equivalência
diff = maximum(abs.(C_serial - C_vectorized))
println("Diferença: $diff")

# Benchmark completo
results = run_benchmark(50, 100)
speedups = results["speedups"]
println("Speedup do sistema: $(speedups["system"])x")
```

## Estrutura Interna

O módulo principal coordena os seguintes submódulos:

- **Config**: Configurações e parâmetros
- **Discretization**: Funções de discretização
- **Serialization**: Implementação serial
- **Vectorization**: Implementação vetorizada
- **InitialConditions**: Condições iniciais
- **Solver**: Solver temporal
- **Benchmark**: Sistema de benchmark

## Configuração

O módulo utiliza variáveis de ambiente para configuração. Principais variáveis:

- `NE`: Número de elementos finitos (padrão: 262144)
- `NPG`: Número de pontos de Gauss (padrão: 5)
- `TAU`: Passo temporal (padrão: 0.05)
- `ALPHA`, `BETA`, `GAMMA`: Coeficientes da equação (padrão: 1.0)
