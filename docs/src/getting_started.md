# Getting Started

This guide will walk you through the basics of using Typst.jl to generate Typst documents from your Julia code.

## Installation

Add Typst.jl to your Julia environment:

```julia
using Pkg
Pkg.add("Typst")
```

## Basic Usage

### Loading the Package

```julia
using Typst
using DataFrames  # for table examples
```

### Your First Table

The simplest way to get started is by converting a DataFrame to a Typst table:

```julia
# Create sample data
df = DataFrame(
    Name = ["Alice", "Bob", "Charlie"],
    Age = [25, 30, 35],
    Score = [85.5, 92.0, 78.5]
)

# Convert to Typst table
tb = tablex(df)

# Export to .typ file
table_export(
    "my_first_table",  # filename (will create my_first_table.typ)
    tb;
    caption = "Sample data showing names, ages, and scores",
    short_caption = "Sample Data"
)
```

This creates a file `my_first_table.typ` that you can include in your Typst document:

```typst
#include("my_first_table.typ")
```

### Your First Figure

Typst.jl integrates seamlessly with Makie for figure generation:

```julia
using CairoMakie

# Create sample data
x = 1:10
y = rand(10)

# Create plot
fig = Figure()
ax = Axis(fig[1, 1], xlabel = "X Values", ylabel = "Y Values")
scatter!(ax, x, y)

# Export figure and .typ file
figure_export(
    "my_first_plot.png",  # figure filename
    fig,                  # Makie figure
    save;                 # Makie save function
    caption = "A scatter plot of random data",
    short_caption = "Random Scatter"
)
```

This creates:
1. `my_first_plot.png` - the actual image file
2. `my_first_plot.typ` - the Typst code to include the figure

## Understanding the Workflow

Typst.jl follows a two-step workflow:

1. **Generate content in Julia**: Create your tables, figures, and analysis
2. **Export to Typst**: Use Typst.jl functions to generate `.typ` files
3. **Include in Typst document**: Use `#include()` to incorporate into your document

This separation allows you to:
- Run computationally expensive analysis once
- Update documents without re-running analysis
- Version control your analysis separately from your writing
- Collaborate on writing while keeping analysis reproducible

## File Organization

A typical project structure might look like:

```
my-paper/
├── analysis/
│   ├── data_analysis.jl     # Your Julia analysis
│   └── generate_outputs.jl  # Export tables/figures
├── outputs/
│   ├── table1.typ
│   ├── figure1.typ
│   ├── figure1.png
│   └── ...
└── main.typ                 # Your main Typst document
```

Your main Typst document would include outputs like:

```typst
#import "@preview/tablex:0.0.9": *

= Introduction

This paper presents our analysis...

= Results

@table1 shows the main results.

#include("outputs/table1.typ")

The relationship is visualized in @figure1.

#include("outputs/figure1.typ")
```

## Next Steps

- Learn about [Tables](@ref) for more advanced table formatting
- Explore [Figures](@ref) for figure customization options
- See [Regression Tables](@ref) for statistical model output
- Check out complete [Examples](@ref)