import Base.mean
export mean

function mean(x::AffineExpr)
  return sum(x) / (x.size[1] * x.size[2])
end

function mean(x::AffineExpr, dim::Int64)
  return sum(x, dim) / x.size[dim]
end
