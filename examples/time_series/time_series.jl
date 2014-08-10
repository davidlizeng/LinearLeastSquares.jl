using LinearLeastSquares
import PyPlot.plt
temps = readdlm("melbourne_temps.txt", ',');
plt.figure(0)
plt.plot(temps, color="b")
plt.title("Melbourne Daily Temperature")
n = size(temps, 1);
plt.xlim([0, n])

yearly = Variable(n)

eq_constraints = EqConstraint[]
for i in 365 + 1 : n
  eq_constraints += yearly[i] == yearly[i - 365];
end

smoothing = 100;
smooth_objective = sum_squares(yearly[1 : n - 1] - yearly[2 : n]);
optval = minimize!(sum_squares(temps - yearly) + smoothing * smooth_objective, eq_constraints);
residuals = temps - yearly.value;

# Plot smooth fit
plt.figure(1)
plt.plot(temps)
plt.plot(yearly.value, color="r")
plt.title("Smooth Fit of Data")
plt.xlim([0, n])

# Plot residuals for a few days
plt.figure(2)
plt.plot(residuals[1:100], color="g")

# Generate the residuals matrix
ar_len = 5
residuals_mat = residuals[ar_len : n - 1]
for i = 1:ar_len - 1
  residuals_mat = [residuals_mat residuals[ar_len - i : n - i - 1]]
end

# Solve autoregressive problem
ar_coef = Variable(ar_len)
optval2 = minimize!(sum_squares(residuals_mat * ar_coef - residuals[ar_len + 1 : end]))

# plot autoregressive fit of daily fluctuations for first few days
plt.figure(3)
plt.plot(residuals[ar_len + 1 : ar_len + 100], color="g")
plt.plot(residuals_mat[1:100, :] * ar_coef.value, color="r")
plt.title("Autoregressive Fit of Residuals")

# plot final fit of data
plt.figure(4)
plt.plot(temps)
total_estimate = yearly.value
total_estimate[ar_len + 1 : end] += residuals_mat * ar_coef.value
plt.plot(total_estimate, color="r", alpha=0.5)
plt.title("Total Fit of Data")
plt.xlim([0, n])

plt.show()
