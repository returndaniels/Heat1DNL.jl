# Primeiro Exemplo

Este tutorial guia você através do seu primeiro uso do Heat1DNL.jl, desde a instalação até a análise dos resultados.

## Passo 1: Instalação

Primeiro, certifique-se de que o Julia está instalado (versão 1.8+) e instale o Heat1DNL.jl:

```julia
using Pkg
Pkg.add(url="https://github.com/seu-usuario/Heat1DNL.jl")
```

## Passo 2: Carregamento do Pacote

```julia
using Heat1DNL
```

Se não houver erros, o pacote foi carregado com sucesso!

## Passo 3: Primeira Simulação

Vamos executar nossa primeira simulação com configurações padrão:

```julia
# Executar simulação com método vetorizado
C, erro = Heat1DNL.run_simulation()

println("✅ Simulação concluída!")
println("Número de coeficientes: $(length(C))")
println("Erro L2: $erro")
```

**Saída esperada:**

```
🔥 Heat1DNL - Simulação da Equação do Calor Transiente 1D
============================================================
Configuração:
  - Domínio: [0.0, 1.0] × [0, 1.0]
  - Elementos: 262144
  - Pontos de Gauss: 5
  - Passo espacial: 3.814697265625e-6
  - Passo temporal: 0.05
  - Passos de tempo: 20
  - Método: vectorized
  - Opção C0: 1
============================================================
Executando simulação com método vetorizado...

✅ Simulação concluída!
Erro L2 final: 1.234567e-6
```

## Passo 4: Comparação de Métodos

Agora vamos comparar os métodos serial e vetorizado:

```julia
println("Comparando métodos...")

# Método serial
println("\n1. Executando método serial:")
@time C_serial, erro_serial = Heat1DNL.run_simulation(1, :serial)

# Método vetorizado
println("\n2. Executando método vetorizado:")
@time C_vectorized, erro_vectorized = Heat1DNL.run_simulation(1, :vectorized)

# Verificar se são equivalentes
diff_coeff = maximum(abs.(C_serial - C_vectorized))
diff_erro = abs(erro_serial - erro_vectorized)

println("\n📊 Resultados:")
println("Erro L2 (serial): $erro_serial")
println("Erro L2 (vetorizado): $erro_vectorized")
println("Diferença máxima nos coeficientes: $diff_coeff")
println("Diferença no erro: $diff_erro")

if diff_coeff < 1e-12 && diff_erro < 1e-12
    println("✅ Métodos são numericamente equivalentes!")
else
    println("❌ Métodos apresentam diferenças significativas!")
end
```

## Passo 5: Análise dos Resultados

Vamos analisar os coeficientes obtidos:

```julia
# Estatísticas básicas
println("\n📈 Análise dos Coeficientes:")
println("Número de coeficientes: $(length(C))")
println("Valor máximo: $(maximum(C))")
println("Valor mínimo: $(minimum(C))")
println("Valor médio: $(sum(C)/length(C))")
println("Norma L2: $(norm(C))")

# Verificar propriedades físicas
if maximum(C) > 0 && minimum(C) < maximum(C)
    println("✅ Solução fisicamente plausível")
else
    println("⚠️  Verificar solução")
end
```

## Passo 6: Visualização (Opcional)

Se você tiver o Plots.jl instalado:

```julia
using Plots

# Criar pontos x correspondentes aos coeficientes
h = 1.0 / (length(C) + 1)  # Passo espacial
x_points = range(h, 1-h, length=length(C))

# Plotar a solução
plot(x_points, C,
     label="Solução Aproximada",
     xlabel="x",
     ylabel="u(x,T)",
     title="Solução da Equação do Calor em t=T",
     linewidth=2)

# Adicionar solução exata para comparação
x_exact = range(0, 1, length=1000)
u_exact = [Heat1DNL.Discretization.u(x, 1.0) for x in x_exact]
plot!(x_exact, u_exact,
      label="Solução Exata",
      linestyle=:dash,
      linewidth=2)

# Salvar o gráfico
savefig("solucao_heat1d.png")
println("📊 Gráfico salvo como 'solucao_heat1d.png'")
```

## Passo 7: Benchmark Básico

Vamos fazer um benchmark rápido para ver o speedup:

```julia
println("\n🏃 Executando benchmark rápido...")

# Benchmark com poucas amostras para ser rápido
results = Heat1DNL.run_benchmark(10, 20)

# Extrair speedups
speedups = results["speedups"]
println("\n🚀 Speedups obtidos:")
println("  - Matriz K: $(round(speedups["K"], digits=2))x")
println("  - Vetor F: $(round(speedups["F"], digits=2))x")
println("  - Vetor G: $(round(speedups["G"], digits=2))x")
println("  - Sistema completo: $(round(speedups["system"], digits=2))x")

# Interpretação dos resultados
system_speedup = speedups["system"]
if system_speedup > 2.0
    println("✅ Excelente speedup! Vetorização muito eficaz.")
elseif system_speedup > 1.5
    println("✅ Bom speedup! Vetorização eficaz.")
elseif system_speedup > 1.1
    println("⚠️  Speedup moderado. Verifique configuração do sistema.")
else
    println("❌ Speedup baixo. Possível problema de configuração.")
end
```

## Passo 8: Teste com Problema Menor

Para testes mais rápidos, você pode usar um problema menor:

```julia
println("\n🔧 Testando com problema menor...")

# Configurar problema pequeno
ENV["NE"] = "4096"      # 2^12 elementos
ENV["TAU"] = "0.1"      # Passo de tempo maior

# Executar simulação
@time C_small, erro_small = Heat1DNL.run_simulation()
println("Erro L2 (problema pequeno): $erro_small")

# Restaurar configuração padrão
ENV["NE"] = "262144"    # 2^18 elementos
ENV["TAU"] = "0.05"     # Passo de tempo padrão
```

## Resumo

Neste tutorial, você aprendeu a:

1. ✅ Instalar e carregar o Heat1DNL.jl
2. ✅ Executar sua primeira simulação
3. ✅ Comparar métodos serial e vetorizado
4. ✅ Analisar os resultados obtidos
5. ✅ Visualizar a solução (opcional)
6. ✅ Fazer benchmark básico
7. ✅ Configurar problemas de diferentes tamanhos

## Próximos Passos

Agora que você domina o básico, explore:

- [Benchmark Completo](benchmark.md): Análise detalhada de performance
- [Análise de Performance](performance.md): Otimização avançada
- [Configuração](../user_guide/configuration.md): Personalização de parâmetros

## Solução de Problemas

### Erro de Memória

```julia
# Se encontrar OutOfMemoryError, reduza o número de elementos:
ENV["NE"] = "16384"  # 2^14 elementos
```

### Simulação Muito Lenta

```julia
# Para testes rápidos, use:
ENV["NE"] = "1024"   # Poucos elementos
ENV["TAU"] = "0.2"   # Menos passos de tempo
```

### Verificar Instalação

```julia
# Teste simples para verificar se tudo funciona:
try
    C, erro = Heat1DNL.run_simulation()
    println("✅ Instalação OK!")
catch e
    println("❌ Erro: $e")
end
```
