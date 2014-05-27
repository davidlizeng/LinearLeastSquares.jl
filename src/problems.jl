export minimize, satisfy, solve!

Float64OrNothing = Union(Float64, Nothing)
SumSquaresExprOrNothing = Union(SumSquaresExpr, Nothing)

type Problem
  head::Symbol
  objective::SumSquaresExpr
  constraints::Array{AffineExpr}
  status::ASCIIString
  optval::Float64OrNothing

  function Problem(head::Symbol, objective::SumSquaresExprOrNothing, constraints::Array{AffineExpr})
    this = new(head, objective, constraints, "not yet solved", nothing)
    return this
  end
end

minimize(objective::SumSquaresExpr, constraints::Array{AffineExpr}) = Problem(:minimize, objective, constraints)
minimize(objective::SumSquaresExpr, constraint::AffineExpr) = minimize(objective, [constraint])
minimize(objective::SumSquaresExpr) = minimize(objective, AffineExpr[])

satisfy(constraints::Array{AffineExpr}) = Problem(:satisfy, SumSquaresExpr(:empty, AffineExpr[]), constraints)
satisfy(constraint::AffineExpr) = satisfy([constraint])

function get_vars_and_vec_sizes(p::Problem)
  vars_to_sizes_map = Dict{Uint64, Int64}()
  for affine in p.objective.affines
    for (var, coeff) in affine.vars_to_coeffs_map
      vars_to_sizes_map[var] = coeff.size[2]
    end
  end
  for affine in p.constraints
    for (var, coeff) in affine.vars_to_coeffs_map
      vars_to_sizes_map[var] = coeff.size[2]
    end
  end
  return vars_to_sizes_map
end

function get_var_ranges(vars_to_sizes_map::Dict{Uint64, Int64})
  vars_to_ranges_map = Dict{Uint64, (Int64, Int64)}()
  num = 0
  for (var, sz) in vars_to_sizes_map
    vars_to_ranges_map[var] = (num + 1, num + sz)
    num += sz
  end
  return vars_to_ranges_map
end

function get_num_matrix_rows(affines::Array{AffineExpr})
  matrix_rows = 0
  for affine in affines
    matrix_rows = matrix_rows + affine.size[1] * affine.size[2]
  end
  return matrix_rows
end

function get_num_matrix_cols(vars_to_sizes_map::Dict{Uint64, Int64})
  return sum(values(vars_to_sizes_map))
end

function coalesce_affine_exprs(vars_to_sizes_map::Dict{Uint64, Int64}, affines::Array{AffineExpr})
  num_cols = get_num_matrix_cols(vars_to_sizes_map)
  num_rows = get_num_matrix_rows(affines)
  coefficient = zeros(num_rows, num_cols)
  constant = zeros(num_rows, 1)
  vars_to_ranges_map = get_var_ranges(vars_to_sizes_map)
  row = 0
  for affine in affines
    row_sz = affine.size[1] * affine.size[2]
    for (var, coeff) in affine.vars_to_coeffs_map
      col_range = vars_to_ranges_map[var]
      coefficient[row + 1 : row + row_sz, col_range[1] : col_range[2]] = coeff.value
    end
    constant[row + 1 : row + row_sz] = affine.constant.value
    row += row_sz
  end
  return coefficient, constant
end

function build_kkt_system(A, b, C, d)
  sz = size(A, 2) + size(C, 1)
  coefficient = zeros(sz, sz)
  coefficient[1:size(A, 2), 1:size(A, 2)] = 2*A'*A
  coefficient[size(A, 2) + 1:, 1:size(C, 2)] = C
  coefficient[1:size(C, 2), size(A, 2) + 1:] = C'
  constant = zeros(sz, 1)
  constant[1:size(A, 2)] = -2*A'*b
  constant[size(A, 2) + 1:] = -d
  return coefficient, constant
end

function populate_vars(vars_to_sizes_map::Dict{Uint64, Int64}, p::Problem, s::Array{Number})

end

function solve!(p::Problem)
  vars_to_sizes_map = get_vars_and_vec_sizes(p)
  A, b = coalesce_affine_exprs(vars_to_sizes_map, p.objective.affines)
  C, d = coalesce_affine_exprs(vars_to_sizes_map, p.constraints)
  coefficient, constant = build_kkt_system(A, b, C, d)
  solution = nothing
  try
    solution = coefficient\constant
  catch
    println("Could not solve KKT system.")
  end
  if solution == nothing
    p.status = "infeasible"
  else
    p.status = "solved"
    num_vars = get_num_matrix_cols(vars_to_sizes_map)
    p.optval = norm(A*solution[1:num_vars] + b)^2
  end
  return p.optval
end
