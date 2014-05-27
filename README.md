# LSQ.jl

[![Build Status](https://travis-ci.org/davidlizeng/LSQ.jl.png)](https://travis-ci.org/davidlizeng/LSQ.jl)

LSQ.jl is a library that makes it easy to formulate and solve least-squares optimization problems with linear equality constraints. With LSQ.jl, these types of problems can be created using a natural syntax for variables, constraints, and objectives that mirrors standard mathematical notation.

LSQ.jl's syntax and format are modelled on those of CVX.jl, a Julia library that handles the larger class of convex optimization problems.

## Installation
From your Julia terminal, run `Pkg.clone("git@github.com:davidlizeng/LSQ.jl.git")`
You probably also want to install some plotting library, such as PyPlot, Winston or Gaston.

## Basic Usage

### Variables
Variables represent the quantities that we want to find. LSQ.jl handles scalar, vector and matrix variables as shown below.

```
x = Variable() # A scalar variable
y = Variable(3) # Create a vector variable with 3 rows and 1 columns
z = Variable(10, 4) # A matrix variable that has 10 rows and 4 columns
```

Variables are objects, not numeric quantities. Their value is set by calling either minimize or solve. After these functions are called, the value of a variable can be obtained through its value attribute. For example,

```
x = Variable(10)
... # Add some constraints
problem = minimize(x, constraints)
solve!(p
# Print the numeric value of x that minimizes the above problem
println(x.value) 
```

## Mathematics behind LSQ.jl

To solve your least-squares problems, lsqpy first converts them to a standard form that looks like

	minimize sum_squares(A * x + b)
	subject to C*x == d
	
A and C are matrices formed by stacking together all the equations in the objective and equality constraints respectively. Similarly, b and d are vectors that contain the constant terms in the objective and equality constraints.

In this form, the least-squares problem by solving the following system of equations:
```
	[ 2*A'*A  C' ] [ x ] = [ -2*A*b ]
	[   C     0  ] [ z ]   [    d   ]
```
This result is derived from the KKT conditions.

Since we are solving a system of linear equations, we can state the precise conditions where LSQ.jl will solve a problem. It requires that the block matrix

	[ 2*A'*A ]
	[    C   ]

has independent columns and that the rows are C are also independent.

## Credits
LSQ.jl is being developed by [David Zeng](http://www.stanford.edu/~dzeng0/) and [Karanveer Mohan](http://www.stanford.edu/~kvmohan/). Several parts of the README have been taken directly from lsqpy, a sister project being developed by Keegan Go. Special thanks to [Stephen Boyd](http://www.stanford.edu/~boyd/).
