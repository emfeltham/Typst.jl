# regtable.jl

"""

        regtablet(
            ms, filename;
            label = nothing,
            modeltitles = nothing,
            caption = :none,
            supplement = :none,
            roundvals = 3,
            understat = "se",
            col1width = 10,
            stats = [nobs, r2, adjr2, aic, bic],
            pvalkey = (
                values = [0.1, 0.05, 0.005, 0.001],
                symbols = [
                    "super[\$+\$]", "super[\$star.op\$]",
                    "super[\$star.op star.op\$]",
                    "super[\$star.op star.op star.op\$]"
                ]
            )
        )

## Description

Cell-based regression table for typst. Basic units are `TableX` abstract types,
which are printed and combined with header information and a caption to form a
formatted ".typ" file.

P-value key symbols must include escape characters as appropriate for printing
strings in Julia.
"""
function regtablet(
    ms, filename;
    label = nothing,
    modeltitles = nothing,
    caption = :none,
    supplement = :none,
    roundvals = 3,
    understat = "se",
    col1width = 10,
    stats = [nobs, r2, adjr2, aic, bic],
    pvalkey = (
        values = [0.1, 0.05, 0.005, 0.001],
        symbols = [
            "super[\$+\$]", "super[\$star.op\$]",
            "super[\$star.op star.op\$]",
            "super[\$star.op star.op star.op\$]"
        ]
    )
)

    cnames = (unique∘reduce)(vcat, [coefnames(m) for m in ms]);
    ms_l = length(ms);

    # table content

    # p-stars and key
    if !all(diff(pvalkey.values) .< 0)
        error("p-value key is wrong")
    end

    pvks = pvalkey.symbols .* ", "
    pstatement = "// pkey \n" * "#let ps = " * "(" * reduce(*, pvks) * ")" * "\n \n"
    
    nts = ["ps.at(" * string(i-1) * ")" * "\$p<" * string(v) * "\$" for (i, v) in enumerate(pvalkey.values)];
    nts = "#" .* nts;
    nts[1:(end-1)] = nts[1:(end-1)] .* "; ";
    pnote = "Note: " * reduce(*, nts); # bottom of table
    
    # force at least two digits for p-values
    rndp = if roundvals < 2
        2
    else
        roundvals
    end;

    # extract model information
    statnames = Dict( # nice names for common statistics
        "nobs" => "N",
        "r2" => "\$R^2\$",
        "adjr2" => "Adjusted \$R^2\$",
        "aic" => "AIC",
        "bic" => "BIC"
    );

    mfos = ModelInfo[];
    _modelinfos!(mfos, ms, stats, roundvals, rndp)
    
    mxname = 0
    for mfo in mfos
        for k in keys(mfo.coef)
            mxname = max(mxname, length(k)) 
        end
        for k in keys(mfo.stats)
            k_ = get(statnames, k, k)
            mxname = max(mxname, length(k_)) 
        end
    end

    # generate the body of the table (coefficients, statistics)
    cells = TableComponent[];
    regtable_content!(
        cells, mfos, cnames, modeltitles,
        stats, understat, pvalkey, pnote, statnames
    );

    # table object
    colwidths = reduce(*, ["coliwidth, " for _ in 1:ms_l]);
    columns = "(col1width, " * colwidths * ")";
    rows = "(0.2em, 1.5em)"; # first row for double line; 1.5 thereafter
    align = "center + horizon";
    
    tbl = tablex(cells; columns, rows, align);

    if caption != :none
        caption = Caption(caption)
    end

    fgt = figuret(tbl; caption, supplement, kind = :table);

    # import statement
    imp = "#import" * "\"" * "@preview/tablex:0.0.8\": tablex, gridx, hlinex, vlinex, colspanx, rowspanx, cellx" * "\n";

    # typst variables
    tvars = [
        "// table params",
        "#let col1width = " * string(col1width) * "em",
        "#let coliwidth = auto",
        "#let name_align = left + horizon",
    ];

    tvars = reduce(*, tvars .* "\n")

    frontmatter = vcat(
        imp * "\n",
        tvars,
        pstatement,
    )

    frontmatter = reduce(*, frontmatter);

    # table label
    if isnothing(label)
        label = makelabel(filename)
    end

    pfgt = print(fgt; label = label, tb = reduce(*, fill(" ", 8)));
    
    txto = reduce(*, [frontmatter, pfgt]);
    textexport(filename, txto; ext = ".typ");
    return txto
end

export regtable_typ

function regtable_content!(
    cells, mfos, cnames, modeltitles,
    stats, understat, pvalkey, pnote, statnames
)

    # define colnum as variable name col +  model cols
    colnum = length(mfos) + 1;

    # top lines
    # creates a double-line top bar
    topline = [
        hlinex(stroke = Symbol("0.05em"), y = 0),
        cellx(colspan = colnum, x = 0, y = 0),
        hlinex(stroke = Symbol("0.05em"), y = 1),
    ];

    append!(cells, topline)

    # model titles
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
        push!(cells, cellx(content = et, x = i, y = 1))
    end

    # line should not cover first column (under model titles)
    push!(cells, hlinex(stroke = Symbol("0.05em"), start_ = 1, y = 2))

    # coefficients
    # starting index at y = ymn
    ymn = 2
    ydex = copy(ymn)
    jmp = 2 # since est and se

    cidxs = [ymn + 2*(i-1) for i in eachindex(cnames)]
    dd = Dict(cnames .=> cidxs)

    for (cn, v) in dd
        # variable name entry
        push!(cells, cellx(content = cn, align = :name_align, x = 0, y = v))
        
        # model values entries
        for (mi, mfo) in enumerate(mfos)
            cinfo = get(mfo.coef, cn, nothing)
            
            if !isnothing(cinfo)
                for (si, st) in enumerate(["est", understat])
                    vl = if st == "se"
                        "(" * cinfo["se"] * ")"
                    elseif st == "est"
                        cinfo[st] * passign(get(cinfo, "pval", "99"), pvalkey)
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

    push!(cells, hlinex(stroke = Symbol("0.05em"), start_ = 1, y = ydex))

    # random effects
    # sort based on N size, nesting? (rather than name...)
    if any(length(mfo.varcomp) > 0 for mfo in mfos)
        rnames = union(
            reduce(vcat, [(collect∘keys)(mfo.varcomp) for mfo in mfos])
        );

        # ordered since it is difficult to extract names,
        # and we want N_grp to appear in the varcomp order
        rdict = OrderedDict(
            string.(rnames) .=> ydex:(ydex + length(rnames) - 1)
        );

        for (k, v) in rdict
            push!(
                cells,
                cellx(content = k, align = :name_align, x = 0, y = v)
            )
        end

        for (mi, mfo) in enumerate(mfos)
            for (k, v) in mfo.varcomp
                sval = get(rdict, k, nothing)

                if !isnothing(sval)
                    push!(cells, cellx(content = v, x = mi, y = sval))
                end
            end
        end

        ydex = maximum(values(rdict)) + 1

        push!(cells, hlinex(stroke = Symbol("0.05em"), start_ = 1, y = ydex))
    end

    # model stats
    sdict = Dict(string.(stats) .=> ydex:(ydex + length(stats) - 1));

    for (k, v) in sdict
        kn = get(statnames, k, k)
        push!(
            cells,
            cellx(content = kn, align = :name_align, x = 0, y = v)
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

    push!(cells, hlinex(stroke = Symbol("0.1em"), y = ydex))

    # notes
    push!(
        cells,
        cellx(; content = pnote, colspan = colnum, align = :left, y = ydex)
    )
end

"""
        passign(pv, pvalkey)

## Description

Assign p-value symbol based on `pvalkey` and the model p-value.

Assignments are calls to the appropriate position in the typst array `ps`,
defined at the beginning of the table.
"""
function passign(pv, pvalkey)
    fl = findlast(parse(Float64, pv) .< pvalkey.values)
    return if !isnothing(fl)
        "#" * "ps.at(" * string(fl-1) * ")" # zero-based in typst
    else
        ""
    end
end
