export variance

function variance(x::AffineExpr)
  vec_sz = x.size[1] * x.size[2]

  # TODO: use / once supported on AffineExpr
  return (1 / vec_sz) * sum_squares(sum(x) * (1 / vec_sz) - x)
end
