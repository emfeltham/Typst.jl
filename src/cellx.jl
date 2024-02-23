# types.jl
# types for table building

abstract type TableComponent end

export TableComponent

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

struct HLineX <: TableComponent
    start_::Int # _
    end_::Union{Symbol, Int} # _
    y::Union{Symbol, Int}
    stroke::Symbol
    stop_pre_gutter::Union{Symbol, Bool} # _
    gutter_restrict::Union{Symbol, Bool} # _
    stroke_expand::Bool # _
    expand::Symbol
end

export HLineX

function hlinex(; 
    start_::Int = 0,
    end_::Union{Symbol, Int} = :auto,
    y::Union{Symbol, Int} = :auto,
    stroke::Symbol = :auto,
    stop_pre_gutter::Union{Symbol, Bool} = :auto,
    gutter_restrict::Union{Symbol, Bool} = :none,
    stroke_expand::Bool = true,
    expand::Symbol = :none
)

    return(
        HLineX(
            start_, end_, y, stroke,
            stop_pre_gutter, gutter_restrict,
            stroke_expand, expand
        )
    )    

end

export hlinex

function print(
    hx::HLineX;
    hlinedefaults = (;
        start_ = 0, # _
        end_ = :auto, # _
        y = :auto,
        stroke = :auto,
        stop_pre_gutter = :auto, # _
        gutter_restrict = :none, # _
        stroke_expand = true, # _
        expand = :none
    )
)

    # fix names to typst format (names changed for compat in julia)
    ndict = Dict(
        :start_ => "start",
        :end_ => "end",
        :stop_pre_gutter => "stop-pre-gutter",
        :gutter_restrict => "gutter-restrict",
        :stroke_expand => "stroke-expand"
    )

    fns = String[]
    for fn in fieldnames(HLineX)
        fo = getfield(hx, fn)
        
        if (fn .∈ Ref(keys(hlinedefaults))) & (fo == hlinedefaults[fn])
            # do nothing if is equal to argument defaults
        else
            o = get(ndict, fn, nothing)
            if !isnothing(o)
                fn = o # change name to match typst
            end
            # push
            push!(fns, string(fn) * ": " * string(fo))
        end
    end

    fns[1:(end-1)] = fns[1:(end-1)] .* ", ";
    return "hlinex" * "(" * reduce(*, fns) * ")"
end

export print
