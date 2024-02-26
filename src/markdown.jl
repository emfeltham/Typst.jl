# markdown.jl

struct MarkdownFigure
    filenamepath::String
    alt_text::Union{String, Nothing}
    fig_scap::Union{String, Nothing}
    caption::Union{String, Nothing}
    width::Union{String, Nothing}
    align::Union{String, Nothing}
    label::Union{String, Nothing}
end

"""
        markdownfigure(
            filenamepath;
            alt_text=nothing, fig_scap=nothing, caption=nothing,
            width=nothing, align=nothing, label=nothing
        )

## Description

Construct a MarkdownFigure object for export.
"""
function markdownfigure(
    filenamepath;
    alt_text=nothing, fig_scap=nothing, caption=nothing,
    width=nothing, align=nothing, label=nothing
)
    return MarkdownFigure(
        filenamepath,
        alt_text,
        fig_scap,
        caption,
        width,
        align,
        label
    )
end

import Base.print

"""
        print(mfg::MarkdownFigure; filepath = "",)

## Description

- `filepath`: optional path to the file that should be used in Quarto
"""
function print(mfg::MarkdownFigure; filepath = "")

    alt_text = if !isnothing(mfg.alt_text)
        " " * "fig-alt=" * "\"" * mfg.alt_text * "\""
    else ""
    end

    caption = if !isnothing(mfg.caption)
        "[" * mfg.caption * "]"
    else "[]"
    end
    
    # curly opts
    width = if !isnothing(mfg.width)
        "width=" * mfg.width
    else ""
    end
    
    fig_scap = if !isnothing(mfg.fig_scap)
        "fig-scap=" * "\"" * mfg.fig_scap * "\""
    else ""
    end

    label = if !isnothing(mfg.label)
        mfg.label
    else getname(mfg.filenamepath; ext = false)
    end
    
    label = replace(label, " " => "-")
    label = "#fig-" * label
    

    align = if !isnothing(mfg.align)
        "fig-align=" * mfg.align
    else ""
    end

    ct = filepath * getname(mfg.filenamepath; ext = true) * alt_text

    opts = [width, align, label, fig_scap]

    opts = opts[opts .!= ""]
    opts[2:end] = " " .* opts[2:end]
    opts = reduce(*, opts)

    return "!" * caption *
    "(" * ct * ")" *
    "{" * opts * "}"
end

export print

"""
        exportmarkdownfigure(
            filenamepath;
            filepath = "",
            alt_text=nothing,
            fig_scap=nothing,
            caption=nothing,
            width=nothing,
            align=nothing,
            label=nothing
        )

## Description

- `fg`: Figure object (or similar)
- `filenamepath`: path to save the file
- `filepath`: optional path to the file that should be used in Quarto. This 
   should be the path to the file from the .qmd file in which the `{{< include ... >}}` statement will be written
- `save`: the function to save the figure object to a file
- `savekwargs`: keyword arguments to `save`
"""
function exportmarkdownfigure(
    fg, filenamepath,
    save::Function;
    filepath = "",
    alt_text=nothing,
    fig_scap=nothing,
    caption=nothing,
    width=nothing,
    align=nothing,
    label=nothing,
    savekwargs...
)
    pt = markdownfigure(
        filenamepath;
        alt_text, fig_scap, caption,
        width, align, label
    )
    
    fnp = split(filenamepath, ".")[1] # remove extension
    fnp * "\"" * fnp * "\""

    text = print(pt; filepath)
    textexport(fnp, text; ext = ".txt")
    if !isnothing(fg)
        save(filenamepath, fg; savekwargs...)
    end
end

export exportmarkdownfigure
