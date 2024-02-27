# export.jl

"""

        figure_export(
            filepathname,
            fg,
            save::Function;
            placement = :auto,
            caption::Union{Symbol, Caption} = :none,
            short_caption::Union{Symbol, Caption} = :auto,
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
- `short_caption`: optionally specify a short caption. `:auto` default option 
  sets the short caption as the first sentence of the caption. There will be no short caption when set to `:none`. N.B. that this option requires the definition of a Typst function in the text export.

"""
function figure_export(
    filepathname,
    fg,
    save::Function;
    placement = :auto,
    caption::Union{Symbol, String} = :none,
    short_caption::Union{Symbol, String} = :auto,
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

    if (short_caption != :none) & (short_caption != :auto)
        short_caption = Caption(short_caption)
    end

    if short_caption != :none
        shortcapfunction = "// short captions" * "\n" *
        "#let in-outline = state(\"in-outline\", false)" * "\n" *
        "#show outline: it => {" * "\n" *
        "    in-outline.update(true)" * "\n" *
        "    it" * "\n" *
        "    in-outline.update(false)" * "\n" *
        "}" * "\n" *
        "#let flex-caption(long, short) = locate(loc => " * "\n" *
        "    if in-outline.at(loc) { short } else { long }" * "\n" *
        ")" * "\n\n"
    end

    fgt = figuret(
        image(filepathname);
        placement,
        caption,
        short_caption,
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

    out = print(fgt; label);

    if short_caption != :none
        out = shortcapfunction * out
    end

    textexport(fnp, out)
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
