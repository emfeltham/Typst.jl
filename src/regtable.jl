# regtable.jl

"""
        ModelInfo

## Description

Model information pulled from linear model object, for use with table 
construction.
"""
struct ModelInfo
    estimation::String
    coef::Dict{String, Dict{String, String}}
    stats::Dict{String, String}
    varcomp::Dict{String, String}
end

"""
        regtable_typ(ms, filename; caption = nothing, roundvals = 3)

## Description

Cell-based regression table for typst. Basic units are `TableX` abstract types,
which are printed and combined with header information and a caption to form a
formatted ".typ" file.
"""
function regtable_typ(
    ms, filename;
    modeltitles = nothing, caption = nothing, roundvals = 3
)

    # indentation for print formatting
    tb = "    ";
    
    cnames = (unique∘reduce)(vcat, [coefnames(m) for m in ms]);
    ms_l = length(ms);
    modtxt = "models";
    
    # force at least two digits for p-values
    rndp = if roundvals < 2
        2
    else
        roundvals
    end;

    # extract model information
    stats = [nobs, r2, adjr2, aic, bic];
    mfos = ModelInfo[];
    _modelinfos!(mfos, ms, stats, roundvals, rndp)
    
    colwidths = reduce(*, ["coliwidth, " for _ in 1:ms_l]);
    cols = "columns: " * "(col1width, " * colwidths * ")";

    # options arguments to gridx
    hvars = [
        cols,
        "rows: auto",
        "align: center + horizon",
    ];

    cells = TableX[];
    regtable_content!(cells, mfos, cnames, modtxt, modeltitles, stats);

    cells_p = [print(cell) for cell in cells]

    # these are all the arguments to gridx
    cells_o = tb * tb .* vcat(hvars, cells_p)
    cells_o[1:(end-1)] = cells_o[1:(end-1)] .* ", \n"
    cells_o[end] = cells_o[end] * " \n"

    fnc = ["#figure( \n", tb * "kind: table, \n", tb * "gridx( \n", ];

    cells_o = if isnothing(caption)
        vcat(fnc, cells_o, tb * ") \n ) \n")
    else
        caption_o = tb * "), \n" * tb * "caption: " * "[" * caption * "]\n)\n"
        vcat(fnc, cells_o, caption_o)
    end

    # import statement
    imp = "#import" * "\"" * "@preview/tablex:0.0.8\": tablex, gridx, hlinex, vlinex, colspanx, rowspanx, cellx";
    println(imp)

    # typst variables
    tvars = [
        "#let topinset = 0.1em",
        "#let col1width = 12em",
        "#let coliwidth = auto"
    ];

    cells_o = vcat(imp * "\n", tvars .* "\n", "\n", cells_o)

    txto = reduce(*, cells_o);
    textexport(filename, txto; ext = ".typ");
    return cells_o
end

export regtable_typ

function regtable_content!(
    cells, mfos, cnames, modtxt, modeltitles, stats;
    pkey = "_Note:_ \$#super[+]p<0.10\$; \$#super[\$star.op\$]p<0.05\$; \$#super[\$star.op star.op\$]p<0.01\$, \$#super[\$star.op star.op star.op\$]p<0.001\$",
    statnames = Dict( # nice names for common statistics
        "nobs" => "N",
        "r2" => "\$R^2\$",
        "adjr2" => "Adjusted \$R^2\$",
        "aic" => "AIC",
        "bic" => "BIC"
    )
)

    # define colnum as variable name col +  model cols
    colnum = length(mfos) + 1;

    # top lines
    # creates a double-line top bar
    topline = [
        hlinex(stroke = Symbol("0.05em"), y = 0),
        cellx(inset = :topinset, colspan = colnum, x = 0, y = 0),
        hlinex(stroke = Symbol("0.05em"), y = 1),
    ];

    append!(cells, topline)

    # model titles
    push!(cells, cellx(align = :center, content = modtxt, colspan = colnum - 1, x = 1, y = 1, inset = Symbol("0.8em")))

    mtitles = if isnothing(modeltitles)
        string.(1:length(mfos)) # enumerate models by default
    elseif length(mfos) == length(modeltitles)
        modeltitles
    else
        error("error in `modeltitles`")
    end

    # add cells for model titles
    for (i, e) in enumerate(mtitles)
        et = "(" * e * ")"
        push!(cells, cellx(content = et, x = i, y = 2))
    end

    # line should not cover first column (under model titles)
    push!(cells, hlinex(stroke = Symbol("0.05em"), start_ = 1, y = 4))

    # coefficients
    # starting index at y = 4
    ymn = 5
    ydex = copy(ymn)
    jmp = 2 # since est and se

    cidxs = [ymn + 2*(i-1) for i in eachindex(cnames)]
    dd = Dict(cnames .=> cidxs)

    for (cn, v) in dd
        # variable name entry
        push!(cells, cellx(content = cn, x = 0, y = v))
        
        # model values entries
        for (mi, mfo) in enumerate(mfos)
            cinfo = get(mfo.coef, cn, nothing)
            
            if !isnothing(cinfo)
                for (si, st) in enumerate(["est", "se"])
                    vl = if st == "se"
                        "(" * cinfo["se"] * ")"
                    elseif st == "est"
                        cinfo[st] * pthres(get(cinfo, "pval", "99"))
                    else
                        cinfo[st]
                    end
                    push!(
                        cells,
                        cellx(content = vl, x = mi, y = v + si - 1)
                    )
                end
            end
        end
    end

    ydex = maximum(values(dd)) + jmp

    push!(
        cells,
        cellx(
            inset = Symbol("0.02em"), align = :center, colspan = colnum,
            x = 0, y = ydex
        )
    )

    ydex += 1

    push!(cells, hlinex(stroke = Symbol("0.05em"), start_ = 1, y = ydex + 1))

    push!(
        cells,
        cellx(align = :center, colspan = colnum - 1, x = 1, y = ydex)
    )

    ydex += 1

    # model stats
    ydex += 1
    sdict = Dict(string.(stats) .=> ydex:(ydex + length(stats) - 1))

    for (k, v) in sdict
        kn = get(statnames, k, k)
        push!(
            cells,
            cellx(content = kn, align = :center, x = 0, y = v)
        )
    end

    for (mi, mfo) in enumerate(mfos)
        for (k, v) in mfo.stats
            sval = get(sdict, k, nothing)
            if k == "nobs"
                v = (string∘convert)(Int, parse(Float64, v))
            end
            if !isnothing(sval)
                push!(cells, cellx(content = v, x = mi, y = sval))
            end
        end
    end

    ydex = maximum(values(sdict)) + 1

    push!(cells, cellx(align = :center, colspan = colnum, x = 0, y = ydex))
    ydex += 1
    
    push!(cells, hlinex(stroke = Symbol("0.1em"), y = ydex))

    # notes
    ydex += 1
    push!(
        cells,
        cellx(; content = pkey, colspan = colnum, y = ydex)
    )
end

function pthres(
    pv;
    ky = [
        "#super[\$+\$]",
        "#super[\$star.op\$]",
        "#super[\$star.op star.op\$]",
        "#super[\$star.op star.op star.op\$]"
    ]
)
    fl = findlast(parse(Float64, pv) .< [0.1, 0.05, 0.01, 0.001])
    return if !isnothing(fl)
        ky[fl]
    else
        ""
    end
end

function _modelinfos!(mfos, ms, stats, digits, rndp)
    for m in ms
        ct = coeftable(m)
        pv = ct.cols[ct.pvalcol]
        cdict = Dict{String, Dict{String, String}}();
        for (cn, c, se, ci, pval) in zip(
            coefnames(m),
            coef(m),
            stderror(m),
            eachrow(confint(m)),
            pv
        )
            cdict[cn] = Dict{String, String}()
            cdict[cn]["est"] = (string∘round)(c; digits)
            cdict[cn]["se"] = (string∘round)(se; digits)
            cdict[cn]["ci"] = string(round.(ci; digits))
            cdict[cn]["pval"] = string(round.(pval; digits = rndp))
        end

        sdict = Dict{String, String}();
        
        for stat in stats
            # need to have a way to leave blank if not defined on `m`
            sdict[string(stat)] = (string∘round)(stat(m); digits)
        end
        # construct row by row

        mfo = ModelInfo("OLS", cdict, sdict, Dict{String, String}())
        push!(mfos, mfo)
    end
end
