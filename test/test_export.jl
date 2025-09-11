@testset "Export Function Tests" begin
    
    @testset "table_export function" begin
        # Create simple table for export
        df = DataFrame(
            Variable = ["A", "B", "C"],
            Value = [1.1, 2.2, 3.3],
            Category = ["X", "Y", "Z"]
        )
        table = Typst.tablex(df)
        
        # Test basic table export
        @test_nowarn Typst.table_export("test_table", table)
        @test isfile("test_table.typ")
        
        content = read("test_table.typ", String)
        @test length(content) > 0
        @test occursin("tablex", content) || occursin("gridx", content)
        @test occursin("import", content)  # Should have tablex import
        @debug "Basic table export created file with $(length(content)) characters"
        
        rm("test_table.typ", force=true)
    end
    
    @testset "table_export with captions" begin
        # Simple table
        cells = [Typst.CellX(0, 0, "Data")]
        table = Typst.tablex(cells)
        
        # Test with long caption
        @test_nowarn Typst.table_export(
            "caption_table",
            table;
            caption = "This is a detailed caption explaining the table contents and methodology.",
            short_caption = "Summary Table"
        )
        
        @test isfile("caption_table.typ")
        content = read("caption_table.typ", String)
        @test occursin("detailed caption", content)
        @test occursin("flex-caption", content)  # Should include short caption function
        @debug "Table export with captions includes caption text and flex-caption function"
        
        rm("caption_table.typ", force=true)
    end
    
    @testset "table_export configuration options" begin
        df = DataFrame(X = [1, 2], Y = [3, 4])
        table = Typst.tablex(df)
        
        # Test different configuration options
        @test_nowarn Typst.table_export(
            "config_table",
            table;
            placement = :top,
            kind = :table,
            supplement = :none,
            numbering = "I",
            gap = Symbol("0.8em"),
            outlined = false
        )
        
        @test isfile("config_table.typ")
        @debug "Table export with custom configuration works"
        rm("config_table.typ", force=true)
        
        # Test with extra content
        @test_nowarn Typst.table_export(
            "extra_table",
            table;
            extra = "#let custom_var = 42"
        )
        
        content = read("extra_table.typ", String)
        @test occursin("custom_var", content)
        @debug "Table export with extra content includes custom code"
        rm("extra_table.typ", force=true)
    end
    
    @testset "figure_export function" begin
        # Mock a simple "figure" object for testing
        # Since we can't create actual Makie figures in this test context,
        # we'll test the interface and file creation
        
        # Create a mock save function
        function mock_save(filename, fig; kwargs...)
            # Just create a dummy file to simulate saving
            open(filename, "w") do io
                write(io, "mock image data")
            end
            @debug "Mock save created: $filename"
        end
        
        mock_figure = "dummy_figure_object"
        
        # Test basic figure export
        @test_nowarn Typst.figure_export(
            "test_figure.png",
            mock_figure,
            mock_save;
            caption = "Test figure caption"
        )
        
        @test isfile("test_figure.typ")
        @test isfile("test_figure.png")
        
        typ_content = read("test_figure.typ", String)
        @test occursin("test_figure.png", typ_content)
        @test occursin("Test figure caption", typ_content)
        @test occursin("image", typ_content)
        @debug "Figure export created both .typ and image files"
        
        rm("test_figure.typ", force=true)
        rm("test_figure.png", force=true)
    end
    
    @testset "figure_export with short captions" begin
        function mock_save(filename, fig; kwargs...)
            open(filename, "w") do io
                write(io, "mock data")
            end
        end
        
        mock_figure = "dummy"
        
        # Test with both long and short captions
        @test_nowarn Typst.figure_export(
            "short_cap_figure.svg",
            mock_figure,
            mock_save;
            caption = "This is a long detailed caption explaining the figure.",
            short_caption = "Short Caption"
        )
        
        @test isfile("short_cap_figure.typ")
        @test isfile("short_cap_figure.svg")
        
        content = read("short_cap_figure.typ", String)
        @test occursin("flex-caption", content)
        @test occursin("Short Caption", content)
        @debug "Figure export with short caption includes flex-caption function"
        
        rm("short_cap_figure.typ", force=true)
        rm("short_cap_figure.svg", force=true)
    end
    
    @testset "figure_export automatic short caption" begin
        function mock_save(filename, fig; kwargs...)
            open(filename, "w") do io
                write(io, "mock data")
            end
        end
        
        mock_figure = "dummy"
        
        # Test with auto short caption
        @test_nowarn Typst.figure_export(
            "auto_cap_figure.pdf",
            mock_figure,
            mock_save;
            caption = "First sentence of caption. Second sentence with more details.",
            short_caption = :auto
        )
        
        @test isfile("auto_cap_figure.typ")
        content = read("auto_cap_figure.typ", String)
        # With :auto, it should still include the flex-caption setup
        @test occursin("flex-caption", content)
        @debug "Figure export with automatic short caption processes correctly"
        
        rm("auto_cap_figure.typ", force=true)
        rm("auto_cap_figure.pdf", force=true)
    end
    
    @testset "figure_export path handling" begin
        function mock_save(filename, fig; kwargs...)
            # Ensure directory exists
            dir = dirname(filename)
            if !isempty(dir) && !isdir(dir)
                mkpath(dir)
            end
            open(filename, "w") do io
                write(io, "mock data")
            end
        end
        
        mock_figure = "dummy"
        
        # Test with subdirectory path
        @test_nowarn Typst.figure_export(
            "figures/subdir/nested_figure.png",
            mock_figure,
            mock_save;
            caption = "Nested figure"
        )
        
        @test isfile("figures/subdir/nested_figure.typ")
        @test isfile("figures/subdir/nested_figure.png")
        @debug "Figure export handles nested directory paths"
        
        rm("figures", recursive=true, force=true)
    end
    
    @testset "Export function error conditions" begin
        df = DataFrame(A = [1])
        table = Typst.tablex(df)
        
        # Test table export to invalid location (should handle gracefully or error appropriately)
        # This tests error handling in the export functions
        
        # Test with invalid parameters
        @test_throws Exception Typst.table_export(
            "error_test",
            table;
            placement = :invalid_placement
        )
        @debug "Invalid placement parameter properly rejected in table_export"
        
        # Test figure export error conditions
        function failing_save(filename, fig; kwargs...)
            error("Mock save failure")
        end
        
        mock_figure = "dummy"
        
        # This should error during the save operation
        @test_throws Exception Typst.figure_export(
            "failing_figure.png",
            mock_figure,
            failing_save;
            caption = "This should fail"
        )
        @debug "Figure export properly propagates save function errors"
    end
    
    @testset "Export with custom save kwargs" begin
        function kwargs_save(filename, fig; test_kwarg=nothing, other_kwarg=42, kwargs...)
            @test test_kwarg == "test_value"
            @test other_kwarg == 100  # Should be overridden
            open(filename, "w") do io
                write(io, "saved with kwargs: $(test_kwarg), $(other_kwarg)")
            end
        end
        
        mock_figure = "dummy"
        
        @test_nowarn Typst.figure_export(
            "kwargs_figure.png",
            mock_figure,
            kwargs_save;
            caption = "Figure with kwargs",
            test_kwarg = "test_value",
            other_kwarg = 100
        )
        
        @test isfile("kwargs_figure.png")
        content = read("kwargs_figure.png", String)
        @test occursin("test_value", content)
        @test occursin("100", content)
        @debug "Figure export properly passes through save kwargs"
        
        rm("kwargs_figure.typ", force=true)
        rm("kwargs_figure.png", force=true)
    end
    
    @testset "Export file cleanup and organization" begin
        # Test that exports don't leave temporary files or create unexpected outputs
        
        df = DataFrame(Clean = ["test"], Up = ["data"])
        table = Typst.tablex(df)
        
        # Count files before export
        files_before = readdir(".")
        
        @test_nowarn Typst.table_export("cleanup_test", table; caption="Clean test")
        
        # Check that only expected files were created
        files_after = readdir(".")
        new_files = setdiff(files_after, files_before)
        
        @test "cleanup_test.typ" in new_files
        @test length(new_files) == 1  # Should only create the one expected file
        @debug "Export creates only expected files: $(new_files)"
        
        rm("cleanup_test.typ", force=true)
    end
    
    @testset "Large export stress test" begin
        # Test export with larger data to check performance and memory usage
        large_df = DataFrame(
            ID = 1:200,
            Value1 = randn(200),
            Value2 = randn(200),
            Category = repeat(["A", "B", "C", "D"], 50),
            Description = ["Row $i description" for i in 1:200]
        )
        
        large_table = Typst.tablex(large_df)
        
        @test_nowarn Typst.table_export(
            "large_export_test",
            large_table;
            caption = "Large table with 200 rows and 5 columns"
        )
        
        @test isfile("large_export_test.typ")
        content = read("large_export_test.typ", String)
        @test length(content) > 10000  # Should be substantial content
        @test occursin("Row 200", content)  # Should include last row
        @debug "Large table export completed: $(length(content)) characters"
        
        rm("large_export_test.typ", force=true)
    end
end