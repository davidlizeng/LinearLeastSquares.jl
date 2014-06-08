import Base.reshape, Base.vec
export reshape, vec

reshape(x::Constant, m::Int64, n::Int64) = Constant(reshape(x.value, m, n))

function reshape(x::AffineExpr, m::Int64, n::Int64)
  if x.size[1] * x.size[2] != m * n
    error("Cannot reshape expression of size $(x.size[1]) by $(x.size[2]) to $m by $n")
  end
  this = AffineExpr(:reshape, (x,), x.vars_to_coeffs_map, x.constant, (m, n))
  this.evaluate = ()->reshape(x.evaluate(), m, n)
  return this
end

vec(x::AffineOrConstant) = reshape(x, x.size[1] * x.size[2], 1)
