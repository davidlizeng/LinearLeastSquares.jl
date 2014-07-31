"""
Reads a temperature data file as taken from
http://www.cru.uea.ac.uk/cru/data/temperature/
"""
import PyPlot.plt
using LSQ

data = readdlm("CRUTEM4v-gl.dat", ' ');

# We only want to extract the odd lines (1-indexed)
data = vcat([data[i, :] for i in 1 : 2 : size(data, 1)]...);
data = float(data);
years = data[:, 1];
temperatures = vec(data[:, 2 : end - 1]');

num_samples = size(temperatures, 1)

yearly_tread = Variable(num_samples);
a = Variable();
b = Variable();


equality_constraints = EqConstraint[];
for i in 13 : num_samples
  push!(equality_constraints, yearly_tread[i] == yearly_tread[i - 12])
end

t = [0 : num_samples - 1];
t2 = t .^ 2;


smoothing = 0.01;
objective = sum_squares(yearly_tread + t * a + t2 * b - temperatures);
objective += smoothing * sum_squares(yearly_tread[1 : num_samples - 1] - yearly_tread[2 : num_samples]);

optval = minimize!(objective, equality_constraints);

plt.figure(0)
plt.plot(temperatures)
plt.plot(yearly_tread.value + t*a.value + t2*b.value, color="r")
plt.show()

# plt.figure(1)
# plt.plot(yearly_tread.value + t*b.value + t2*a.value - temperatures)
# plt.show()
