# cellx.jl
# types and functions for table building and printing

struct CellX <: TableComponent
    content::Union{String, Symbol, Real}
    x::Union{Symbol, Int}
    y::Union{Symbol, Int}
    rowspan::Int # units
    colspan::Int # units
    fill::Symbol
    align::Symbol
    inset::Symbol # units
    fitspans::Union{Symbol, NamedTuple{(:x, :y), Tuple{Bool, Bool}}}
end

function cellx(;
    content::Union{String, Symbol, Real} = "",
    x::Union{Symbol, Int} = :auto,
    y::Union{Symbol, Int} = :auto,
    rowspan::Int = 1,
    colspan::Int = 1,
    fill::Symbol = :auto,
    align::Symbol = :auto,
    inset::Symbol = :auto,
    fitspans::Union{Symbol, NamedTuple{(:x, :y), Tuple{Bool, Bool}}} = :auto # fit-spans
)

    return CellX(
        content, x, y,
        rowspan, colspan,
        fill, align,
        inset,
        fitspans # fit-spans
    )
end

export CellX, cellx

import Base.print

"""
print(
    cx::CellX;
    celldefaults = (;
        x = :auto,
        y = :auto,
        rowspan = 1,
        colspan = 1,
        fill = :auto,
        align = :auto,
        inset = :auto,
        fitspans = :auto # fit-spans
    )
)

## Description

Print `CellX` object, formatted for typst. Omits arguments equal to the typst default, which may be altered by changes to `celldefaults`.
"""
function print(
    cx::CellX;
    celldefaults = (;
        x = :auto,
        y = :auto,
        rowspan = 1,
        colspan = 1,
        fill = :auto,
        align = :auto,
        inset = :auto,
        fitspans = :auto # fit-spans
    )
)
    fns = String[]
    for fn in fieldnames(CellX)
        if fn != :content
            fo = getfield(cx, fn)
            
            if (fn .∈ Ref(keys(celldefaults))) & (fo == celldefaults[fn])
                # do nothing if is equal to argument defaults
            else
                if fn == :fitspans # change name to match typst
                    fn = "fit-spans"
                end
                # push
                push!(fns, string(fn) * ": " * string(fo))
            end
        end
    end

    cont = string(getfield(cx, :content))
    fns[1:(end-1)] = fns[1:(end-1)] .* ", "
    return "cellx" * "(" * reduce(*, fns) * ")" * "[" * cont * "]"
end

export print
