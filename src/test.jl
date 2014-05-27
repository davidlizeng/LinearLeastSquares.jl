x = Variable(3)
y = SumSquares(x)
p = minimize(y)
solve!(p)

x = Variable(3)
y = SumSquares(x)
p = minimize(y, x == 3)
solve!(p)

x = Variable(2)
A = [1 0; 1 0]
y = SumSquares(x)
p = minimize(y, A*x == [1; 2])
solve!(p)

A = randn(5, 5)
x_real = randn(5, 5)
x = Variable(5, 5)
y = A*x
b = A*x_real
p = minimize(SumSquares(x), y == b)
solve!(p)


n = 200
# Specify the true value of the variable
true_vect = [-1; 1]
# Create data and labels
X = randn(n, 2) * 2
b = randn(n, 1)
y = sign(X * true_vect)+ b
a = Variable(2)
p = minimize(SumSquares(X * a - y))
solve!(p)
