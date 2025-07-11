# Uso Básico

## Primeiros Passos

### Carregando o Pacote

```julia
using Heat1DNL
```

### Simulação Simples

A forma mais simples de usar o Heat1DNL.jl é através da função `run_simulation`:

```julia
# Simulação com método vetorizado (padrão)
C, erro = Heat1DNL.run_simulation()
println("Erro L2: $erro")

# Simulação com método serial
C_serial, erro_serial = Heat1DNL.run_simulation(1, :serial)
println("Erro L2 (serial): $erro_serial")
```

## Funções Principais

### `run_simulation`

```julia
C, erro = Heat1DNL.run_simulation(option, method)
```

**Parâmetros:**

- `option` (Int): Opção de condição inicial (1-4, padrão: 1)
- `method` (Symbol): Método de solução (`:serial` ou `:vectorized`, padrão: `:vectorized`)

**Retorna:**

- `C` (Vector{Float64}): Coeficientes da solução final
- `erro` (Float64): Erro L2 entre a solução exata e aproximada

### `run_benchmark`

```julia
results = Heat1DNL.run_benchmark(individual_samples, system_samples)
```

**Parâmetros:**

- `individual_samples` (Int): Amostras para benchmark das funções (padrão: 100)
- `system_samples` (Int): Amostras para benchmark do sistema (padrão: 200)

**Retorna:**

- `results` (Dict): Resultados completos do benchmark

### `demo`

```julia
Heat1DNL.demo()
```

Executa uma demonstração completa incluindo simulação e benchmark.

## Opções de Condição Inicial

O parâmetro `option` determina como a condição inicial é calculada:

1. **Interpolante de u₀** (padrão): Mais rápido, adequado para a maioria dos casos
2. **Projeção L2 de u₀**: Mais preciso, computacionalmente mais caro
3. **Projeção H de u₀**: Para problemas com derivadas importantes
4. **Operador k(u,v)**: Projeção completa, mais preciso mas mais lento

```julia
# Diferentes opções de condição inicial
C1, erro1 = Heat1DNL.run_simulation(1, :vectorized)  # Interpolante
C2, erro2 = Heat1DNL.run_simulation(2, :vectorized)  # Projeção L2
C3, erro3 = Heat1DNL.run_simulation(3, :vectorized)  # Projeção H
C4, erro4 = Heat1DNL.run_simulation(4, :vectorized)  # Operador k(u,v)

println("Erros L2:")
println("Opção 1: $erro1")
println("Opção 2: $erro2")
println("Opção 3: $erro3")
println("Opção 4: $erro4")
```

## Comparação de Métodos

### Serial vs Vetorizado

```julia
using BenchmarkTools

# Benchmark individual
println("Método Serial:")
@time C_serial, erro_serial = Heat1DNL.run_simulation(1, :serial)

println("Método Vetorizado:")
@time C_vectorized, erro_vectorized = Heat1DNL.run_simulation(1, :vectorized)

# Verificar equivalência
diff = maximum(abs.(C_serial - C_vectorized))
println("Diferença máxima: $diff")
println("Métodos equivalentes: $(diff < 1e-12)")
```

## Análise dos Resultados

### Coeficientes da Solução

```julia
C, erro = Heat1DNL.run_simulation()

println("Número de coeficientes: $(length(C))")
println("Valor máximo: $(maximum(C))")
println("Valor mínimo: $(minimum(C))")
println("Norma L2: $(norm(C))")
```

### Visualização (Opcional)

Se você tiver Plots.jl instalado:

```julia
using Plots

# Plotar os coeficientes
C, erro = Heat1DNL.run_simulation()
x = range(0, 1, length=length(C)+2)[2:end-1]  # Pontos internos
plot(x, C, label="Solução Aproximada", xlabel="x", ylabel="u")
```

## Configuração Rápida

### Problemas Pequenos (Teste Rápido)

```julia
# Configurar problema pequeno
ENV["NE"] = "1024"      # 2^10 elementos
ENV["TAU"] = "0.1"      # Passo de tempo maior

# Executar
C, erro = Heat1DNL.run_simulation()
```

### Problemas Grandes (Alta Precisão)

```julia
# Configurar problema grande
ENV["NE"] = "1048576"   # 2^20 elementos
ENV["TAU"] = "0.01"     # Passo de tempo menor

# Executar (pode demorar)
C, erro = Heat1DNL.run_simulation()
```

## Benchmark Rápido

Para uma análise rápida de performance:

```julia
# Benchmark com poucas amostras
results = Heat1DNL.run_benchmark(10, 20)

# Mostrar speedups
speedups = results["speedups"]
println("Speedup da matriz K: $(round(speedups["K"], digits=2))x")
println("Speedup do sistema: $(round(speedups["system"], digits=2))x")
```

## Tratamento de Erros

### Problemas de Memória

```julia
try
    C, erro = Heat1DNL.run_simulation()
    println("Simulação bem-sucedida! Erro: $erro")
catch e
    if isa(e, OutOfMemoryError)
        println("Erro de memória. Tente reduzir NE.")
        ENV["NE"] = "65536"  # Reduzir elementos
        C, erro = Heat1DNL.run_simulation()
    else
        rethrow(e)
    end
end
```

### Verificação de Convergência

```julia
# Testar diferentes discretizações
elementos = [1024, 2048, 4096, 8192]
erros = Float64[]

for ne in elementos
    ENV["NE"] = string(ne)
    C, erro = Heat1DNL.run_simulation()
    push!(erros, erro)
    println("NE = $ne, Erro = $erro")
end

# Verificar convergência
println("Taxa de convergência:")
for i in 2:length(erros)
    taxa = log(erros[i-1]/erros[i]) / log(2)
    println("$(elementos[i-1]) → $(elementos[i]): $(round(taxa, digits=2))")
end
```

## Próximos Passos

- [Configuração](configuration.md): Personalização avançada dos parâmetros
- [Exemplos](examples.md): Exemplos mais detalhados
- [Tutoriais](../tutorials/first_example.md): Tutorial passo a passo
