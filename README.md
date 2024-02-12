# Typst.jl
Functions for interfacing julia with the new typesetting language Typst.

## Tables

Tables are built using the [typst-tablex](https://github.com/PgBiel/typst-tablex) package, which allows for the construction of more sophisticated tables than [included in base Typst](https://typst.app/docs/reference/model/table/).

Table construction for Typst is built around structs that correspond to tablex functions, subset under the `TableX` abstract type, including `CellX`, and `HLineX`, which constitute the building blocks of tables.

## Regression table

Example borrowed from [GLM.jl](https://juliastats.org/GLM.jl/stable/examples/).

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

The output contains code that imports the typst-tablex package, and defines two variables that control table column widths, which may be easily altered by the user. The table itself[^`gridx` objects are identical to `tablex` objects, but do not include vertical and horizontal lines by default.] is embedded in a `figure` object, and is specified as a `table` type^[Which is useful if you want to, for example, set captions above the all table objects in your document, but not for other sorts of figures.]

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

This file should be incorporated into your document via ```typst #include("exampletable.typ")```.

## Figure

The package also provides a function to easily write a ".typ" file that will load a corresponding figure, formatted with a caption and label.

```julia
using DataFrames
using CairoMakie

data = DataFrame(X=[1,2,3], Y=[2,4,7], Z = [4,5,6]);

fg, ax, pl = scatter(data.X, data.Y)
```

The function will automatically handle directories on the path. N.B., the figure file extension is included in `filename`. Note also that output ".typ" file to load the figure expects the figure file to appear in the same directory (e.g., below, the "plot.png" should be saved in "dir/").

```julia
filename = "dir/plot.png"
caption = "Plot caption."

figure_typ(
    filename; caption, label = nothing, width_pct = 100
)
```

The following output is produced in "dir/plot.typ":

```typst
#figure(
   image("plot.png", width: 100%),
   caption: [Plot caption.],
) <plot>
```

This file should be incorporated into your document via ```typst #include("dir/plot.typ")```.

## Tasks

- [ ] labels for tables
- [ ] add objects for other tablex functions, e.g., `#vlinex`
- [ ] functions for other kinds of tables (e.g., simple display of an array)
- [ ] documentation for figure export
- [ ] functions to export variables from julia into Typst (e.g., so that the text can reference exported variables that update based on julia code execution)
- [ ] real documentation
- [ ] adjust import statement above to only include functions needed for current table
