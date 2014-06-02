export ==

function ==(lhs::Constant, rhs::Constant)
  error ("Equality constraints between two constants are not allowed")
end

==(lhs::AffineExpr, rhs::AffineExpr) = lhs - rhs
==(lhs::Constant, rhs::AffineExpr) = rhs - lhs
==(lhs::AffineExpr, rhs::Constant) = lhs - rhs
==(lhs::Value, rhs::AffineExpr) = ==(Constant(lhs), rhs)
==(lhs::AffineExpr, rhs::Value) = ==(lhs, Constant(rhs))