export +, -

function promote_size(x::AbstractExpr, y::AbstractExpr)
  if x.size == y.size
    return x.size
  elseif x.size == (1, 1)
    return y.size
  elseif y.size == (1, 1)
    return x.size
  else
    error ("Cannot add two expressions with sizes $(x.size) and $(y.size)")
  end
end

function promote_constant(x::AbstractExpr, y::Constant)
  if y.size == (1, 1) && x.size != (1, 1)
    return Constant(ones(x.size)*y)
  else
    return y
  end
end

function reverse_sign(x::AbstractExpr)
  if x.sign == :pos
    return :neg
  elseif x.sign == :neg
    return :pos
  else
    return :any
  end
end

function promote_sign(x::AbstractExpr, y::AbstractExpr)
  signs = Set(x.sign, y.sign)
  if :any in signs || signs == Set(:pos,:neg)
    return :any
  else
    return x.sign
  end
end

# Unary Negation

function -(x::Constant)
  return Constant(-x.value)
end

function -(x::AffineExpr)
  varsToCoeffsMap = Dict{Uint64, Constant}()
  for (v, c) in x.varsToCoeffsMap
    varsToCoeffsMap[v] = -c
  end
  this = AffineExpr(:-, varsToCoeffsMap, -x.constant reverse_sign(x), x.size)
  return this
end


# Binary Addition

function +(x::Constant, y::Constant)
  if x.size == (1, 1)
    return Constant(x.value[1] + y.value)
  elseif y.size == (1, 1)
    return Constant(x.value + y.value[1])
  else
    return Constant(x.value + y.value)
  end
end

function +(x::AffineExpr, y::Constant)
  sz = promote_size(x, y)
  if sz == x.size
    varsToCoeffsMap = copy(x.varsToCoeffsMap)
  else
    vec_sz = sz[1]*sz[2]
    varsToCoeffsMap = Dict{Uint64, Constant}()
    for (v, c) in x.varsToCoeffsMap
      varsToCoeffsMap[v] = Constant(repmat([c.value], vec_sz, 1))
    end
  end
  constant = x.constant + Constant(vec([y.value]))
  return AffineExpr(:+, varsToCoeffsMap, constant, promote_sign(x, y), sz)
end

function +(x::Constant, y::AffineExpr)
  return y + x
end

function +(x::AffineExpr, y::AffineExpr)
  sz = promote_size(x, y)
  if x.size == y.size
    varsToCoeffsMap = copy(x.varsToCoeffsMap)
    for (v, c) in y.varsToCoeffsMap
      if v in varsToCoeffsMap
        varsToCoeffsMap[v] = varsToCoeffsMap[v] + c
      else
        varsToCoeffsMap[v] = c
      end
    end
  elseif x.size == (1, 1)
    return y + x
  elseif y.size == (1, 1)
    vec_sz = sz[1]*sz[2]
    varsToCoeffsMap = copy(x.varsToCoeffsMap)
    for (v, c) in y.varsToCoeffsMap
      if v in varsToCoeffsMap
        varsToCoeffsMap[v] = varsToCoeffsMap[v] + Constant(repmat([c.value], vec_sz, 1))
      else
        varsToCoeffsMap[v] = c
      end
    end
  else
    error("Cannot add two expressions of sizes $(x.size) and $(y.size)")
  end
  constant = x.constant + y.constant
  this = AffineExpr(:+, varsToCoeffsMap, constant, promote_sign(x, y), sz)
  return this
end

function +(x::SumSquaresExpr, y::SumSquaresExpr)
end

+(x::AffineExpr, y::Value) = +(x, Constant(y))
+(x::Value, y::AffineExpr) = +(y, Constant(x))


# Binary Subtraction

-(x::AffineExpr, y::AffineExpr) = +(x, -y)
-(x::AffineExpr, y::Value) = +(x, -y)
-(x::Value, y::AffineExpr) = +(-y, x)