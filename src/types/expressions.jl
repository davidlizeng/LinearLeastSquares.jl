import Base.size, Base.endof, Base.ndims
export Constant, AffineExpr, AffineConstant, Variable, SumSquaresExpr
export Value, AffineOrValue, AffineOrConstant
export sum_squares
export endof, size, ndims

Value = Union(Number, AbstractArray)
ValueOrNothing = Union(Value, Nothing)

abstract AffineOrConstant

type Constant <: AffineOrConstant
  head::Symbol
  value::ValueOrNothing
  size::(Int64, Int64)
  uid::Uint64
  evaluate::Function

  function Constant(value::Value)
    # Use full([value])'' to ensure everything has two dimensions and uses dense types
    this = new(:constant, full([value])'', (size(value, 1), size(value, 2)))
    this.uid = object_id(this)
    this.evaluate = ()->this.value
    return this
  end
end

type AffineExpr <: AffineOrConstant
  head::Symbol
  value::ValueOrNothing
  children::Tuple
  vars_to_coeffs_map::Dict{Uint64, Constant}
  constant::Constant
  size::(Int64, Int64)
  uid::Uint64
  evaluate::Function

  function AffineExpr(head::Symbol, children::Tuple, vars_to_coeffs_map::Dict{Uint64, Constant}, constant::Constant, size::(Int64, Int64))
    this = new(head, nothing, children, vars_to_coeffs_map, constant, size)
    this.uid = object_id(this)
    return this
  end
end

AffineOrValue = Union(AffineExpr, Value)

function AffineConstant(value::Value)
  constant = Constant(value)
  this = AffineExpr(:constant, (), Dict{Uint64, Constant}(), constant, constant.size)
  this.value = this.constant.value
  this.evaluate = ()->this.value
  return this
end

function Variable(size::(Int64, Int64))
  vec_sz = size[1]*size[2]
  this = AffineExpr(:variable, (), Dict{Uint64, Constant}(), Constant(spzeros(vec_sz, 1)), size)
  this.vars_to_coeffs_map[this.uid] = Constant(speye(vec_sz))
  this.evaluate = ()->this.value == nothing ? error("value of the variable is yet to be calculated") : this.value
  return this
end

Variable(size...) = Variable(size)
Variable() = Variable((1, 1))
Variable(size::Integer) = Variable((size, 1))

type SumSquaresExpr
  head::Symbol
  value::ValueOrNothing
  affines::Array{AffineExpr}
  uid::Uint64
  evaluate::Function

  function SumSquaresExpr(head::Symbol, affines::Array{AffineExpr})
    this = new(head, nothing, affines)
    this.uid = object_id(this)
    # TODO: eval
    return this
  end
end

function sum_squares(affine::AffineExpr)
  affines = AffineExpr[]
  push!(affines, affine)
  this = SumSquaresExpr(:sum_squares, affines)
end

endof(x::AffineOrConstant) = x.size[1]*x.size[2]
function size(x::AffineOrConstant, dim::Integer)
  if dim < 1
    error("dimension out of range")
  elseif dim > 2
    return 1
  else
    return x.size[dim]
  end
end
ndims(x::AffineOrConstant) = 2
