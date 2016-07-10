import Base.==, Base.+

export ==, EqConstraint, +

AffineOrConst = Union{AffineExpr, Constant}

type EqConstraint
  head::Symbol
  lhs::AffineOrConst
  rhs::AffineOrConst
  canon_form::AffineExpr

  function EqConstraint(lhs::AffineOrConst, rhs::AffineOrConst)
    if lhs.head == :Constant && rhs.head == :Constant
      error("Equality constraints between two constants are not allowed")
    end
    if lhs.size != rhs.size && lhs.size != (1, 1) && rhs.size != (1, 1)
      error("LHS and RHS of constraints muust have the same size, or one needs to be scalar")
    end
    this = new(:(==), lhs, rhs, lhs - rhs)
    return this
  end
end

==(lhs::AffineOrConst, rhs::AffineOrConst) = EqConstraint(lhs, rhs)
==(lhs::Numeric, rhs::AffineExpr) = ==(convert(Constant, lhs), rhs)
==(lhs::AffineExpr, rhs::Numeric) = ==(lhs, convert(Constant, rhs))

+(constraints::Array{EqConstraint, 1}, new_constraints::Array{EqConstraint, 1}) = append!(constraints, new_constraints)
+(constraints::Array{EqConstraint, 1}, new_constraint::EqConstraint) = push!(constraints, new_constraint)
+(constraints::Array{Any, 1}, new_constraints::Array{EqConstraint, 1}) =
  if length(constraints) == 0
    new_constraints
  else
    error("Cannot append equality constraint to arbitrary array.")
  end
+(constraints::Array{Any, 1}, new_constraint::EqConstraint) =
  if length(constraints) == 0
    [new_constraint]
  else
    error("Cannot append equality constraint to arbitrary array.")
  end