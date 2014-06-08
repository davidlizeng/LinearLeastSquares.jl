export ==, EqConstraint, +

AffineOrConst = Union(AffineExpr, Constant)

type EqConstraint
  head::Symbol
  lhs::AffineOrConst
  rhs::AffineOrConst
  canon_form::AffineExpr

  function EqConstraint(lhs::AffineOrConst, rhs::AffineOrConst)
    if lhs.head == :Constant && rhs.head == :Constant
      error ("Equality constraints between two constants are not allowed")
    end
    this = new(:(==), lhs, rhs, lhs .- rhs)
    return this
  end
end

==(lhs::AffineOrConst, rhs::AffineOrConst) = EqConstraint(lhs, rhs)
==(lhs::Value, rhs::AffineExpr) = ==(Constant(lhs), rhs)
==(lhs::AffineExpr, rhs::Value) = ==(lhs, Constant(rhs))

+(constraints::Array{EqConstraint}, new_constraints::Array{EqConstraint}) = append!(constraints, new_constraints)
+(constraints::Array{EqConstraint}, new_constraint::EqConstraint) = push!(constraints, new_constraint)
