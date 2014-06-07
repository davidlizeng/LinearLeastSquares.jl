import Base.vcat, Base.hcat, Base.hvcat
export vcat, hcat, hvcat

# TODO: don't allow all constants

function vcat_impl(args::Array{AffineOrConstant})
  num_cols = args[1].size[2]
  num_rows = 0
  for arg in args
    if arg.size[2] != num_cols
      error("All arguments must have same number of columns")
    end
    num_rows += arg.size[1]
  end
  vars_to_coeffs_map = Dict{Uint64, Constant}()
  vec_sz = num_rows * num_cols
  constant = Constant(spzeros(vec_sz, 1))
  index_start = 0
  for i = 1:length(args)
    if args[i].head == :constant
      for j = 1 : num_cols
        index = index_start + (j - 1) * num_rows
        # TODO: Julia 0.2 bug, sparse matrix of floats cannot be set to equal ints
        # TODO: Julia has so many sparse matrix bugs
        constant.value[index + 1 : index + args[1].size[1], :] = args[i].value[:, j]
      end
    else
      for (v, c) in args[i].vars_to_coeffs_map
        if !haskey(vars_to_coeffs_map, v)
          vars_to_coeffs_map[v] = Constant(spzeros(vec_sz, c.size[2]))
        end
        for j in 1 : num_cols
          index = index_start + (j - 1) * num_rows
          vars_to_coeffs_map[v].value[index + 1 : index + args[i].size[1], :] = c.value[(j - 1) * args[i].size[1] + 1 : j * args[i].size[1], :]
        end
      end
      for j in 1 : num_cols
        index = index_start + (j - 1) * num_rows
        constant.value[index + 1 : index + args[i].size[1], :] = args[i].constant.value[(j - 1) * args[i].size[1] + 1 : j * args[i].size[1], :]
      end
    end
    index_start += args[i].size[1]
  end

  this = AffineExpr(:vcat, args, vars_to_coeffs_map, constant, (num_rows, num_cols))
  # TODO: eval
  return this
end

function vcat(args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  return vcat_impl(args_converted)
end


function hcat_impl(args::Array{AffineOrConstant})
  num_rows = args[1].size[1]
  num_cols = 0
  for arg in args
    if arg.size[1] != num_rows
      error("All arguments must have same number of rows")
    end
    num_cols += arg.size[2]
  end
  vars_to_coeffs_map = Dict{Uint64, Constant}()
  vec_sz = num_rows * num_cols
  constant = Constant(spzeros(vec_sz, 1))
  index = 0
  for i = 1:length(args)
    arg_vec_sz = args[i].size[1] * args[i].size[2]
    if args[i].head == :constant
      # TODO: Julia 0.2 bug, sparse matrix of floats cannot be set to equal ints
      # TODO: Julia has so many sparse matrix bugs
      constant.value[index + 1 : index + arg_vec_sz, :] = sparse(vec(args[i].value)*1.0)
    else
      for (v, c) in args[i].vars_to_coeffs_map
        if !haskey(vars_to_coeffs_map, v)
          vars_to_coeffs_map[v] = Constant(spzeros(vec_sz, c.size[2]))
        end
        vars_to_coeffs_map[v].value[index + 1 : index + arg_vec_sz, :] = c.value
      end
      constant.value[index + 1 : index + arg_vec_sz, :] = args[i].constant.value
    end
    index += arg_vec_sz
  end

  this = AffineExpr(:hcat, args, vars_to_coeffs_map, constant, (num_rows, num_cols))
  # TODO: eval
  return this
end

function hcat(args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  return hcat_impl(args_converted)
end

function hvcat_impl(rows::(Int64...), args::Array{AffineOrConstant})
  error("hvcat not yet implemented")
end

function hvcat(rows::(Int64...), args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  return hvcat_impl(rows, args_converted)
end


