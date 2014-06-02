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
  vars_to_coeffs_map = Dict{Uint64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = -c
  end
  this = AffineExpr(:-, vars_to_coeffs_map, -x.constant, reverse_sign(x), x.size)
  #TODO eval
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
    vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
  else
    vec_sz = sz[1]*sz[2]
    vars_to_coeffs_map = Dict{Uint64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = Constant(repmat([c.value], vec_sz, 1))
    end
  end
  constant = x.constant + Constant(vec([y.value]))
  this = AffineExpr(:+, vars_to_coeffs_map, constant, promote_sign(x, y), sz)
  #TODO eval
  return this
end

function +(x::Constant, y::AffineExpr)
  return y + x
end

function +(x::AffineExpr, y::AffineExpr)
  sz = promote_size(x, y)
  if x.size == y.size
    vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
    for (v, c) in y.vars_to_coeffs_map
      if v in vars_to_coeffs_map
        vars_to_coeffs_map[v] = vars_to_coeffs_map[v] + c
      else
        vars_to_coeffs_map[v] = c
      end
    end
  elseif x.size == (1, 1)
    return y + x
  elseif y.size == (1, 1)
    vec_sz = sz[1]*sz[2]
    vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
    for (v, c) in y.vars_to_coeffs_map
      if v in vars_to_coeffs_map
        vars_to_coeffs_map[v] = vars_to_coeffs_map[v] + Constant(repmat([c.value], vec_sz, 1))
      else
        vars_to_coeffs_map[v] = c
      end
    end
  else
    error("Cannot add two expressions of sizes $(x.size) and $(y.size)")
  end
  constant = x.constant + y.constant
  this = AffineExpr(:+, vars_to_coeffs_map, constant, promote_sign(x, y), sz)
  #TODO eval
  return this
end

function +(x::SumSquaresExpr, y::SumSquaresExpr)
  affines = copy(x.affines)
  append!(affines, y.affines)
  this = SumSquaresExpr(:+, affines)
  return this
end

+(x::AffineExpr, y::Value) = +(x, Constant(y))
+(x::Value, y::AffineExpr) = +(y, Constant(x))


# Binary Subtraction

-(x::AffineExpr, y::AffineExpr) = +(x, -y)
-(x::AffineExpr, y::Constant) = +(x, -y)
-(x::Constant, y::AffineExpr) = +(-y, x)
-(x::AffineExpr, y::Value) = -(x, Constant(y))
-(x::Value, y::AffineExpr) = -(Constant(y), x)