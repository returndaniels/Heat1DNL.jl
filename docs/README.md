# Documentação do Heat1DNL.jl

## 📚 Como Gerar a Documentação

Para gerar a documentação localmente:

```bash
cd docs/
julia --project=. make.jl
```

## 🌐 Como Visualizar a Documentação

### Opção 1: Abrir no Navegador

Abra o arquivo `build/index.html` no seu navegador web:

```bash
# Linux/macOS
open build/index.html

# Windows
start build/index.html

# Ou simplesmente navegue até o arquivo e abra com o navegador
```

### Opção 2: Servidor Local

Para uma melhor experiência, use um servidor HTTP local:

```bash
# Python 3
cd build/
python -m http.server 8000

# Python 2
cd build/
python -m SimpleHTTPServer 8000

# Node.js (se tiver npx)
cd build/
npx http-server

# Julia
cd build/
julia -e "using Pkg; Pkg.add(\"HTTP\"); using HTTP; HTTP.serve(HTTP.FileServer(\".\"), \"127.0.0.1\", 8000)"
```

Depois acesse `http://localhost:8000` no navegador.

## 📖 Estrutura da Documentação

A documentação inclui:

- **Início**: Visão geral do projeto
- **Instalação**: Como instalar o Heat1DNL.jl
- **Uso Básico**: Primeiros passos e exemplos simples
- **API**: Documentação das funções principais
- **Tutorial**: Tutorial passo a passo completo

## 🔧 Personalizando a Documentação

Para modificar a documentação:

1. Edite os arquivos `.md` em `src/`
2. Execute `julia --project=. make.jl` para regenerar
3. A documentação atualizada estará em `build/`

## 📝 Adicionando Novas Páginas

1. Crie um novo arquivo `.md` em `src/`
2. Adicione a página no `make.jl` na seção `pages`
3. Regenere a documentação

## 🚀 Deploy Online

Para fazer deploy da documentação online, você pode:

1. **GitHub Pages**: Habilite GitHub Pages no repositório
2. **Netlify**: Faça upload da pasta `build/`
3. **Vercel**: Conecte o repositório
4. **Documenter.jl + GitHub Actions**: Configure CI/CD automático

## ⚠️ Solução de Problemas

### Erro de Compilação

Se encontrar erros ao gerar a documentação:

```bash
# Limpe e reinstale dependências
julia --project=. -e "using Pkg; Pkg.rm(\"Heat1DNL\"); Pkg.develop(path=\"..\")"
julia --project=. make.jl
```

### Links Quebrados

Os warnings sobre links inválidos são normais - indicam que algumas páginas ainda não foram criadas.

### Documentação Vazia

Se a documentação aparecer vazia, verifique se o Heat1DNL.jl está corretamente instalado:

```bash
julia --project=. -e "using Heat1DNL; println(\"✅ OK\")"
```

## 📞 Suporte

Para problemas com a documentação:

- Verifique os logs de erro ao executar `make.jl`
- Consulte a [documentação do Documenter.jl](https://documenter.juliadocs.org/)
- Abra uma issue no repositório
