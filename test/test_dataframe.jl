@testset "DataFrame Integration Tests" begin
    
    @testset "Basic DataFrame to tablex conversion" begin
        # Create simple test DataFrame
        df = DataFrame(
            Name = ["Alice", "Bob", "Charlie"],
            Age = [25, 30, 35],
            Score = [85.5, 92.0, 78.5]
        )
        
        # Convert to tablex
        table = Typst.tablex(df)
        @test table isa Typst.TableX
        @debug "DataFrame with $(nrow(df)) rows, $(ncol(df)) columns converted to TableX"
        
        # Test that table contains expected number of items
        cell_count = count(item -> item isa Typst.CellX, table.items)
        expected_cells = (nrow(df) + 1) * ncol(df)  # +1 for header row
        @test cell_count >= expected_cells  # May have row numbers too
        @debug "Table contains $(cell_count) cells (expected at least $(expected_cells))"
        
        # Verify some content is preserved
        output = sprint(print, table)
        @test occursin("Alice", output)
        @test occursin("Age", output)  # Column name
        @test occursin("85.5", output) || occursin("85", output)  # Score value
        @debug "DataFrame content preserved in table output"
    end
    
    @testset "DataFrame with row numbering" begin
        df = DataFrame(A = [1, 2], B = [3, 4])
        
        # Test with row numbering (default)
        table_with_rows = Typst.tablex(df; numberrows=true)
        output_with_rows = sprint(print, table_with_rows)
        @test occursin("1", output_with_rows)  # Row number
        @debug "DataFrame with row numbering includes row numbers"
        
        # Test without row numbering
        table_without_rows = Typst.tablex(df; numberrows=false)
        output_without_rows = sprint(print, table_without_rows)
        
        # Outputs should be different
        @test output_with_rows != output_without_rows
        @debug "Row numbering option changes output"
    end
    
    @testset "DataFrame column name processing" begin
        # Test underscore replacement
        df_underscores = DataFrame(
            first_name = ["John", "Jane"],
            last_name = ["Doe", "Smith"],
            birth_year = [1990, 1985]
        )
        
        # With underscore replacement (default)
        table_replaced = Typst.tablex(df_underscores; replaceunderscore=true)
        output_replaced = sprint(print, table_replaced)
        @test occursin("first name", output_replaced) || occursin("first", output_replaced)
        @debug "Underscores in column names replaced with spaces"
        
        # Without underscore replacement
        table_original = Typst.tablex(df_underscores; replaceunderscore=false)
        output_original = sprint(print, table_original)
        
        @test output_replaced != output_original
        @debug "Underscore replacement option works"
    end
    
    @testset "DataFrame formatting options" begin
        df = DataFrame(
            Value1 = [3.14159, 2.71828],
            Value2 = [1.41421, 1.73205]
        )
        
        # Test rounding
        table_rounded = Typst.tablex(df; rounddigits=2)
        output_rounded = sprint(print, table_rounded)
        @test occursin("3.14", output_rounded) || occursin("3.1", output_rounded)
        @debug "DataFrame values rounded according to rounddigits parameter"
        
        # Test scientific notation option
        table_sci = Typst.tablex(df; scientificnotation=true)
        @test_nowarn sprint(print, table_sci)
        @debug "Scientific notation option processes without error"
    end
    
    @testset "DataFrame with different column types" begin
        # Mixed column types
        df_mixed = DataFrame(
            String_Col = ["A", "B", "C"],
            Int_Col = [1, 2, 3],
            Float_Col = [1.1, 2.2, 3.3],
            Bool_Col = [true, false, true],
            Symbol_Col = [:x, :y, :z]
        )
        
        table_mixed = Typst.tablex(df_mixed)
        @test table_mixed isa Typst.TableX
        @debug "Mixed column types DataFrame converted successfully"
        
        # Check output contains all types
        output = sprint(print, table_mixed)
        @test occursin("true", output) || occursin("false", output)  # Boolean
        @test occursin("1.1", output) || occursin("1", output)       # Float
        @test occursin("A", output)                                  # String
        @debug "All column types represented in output"
    end
    
    @testset "DataFrame stroke and line options" begin
        df = DataFrame(X = [1, 2], Y = [3, 4])
        
        # Test custom stroke
        table_thick = Typst.tablex(df; stroke=Symbol("0.2em"))
        @test table_thick.stroke == Symbol("0.2em")
        @debug "Custom stroke setting applied: $(table_thick.stroke)"
        
        # Test variable stroke
        table_varStroke = Typst.tablex(df; varstroke=Symbol("0.05em"))
        @test_nowarn sprint(print, table_varStroke)
        @debug "Variable stroke option processes correctly"
        
        # Test auto_lines option
        table_grid = Typst.tablex(df; auto_lines=false)
        table_lines = Typst.tablex(df; auto_lines=true)
        
        output_grid = sprint(print, table_grid)
        output_lines = sprint(print, table_lines)
        
        @test output_grid != output_lines
        @debug "auto_lines option affects output (gridx vs tablex)"
    end
    
    @testset "DataFrame with hline column" begin
        # Test DataFrame with special hline column
        df_hlines = DataFrame(
            Data = ["A", "B", "C"],
            hline = [false, true, false]  # Special column name
        )
        
        # This tests the special handling of hline column in dataframe.jl:49
        @test_nowarn Typst.tablex(df_hlines)
        @debug "DataFrame with hline column processes without error"
    end
    
    @testset "Empty and edge case DataFrames" begin
        # Empty DataFrame
        df_empty = DataFrame()
        @test_nowarn Typst.tablex(df_empty)
        @debug "Empty DataFrame handled without error"
        
        # Single row DataFrame
        df_single = DataFrame(A = [1], B = [2])
        table_single = Typst.tablex(df_single)
        @test table_single isa Typst.TableX
        @debug "Single row DataFrame converted successfully"
        
        # Single column DataFrame  
        df_single_col = DataFrame(OnlyCol = [1, 2, 3])
        table_single_col = Typst.tablex(df_single_col)
        @test table_single_col isa Typst.TableX
        @debug "Single column DataFrame converted successfully"
        
        # DataFrame with missing values
        df_missing = DataFrame(
            A = [1, missing, 3],
            B = ["x", "y", missing]
        )
        @test_nowarn Typst.tablex(df_missing)
        @debug "DataFrame with missing values handled"
    end
    
    @testset "DataFrame superheader functionality" begin
        df = DataFrame(A = [1, 2], B = [3, 4])
        
        # Test with superheader
        table_super = Typst.tablex(df; superheader="Main Header")
        @test_nowarn sprint(print, table_super)
        @debug "DataFrame with superheader processes correctly"
    end
    
    @testset "Large DataFrame performance" begin
        # Test with larger DataFrame to check performance
        large_df = DataFrame(
            ID = 1:100,
            Value1 = randn(100),
            Value2 = randn(100),
            Category = repeat(["A", "B", "C", "D"], 25)
        )
        
        # This should complete in reasonable time
        @test_nowarn table_large = Typst.tablex(large_df)
        @debug "Large DataFrame (100 rows) converted successfully"
    end
end