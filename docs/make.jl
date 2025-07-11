using Documenter
using Heat1DNL

makedocs(
    sitename = "Heat1DNL.jl",
    authors = "Daniel Silva <returndaniels@gmail.com> e Leonardo Veiga <leo.veiga.filho@gmail.com>",
    format = Documenter.HTML(
        prettyurls = false,
        assets = String[]
    ),
    pages = [
        "Início" => "index.md",
        "Instalação" => "user_guide/installation.md",
        "Uso Básico" => "user_guide/basic_usage.md",
        "API" => "api/heat1dnl.md",
        "Tutorial" => "tutorials/first_example.md",
    ],
    clean = true,
    warnonly = [:missing_docs, :cross_references, :docs_block]
)