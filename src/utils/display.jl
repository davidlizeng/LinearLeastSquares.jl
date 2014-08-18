import Base.show
export show

# A Constant is simply a wrapper around a native Julia constant
# Hence, we simply display its value
function show(io::IO, x::Constant)
  print(io, "Constant($(x.value))")
end

# A variable and affine expression will display its size
function show(io::IO, x::AffineExpr)
  if x.head == :variable
    print(io, "Variable($(x.size[1]), $(x.size[2]))")
  else
    print(io, "Affine Expression($(x.size[1]), $(x.size[2]))")
  end
end

# A sum of squares expression simply prints its name
function show(io::IO, x::SumSquaresExpr)
  print(io, "Sum of Squares Expression")
end

# A linear equality constraint will print
function show(io::IO, c::EqConstraint)
  print(io, "Equality Constraint: $(c.lhs) == $(c.rhs)")
end

