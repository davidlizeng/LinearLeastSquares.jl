import Base.reshape, Base.vec
export reshape, vec

reshape(x::Constant, m::Int64, n::Int64) = Constant(reshape(x.value, m, n))

function reshape(x::AffineExpr, m::Int64, n::Int64)
  error("TODO: not implemented")
end

vec(x::AffineOrConstant) = reshape(x, x.size[1] * x.size[2], 1)
