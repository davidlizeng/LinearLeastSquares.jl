export Problem

Float64OrVoid = Union{Float64, Void}
SumSquaresExprOrVoid = Union{SumSquaresExpr, Void}

type Problem
  head::Symbol
  objective::SumSquaresExpr
  constraints::Array{EqConstraint, 1}
  status::ASCIIString
  optval::Float64OrVoid

  function Problem(head::Symbol, objective::SumSquaresExprOrVoid, constraints::Array{EqConstraint, 1})
    this = new(head, objective, constraints, "not yet solved", nothing)
    return this
  end
end
