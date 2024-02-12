# modelinfo.jl

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
