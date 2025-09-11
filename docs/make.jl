using Documenter
using Typst

makedocs(
    sitename = "Typst.jl",
    format = Documenter.HTML(
        canonical = "https://emf.github.io/Typst.jl",
        edit_link = "main",
        assets = String[],
    ),
    modules = [Typst],
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "User Guide" => [
            "Tables" => "guide/tables.md",
            "Figures" => "guide/figures.md",
            "Regression Tables" => "guide/regression.md",
        ],
        "Examples" => "examples.md",
        "API Reference" => "api.md",
    ],
    checkdocs = :exports,
)

deploydocs(
    repo = "github.com/emf/Typst.jl.git",
    devbranch = "main",
)