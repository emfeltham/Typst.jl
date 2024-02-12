# figure_example.jl


using DataFrames
using CairoMakie

data = DataFrame(X=[1,2,3], Y=[2,4,7], Z = [4,5,6]);

fg, ax, pl = scatter(data.X, data.Y)


#=
The function will automatically handle directories on the path. N.B., the figure file extension is included in `filename`. Note also that output ".typ" file to load the figure expects the figure file to appear in the same directory (e.g., below, the "plot.png" should be saved in "dir/").
=#

filename = "dir/plot.png"
caption = "Plot caption."

figure_typ(
    filename; caption, label = nothing, width_pct = 100
)

