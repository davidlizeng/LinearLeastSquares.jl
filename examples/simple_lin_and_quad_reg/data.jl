# Set the random seed to get consistent data
import PyPlot.plt

srand(1)

# Number of examples to use
n = 100

# Specify the true value of the variable
true_coeffs = [2; -2; 0.5];

# Generate data
x_data = rand(n, 1) * 5;
x_data_expanded = hcat([x_data .^ i for i in 1 : 3]...);
y_data = x_data_expanded * true_coeffs + 0.5 * rand(n, 1);

plt.plot(x_data, y_data, "ro");
