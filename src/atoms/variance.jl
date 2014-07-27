import Base.var
export var

function var(x::AffineExpr)
  return sum_squares(mean(x) - x) / (x.size[1] * x.size[2])
end
