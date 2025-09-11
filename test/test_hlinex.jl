@testset "HLineX Tests" begin
    
    @testset "HLineX struct construction" begin
        # Test basic HLineX creation
        hline1 = Typst.HLineX(0)
        @test hline1 isa Typst.HLineX
        @test hline1 isa Typst.TableComponent
        @test hline1.y == 0
        @debug "Basic HLineX created at y=$(hline1.y)"
        
        # Test HLineX with all parameters
        hline2 = Typst.HLineX(2, 1, 3, Symbol("0.1em"))
        @test hline2.y == 2
        @test hline2.start == 1
        @test hline2.end == 3
        @test hline2.stroke == Symbol("0.1em")
        @debug "Full HLineX: y=$(hline2.y), start=$(hline2.start), end=$(hline2.end), stroke=$(hline2.stroke)"
    end
    
    @testset "hlinex function" begin
        # Test hlinex constructor function
        hline3 = Typst.hlinex(1)
        @test hline3 isa Typst.HLineX
        @test hline3.y == 1
        @debug "hlinex function created line at y=$(hline3.y)"
        
        # Test with optional parameters
        hline4 = Typst.hlinex(3; start=0, end=2, stroke=Symbol("0.2em"))
        @test hline4.y == 3
        @test hline4.start == 0
        @test hline4.end == 2
        @test hline4.stroke == Symbol("0.2em")
        @debug "hlinex with parameters: y=$(hline4.y), span=$(hline4.start)-$(hline4.end)"
    end
    
    @testset "HLineX field validation" begin
        hline = Typst.HLineX(1)
        
        # Check field types
        @test hline.y isa Int
        @test hline.start isa Int
        @test hline.end isa Int
        @test hline.stroke isa Union{Symbol, String}
        
        # Check default values
        @test hline.start == 0  # Default start
        @test hline.end == -1   # Default end (full width)
        @test hline.stroke == :auto  # Default stroke
        @debug "HLineX defaults: start=$(hline.start), end=$(hline.end), stroke=$(hline.stroke)"
    end
    
    @testset "HLineX positioning" begin
        # Test different y positions
        positions = [0, 1, 2, 5, 10]
        for pos in positions
            hline = Typst.HLineX(pos)
            @test hline.y == pos
            @debug "HLineX created at position y=$(pos)"
        end
        
        # Test negative positions (edge case)
        neg_hline = Typst.HLineX(-1)
        @test neg_hline.y == -1
        @debug "Negative position allowed: y=$(neg_hline.y)"
    end
    
    @testset "HLineX span control" begin
        # Test partial horizontal lines
        partial_hline = Typst.HLineX(1, 2, 5)
        @test partial_hline.start == 2
        @test partial_hline.end == 5
        @debug "Partial hline spans columns $(partial_hline.start) to $(partial_hline.end)"
        
        # Test single column line
        single_col_hline = Typst.HLineX(0, 3, 3)
        @test single_col_hline.start == 3
        @test single_col_hline.end == 3
        @debug "Single column hline at column $(single_col_hline.start)"
        
        # Test full width line (default)
        full_hline = Typst.HLineX(0)
        @test full_hline.end == -1  # -1 typically means "to the end"
        @debug "Full width hline: end=$(full_hline.end)"
    end
    
    @testset "HLineX stroke options" begin
        # Test different stroke styles
        stroke_styles = [Symbol("0.05em"), Symbol("0.1em"), Symbol("0.2em"), :thick, :thin, :auto]
        
        for stroke in stroke_styles
            hline = Typst.HLineX(0, 0, -1, stroke)
            @test hline.stroke == stroke
            @debug "HLineX with stroke: $(stroke)"
        end
        
        # Test string stroke values
        string_stroke_hline = Typst.HLineX(1, 0, -1, "1pt")
        @test string_stroke_hline.stroke == "1pt"
        @debug "HLineX with string stroke: $(string_stroke_hline.stroke)"
    end
    
    @testset "HLineX print functionality" begin
        hline = Typst.HLineX(2, 1, 4, Symbol("0.1em"))
        
        # Test that HLineX has a print method
        @test_nowarn print(hline)
        @debug "HLineX print method executes without error"
        
        # Test print output
        output = sprint(print, hline)
        @test output isa String
        @test length(output) > 0
        @test occursin("hlinex", output)
        @debug "HLineX print output length: $(length(output)) characters"
        
        # Test that output contains position information
        @test occursin("2", output) || occursin("y", output)  # Should reference y position
    end
    
    @testset "HLineX in table context" begin
        # Test HLineX as part of a table structure
        cells = [
            Typst.CellX(0, 0, "A1"),
            Typst.CellX(1, 0, "B1"),
            Typst.CellX(0, 1, "A2"), 
            Typst.CellX(1, 1, "B2")
        ]
        
        hlines = [
            Typst.HLineX(0),      # Top border
            Typst.HLineX(1),      # After header
            Typst.HLineX(2)       # Bottom border
        ]
        
        all_items = vcat(cells, hlines)
        table = Typst.tablex(all_items)
        
        @test table isa Typst.TableX
        
        # Verify hlines are in the table items
        hline_count = count(item -> item isa Typst.HLineX, table.items)
        @test hline_count >= 3  # At least our 3 hlines (may have auto-generated ones)
        @debug "Table with explicit hlines contains $(hline_count) horizontal lines"
        
        # Test table prints correctly with hlines
        @test_nowarn print(table)
        table_output = sprint(print, table)
        @test occursin("hlinex", table_output)
        @debug "Table with hlines prints correctly"
    end
    
    @testset "HLineX edge cases" begin
        # Test edge cases and boundary conditions
        
        # Same start and end
        same_span = Typst.HLineX(0, 2, 2)
        @test same_span.start == same_span.end
        @debug "HLineX with same start and end: $(same_span.start)"
        
        # Start greater than end (invalid but should be allowed for construction)
        reversed_span = Typst.HLineX(0, 5, 2)
        @test reversed_span.start == 5
        @test reversed_span.end == 2
        @debug "HLineX with start > end: $(reversed_span.start) > $(reversed_span.end)"
        
        # Zero stroke
        zero_stroke = Typst.HLineX(0, 0, -1, Symbol("0em"))
        @test zero_stroke.stroke == Symbol("0em")
        @debug "HLineX with zero stroke"
        
        # Large y position
        large_y = Typst.HLineX(1000)
        @test large_y.y == 1000
        @debug "HLineX at large y position: $(large_y.y)"
    end
    
    @testset "Multiple HLineX coordination" begin
        # Test multiple horizontal lines in sequence
        sequential_hlines = [
            Typst.HLineX(0, 0, -1, Symbol("0.2em")),  # Thick top
            Typst.HLineX(1, 0, -1, Symbol("0.05em")), # Thin middle
            Typst.HLineX(2, 0, -1, Symbol("0.2em"))   # Thick bottom
        ]
        
        @test length(sequential_hlines) == 3
        @test all(h -> h isa Typst.HLineX, sequential_hlines)
        
        # Test that they have different y positions
        y_positions = [h.y for h in sequential_hlines]
        @test y_positions == [0, 1, 2]
        @debug "Sequential hlines at positions: $(y_positions)"
        
        # Test different strokes
        strokes = [h.stroke for h in sequential_hlines]
        @test strokes[1] == strokes[3]  # Top and bottom same
        @test strokes[2] != strokes[1]  # Middle different
        @debug "Sequential hlines with strokes: $(strokes)"
    end
end