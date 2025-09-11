# Figures

Typst.jl provides streamlined figure management with automatic file handling, caption management, and proper cross-referencing.

## Basic Figure Export

The `figure_export` function handles both saving your figure and generating the corresponding Typst code:

```julia
using CairoMakie

# Create your plot
fig = Figure(resolution = (600, 400))
ax = Axis(fig[1, 1], 
    xlabel = "Time (hours)", 
    ylabel = "Temperature (°C)"
)

x = 1:24
y = 20 .+ 5 * sin.(2π * x / 24) .+ randn(24)
lines!(ax, x, y)

# Export both image and .typ files
figure_export(
    "temperature_plot.png",    # Image filename  
    fig,                       # Makie figure
    save;                      # Save function
    caption = "Hourly temperature measurements over 24 hours showing diurnal variation",
    short_caption = "Hourly Temperature"
)
```

This creates two files:
- `temperature_plot.png`: The actual image
- `temperature_plot.typ`: Typst code to include the figure

## Makie Integration

Typst.jl works seamlessly with all Makie backends:

### CairoMakie (PNG, SVG, PDF)
```julia
using CairoMakie

# Save as PNG (default)
figure_export("plot.png", fig, save; caption = "...")

# Save as SVG for vector graphics
figure_export("plot.svg", fig, save; caption = "...")
```

### Custom Save Functions

You can customize the save function for specific output requirements:

```julia
# High-resolution save function
@inline save_hires(name, fig) = save(name, fig; pt_per_unit = 2, px_per_unit = 2)

# Use custom save function
figure_export(
    "high_res_plot.png",
    fig,
    save_hires;
    caption = "High resolution plot for print publication"
)
```

## Caption Management

### Long and Short Captions

Figures support both long captions (displayed with the figure) and short captions (used in lists of figures):

```julia
figure_export(
    "complex_analysis.png",
    fig,
    save;
    caption = "(a) Effect of treatment on outcome variable controlling for confounders. Error bars represent 95% confidence intervals. (b) Distribution of residuals showing approximate normality (Shapiro-Wilk p = 0.23).",
    short_caption = "Treatment Effects and Residuals"
)
```

### Automatic Short Captions

If you don't specify a short caption, the first sentence of the long caption is used automatically:

```julia
figure_export(
    "simple_plot.png",
    fig,
    save;
    caption = "This is the main finding. Additional details follow here."
    # short_caption will automatically be "This is the main finding."
)
```

## Figure Formatting Options

Control various aspects of figure appearance:

```julia
figure_export(
    "formatted_figure.png",
    fig,
    save;
    caption = "Detailed analysis results",
    placement = :top,           # Figure placement (:auto, :top, :bottom, :here)
    kind = :figure,            # Figure type (affects numbering)
    numbering = "1",           # Numbering format
    gap = Symbol("0.8em"),     # Gap between figure and caption
    outlined = true            # Include in list of figures
)
```

## File Organization

Typst.jl automatically handles file paths and organization:

```julia
# Figures and .typ files are saved in the same directory
figure_export("figures/analysis1.png", fig, save; caption = "...")

# This creates:
# - figures/analysis1.png (the image)
# - figures/analysis1.typ (the Typst code)
```

## Cross-References and Labels

Figures are automatically labeled based on their filename:

```julia
figure_export("results_summary.png", fig, save; caption = "...")

# In your Typst document, reference as:
# See @results_summary for key findings.
```

## Multiple Figures

For papers with many figures, organize systematically:

```julia
# Organize by section
figure_export("figures/intro/motivation.png", motivation_fig, save; 
              caption = "Motivating example")
              
figure_export("figures/methods/workflow.png", workflow_fig, save; 
              caption = "Analysis workflow")
              
figure_export("figures/results/main_finding.png", results_fig, save; 
              caption = "Primary results")
```

## Advanced Figure Types

### Subfigures

For complex figures with multiple panels:

```julia
# Create multi-panel figure in Makie
fig = Figure(resolution = (800, 400))
ax1 = Axis(fig[1, 1], title = "Panel A")
ax2 = Axis(fig[1, 2], title = "Panel B")

# Plot in each panel
scatter!(ax1, randn(50), randn(50))
lines!(ax2, 1:10, cumsum(randn(10)))

figure_export(
    "multipanel_analysis.png",
    fig,
    save;
    caption = "(A) Scatter plot of variables X and Y showing no correlation (r = 0.02). (B) Time series of cumulative returns demonstrating random walk behavior.",
    short_caption = "Two-Panel Analysis"
)
```

## Best Practices

1. **Use descriptive filenames**: They become the figure labels
2. **Consistent naming**: Use systematic naming conventions
3. **Appropriate resolution**: Consider your final output medium
4. **Vector formats when possible**: Use SVG for line plots and diagrams
5. **Organize by sections**: Keep figures organized in subdirectories
6. **Test cross-references**: Ensure your figure labels work in Typst
7. **Meaningful captions**: Provide context and interpretation, not just description