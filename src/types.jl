# types.jl

struct Caption
    text::String
end

struct TableX
    columns::Union{Symbol, String} # string is easiest for now
    rows::Union{Symbol, String}
    inset::Symbol
    align::Union{Symbol, String}
    fill::Symbol
    stroke::Symbol
    column_gutter::Symbol # _
    row_gutter::Symbol # _
    gutter::Symbol
    repeat_header::Bool # _
    header_rows::Int # _
    header_hlines_have_priority::Bool # _
    auto_lines::Bool # _
    auto_hlines::Symbol # _
    auto_vlines::Symbol # _
    map_cells::Union{Symbol, String} # _
    map_hlines::Union{Symbol, String} # _
    map_vlines::Union{Symbol, String} # _
    map_rows::Union{Symbol, String} # _
    map_cols::Union{Symbol, String} # _
    items::Vector{TableComponent} # this is the content
end

struct Image
    fn::String
    format::Union{String, Symbol}
    width::Union{Int, Symbol}
    height::Union{Int, Symbol}
    alt::Symbol
    fit::Symbol
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
