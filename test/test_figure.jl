@testset "Figure Tests" begin
    
    @testset "Caption struct and printing" begin
        cap = Caption("Test caption text")
        
        @test cap isa Caption
        @test cap.text == "Test caption text"
        @debug "Caption created: '$(cap.text)'"
        
        # Test caption print functionality
        @test_nowarn print(cap)
        output = sprint(print, cap)
        @test output isa String
        @test occursin("Test caption", output)
        @debug "Caption print output: $(length(output)) characters"
    end
    
    @testset "Image struct creation" begin
        # Test basic image creation
        img1 = Typst.image("test.png")
        @test img1 isa Typst.Image
        @test img1.fn == "test.png"
        @debug "Basic image created: $(img1.fn)"
        
        # Test image with all parameters
        img2 = Typst.image(
            "figure.svg"; 
            format="svg", 
            width=500, 
            height=300, 
            alt=:none, 
            fit=:contain
        )
        @test img2.fn == "figure.svg"
        @test img2.format == "svg"
        @test img2.width == 500
        @test img2.height == 300
        @test img2.fit == :contain
        @debug "Full image: $(img2.fn), $(img2.width)x$(img2.height), $(img2.format)"
    end
    
    @testset "Image format validation" begin
        # Test valid formats
        valid_formats = ["png", "svg", "pdf", "jpg", "jpeg"]
        for fmt in valid_formats
            @test_nowarn Typst.image("test.$(fmt)"; format=fmt)
            @debug "Valid format accepted: $(fmt)"
        end
        
        # Test format auto-detection from filename
        auto_img = Typst.image("autodetect.png")
        # The format should be detected automatically
        @test auto_img.format in ["png", :auto]  # Depending on implementation
        @debug "Format auto-detection for: autodetect.png"
        
        # Test invalid format (should error)
        @test_throws Exception Typst.image("test.xyz"; format="xyz")
        @debug "Invalid format properly rejected"
    end
    
    @testset "Image fit options" begin
        valid_fits = [:contain, :cover, :stretch, :auto]
        
        for fit_option in valid_fits
            img = Typst.image("test.png"; fit=fit_option)
            @test img.fit == fit_option
            @debug "Valid fit option: $(fit_option)"
        end
        
        # Test invalid fit option
        @test_throws Exception Typst.image("test.png"; fit=:invalid_fit)
        @debug "Invalid fit option properly rejected"
    end
    
    @testset "Image print functionality" begin
        img = Typst.image("test.png"; width=400, height=300)
        
        @test_nowarn print(img)
        output = sprint(print, img)
        @test output isa String
        @test length(output) > 0
        @test occursin("test.png", output)
        @test occursin("400", output) || occursin("width", output)
        @debug "Image print output contains filename and dimensions"
    end
    
    @testset "FigureT (figuret) creation" begin
        # Create image content
        img = Typst.image("content.png")
        cap = Caption("Figure caption")
        short_cap = Caption("Short cap")
        
        # Test basic figuret creation
        fig1 = Typst.figuret(img)
        @test fig1 isa Typst.FigureT
        @test fig1.content isa Typst.Image
        @debug "Basic figuret created with image content"
        
        # Test figuret with all options
        fig2 = Typst.figuret(
            img;
            placement=:top,
            caption=cap,
            short_caption=short_cap,
            kind=:figure,
            supplement="Figure",
            numbering="1",
            gap=Symbol("0.5em"),
            outlined=true
        )
        
        @test fig2.placement == :top
        @test fig2.caption == cap
        @test fig2.short_caption == short_cap
        @test fig2.kind == :figure
        @test fig2.supplement == "Figure"
        @test fig2.numbering == "1"
        @test fig2.outlined == true
        @debug "Full figuret created with all options"
    end
    
    @testset "FigureT with TableX content" begin
        # Create table content
        cells = [Typst.CellX(0, 0, "A"), Typst.CellX(1, 0, "B")]
        table = Typst.tablex(cells)
        
        # Test figuret with table content
        fig_table = Typst.figuret(table)
        @test fig_table isa Typst.FigureT
        @test fig_table.content isa Typst.TableX
        @debug "FigureT created with table content"
    end
    
    @testset "FigureT placement validation" begin
        img = Typst.image("test.png")
        
        # Valid placements
        valid_placements = [:auto, :top, :bottom]
        for placement in valid_placements
            @test_nowarn Typst.figuret(img; placement=placement)
            @debug "Valid placement: $(placement)"
        end
        
        # Invalid placement should error
        @test_throws Exception Typst.figuret(img; placement=:invalid)
        @debug "Invalid placement properly rejected"
    end
    
    @testset "FigureT caption logic" begin
        img = Typst.image("test.png")
        cap = Caption("Main caption")
        short_cap = Caption("Short")
        
        # Test with both captions
        fig_both = Typst.figuret(img; caption=cap, short_caption=short_cap)
        @test fig_both.caption == cap
        @test fig_both.short_caption == short_cap
        @debug "FigureT with both captions"
        
        # Test short caption without main caption should error
        @test_throws Exception Typst.figuret(img; short_caption=short_cap)
        @debug "Short caption without main caption properly rejected"
        
        # Test with only main caption
        fig_main_only = Typst.figuret(img; caption=cap)
        @test fig_main_only.caption == cap
        @test fig_main_only.short_caption == :auto  # Should be auto
        @debug "FigureT with main caption only"
    end
    
    @testset "FigureT kind and supplement validation" begin
        img = Typst.image("test.png")
        
        # Test custom kind requires supplement
        @test_throws Exception Typst.figuret(img; kind=:custom)
        @debug "Custom kind without supplement properly rejected"
        
        # Test custom kind with supplement
        fig_custom = Typst.figuret(img; kind=:custom, supplement="Custom")
        @test fig_custom.kind == :custom
        @test fig_custom.supplement == "Custom"
        @debug "Custom kind with supplement works"
        
        # Test standard kinds
        standard_kinds = [:figure, :table, :auto]
        for kind in standard_kinds
            @test_nowarn Typst.figuret(img; kind=kind)
            @debug "Standard kind works: $(kind)"
        end
    end
    
    @testset "FigureT print functionality" begin
        img = Typst.image("printable.png")
        cap = Caption("Printable figure")
        fig = Typst.figuret(img; caption=cap)
        
        @test_nowarn print(fig)
        output = sprint(print, fig)
        @test output isa String
        @test length(output) > 0
        @test occursin("figure", output) || occursin("Figure", output)
        @test occursin("Printable", output)
        @debug "FigureT print output contains figure markup and caption"
        
        # Test print with label
        labeled_output = sprint(print, fig; label=" <test_label>\n")
        @test occursin("test_label", labeled_output)
        @debug "FigureT print with label works"
    end
    
    @testset "Image path handling" begin
        # Test different path formats
        paths = [
            "simple.png",
            "./relative/path.svg", 
            "/absolute/path/figure.pdf",
            "no_extension",
            "multiple.dots.in.name.jpg"
        ]
        
        for path in paths
            if occursin(".", path) || path == "no_extension"
                @test_nowarn Typst.image(path)
                @debug "Path format handled: $(path)"
            end
        end
    end
    
    @testset "Complex figure workflow" begin
        # Simulate a complete figure workflow
        
        # 1. Create image
        img = Typst.image("analysis_results.png"; width=600, height=400)
        
        # 2. Create captions
        main_cap = Caption("Analysis results showing significant correlation (p < 0.01)")
        short_cap = Caption("Analysis Results")
        
        # 3. Create figure
        complete_fig = Typst.figuret(
            img;
            placement=:top,
            caption=main_cap,
            short_caption=short_cap,
            kind=:figure,
            numbering="1",
            outlined=true
        )
        
        @test complete_fig isa Typst.FigureT
        @test complete_fig.content.width == 600
        @test complete_fig.caption.text == "Analysis results showing significant correlation (p < 0.01)"
        @debug "Complete figure workflow successful"
        
        # 4. Test printing
        @test_nowarn print(complete_fig)
        final_output = sprint(print, complete_fig)
        @test occursin("analysis_results.png", final_output)
        @test occursin("Analysis results", final_output)
        @debug "Complete figure prints correctly"
    end
end