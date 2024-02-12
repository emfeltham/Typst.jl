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
