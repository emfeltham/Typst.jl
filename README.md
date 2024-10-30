# Typst.jl
Include [Julia](https://julialang.org) outputs as formatted elements of [Typst](https://typst.app/docs) documents.

## Introduction

[Typst](https://typst.app/docs) is a new system for markup-based typesetting, touted as an alternative to LaTeX. Typst is desirable as a system that is very fast to compile (near instantaneous live rendering), relatively simple to use with clear and clean syntax, and easily extensible with user-contributed packages. It has also recently been [incorporated into Quarto](https://quarto.org/docs/output-formats/typst.html). However, do note that this system is new and limited in various ways (e.g., Typst currently only renders to PDF).

This package will be useful to Julia users engaged in academic and professional writing, and may be a more parsimonious alternative to other common approaches to writing documents that rely on the outputs of programs (e.g, Jupyter[^rdme-1], Markdown-based solutions[^rdme-2], LaTeX).

[^rdme-1]: Which I find to be slow, and difficult to work with. Perhaps more importantly, they have been found [difficult to replicate](https://arxiv.org/abs/2209.04308).

[^rdme-2]: These solutions, e.g., Quarto requires conversion of Markdown to TeX to render to PDF which may complicate detailed formatting, and is consequently subject to slow compilation. While Quarto now supports Typst, users may find that that indirectly producing Typst documents may cause similar complications and may defeat the purpose of Typst's clean user-end syntax and customizability.

The underlying philosophy here is to provide a simple set of functions that produce properly formatted Typst documents with captions, labels, and other features that may be easily embedded into larger Typst documents. These documents should be easily updated as models are re-estimated, figures and tables are changed, or reported values in the text change as the research and writing process take their course. The point is to provide a relatively simple framework, that does [more with less](https://yihui.org/en/2024/01/bye-rstudio/).

The above-mentioned solutions make it possible to do this[^rdme-3]. However, I believe that it is useful to provide an option that does not additionally conflate program execution and writing. Quarto or RMarkdown documents may become unwieldy when execution times extend beyond those of simple toy examples. Generally, one does not want to re-run large models or execute long-running code to render a document. The outputs of programs will reasonably be updated asynchronously in relation to changes to the text.

Subsequently, the goal here is both to provide a set of ready-made functions common to an academic writing workflow (e.g., creating regression tables, including figures) along with more general means to customize outputs to Typst documents (e.g., export a custom table using simple defined types).

[^rdme-3]: Though, the support seems much greater for R than for Julia. For example, it is much more awkward to write Quarto documents that include text that updates based on the values of variables.

## Tables

Tables are built using the [typst-tablex](https://github.com/PgBiel/typst-tablex) package, which allows for the construction of more sophisticated tables than [those made in base Typst](https://typst.app/docs/reference/model/table/).

Table construction for Typst is built around structs that correspond to tablex functions, subset under the `TableX` abstract type, including `CellX`, and `HLineX`, which constitute the building blocks of tables.

## DataFrame

We can convert a DataFrame to a Typst table in the following way:

```julia
df = DataFrame(rand(10, 5), :auto)
tb = tablex(df)

table_export(
    filepathname, # without extension (will be suffixed with ".typ")
    tb;
    short_caption = "Table Cap",
    caption = "This is a simple conversion of a DataFrame to a typst table.",
);
```

This will produce a file, `filepathname`, with suffix ".typ" that contains the formatted Typst table.

## Regression tables[^rdme-4]

[^rdme-4]: Example adapted from [GLM.jl](https://juliastats.org/GLM.jl/stable/examples/).

Set up simple data set, and execute OLS.

```{julia}
using Typst
using DataFrames
using GLM

data = DataFrame(X=[1,2,3], Y=[2,4,7], Z = [4,5,6])

ols1 = lm(@formula(Y ~ X), data)
ols2 = lm(@formula(Y ~ Z), data)
ols3 = lm(@formula(Y ~ X + Z), data)

ms = [ols1, ols2, ols3];
```

Construct a formatted regression table for Typst:

```{julia}
regtable_typ(
    ms, "exampletable";
    caption = "Models of Y."
)
```

Produces the following output saved to a specified ".typ file (here, "exampletable.typ"):

The output contains code that imports the typst-tablex package, and defines two variables that control table column widths, which may be easily altered by the user. The table itself[^rdme-5] is embedded in a `figure` object, and is specified as a `table` type[^rdme-6].

[^rdme-5]: `gridx` objects are identical to `tablex` objects, but do not include vertical and horizontal lines by default.

[^rdme-6]: Which is useful if you want to, for example, set captions above the all table objects in your document, but not for other sorts of figures.

```{typst}
#import"@preview/tablex:0.0.8": tablex, gridx, hlinex, vlinex, colspanx, rowspanx, cellx
#let col1width = 12em
#let coliwidth = auto

#figure( 
    kind: table, 
    gridx( 
        columns: (col1width, coliwidth, coliwidth, coliwidth, ), 
        rows: (0.2em, 1.5em), 
        align: center + horizon, 
        hlinex(y: 0, stroke: 0.05em), 
        cellx(x: 0, y: 0, colspan: 4)[], 
        hlinex(y: 1, stroke: 0.05em), 
        cellx(x: 1, y: 1)[(1)], 
        cellx(x: 2, y: 1)[(2)], 
        cellx(x: 3, y: 1)[(3)], 
        hlinex(start: 1, y: 2, stroke: 0.05em), 
        cellx(x: 0, y: 6, align: left)[Z], 
        cellx(x: 2, y: 6)[2.5#super[$+$]], 
        cellx(x: 2, y: 7)[(0.289)], 
        cellx(x: 3, y: 6)[-0.222], 
        cellx(x: 3, y: 7)[(0.208)], 
        cellx(x: 0, y: 4, align: left)[X], 
        cellx(x: 1, y: 4)[2.5#super[$+$]], 
        cellx(x: 1, y: 5)[(0.289)], 
        cellx(x: 3, y: 4)[2.722], 
        cellx(x: 3, y: 5)[(0.487)], 
        cellx(x: 0, y: 2, align: left)[(Intercept)], 
        cellx(x: 1, y: 2)[-0.667], 
        cellx(x: 1, y: 3)[(0.624)], 
        cellx(x: 2, y: 2)[-8.167], 
        cellx(x: 2, y: 3)[(1.462)], 
        cellx(x: 3, y: 2)[0.0], 
        cellx(x: 3, y: 3)[(NaN)], 
        hlinex(start: 1, y: 8, stroke: 0.05em), 
        cellx(x: 0, y: 8, align: left)[N], 
        cellx(x: 0, y: 12, align: left)[BIC], 
        cellx(x: 0, y: 9, align: left)[$R^2$], 
        cellx(x: 0, y: 11, align: left)[AIC], 
        cellx(x: 0, y: 10, align: left)[Adjusted $R^2$], 
        cellx(x: 1, y: 8)[3], 
        cellx(x: 1, y: 12)[3.138], 
        cellx(x: 1, y: 9)[0.987], 
        cellx(x: 1, y: 11)[5.843], 
        cellx(x: 1, y: 10)[0.974], 
        cellx(x: 2, y: 8)[3], 
        cellx(x: 2, y: 12)[3.138], 
        cellx(x: 2, y: 9)[0.987], 
        cellx(x: 2, y: 11)[5.843], 
        cellx(x: 2, y: 10)[0.974], 
        cellx(x: 3, y: 8)[3], 
        cellx(x: 3, y: 12)[3.138], 
        cellx(x: 3, y: 9)[0.987], 
        cellx(x: 3, y: 11)[5.843], 
        cellx(x: 3, y: 10)[0.974], 
        hlinex(y: 13, stroke: 0.1em), 
        cellx(y: 13, colspan: 4, align: left)[_Note:_ $#super[+]p<0.10$; $#super[$star.op$]p<0.05$; $#super[$star.op star.op$]p<0.01$, $#super[$star.op star.op star.op$]p<0.001$] 
    ), 
    caption: [Models of Y.]
)
```

This file should be incorporated into your document via `#include("exampletable.typ")`.

## Figures

The package also provides a function to easily write a ".typ" file that will load a corresponding figure, formatted with a caption and label.

```julia
using DataFrames
using CairoMakie

data = DataFrame(X=[1,2,3], Y=[2,4,7], Z = [4,5,6]);

fg, ax, pl = scatter(data.X, data.Y)
```

The function will automatically handle directories on the path. N.B., the figure file extension is included in `filenamepath`. Also observe that the output ".typ" file to load the figure expects the figure file to appear in the same directory (in the example below, the "plot.svg" should be saved in "dir/"). `export_figure` will automatically save them in the same place.

```julia
filenamepath = "dir/plot.svg"
caption = "Plot caption.",
short_caption = "Cap"

#=
If desired, define a modified version of the Makie `save` function with whatever specified options. Otherwise,
just input `save`.
=#
@inline save2(name, fg) = save(name, fg; pt_per_unit = 2)

# Short captions are used in the list of figures or the list of tables
short_caption = "Effect of village size above or below 150"
# Long captions appear with the figure itself
caption = "(a) Effect of village size above or below Dunbar's number with respect to accuracy in network cognition. LHS: Grey bands that surround the effect estimates represent bootstrapped 95% confidence ellipses. RHS: Bands represent 95% confidence intervals (see Methods for details). (b) Distribution of village sizes, with Dunbar's number (150) (yellow line) and average size (black line)."

#= generate two files
(1) a ".typ" that includes figure information for Typst, and
(2) the image file (e.g., "plot.svg") that is called in the ".typ" file.
=#
figure_export(
    filenamepath,
    fg, # Makie figure
    save2; # Makie save function
    caption,
    short_caption,
)
end
```

The following output is produced in "dir/plot.typ":

```typst
#figure(
    image("plot.png", width: 100%),
    caption: flex-caption(
	     [Plot caption.],
	     [Cap]
    )
) <plot>
```

This file should be incorporated into your document via `#include("dir/plot.typ")`.

## Tasks

- [/] real and updated documentation (the documentation is **not** current)
  - [/] updated for figure export
  - [/] DataFrame export
  - [ ] update regression table export
- [ ] update examples to match code changes (N.B., the examples are very out of date and not correct)
- [X] short captions
- [ ] integrate [Typstry.jl](https://github.com/jakobjpeters/Typstry.jl)

### Regression tables

- [X] basic support for MixedModels
- [X] labels
- [X] better alignment
- [ ] improve table row spacing

### Tables

- [X] objects for other tablex functions
  - [X] `vlinex`
  - [ ] `rowspanx`, `colspanx`
- [ ] functions for other kinds of tables
  - [X] simple display of an array, DataFrame
- [ ] NamedArrays
- [X] `gridx` option (cf. `autolines`)
- [ ] adjust import statement above to only include functions needed for current table
- [ ] option to include tables with tablecomponents not explicitly indexed by (x, y)
- [ ] regularize regression table with table_export workflow

### Figures

- [X] figure export function
- [ ] documentation for figure export

### Dynamic text

- [ ] export variables from Julia into Typst (_e.g._, so that the text can reference exported variables that update based on Julia code execution) (probably use dicts)

### Types

- [X] define types to hold contents relevant Typst functions, start with those relevant to table and figure production (they should have same print workflow)
