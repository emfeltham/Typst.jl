# typst.jl

function print(caption::Caption)
    return "[" * caption.text * "]"
end

"""
        figuret(
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

## Description

Create a `FigureT` object, containing a `TableX` or `Image` object.

- `short_caption`: Optionally include a short caption that will appear in the list of figures (tables).
- `kind`: :auto, :table, :figure, or a custom definition. If a custom kind is
  specified, the supplement must be explicitly stated.
"""
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
        short_caption,
        kind,
        supplement,
        numbering,
        gap,
        outlined
    )
end

export figuret

function print(fx::FigureT; label = nothing, tb = reduce(*, fill(" ", 8)))

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

        short_caption = if fx.short_caption == :auto
            Caption(split(fx.caption.text, ".")[1])
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
        if (fx.kind != :figure) | (fx.kind != :table)
            # custom types should have surrounding quotes
            "kind: " * "\"" * string(fx.kind) * "\""
        else "kind: " * string(fx.kind)
        end
    else ""
    end
    
    if (fx.kind ∉ [:auto, :table, :figure]) & (fx.supplement == :none)
        error("custom kind requires supplement")    
    end

    supplement = if fx.supplement != :none
        "supplement: " * "[" * fx.supplement * "]"
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

    ptbl = print(fx.content; tb);

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
