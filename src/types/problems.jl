export Problem

Float64OrNothing = Union(Float64, Nothing)
SumSquaresExprOrNothing = Union(SumSquaresExpr, Nothing)

type Problem
  head::Symbol
  objective::SumSquaresExpr
  constraints::Array{EqConstraint}
  status::ASCIIString
  optval::Float64OrNothing

  function Problem(head::Symbol, objective::SumSquaresExprOrNothing, constraints::Array{EqConstraint})
    this = new(head, objective, constraints, "not yet solved", nothing)
    return this
  end
end
