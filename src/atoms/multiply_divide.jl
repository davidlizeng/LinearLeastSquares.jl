export *, .*

*(x::Constant, y::Constant) = Constant(x.value * y.value)
.*(x::Constant, y::Constant) = Constant(x.value .* y.value)


function .*(x::Constant, y::AffineExpr)
  if x.size == (1, 1)
    x = repmat(x, y.size[1], y.size[2])
  elseif y.size == (1, 1)
    y = repmat(y, x.size[1], x.size[2])
  end

  if x.size == y.size
    # TODO: Implement vec
    vec_x = Constant(vec(x.value))

    vars_to_coeffs_map = Dict{Uint64, Constant}()
    for (v, c) in y.vars_to_coeffs_map
      vars_to_coeffs_map[v] = vec_x .* c
    end
    constant = vec_x .* y.constant

    this = AffineExpr(:*, (x, y), vars_to_coeffs_map, constant, x.size)
    # TODO: eval
    return this
  else
    error("Cannot dot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

.*(x::AffineExpr, y::Constant) = y .* x

function *(x::Constant, y::AffineExpr)
  # y could be a matrix variable and needs to be vectorized, hence we use kron
  if x.size[2] == y.size[1]
    x_kron = Constant(kron(eye(y.size[2]), x.value))

    # Build the coefficient map for x * y
    vars_to_coeffs_map = Dict{Uint64, Constant}()
    for (v, c) in y.vars_to_coeffs_map
      vars_to_coeffs_map[v] = x_kron * c
    end
    constant = x_kron * y.constant
    this = AffineExpr(:*, (x, y), vars_to_coeffs_map, constant, (x.size[1], y.size[2]))
  elseif x.size == (1, 1) || y.size == (1, 1)
    return x .* y
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
  # TODO: eval
  return this
end

function *(x::AffineExpr, y::Constant)
  if x.size[2] == y.size[1]
    y_kron = Constant(kron(y.value', eye(x.size[1])))
    vars_to_coeffs_map = Dict{Uint64, Constant}()
    for (v, c) in x.vars_to_coeffs_map
      vars_to_coeffs_map[v] = y_kron * c
    end
    constant = y_kron * x.constant
    this = AffineExpr(:*, (x, y), vars_to_coeffs_map, constant, (x.size[1], y.size[2]))
    # TODO: eval
    return this
  elseif y.size == (1, 1) || x.size == (1, 1)
    return y * x
  else
    error("Cannot multiply two expressions of sizes $(x.size) and $(y.size)")
  end
end

*(x::Value, y::AffineExpr) = *(Constant(x), y)
*(x::AffineExpr, y::Value) = *(x, Constant(y))
.*(x::Value, y::AffineExpr) = .*(Constant(x), y)
.*(x::AffineExpr, y::Value) = .*(x, Constant(y))


function *(x::Constant, y::SumSquaresExpr)
  if x.size != (1, 1) || x.value[1] < 0
    error("Sum Squares expressions can only be multiplied by nonegative scalars")
  end
  affines = [x * affine for affine in y.affines]
  this = SumSquaresExpr(:*, affines)
  return this
end

*(x::SumSquaresExpr, y::Constant) = *(y, x)
*(x::SumSquaresExpr, y::Value) = *(x, Constant(y))
*(x::Value, y::SumSquaresExpr) = *(Constant(x), y)
