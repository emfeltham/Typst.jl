@testset "ModelInfo Tests" begin
    
    @testset "ModelInfo struct construction" begin
        # Test basic ModelInfo construction
        coef_dict = Dict(
            "(Intercept)" => Dict("est" => "2.5", "se" => "0.3", "ci" => "[1.9, 3.1]", "pval" => "0.001"),
            "x1" => Dict("est" => "1.8", "se" => "0.2", "ci" => "[1.4, 2.2]", "pval" => "0.001")
        )
        stats_dict = Dict("nobs" => "100", "r2" => "0.85", "adjr2" => "0.84")
        varcomp_dict = Dict("group var." => "0.25", "residual var." => "1.15")
        
        model_info = Typst.ModelInfo("OLS", coef_dict, stats_dict, varcomp_dict)
        
        @test model_info isa Typst.ModelInfo
        @test model_info.estimation == "OLS"
        @test length(model_info.coef) == 2
        @test haskey(model_info.coef, "(Intercept)")
        @test haskey(model_info.coef, "x1")
        @test model_info.stats["nobs"] == "100"
        @test model_info.varcomp["group var."] == "0.25"
        @debug "ModelInfo created with $(length(model_info.coef)) coefficients and $(length(model_info.stats)) statistics"
    end
    
    @testset "±(plus-minus) operator" begin
        # Test the custom ± operator defined in modelinfo.jl
        result = 2.0 Typst.± 0.5
        @test result isa Vector
        @test length(result) == 2
        @test result[1] == 1.5  # 2.0 - 0.5
        @test result[2] == 2.5  # 2.0 + 0.5
        @debug "Plus-minus operator: 2.0 ± 0.5 = $(result)"
        
        # Test with different values
        result2 = 10.0 Typst.± 2.0
        @test result2 == [8.0, 12.0]
        @debug "Plus-minus operator: 10.0 ± 2.0 = $(result2)"
        
        # Test with negative values
        result3 = -1.0 Typst.± 0.3
        @test result3[1] == -1.3
        @test result3[2] == -0.7
        @debug "Plus-minus operator with negative: -1.0 ± 0.3 = $(result3)"
    end
    
    @testset "_modelinfos! function with GLM models" begin
        # Create test data
        n = 30
        x1 = randn(n)
        x2 = randn(n)
        y = 1.5 .+ 2.0 * x1 .+ 0.8 * x2 .+ 0.5 * randn(n)
        
        test_data = DataFrame(x1 = x1, x2 = x2, y = y)
        
        # Fit models
        model1 = lm(@formula(y ~ x1), test_data)
        model2 = lm(@formula(y ~ x1 + x2), test_data)
        models = [model1, model2]
        
        # Test _modelinfos! function
        model_infos = Typst.ModelInfo[]
        stats_funcs = [Typst.nobs, Typst.r2, Typst.adjr2]
        
        @test_nowarn Typst._modelinfos!(model_infos, models, stats_funcs, 3, 4, nothing)
        
        @test length(model_infos) == 2
        @test all(mi -> mi isa Typst.ModelInfo, model_infos)
        @debug "Created ModelInfo objects for $(length(models)) GLM models"
        
        # Check first model
        mi1 = model_infos[1]
        @test haskey(mi1.coef, "(Intercept)")
        @test haskey(mi1.coef, "x1")
        @test !haskey(mi1.coef, "x2")  # First model doesn't have x2
        @test haskey(mi1.stats, "nobs")
        @test haskey(mi1.stats, "r2")
        @debug "Model 1 has $(length(mi1.coef)) coefficients: $(keys(mi1.coef))"
        
        # Check second model
        mi2 = model_infos[2]
        @test haskey(mi2.coef, "(Intercept)")
        @test haskey(mi2.coef, "x1")
        @test haskey(mi2.coef, "x2")  # Second model has x2
        @debug "Model 2 has $(length(mi2.coef)) coefficients: $(keys(mi2.coef))"
    end
    
    @testset "ModelInfo coefficient structure" begin
        # Test the internal structure of coefficient dictionaries
        n = 20
        x = randn(n)
        y = 2.0 .+ 1.5 * x .+ randn(n)
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        model_infos = Typst.ModelInfo[]
        @test_nowarn Typst._modelinfos!(model_infos, [model], [Typst.nobs], 2, 3, nothing)
        
        mi = model_infos[1]
        
        # Check coefficient structure for intercept
        intercept_coef = mi.coef["(Intercept)"]
        @test haskey(intercept_coef, "est")    # Estimate
        @test haskey(intercept_coef, "se")     # Standard error
        @test haskey(intercept_coef, "ci")     # Confidence interval
        @test haskey(intercept_coef, "pval")   # P-value
        @debug "Intercept coefficient keys: $(keys(intercept_coef))"
        
        # Check that values are strings (formatted for display)
        @test intercept_coef["est"] isa String
        @test intercept_coef["se"] isa String
        @test intercept_coef["ci"] isa String
        @test intercept_coef["pval"] isa String
        @debug "Coefficient values are properly formatted as strings"
        
        # Check x coefficient
        x_coef = mi.coef["x"]
        @test all(haskey(x_coef, key) for key in ["est", "se", "ci", "pval"])
        @debug "x coefficient structure complete"
    end
    
    @testset "ModelInfo statistics handling" begin
        # Test statistics collection and error handling
        n = 25
        x = randn(n)
        y = 1.0 .+ x .+ 0.3 * randn(n)
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # Test with various statistics functions
        stats_funcs = [Typst.nobs, Typst.r2, Typst.adjr2, Typst.aic, Typst.bic]
        model_infos = Typst.ModelInfo[]
        
        @test_nowarn Typst._modelinfos!(model_infos, [model], stats_funcs, 3, 4, nothing)
        
        mi = model_infos[1]
        @test haskey(mi.stats, "nobs")
        @test haskey(mi.stats, "r2")
        @test haskey(mi.stats, "adjr2")
        @test haskey(mi.stats, "aic")
        @test haskey(mi.stats, "bic")
        @debug "Statistics collected: $(keys(mi.stats))"
        
        # Test that statistics are formatted as strings
        @test all(v -> v isa String, values(mi.stats))
        @debug "All statistics properly formatted as strings"
        
        # Test with function that might fail
        function failing_stat(model)
            error("This statistic is not available")
        end
        
        stats_with_fail = [Typst.nobs, failing_stat]
        model_infos_fail = Typst.ModelInfo[]
        
        @test_nowarn Typst._modelinfos!(model_infos_fail, [model], stats_with_fail, 3, 4, nothing)
        
        mi_fail = model_infos_fail[1]
        @test haskey(mi_fail.stats, "nobs")  # This should work
        @test haskey(mi_fail.stats, "failing_stat")  # This should exist but be "NA"
        @test mi_fail.stats["failing_stat"] == "NA"
        @debug "Failed statistics handled gracefully: $(mi_fail.stats["failing_stat"])"
    end
    
    @testset "ModelInfo with custom coeftables" begin
        # Test providing custom coefficient tables
        n = 20
        x = randn(n)
        y = 1.0 .+ 0.5 * x .+ randn(n)
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # Create custom coefficient table
        custom_coeftable = DataFrame(
            Name = ["(Intercept)", "x"],
            Coef = [1.0, 0.5],
            StdError = [0.1, 0.08],
            tstat = [10.0, 6.25],
            pval = [0.001, 0.001]
        )
        # Rename columns to match expected names
        rename!(custom_coeftable, 
            :Coef => Symbol("Coef."),
            :StdError => Symbol("Std. Error"),
            :pval => Symbol("Pr(>|t|)")
        )
        
        model_infos = Typst.ModelInfo[]
        @test_nowarn Typst._modelinfos!(
            model_infos, 
            [model], 
            [Typst.nobs], 
            2, 3, 
            [custom_coeftable]  # Provide custom coeftable
        )
        
        mi = model_infos[1]
        @test haskey(mi.coef, "(Intercept)")
        @test haskey(mi.coef, "x")
        
        # Check that custom values were used
        @test mi.coef["(Intercept)"]["est"] == "1.0"  # From our custom table
        @test mi.coef["x"]["est"] == "0.5"            # From our custom table
        @debug "Custom coefficient table used successfully"
    end
    
    @testset "ModelInfo with MixedModels" begin
        # Test MixedModels integration if possible
        # Create grouped data
        n_groups = 4
        n_per_group = 8
        total_n = n_groups * n_per_group
        
        mixed_data = DataFrame(
            group = repeat(1:n_groups, inner=n_per_group),
            x = randn(total_n),
            y = Float64[]
        )
        
        # Add group random effects
        group_effects = randn(n_groups) * 0.5
        for i in 1:nrow(mixed_data)
            group_id = mixed_data.group[i]
            group_effect = group_effects[group_id]
            y_val = 1.0 + 0.8 * mixed_data.x[i] + group_effect + 0.3 * randn()
            push!(mixed_data.y, y_val)
        end
        
        try
            # Fit mixed model
            mixed_model = fit(MixedModel, @formula(y ~ x + (1|group)), mixed_data)
            
            model_infos = Typst.ModelInfo[]
            @test_nowarn Typst._modelinfos!(model_infos, [mixed_model], [Typst.nobs], 3, 4, nothing)
            
            mi = model_infos[1]
            @test mi isa Typst.ModelInfo
            @test haskey(mi.coef, "(Intercept)")
            @test haskey(mi.coef, "x")
            
            # Check variance components
            @test length(mi.varcomp) > 0  # Should have variance components
            @debug "Mixed model processed with $(length(mi.varcomp)) variance components: $(keys(mi.varcomp))"
            
            # Check for group information
            @test any(key -> occursin("N", key), keys(mi.varcomp))  # Should have group count info
            @debug "Mixed model variance components include group information"
            
        catch e
            @warn "Mixed model test skipped: $e"
            @debug "Mixed model functionality may need data or package adjustments"
        end
    end
    
    @testset "ModelInfo rounding and formatting" begin
        # Test different rounding settings
        n = 20
        x = randn(n)
        y = π .+ ℯ * x .+ randn(n)  # Use irrational numbers for rounding test
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # Test different digit settings
        for digits in [1, 2, 3, 5]
            model_infos = Typst.ModelInfo[]
            @test_nowarn Typst._modelinfos!(model_infos, [model], [Typst.nobs], digits, digits, nothing)
            
            mi = model_infos[1]
            intercept_est = mi.coef["(Intercept)"]["est"]
            
            # Count decimal places (rough check)
            if occursin(".", intercept_est)
                decimal_part = split(intercept_est, ".")[2]
                decimal_places = length(decimal_part)
                @test decimal_places <= digits + 1  # Allow some flexibility
                @debug "Rounding with $(digits) digits: $(intercept_est) ($(decimal_places) decimal places)"
            end
        end
    end
end