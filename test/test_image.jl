@testset "Image Tests" begin
    
    @testset "Basic image function" begin
        # Test simple image creation
        img1 = Typst.image("test.png")
        @test img1 isa Typst.Image
        @test img1.fn == "test.png"
        @debug "Basic image created: $(img1.fn)"
        
        # Test that format is auto-detected or set appropriately
        @test img1.format isa Union{String, Symbol}
        @debug "Image format: $(img1.format)"
    end
    
    @testset "Image with explicit parameters" begin
        # Test image with all parameters specified
        img2 = Typst.image(
            "figure.svg";
            format = "svg",
            width = 600,
            height = 400,
            alt = :none,
            fit = :contain
        )
        
        @test img2.fn == "figure.svg"
        @test img2.format == "svg"
        @test img2.width == 600
        @test img2.height == 400
        @test img2.alt == :none
        @test img2.fit == :contain
        @debug "Full image: $(img2.fn), $(img2.width)×$(img2.height), format=$(img2.format), fit=$(img2.fit)"
    end
    
    @testset "Image format validation" begin
        # Test supported formats
        valid_formats = ["png", "svg", "pdf", "jpg", "jpeg"]
        
        for fmt in valid_formats
            img = Typst.image("test.$(fmt)"; format=fmt)
            @test img.format == fmt
            @debug "Valid format accepted: $(fmt)"
        end
        
        # Test invalid format should error
        @test_throws Exception Typst.image("test.xyz"; format="xyz")
        @debug "Invalid format properly rejected"
        
        # Test case sensitivity
        @test_nowarn Typst.image("test.PNG"; format="png")  # Should work
        @debug "Format validation handles case appropriately"
    end
    
    @testset "Image fit validation" begin
        # Test valid fit options
        valid_fits = [:contain, :cover, :stretch, :auto]
        
        for fit_val in valid_fits
            img = Typst.image("test.png"; fit=fit_val)
            @test img.fit == fit_val
            @debug "Valid fit option: $(fit_val)"
        end
        
        # Test invalid fit should error
        @test_throws Exception Typst.image("test.png"; fit=:invalid_fit)
        @debug "Invalid fit option properly rejected"
    end
    
    @testset "Image dimensions" begin
        # Test integer dimensions
        img_int = Typst.image("test.png"; width=800, height=600)
        @test img_int.width == 800
        @test img_int.height == 600
        @debug "Integer dimensions: $(img_int.width)×$(img_int.height)"
        
        # Test symbol dimensions (for Typst-specific values)
        img_sym = Typst.image("test.png"; width=Symbol("100%"), height=:auto)
        @test img_sym.width == Symbol("100%")
        @test img_sym.height == :auto
        @debug "Symbol dimensions: $(img_sym.width)×$(img_sym.height)"
        
        # Test mixed dimensions
        img_mixed = Typst.image("test.png"; width=400, height=Symbol("50%"))
        @test img_mixed.width == 400
        @test img_mixed.height == Symbol("50%")
        @debug "Mixed dimensions: $(img_mixed.width)×$(img_mixed.height)"
    end
    
    @testset "Image alt text" begin
        # Test different alt text options
        img_alt_none = Typst.image("test.png"; alt=:none)
        @test img_alt_none.alt == :none
        @debug "Alt text: none"
        
        img_alt_auto = Typst.image("test.png"; alt=:auto)
        @test img_alt_auto.alt == :auto
        @debug "Alt text: auto"
        
        # Note: The current implementation might not support string alt text,
        # but we test the symbol versions that are defined
    end
    
    @testset "Image print functionality" begin
        img = Typst.image("printable.png"; width=500, height=300, format="png")
        
        # Test print method exists and works
        @test_nowarn print(img)
        @debug "Image print method executes without error"
        
        # Test print output
        output = sprint(print, img)
        @test output isa String
        @test length(output) > 0
        @test occursin("printable.png", output)
        @debug "Image print output: $(length(output)) characters"
        
        # Test that output contains image markup
        @test occursin("image", output)
        @debug "Image print output contains image markup"
        
        # Test print with custom tabulation
        custom_output = sprint(print, img; tb="        ")  # Custom indentation
        @test custom_output isa String
        @debug "Image print with custom tabulation works"
    end
    
    @testset "Image file path handling" begin
        # Test different path formats
        paths = [
            "simple.png",
            "./relative/path.svg",
            "../parent/figure.pdf", 
            "/absolute/path/image.jpg",
            "no_extension",
            "multiple.dots.in.name.png",
            "spaces in name.png",  # May or may not be supported
            "unicode_名前.png"      # Unicode characters
        ]
        
        for path in paths
            try
                img = Typst.image(path)
                @test img.fn == path
                @debug "Path format handled: $(path)"
            catch e
                @debug "Path format rejected: $(path) - $(typeof(e))"
            end
        end
    end
    
    @testset "Image format auto-detection" begin
        # Test that format is auto-detected from file extension
        extensions_and_formats = [
            ("test.png", "png"),
            ("test.jpg", "jpg"), 
            ("test.jpeg", "jpeg"),
            ("test.svg", "svg"),
            ("test.pdf", "pdf")
        ]
        
        for (filename, expected_format) in extensions_and_formats
            img = Typst.image(filename)
            # The format should either be auto-detected correctly or be :auto
            if img.format isa String
                @test img.format == expected_format
                @debug "Format auto-detected: $(filename) → $(img.format)"
            else
                @test img.format == :auto
                @debug "Format set to auto: $(filename) → $(img.format)"
            end
        end
    end
    
    @testset "Image in figure context" begin
        # Test image used within a figure
        img = Typst.image("context_test.png"; width=400, height=300)
        cap = Typst.Caption("Test figure with image")
        
        fig = Typst.figuret(img; caption=cap)
        @test fig isa Typst.FigureT
        @test fig.content isa Typst.Image
        @test fig.content.fn == "context_test.png"
        @debug "Image successfully used in figure context"
        
        # Test figure with image prints correctly
        @test_nowarn print(fig)
        fig_output = sprint(print, fig)
        @test occursin("context_test.png", fig_output)
        @test occursin("Test figure", fig_output)
        @debug "Figure with image prints correctly"
    end
    
    @testset "Image edge cases" begin
        # Test edge cases and unusual but potentially valid inputs
        
        # Very large dimensions
        big_img = Typst.image("big.png"; width=10000, height=10000)
        @test big_img.width == 10000
        @test big_img.height == 10000
        @debug "Large dimensions handled: $(big_img.width)×$(big_img.height)"
        
        # Zero dimensions (edge case)
        zero_img = Typst.image("zero.png"; width=0, height=0)
        @test zero_img.width == 0
        @test zero_img.height == 0
        @debug "Zero dimensions allowed: $(zero_img.width)×$(zero_img.height)"
        
        # Empty filename (edge case)
        @test_throws Exception Typst.image("")
        @debug "Empty filename properly rejected"
        
        # Very long filename
        long_name = "a" ^ 100 * ".png"
        long_img = Typst.image(long_name)
        @test length(long_img.fn) > 100
        @debug "Long filename handled: $(length(long_img.fn)) characters"
    end
    
    @testset "Image parameter combinations" begin
        # Test various parameter combinations to ensure they work together
        
        combo1 = Typst.image(
            "combo1.svg";
            format = "svg",
            width = Symbol("80%"),
            height = 400,
            fit = :contain,
            alt = :auto
        )
        
        @test combo1.format == "svg"
        @test combo1.width == Symbol("80%")
        @test combo1.height == 400
        @test combo1.fit == :contain
        @test combo1.alt == :auto
        @debug "Parameter combination 1 successful"
        
        combo2 = Typst.image(
            "combo2.pdf";
            format = "pdf", 
            width = 600,
            height = Symbol("auto"),
            fit = :cover,
            alt = :none
        )
        
        @test combo2.format == "pdf"
        @test combo2.width == 600
        @test combo2.height == Symbol("auto")
        @test combo2.fit == :cover
        @test combo2.alt == :none
        @debug "Parameter combination 2 successful"
    end
    
    @testset "Image struct field access" begin
        # Test direct access to Image struct fields
        img = Typst.image("field_test.png"; width=300, height=200, format="png")
        
        # Test all fields are accessible
        @test hasfield(Typst.Image, :fn)
        @test hasfield(Typst.Image, :format)
        @test hasfield(Typst.Image, :width)
        @test hasfield(Typst.Image, :height)
        @test hasfield(Typst.Image, :alt)
        @test hasfield(Typst.Image, :fit)
        @debug "All Image struct fields accessible"
        
        # Test field types match expectations
        @test img.fn isa String
        @test img.format isa Union{String, Symbol}
        @test img.width isa Union{Int, Symbol}
        @test img.height isa Union{Int, Symbol}
        @test img.alt isa Symbol
        @test img.fit isa Symbol
        @debug "Image field types correct"
    end
end