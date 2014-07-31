using LSQ
import PyPlot.plt
temps = readdlm("melbourne_temps.txt", ',');
plt.figure(0)
plt.plot(temps, color="b")
plt.title("Melbourne Daily Temperature")
n = size(temps, 1);
plt.xlim([0, n])

seasonal = Variable(n)

eq_constraints = EqConstraint[]
for i in 365 + 1 : n
  eq_constraints += seasonal[i] == seasonal[i - 365];
end

smoothing = 3;
smooth_objective = sum_squares(seasonal[1 : n - 1] - seasonal[2 : n]);
optval = minimize!(sum_squares(temps - seasonal) + smoothing * smooth_objective, eq_constraints);
residuals = temps - seasonal.value;

# Plot seasonal trend
plt.figure(1)
plt.plot(temps)
plt.plot(seasonal.value, color="r", alpha=0.5)
plt.title("Seasonal Fit of Data")
plt.xlim([0, n])

# Generate the residuals matrix
ar_len = 5
residuals_mat = residuals[ar_len : n - 1]
for i = 1:ar_len - 1
  residuals_mat = [residuals_mat residuals[ar_len - i : n - i - 1]]
end

# Solve autoregressive problem
ar_coef = Variable(ar_len)
optval2 = minimize!(sum_squares(residuals_mat * ar_coef - residuals[ar_len + 1 : end]))

# plot autoregressive fit of daily fluctuations
plt.figure(2)
plt.plot(residuals[ar_len + 1 : end], color="g", alpha=1)
plt.plot(residuals_mat * ar_coef.value, color="r", alpha=0.5)
plt.title("Autoregressive Fit of Residuals")
plt.xlim([0, n])

# plot final fit of data
plt.figure(3)
plt.plot(temps)
total_estimate = seasonal.value
total_estimate[ar_len + 1 : end] += residuals_mat * ar_coef.value
plt.plot(total_estimate, color="r", alpha=0.5)
plt.title("Total Fit of Data")
plt.xlim([0, n])

plt.show()
