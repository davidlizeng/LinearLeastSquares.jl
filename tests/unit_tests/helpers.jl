export eval_internals

function eval_internals(x::AffineExpr, vars::Tuple, rows::Int64, cols::Int64)
  value = zeros(rows, cols)
  for var in vars
    coeff = x.vars_to_coeffs_map[object_id(var)]
    value += reshape(coeff.value * vec(var.value), rows, cols)
  end
  value += reshape(x.constant.value, rows, cols)
  return value
end
