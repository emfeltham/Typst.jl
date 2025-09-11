@testset "CellX Tests" begin
    
    @testset "CellX struct construction" begin
        # Test basic CellX creation using cellx function
        cell1 = cellx(content="content", x=0, y=0)
        @test cell1 isa CellX
        @test cell1 isa TableComponent
        @test cell1.x == 0
        @test cell1.y == 0
        @test cell1.content == "content"
        @debug "Basic CellX: ($(cell1.x), $(cell1.y)) = '$(cell1.content)'"
        
        # Test CellX with all parameters
        cell2 = cellx(content="full content", x=2, y=3, colspan=1, rowspan=2, align=:left, fill=:fill, inset=Symbol("5pt"))
        @test cell2.x == 2
        @test cell2.y == 3
        @test cell2.content == "full content"
        @test cell2.colspan == 1
        @test cell2.rowspan == 2
        @test cell2.align == :left
        @test cell2.fill == :fill
        @test cell2.inset == Symbol("5pt")
        @debug "Full CellX: ($(cell2.x), $(cell2.y)) colspan=$(cell2.colspan), rowspan=$(cell2.rowspan)"
    end
    
    @testset "cellx function" begin
        # Test cellx constructor function
        cell3 = cellx(content="test", x=1, y=1, align=:center)
        @test cell3 isa CellX
        @test cell3.x == 1
        @test cell3.y == 1
        @test cell3.content == "test"
        @test cell3.align == :center
        @debug "cellx function created cell at ($(cell3.x), $(cell3.y))"
        
        # Test with different content types
        cell4 = cellx(content=42, x=0, y=0)  # Number content
        @test cell4.content == 42
        @debug "cellx with numeric content: $(cell4.content)"
        
        # Test with Symbol content
        cell5 = cellx(content=:symbol_content, x=0, y=0)
        @test cell5.content == :symbol_content
        @debug "cellx with symbol content: $(cell5.content)"
    end
    
    @testset "CellX field validation" begin
        cell = Typst.CellX(1, 2, "test")
        
        # Check field types
        @test cell.x isa Int
        @test cell.y isa Int
        @test cell.content isa Any  # Should accept any type
        @test cell.colspan isa Int
        @test cell.rowspan isa Int
        
        # Check default values
        @test cell.colspan == 1  # Default
        @test cell.rowspan == 1  # Default
        @test cell.align == :auto  # Default
        @debug "CellX defaults: colspan=$(cell.colspan), rowspan=$(cell.rowspan), align=$(cell.align)"
    end
    
    @testset "CellX with span parameters" begin
        # Test colspan
        colspan_cell = Typst.CellX(0, 0, "spans columns", 3, 1)
        @test colspan_cell.colspan == 3
        @test colspan_cell.rowspan == 1
        @debug "Colspan cell spans $(colspan_cell.colspan) columns"
        
        # Test rowspan  
        rowspan_cell = Typst.CellX(0, 0, "spans rows", 1, 2)
        @test rowspan_cell.colspan == 1
        @test rowspan_cell.rowspan == 2
        @debug "Rowspan cell spans $(rowspan_cell.rowspan) rows"
        
        # Test both
        span_cell = Typst.CellX(0, 0, "spans both", 2, 3)
        @test span_cell.colspan == 2
        @test span_cell.rowspan == 3
        @debug "Combined span cell: $(span_cell.colspan)x$(span_cell.rowspan)"
    end
    
    @testset "CellX formatting options" begin
        # Test different alignment options
        alignments = [:left, :right, :center, :auto]
        for align in alignments
            cell = Typst.CellX(0, 0, "aligned", 1, 1, align)
            @test cell.align == align
            @debug "Cell with alignment: $(align)"
        end
        
        # Test fill and stroke options
        styled_cell = Typst.CellX(0, 0, "styled", 1, 1, :center, :blue, :thick)
        @test styled_cell.fill == :blue
        @test styled_cell.stroke == :thick
        @debug "Styled cell: fill=$(styled_cell.fill), stroke=$(styled_cell.stroke)"
    end
    
    @testset "CellX print functionality" begin
        # Test that CellX has a print method (though we won't test output format)
        cell = Typst.CellX(1, 2, "printable content")
        
        # Just test that print doesn't error
        @test_nowarn print(cell)
        @debug "CellX print method executes without error"
        
        # Test print to string
        output = sprint(print, cell)
        @test output isa String
        @test length(output) > 0
        @debug "CellX print output length: $(length(output)) characters"
    end
    
    @testset "Edge cases and error conditions" begin
        # Test negative coordinates (should be allowed)
        neg_cell = Typst.CellX(-1, -1, "negative coords")
        @test neg_cell.x == -1
        @test neg_cell.y == -1
        @debug "Negative coordinates allowed: ($(neg_cell.x), $(neg_cell.y))"
        
        # Test zero span (edge case)
        zero_span_cell = Typst.CellX(0, 0, "zero span", 0, 0)
        @test zero_span_cell.colspan == 0
        @test zero_span_cell.rowspan == 0
        @debug "Zero span cell created (may be invalid for rendering)"
        
        # Test empty content
        empty_cell = Typst.CellX(0, 0, "")
        @test empty_cell.content == ""
        @debug "Empty content cell created"
        
        # Test various content types
        content_types = [
            "string",
            42,
            3.14,
            :symbol,
            true,
            [1, 2, 3],
            Dict("key" => "value")
        ]
        
        for content in content_types
            cell = Typst.CellX(0, 0, content)
            @test cell.content == content
            @debug "CellX accepts content type: $(typeof(content))"
        end
    end
end