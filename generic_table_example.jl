# generic_table_example.jl

cells = TableX[];
for i in axes(M, 2), j in axes(M ,1)
    m = round(M[i,j]; digits = 2)
    push!(cells, cellx(content = m, x = i, y = j))
end

cells = [print(cell) for cell in cells]

opts = ["auto-vlines: true", "auto-hlines: true"];

tbl = vcat(opts, cells)
tbl[1:(end-1)] .= tbl[1:(end-1)] .* ", \n";

