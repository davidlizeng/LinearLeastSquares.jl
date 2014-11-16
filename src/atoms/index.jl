import Base.getindex
export getindex


getindex{T <: Real}(x::Constant, inds::AbstractArray{T, 1}) = Constant(getindex(x.value, inds))
getindex{T <: Real}(x::Constant, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1}) = Constant(getindex(x.value, rows, cols))

function getindex{T <: Real}(x::AffineExpr, inds::AbstractArray{T, 1})
  # number of rows/cols in the coefficient for x in our canonical form
  num_rows_coeff = length(inds)
  num_cols_coeff = x.size[1] * x.size[2]
  indexer = Constant(sparse(1:length(inds), inds, 1.0, num_rows_coeff, num_cols_coeff))

  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (num_rows_coeff, 1))
  this.evaluate = ()->x.evaluate()[inds]
  return this
end

function getindex{T <: Real}(x::AffineExpr, row::T, col::T)
  position = x.size[1] * (convert(Int64, col) - 1) + convert(Int64, row)
  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = c[position, :]
  end
  constant = x.constant[position, :]
  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (1, 1))
  this.evaluate = ()->x.evaluate()[row, col]
  return this
end

function getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1})
  if length(rows) == 1 && length(cols) == 1
    return getindex(x, rows[1], cols[1])
  end
  # number of rows/cols in the coefficient for x in our canonical form
  num_rows_coeff = length(rows) * length(cols)
  num_cols_coeff = x.size[1] * x.size[2]

  # Create the indexing matrix such that indexer * vec(x) = vec(x[rows, cols])
  J = Array(Int64, num_rows_coeff)
  k = 1
  num_rows = x.size[1]
  for c in cols
    for r in rows
      J[k] = num_rows * (convert(Int64, c) - 1) + convert(Int64, r)
      k += 1
    end
  end
  indexer = Constant(sparse(1:num_rows_coeff, J, 1.0, num_rows_coeff, num_cols_coeff))

  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (length(rows), length(cols)))
  this.evaluate = ()->x.evaluate()[rows, cols]
  return this
end

getindex(x::AffineOrConstant, ind::Real) = getindex(x, ind:ind)
getindex(x::AffineOrConstant, row::Real, col::Real) = getindex(x, row:row, col:col)
getindex{T <: Real}(x::AffineOrConstant, row::Real, cols::AbstractArray{T, 1}) = getindex(x, row:row, cols)
getindex{T <: Real}(x::AffineOrConstant, rows::AbstractArray{T, 1}, col::Real) = getindex(x, rows, col:col)
