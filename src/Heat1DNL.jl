module Heat1DNL

# Importação dos módulos necessários
using .Config
using .Discretization
using .Vectorization
using .Serialization
using .utils.benchmark
using LinearAlgebra

# Função principal (exemplo)
function run_simulation()
    # Inicializando os parâmetros a partir da configuração
    ne = Config.ne
    m = Config.m
    h = Config.h
    tau = Config.tau
    npg = Config.npg

    # Definindo a função de força externa, solução exata, etc.
    f(x) = sin(pi * x)  # Exemplo de função f
    u(x) = sin(pi * x)  # Exemplo de solução exata

    # Discretização e montagem de matrizes
    EQoLG = Discretization.local_to_global_mapping(ne)
    K = Serialization.K_serial(ne, m, h, npg, Config.alpha, Config.beta, Config.gamma, EQoLG)
    F_ext = zeros(Float64, m+1)

    # Resolver o sistema
    # Aqui você pode adicionar a solução do sistema, por exemplo:
    # C = solve(K, F_ext)  # exemplo de resolução de um sistema linear

    # Calcular erro, se necessário
    erro = Serialization.erro_serial(u, Config.P, ne, m, h, npg, C, EQoLG)
    # println("Erro: ", erro)

    # Benchmarking
    # result = benchmark(Heat1DNL.run_simulation, ())
    # println("Tempo de execução: ", result)

    # Visualização dos resultados
    # Por exemplo, pode gerar um gráfico da solução
    # plot_solution(C)
end

# Rodar a simulação
run_simulation()

end # module
