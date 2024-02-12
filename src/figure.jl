# typst.jl

"""
        figure_typ(file, caption; label = nothing, width_pct = 100)

## Description

- Filename should not include \".\", except for the file extension.
- File path to the figure file should be relative to the position of the exported text file.
"""
function figure_typ(file, caption; label = nothing, width_pct = 100)
    if isnothing(label)
        # use filename without extension 
        label = split(split(file, "/")[end], ".")[1]
    end
    w = string(width_pct)
    return "#figure(" * "\n" *
    "   " * "image(" * "\"" * file * "\""* ", " * "width: " * w * "%)," * "\n" *
    "   " * "caption: [" * caption * "]," * "\n" *
    ") <" * label * ">"
end

export figure_typ

"""
        save_typ(filename, figure; caption = "", label = nothing, ext = ".svg")

## Description

- Saves the figure and the \".typ\" files in the same directory.
- Typst figure label becomes filename
- "." can only be used for the file extension in `filename`
- Permitted filename structure: "documents/content.ext"

"""
function save_typ(
    filename, figure; caption = "", label = nothing, width_pct = 100
)

    file = if occursin("/", filename)
        split(filename, "/")[end] # split along directory
    else
        filename
    end
    
    # figure file
    save(filename, figure)

    # .typ file
    # directory is the same as fig file, so ".typ" relative path is ""
    txt = figure_typ(file, caption; label, width_pct)

    # split along extension, grab file's 
    # in case "." appears in path, grab all content but that after last.
    # since split, add back periods to all breaks except the last
    sp = split(filename, ".")
    filename2 = if count(".", filename) > 1
        sp2 = sp[1:(end-1)]
        sp3 = [sp[i] * "." for i in 1:(length(sp2)-1)] * sp2[end]
        reduce(*, sp3)
    else
        sp[1]
    end
    textexport(filename2, txt)
end

export save_typ
