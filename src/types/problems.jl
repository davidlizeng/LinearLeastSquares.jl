export minimize, satisfy

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

minimize(objective::SumSquaresExpr, constraints::Array{EqConstraint}) = Problem(:minimize, objective, constraints)
minimize(objective::SumSquaresExpr, constraint::EqConstraint) = minimize(objective, [constraint])
minimize(objective::SumSquaresExpr) = minimize(objective, EqConstraint[])

satisfy(constraints::Array{EqConstraint}) = Problem(:satisfy, SumSquaresExpr(:empty, AffineExpr[]), constraints)
satisfy(constraint::EqConstraint) = satisfy([constraint])
