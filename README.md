# LSQ.jl

[![Build Status](https://travis-ci.org/davidlizeng/LSQ.jl.png)](https://travis-ci.org/davidlizeng/LSQ.jl)

LSQ.jl is a library that makes it easy to formulate and solve least-squares optimization problems with linear equality constraints. With LSQ.jl, these types of problems can be created using a natural syntax for variables, constraints, and objectives that mirrors standard mathematical notation.

LSQ.jl's syntax and format are modelled on those of CVX.jl, a Julia library that handles the larger class of convex optimization problems.

## Table of contents
* [Installation](#installation)
* [User guide](#user-guide "User guide")
* [Tutorials](#tutorials "Tutorials")
	* [Regression](#regression "Regression")
	* [Control](#control "Control")
* [The math](#the-math "The math")

## Installation

LSQ.jl relies mainly on Julia and some plotting library.

### Julia
[Julia](http://julialang.org/downloads/) is a high-level, high-performance dynamic programming language for technical computing. Make sure to use at least Julia version 0.2.1.

### Plotting libraries
Julia has several plotting libraries, although none has emerged yet as a clear winner. 

## PyPlot.jl
For EE103 at Stanford, we will be using PyPlot.jl To use it, you will also need to install Python, NumPy and Matplotlib. [lsqpy](https://github.com/keegango/lsqpy) has instructions on installing these.

Once you have matplotlib, from your Julia terminal, run `julia> Pkg.add(PyPlot)`. Documentation on PyPlot.jl can be found [here](https://github.com/stevengj/PyPlot.jl).

## Winston.jl
`julia> Pkg.add("Winston")`
More details can be found [here](https://github.com/nolta/Winston.jl).

### LSQ.jl
From your Julia terminal, run `Pkg.clone("git@github.com:davidlizeng/LSQ.jl.git")`.

## User Guide

### Variables

Variables represent the quantities that we want to find. LSQ.jl handles scalar, vector and matrix variables as shown below.

	x = Variable() # A scalar variable
	y = Variable(3) # Create a vector variable with 3 rows and 1 columns
	z = Variable(10,4) # A matrix variable that has 10 rows and 4 columns

Variables are objects, not numeric quantities. Their value is set by calling either minimize or satisfy. After these functions are called, the value of a variable can be obtained through its value attribute. For example,

	x = Variable(10)
	... # Add some constraints
	minimize(x, constraints)
	
	# Print the numeric value of x that minimizes the above problem
	print(x.value) 

### Affine expressions

Affine expressions are made from variables, constants, and other affine expressions using the operations +, -, / and * and also .+, and .-. There are a few rules about what can be combined for each operator.

For addition and subtraction, the two expressions being combined must have the same dimensions to use + and -. If one of the expressions is a scalar and the other is not, .+ and .- is used. When one expression is a scalar, it is added to each entry of the other expression. For example,

For addition and subtraction, the two expressions being combined must either have the same dimensions or one of the two must be a scalar. When one expression is a scalar, it is added to each entry of the other expression. For example,
```
x = Variable(3);
y = Variable(2);
z = Variable(3);
	
x + z; # Ok
x + y; # Fails
z - x ;# Ok

w = Variable(); # A scalar variable
x .+ w; # Ok
y .+ 1; # Ok
```
On the other hand, multiplication will only work between an affine expression and a constant. If either expression is a scalar, the multiplication will work regardless of the size of the other expression.
```
x = Variable(3);
y = Variable();

x * y; # Fails, one must be a constant
5 * x; # Ok
y * [1; 2; 3]
```
However, if both expressions are vectors or matrices then their sizes must match in the usual matrix/vector multiplication sense. This means we can only perform A * B if A is m-by-n and B is n-by-p.
```
x = Variable(4); # A 4-by-1 matrix
A = [1 2 3 4]; # A 1-by-4 matrix
B = [1 2 3]; # A 1-by-3 matrix

B * x; # Fails
A * x; # Ok
```

Division between expressions x and y (x / y) is only allowed if y is some scalar constant value.
```
x = Variable(4, 4); # A 4-by-4 matrix
y = Variable(); # A scalar variable

x / y; # Fails, y must be constant
x / [1; 2; 3; 4]; # Fails, divisor must be scalar
x / 5; # Ok
```

Finally, a few common operations have been created to make formulating your problem simpler.

```
x = Variable(10);
y = Variable(5, 6);

# A scalar affine expression who value is the sum of the entries of x
sum(x);

# A vector affine expression which finds the sum along the specific dimension
sum(y, 1); # Returns a vector of size 6, where the i-th index is sum of the elements in column i.

# A scalar affine expression whose value is the mean of the entries of x
mean(x);
	
# Indexing
x[1]; # Indexing to get the first entry of x
x[1:4]; # Index the first 4 entries of x
y = Variable(3, 3);
y[2, 1:3]; # Get the 2nd row of y, and columns 1, 2 and 3, remember Julia is one-indexed

# Transpose
y'; # Returns a 6-by-5 variable matrix that is the transpose of y

# Reshaping and vectorization

reshape(y, 10, 3); # reshapes y (column-wise) into a 10-by-3 matrix
vec(y); # reshapes y (column-wise) into a 30-by-1 vector

# Diagonal and Diagonal matrix
diagm(x); # Creates a 10-by-10 matrix whose diagonal entries are the entries of x and all other entries are 0
diag(y); # Returns the main-diagonal of y
diag(y, k); # Returns the k-th diagonal of y

# Stacking
# You can horizontally and vertically concatenate variables, expressions and constants 
z = Variable(3, 4);
a = ones(5, 4); # a 5-by-4 matrix of ones
b = ones(3, 10); # a 3-by-10 matrix of ones
[z; a]; # vertical concatenation - a 8-by-4 matrix
[z b]; # horizontal concatenation - 3-by-14 matrix
```

### Equality constraints

The '==' operator creates equality constraints between two affine expressions.
```
x = Variable();
y = Variable();
x == y + 2; # An equality constraint
```
Similar to addition or subtraction, an equality constraint can only be created if two expressions have equal dimensions or if one expression is a scalar. In the latter case, each entry of the matrix is set equal to the scalar.
```
x = Variable(3, 10)
y = Variable(4, 10)
z = Variable() # A scalar variable

x == y; # Fails
x == y[0:3, :]; # Ok, we dropped the last row from y making it 3-by-10
x == z; # Ok
```
### Sum of squares expressions
Sum of squares expressions are created by summing the square of each entry in an affine expression. If you have an affine expression, a sum of squares expression can be created by calling the function sum_squares as shown below.
```
x = Variable(4);
sum_sq_expression = sum_squares(x);
```
Sum of squares expressions can also be created by combining two other sum of squares expressions with +, or by multiplying a sum of squares expression by a non-negative scalar.
```
y = Variable(18);
z = Variable(20);

sum_squares(y) + sum_squares(z); # Ok, sum_squares is always a scalar so sizes of the affine don't matter
10 * sum_squares(z); # Ok
-1 * sum_squares(z); # Fails
```
### Solving

The 'minimize' function creates a least-squares problem for you. It takes as argument an objective that is a sum of squares expression and an optional list of equality constraints to apply. In a simple case it looks like
```
x = Variable(10);
problem = minimize(sum_squares(x), sum(x) == 10); # Creates the problem
solve!(problem); # Solves the problem
problem.optval # Optimal value of the problem
x.value # Optimal value of x
```
	
If a solution is found, the values of the variables used in the problem can be obtained as the value attribute of the variables as shown above. Otherwise, the problem as formed is invalid and minimize will print an appropriate error message. See the math for more information about when the least-squares problem cannot be solved.

LSQ.jl also provides a 'satisfy' function to solve a system of linear equations. It takes as arguments either a list of equality constraints, or a single equality constraint.
```
x = Variable(3);
problem = satisfy([sum(x) == 3, x[0] + x[2] == 2, x[0] + x[1] == 1]);
solve!(problem);
x.value
```

## Tutorials

### Regression

This is an example of using LSQ.jl for regression - the problem of trying to fit a function to some data.

The files for this example are in [examples/simple_lin_and_quad_reg](https://github.com/davidlizeng/LSQ.jl/tree/master/examples/simple_lin_and_quad_reg).

#### Data

In this problem, we are given n points, represented by two n-by-1 vectors: x_data and y_data. The x and y coordinates of the ith point are given by the i-th entries of x_data and y_data respectively.

We should first visualize the [data](https://github.com/davidlizeng/LSQ.jl/tree/master/examples/simple_lin_and_quad_reg/data.jl). In this example, the plotting is built into the data file so we can just run
```
julia data.jl
```	
which shows

![data](https://raw.githubusercontent.com/davidlizeng/LSQ.jl/master/examples/simple_lin_and_quad_reg/data.png)

#### Linear regression

We will first try to fit a line to the data. A general function for a line is:

	f(x) = offset + slope * x

where slope and offset are scalar quantities that we pick to determine the line.

We would like our data points to be "close" the line given by the slope and offset we pick. To define "close", we measure a residual defined as

	residual(x, y) = f(x) - y

for each point (x, y) in our data. Note that when the residual is small in magnitude the value of f(x) is close to y which means the line passes near the point. To account for the residual across multiple points we sum the squares of the residuals to obtain

	total_residual_sq = sum of square(residual(x, y)) for each point (x, y)

The values we want for slope and offset will be the ones that minimize total_residual_sq.

We can now use lsqpy to solve this problem. The [code](https://github.com/davidlizeng/LSQ.jl/blob/master/examples/simple_lin_and_quad_reg/linear_regression.jl) for this example is shown below (with the plotting omitted):

```
# Import LSQ.jl
using LSQ

# Import the data
include("data.jl")

# Solve the problem, and print the result
slope = Variable();
offset = Variable();
p = minimize(sum_squares(offset .+ x_data * slope - y_data));
solve!(p);
println("Slope = $(slope.value[1, 1]), offset = $(offset.value[1, 1])");
```

The first section includes LSQ.jl for use, and the second makes the data accessible. The third section contains the actual work. We first declare two Variables, one for each of the quantities we want to determine. Then we call the function 'minimize' and pass in our expression to minimize. Calling minimize both finds the minimum value of the expression and sets all variables in the problem with values that achieve this minimum. With the values set, all we have to do is print the results.

You can run the above code in your console with
```
julia linear_regression.jl
```

This will print the optimal values and also display the a plot of the line we found.

![lin_results](https://raw.githubusercontent.com/davidlizeng/LSQ.jl/master/examples/simple_lin_and_quad_reg/linear.png)

#### Quadratic regression

Now instead of using a line, let's try to fit a quadratic function to the data.

Our new function will be something of the form

	f(x) = offset + slope * x + quadratic * x ^ 2

which is similar to the linear function we used previously. The only difference is that we have introduced an x^2 term with a new Variable coefficient. Along with offset and slope, quadratic is a Variable that we wish to determine.

Here is the [code](https://github.com/davidlizeng/LSQ.jl/blob/master/examples/simple_lin_and_quad_reg/quadratic_regression.jl) that solves the problem (again, with plotting omitted)

```
# Import LSQ.jl
using LSQ

# Import the data
include("data.jl")

# Create variables that holds the coefficients
quadratic = Variable();
slope = Variable();
offset = Variable();

# We copy x_data but square the entries
x_squared = x_data .^ 2;

# Solve the problem
p = minimize(sum_squares(offset .+ x_data * slope + x_squared * quadratic - y_data));
solve!(p);
```

The code here is very much the same as the linear regression case. Running
```
julia quadratic_regression.jl
```
will show the plot

![quad_results](https://raw.githubusercontent.com/davidlizeng/LSQ.jl/master/examples/simple_lin_and_quad_reg/quadratic.png)

### Control

Another example of a least-squares problem is control, where we want to plan how something will move. In our example, we want to determine the forces that will move our object to a goal position.

#### Formulation

There are 3 unknown quantities in the problem: the force applied, the velocity of the object, and the position of the object. To solve this problem, we will break up time into T points, each h seconds apart. The values of our variables must then satisfy

	p[t+1] = p[t] + h*v[t]
	v[t+1] = v[t] + h/mass*f[t] - drag*v[t]

where p[t], v[t], and f[t] are the position, velocity, and force respectively at time t. This model is only an approximation of the real dynamics of moving objects, but when h is small this model is reasonable accurate.

Finally, we need to decide on an objective. Here we will use the combination

	objective = mu*sum_squares(v[t]) + sum_squares(f[t]) for all t

This objective tells us that we want to minimize both the forces we apply as well as the speed of the object. mu is a constant that determines how much we care about the size of the forces versus the size of the velocity.

#### Solution

The [code](https://github.com/keegango/lsqpy/blob/master/examples/simple_control/simple_control.py "control code") is shown below.

	# Import lsqpy
	from lsqpy import Variable, sum_squares, minimize

	# Import the way points
	from data import initial_velocity, final_position, T, h, mass, drag
	
	# Declare the variables we need
	position = Variable(2,T)
	velocity = Variable(2,T)
	force = Variable(2,T-1)
	
	# Create the list of constraints on our variables
	constraints = []
	for i in range(T-1):
		constraints.append(position[:,i+1] == position[:,i] + h * velocity[:,i])
	for i in range(T-1):
		constraints.append(velocity[:,i+1] == velocity[:,i] + h/mass * force[:,i] - drag*velocity[:,i])
		
	# Add position constraints
	constraints.append(position[:,0] == 0)
	constraints.append(position[:,T-1] == final_position)
	
	# Add velocity constraints
	constraints.append(velocity[:,0] == initial_velocity)
	constraints.append(velocity[:,T-1] == 0)
	
	# Solve the problem
	mu = 1
	minimize(mu*sum_squares(velocity)+sum_squares(force),constraints)
	
The code roughly divides into three sections. We first create our variables: position, velocity, and force. We then create a list of our equality constraints that enforce consistency in our variables. Finally, we call solve. When you run the code with

	python simple_control.py

you should see this plot

![control results](https://github.com/keegango/lsqpy/raw/master/images/control.png "control results")

The black arrows show the force applied to the object, and the red line gives the actual position.

At this point, you can play around with the value of mu to see how the weighting between force and velocity affects the motion of the object. You could even try include in the objective the sum of squares of the position as well. What effect will this have?



## Mathematics behind LSQ.jl

To solve your least-squares problems, lsqpy first converts them to a standard form that looks like

	minimize sum_squares(A * x + b)
	subject to C*x + d == 0
	
A and C are matrices formed by stacking together all the equations in the objective and equality constraints respectively. Similarly, b and d are vectors that contain the constant terms in the objective and equality constraints.

In this form, the least-squares problem by solving the following system of equations:

	[ 2*A'*A  C' ] [ x ] = [ -2*A*b ]
	[   C     0  ] [ z ]   [   -d   ]

This result is derived from the KKT conditions.

Since we are solving a system of linear equations, we can state the precise conditions where LSQ.jl will solve a problem. It requires that the block matrix

	[ 2*A'*A ]
	[    C   ]

has independent columns and that the rows are C are also independent.

## Credits
LSQ.jl is being developed by [David Zeng](http://www.stanford.edu/~dzeng0/) and [Karanveer Mohan](http://www.stanford.edu/~kvmohan/) along with Keegan Go, who is also developing [lsqpy](https://github.com/keegango/lsqpy), a sister project. Special thanks to [Stephen Boyd](http://www.stanford.edu/~boyd/) for all his input.
