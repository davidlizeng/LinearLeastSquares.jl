using LSQ

TOLERANCE = 1e-4;

x = Variable(3);
y = sum_squares(x);
p = minimize(y);
solve!(p);
@assert abs(p.optval - 0) < TOLERANCE

x = Variable(3);
y = sum_squares(x);
p = minimize(y, x == 3);
solve!(p)
@assert abs(p.optval - 27) < TOLERANCE

x = Variable(2);
A = [1 0; 1 0];
y = sum_squares(x);
p = minimize(y, A * x == [1; 2]);
solve!(p);
@assert p.status == "infeasible";

A = randn(5, 5);
x_real = randn(5, 5);
x = Variable(5, 5);
y = A * x;
b = A * x_real;
p = minimize(sum_squares(x));
for i = 1:5
  p.constraints += y[:, i] == b[:, i];
end
solve!(p)

n = 200;
# Specify the true value of the variable
true_vect = [-1; 1];
# Create data and labels
X = randn(n, 2) * 2;
b = randn(n, 1);
y = sign(X * true_vect) + b;
a = Variable(2);
p = minimize(sum_squares(X * a - y));
solve!(p);

x = Variable(5, 5);
y = Variable(5, 6);
z = Variable(7, 5);

p = minimize(sum_squares([x y]) + sum_squares([x; z]),
  [x == 1, 2 * y == 2, ones(7, 5) .* z == 3]);
solve!(p);
@assert abs(p.optval - 395) < TOLERANCE

# x = Variable(5);
# p = minimize(sum_squares(sum(x)), x == 3);
# solve!(p);
# @assert abs(p.optval - 225) < TOLERANCE
