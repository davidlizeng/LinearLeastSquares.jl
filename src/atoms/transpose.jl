import Base.transpose, Base.ctranspose
export transpose, ctranspose

transpose(x::Constant) = Constant(transpose(x.value))
ctranspose(x::Constant) = transpose(x)

function transpose(x::AffineExpr)
  vec_sz = x.size[1] * x.size[2]
  num_rows = x.size[1]
  num_cols = x.size[2]

  I = Array(Int64, vec_sz)
  J = Array(Int64, vec_sz)

  k = 1
  for r = 1:num_rows
    for c = 1:num_cols
      J[k] = (c - 1) * num_rows + r
      I[k] = (r - 1) * num_cols + c
      k += 1
    end
  end

  perm_constant = Constant(sparse(I, J, 1.0))

  vars_to_coeffs_map = Dict{UInt64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = perm_constant * c
  end
  constant = perm_constant * x.constant

  this = AffineExpr(:transpose, (x,), vars_to_coeffs_map, constant, (num_cols, num_rows))
  this.evaluate = ()->x.evaluate()'
  return this
end

ctranspose(x::AffineExpr) = transpose(x::AffineExpr)
