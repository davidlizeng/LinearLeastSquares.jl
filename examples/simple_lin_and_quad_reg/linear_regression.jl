# Simple Linear Regression
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
x_data = rand(n, 1) * 5;
x_data_expanded = hcat([x_data .^ i for i in 1 : 3]...);
y_data = x_data_expanded * true_coeffs + 0.5 * rand(n, 1);

slope = Variable();
offset = Variable();
optval = minimize!(sum_squares(offset .+ x_data * slope - y_data));
println("Slope = $(slope.value[1, 1]), offset = $(offset.value[1, 1])");

import PyPlot.plt
# Print results and plot
t = [0; 5; 0.1];
plt.plot(x_data, y_data, "ro");
plt.plot(t, slope.value[1, 1] * t .+ offset.value[1, 1]);
plt.xlabel("x");
plt.ylabel("y");
plt.show();
