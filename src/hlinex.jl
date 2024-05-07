# hlinex.jl

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
