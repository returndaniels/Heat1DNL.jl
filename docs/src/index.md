# Heat1DNL.jl

**Heat1DNL.jl** é um pacote Julia para resolver numericamente o problema do calor transiente unidimensional não-linear usando o método dos elementos finitos. O projeto implementa e compara duas abordagens: **serial** (laços explícitos) e **vetorizada** (operações matriciais otimizadas).

## 🔥 Características Principais

- **Método dos Elementos Finitos 1D**: Implementação completa com funções de forma lineares
- **Problema Não-Linear**: Suporte a termos não-lineares na equação diferencial
- **Integração Temporal**: Esquema implícito de diferenças finitas
- **Quadratura de Gauss**: Integração numérica precisa
- **Duas Implementações**:
  - **Serial**: Laços explícitos para máxima clareza
  - **Vetorizada**: Operações matriciais otimizadas para performance
- **Benchmarking Completo**: Comparação detalhada de performance
- **Configuração Flexível**: Parâmetros configuráveis via variáveis de ambiente

## 📋 Equação Diferencial

O pacote resolve a seguinte equação diferencial parcial:

```math
\frac{\partial u}{\partial t} - \alpha \nabla^2 u + \beta \nabla u + \gamma u + g(u) = f(x,t)
```

Com condições de contorno homogêneas:

- `u(0,t) = 0`
- `u(1,t) = 0`

E condição inicial:

- `u(x,0) = u_0(x)`

Onde:

- `\alpha`, `\beta`, `\gamma` são coeficientes da equação
- `g(u)` é uma função não-linear (por padrão: `g(u) = u^3 - u`)
- `f(x,t)` é o termo fonte

## 🚀 Início Rápido

### Instalação

```julia
using Pkg
Pkg.add(url="https://github.com/seu-usuario/Heat1DNL.jl")
```

### Uso Básico

```julia
using Heat1DNL

# Executar simulação com método vetorizado
C, erro = Heat1DNL.run_simulation(1, :vectorized)
println("Erro L2: $erro")

# Executar benchmark completo
results = Heat1DNL.run_benchmark(100, 200)

# Demonstração completa
Heat1DNL.demo()
```

## 📚 Documentação

Esta documentação está organizada nas seguintes seções:

- **Guia do Usuário**: Como instalar e usar o pacote
- **Manual de Referência**: Documentação detalhada de todas as funções
- **Tutoriais**: Exemplos práticos passo a passo

## 🔧 Funções Principais

### run_simulation

Executa a simulação da equação do calor.

**Sintaxe:**

```julia
C, erro = run_simulation(option=1, method=:vectorized)
```

**Parâmetros:**

- `option`: Opção de inicialização de C0 (1-4, padrão: 1)
- `method`: Método de solução (`:serial` ou `:vectorized`, padrão: `:vectorized`)

**Retorna:**

- `C`: Vetor com os coeficientes da solução final
- `erro`: Erro L2 entre a solução exata e aproximada no tempo final

### run_benchmark

Executa benchmark completo do sistema.

**Sintaxe:**

```julia
results = run_benchmark(individual_samples=100, system_samples=200)
```

### demo

Executa uma demonstração completa do Heat1DNL.

```julia
Heat1DNL.demo()
```

## 📊 Performance Típica

### Speedups Esperados

- **Matriz K**: 2-5x
- **Vetor F**: 3-8x
- **Vetor G**: 2-6x
- **Sistema Completo**: 2-4x

### Precisão

- **Erro L2**: ~10⁻⁶ (dependendo da discretização)
- **Diferença Serial vs Vetorizada**: <10⁻¹²

## 👨‍💻 Autores

- **Daniel Silva** - [returndaniels@gmail.com](mailto:returndaniels@gmail.com)
- **Leonardo Veiga** - [leo.veiga.filho@gmail.com](mailto:leo.veiga.filho@gmail.com)

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.

---

Para começar, veja o Guia do Usuário ou explore os Tutoriais para exemplos práticos.
