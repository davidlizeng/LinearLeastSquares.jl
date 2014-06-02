export reverse_sign
export kron


function reverse_sign(x::AbstractExpr)
  if x.sign == :pos
    return :neg
  elseif x.sign == :neg
    return :pos
  else
    return :any
  end
end


# TODO: This is taken from the julia code, remove after updating to new version
function kron{Tv1,Ti1,Tv2,Ti2}(A::SparseMatrixCSC{Tv1,Ti1}, B::SparseMatrixCSC{Tv2,Ti2})
  Tv_res = promote_type(Tv1, Tv2)
  Ti_res = promote_type(Ti1, Ti2)
  A = convert(SparseMatrixCSC{Tv_res,Ti_res}, A)
  B = convert(SparseMatrixCSC{Tv_res,Ti_res}, B)
  return Base.kron(A,B)
end

kron(A::VecOrMat, B::VecOrMat) = kron(sparse(A), sparse(B))
kron(A::SparseMatrixCSC, B::VecOrMat) = kron(A, sparse(B))
kron(A::VecOrMat, B::SparseMatrixCSC) = kron(sparse(A), B)
kron(A::Number, B::Number) = kron([A], [B])
kron(A::SparseMatrixCSC, B::Number) = kron(A, [B])
kron(A::Number, B::SparseMatrixCSC) = kron([A], B)