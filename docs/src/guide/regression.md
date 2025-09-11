# Regression Tables

Typst.jl provides specialized support for creating publication-ready regression tables from statistical models, with built-in support for GLM.jl and MixedModels.jl.

## Basic Regression Table

Create a regression table from fitted models:

```julia
using GLM, DataFrames

# Prepare data
data = DataFrame(
    X = randn(100),
    Z = randn(100),
    ε = randn(100)
)
data.Y = 2.0 * data.X + 1.5 * data.Z + data.ε

# Fit models
ols1 = lm(@formula(Y ~ X), data)
ols2 = lm(@formula(Y ~ Z), data) 
ols3 = lm(@formula(Y ~ X + Z), data)

# Create regression table
models = [ols1, ols2, ols3]
regtable_typ(
    models, 
    "regression_results";
    caption = "Regression models of Y on X and Z variables"
)
```

## Table Features

Regression tables automatically include:

- **Coefficient estimates** with significance stars
- **Standard errors** in parentheses  
- **Model statistics**: R², Adjusted R², AIC, BIC, N
- **Significance legend**: p-value thresholds for stars
- **Professional formatting**: Aligned columns, appropriate spacing

## Model Support

### GLM.jl Models
```julia
using GLM

# Linear regression
linear_model = lm(@formula(y ~ x1 + x2), data)

# Logistic regression  
logit_model = glm(@formula(binary_y ~ x1 + x2), data, Binomial(), LogitLink())

# Include both in table
regtable_typ([linear_model, logit_model], "mixed_models")
```

### MixedModels.jl Support
```julia
using MixedModels

# Fit mixed effects model
mixed_model = fit(MixedModel, @formula(y ~ x1 + (1|group)), data)

# Include in regression table
regtable_typ([mixed_model], "mixed_effects_results")
```

## Customization Options

### Table Formatting

```julia
regtable_typ(
    models,
    "custom_table";
    caption = "Detailed regression analysis",
    short_caption = "Regression Results",
    
    # Significance levels (default shown)
    alpha_levels = [0.1, 0.05, 0.01, 0.001],
    
    # Column labels  
    model_labels = ["Model 1", "Model 2", "Full Model"],
    
    # Additional statistics
    include_stats = [:r2, :adjr2, :aic, :bic, :nobs, :fstat]
)
```

### Variable Names and Formatting

```julia
# Control variable display names
regtable_typ(
    models,
    "labeled_results";
    variable_labels = Dict(
        "x1" => "Treatment",
        "x2" => "Control Variable", 
        "(Intercept)" => "Constant"
    ),
    
    # Decimal places
    digits = 3,
    
    # Standard error format
    se_format = :parentheses  # or :brackets
)
```

## Model Comparison Tables

Compare multiple model specifications:

```julia
# Progressive model building
base_model = lm(@formula(outcome ~ treatment), data)
control_model = lm(@formula(outcome ~ treatment + age + gender), data)  
full_model = lm(@formula(outcome ~ treatment + age + gender + treatment*age), data)

models = [base_model, control_model, full_model]

regtable_typ(
    models,
    "model_comparison";
    caption = "Progressive addition of control variables and interaction terms",
    model_labels = ["Base", "+ Controls", "+ Interaction"]
)
```

## Advanced Features

### Custom Model Statistics

Add custom statistics to your regression table:

```julia
# Define custom statistic function
function custom_stat(model)
    # Calculate custom statistic
    return some_calculation(model)
end

# Include in table
regtable_typ(
    models,
    "with_custom_stats";
    custom_stats = Dict("Custom Metric" => custom_stat)
)
```

### Panel and Fixed Effects

For panel data models:

```julia
# Panel regression with fixed effects
panel_model = lm(@formula(y ~ x1 + x2 + fe(id) + fe(time)), panel_data)

regtable_typ(
    [panel_model],
    "panel_results";
    caption = "Panel regression with individual and time fixed effects",
    fixed_effects = ["Individual FE", "Time FE"]
)
```

## Output Customization

### Table Layout

The generated `.typ` file includes customizable layout variables:

```typst
#let col1width = 12em        // First column width
#let coliwidth = auto        // Other column widths
```

### Breaking Long Tables

Large regression tables automatically support page breaks:

```julia
# Tables include breakable: true setting
# Long tables will break across pages appropriately
```

## Integration with Documents

Include regression tables in your Typst document:

```typst
= Results

The regression results are presented in @regression_results. 
Model 1 shows the baseline relationship, while Models 2-3 
add control variables and interaction terms.

#include("regression_results.typ")

The coefficients indicate...
```

## Best Practices

1. **Progressive complexity**: Start with simple models, add complexity
2. **Meaningful labels**: Use descriptive model and variable names  
3. **Appropriate statistics**: Include relevant fit statistics
4. **Clear captions**: Explain what each model specification includes
5. **Consistent formatting**: Use the same decimal places across tables
6. **Significance testing**: Report appropriate significance levels
7. **Robustness checks**: Consider including robustness specifications

## Common Patterns

### Treatment Effect Analysis
```julia
# Typical treatment effect progression
baseline = lm(@formula(outcome ~ treatment), data)
with_controls = lm(@formula(outcome ~ treatment + controls...), data)  
with_interaction = lm(@formula(outcome ~ treatment * moderator + controls...), data)

regtable_typ([baseline, with_controls, with_interaction], "treatment_effects")
```

### Sensitivity Analysis
```julia
# Different model specifications for robustness
main_spec = lm(@formula(y ~ x + controls...), data)
alt_spec1 = lm(@formula(log(y) ~ x + controls...), data)  # Log outcome
alt_spec2 = lm(@formula(y ~ x + extended_controls...), data)  # More controls

regtable_typ([main_spec, alt_spec1, alt_spec2], "sensitivity_analysis")
```