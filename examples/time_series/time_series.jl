using LSQ
temps = readdlm("melbourne_temps.txt", ',');
n = size(temps, 1);

seasonal = Variable(n)

eq_constraints = EqConstraint[]
for i in 365 + 1 : n
  push!(eq_constraints, seasonal[i] == seasonal[i - 365]);
end

smoothing = 0;
smooth_objective = sum_squares(seasonal[1 : n - 1] - seasonal[2 : n]);
p = minimize(sum_squares(temps - seasonal) + smoothing * smooth_objective, eq_constraints);
solve!(p);
residuals = temps - seasonal.value;

# Generate the residuals matrix
matlist = []
residuals_mat = hstack(residuals[ar_len - i : n - i - 1] for i in 1 : ar_len)

# Solve autoregressive problem
ar_coef = Variable(ar_len)
minimize(sum_squares(residuals_mat * ar_coef - residuals[ar_len : end]))

# Do all plotting
plt.figure(0)
plt.plot(temps)
plt.plot(seasonal.value, "r")
plt.title("seasonal fit against data")

plt.figure(1)
plt.plot(residuals[ar_len:], "g")
plt.plot(residuals_mat * ar_coef.value, "r")
plt.title("autoregressive fit against residuals")

plt.figure(2)
plt.plot(temps)
total_estimate = seasonal.value
total_estimate[ar_len : end] += residuals_mat * ar_coef.value
plt.plot(total_estimate,"r")
plt.title("total fit vs data")

plt.show()
