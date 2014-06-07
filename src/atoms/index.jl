import Base.getindex
export getindex

function getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1} = [1])
  # number of rows/cols in the coefficient for x in our canonical form
  num_rows_coeff = length(rows) * length(cols)
  num_cols_coeff = x.size[1] * x.size[2]

  indexer_val = spzeros(num_rows_coeff, num_cols_coeff)

  # Create the indexing matrix such that indexer * vec(x) = vec(x[rows, cols])
  k = 1
  num_rows = x.size[1]
  for c in cols
    for r in rows
      idx = num_rows * (convert(Int64, c) - 1) + convert(Int64, r)
      indexer_val[k, idx] = 1
      k += 1
    end
  end

  indexer = Constant(indexer_val)

  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  children = AffineOrConstant[]
  push!(children, x)
  this = AffineExpr(:getindex, children, vars_to_coeffs_map, constant, (length(rows), length(cols)))
  # TODO: eval
  return this
end

getindex(x::AffineExpr, row::Number, col::Number = 1) = getindex(x, row:row, col:col)
getindex{T <: Real}(x::AffineExpr, row::Number, cols::AbstractArray{T, 1}) = getindex(x, row:row, cols)
getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, col::Number) = getindex(x, rows, col:col)
