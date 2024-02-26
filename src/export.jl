# export.jl

"""

        figure_export(
            filepathname,
            fg,
            save::Function;
            placement = :auto,
            caption::Union{Symbol, Caption} = :none,
            kind = :auto,
            supplement = :none,
            numbering = "1",
            gap = Symbol("0.65em"),
            outlined = true
        )

## Description

- `filepathname`: the path to the file, including the filename and the figure
  extension.
- `fg`: the figure object
- `save`: the function to save the figure object to a file
- `savekwargs`: keyword arguments to `save`

"""
function figure_export(
    filepathname,
    fg,
    save::Function;
    placement = :auto,
    caption::Union{Symbol, String} = :none,
    kind = :auto,
    supplement = :none,
    numbering = "1",
    gap = Symbol("0.65em"),
    outlined = true,
    savekwargs...
)

    if caption != :none
        caption = Caption(caption)
    end

    fgt = figuret(
        image(filepathname);
        placement,
        caption,
        kind,
        supplement,
        numbering,
        gap,
        outlined
    )

    fnp = split(filepathname, ".")[1] # remove extension
    fnp * "\"" * fnp * "\""

    # label is filename
    label = getname(filepathname; ext = false) |> makelabel

    textexport(fnp, print(fgt; label))
    save(filepathname, fg; savekwargs...)
end

export figure_export


"""
NOT FINISHED

        table_export(
            filepathname,
            tbl;

            placement = :auto,
            caption::Union{Symbol, Caption} = :none,
            kind = :auto,
            supplement = :none,
            numbering = "1",
            gap = Symbol("0.65em"),
            outlined = true
        )

## Description

- `filepathname`: the path to the file, including the filename and the figure
  extension.
- `tbl`: the table object

"""
function table_export(
    filepathname,
    tbl;
    placement = :auto,
    caption::Union{Symbol, Caption} = :none,
    kind = :auto,
    supplement = :none,
    numbering = "1",
    gap = Symbol("0.65em"),
    outlined = true,
    savekwargs...
)

    if caption != :none
        caption = Caption(caption)
    end

    fgt = figuret(
        image(filepathname);
        placement,
        caption,
        kind,
        supplement,
        numbering,
        gap,
        outlined
    )

    textexport(filepathname, print(fgt))
    save(filepathname, fg; savekwargs...)
end

# export table_export
