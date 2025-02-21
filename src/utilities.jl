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
    x = getname(filename)
    x = replace(x, " " => "-")
    return " " * "<" * x * ">" * "\n"
end

import StatsBase.round

function round(x::Tuple{Float64, Float64}; digits = digits)
    return tuple([round(a; digits) for a in x]...)
end

shortcapfunction = "// short captions" * "\n" *
    "#let in-outline = state(\"in-outline\", false)" * "\n" *
    "#show outline: it => {" * "\n" *
    "    in-outline.update(true)" * "\n" *
    "    it" * "\n" *
    "    in-outline.update(false)" * "\n" *
    "}" * "\n" *
    "#let flex-caption(long, short) = context if in-outline.get() { short } else { long }" * "\n"