# Simple control problem
# Code was initially written by Jenny Hong for EE103
# Translated to lsqpy by Keegan Go
# Written in LinearLeastSquares.jl by Karanveer Mohan and David Zeng
#
# In this control problem, the object starts from the origin

using LinearLeastSquares
import PyPlot.plt

# Some constraints on our motion
# The object should start from the origin, and end at rest
initial_velocity = [4; 20];
final_position = [10; 10];

T = 100; # The number of timesteps
h = 0.1; # The time between time intervals
mass = 1; # Mass of object
drag = 0.01; # Drag on object
g = [0, -1]; # Gravity on object

# Declare the variables we need
position = Variable(2, T);
velocity = Variable(2, T);
force = Variable(2, T - 1);

# Create a problem instance
mu = 1;
constraints = EqConstraint[];

# Add constraints on our variables
for i in 1 : T - 1
  constraints += position[:, i + 1] == position[:, i] + h * velocity[:, i];
end

for i in 1 : T - 1
  constraints += velocity[:, i + 1] == velocity[:, i] + h / mass * force[:, i] + h * g - drag * velocity[:, i];
end

# Add position constraints
constraints += position[:, 1] == 0;
constraints += position[:, T] == final_position;

# Add velocity constraints
constraints += velocity[:, 1] == initial_velocity;
constraints += velocity[:, T] == 0;

# Solve the problem
optval = minimize!(mu * sum_squares(velocity) + sum_squares(force), constraints);


plt.plot(position.value[1, 1:2:T]', position.value[2, 1:2:T]', "r-", linewidth=1.5)
plt.quiver(position.value[1, 1:4:T], position.value[2, 1:4:T], force.value[1, 1:4:T-1]/2, force.value[2, 1:4:T-1]/2, width=0.002)
plt.plot(0, 0, "bo", markersize=10)
plt.plot(final_position[1], final_position[2], "go", markersize=10)
plt.xlim([-5, 15])
plt.ylim([-20, 20])
plt.show()
