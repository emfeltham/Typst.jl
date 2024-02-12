module Typst

#=
Maybe, it would be better to save figures outside and separately call here
to generate the typst content. that way, it would be agnostic, and we wouldn't
need a huge dependency.
=#
import CairoMakie: Figure, save

using DataFrames

# these likely do need to be imported to make things relatively easy
using GLM, StatsAPI, StatsBase, Statistics

include("utilities.jl")
include("types.jl")
include("figure.jl")
include("regtable.jl")

end # module Typst
