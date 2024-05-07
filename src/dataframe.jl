# dataframe.jl
# make simple table from DataFrame

"""
        tablex(
            df::AbstractDataFrame;
            stroke = Symbol("0.05em"),
            numberrows = true,
            replaceunderscore = true,
            auto_lines = false
        )


## Description

Creates a `TableX` object from a DataFrame with simple formatting.

- `df`: DataFrame.
- `stroke = Symbol("0.05em")`: stroke width for vertical lines.
- `numberrows`: include the row numbers.
- `replaceunderscore`: replaces column heading name instances of "_" with a space.
- `auto_lines = false`: Whether to use `gridx` or `tablex` object. The latter automatically draws row and column lines.

"""
function tablex(
    df::AbstractDataFrame;
    stroke = Symbol("0.05em"),
    numberrows = true,
    replaceunderscore = true,
    auto_lines = false
)

    cells = TableComponent[];

    # column of row numbers
    coloff = if numberrows
        for j in 1:nrow(df)
            push!(cells, cellx(content = string(j), x = 0, y = j))
        end
        push!(cells, vlinex(; start_ = 1, stroke, x = 1))
        0
    else
        1
    end

    # header
    for (j, e) in names(df) |> enumerate
        if replaceunderscore
            e = replace(e, "_" => " ")
        end
        push!(cells, cellx(content = e, x = j-coloff, y = 0))
    end
    push!(cells, hlinex(; stroke, y = 1),)

    # iterate over elements of row
    for (i, r) in (enumerate∘eachrow)(df)
        for (j, e) in enumerate(r)
            e_ = if (supertype∘eltype)(e) == AbstractFloat
                @show e
                round(e, digits = 3)
            else
                e
            end
            e_ = string(e_)
            push!(cells, cellx(content = e_, x = j-coloff, y = i))
        end
    end

    ncol = size(df, 2) + (coloff - 1)*-1
    columns = "(" * reduce(*, ["auto, " for _ in 1:ncol]) * ")"

    return tablex(cells; columns, auto_lines);
end

export tablex
