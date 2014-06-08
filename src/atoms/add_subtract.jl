export +, -

function promote_size(x::AffineOrConstant, y::AffineOrConstant)
  if x.size == y.size
    return x, y, x.size
  elseif x.size == (1, 1)
    return repmat(x, y.size[1], y.size[2]), y, y.size
  elseif y.size == (1, 1)
    return x, repmat(y, x.size[1], y.size[2]), x.size
  else
    error ("Cannot add two expressions with sizes $(x.size) and $(y.size)")
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
  this = AffineExpr(:-, (x,), vars_to_coeffs_map, -x.constant, x.size)
  this.evaluate = ()->-this.value;
  return this
end

# Binary Addition

function +(x::Constant, y::Constant)
  x, y, sz = promote_size(x, y)
  return Constant(x.value + y.value)
end

function +(x::AffineExpr, y::Constant)
  x, y, sz = promote_size(x, y)
  vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
  constant = x.constant + Constant(vec([y.value]))
  this = AffineExpr(:+, (x, y), vars_to_coeffs_map, constant, sz)
  # TODO: eval
  return this
end

function +(x::Constant, y::AffineExpr)
  return y + x
end

function +(x::AffineExpr, y::AffineExpr)
  x, y, sz = promote_size(x, y)
  vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
  for (v, c) in y.vars_to_coeffs_map
    if haskey(vars_to_coeffs_map, v)
      vars_to_coeffs_map[v] = vars_to_coeffs_map[v] + c
    else
      vars_to_coeffs_map[v] = c
    end
  end
  constant = x.constant + y.constant
  this = AffineExpr(:+, (x, y), vars_to_coeffs_map, constant, sz)
  # TODO: eval
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
-(x::Value, y::AffineExpr) = -(Constant(x), y)
