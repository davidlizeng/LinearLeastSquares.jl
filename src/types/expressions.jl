import Base.size, Base.endof, Base.ndims, Base.convert
export Constant, AffineExpr, AffineConstant, Variable, SumSquaresExpr
export Value, Numeric, AffineOrConstant
export evaluate
export convert
export sum_squares
export endof, size, ndims

Value = Union(Float64, SparseMatrixCSC{Float64, Int64})
Numeric = Union(Number, AbstractArray)

ValueOrNothing = Union(Value, Nothing)

abstract AbstractExpr

function evaluate(x::AbstractExpr)
  if x.size == (1, 1)
    return (x.evaluate())[1]
  else
    return full(x.evaluate())
  end
end

abstract AffineOrConstant <: AbstractExpr

type Constant <: AffineOrConstant
  head::Symbol
  value::ValueOrNothing
  size::(Int64, Int64)
  uid::Uint64
  evaluate::Function

  function Constant(value::Value)
    this = new(:constant, value, (size(value, 1), size(value, 2)))
    this.uid = object_id(this)
    this.evaluate = ()->this.value
    return this
  end
end

function convert(::Type{Constant}, value::Number)
  return Constant(convert(Float64, value))
end

function convert(::Type{Constant}, value::AbstractArray)
  return Constant(convert(SparseMatrixCSC{Float64, Int64}, sparse(value)))
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
  this.evaluate = ()->begin
    if this.value == nothing
      error("value of the variable is yet to be calculated")
    elseif this.size == (1, 1)
      return this.value[1]
    else
      return this.value
    end
  end
  return this
end

Variable(size...) = Variable(size)
Variable() = Variable((1, 1))
Variable(size::Integer) = Variable((size, 1))

type SumSquaresExpr <: AbstractExpr
  head::Symbol
  value::ValueOrNothing
  affines::Array{AffineExpr}
  uid::Uint64
  evaluate::Function

  function SumSquaresExpr(head::Symbol, affines::Array{AffineExpr})
    this = new(head, nothing, affines)
    this.uid = object_id(this)
    this.evaluate = ()->begin
      sum = 0
      for affine in affines
        sum += norm(vec(affine.evaluate()))^2
      end
      return sum
    end
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
