@testset "Types Tests" begin
    
    @testset "TableComponent abstract type" begin
        @test TableComponent isa Type
        @test isabstracttype(TableComponent)
        @debug "TableComponent is properly defined as abstract type"
    end
    
    @testset "Caption struct" begin
        cap = Caption("Test caption")
        @test cap isa Caption
        @test cap.text == "Test caption"
        @test fieldnames(Caption) == (:text,)
        @debug "Caption struct: $(cap.text)"
    end
    
    @testset "TableX struct" begin
        # Test TableX construction with minimal parameters
        items = []  # Empty for basic construction test
        tx = TableX(
            :auto, :auto, :auto, :auto, :auto, :auto, :auto, :auto, :auto,
            false, 1, true, true, :auto, :auto, :auto, :auto, :auto, :auto, :auto,
            items
        )
        
        @test tx isa TableX
        @test tx.items == items
        @test tx.repeat_header == false
        @test tx.header_rows == 1
        @test tx.auto_lines == true
        @debug "TableX created with $(length(tx.items)) items"
    end
    
    @testset "Image struct" begin
        img = Image("test.png", "png", 100, 200, :none, :contain)
        @test img isa Image
        @test img.fn == "test.png"
        @test img.format == "png"
        @test img.width == 100
        @test img.height == 200
        @test img.alt == :none
        @test img.fit == :contain
        @debug "Image struct: $(img.fn), $(img.width)x$(img.height)"
    end
    
    @testset "FigureT struct" begin
        cap = Caption("Test figure")
        short_cap = Caption("Short")
        img = Image("test.png", "png", 100, 100, :none, :contain)
        
        fig = FigureT(
            img, :auto, cap, short_cap, :figure, :none, "1", :auto, true
        )
        
        @test fig isa FigureT
        @test fig.content isa Image
        @test fig.caption isa Caption
        @test fig.short_caption isa Caption
        @test fig.kind == :figure
        @test fig.outlined == true
        @debug "FigureT created with content type: $(typeof(fig.content))"
    end
    
    @testset "Field type validation" begin
        # Test that structs have expected field types
        @test fieldtype(Caption, :text) == String
        @test fieldtype(Image, :fn) == String
        @test fieldtype(Image, :width) == Union{Int, Symbol}
        @test fieldtype(TableX, :items) == Vector{TableComponent}
        @test fieldtype(FigureT, :outlined) == Bool
        @debug "All field types validated"
    end
end