import Base.transpose, Base.ctranspose
export transpose, ctranspose

transpose(x::Constant) = Constant(transpose(x.value))
ctranspose(x::Constant) = transpose(x)

function transpose(x::AffineExpr)
  vec_sz = x.size[1] * x.size[2]
  perm_matrix = spzeros(vec_sz, vec_sz)
  num_rows = x.size[1]
  num_cols = x.size[2]

  for r = 1:num_rows
    for c = 1:num_cols
      i = (c - 1) * num_rows + r
      j = (r - 1) * num_cols + c
      perm_matrix[i, j] = 1.0
    end
  end

  perm_constant = Constant(perm_matrix)

  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = perm_constant * c
  end
  constant = perm_constant * x.constant

  this = AffineExpr(:transpose, (x,), vars_to_coeffs_map, constant, (x.size[2], x.size[1]))
  this.evaluate = ()->x.evaluate()'
  return this
end

ctranspose(x::AffineExpr) = transpose(x::AffineExpr)
