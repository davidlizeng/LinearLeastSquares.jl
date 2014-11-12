# Simple Linear Regression
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
x_data = rand(n) * 5
x_data_expanded = hcat([x_data .^ i for i in 1 : 3]...)
y_data = x_data_expanded * true_coeffs + 0.5 * rand(n)

slope = Variable()
offset = Variable()
line = offset + x_data * slope
residuals = line - y_data
fit_error = sum_squares(residuals)
optval = minimize!(fit_error)

# plot the data and the line
t = [0; 5; 0.1]
p = plot(
  layer(x=x_data, y=y_data, Geom.point),
  layer(x=t, y=evaluate(slope) * t + evaluate(offset), Geom.line),
  Theme(panel_fill=color("white"))
)
# draw(PNG("linear_regression.png", 16cm, 12cm), p)
