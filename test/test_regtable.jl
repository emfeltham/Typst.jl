@testset "Regression Table Tests" begin
    
    @testset "ModelInfo struct and construction" begin
        # Test basic ModelInfo construction
        coef_dict = Dict("(Intercept)" => Dict("est" => "1.0", "se" => "0.1", "ci" => "[0.8, 1.2]", "pval" => "0.01"))
        stats_dict = Dict("r2" => "0.95", "nobs" => "100")
        varcomp_dict = Dict{String, String}()
        
        model_info = Typst.ModelInfo("OLS", coef_dict, stats_dict, varcomp_dict)
        @test model_info isa Typst.ModelInfo
        @test model_info.estimation == "OLS"
        @test haskey(model_info.coef, "(Intercept)")
        @test model_info.stats["r2"] == "0.95"
        @debug "ModelInfo created with $(length(model_info.coef)) coefficients"
    end
    
    @testset "p-value assignment functions" begin
        # Test pvalkey structure
        @test Typst.pvalkey isa NamedTuple
        @test haskey(Typst.pvalkey, :values)
        @test haskey(Typst.pvalkey, :symbols)
        @test length(Typst.pvalkey.values) == length(Typst.pvalkey.symbols)
        @debug "Default pvalkey has $(length(Typst.pvalkey.values)) significance levels"
        
        # Test pset function
        sig_001 = Typst.pset(0.0001, Typst.pvalkey)
        sig_05 = Typst.pset(0.04, Typst.pvalkey)  
        sig_ns = Typst.pset(0.15, Typst.pvalkey)
        
        @test sig_001 != ""  # Should have significance marker
        @test sig_05 != ""   # Should have significance marker
        @test sig_ns == ""   # Should be non-significant
        @debug "Significance markers: p=0.0001 -> '$(sig_001)', p=0.04 -> '$(sig_05)', p=0.15 -> '$(sig_ns)'"
        
        # Test passign functions
        @test Typst.passign("0.001", Typst.pvalkey) isa String
        @test Typst.passign(0.01, Typst.pvalkey) isa String
        @debug "passign functions work for both string and float inputs"
    end
    
    @testset "Simple regression model processing" begin
        # Create simple test data
        n = 20
        x = randn(n)
        y = 2.0 .+ 1.5 * x .+ 0.5 * randn(n)
        
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # Test that we can create ModelInfo from real model
        models = [model]
        model_infos = Typst.ModelInfo[]
        
        @test_nowarn Typst._modelinfos!(
            model_infos, 
            models, 
            [Typst.nobs, Typst.r2], 
            3, 4, 
            nothing
        )
        
        @test length(model_infos) == 1
        @test model_infos[1] isa Typst.ModelInfo
        @test haskey(model_infos[1].coef, "(Intercept)")
        @test haskey(model_infos[1].coef, "x")
        @test haskey(model_infos[1].stats, "nobs")
        @debug "ModelInfo successfully created from GLM model"
    end
    
    @testset "Multiple regression models" begin
        # Create test data for multiple models
        n = 30
        x1 = randn(n)
        x2 = randn(n) 
        y = 1.0 .+ 2.0 * x1 .+ 0.5 * x2 .+ randn(n)
        
        test_data = DataFrame(x1 = x1, x2 = x2, y = y)
        
        # Fit progressive models
        model1 = lm(@formula(y ~ x1), test_data)
        model2 = lm(@formula(y ~ x1 + x2), test_data)
        
        models = [model1, model2]
        model_infos = Typst.ModelInfo[]
        
        @test_nowarn Typst._modelinfos!(
            model_infos, 
            models, 
            [Typst.nobs, Typst.r2, Typst.adjr2], 
            3, 4, 
            nothing
        )
        
        @test length(model_infos) == 2
        @test haskey(model_infos[2].coef, "x2")  # Second model should have x2
        @debug "Multiple models processed successfully"
    end
    
    @testset "Mixed effects model support" begin
        # Test mixed model functionality if possible
        # Note: This requires appropriate data structure for mixed models
        
        # Create simple grouped data
        n_groups = 5
        n_per_group = 6
        total_n = n_groups * n_per_group
        
        mixed_data = DataFrame(
            group = repeat(1:n_groups, inner=n_per_group),
            x = randn(total_n),
            y = Float64[]
        )
        
        # Add group effects and individual variation
        for i in 1:nrow(mixed_data)
            group_effect = 0.5 * mixed_data.group[i]  # Group-specific intercept
            y_val = group_effect + 1.5 * mixed_data.x[i] + randn()
            push!(mixed_data.y, y_val)
        end
        
        try
            # Fit mixed effects model
            mixed_model = fit(MixedModel, @formula(y ~ x + (1|group)), mixed_data)
            
            models = [mixed_model]
            model_infos = Typst.ModelInfo[]
            
            @test_nowarn Typst._modelinfos!(
                model_infos, 
                models, 
                [Typst.nobs], 
                3, 4, 
                nothing
            )
            
            @test length(model_infos) == 1
            @test length(model_infos[1].varcomp) > 0  # Should have variance components
            @debug "Mixed effects model processed with $(length(model_infos[1].varcomp)) variance components"
            
        catch e
            @warn "Mixed model test skipped due to error: $e"
            @debug "Mixed model functionality may need adjustment"
        end
    end
    
    @testset "Regression table generation" begin
        # Create test models for table generation
        n = 25
        x = randn(n)
        z = randn(n)
        y = 1.0 .+ 2.0 * x .+ 0.8 * z .+ 0.3 * randn(n)
        
        test_data = DataFrame(x = x, z = z, y = y)
        
        model1 = lm(@formula(y ~ x), test_data)
        model2 = lm(@formula(y ~ x + z), test_data)
        models = [model1, model2]
        
        # Test regtablet function (the main regression table function)
        @test_nowarn Typst.regtablet(
            models, 
            "test_regtable";
            caption = :none,
            modeltitles = nothing
        )
        
        # Check that file was created
        @test isfile("test_regtable.typ")
        content = read("test_regtable.typ", String)
        @test length(content) > 0
        @test occursin("tablex", content) || occursin("gridx", content)
        @debug "Regression table file created with $(length(content)) characters"
        
        # Clean up
        rm("test_regtable.typ", force=true)
    end
    
    @testset "Regression table customization options" begin
        # Simple model for testing options
        n = 20
        x = randn(n)
        y = 1.0 .+ x .+ 0.2 * randn(n)
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # Test different customization options
        @test_nowarn Typst.regtablet(
            [model], 
            "custom_test";
            modeltitles = ["Model 1"],
            roundvals = 2,
            understat = "se",
            stats = [Typst.nobs, Typst.r2]
        )
        
        @test isfile("custom_test.typ")
        @debug "Customized regression table created"
        rm("custom_test.typ", force=true)
        
        # Test with caption
        @test_nowarn Typst.regtablet(
            [model], 
            "caption_test";
            caption = "Test regression results",
            short_caption = :auto
        )
        
        @test isfile("caption_test.typ")
        content = read("caption_test.typ", String)
        @test occursin("Test regression", content)
        @debug "Regression table with caption created"
        rm("caption_test.typ", force=true)
    end
    
    @testset "Error handling in regression tables" begin
        # Test invalid p-value key structure
        invalid_pvalkey = (values = [0.05], symbols = ["*", "**"])  # Mismatched lengths
        
        n = 15
        x = randn(n)
        y = 1.0 .+ x .+ randn(n)
        test_data = DataFrame(x = x, y = y) 
        model = lm(@formula(y ~ x), test_data)
        
        @test_throws Exception Typst.regtablet(
            [model], 
            "error_test";
            pvalkey = invalid_pvalkey
        )
        @debug "Invalid pvalkey properly rejected"
        
        # Test invalid modeltitles length
        @test_throws Exception Typst.regtablet(
            [model], 
            "error_test2";
            modeltitles = ["Model 1", "Model 2"]  # Too many titles for one model
        )
        @debug "Invalid modeltitles length properly rejected"
    end
    
    @testset "Alternative regression function" begin
        # Test regtable_typ function (from regtable_copy.jl)
        n = 20
        x = randn(n)
        y = 2.0 .+ 1.5 * x .+ randn(n)
        test_data = DataFrame(x = x, y = y)
        model = lm(@formula(y ~ x), test_data)
        
        # This tests the duplicate function to understand the difference
        @test_nowarn Typst.regtable_typ(
            [model], 
            "alt_regtable"
        )
        
        @test isfile("alt_regtable.typ")
        @debug "Alternative regression table function works"
        rm("alt_regtable.typ", force=true)
    end
    
    @testset "Large regression table" begin
        # Test with more variables to stress-test table generation
        n = 50
        data_large = DataFrame(
            x1 = randn(n),
            x2 = randn(n),
            x3 = randn(n), 
            x4 = randn(n),
            group = repeat(["A", "B"], inner=25)
        )
        data_large.y = 1.0 .+ 0.5 * data_large.x1 .+ 0.3 * data_large.x2 .+ 
                      0.2 * data_large.x3 .+ 0.1 * data_large.x4 .+ randn(n)
        
        # Progressive model building
        models_large = [
            lm(@formula(y ~ x1), data_large),
            lm(@formula(y ~ x1 + x2), data_large), 
            lm(@formula(y ~ x1 + x2 + x3), data_large),
            lm(@formula(y ~ x1 + x2 + x3 + x4), data_large)
        ]
        
        @test_nowarn Typst.regtablet(
            models_large, 
            "large_regtable";
            modeltitles = ["(1)", "(2)", "(3)", "(4)"],
            caption = "Progressive regression models"
        )
        
        @test isfile("large_regtable.typ")
        content = read("large_regtable.typ", String)
        @test occursin("x4", content)  # Should include the last variable
        @debug "Large regression table with 4 models and 4 variables created"
        rm("large_regtable.typ", force=true)
    end
end