export *

# Utility function for handling sign for multiplication/division
function promote_sign(x::Constant, y::AffineExpr)
  if x.sign == :zero || y.sign == :zero
    return :zero
  elseif x.sign == :pos
    return y.sign
  elseif x.sign == :neg
    return reverse_sign(y)
  else
    return :any
  end
end

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
  if x.size[2] == y.size[1]
    x_kron = Constant(kron(speye(y.size[2]), x.value))
    varsToCoeffsMap = Dict{Uint64, Constant}()
    for (v, c) in y.varsToCoeffsMap
      varsToCoeffsMap[v] = x_kron * c
    end
    constant = x_kron * y.constant
    this = AffineExpr(:*, varsToCoeffsMap, constant, promote_sign(x, y), (x.size[1], y.size[2]))
  elseif x.size == (1, 1)
    varsToCoeffsMap = Dict{Uint64, Constant}()
    for (v, c) in y.varsToCoeffsMap
      varsToCoeffsMap[v] = x * c
    end
    constant = x * y.constant
    this = AffineExpr(:*, varsToCoeffsMap, constant, promote_sign(x, y), y.size)
  elseif y.size == (1, 1)
    vec_sz = x.size[1] * x.size[2]
    varsToCoeffsMap = Dict{Uint64, Constant}()
    for (v, c) in y.varsToCoeffsMap
      coeff_rep = repmat([c.value], vec_sz, 1)
      for i in 1:vec_sz
        coeff_rep[i,:] = x.value[i] * c_rep[i,:]
      end
      varsToCoeffsMap[v] = Constant(coeff_rep)
    end
    constant_rep = repmat([y.constant.value], vec_sz, 1)
    for i in 1:vec_sz
      constant_rep[i,:] = x.value[i] * y_constant_rep[i,:]
    end
    constant = Constant(constant_rep)
    this = AffineExpr(:*, varsToCoeffsMap, constant, promote_sign(x, y), x.size)
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

function *(x::AffineExpr, y::Constant)
  if x.size[2] == y.size[1]
    error("Right multiplication not supported yet")
  elseif y.size == (1, 1) || x.size == (1, 1)
    return y*x
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

*(x::Value, y::AffineExpr) = *(Constant(x), y)
*(x::AffineExpr, y::Value) = *(x, Constant(y))


function *(x::Constant, y::SumSquaresExpr)
  if y.size != (1, 1) || y.sign != :pos
    error("Sum Squares expressions can only be multiplied by nonegative scalars")
  end
  return SumSquaresExpr(:*, x*y.arg)
end

*(x::SumSquaresExpr, y::Constant) = *(y, x)
