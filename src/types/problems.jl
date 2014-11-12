export Problem

Float64OrNothing = Union(Float64, Nothing)
SumSquaresExprOrNothing = Union(SumSquaresExpr, Nothing)

type Problem
  head::Symbol
  objective::SumSquaresExpr
  constraints::Array{EqConstraint, 1}
  status::ASCIIString
  optval::Float64OrNothing

  function Problem(head::Symbol, objective::SumSquaresExprOrNothing, constraints::Array{EqConstraint, 1})
    this = new(head, objective, constraints, "not yet solved", nothing)
    return this
  end
end
