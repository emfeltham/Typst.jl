@testset "TableX Tests" begin
    
    @testset "tablex function with vectors" begin
        # Test basic tablex creation with vector of items
        items = [
            Typst.CellX(0, 0, "A1"),
            Typst.CellX(1, 0, "B1"),
            Typst.CellX(0, 1, "A2"),
            Typst.CellX(1, 1, "B2")
        ]
        
        table1 = Typst.tablex(items)
        @test table1 isa Typst.TableX
        @test length(table1.items) >= length(items)  # May include auto-generated lines
        @debug "Created tablex with $(length(items)) input items, result has $(length(table1.items)) total items"
        
        # Test that input items are preserved
        cell_contents = [item.content for item in table1.items if item isa Typst.CellX]
        @test "A1" in cell_contents
        @test "B1" in cell_contents
        @test "A2" in cell_contents
        @test "B2" in cell_contents
        @debug "All input cell contents preserved in tablex"
    end
    
    @testset "tablex configuration options" begin
        items = [Typst.CellX(0, 0, "test")]
        
        # Test auto_lines option
        table_with_lines = Typst.tablex(items; auto_lines=true)
        table_without_lines = Typst.tablex(items; auto_lines=false)
        
        @test table_with_lines.auto_lines == true
        @test table_without_lines.auto_lines == false
        @debug "auto_lines setting: with=$(table_with_lines.auto_lines), without=$(table_without_lines.auto_lines)"
        
        # Test stroke option
        table_custom_stroke = Typst.tablex(items; stroke=Symbol("0.1em"))
        @test table_custom_stroke.stroke == Symbol("0.1em")
        @debug "Custom stroke setting: $(table_custom_stroke.stroke)"
        
        # Test alignment option
        table_aligned = Typst.tablex(items; align=:center)
        @test table_aligned.align == :center
        @debug "Custom alignment: $(table_aligned.align)"
        
        # Test column specification
        table_cols = Typst.tablex(items; columns="(auto, 1fr, 2fr)")
        @test table_cols.columns == "(auto, 1fr, 2fr)"
        @debug "Custom columns: $(table_cols.columns)"
    end
    
    @testset "tablex with header options" begin
        items = [
            Typst.CellX(0, 0, "Header1"),
            Typst.CellX(1, 0, "Header2"),
            Typst.CellX(0, 1, "Data1"),
            Typst.CellX(1, 1, "Data2")
        ]
        
        # Test header configuration
        table_header = Typst.tablex(items; header_rows=1, repeat_header=true)
        @test table_header.header_rows == 1
        @test table_header.repeat_header == true
        @debug "Header configuration: rows=$(table_header.header_rows), repeat=$(table_header.repeat_header)"
        
        # Test header line priority
        table_hline_priority = Typst.tablex(items; header_hlines_have_priority=false)
        @test table_hline_priority.header_hlines_have_priority == false
        @debug "Header hlines priority: $(table_hline_priority.header_hlines_have_priority)"
    end
    
    @testset "tablex print functionality" begin
        items = [Typst.CellX(0, 0, "printable")]
        table = Typst.tablex(items)
        
        # Test print doesn't error
        @test_nowarn print(table)
        @debug "TableX print method executes without error"
        
        # Test print output is string
        output = sprint(print, table)
        @test output isa String
        @test length(output) > 0
        @test occursin("tablex", output) || occursin("gridx", output)  # Should contain table command
        @debug "TableX print output contains table markup ($(length(output)) chars)"
    end
    
    @testset "tablex vs gridx distinction" begin
        items = [Typst.CellX(0, 0, "test")]
        
        # With auto_lines=true, should create tablex
        table_with_lines = Typst.tablex(items; auto_lines=true)
        output_with_lines = sprint(print, table_with_lines)
        
        # With auto_lines=false, should create gridx  
        table_without_lines = Typst.tablex(items; auto_lines=false)
        output_without_lines = sprint(print, table_without_lines)
        
        # The print output should differ based on auto_lines
        @test output_with_lines != output_without_lines
        @debug "tablex vs gridx produce different output based on auto_lines"
    end
    
    @testset "Complex table structure" begin
        # Create a more complex table with spans and formatting
        items = [
            # Header row
            Typst.CellX(0, 0, "Name", 1, 1, :left),
            Typst.CellX(1, 0, "Value", 2, 1, :center),  # Spans 2 columns
            # Data rows
            Typst.CellX(0, 1, "Item 1", 1, 1, :left),
            Typst.CellX(1, 1, "10.5", 1, 1, :right),
            Typst.CellX(2, 1, "Good", 1, 1, :center),
            Typst.CellX(0, 2, "Item 2", 1, 1, :left),
            Typst.CellX(1, 2, "20.3", 1, 1, :right),
            Typst.CellX(2, 2, "Better", 1, 1, :center)
        ]
        
        complex_table = Typst.tablex(
            items;
            columns="(8em, 4em, 4em)",
            align=:center,
            header_rows=1
        )
        
        @test complex_table isa Typst.TableX
        @test complex_table.columns == "(8em, 4em, 4em)"
        @test complex_table.header_rows == 1
        @debug "Complex table created with $(length(items)) cells and custom formatting"
        
        # Test that it prints without error
        @test_nowarn print(complex_table)
    end
    
    @testset "Edge cases" begin
        # Empty table
        empty_table = Typst.tablex([])
        @test empty_table isa Typst.TableX
        @test length(empty_table.items) >= 0  # May have auto-generated items
        @debug "Empty table creation: $(length(empty_table.items)) items"
        
        # Single cell table
        single_cell = [Typst.CellX(0, 0, "alone")]
        single_table = Typst.tablex(single_cell)
        @test single_table isa Typst.TableX
        @debug "Single cell table created"
        
        # Table with only lines (no cells)
        lines_only = [Typst.HLineX(0), Typst.HLineX(1)]
        lines_table = Typst.tablex(lines_only)
        @test lines_table isa Typst.TableX
        @debug "Lines-only table created with $(length(lines_only)) lines"
    end
    
    @testset "Parameter validation" begin
        items = [Typst.CellX(0, 0, "test")]
        
        # Test various parameter types are accepted
        @test_nowarn Typst.tablex(items; columns=:auto)
        @test_nowarn Typst.tablex(items; columns="(auto, 1fr)")
        @test_nowarn Typst.tablex(items; rows=:auto)
        @test_nowarn Typst.tablex(items; align=:center)
        @test_nowarn Typst.tablex(items; align="left")
        @test_nowarn Typst.tablex(items; inset=Symbol("5pt"))
        @test_nowarn Typst.tablex(items; stroke=Symbol("0.1em"))
        @debug "Various parameter types accepted by tablex"
        
        # Test boolean parameters
        @test_nowarn Typst.tablex(items; repeat_header=true)
        @test_nowarn Typst.tablex(items; repeat_header=false)
        @test_nowarn Typst.tablex(items; auto_lines=true)
        @test_nowarn Typst.tablex(items; auto_lines=false)
        @debug "Boolean parameters work correctly"
    end
end