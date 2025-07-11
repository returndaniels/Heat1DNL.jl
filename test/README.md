# Testes do Heat1DNL.jl

Este diretório contém a suíte de testes para o pacote Heat1DNL.jl.

## Estrutura dos Testes

### `runtests.jl` - Testes Principais

Contém 10 conjuntos de testes abrangentes:

1. **Testes das Funções Matemáticas** - Verifica correção das funções `u`, `u0`, `du0`, `g`, `f`
2. **Testes de Discretização** - Valida `monta_LG`, `monta_EQ` e estruturas de elementos finitos
3. **Testes de Equivalência Serial vs Vetorizada** - Compara implementações com tolerância de 1e-14
4. **Testes das Condições Iniciais** - Verifica todas as opções de `C0_options`
5. **Testes de Solução Completa** - Valida `solve_heat_equation_serial` e `solve_heat_equation_vectorized`
6. **Testes de Interface Principal** - Testa `run_simulation` e tratamento de erros
7. **Testes de Benchmark** - Verifica sistema de benchmark com poucas amostras
8. **Testes de Propriedades Físicas** - Valida decaimento temporal e conservação de energia
9. **Testes de Robustez** - Verifica estabilidade e consistência
10. **Testes de Configuração** - Valida constantes e parâmetros do `Config`

### `test_convergence.jl` - Testes de Convergência

Testes adicionais focados em:

- **Convergência Espacial** - Verifica que erro diminui com refinamento de malha
- **Estabilidade Temporal** - Testa diferentes passos de tempo
- **Precisão Numérica** - Valida limites de erro e condições de contorno
- **Conservação** - Verifica propriedades de conservação de massa e energia
- **Monotonicidade** - Testa decaimento temporal
- **Performance** - Compara métodos serial vs vetorizado
- **Escalabilidade** - Testa diferentes tamanhos de problema

## Como Executar

### Testes Completos

```bash
# No diretório Heat1DNL.jl/
julia --project=. -e "using Pkg; Pkg.test()"
```

### Teste Simples

```bash
# Para um teste rápido
julia --project=. test_simple.jl
```

### Testes Individuais

```bash
# Apenas testes principais
julia --project=. test/runtests.jl

# Apenas testes de convergência
julia --project=. test/test_convergence.jl
```

## Configuração de Teste

Os testes usam configurações reduzidas para execução rápida:

- `ne_test = 2^8` (ao invés de `2^18` padrão)
- `samples = 5` para benchmarks (ao invés de 100+)
- Tolerâncias rigorosas (1e-12 a 1e-15) para verificar equivalência numérica

## Tolerâncias e Critérios

### Equivalência Numérica

- **Coeficientes**: `max(|C_serial - C_vectorized|) < 1e-12`
- **Erro L2**: `|erro_serial - erro_vectorized| < 1e-12`
- **Matrizes**: `max(|K_serial - K_vectorized|) < 1e-14`

### Propriedades Físicas

- **Erro L2 final**: `< 1e-3` para malha fina
- **Decaimento temporal**: `energia_final < energia_inicial`
- **Condições de contorno**: `|C[bordas]| < 1e-6`

### Performance

- **Speedup**: Medido mas não há limite mínimo exigido
- **Estabilidade**: Todos os valores devem ser finitos
- **Consistência**: Múltiplas execuções devem dar mesmo resultado

## Dependências de Teste

As seguintes dependências são necessárias:

- `Test` (stdlib)
- `LinearAlgebra` (stdlib)
- `SparseArrays` (stdlib)
- Todos os módulos do Heat1DNL.jl

## Solução de Problemas

### Erro "Package Test not found"

Certifique-se de que `Test` está listado em `[extras]` no `Project.toml`:

```toml
[extras]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[targets]
test = ["Test"]
```

### Testes demoram muito

- Use `test_simple.jl` para teste rápido
- Configure `ne` menor nos testes de convergência
- Reduza número de amostras nos benchmarks

### Falhas de precisão

- Verifique se todas as implementações estão sincronizadas
- Confirme que as constantes em `Config` estão corretas
- Valide que não há problemas de compilação

## Cobertura de Testes

Os testes cobrem:

- ✅ Todas as funções exportadas
- ✅ Equivalência entre implementações
- ✅ Propriedades físicas do problema
- ✅ Estabilidade numérica
- ✅ Interface de usuário
- ✅ Sistema de benchmark
- ✅ Tratamento de erros
- ✅ Configuração e parâmetros

## Resultados Esperados

Execução bem-sucedida deve mostrar:

```
🧪 Iniciando testes do Heat1DNL.jl
==================================================
📐 Testando funções matemáticas...
✅ Funções matemáticas: PASSOU
🔢 Testando discretização...
✅ Discretização: PASSOU
...
🎉 Todos os testes concluídos!
```
