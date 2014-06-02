export getindex

function getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1} = [1])
  # number of rows/cols in the coefficient for x in our canonical form
  num_rows_coeff = length(rows) * length(cols)
  num_cols_coeff = x.size[1] * x.size[2]

  coeff = spzeros(num_rows_coeff, num_cols_coeff)

  # Create the coeff matrix such that coeff * vec(x) = vec(x[rows, cols])
  k = 1
  num_rows = x.size[1]
  for c in cols
    for r in rows
      idx = num_rows * (c - 1) + r
      coeff[k, idx] = 1
      k += 1
    end
  end
  
  return coeff * x
end

getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{1, T}) = getindex(x, rows')
getindex(x::AffineExpr, row::Number, col::Number = 1) = getindex(x, row:row, col:col)
getindex{T <: Real}(x::AffineExpr, row::Number, cols::AbstractArray{T, 1}) = getindex(x, row:row, cols)
getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, col::Number) = getindex(x, rows, col:col)