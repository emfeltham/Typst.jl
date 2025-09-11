# runtests.jl
# julia --project="." -e "import Pkg; Pkg.test()" > test/test.txt 2>&1

using Test
using Typst
using DataFrames
using GLM
using MixedModels
using Statistics

# Import internal types and functions for testing  
import Typst: ModelInfo, regtable_typ, _modelinfos!

# Import statistical functions from StatsAPI/StatsBase (they're re-exported by Typst)
import StatsAPI: nobs, r2, adjr2, aic, bic

# Test files to include
test_files = [
    "test_simple.jl",      # Basic functionality tests
    "test_types.jl",       # Core type system
    "test_utilities.jl",   # Utility functions (including bugs)
    "test_cellx.jl",       # Cell components (API issues)
    "test_hlinex.jl",      # Horizontal lines
    "test_vlinex.jl",      # Vertical lines
    "test_tablex.jl",      # Table construction
    "test_dataframe.jl",   # DataFrame integration
    "test_figure.jl",      # Figure handling
    "test_image.jl",       # Image components
    "test_modelinfo.jl",   # Statistical model info
    "test_regtable.jl",    # Regression tables
    "test_export.jl",      # Export functions
    "test_integration.jl"  # End-to-end workflows
]

@testset "Typst.jl Tests" begin
    for test_file in test_files
        @debug "Running test file: $test_file"
        include(test_file)
    end
end