module LinearLeastSquares

using Compat
import Compat.String

include("types/expressions.jl")
include("types/constraints.jl")
include("types/problems.jl")

include("utils/utilities.jl")
include("utils/display.jl")

include("atoms/repmat.jl")
include("atoms/reshape.jl")
include("atoms/add_subtract.jl")
include("atoms/multiply_divide.jl")
include("atoms/transpose.jl")
include("atoms/index.jl")
include("atoms/stack.jl")
include("atoms/diag.jl")
include("atoms/sum.jl")
include("atoms/mean.jl")
include("atoms/variance.jl")

include("solvers/backslash_solver.jl")

include("solve.jl")
end # module
