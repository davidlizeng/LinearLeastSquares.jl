import Base.vcat, Base.hcat, Base.hvcat, Base.start
export vcat, hcat, hvcat

function vcat(args::AffineExpr...)
  num_cols = args[1].size[2]
  num_rows = 0
  # Calculate numbers of rows after vertical concatenation
  for arg in args
    if arg.size[2] != num_cols
      error("All arguments must have same number of columns")
    end
    num_rows += arg.size[1]
  end

  vars_to_coeffs_map = Dict{UInt64, Constant}()
  vec_sz = num_rows * num_cols
  constant = Constant(spzeros(vec_sz, 1))
  index_start = 0

  for i = 1:length(args)
    for (v, c) in args[i].vars_to_coeffs_map
      if !haskey(vars_to_coeffs_map, v)
        vars_to_coeffs_map[v] = Constant(spzeros(vec_sz, c.size[2]))
      end
      for j in 1 : num_cols
        index = index_start + (j - 1) * num_rows
        vars_to_coeffs_map[v].value[index + 1 : index + args[i].size[1], :] =
            c.value[(j - 1) * args[i].size[1] + 1 : j * args[i].size[1], :]
      end
    end

    for j in 1 : num_cols
      index = index_start + (j - 1) * num_rows
      constant.value[index + 1 : index + args[i].size[1]] =
          args[i].constant.value[(j - 1) * args[i].size[1] + 1 : j * args[i].size[1]]
    end

    index_start += args[i].size[1]
  end

  this = AffineExpr(:vcat, tuple(args...), vars_to_coeffs_map, constant, (num_rows, num_cols))
  this.evaluate = ()->Base.vcat([arg.evaluate() for arg in args]...)
  return this
end

function hcat(args::AffineExpr...)
  num_rows = args[1].size[1]
  num_cols = 0

  for arg in args
    if arg.size[1] != num_rows
      error("All arguments must have same number of rows")
    end
    num_cols += arg.size[2]
  end

  vars_to_coeffs_map = Dict{UInt64, Constant}()
  vec_sz = num_rows * num_cols
  constant = Constant(spzeros(vec_sz, 1))
  index = 0

  for i = 1:length(args)
    arg_vec_sz = args[i].size[1] * args[i].size[2]

    for (v, c) in args[i].vars_to_coeffs_map
      if !haskey(vars_to_coeffs_map, v)
        vars_to_coeffs_map[v] = Constant(spzeros(vec_sz, c.size[2]))
      end
      vars_to_coeffs_map[v].value[index + 1 : index + arg_vec_sz, :] = c.value
    end
    constant.value[index + 1 : index + arg_vec_sz] = args[i].constant.value

    index += arg_vec_sz
  end

  this = AffineExpr(:hcat, tuple(args...), vars_to_coeffs_map, constant, (num_rows, num_cols))
  this.evaluate = ()->Base.hcat([arg.evaluate() for arg in args]...)
  return this
end

function hvcat(rows::Tuple{Vararg{Int64}}, args::AffineExpr...)
  row_exprs = AffineExpr[]
  index = 0
  for row_size in rows
    push!(row_exprs, hcat(args[index + 1 : index + row_size]...))
    index += row_size
  end
  return vcat(row_exprs...)
end
