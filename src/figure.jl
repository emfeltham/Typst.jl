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
    short_caption::Union{Symbol, Caption}
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
    short_caption::Union{Symbol, Caption} = :none,
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
        shortcaption,
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

    #= caption
    short caption support via function provided
    in https://github.com/typst/typst/issues/1295
    =#

    caption = if (fx.caption == :none) & (fx.short_caption != :none)
        error("short caption may only be specified when there is a caption.")
    elseif (fx.caption != :none) & (fx.short_caption == :none)
        "caption: " * print(fx.caption)
    elseif (fx.caption != :none) & (fx.short_caption != :none)

        short_caption = if fx.sort_caption == :auto
            Caption(split(fx.caption, ".")[1])
        else
            fx.short_caption
        end

        "caption: flex-caption(\n" *
        print(fx.caption) * ",\n" *
        print(short_caption) * "\n" *
        ")"
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
