import Base.vec, Base.repmat, Base.reshape
export vec, repmat, reshape

function vec(x::Number)
  return x
end

function repmat(x::Number, m::Int64, n::Int64)
  return repmat([x], m, n)
end

function reshape(x::Number, m::Int64, n::Int64)
  return x
end
