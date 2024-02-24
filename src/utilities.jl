# utilities.jl

"""
        textexport(filename, text; ext = ".typ")

## Description

Write a String object to a file.
"""
function textexport(filename, text; ext = ".typ")
    open(filename * ext, "w") do file
        write(file, text)
    end
end

export textexport

"""
        getname(filename; ext = false)

## Description

Extract filename from a path to a filename with the file extension. Optionally include the file extension in the output string.
"""
function getname(filename; ext = false)
    lbraw = split(filename, "/")[end]
    lbraw = split(lbraw, ".")
    return if length(lbraw) > 1
        if ext
            lbraw[end-1] * "." * lbraw[end]
        else
            lbraw[end-1]
        end
    else
        if ext
            lbraw[1] * "." * lbraw[end]
        else
            lbraw[1]
        end
    end
end

function makelabel(filename)
    return " " * "<" * getname(filename) * ">" * "\n"
end

function print(fx::FigureT; label = nothing, tb = "    ")

    placement = if fx.placement != :auto
        "placement: " * string(fx.placement)
    else ""
    end

    caption = if fx.caption != :none
        "caption: " * print(fx.caption)
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
