export eval_internals, set_value!

function eval_internals(x::AffineExpr, vars::Tuple)
  (rows, cols) = x.size
  value = zeros(rows, cols)
  for var in vars
    coeff = x.vars_to_coeffs_map[object_id(var)]
    value += reshape(coeff.value * vec(var.value), rows, cols)
  end
  value += reshape(x.constant.value, rows, cols)
  return value
end

function set_value!(x::AffineExpr, value::Number)
  x.value = convert(Float64, value)
end

function set_value!(x::AffineExpr, value::AbstractArray)
  x.value = convert(SparseMatrixCSC{Float64, Int64}, sparse(value))
end
