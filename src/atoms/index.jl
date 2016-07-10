import Base.getindex
export getindex


getindex{T <: Real}(x::Constant, inds::AbstractArray{T, 1}) = Constant(getindex(x.value, inds))
getindex{T <: Real}(x::Constant, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1}) = Constant(getindex(x.value, rows, cols))

function getindex{T <: Real}(x::AffineExpr, inds::AbstractArray{T, 1})
  if length(inds) == 1
    # select only one entry of x
    ind = convert(Int64, inds[1])
    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = c[ind, :]
    end
    constant = x.constant[ind, :]
  else
    # number of rows/cols in the coefficient for x in our canonical form
    num_rows_coeff = length(inds)
    num_cols_coeff = x.size[1] * x.size[2]
    indexer = Constant(sparse(1:length(inds), inds, 1.0, num_rows_coeff, num_cols_coeff))

    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = indexer * c
    end
    constant = indexer * x.constant
  end
  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (length(inds), 1))
  this.evaluate = ()->x.evaluate()[inds]
  return this
end

function getindex{T <: Real}(x::AffineExpr, rows::AbstractArray{T, 1}, cols::AbstractArray{T, 1})
  if length(rows) == 1 && length(cols) == 1
    # select only one entry of x
    ind = x.size[1] * (convert(Int64, cols[1]) - 1) + convert(Int64, rows[1])
    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = c[ind, :]
    end
    constant = x.constant[ind, :]
  elseif length(cols) == 1 && typeof(rows) == UnitRange{Int64}
    # build a range object to just select the part of a column in x
    ind = x.size[1] * (convert(Int64, cols[1]) - 1)
    ind_range = (ind + rows[1]) : (ind + rows[end])
    vars_to_coeffs_map = Dict{UInt64, Constant}()

    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = c[ind_range, :]
    end
    constant = x.constant[ind_range, :]
  elseif length(rows) == 1 && typeof(cols) == UnitRange{Int64}
    # build a range object to just select part of a row in x
    start_ind = x.size[1] * (cols[1] - 1)
    end_ind = x.size[1] * (cols[end] - 1)
    ind_range = (start_ind + rows[1]) : x.size[1] : (end_ind + rows[1])

    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = c[ind_range, :]
    end
    constant = x.constant[ind_range, :]
  else
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

    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = indexer * c
    end
    constant = indexer * x.constant
  end

  this = AffineExpr(:index, (x,), vars_to_coeffs_map, constant, (length(rows), length(cols)))
  this.evaluate = ()->x.evaluate()[rows, cols]
  return this
end

getindex(x::AffineOrConstant, ind::Colon) = getindex(x, 1:size(x,1)*size(x,2))
getindex{T <: Real}(x::AffineOrConstant, rows::Colon, cols::AbstractArray{T, 1}) = getindex(x, 1:size(x, 1), cols)
getindex{T <: Real}(x::AffineOrConstant, rows::AbstractArray{T, 1}, col::Colon) = getindex(x, rows, 1:size(x,2))

getindex(x::AffineOrConstant, ind::Real) = getindex(x, ind:ind)
getindex(x::AffineOrConstant, row::Real, col::Real) = getindex(x, row:row, col:col)
getindex{T <: Real}(x::AffineOrConstant, row::Real, cols::AbstractArray{T, 1}) = getindex(x, row:row, cols)
getindex{T <: Real}(x::AffineOrConstant, rows::AbstractArray{T, 1}, col::Real) = getindex(x, rows, col:col)
getindex(x::AffineOrConstant, rows::Colon, col::Real) = getindex(x, 1:size(x,1), col:col)
getindex(x::AffineOrConstant, row::Real, cols::Colon) = getindex(x, row:row, 1:size(x,2))
