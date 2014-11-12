export minimize!, solve!

# Eventually, this can take in arguments to specify solving method.
# For now, backslash is the only supported method.
function solve!(problem_type::Symbol, objective::SumSquaresExpr, constraints::Array{EqConstraint, 1})
  p = Problem(problem_type, objective, constraints)
  # return backslash_solve!(p)
  backslash_solve!(p)
  if p.status == "KKT singular"
    error("KKT system is singular. No unique solution")
  elseif p.status == "solved"
    return p.optval
  else
    error("Unrecognized problem status")
  end
end


minimize!(objective::SumSquaresExpr, constraints::Array{EqConstraint, 1}) = solve!(:minimize, objective, constraints)
minimize!(objective::SumSquaresExpr, constraint::EqConstraint) = minimize!(objective, [constraint])
minimize!(objective::SumSquaresExpr, constraints::EqConstraint...) = minimize!(objective, [constraints...])
minimize!(objective::SumSquaresExpr) = minimize!(objective, EqConstraint[])

solve!(constraints::Array{EqConstraint, 1}) = solve!(:solve, sum_squares(), constraints)
solve!(constraint::EqConstraint) = solve!([constraint])
solve!(constraints::EqConstraint...) = solve!([constraints...])
