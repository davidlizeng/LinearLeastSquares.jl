import Base.*, Base.(.*), Base./, Base.(./)

export *, /

## Constants

# Should only be used internally
.*(x::Constant, y::Constant) = Constant(x.value .* y.value)
*(x::Constant, y::Constant) = Constant(x.value * y.value)


## Affine expressions

# dot multiply currently only used to implement scalar multiplication
# can be extended in the future to support other forms
function .*(x::Constant, y::AffineExpr)
  if x.size != (1, 1) && y.size != (1, 1) && x.size != y.size
    error("Cannot dot multiply two expressions of sizes $(x.size) and $(y.size)")
  end

  if y.size == (1, 1) && x.size != (1, 1)
    y = repmat(y, x.size[1], x.size[2])
  end

  # vec_x needs to be repmat'd for this to work for other forms of dot mult
  vec_x = vec(x)
  vars_to_coeffs_map = Dict{UInt64, Constant}()
  for (v, c) in y.vars_to_coeffs_map
    if vec_x.size != (1, 1) && c.size[2] > 1
      rep_x = repmat(vec_x, 1, c.size[2])
      vars_to_coeffs_map[v] = rep_x .* c
    else
      vars_to_coeffs_map[v] = vec_x .* c
    end
  end
  constant = vec_x .* y.constant

  this = AffineExpr(:.*, (x, y), vars_to_coeffs_map, constant, y.size)
  this.evaluate = ()->x.evaluate() .* y.evaluate()
  return this
end

.*(x::AffineExpr, y::Constant) = y .* x

function *(x::Constant, y::AffineExpr)
  # scalar multiplication
  if x.size == (1, 1) || y.size == (1, 1)
    return x .* y
  # matrix multiplication
  elseif x.size[2] == y.size[1]
    x_kron = Constant(kron(speye(y.size[2]), x.value))

    # Build the coefficient map for x * y
    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in y.vars_to_coeffs_map
      vars_to_coeffs_map[v] = x_kron * c
    end
    constant = x_kron * y.constant
    this = AffineExpr(:*, (x, y), vars_to_coeffs_map, constant, (x.size[1], y.size[2]))
    this.evaluate = ()->x.evaluate() * y.evaluate()
    return this
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

function *(x::AffineExpr, y::Constant)
  # scalar multiplication
  if y.size == (1, 1) || x.size == (1, 1)
    return y .* x
  # matrix multiplication
  elseif x.size[2] == y.size[1]
    y_kron = Constant(kron(y.value', speye(x.size[1])))
    vars_to_coeffs_map = Dict{UInt64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = y_kron * c
    end
    constant = y_kron * x.constant
    this = AffineExpr(:*, (x, y), vars_to_coeffs_map, constant, (x.size[1], y.size[2]))
    this.evaluate = ()->x.evaluate() * y.evaluate()
    return this
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

*(x::Numeric, y::AffineExpr) = *(convert(Constant, x), y)
*(x::AffineExpr, y::Numeric) = *(x, convert(Constant, y))
.*(x::Numeric, y::AffineExpr) = .*(convert(Constant, x), y)
.*(x::AffineExpr, y::Numeric) = .*(x, convert(Constant, y))

# Will also work for dot division if .* is fully implemented for dot multiplication
function ./(x::AffineExpr, y::Constant)
  if y.size != (1, 1) && x.size != (1, 1) && y.size != x.size
    error("Cannot dot divide two expressions of sizes $(x.size) and $(y.size)")
  end
  return Constant(1 ./ y.value) .* x
end

# Only support scalar division
function /(x::AffineExpr, y::Constant)
  if y.value == 0
    error("Cannot divide an affine expression by 0")
  else
    return x ./ y
  end
end

/(x::AffineExpr, y::Number) = /(x, convert(Constant, y))


## Sum of squares expressions

function *(x::Number, y::SumSquaresExpr)
  try
    x = convert(Float64, x)
  catch
    error("Sum Squares expressions can only be multiplied by real numbers")
  end
  if x < 0
    error("Sum Squares expressions can only be multiplied by nonegative scalars")
  end
  return SumSquaresExpr(:*, y.affines, x * y.multipliers, x * y.scalar)
end

*(x::SumSquaresExpr, y::Number) = *(y, x)

function /(x::SumSquaresExpr, y::Number)
  try
    y = convert(Float64, y)
  catch
    error("Sum Squares expressions can only be divided by real numbers")
  end
  if y <= 0
    error("Sum Squares expressions can only be divided by positive scalars")
  end
  return SumSquaresExpr(:/, x.affines, x.multipliers / y, x.scalar / y)
end
