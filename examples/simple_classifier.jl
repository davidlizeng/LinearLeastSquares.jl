# Simple Classifier
# Originally written by Keegan Go for lsqpy
# Translated into LSQ.jl by Karanveer Mohan and David Zeng

using LSQ
import PyPlot.plt

# Set the random seed to get consistent data
srand(1);

# Number of examples to use
n = 200;

# Specify the true value of the variable
true_vect = [-1; 1];

# Create data and labels
X = rand(n, 2) * 2;
y = sign(X * true_vect + rand(n, 1));

a = Variable(2);
p = minimize(SumSquares(X * a - y));
solve!(p);
println(a.value);

# Plot the line we found
plt.plot(X[y[:, 1] .>= 0, 1], X[y[:, 1] .>= 0, 2], "ro");
plt.plot(X[y[:, 1] .< 0, 1], X[y[:, 1] .< 0, 2], "bo");

t = [-5 : 0.1 : 5];
plt.plot(t, -a.value[1, 1] * t / a.value[2, 1]);
plt.xlabel("x");
plt.ylabel("y");
plt.xlim([0, 2]);
plt.ylim([0, 2]);
