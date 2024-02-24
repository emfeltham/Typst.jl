# typst.jl

import Base.print

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
