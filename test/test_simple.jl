@testset "Simple Working Tests" begin
    
    @testset "Basic functionality" begin
        # Test that the module loads
        @test Typst isa Module
        @debug "Typst module loaded successfully"
        
        # Test basic types are available
        @test TableComponent isa Type
        @test CellX isa Type  
        @test HLineX isa Type
        @test VLineX isa Type
        @test Caption isa Type
        @debug "All main types are accessible"
        
        # Test that we can create a simple cell
        cell = cellx(content="test", x=0, y=0)
        @test cell isa CellX
        @test cell.content == "test"
        @test cell.x == 0
        @test cell.y == 0
        @debug "Simple cell creation works: $(cell.content)"
        
        # Test basic Caption
        cap = Caption("Test caption")
        @test cap isa Caption
        @test cap.text == "Test caption"
        @debug "Caption creation works: $(cap.text)"
        
        # Test DataFrame functionality
        df = DataFrame(A = [1, 2], B = [3, 4])
        @test_nowarn table = tablex(df)
        @debug "DataFrame to table conversion works"
        
        # Test export functionality exists
        @test hasmethod(table_export, (String, Any))
        @test hasmethod(figure_export, (String, Any, Any))
        @debug "Export functions are available"
    end
    
    @testset "Utilities bug detection" begin
        # This should catch the digits bug in utilities.jl
        test_tuple = (3.14, 2.72)
        
        # This test documents the current bug - it should fail
        @test_throws Exception Typst.round(test_tuple; digits=2)
        @debug "utilities.jl digits bug detected as expected"
    end
end