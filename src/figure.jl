# typst.jl

struct Caption
    text::String
end

function print(caption::Caption)
    return "[" * caption.text * "]"
end

struct FigureT
    content::Union{TableX, Image}
    placement::Symbol
    caption::Union{Symbol, Caption}
    kind::Symbol
    supplement::Union{String, Symbol}
    numbering::Union{String, Symbol}
    gap::Symbol
    outlined::Bool
end

function figuret(
    content;
    placement = :auto,
    caption::Union{Symbol, Caption} = :none,
    kind = :auto,
    supplement = :none,
    numbering = "1",
    gap = Symbol("0.65em"),
    outlined = true
)

    if placement ∉ [:top, :bottom, :auto]
        error("invalid placement, must be one of :top or :bottom")
    end

    return FigureT(
        content,
        placement,
        caption,
        kind,
        supplement,
        numbering,
        gap,
        outlined
    )
end

export figuret

import Base.print

function print(fx::FigureT; label = nothing, tb = "    ")

    placement = if fx.placement != :auto
        "placement: " * string(fx.placement)
    else ""
    end

    caption = if fx.caption != :none
        "caption: " * print(fx.caption)
    else ""
    end

    kind = if fx.kind != :auto
        "kind: " * string(fx.kind)
    else ""
    end

    supplement = if fx.supplement != :none
        "supplement: " * fx.supplement
    else ""
    end

    numbering = if fx.numbering != "1"
        "numbering: " * fx.numbering
    else ""
    end

    gap = if fx.gap != Symbol("0.65em")
        "gap: " * string(fx.gap)
    else ""
    end

    outlined = if !fx.outlined
        "outlined: " * string(fx.outlined)
    else ""
    end

    ptbl = print(
        fx.content; tb = reduce(*, fill(" ", 8))
    );

    elems = [
        ptbl,
        placement,
        caption,
        kind,
        supplement,
        numbering,
        gap,
        outlined
    ]

    elems = elems[elems .!= ""]

    lb = if !isnothing(label)
        label
    else
        ""
    end

    out = "#figure(" * "\n" *
    reduce(*, "    " .* elems .* ",\n") *
    ")" * lb

    return out
end
