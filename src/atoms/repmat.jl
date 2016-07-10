import Base.repmat
export repmat


function repmat(x::Constant, m::Int64, n::Int64)
  return Constant(repmat(x.value, m, n))
end

function repmat(x::AffineExpr, m::Int64, n::Int64)
  vars_to_coeffs_map = Dict{UInt64, Constant}()
  index_start = 0
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = Constant(spzeros(m * x.size[1] * x.size[2], c.size[2]))
    for j = 1 : x.size[2]
      index_start = (j - 1) * x.size[1] * m
      for i = 1 : m
        index = index_start + (i - 1) * x.size[1]
        vars_to_coeffs_map[v].value[index + 1 : index + x.size[1], :] = c.value[(j - 1) * x.size[1] + 1 : j * x.size[1], :]
      end
    end
  end
  constant = Constant(spzeros(m * x.size[1] * x.size[2], 1))
  for j = 1 : x.size[2]
    index_start = (j - 1) * x.size[1] * m
    for i = 1 : m
      index = index_start + (i - 1) * x.size[1]
      constant.value[index + 1 : index + x.size[1]] = x.constant.value[(j - 1) * x.size[1] + 1 : j * x.size[1]]
    end
  end
  for (v, c) in vars_to_coeffs_map
    vars_to_coeffs_map[v] = repmat(c, n, 1)
  end
  constant = repmat(constant, n, 1)

  this = AffineExpr(:repmat, (x,), vars_to_coeffs_map, constant, (m * x.size[1], n * x.size[2]))
  this.evaluate = ()->repmat(x.evaluate(), m, n)
  return this
end
