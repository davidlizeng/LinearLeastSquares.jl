# Runs all unit tests
using LinearLeastSquares
using Base.Test

info("JULIA VERSION: $(VERSION)") # important as Julia versions are volatile
include("helpers.jl")
include("add_subtract.jl")
include("multiply_divide.jl")
include("stack.jl")
include("diag.jl")
include("repmat.jl")
include("index.jl")
include("reshape.jl")
include("transpose.jl")
include("sum_squares.jl")
include("compound.jl")
include("constraints.jl")
include("problems.jl")
