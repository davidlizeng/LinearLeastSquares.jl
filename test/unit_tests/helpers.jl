export eval_internals, set_value!, test_expr, create_var

function eval_internals(x::AffineExpr, vars::Tuple)
  (rows, cols) = x.size
  value = zeros(rows, cols)
  for var in vars
    coeff = x.vars_to_coeffs_map[object_id(var)]
    value += reshape(coeff.value * vec(var.value), rows, cols)
  end
  value += reshape(x.constant.value, rows, cols)
  return value
end

function eval_internals(x::SumSquaresExpr)
  value = 0
  for i in 1:length(x.affines)
    value += x.multipliers[i]*vecnorm(evaluate(x.affines[i]))^2
  end
  value += x.scalar
  return value
end

function set_value!(x::AffineExpr, value::Number)
  x.value = convert(Float64, value)
end

function set_value!(x::AffineExpr, value::AbstractArray)
  x.value = convert(SparseMatrixCSC{Float64, Int64}, sparse(value))
end

function test_expr(x::SumSquaresExpr)
  val1 = evaluate(x)
  val2 = eval_internals(x)
  @assert abs.(val1 .- val2) <= 0.0001
end

function test_expr(x::AffineExpr, vars::Tuple)
  val1 = eval_internals(x, vars)
  val2 = evaluate(x)
  @assert all(abs.(val1 .- val2) .<= 0.0001)
end

function create_var(m::Int64, n::Int64)
  x = Variable(m, n)
  set_value!(x, rand(m, n))
  return x
end
