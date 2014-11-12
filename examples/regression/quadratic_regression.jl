# Simple Quadratic Regression
# Originally written by Keegan Go for lsqpy
# Translated into LinearLeastSquares.jl by Karanveer Mohan and David Zeng

using LinearLeastSquares
using Gadfly
# Set the random seed to get consistent data
srand(1)

# Number of examples to use
n = 100

# Specify the true value of the variable
true_coeffs = [2; -2; 0.5]

# Generate data
x_data = rand(n, 1) * 5
x_data_expanded = hcat([x_data .^ i for i in 1 : 3]...)
y_data = x_data_expanded * true_coeffs + 0.5 * rand(n, 1)

quadratic_coeff = Variable()
slope = Variable()
offset = Variable()
quadratic = offset + x_data * slope + quadratic_coeff * x_data .^ 2
residuals = quadratic - y_data
fit_error = sum_squares(residuals)
optval = minimize!(fit_error)

# Create some evenly spaced points for plotting, again replicate powers
t = reshape([0 : 0.1 : 5], length([0 : 0.1 : 5]), 1)
t_squared = t .^ 2

# Plot our regressed function
p = plot(
  layer(x=x_data, y=y_data, Geom.point),
  layer(x=t, y=evaluate(offset) + t * evaluate(slope) + t_squared * evaluate(quadratic_coeff), Geom.line),
  Theme(panel_fill=color("white"))
)
# draw(PNG("quadratic_regression.png", 16cm, 12cm), p)
