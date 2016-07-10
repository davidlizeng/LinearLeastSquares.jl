import Base.+, Base.-

export +, -

# Unary Negation

function -(x::Constant)
  return Constant(-x.value)
end

function -(x::AffineExpr)
  vars_to_coeffs_map = Dict{UInt64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = -c
  end
  this = AffineExpr(:-, (x,), vars_to_coeffs_map, -x.constant, x.size)
  this.evaluate = ()->(-x.evaluate())
  return this
end

# Binary Addition


function +(x::Constant, y::Constant)
  if x.size == (1, 1) || y.size == (1, 1) || x.size == y.size
    return convert(Constant, x.value + y.value)
  else
    error("Cannot add two expressions with sizes $(x.size) and $(y.size)")
  end
end

function +(x::AffineExpr, y::Constant)
  if x.size != (1, 1) && y.size != (1, 1) && x.size != y.size
    error("Cannot add two expressions with sizes $(x.size) and $(y.size)")
  end

  if x.size == (1, 1) && y.size != (1, 1)
    x = repmat(x, y.size[1], y.size[2])
  end

  vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
  constant = x.constant + vec(y)
  this = AffineExpr(:+, (x, y), vars_to_coeffs_map, constant, x.size)
  this.evaluate = ()->x.evaluate() + y.evaluate()
  return this
end

function +(x::Constant, y::AffineExpr)
  return y + x
end

function +(x::AffineExpr, y::AffineExpr)
  if x.size != (1, 1) && y.size != (1, 1) && x.size != y.size
    error("Cannot add two expressions with sizes $(x.size) and $(y.size)")
  end

  if x.size == (1, 1) && y.size != (1, 1)
    x = repmat(x, y.size[1], y.size[2])
  elseif y.size == (1, 1) && x.size != (1, 1)
    y = repmat(y, x.size[1], x.size[2])
  end

  vars_to_coeffs_map = copy(x.vars_to_coeffs_map)
  for (v, c) in y.vars_to_coeffs_map
    if haskey(vars_to_coeffs_map, v)
      vars_to_coeffs_map[v] = vars_to_coeffs_map[v] + c
    else
      vars_to_coeffs_map[v] = c
    end
  end
  constant = x.constant + y.constant
  this = AffineExpr(:+, (x, y), vars_to_coeffs_map, constant, x.size)
  this.evaluate = ()->x.evaluate() + y.evaluate()
  return this
end

+(x::AffineExpr, y::Numeric) = +(x, convert(Constant, y))
+(x::Numeric, y::AffineExpr) = +(y, convert(Constant, x))


function +(x::SumSquaresExpr, y::SumSquaresExpr)
  affines = copy(x.affines)
  multipliers = copy(x.multipliers)
  append!(affines, y.affines)
  append!(multipliers, y.multipliers)
  this = SumSquaresExpr(:+, affines, multipliers, x.scalar + y.scalar)
  return this
end

function +(x::Number, y::SumSquaresExpr)
  try
    x = convert(Float64, x)
  catch
    error("Only real scalars can be added to Sum Squares expressions")
  end
  if x < 0
    error("Only nonnegative scalars can be added to Sum Squares expressions")
  end
  this = SumSquaresExpr(:+, y.affines, y.multipliers, y.scalar + x)
  return this
end

+(x::SumSquaresExpr, y::Number) = +(y, x)


# Binary Subtraction
-(x::AffineExpr, y::AffineExpr) = +(x, -y)
-(x::AffineExpr, y::Constant) = +(x, -y)
-(x::Constant, y::AffineExpr) = +(-y, x)
-(x::AffineExpr, y::Numeric) = -(x, convert(Constant, y))
-(x::Numeric, y::AffineExpr) = -(convert(Constant, x), y)
