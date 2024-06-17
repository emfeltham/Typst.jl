# modelinfo.jl

"""
        ModelInfo

## Description

Model information pulled from linear model object, for use with table 
construction.
"""
struct ModelInfo
    estimation::String
    coef::AbstractDict{String, Dict{String, String}}
    stats::AbstractDict{String, String}
    varcomp::AbstractDict{String, String}
end

@inline ±(x, y) = [x-y, x+y]

"""
        _modelinfos!(mfos, ms, stats, digits, rndp, coeftables)

## Description

Populate a `ModelInfo` object for each input model in `ms` that contains
model information for the regression table in a format more amenable to
table construction.
"""
function _modelinfos!(
    mfos::Vector{ModelInfo},
    ms, stats, digits, rndp, coeftables
)
    for (ix, m) in enumerate(ms)
        cdict = Dict{String, Dict{String, String}}();
        
        cft = if isnothing(coeftables)
            coeftable(m) |> DataFrame
        else coeftables[ix]
        end

        for c in eachrow(cft)
            cn = c[:Name];
            cdict[cn] = Dict{String, String}()
            cdict[cn]["est"] = (string∘round)(c[Symbol("Coef.")]; digits)
            cdict[cn]["se"] = (string∘round)(c[Symbol("Std. Error")]; digits)
            cint = c[Symbol("Coef.")] ± c[Symbol("Std. Error")] * 1.96 # 5% sig.
            cdict[cn]["ci"] = string(round.(cint; digits))
            pname = ifelse(Symbol("Pr(>|z|)") ∈ (collect∘keys)(c), Symbol("Pr(>|z|)"), Symbol("Pr(>|t|)"))
            cdict[cn]["pval"] = string(round.(c[pname]; digits = rndp))
        end

        sdict = Dict{String, String}();

        # Mixed Model info
        # Random effects variance components
        vcomp = OrderedDict{String, String}();
        if typeof(m) <: MixedModel
            varcorr = VarCorr(m) # σρ field is NamedTuple
            σρ = getfield(varcorr, :σρ)
            for (ranvar, ran) in pairs(σρ)
                # only handle intercepts for now
                # (ignore ρ, possibility of random intercepts)
                rval = getfield(ran.σ, Symbol("(Intercept)"));
                vcomp[string(ranvar) * " var."] = string(round.(rval; digits))
            end
            ngr = string.(MixedModels.nlevs.(m.reterms));
            ngr[1:(end-1)] = ngr[1:(end-1)] .* ", "
            vcomp["N#sub[groups]"] = reduce(*, ngr)
        end
        
        for stat in stats
            # need to have a way to leave blank if not defined on `m`
            sdict[string(stat)] = try
                (string∘round)(stat(m); digits)
            catch
                "NA"
            end
        end
        # construct row by row

        mfo = ModelInfo(
            "",
            cdict::AbstractDict{String, Dict{String, String}}, 
            sdict::AbstractDict{String, String},
            vcomp::AbstractDict{String, String}
        )
        push!(mfos, mfo)
    end
end
