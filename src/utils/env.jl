using DotEnv

"""
    load_env_manual(env_path::AbstractString)

Carrega variáveis do arquivo `.env` no `ENV` global, linha a linha, no formato `VAR=VAL`.
Ignora linhas vazias e comentários (#).
Não suporta export, aspas ou multilinhas.

"""
function load_env_manual(env_path::AbstractString)
    if !isfile(env_path)
        println("Arquivo .env não encontrado em: $env_path")
        return
    end

    for line in eachline(env_path)
        line_strip = strip(line)
        if isempty(line_strip) || startswith(line_strip, "#")
            continue
        end
        split_idx = findfirst(isequal('='), line_strip)
        if split_idx === nothing
            continue
        end
        key = strip(line_strip[1:split_idx-1])
        val = strip(line_strip[split_idx+1:end])
        if isempty(key) || isempty(val)
            continue
        end
        ENV[key] = val
    end
end


"""
    getenv_float(var::String, default::Float64)

Lê uma variável de ambiente com o nome `var` e tenta convertê-la para um `Float64`. Se a variável
não existir ou não for válida (não puder ser convertida para `Float64`), retorna o valor padrão fornecido.

# Parâmetros
- `var::String`: O nome da variável de ambiente a ser lida.
- `default::Float64`: O valor padrão a ser retornado em caso de erro de leitura ou conversão.

# Retorna
- `Float64`: O valor da variável de ambiente como `Float64`, ou o valor padrão se ocorrer um erro.

# Exemplo
```julia
valor = getenv_float("MY_FLOAT_VAR", 3.14)
````

"""
function getenv_float(var::String, default::Float64)
    try
        return parse(Float64, get(ENV, var, string(default)))
    catch
        @warn "Variável de ambiente $var inválida (esperado Float64). Usando valor padrão: $default"
        return default
    end
end

"""
getenv_int(var::String, default::Int)

Lê uma variável de ambiente com o nome `var` e tenta convertê-la para um `Int`. Se a variável
não existir ou não for válida (não puder ser convertida para `Int`), retorna o valor padrão fornecido.

# Parâmetros

* `var::String`: O nome da variável de ambiente a ser lida.
* `default::Int`: O valor padrão a ser retornado em caso de erro de leitura ou conversão.

# Retorna

* `Int`: O valor da variável de ambiente como `Int`, ou o valor padrão se ocorrer um erro.

# Exemplo

```julia
valor = getenv_int("MY_INT_VAR", 42)
```

"""
function getenv_int(var::String, default::Int)
    try
        return parse(Int, get(ENV, var, string(default)))
    catch
        @warn "Variável de ambiente $var inválida (esperado Int). Usando valor padrão: $default"
        return default
    end
end