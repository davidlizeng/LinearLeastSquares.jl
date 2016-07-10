import Base.diag, Base.diagm
export diag, diagm

function diag(x::AffineExpr, num::Int64)
  if num <= -x.size[1] || num >= x.size[2]
    error("Out of bounds diagonal number for diag")
  end
  if num < 0
    start_row = -num + 1
    start_col = 1
  else
    start_row = 1
    start_col = num + 1
  end
  len = min(x.size[1] - start_row + 1, x.size[2] - start_col + 1)
  start_ind = (start_col - 1) * x.size[1] + start_row

  indexer = Constant(
    sparse(
      1 : len,
      start_ind : x.size[1] + 1 : start_ind + (len - 1) * (x.size[1] + 1),
      1.0,
      len,
      x.size[1] * x.size[2]
    )
  )

  vars_to_coeffs_map = Dict{UInt64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  this = AffineExpr(:diag, (x,), vars_to_coeffs_map, constant, (len, 1))
  this.evaluate = ()->diag(full(x.evaluate()), num)
  return this
end

diag(x::AffineExpr) = diag(x, 0)

function diagm(x::AffineExpr)
  if x.size[2] != 1
    error("Can only call diagm on column vectors")
  end

  indexer = Constant(
    sparse(
      1 : x.size[1] + 1 : 1 + (x.size[1] - 1) * (x.size[1] + 1),
      1 : x.size[1],
      1.0,
      x.size[1] * x.size[1],
      x.size[1]
    )
  )

  vars_to_coeffs_map = Dict{UInt64, Constant}()
  for (v, c) in x.vars_to_coeffs_map
    vars_to_coeffs_map[v] = indexer * c
  end
  constant = indexer * x.constant
  this = AffineExpr(:diagm, (x,), vars_to_coeffs_map, constant, (x.size[1], x.size[1]))
  this.evaluate = ()->diagm(vec(x.evaluate()))
  return this
end
