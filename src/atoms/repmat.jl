import Base.repmat
export repmat

function repmat(x::Constant, m::Int64, n::Int64)
  return Constant(repmat(x.value, m, n))
end

function repmat(x::AffineExpr, m::Int64, n::Int64)
  vec_sz = m * n
  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = repmat(c, vec_sz, 1)
  end
  constant = repmat(x.constant, vec_sz, 1)
  this = AffineExpr(:repmat, (x,), vars_to_coeffs_map, constant, (m * x.size[1], n * x.size[2]))
  # TODO: eval
  return this
end
