TOLERANCE = 0.0001

x = Variable()
solve!(x == 3)
@assert evaluate(x) == 3

y = Variable(3, 1)
A = rand(3, 3)
solve!(x == 3, A*y == 4)
@assert evaluate(x) == 3
@assert all(abs(A*evaluate(y) - 4) .<= TOLERANCE)

solve!([x == 5, y == 7])
@assert evaluate(x) == 5
@assert all(evaluate(y) .== 7)

x = Variable(3)
y = sum_squares(x)
optval = minimize!(y)
@assert abs(optval - 0) < TOLERANCE
@assert all(abs(evaluate(x)) .<= TOLERANCE)

x = Variable(3)
y = sum_squares(x)
optval = minimize!(y, x == 3)
@assert abs(optval - 27) < TOLERANCE
@assert all(abs(evaluate(x) .- 3) .<= TOLERANCE)

x = Variable(2)
A = [1 0; 1 0]
y = sum_squares(x)
@test_throws ErrorException optval = minimize!(y, A * x == [1; 2])

A = randn(5, 5)
x_real = randn(5, 5)
x = Variable(5, 5)
y = A * x
b = A * x_real
constraints = EqConstraint[]
for i = 1:5
  constraints += y[:, i] == b[:, i]
end
optval = minimize!(sum_squares(x), constraints)
@assert abs(sum(x_real.^2) - optval) <= TOLERANCE
@assert all(abs(evaluate(x) .- x_real) .<= TOLERANCE)

info("All solve/minimize tests passed")
