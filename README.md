# Heat1DNL.jl

[![Julia](https://img.shields.io/badge/Julia-1.11+-blue.svg)](https://julialang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Heat1DNL.jl** é um pacote Julia para resolver numericamente o problema do calor transiente unidimensional não-linear usando o método dos elementos finitos. O projeto implementa e compara duas abordagens: **serial** (laços explícitos) e **vetorizada** (operações matriciais otimizadas).

## 🔥 Características

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

```
∂u/∂t - α∇²u + β∇u + γu + g(u) = f(x,t)
```

Com condições de contorno homogêneas:

- u(0,t) = 0
- u(1,t) = 0

E condição inicial:

- u(x,0) = u₀(x)

## 🚀 Instalação

```julia
# No REPL do Julia
using Pkg
Pkg.add(url="https://github.com/returndaniels/Heat1DNL.jl")

# Ou clone o repositório
git clone https://github.com/returndaniels/Heat1DNL.jl.git
cd Heat1DNL.jl
julia --project=.
```

## 📖 Uso Básico

### Simulação Simples

```julia
using Heat1DNL

# Executar simulação com método vetorizado
C, erro = Heat1DNL.run_simulation(1, :vectorized)

# Executar simulação com método serial
C, erro = Heat1DNL.run_simulation(1, :serial)
```

## 🛠️ Desenvolvimento Local com `Pkg.develop`

Se você pretende modificar o código do pacote e testar localmente, a melhor prática é usar o modo _develop_ do Julia, que cria um link simbólico para o diretório local do pacote, facilitando atualizações sem precisar reinstalar.

No REPL do Julia, faça:

```julia
using Pkg

# Registre o pacote localmente para desenvolvimento
Pkg.develop(path="/caminho/para/Heat1DNL.jl")

# (Opcional, mas recomendado) Instale Revise para recarregar mudanças automaticamente
Pkg.add("Revise")
using Revise

# Agora carregue o pacote normalmente
using Heat1DNL
```

Com isso:

- Toda alteração no código dentro da pasta `/caminho/para/Heat1DNL.jl` será refletida automaticamente (especialmente com Revise).
- Você não precisa reinstalar ou reiniciar a sessão Julia após cada modificação.
- Facilita testes rápidos e desenvolvimento contínuo.

---

### Benchmark Completo

```julia
# Executar benchmark completo
results = Heat1DNL.run_benchmark(100, 200)

# Ou usar a função de demonstração
Heat1DNL.demo()
```

### Exemplo Detalhado

```julia
using Heat1DNL

# Configurar simulação
option = 1  # Opção de condição inicial
method = :vectorized  # ou :serial

# Executar simulação
println("Executando simulação...")
C, erro = Heat1DNL.run_simulation(option, method)

println("Erro L2 final: $erro")
println("Número de coeficientes: $(length(C))")

# Executar benchmark
println("Executando benchmark...")
benchmark_results = Heat1DNL.run_benchmark(50, 100)

# Analisar speedups
speedups = benchmark_results["speedups"]
println("Speedup do sistema: $(speedups["system"])x")
```

## ⚙️ Configuração

O projeto usa variáveis de ambiente para configuração. Crie um arquivo `.env` no diretório onde irá rodar o projeto:

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

## 🏗️ Estrutura do Projeto

```
Heat1DNL.jl/
├── src/
│   ├── Heat1DNL.jl           # Módulo principal
│   ├── Config.jl             # Configurações e parâmetros
│   ├── Discretization.jl     # Funções de discretização
│   ├── Serialization.jl      # Implementação serial
│   ├── Vectorization.jl      # Implementação vetorizada
│   ├── InitialConditions.jl  # Condições iniciais
│   ├── Solver.jl             # Solver temporal
│   ├── Benchmark.jl          # Sistema de benchmark
│   └── utils/
│       ├── env.jl            # Utilitários de ambiente
│       └── benchmark.jl      # Utilitários de benchmark
├── examples/
│   └── benchmark_example.jl  # Exemplo de uso
├── test/
│   └── runtests.jl          # Testes automatizados
├── docs/                     # Documentação
└── Project.toml             # Dependências
```

## 🔧 Módulos Principais

### Config.jl

- Carrega configurações de variáveis de ambiente
- Define parâmetros físicos e de discretização
- Pré-calcula constantes de quadratura de Gauss

### Discretization.jl

- Funções da solução exata e condições de contorno
- Mapeamento local-global de elementos finitos
- Funções de forma e suas derivadas

### Serialization.jl

- Implementação serial com laços explícitos
- Montagem de matrizes elemento por elemento
- Integração numérica ponto a ponto

### Vectorization.jl

- Implementação vetorizada otimizada
- Operações matriciais em lote
- Uso eficiente de cache e SIMD

### Solver.jl

- Integração temporal implícita
- Resolução de sistemas lineares
- Tratamento de não-linearidades

### Benchmark.jl

- Comparação de performance serial vs vetorizada
- Análise de speedup detalhada
- Verificação de correção dos resultados

## 📊 Resultados Esperados

### Performance Típica

- **Speedup da Matriz K**: 2-5x
- **Speedup do Vetor F**: 3-8x
- **Speedup do Vetor G**: 2-6x
- **Speedup do Sistema**: 2-4x

### Precisão

- **Erro L2**: ~10⁻⁶ (dependendo da discretização)
- **Diferença Serial vs Vetorizada**: <10⁻¹²

## 🧪 Testes

```julia
# Executar testes
using Pkg
Pkg.test("Heat1DNL")

# Ou manualmente
include("test/runtests.jl")
```

## 📚 Documentação

### Visualizar Documentação

```bash
# Opção 1: Script automático
./view_docs.sh

# Opção 2: Manual
cd docs/
julia --project=. make.jl
cd build/
python3 -m http.server 8080
# Acesse: http://localhost:8080
```

A documentação inclui:

- 📖 Guia de instalação e uso
- 🔧 Referência completa da API
- 📝 Tutoriais passo a passo
- 🚀 Exemplos práticos

## 📚 Dependências

- **Julia**: 1.11+
- **LinearAlgebra**: Álgebra linear
- **SparseArrays**: Matrizes esparsas
- **StaticArrays**: Arrays estáticos
- **FastGaussQuadrature**: Quadratura de Gauss
- **BenchmarkTools**: Benchmarking preciso
- **DotEnv**: Variáveis de ambiente
- **Documenter**: Geração de documentação

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Daniel Silva** - [returndaniels@gmail.com](mailto:returndaniels@gmail.com)
**Leonardo Veiga** - [leo.veiga.filho@gmail.com](mailto:leo.veiga.filho@gmail.com)

## 🙏 Agradecimentos

- Comunidade Julia pela excelente linguagem
- Desenvolvedores das bibliotecas utilizadas
- Contribuidores e testadores do projeto

---

**Heat1DNL.jl** - Simulação eficiente da equação do calor não-linear 🔥
