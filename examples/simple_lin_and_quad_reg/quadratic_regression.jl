# Simple Quadratic Regression
# Originally written by Keegan Go for lsqpy
# Translated into LSQ.jl by Karanveer Mohan and David Zeng

using LSQ
# Set the random seed to get consistent data
srand(1)

# Number of examples to use
n = 100

# Specify the true value of the variable
true_coeffs = [2; -2; 0.5];

# Generate data
x_data = rand(n, 1) * 5
x_data_expanded = hcat([x_data .^ i for i in 1 : 3]...)
y_data = x_data_expanded * true_coeffs + 0.5 * rand(n, 1)

quadratic = Variable();
slope = Variable();
offset = Variable();

# We copy x_data but square the entries
x_squared = x_data .^ 2;

# Solve the problem
p = minimize(sum_squares(offset + x_data * slope + x_squared * quadratic - y_data));
solve!(p);

# Create some evenly spaced points for plotting, again replicate powers
t = reshape([0 : 0.1 : 5], length([0 : 0.1 : 5]), 1);
t_squared = t .^ 2;

# Plot our regressed function
plt.plot(x_data, y_data, "ro")
plt.plot(t, slope.value[1, 1] * t + offset.value[1, 1] + t_squared * quadratic.value[1, 1], "b")
plt.xlabel("x")
plt.ylabel("y")
plt.show()
