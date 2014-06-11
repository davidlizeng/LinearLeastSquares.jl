export backslash_solve!

function reset_value_and_add_vars!(x::AffineOrConstant, unique_vars_map::Dict{Uint64, AffineExpr})
  if x.head != :constant
    x.value = nothing
    if x.head == :variable
      unique_vars_map[object_id(x)] = x
    else
      for child in x.children
        reset_value_and_add_vars!(child, unique_vars_map)
      end
    end
  end
end

function reset_values_and_get_vars!(p::Problem)
  p.status = "not yet solved"
  p.optval = nothing
  unique_vars_map = Dict{Uint64, AffineExpr}()
  p.objective.value = nothing
  for affine in p.objective.affines
    reset_value_and_add_vars!(affine, unique_vars_map)
  end
  for constraint in p.constraints
    reset_value_and_add_vars!(constraint.canon_form, unique_vars_map)
  end
  return unique_vars_map
end

function get_var_ranges_and_num_vars(unique_vars_map::Dict{Uint64, AffineExpr})
  vars_to_ranges_map = Dict{Uint64, (Int64, Int64)}()
  num_vars = 0
  for (id, var) in unique_vars_map
    sz = var.size[1] * var.size[2]
    vars_to_ranges_map[id] = (num_vars + 1, num_vars + sz)
    num_vars += sz
  end
  return vars_to_ranges_map, num_vars
end

function get_num_rows(affines::Array{AffineExpr})
  num_rows = 0
  for affine in affines
    num_rows += affine.size[1] * affine.size[2]
  end
  return num_rows
end

function coalesce_affine_exprs(vars_to_ranges_map::Dict{Uint64, (Int64, Int64)}, num_vars::Int64, affines::Array{AffineExpr})
  num_rows = get_num_rows(affines)
  coefficient = zeros(num_rows, num_vars)
  constant = zeros(num_rows, 1)
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

# TODO: Julia 0.2 does not support A\b for sparse A,b
function build_kkt_system(A, b, C, d)
  sz = size(A, 2) + size(C, 1)
  coefficient = zeros(sz, sz)
  coefficient[1 : size(A, 2), 1 : size(A, 2)] = 2 * A' * A
  coefficient[size(A, 2) + 1 : end, 1 : size(C, 2)] = C
  coefficient[1 : size(C, 2), size(A, 2) + 1 : end] = C'
  constant = zeros(sz, 1)
  constant[1 : size(A, 2)] = -2 * A' * b
  constant[size(A, 2) + 1 : end] = -d
  return coefficient, constant
end

function populate_vars!(unique_vars_map::Dict{Uint64, AffineExpr}, vars_to_ranges_map::Dict{Uint64, (Int64, Int64)}, solution)
  for (id, var) in unique_vars_map
    var.value = zeros(var.size)
    var.value[:] = solution[vars_to_ranges_map[id][1] : vars_to_ranges_map[id][2]]
  end
end

function backslash_solve!(p::Problem)
  unique_vars_map = reset_values_and_get_vars!(p)
  vars_to_ranges_map, num_vars = get_var_ranges_and_num_vars(unique_vars_map)
  A, b = coalesce_affine_exprs(vars_to_ranges_map, num_vars, p.objective.affines)
  canon_forms = AffineExpr[]
  for constraint in p.constraints
    push!(canon_forms, constraint.canon_form)
  end
  C, d = coalesce_affine_exprs(vars_to_ranges_map, num_vars, canon_forms)
  coefficient, constant = build_kkt_system(A, b, C, d)
  solution = nothing
  try
    solution = coefficient\constant
  # TODO: Only catch specific error
  catch
    println("Could not solve KKT system")
  end
  if solution == nothing
    p.status = "infeasible"
  else
    p.status = "solved"
    p.optval = norm(A*solution[1:num_vars] + b)^2
    populate_vars!(unique_vars_map, vars_to_ranges_map, solution)
  end
  return p.optval
end
