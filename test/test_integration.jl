@testset "Integration Tests" begin
    
    @testset "Complete DataFrame to Typst workflow" begin
        # Simulate a complete research workflow
        
        # 1. Create research data
        n = 50
        research_data = DataFrame(
            participant_id = 1:n,
            treatment = rand([0, 1], n),
            age = rand(18:70, n),
            baseline_score = randn(n) .+ 50,
            followup_score = Float64[]
        )
        
        # Add treatment effect to followup scores
        for row in eachrow(research_data)
            treatment_effect = row.treatment * 5.0  # Treatment adds 5 points
            age_effect = (row.age - 40) * 0.1       # Age effect
            noise = randn() * 2.0                   # Random variation
            followup = row.baseline_score + treatment_effect + age_effect + noise
            push!(research_data.followup_score, followup)
        end
        
        @test nrow(research_data) == n
        @debug "Research dataset created with $(nrow(research_data)) participants"
        
        # 2. Create descriptive statistics table
        desc_stats = DataFrame(
            Variable = ["Treatment", "Age", "Baseline", "Followup"],
            Mean = [
                mean(research_data.treatment),
                mean(research_data.age),
                mean(research_data.baseline_score),
                mean(research_data.followup_score)
            ],
            SD = [
                std(research_data.treatment),
                std(research_data.age),
                std(research_data.baseline_score),
                std(research_data.followup_score)
            ]
        )
        
        # Round values for presentation
        for col in [:Mean, :SD]
            desc_stats[!, col] = round.(desc_stats[!, col], digits=2)
        end
        
        desc_table = Typst.tablex(desc_stats)
        
        @test_nowarn Typst.table_export(
            "integration_descriptive",
            desc_table;
            caption = "Descriptive statistics for treatment study variables",
            short_caption = "Descriptive Statistics"
        )
        
        @test isfile("integration_descriptive.typ")
        @debug "Descriptive statistics table exported successfully"
        
        # 3. Fit regression models
        model1 = lm(@formula(followup_score ~ treatment), research_data)
        model2 = lm(@formula(followup_score ~ treatment + age), research_data)
        model3 = lm(@formula(followup_score ~ treatment + age + baseline_score), research_data)
        
        models = [model1, model2, model3]
        
        @test_nowarn Typst.regtablet(
            models,
            "integration_regression";
            modeltitles = ["Bivariate", "Age Control", "Full Model"],
            caption = "Treatment effects on followup scores with progressive controls",
            short_caption = "Treatment Effects"
        )
        
        @test isfile("integration_regression.typ")
        @debug "Regression table exported successfully"
        
        # 4. Verify all files contain expected content
        desc_content = read("integration_descriptive.typ", String)
        @test occursin("Descriptive statistics", desc_content)
        @test occursin("Treatment", desc_content)
        @test occursin("tablex", desc_content) || occursin("gridx", desc_content)
        
        reg_content = read("integration_regression.typ", String)
        @test occursin("treatment", reg_content)
        @test occursin("Full Model", reg_content)
        @test occursin("tablex", reg_content) || occursin("gridx", reg_content)
        
        @debug "Integration workflow: descriptive table ($(length(desc_content)) chars), regression table ($(length(reg_content)) chars)"
        
        # Cleanup
        rm("integration_descriptive.typ", force=true)
        rm("integration_regression.typ", force=true)
    end
    
    @testset "Mixed table and figure workflow" begin
        # Create data for both table and figure
        analysis_data = DataFrame(
            group = repeat(["Control", "Treatment"], inner=20),
            outcome = vcat(randn(20) .+ 10, randn(20) .+ 12),  # Treatment effect
            covariate = randn(40)
        )
        
        # 1. Summary table by group
        summary_stats = combine(groupby(analysis_data, :group), 
            :outcome => mean => :mean_outcome,
            :outcome => std => :sd_outcome,
            :covariate => mean => :mean_covariate
        )
        
        # Round for presentation
        for col in [:mean_outcome, :sd_outcome, :mean_covariate]
            summary_stats[!, col] = round.(summary_stats[!, col], digits=2)
        end
        
        summary_table = Typst.tablex(summary_stats)
        
        @test_nowarn Typst.table_export(
            "mixed_workflow_table",
            summary_table;
            caption = "Summary statistics by treatment group"
        )
        
        @test isfile("mixed_workflow_table.typ")
        @debug "Summary table created for mixed workflow"
        
        # 2. Mock figure creation (simulating a plot)
        function mock_plot_save(filename, fig; dpi=300, kwargs...)
            # Simulate creating a plot file
            open(filename, "w") do io
                write(io, "Mock plot data showing group comparison with DPI=$dpi")
            end
        end
        
        mock_plot = "group_comparison_plot"
        
        @test_nowarn Typst.figure_export(
            "mixed_workflow_figure.png",
            mock_plot,
            mock_plot_save;
            caption = "Comparison of outcome measures between control and treatment groups",
            short_caption = "Group Comparison",
            dpi = 150
        )
        
        @test isfile("mixed_workflow_figure.typ")
        @test isfile("mixed_workflow_figure.png")
        @debug "Figure created for mixed workflow"
        
        # 3. Statistical analysis
        t_test_model = lm(@formula(outcome ~ group), analysis_data)
        
        @test_nowarn Typst.regtablet(
            [t_test_model],
            "mixed_workflow_stats";
            caption = "Statistical test of group differences"
        )
        
        @test isfile("mixed_workflow_stats.typ")
        @debug "Statistical analysis completed for mixed workflow"
        
        # 4. Verify integration
        table_content = read("mixed_workflow_table.typ", String)
        figure_content = read("mixed_workflow_figure.typ", String)
        stats_content = read("mixed_workflow_stats.typ", String)
        
        @test occursin("Treatment", table_content)
        @test occursin("mixed_workflow_figure.png", figure_content)
        @test occursin("group", stats_content)
        
        # Check that figure file has expected mock content
        plot_data = read("mixed_workflow_figure.png", String)
        @test occursin("DPI=150", plot_data)
        @debug "Mixed workflow files contain expected content"
        
        # Cleanup
        rm("mixed_workflow_table.typ", force=true)
        rm("mixed_workflow_figure.typ", force=true)
        rm("mixed_workflow_figure.png", force=true)
        rm("mixed_workflow_stats.typ", force=true)
    end
    
    @testset "Complex nested directory workflow" begin
        # Test workflow with organized directory structure
        
        # Create directory structure
        mkpath("integration_test/tables")
        mkpath("integration_test/figures") 
        mkpath("integration_test/analysis")
        
        try
            # Simple dataset
            nested_data = DataFrame(
                var1 = randn(25),
                var2 = randn(25),
                var3 = rand(["A", "B", "C"], 25)
            )
            
            # 1. Export table to tables subdirectory
            data_table = Typst.tablex(nested_data)
            @test_nowarn Typst.table_export(
                "integration_test/tables/dataset",
                data_table;
                caption = "Primary dataset for analysis"
            )
            
            @test isfile("integration_test/tables/dataset.typ")
            @debug "Table exported to nested directory structure"
            
            # 2. Export figure to figures subdirectory
            function nested_save(filename, fig; kwargs...)
                dir = dirname(filename)
                mkpath(dir)  # Ensure directory exists
                open(filename, "w") do io
                    write(io, "Nested figure data for analysis")
                end
            end
            
            mock_analysis_plot = "correlation_plot"
            @test_nowarn Typst.figure_export(
                "integration_test/figures/correlation.svg",
                mock_analysis_plot,
                nested_save;
                caption = "Correlation analysis of primary variables"
            )
            
            @test isfile("integration_test/figures/correlation.typ")
            @test isfile("integration_test/figures/correlation.svg")
            @debug "Figure exported to nested directory structure"
            
            # 3. Export analysis to analysis subdirectory  
            analysis_model = lm(@formula(var1 ~ var2), nested_data)
            @test_nowarn Typst.regtablet(
                [analysis_model],
                "integration_test/analysis/correlation_model";
                caption = "Regression analysis of variable relationships"
            )
            
            @test isfile("integration_test/analysis/correlation_model.typ")
            @debug "Analysis exported to nested directory structure"
            
            # 4. Verify directory organization
            tables_files = readdir("integration_test/tables")
            figures_files = readdir("integration_test/figures")
            analysis_files = readdir("integration_test/analysis")
            
            @test "dataset.typ" in tables_files
            @test "correlation.typ" in figures_files
            @test "correlation.svg" in figures_files
            @test "correlation_model.typ" in analysis_files
            
            @debug "Directory organization: tables=$(length(tables_files)), figures=$(length(figures_files)), analysis=$(length(analysis_files))"
            
        finally
            # Cleanup
            rm("integration_test", recursive=true, force=true)
        end
    end
    
    @testset "Cross-reference integration" begin
        # Test that exported files generate proper labels for cross-referencing
        
        simple_data = DataFrame(A = [1, 2], B = [3, 4])
        simple_table = Typst.tablex(simple_data)
        
        # Export with specific names for cross-referencing
        @test_nowarn Typst.table_export(
            "results_table",
            simple_table;
            caption = "Main results table"
        )
        
        # Mock figure with cross-referenceable name
        function ref_save(filename, fig; kwargs...)
            open(filename, "w") do io
                write(io, "Figure for cross-referencing")
            end
        end
        
        @test_nowarn Typst.figure_export(
            "results_figure.png",
            "mock_fig",
            ref_save;
            caption = "Main results figure"
        )
        
        # Check that files contain proper labels
        table_content = read("results_table.typ", String)
        figure_content = read("results_figure.typ", String)
        
        @test occursin("<results_table>", table_content) || occursin("results_table", table_content)
        @test occursin("<results_figure>", figure_content) || occursin("results_figure", figure_content)
        @debug "Cross-reference labels properly generated"
        
        # Cleanup
        rm("results_table.typ", force=true)
        rm("results_figure.typ", force=true)
        rm("results_figure.png", force=true)
    end
    
    @testset "Error recovery in workflow" begin
        # Test that workflow continues after individual failures
        
        good_data = DataFrame(X = [1, 2], Y = [3, 4])
        good_table = Typst.tablex(good_data)
        
        # This should work
        @test_nowarn Typst.table_export("recovery_good", good_table)
        @test isfile("recovery_good.typ")
        
        # Test recovery after error
        function failing_save(filename, fig; kwargs...)
            error("Simulated save failure")
        end
        
        # This should fail
        @test_throws Exception Typst.figure_export(
            "recovery_bad.png",
            "mock",
            failing_save
        )
        
        # But this should still work after the failure
        @test_nowarn Typst.table_export("recovery_after", good_table)
        @test isfile("recovery_after.typ")
        
        @debug "Workflow continues properly after individual component failures"
        
        # Cleanup
        rm("recovery_good.typ", force=true)
        rm("recovery_after.typ", force=true)
    end
    
    @testset "Memory and performance integration" begin
        # Test workflow with larger datasets to check memory handling
        
        # Create moderately large dataset
        large_n = 500
        perf_data = DataFrame(
            id = 1:large_n,
            group = repeat(["A", "B", "C"], inner=div(large_n, 3)),
            value1 = randn(large_n),
            value2 = randn(large_n),
            outcome = randn(large_n)
        )
        
        # Add some structure to the data
        for i in 1:nrow(perf_data)
            if perf_data.group[i] == "B"
                perf_data.outcome[i] += 1.0  # Group B has higher outcomes
            elseif perf_data.group[i] == "C"
                perf_data.outcome[i] += 0.5  # Group C has moderately higher outcomes
            end
        end
        
        @debug "Performance test data created: $(nrow(perf_data)) rows"
        
        # Test table export performance
        perf_table = Typst.tablex(perf_data[1:20, :])  # Subset for reasonable table size
        
        start_time = time()
        @test_nowarn Typst.table_export("perf_table", perf_table)
        table_time = time() - start_time
        
        @test isfile("perf_table.typ")
        @debug "Table export completed in $(round(table_time, digits=3)) seconds"
        
        # Test regression analysis performance
        perf_models = [
            lm(@formula(outcome ~ group), perf_data),
            lm(@formula(outcome ~ group + value1), perf_data),
            lm(@formula(outcome ~ group + value1 + value2), perf_data)
        ]
        
        start_time = time()
        @test_nowarn Typst.regtablet(perf_models, "perf_regression")
        reg_time = time() - start_time
        
        @test isfile("perf_regression.typ")
        @debug "Regression table export completed in $(round(reg_time, digits=3)) seconds"
        
        # Verify reasonable performance (should complete quickly)
        @test table_time < 5.0   # Should take less than 5 seconds
        @test reg_time < 10.0    # Should take less than 10 seconds
        
        # Cleanup
        rm("perf_table.typ", force=true)
        rm("perf_regression.typ", force=true)
    end
end