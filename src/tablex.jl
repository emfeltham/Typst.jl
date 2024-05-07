# tablex.jl

"""
tablex(
    items;
    columns = :auto,
    rows = :auto,
    inset = Symbol("5pt"),
    align = :auto,
    fill = :none,
    stroke = :auto,
    column_gutter = :auto,
    row_gutter = :auto,
    gutter = :none,
    repeat_header = false,
    header_rows = 1,
    header_hlines_have_priority = true,
    auto_lines = true,
    auto_hlines = :auto,
    auto_vlines = :auto,
    map_cells = :none,
    map_hlines = :none,
    map_vlines = :none,
    map_rows = :none,
    map_cols = :none
)

## Description

Create a `tablex` object, essentially, a collection of `TableComponent` objects.
"""
function tablex(
    items;
    columns = :auto,
    rows = :auto,
    inset = Symbol("5pt"),
    align = :auto,
    fill = :none,
    stroke = :auto,
    column_gutter = :auto,
    row_gutter = :auto,
    gutter = :none,
    repeat_header = false,
    header_rows = 1,
    header_hlines_have_priority = true,
    auto_lines = true,
    auto_hlines = :auto,
    auto_vlines = :auto,
    map_cells = :none,
    map_hlines = :none,
    map_vlines = :none,
    map_rows = :none,
    map_cols = :none
)

    return TableX(
        columns,
        rows,
        inset,
        align,
        fill,
        stroke,
        column_gutter,
        row_gutter,
        gutter,
        repeat_header,
        header_rows,
        header_hlines_have_priority,
        auto_lines,
        auto_hlines,
        auto_vlines,
        map_cells,
        map_hlines,
        map_vlines,
        map_rows,
        map_cols,
        items
    )
end


"""
        print(tx::TableX; tb = "    ")

## Description

Print a `TableX` object to a string. `tb` adjusts the indentation.
"""
function print(tx::TableX; tb = "    ")
    
    columns = if tx.columns != :auto
        "columns: " * tx.columns
    else ""
    end

    rows = if tx.rows != :auto
        "rows: " * tx.rows
    else ""
    end

    inset = if tx.inset != Symbol("5pt")
        "inset: " * string(tx.inset)
    else ""
    end

    align = if tx.align != :auto
        "align: " * string(tx.align)
    else ""
    end

    fill = if tx.fill != :none
        "fill: " * string(tx.fill)
    else ""
    end

    stroke = if tx.stroke != :none
        "stroke: " * string(tx.stroke)
    else ""
    end

    column_gutter = if tx.column_gutter != :auto
        "column-gutter: " * string(tx.column_gutter)
    else ""
    end

    row_gutter = if tx.row_gutter != :auto
        "row-gutter: " * string(tx.row_gutter)
    else ""
    end

    gutter = if tx.gutter != :none
        "gutter: " * string(tx.gutter)
    else ""
    end

    repeat_header = if tx.repeat_header
        "repeat-header: " * string(tx.repeat_header)
    else ""
    end

    header_rows = if tx.header_rows != 1
        "header-rows: " * string(tx.header_rows)
    else ""
    end

    header_hlines_have_priority = if !tx.header_hlines_have_priority
        "header-hlines-have-priority: " * string(tx.header_hlines_have_priority)
    else ""
    end

    # gridx or tablex
    fnc = if tx.auto_lines
        "#tablex"
    else "#gridx"
    end

    auto_hlines = if tx.auto_hlines != :auto
        "auto-hlines: " * string(tx.auto_hlines)
    else ""
    end

    auto_vlines = if tx.auto_vlines != :auto
        "auto-vlines: " * string(tx.auto_vlines)
    else ""
    end

    map_cells = if tx.map_cells != :none
        "map-cells: " * string(tx.map_cells)
    else ""
    end

    map_hlines = if tx.map_hlines != :none
        "map-hlines: " * string(tx.map_hlines)
    else ""
    end

    map_vlines = if tx.map_vlines != :none
        "map-vlines: " * string(tx.map_vlines)
    else ""
    end

    map_rows = if tx.map_rows != :none
        "map-rows: " * string(tx.map_rows)
    else ""
    end

    map_cols = if tx.map_cols != :none
        "map-cols: " * string(tx.map_cols)
    else ""
    end

    pcells = String[];
    for cell in tx.items
        push!(pcells, tb * print(cell) * ",\n")
    end

    elems = [
        columns, rows, inset, align, fill, stroke,
        column_gutter, row_gutter, gutter,
        repeat_header, header_rows, header_hlines_have_priority,
        auto_hlines, auto_vlines, map_cells, map_hlines, map_vlines,
        map_rows, map_cols
    ];

    elems = elems[elems .!= ""]

    return fnc * "(" * "\n" *
    reduce(*, tb .* elems .* ",\n") *
    reduce(*, pcells) *
    tb[1:(length(tb)-4)] * ")"
end

export tablex
