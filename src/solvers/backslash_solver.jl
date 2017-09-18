export backslash_solve!, build_kkt_system

function reset_value_and_add_vars!(x::AffineOrConstant, unique_vars_map::Dict{UInt64, AffineExpr})
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
  unique_vars_map = Dict{UInt64, AffineExpr}()
  p.objective.value = nothing
  for affine in p.objective.affines
    reset_value_and_add_vars!(affine, unique_vars_map)
  end
  for constraint in p.constraints
    reset_value_and_add_vars!(constraint.canon_form, unique_vars_map)
  end
  return unique_vars_map
end

function get_var_ranges_and_num_vars(unique_vars_map::Dict{UInt64, AffineExpr})
  vars_to_ranges_map = Dict{UInt64, Tuple{Int64, Int64}}()
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

function coalesce_affine_exprs(vars_to_ranges_map::Dict{UInt64, Tuple{Int64, Int64}}, num_vars::Int64, affines::Array{AffineExpr})
  num_rows = get_num_rows(affines)
  coefficient = spzeros(num_rows, num_vars)
  constant = spzeros(num_rows, 1)
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
  if size(A, 1) == 0
    num_rows = size(C, 1)
    num_cols = size(C, 2)
  else
    num_rows = num_cols = size(A, 2) + size(C, 1)
  end

  coefficient = spzeros(num_rows, num_cols)
  constant = spzeros(num_rows, 1)

  if size(A, 1) != 0
    coefficient[1 : size(A, 2), 1 : size(A, 2)] = 2 * A' * A
    constant[1 : size(A, 2)] = -2 * A' * b
    if size(C, 1) != 0
      coefficient[1 : size(C, 2), size(A, 2) + 1 : end] = C'
      coefficient[size(A, 2) + 1 : end, 1 : size(C, 2)] = C
      constant[size(A, 2) + 1 : end] = -d
    end
  elseif size(C, 1) != 0
    coefficient[:, 1 : size(C, 2)] = C
    constant = -d
  else
    error("KKT system should not be empty")
  end

  return coefficient, constant
end

function populate_vars!(unique_vars_map::Dict{UInt64, AffineExpr}, vars_to_ranges_map::Dict{UInt64, Tuple{Int64, Int64}}, solution)
  for (id, var) in unique_vars_map
    var.value = spzeros(var.size...)
    var.value[:] = solution[vars_to_ranges_map[id][1] : vars_to_ranges_map[id][2]]
  end
end

function backslash_solve!(p::Problem)
  unique_vars_map = reset_values_and_get_vars!(p)
  vars_to_ranges_map, num_vars = get_var_ranges_and_num_vars(unique_vars_map)
  num_objectives = length(p.objective.affines)
  scaled_obj_affines = Array{AffineExpr}(num_objectives)
  for i in 1:num_objectives
    scaled_obj_affines[i] = sqrt(p.objective.multipliers[i]) * p.objective.affines[i]
  end
  A, b = coalesce_affine_exprs(vars_to_ranges_map, num_vars, scaled_obj_affines)
  canon_forms = AffineExpr[]
  for constraint in p.constraints
    push!(canon_forms, constraint.canon_form)
  end
  C, d = coalesce_affine_exprs(vars_to_ranges_map, num_vars, canon_forms)
  if size(A, 1) == 0
    if size(C, 1) < size(C, 2)
      error("Underdetermined system of equations.")
    elseif size(C, 2) < size(C, 1)
      error("Overdetermined system of equaitons.")
    end
  end
  solution = nothing
  # return A, b, C, d
  if size(A, 1) > 0 || size(C, 1) > 0
    coefficient, constant = build_kkt_system(A, b, C, d)
    # Julia 0.4 sparse backslash uses Cholesky decomposition
    # and requires coefficient to be positive definite
    if !isposdef(coefficient)
      coefficient = full(coefficient)
    end
    try
      solution = coefficient\full(constant)
    end
  end
  if solution == nothing
    p.status = "KKT singular"
  else
    p.status = "solved"
    p.optval = p.objective.scalar
    if size(A, 1) > 0
      p.optval += sum((A*solution[1:num_vars] + b).^2)
    end
    populate_vars!(unique_vars_map, vars_to_ranges_map, solution)
  end
  return p.optval
end
