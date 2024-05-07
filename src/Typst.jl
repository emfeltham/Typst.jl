module Typst

using DataFrames

# these likely do need to be imported to make things relatively easy
using StatsAPI, StatsBase, Statistics
using StatsModels, GLM, MixedModels
import OrderedCollections:OrderedDict

import Base.print

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
