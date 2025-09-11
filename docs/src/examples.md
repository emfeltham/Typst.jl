# Examples

This page provides complete, working examples of using Typst.jl for common academic and research workflows.

## Complete Research Workflow

Here's a complete example showing how to use Typst.jl in a typical research project:

### Setup and Data Generation

```julia
using Typst
using DataFrames
using GLM
using CairoMakie
using Random

# Set seed for reproducibility
Random.seed!(123)

# Generate synthetic research data
n = 200
data = DataFrame(
    id = 1:n,
    treatment = rand([0, 1], n),
    age = rand(18:65, n),
    education = rand(["High School", "College", "Graduate"], n),
    income = exp.(randn(n) * 0.5 .+ 10),  # Log-normal income
    outcome = Float64[]
)

# Generate outcome variable with treatment effect
for row in eachrow(data)
    treatment_effect = row.treatment * 2.5
    age_effect = (row.age - 40) * 0.02
    education_effect = row.education == "Graduate" ? 1.2 : 
                      (row.education == "College" ? 0.6 : 0.0)
    income_effect = log(row.income / 10000) * 0.8
    
    outcome = 5.0 + treatment_effect + age_effect + education_effect + income_effect + randn()
    push!(row.outcome, outcome)
end
```

### Descriptive Statistics Table

```julia
# Create descriptive statistics
desc_stats = DataFrame(
    Variable = ["Treatment", "Age", "Income", "Outcome"],
    Mean = [
        mean(data.treatment),
        mean(data.age),
        mean(data.income),
        mean(data.outcome)
    ],
    SD = [
        std(data.treatment),
        std(data.age), 
        std(data.income),
        std(data.outcome)
    ],
    Min = [
        minimum(data.treatment),
        minimum(data.age),
        minimum(data.income),
        minimum(data.outcome)
    ],
    Max = [
        maximum(data.treatment),
        maximum(data.age),
        maximum(data.income),
        maximum(data.outcome)
    ]
)

# Round for presentation
for col in [:Mean, :SD, :Min, :Max]
    desc_stats[!, col] = round.(desc_stats[!, col], digits=2)
end

# Export descriptive statistics table
tb_desc = tablex(desc_stats)
table_export(
    "descriptive_stats",
    tb_desc;
    caption = "Descriptive statistics for analysis variables. Treatment is binary (0/1), age in years, income in dollars, outcome is standardized score.",
    short_caption = "Descriptive Statistics"
)
```

### Regression Analysis

```julia
# Fit progressive models
model1 = lm(@formula(outcome ~ treatment), data)
model2 = lm(@formula(outcome ~ treatment + age), data)
model3 = lm(@formula(outcome ~ treatment + age + income), data) 
model4 = lm(@formula(outcome ~ treatment + age + income + education), data)

# Create regression table
models = [model1, model2, model3, model4]
regtable_typ(
    models,
    "regression_analysis";
    caption = "Progressive regression models examining treatment effects. Model 1 shows bivariate relationship, Models 2-4 add demographic and economic controls sequentially.",
    model_labels = ["Bivariate", "+ Age", "+ Income", "+ Education"]
)
```

### Data Visualization

```julia
# Create treatment effect visualization
fig = Figure(resolution = (800, 600))

# Panel A: Outcome by treatment
ax1 = Axis(fig[1, 1], 
    title = "Panel A: Treatment vs Control",
    xlabel = "Group", 
    ylabel = "Outcome Score"
)

treatment_data = data[data.treatment .== 1, :outcome]
control_data = data[data.treatment .== 0, :outcome]

boxplot!(ax1, [1], treatment_data, label="Treatment")
boxplot!(ax1, [0], control_data, label="Control") 
ax1.xticks = ([0, 1], ["Control", "Treatment"])

# Panel B: Age vs outcome, colored by treatment
ax2 = Axis(fig[1, 2],
    title = "Panel B: Age Effect by Treatment",
    xlabel = "Age (years)",
    ylabel = "Outcome Score"
)

treated = data.treatment .== 1
scatter!(ax2, data.age[treated], data.outcome[treated], 
         color = :red, alpha = 0.6, label = "Treatment")
scatter!(ax2, data.age[.!treated], data.outcome[.!treated], 
         color = :blue, alpha = 0.6, label = "Control")

# Add regression lines
age_range = extrema(data.age)
age_smooth = range(age_range[1], age_range[2], length=50)

# Treatment group line
treat_coef = coef(lm(@formula(outcome ~ age), data[treated, :]))
lines!(ax2, age_smooth, treat_coef[1] .+ treat_coef[2] .* age_smooth, 
       color = :red, linewidth = 2)

# Control group line  
control_coef = coef(lm(@formula(outcome ~ age), data[.!treated, :]))
lines!(ax2, age_smooth, control_coef[1] .+ control_coef[2] .* age_smooth, 
       color = :blue, linewidth = 2)

axislegend(ax2)

# Export figure
figure_export(
    "treatment_analysis.png",
    fig,
    save;
    caption = "(A) Distribution of outcome scores by treatment group showing clear treatment effect. (B) Relationship between age and outcome, with separate regression lines for treatment and control groups demonstrating parallel trends.",
    short_caption = "Treatment Effect Analysis"
)
```

### Results Summary Figure

```julia
# Create coefficient plot
coef_fig = Figure(resolution = (600, 400))
ax = Axis(coef_fig[1, 1],
    title = "Treatment Effect Across Model Specifications",
    xlabel = "Coefficient Estimate",
    ylabel = "Model"
)

# Extract treatment coefficients and standard errors
treatment_coefs = [coef(m)[2] for m in models]  # Treatment is second coefficient
treatment_ses = [sqrt(vcov(m)[2, 2]) for m in models]

model_names = ["Bivariate", "Age Control", "Income Control", "Full Model"]
y_pos = 1:length(models)

# Plot point estimates with error bars
scatter!(ax, treatment_coefs, y_pos, markersize = 12, color = :red)
errorbars!(ax, treatment_coefs, y_pos, treatment_ses, direction = :x, 
           linewidth = 2, whiskerwidth = 8)

# Add zero line
vlines!(ax, [0], color = :gray, linestyle = :dash)

# Customize y-axis
ax.yticks = (y_pos, model_names)

figure_export(
    "coefficient_plot.png",
    coef_fig,
    save;
    caption = "Treatment effect estimates across model specifications. Point estimates with 95% confidence intervals demonstrate robustness of treatment effect to inclusion of control variables.",
    short_caption = "Coefficient Plot"
)
```

## Typst Document Integration

Create a main Typst document that uses all the generated outputs:

```typst
#import "@preview/tablex:0.0.9": *

#set document(title: "Treatment Effect Analysis")
#set page(margin: (x: 3cm, y: 2.5cm))
#set text(size: 11pt)

#align(center)[
  #text(size: 18pt, weight: "bold")[Treatment Effect Analysis]
  
  #text(size: 12pt)[A Study of Intervention Outcomes]
  
  #v(1em)
  
  #text(size: 10pt)[Author Name • Institution • Date]
]

#pagebreak()

= Introduction

This study examines the effectiveness of a treatment intervention 
on participant outcomes, controlling for demographic and economic factors.

= Data and Methods

Our analysis uses data from 200 participants randomly assigned to 
treatment and control groups. @descriptive_stats provides summary 
statistics for the key analysis variables.

#include("descriptive_stats.typ")

= Results

== Treatment Effects

The main results are presented in @regression_analysis, which shows 
progressive model specifications adding control variables.

#include("regression_analysis.typ")

The treatment effect remains statistically significant and substantively 
meaningful across all specifications, suggesting robustness to model 
specification.

== Visual Analysis  

@treatment_analysis provides visual evidence of the treatment effect.

#include("treatment_analysis.typ")

The consistency of the treatment effect across model specifications 
is demonstrated in @coefficient_plot.

#include("coefficient_plot.typ")

= Discussion

The results provide strong evidence for a positive treatment effect...

= References

// Add your references here
```

## Statistical Power Analysis Example

```julia
# Power analysis for future studies
using Distributions

function simulate_power(effect_size, n_per_group, alpha = 0.05, nsim = 1000)
    significant_results = 0
    
    for i in 1:nsim
        # Simulate data
        treatment = vcat(zeros(n_per_group), ones(n_per_group))
        outcome = randn(2 * n_per_group) + effect_size * treatment
        
        # Fit model
        sim_data = DataFrame(treatment = treatment, outcome = outcome)
        model = lm(@formula(outcome ~ treatment), sim_data)
        
        # Check if significant
        p_value = coeftable(model).cols[4][2]  # p-value for treatment
        if p_value < alpha
            significant_results += 1
        end
    end
    
    return significant_results / nsim
end

# Calculate power for different sample sizes
sample_sizes = [25, 50, 75, 100, 150, 200]
effect_size = 0.5
power_results = [simulate_power(effect_size, n) for n in sample_sizes]

# Create power analysis table
power_df = DataFrame(
    SamplePerGroup = sample_sizes,
    TotalSample = 2 * sample_sizes,
    Power = round.(power_results, digits = 3)
)

table_export(
    "power_analysis",
    tablex(power_df);
    caption = "Statistical power analysis for detecting treatment effect of 0.5 standard deviations at α = 0.05. Power calculated from 1,000 Monte Carlo simulations per sample size.",
    short_caption = "Power Analysis"
)

# Plot power curve
power_fig = Figure(resolution = (600, 400))
ax = Axis(power_fig[1, 1],
    xlabel = "Sample Size per Group",
    ylabel = "Statistical Power",
    title = "Power Analysis for Treatment Effect Detection"
)

lines!(ax, sample_sizes, power_results, linewidth = 3, color = :blue)
scatter!(ax, sample_sizes, power_results, markersize = 8, color = :red)
hlines!(ax, [0.8], color = :gray, linestyle = :dash, label = "80% Power")
axislegend(ax)

figure_export(
    "power_curve.png",
    power_fig,
    save;
    caption = "Statistical power as a function of sample size per group. Horizontal dashed line indicates conventional 80% power threshold. Analysis assumes effect size of 0.5 standard deviations.",
    short_caption = "Power Curve"
)
```

This comprehensive example demonstrates:

1. **Data generation and management**
2. **Descriptive statistics tables** 
3. **Progressive regression modeling**
4. **Multi-panel data visualization**
5. **Coefficient plotting for robustness**
6. **Power analysis for study design**
7. **Integration into a complete Typst document**

The workflow separates analysis (Julia) from writing (Typst), allowing you to update analyses without recompiling the entire document.