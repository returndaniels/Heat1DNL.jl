#!/bin/bash

# Script para visualizar a documentação do Heat1DNL.jl

echo "🔥 Heat1DNL.jl - Visualizador de Documentação"
echo "=============================================="

# Verificar se a documentação existe
if [ ! -d "docs/build" ]; then
    echo "❌ Documentação não encontrada. Gerando..."
    cd docs/
    julia --project=. make.jl
    cd ..
    echo "✅ Documentação gerada!"
fi

# Verificar se Python está disponível
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Python não encontrado. Abrindo arquivo diretamente..."
    if command -v xdg-open &> /dev/null; then
        xdg-open docs/build/index.html
    elif command -v open &> /dev/null; then
        open docs/build/index.html
    else
        echo "📁 Abra manualmente: docs/build/index.html"
    fi
    exit 0
fi

# Iniciar servidor HTTP
echo "🌐 Iniciando servidor HTTP local..."
echo "📍 URL: http://localhost:8080"
echo "⏹️  Para parar: Ctrl+C"
echo ""

cd docs/build/
$PYTHON_CMD -m http.server 8080 