import Base.getindex
export getindex


getindex{T <: Real}(x::Constant, inds::AbstractArray{T, 1}) = Constant(getindex(x.value, inds))
getindex{T <: Real}(x::Constant, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1}) = Constant(getindex(x.value, rows, cols))

function getindex{T <: Real}(x::AffineExpr, inds::AbstractArray{T, 1})
  indexer = Constant(spzeros(length(inds), x.size[1] * x.size[2]))
  k = 1
  for i in inds
    indexer.value[k, i] = 1
    k += 1
  end

  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (length(inds), 1))
  this.evaluate = ()->x.evaluate()[inds]
  return this
end

function getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1})
  # number of rows/cols in the coefficient for x in our canonical form
  num_rows_coeff = length(rows) * length(cols)
  num_cols_coeff = x.size[1] * x.size[2]

  indexer = Constant(spzeros(num_rows_coeff, num_cols_coeff))

  # Create the indexing matrix such that indexer * vec(x) = vec(x[rows, cols])
  k = 1
  num_rows = x.size[1]
  for c in cols
    for r in rows
      idx = num_rows * (convert(Int64, c) - 1) + convert(Int64, r)
      indexer.value[k, idx] = 1
      k += 1
    end
  end

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
