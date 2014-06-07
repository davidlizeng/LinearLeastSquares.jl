x = Variable(3)
y = sum_squares(x)
p = minimize(y)
solve!(p)

x = Variable(3)
y = sum_squares(x)
p = minimize(y, x == 3)
solve!(p)

x = Variable(2)
A = [1 0; 1 0]
y = sum_squares(x)
p = minimize(y, A*x == [1; 2])
solve!(p)

A = randn(5, 5)
x_real = randn(5, 5)
x = Variable(5, 5)
y = A*x
b = A*x_real
p = minimize(sum_squares(x))
for i = 1:5
  p.constraints += y[:,i] == b[:,i]
end
solve!(p)



n = 200
# Specify the true value of the variable
true_vect = [-1; 1]
# Create data and labels
X = randn(n, 2) * 2
b = randn(n, 1)
y = sign(X * true_vect)+ b
a = Variable(2)
p = minimize(sum_squares(X * a - y))
solve!(p)
