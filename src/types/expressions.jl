import Base.size, Base.endof, Base.ndims, Base.convert
export Constant, AffineExpr, AffineConstant, Variable, SumSquaresExpr
export Value, Numeric, AffineOrConstant
export evaluate
export convert
export sum_squares
export endof, size, ndims

Value = Union{Float64, SparseMatrixCSC{Float64, Int64}}
Numeric = Union{Number, AbstractArray}

ValueOrVoid = Union{Value, Void}

abstract AbstractExpr
abstract AffineOrConstant <: AbstractExpr

function evaluate(x::AbstractExpr)
  if x.size == (1, 1)
    return (x.evaluate())[1]
  elseif x.size[2] == 1
    return vec(full(x.evaluate()))
  else
    return full(x.evaluate())
  end
end

type Constant <: AffineOrConstant
  head::Symbol
  value::ValueOrVoid
  size::Tuple{Int64, Int64}
  uid::UInt64
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
  sparse_value = sparse(value)
  if size(sparse_value) == (1, 1)
    return Constant(convert(Float64, value[1]))
  end
  return Constant(convert(SparseMatrixCSC{Float64, Int64}, sparse(value)))
end

Constant(value) = convert(Constant, value)

type AffineExpr <: AffineOrConstant
  head::Symbol
  value::ValueOrVoid
  children::Tuple
  vars_to_coeffs_map::Dict{UInt64, Constant}
  constant::Constant
  size::Tuple{Int64, Int64}
  uid::UInt64
  evaluate::Function

  function AffineExpr(head::Symbol, children::Tuple, vars_to_coeffs_map::Dict{UInt64, Constant}, constant::Constant, size::Tuple{Int64, Int64})
    this = new(head, nothing, children, vars_to_coeffs_map, constant, size)
    this.uid = object_id(this)
    return this
  end
end

function AffineConstant(value::Value)
  constant = Constant(value)
  this = AffineExpr(:constant, (), Dict{UInt64, Constant}(), constant, constant.size)
  this.value = this.constant.value
  this.evaluate = ()->this.value
  return this
end

function Variable(size::Tuple{Int64, Int64})
  if (size[1] < 1 || size[2] < 1)
    error("invalid variable size")
  end
  vec_sz = size[1]*size[2]
  this = AffineExpr(:variable, (), Dict{UInt64, Constant}(), Constant(spzeros(vec_sz, 1)), size)
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
  value::ValueOrVoid
  affines::Array{AffineExpr}
  multipliers::Array{Float64}
  scalar::Float64
  uid::UInt64
  evaluate::Function

  function SumSquaresExpr(head::Symbol, affines::Array{AffineExpr}, multipliers::Array{Float64}, scalar::Float64)
    this = new(head, nothing, affines, multipliers, scalar)
    this.uid = object_id(this)
    this.evaluate = ()->begin
      value = 0
      for i in 1:length(this.affines)
        value += multipliers[i] * sum((this.affines[i].evaluate()).^2)
      end
      return value + this.scalar
    end
    return this
  end
end

function sum_squares()
  this = SumSquaresExpr(:sum_squares, AffineExpr[], Float64[], 0.0)
end

function sum_squares(num::Number)
  try
    num = convert(Float64, num)
  catch
    error("Sum Squares expressions can only be constructed from real numbers")
  end
  if num < 0
    error("Sum Squares expressions can only be constructed from nonnegative scalars")
  end
  this = SumSquaresExpr(:sum_squares, AffineExpr[], Float64[], num^2)
end

function sum_squares(affine::AffineExpr)
  affines = AffineExpr[]
  push!(affines, affine)
  this = SumSquaresExpr(:sum_squares, affines, ones(length(affines)), 0.0)
end

function evaluate(x::SumSquaresExpr)
  return (x.evaluate())[1]
end

endof(x::AffineOrConstant) = x.size[1] * x.size[2]
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
