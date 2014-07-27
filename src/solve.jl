export minimize!, satisfy!

# Eventually, this can take in arguments to specify solving method.
# For now, backslash is the only supported method.
function solve!(problem_type::Symbol, objective::SumSquaresExpr, constraints::Array{EqConstraint})
  p = Problem(problem_type, objective, constraints)
  backslash_solve!(p)
  if p.status == "infeasible"
    println("Problem was infeasible")
    return nothing
  elseif p.status == "solved"
    return p.optval
  else
    error("Unrecognized problem status")
  end
end


minimize!(objective::SumSquaresExpr, constraints::Array{EqConstraint}) = solve!(:minimize, objective, constraints)
minimize!(objective::SumSquaresExpr, constraint::EqConstraint) = minimize!(objective, [constraint])
minimize!(objective::SumSquaresExpr) = minimize!(objective, EqConstraint[])

solve!(constraints::Array{EqConstraint}) = solve!(:satisfy, SumSquaresExpr(:empty, AffineExpr[]), constraints)
solve!(constraint::EqConstraint) = satisfy!([constraint])
solve!(constraints::EqConstraint...) = satisfy!([constraints...])
