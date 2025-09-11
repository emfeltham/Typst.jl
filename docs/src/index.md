# Typst.jl Documentation

*Generate [Typst](https://typst.app/docs) documents from Julia data structures and statistical models.*

```@contents
```

## Introduction

[Typst](https://typst.app/docs) is a new system for markup-based typesetting, touted as an alternative to LaTeX. Typst is desirable as a system that is very fast to compile (near instantaneous live rendering), relatively simple to use with clear and clean syntax, and easily extensible with user-contributed packages.

**Typst.jl** provides a simple set of functions that produce properly formatted Typst documents with captions, labels, and other features that may be easily embedded into larger Typst documents. These documents should be easily updated as models are re-estimated, figures and tables are changed, or reported values in the text change as the research and writing process takes their course.

## Philosophy

The underlying philosophy here is to provide a relatively simple framework that separates program execution from document writing. This avoids the complexity of solutions like Jupyter notebooks (which can be slow and difficult to replicate) or Markdown-based solutions that require conversion chains.

The goal is to provide:
- Ready-made functions common to academic writing workflows (e.g., creating regression tables, including figures)
- General means to customize outputs to Typst documents using simple defined types
- Fast compilation through Typst's near-instantaneous rendering
- Clean, customizable syntax without the complications of LaTeX

## Features

- **DataFrame Tables**: Convert Julia DataFrames to formatted Typst tables
- **Regression Tables**: Generate professional regression tables from statistical models
- **Figure Management**: Export figures with proper captions, labels, and cross-references
- **Makie Integration**: Seamless integration with Makie plotting ecosystem
- **Professional Output**: Support for short captions, figure numbering, and academic formatting

## Quick Example

```julia
using Typst
using DataFrames

# Create a simple table
df = DataFrame(rand(10, 5), :auto)
tb = tablex(df)

table_export(
    "my_table", # filename without extension
    tb;
    short_caption = "Table Cap",
    caption = "This is a simple conversion of a DataFrame to a Typst table.",
)
```

This generates a `.typ` file that can be included in your Typst document with `#include("my_table.typ")`.

## Installation

```julia
using Pkg
Pkg.add("Typst")
```

## Getting Started

See the [Getting Started](@ref) guide for a comprehensive introduction to using Typst.jl.