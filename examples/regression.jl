# Regression problem
# Originally written by Keegan Go for lsqpy
# Translated into LSQ.jl by Karanveer Mohan and David Zeng

"""
Fit a large polynomial to some given data
Play with regularization to understand
Question: Why does increasing regularization not help very much
near the end of the polynomial (farther from zero)?
"""

using LSQ
import PyPlot.plt

# Set the random seed to get consistent data
srand(1);

# Number of examples to use
n = 50

# Generate data
x_data = rand(n, 1) * 18;
y_data = sin(x_data * 2) + cos(x_data)- 4 * cos(x_data) / 4 + 3 * sin(x_data / 3) + 0.2 * rand(n, 1);

num_powers = 20;

t_vals = 0 : 0.1 : 18;
t = reshape(t_vals, length(t_vals), 1);
T = hcat([t .^ i for i in 1 : num_powers]...);

# We will regress using different powers of x
X = hcat([x_data .^ i for i in 1 : num_powers]...);

# Solve the problem
mu = 0;
a = Variable(num_powers);
optval = minimize!(sum_squares(X * a - y_data) + mu * sum_squares(a));

# Plot our regressed function
plt.plot(x_data, y_data, "bo");
plt.plot(t, T * a.value, "r");
plt.xlabel("x");
plt.ylabel("y");
plt.ylim([-5, 5]);
plt.show();
