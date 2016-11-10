TOLERANCE = 0.0001

x = Variable()
y = Variable()
solve!(x == 3)
@test evaluate(x) == 3
@test_throws ErrorException solve!(x + 3 * y == 2)

y = Variable(3, 1)
A = rand(3, 3)
solve!(x == 3, A*y == 4)
@test evaluate(x) == 3
@test all(abs.(A*evaluate(y) - 4) .<= TOLERANCE)

solve!([x == 5, y == 7])
@test evaluate(x) == 5
@test all(evaluate(y) .== 7)

x = Variable(3)
y = sum_squares(x)
optval = minimize!(y)
@test abs(optval - 0) < TOLERANCE
@test all(abs(evaluate(x)) .<= TOLERANCE)

x = Variable(3)
y = sum_squares(x)
optval = minimize!(y, x == 3)
@test abs(optval - 27) < TOLERANCE
@test all(abs.(evaluate(x) - 3) .<= TOLERANCE)

x = Variable(3)
optval = minimize!(sum_squares(3), x == 3)
@test abs(optval - 9) < TOLERANCE
@test all(abs.(evaluate(x) - 3) .<= TOLERANCE)

x = Variable(2)
A = [1 0; 1 0]
y = sum_squares(x)
@test_throws ErrorException optval = minimize!(y, A * x == [1; 2])

A = randn(5, 5)
x_real = randn(5, 5)
x = Variable(5, 5)
y = A * x
b = A * x_real
constraints = []
for i = 1:5
  constraints += y[:, i] == b[:, i]
end
optval = minimize!(sum_squares(x), constraints)
@test abs.(sum(x_real.^2) - optval) <= TOLERANCE
@test all(abs.(evaluate(x) .- x_real) .<= TOLERANCE)

info("All solve/minimize tests passed")
