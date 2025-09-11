# Tables

Typst.jl provides comprehensive support for creating tables using the [typst-tablex](https://github.com/PgBiel/typst-tablex) package, which allows for more sophisticated tables than base Typst.

## Table Architecture

Tables in Typst.jl are built around structs that correspond to tablex functions:

- `TableX`: The main table container
- `CellX`: Individual table cells
- `HLineX`: Horizontal lines
- `VLineX`: Vertical lines

These are all subtypes of the `TableComponent` abstract type.

## DataFrame Tables

The most common use case is converting a Julia DataFrame to a Typst table:

```julia
using DataFrames

# Create sample data
df = DataFrame(
    Product = ["Widget A", "Widget B", "Widget C"],
    Sales = [1000, 1500, 800],
    Profit = [200, 350, 120],
    MarginPct = [20.0, 23.3, 15.0]
)

# Convert to table
tb = tablex(df)

# Export with formatting options
table_export(
    "sales_table",
    tb;
    caption = "Sales performance by product for Q3 2024",
    short_caption = "Q3 Sales Performance"
)
```

## Table Customization

### Column Widths

You can control column widths by modifying the generated table:

```julia
# The exported .typ file includes width variables you can modify:
# #let col1width = 12em
# #let coliwidth = auto
```

### Grid vs Table Style

Use `gridx` for tables without default borders:

```julia
tb = tablex(df; grid = true)  # Creates gridx instead of tablex
```

### Alignment

Control cell alignment:

```julia
# Tables support various alignment options
# Default is center + horizon for most cells
# First column is typically left-aligned for row headers
```

## Manual Table Construction

For more control, construct tables manually:

```julia
# Create individual cells
cells = [
    CellX(0, 0, "Header 1"),
    CellX(1, 0, "Header 2"),
    CellX(0, 1, "Data 1"),
    CellX(1, 1, "Data 2"),
]

# Add horizontal lines
hlines = [
    HLineX(0),  # Top border
    HLineX(1),  # After header
    HLineX(2),  # Bottom border
]

# Combine into table
tb = TableX(
    columns = "(auto, auto)",
    items = vcat(cells, hlines)
)
```

## Table Export Options

The `table_export` function provides many customization options:

```julia
table_export(
    "filename",
    table;
    caption = "Long caption text",
    short_caption = "Short caption for list of tables",
    placement = :auto,        # or :top, :bottom, :here
    kind = :table,           # figure kind
    numbering = "1",         # numbering format
    outlined = true,         # include in outline/list of tables
    extra = "custom typst code"  # additional Typst code to include
)
```

## Advanced Features

### Breakable Tables

Tables automatically support page breaks:

```julia
# Tables include: #show figure: set block(breakable: true)
# This allows tables to span multiple pages
```

### Custom Cell Formatting

Individual cells can have custom formatting:

```julia
# Cells support various Typst formatting options
# Including alignment, styling, and content formatting
```

### Integration with Statistical Models

See [Regression Tables](@ref) for specialized support for statistical model output.

## Best Practices

1. **Use descriptive captions**: Both long and short captions help readers understand your tables
2. **Consider column widths**: Adjust the generated width variables for better layout
3. **Choose appropriate alignment**: Left-align text, right-align numbers
4. **Use grid style sparingly**: Only when borders would be distracting
5. **Test page breaks**: Ensure long tables break appropriately