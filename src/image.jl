# figure.jl

struct Image
    fn::String
    format::Union{String, Symbol}
    width::Union{Int, Symbol}
    height::Union{Int, Symbol}
    alt::Symbol
    fit::Symbol
end

"""
Specify the format via `filename` by default.
"""
function image(
    filename;
    format = :auto,
    width = :auto,
    height = :auto,
    alt = :none,
    fit = :cover,
    formats = ["svg", "png", "gif", "jpg"],
    fits = [:cover, :contain, :stretch]
)

    # add check for auto too
    if format != :auto
        if format ∉ formats
            error("invalid format")
        end
    end

    if img.width != :auto
        if (img.width < 0) | (img.width > 100)
            error("width outside range")
        end
    end

    if img.height != :auto
        if (img.height < 0) | (img.height > 100)
            error("width outside range")
        end
    end

    if fit ∉ fits
        error("invalid fit specification")
    end 

    return Image(filename, format, width, height, alt, fit)
end

function print(img::Image; tb = "    ")

    format = if img.format != :auto
        "format: " * string(img.format) * "\n"
    else
        ""
    end

    width = if img.width != :auto
        "width: " * string(img.width) * "%" * "\n"
    else
        ""
    end

    height = if img.height != :auto
        "height: " * string(img.height) * "%" * "\n"
    else
        ""
    end

    alt = if img.alt != :none
        "alt: " * img.alt * "\n"
    else
        ""
    end

    fit = if img.fit != :cover
        "fit: " * string(img.fit) * "\n"
    else
        ""
    end

    return "image(" * "\n" *
    tb * format *
    tb * width *
    tb * height *
    tb * alt *
    tb * fit * 
    ")"
end
