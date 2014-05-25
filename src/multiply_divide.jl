export *,/

function *(x::Constant, y::Constant)
  if x.size == (1, 1)
    return Constant(x.value[1] * y.value)
  elseif y.size == (1, 1)
    return Constant(x.value * y.value[1])
  else
    return Constant(x.value * y.value)
  end
end

function *(x::Constant, y::AffineExpr)

end

function *(x::AffineExpr, y::Constant)
  if x.size == y.size


  elseif y.size == (1, 1) || x.size == (1, 1)
    return y*x
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end

end

function *(x::Constant, y::SumSquaresExpr)
end

function *(x::SumSquaresExpr, y::Constant)
end