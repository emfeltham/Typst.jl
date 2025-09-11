@testset "VLineX Tests" begin
    
    @testset "VLineX struct construction" begin
        # Test basic VLineX creation
        vline1 = Typst.VLineX(0)
        @test vline1 isa Typst.VLineX
        @test vline1 isa Typst.TableComponent
        @test vline1.x == 0
        @debug "Basic VLineX created at x=$(vline1.x)"
        
        # Test VLineX with all parameters
        vline2 = Typst.VLineX(2, 1, 3, Symbol("0.1em"))
        @test vline2.x == 2
        @test vline2.start == 1
        @test vline2.end == 3
        @test vline2.stroke == Symbol("0.1em")
        @debug "Full VLineX: x=$(vline2.x), start=$(vline2.start), end=$(vline2.end), stroke=$(vline2.stroke)"
    end
    
    @testset "vlinex function" begin
        # Test vlinex constructor function
        vline3 = Typst.vlinex(1)
        @test vline3 isa Typst.VLineX
        @test vline3.x == 1
        @debug "vlinex function created line at x=$(vline3.x)"
        
        # Test with optional parameters
        vline4 = Typst.vlinex(3; start=0, end=2, stroke=Symbol("0.2em"))
        @test vline4.x == 3
        @test vline4.start == 0
        @test vline4.end == 2
        @test vline4.stroke == Symbol("0.2em")
        @debug "vlinex with parameters: x=$(vline4.x), span=$(vline4.start)-$(vline4.end)"
    end
    
    @testset "VLineX field validation" begin
        vline = Typst.VLineX(1)
        
        # Check field types
        @test vline.x isa Int
        @test vline.start isa Int
        @test vline.end isa Int
        @test vline.stroke isa Union{Symbol, String}
        
        # Check default values
        @test vline.start == 0   # Default start
        @test vline.end == -1    # Default end (full height)
        @test vline.stroke == :auto  # Default stroke
        @debug "VLineX defaults: start=$(vline.start), end=$(vline.end), stroke=$(vline.stroke)"
    end
    
    @testset "VLineX positioning" begin
        # Test different x positions
        positions = [0, 1, 2, 5, 10]
        for pos in positions
            vline = Typst.VLineX(pos)
            @test vline.x == pos
            @debug "VLineX created at position x=$(pos)"
        end
        
        # Test negative positions (edge case)
        neg_vline = Typst.VLineX(-1)
        @test neg_vline.x == -1
        @debug "Negative position allowed: x=$(neg_vline.x)"
    end
    
    @testset "VLineX span control" begin
        # Test partial vertical lines
        partial_vline = Typst.VLineX(1, 2, 5)
        @test partial_vline.start == 2
        @test partial_vline.end == 5
        @debug "Partial vline spans rows $(partial_vline.start) to $(partial_vline.end)"
        
        # Test single row line
        single_row_vline = Typst.VLineX(0, 3, 3)
        @test single_row_vline.start == 3
        @test single_row_vline.end == 3
        @debug "Single row vline at row $(single_row_vline.start)"
        
        # Test full height line (default)
        full_vline = Typst.VLineX(0)
        @test full_vline.end == -1  # -1 typically means "to the end"
        @debug "Full height vline: end=$(full_vline.end)"
    end
    
    @testset "VLineX stroke options" begin
        # Test different stroke styles
        stroke_styles = [Symbol("0.05em"), Symbol("0.1em"), Symbol("0.2em"), :thick, :thin, :auto]
        
        for stroke in stroke_styles
            vline = Typst.VLineX(0, 0, -1, stroke)
            @test vline.stroke == stroke
            @debug "VLineX with stroke: $(stroke)"
        end
        
        # Test string stroke values
        string_stroke_vline = Typst.VLineX(1, 0, -1, "1pt")
        @test string_stroke_vline.stroke == "1pt"
        @debug "VLineX with string stroke: $(string_stroke_vline.stroke)"
    end
    
    @testset "VLineX print functionality" begin
        vline = Typst.VLineX(2, 1, 4, Symbol("0.1em"))
        
        # Test that VLineX has a print method
        @test_nowarn print(vline)
        @debug "VLineX print method executes without error"
        
        # Test print output
        output = sprint(print, vline)
        @test output isa String
        @test length(output) > 0
        @test occursin("vlinex", output)
        @debug "VLineX print output length: $(length(output)) characters"
        
        # Test that output contains position information
        @test occursin("2", output) || occursin("x", output)  # Should reference x position
    end
    
    @testset "VLineX in table context" begin
        # Test VLineX as part of a table structure
        cells = [
            Typst.CellX(0, 0, "A1"),
            Typst.CellX(1, 0, "B1"),
            Typst.CellX(2, 0, "C1"),
            Typst.CellX(0, 1, "A2"),
            Typst.CellX(1, 1, "B2"), 
            Typst.CellX(2, 1, "C2")
        ]
        
        vlines = [
            Typst.VLineX(0),      # Left border
            Typst.VLineX(1),      # Between A and B columns
            Typst.VLineX(2),      # Between B and C columns
            Typst.VLineX(3)       # Right border
        ]
        
        all_items = vcat(cells, vlines)
        table = Typst.tablex(all_items)
        
        @test table isa Typst.TableX
        
        # Verify vlines are in the table items
        vline_count = count(item -> item isa Typst.VLineX, table.items)
        @test vline_count >= 4  # At least our 4 vlines (may have auto-generated ones)
        @debug "Table with explicit vlines contains $(vline_count) vertical lines"
        
        # Test table prints correctly with vlines
        @test_nowarn print(table)
        table_output = sprint(print, table)
        @test occursin("vlinex", table_output)
        @debug "Table with vlines prints correctly"
    end
    
    @testset "VLineX and HLineX combination" begin
        # Test both horizontal and vertical lines in same table
        cells = [
            Typst.CellX(0, 0, "A1"),
            Typst.CellX(1, 0, "B1"),
            Typst.CellX(0, 1, "A2"),
            Typst.CellX(1, 1, "B2")
        ]
        
        hlines = [
            Typst.HLineX(0),  # Top
            Typst.HLineX(1),  # Middle 
            Typst.HLineX(2)   # Bottom
        ]
        
        vlines = [
            Typst.VLineX(0),  # Left
            Typst.VLineX(1),  # Middle
            Typst.VLineX(2)   # Right
        ]
        
        all_items = vcat(cells, hlines, vlines)
        combo_table = Typst.tablex(all_items)
        
        @test combo_table isa Typst.TableX
        
        # Count different line types
        h_count = count(item -> item isa Typst.HLineX, combo_table.items)
        v_count = count(item -> item isa Typst.VLineX, combo_table.items)
        
        @test h_count >= 3
        @test v_count >= 3
        @debug "Combined table: $(h_count) hlines, $(v_count) vlines"
        
        # Test printing
        @test_nowarn print(combo_table)
        combo_output = sprint(print, combo_table)
        @test occursin("hlinex", combo_output)
        @test occursin("vlinex", combo_output)
        @debug "Combined hline/vline table prints correctly"
    end
    
    @testset "VLineX edge cases" begin
        # Test edge cases and boundary conditions
        
        # Same start and end
        same_span = Typst.VLineX(0, 2, 2)
        @test same_span.start == same_span.end
        @debug "VLineX with same start and end: $(same_span.start)"
        
        # Start greater than end (invalid but should be allowed for construction)
        reversed_span = Typst.VLineX(0, 5, 2)
        @test reversed_span.start == 5
        @test reversed_span.end == 2
        @debug "VLineX with start > end: $(reversed_span.start) > $(reversed_span.end)"
        
        # Zero stroke
        zero_stroke = Typst.VLineX(0, 0, -1, Symbol("0em"))
        @test zero_stroke.stroke == Symbol("0em")
        @debug "VLineX with zero stroke"
        
        # Large x position
        large_x = Typst.VLineX(1000)
        @test large_x.x == 1000
        @debug "VLineX at large x position: $(large_x.x)"
    end
    
    @testset "Multiple VLineX coordination" begin
        # Test multiple vertical lines with different properties
        column_separators = [
            Typst.VLineX(0, 0, -1, Symbol("0.2em")),  # Thick left border
            Typst.VLineX(1, 0, -1, Symbol("0.05em")), # Thin separator
            Typst.VLineX(2, 0, -1, Symbol("0.05em")), # Thin separator  
            Typst.VLineX(3, 0, -1, Symbol("0.2em"))   # Thick right border
        ]
        
        @test length(column_separators) == 4
        @test all(v -> v isa Typst.VLineX, column_separators)
        
        # Test that they have different x positions
        x_positions = [v.x for v in column_separators]
        @test x_positions == [0, 1, 2, 3]
        @debug "Column separators at positions: $(x_positions)"
        
        # Test border vs separator strokes
        border_stroke = column_separators[1].stroke
        separator_stroke = column_separators[2].stroke
        @test border_stroke != separator_stroke
        @debug "Border stroke: $(border_stroke), separator stroke: $(separator_stroke)"
    end
    
    @testset "VLineX partial spans" begin
        # Test vertical lines that don't span the full table height
        
        # Header separator (only spans first row)
        header_sep = Typst.VLineX(1, 0, 1, Symbol("0.1em"))
        @test header_sep.start == 0
        @test header_sep.end == 1
        @debug "Header separator spans rows $(header_sep.start)-$(header_sep.end)"
        
        # Data section separator (skips header)
        data_sep = Typst.VLineX(2, 1, 5, Symbol("0.05em"))
        @test data_sep.start == 1
        @test data_sep.end == 5
        @debug "Data separator spans rows $(data_sep.start)-$(data_sep.end)"
        
        # Test in table context
        mixed_cells = [
            Typst.CellX(0, 0, "Header A"),
            Typst.CellX(1, 0, "Header B"),
            Typst.CellX(2, 0, "Header C"),
            Typst.CellX(0, 1, "Data A1"),
            Typst.CellX(1, 1, "Data B1"),
            Typst.CellX(2, 1, "Data C1")
        ]
        
        partial_vlines = [header_sep, data_sep]
        partial_items = vcat(mixed_cells, partial_vlines)
        partial_table = Typst.tablex(partial_items)
        
        @test partial_table isa Typst.TableX
        @test_nowarn print(partial_table)
        @debug "Table with partial-span vlines created successfully"
    end
end