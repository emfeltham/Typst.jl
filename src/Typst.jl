module Typst

using Reexport
using DataFrames

# these likely do need to be imported to make things relatively easy
using StatsAPI, StatsBase, Statistics
using StatsModels, GLM, MixedModels
import OrderedCollections:OrderedDict
@reexport using Typstry

import Base.print
using Printf

global typst_version = "\"@preview/tablex:0.0.9\""

include("types.jl")
include("cellx.jl")
include("hlinex.jl")
include("vlinex.jl")
include("figure.jl")
include("utilities.jl")
include("image.jl")
include("tablex.jl")
include("modelinfo.jl")

include("regtable.jl")
include("dataframe.jl")

include("export.jl")

include("markdown.jl")

export print

end # module Typst
