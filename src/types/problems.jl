export minimize, satisfy

Float64OrNothing = Union(Float64, Nothing)
SumSquaresExprOrNothing = Union(SumSquaresExpr, Nothing)

type Problem
  head::Symbol
  objective::SumSquaresExpr
  constraints::Array{AffineExpr}
  status::ASCIIString
  optval::Float64OrNothing

  function Problem(head::Symbol, objective::SumSquaresExprOrNothing, constraints::Array{AffineExpr})
    this = new(head, objective, constraints, "not yet solved", nothing)
    return this
  end
end

minimize(objective::SumSquaresExpr, constraints::Array{AffineExpr}) = Problem(:minimize, objective, constraints)
minimize(objective::SumSquaresExpr, constraint::AffineExpr) = minimize(objective, [constraint])
minimize(objective::SumSquaresExpr) = minimize(objective, AffineExpr[])

satisfy(constraints::Array{AffineExpr}) = Problem(:satisfy, SumSquaresExpr(:empty, AffineExpr[]), constraints)
satisfy(constraint::AffineExpr) = satisfy([constraint])
