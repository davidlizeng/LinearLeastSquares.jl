import Base.sum
export sum

function sum(x::AffineExpr)
  return ones(1, x.size[1]) * x * ones(x.size[2], 1)
end

function sum(x::AffineExpr, dim::Int64)
  if dim == 1
    return ones(1, x.size[1]) * x
  elseif dim == 2
    return x * ones(x.size[2], 1)
  else
    error("dimension must be 1 or 2, but got $dimension")
  end
end
