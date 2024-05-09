# dataframe.jl
# make simple table from DataFrame

function cellpos(autocell; x = nothing, y = nothing)
    x, y = if !autocell
        x, y
    else
        :auto, :auto
    end
    return (x = x, y = y,)
end

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
    auto_lines = false,
    autocell = true,
    superheader = nothing,
    scientificnotation = false,
    rounddigits = 3
)

    if scientificnotation
        z = "%." * string(rounddigits) * "E"
    end

    cells = TableComponent[];

    # superheader
    if !isnothing(superheader)
        append!(cells, superheader.content)
    end

    # column of row numbers
    coloff = ifelse(numberrows, 0, 1)

    # header
    if numberrows # blank cell
        start_1 = ifelse(!isnothing(superheader), superheader.rownum, 0) + 1
        push!(cells, cellx(; cellpos(autocell; x = 0, y = 0)...))
        push!(cells, vlinex(
            ; start_ = start_1, stroke, x = ifelse(autocell, :auto, 1)
        ))
    end

    # column names
    for (j, e) in names(df) |> enumerate
        if replaceunderscore
            e = replace(e, "_" => " ")
        end
        push!(cells, cellx(
            ; content = e, cellpos(autocell; x = j - coloff, y = 0)...
        ))
    end
    push!(cells, hlinex(
        ; start_ = (coloff - 1)*-1, stroke, y = ifelse(autocell, :auto, 1)),
    )

    # table content
    # row-by-row (to match cell entry order for tablex when autocell=false)
    for (i, r) in (enumerate∘eachrow)(df)
        if numberrows
            push!(cells, cellx(; content = string(i), cellpos(autocell; x = i, y = 0)...))
        end
        # iterate over elements of a DataFrameRow
        for (j, e) in enumerate(r)
            e_ = if (supertype∘eltype)(e) == AbstractFloat
                @show e
                if scientificnotation
                    @eval @sprintf($z, 3)
                else
                    round(e, digits = rounddigits)
                end
            else
                e
            end
            e_ = string(e_)
            push!(cells, cellx(
                ; content = e_, cellpos(autocell; x = j-coloff, y = i)...
            ))
        end
    end

    ncol = size(df, 2) + (coloff - 1)*-1
    columns = "(" * reduce(*, ["auto, " for _ in 1:ncol]) * ")"

    return tablex(cells; columns, auto_lines);
end

export tablex
