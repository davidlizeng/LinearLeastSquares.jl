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