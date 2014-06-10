export mean

function mean(x::AffineExpr, dim::Int64)
  # TODO: use / once supported
  return sum(x, dim) * (1 / x.size[dim])
end
