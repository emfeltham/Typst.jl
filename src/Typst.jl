module Typst

#=
Maybe, it would be better to save figures outside and separately call here
to generate the typst content. that way, it would be agnostic, and we wouldn't
need a huge dependency.
-> done
=#
# import CairoMakie: Figure, save

using DataFrames

# these likely do need to be imported to make things relatively easy
using StatsAPI, StatsBase, Statistics
using StatsModels, GLM, MixedModels
import OrderedCollections:OrderedDict

include("utilities.jl")
include("cellx.jl")
include("image.jl")
include("tablex.jl")
include("figure.jl")
include("modelinfo.jl")
include("regtable.jl")

# function tablex(cells)
#     return vcat("tablex( \n", cells, ")\n")
# end

export print

end # module Typst
