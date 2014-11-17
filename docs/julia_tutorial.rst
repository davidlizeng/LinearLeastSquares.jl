==============================
LinearLeastSquares.jl Tutorial
==============================

The Julia package that implements LLS goes by the name of LinearLeastSquares.jl.
We'll refer to LinearLeastSquares.jl as LLS throughout this tutorial.

Installing LLS
==============
LLS requires `Julia 0.3 <http://julialang.org/downloads/>`_ or higher.
For those new to Julia, the `official Julia docs <http://docs.julialang.org/en/release-0.3/>`_
are a good way to get acquainted with the language.

To install LLS, simply open up a Julia terminal and run the commands:

.. code-block:: none

  Pkg.update()
  Pkg.add("LinearLeastSquares")

To use LLS in Julia, run the following command to import the library:

.. code-block:: none

  using LinearLeastSquares

The same line of code can also be used in Julia scripts to import the LinearLeastSquares.jl
package.

.. TODO: plotting library instructions.

Variables and Constants
=======================
To declare variables in LLS, use the following syntax to specify their size:

.. code-block:: none

  x = Variable()      # A scalar variable
  y = Variable(3)     # A vector variable with 3 rows and 1 column
  z = Variable(10, 4) # A matrix variable that has 10 rows and 4 columns

LLS currently only supports variables up to 2 dimensions in size, i.e.,
scalars, vectors, and matrices. Variables
have no value upon creation, but after solving a problem, LLS will populate
all variables in the problem with optimal values.
These values can be accessed using the evaluate function:

.. code-block:: none

  # x is a variable with value populated
  x_value = evaluate(x)

Constants refer to any numerical scalars, vectors, or matrices of fixed value.
Together with variables, they serve as the building blocks for more complex expressions.


Affine Expressions
==================
Affine expressions are linear functions of variables plus a constant.
Variables are themselves affine expressions.
The most basic way to build more affine expressions from variables is to use the overloaded
binary arithmetic operators ``+, -, *, /``. The following operations are
supported:

#. Addition or subtraction of two affine expressions, provided they are the same size or one is scalar.
#. Addition or subtraction of an affine expression and a constant, provided they are the same size or one is scalar.
#. Scalar or matrix multiplication between an affine expression and a constant.
#. Division of an affine expression by a scalar, nonzero constant.

Here are some examples of using binary operators to construct affine expressions:

.. code-block:: none

  w = Variable()     # scalar
  x = Variable(3)    # 3-by-1 vector
  Y = Variable(2, 3) # 2-by-3 matrix
  z = Variable()     # scalar
  b = [1 2 3]        # 1-by-3 matrix
  C = randn(3, 4)    # 3-by-4 matrix

  affine1 = w + b * x / 1.3 - 6.1   # scalar
  affine2 = (affine1 - Y) * C       # 2-by-4 matrix
  affine3 = affine2 - affine1       # 2-by-4 matrix

An affine expression can be evaluated to a numerical value if all variables the affine
expression depends on have been populated with values. For example, the following
code prints the value of the affine expression ``affine1``, assuming both ``w``
and ``x`` have been populated with values:

.. code-block:: none

  println(evaluate(affine1))

Affine expressions support indexing and slicing using Julia's native syntax:

.. code-block:: none

  x = Variable(4)
  a = x[3]              # third component of x
  y = x[1:2]            # first two components of x
  X = Variable(4, 5)
  Y = X[3:4, 4:5]       # bottom right 2-by-2 submatrix of X
  T = X[2:end, :]       # all but the first row of X
  Z = 2 * x[1] + X
  b = Z[1, 2]           # entry in first row and second column of Z

Affine expressions may also be stacked vertically and horizontally using Julia's
native syntax:

.. code-block:: none

  x = Variable()
  y = Variable(1, 3)
  z = Variable(3)
  T = Variable(3, 3)
  horizontal_stack = [x y]  # 1-by-4 matrix
  vertical_stack = [z; x]   # 4-by-1 vector
  horizontal_and_vertical_stack = [x y; z T]  # 4-by-4 matrix

A few other functions also alter the shapes and sizes of
affine expressions:

.. code-block:: none

  x = Variable(3, 1)
  T = Variable(4, 4)

  y = x' # transpose of x

  X = diagm(x)     # create a diagonal matrix from a vector x
  t = diag(T)      # extract the main diagonal of T as a column vector
  t1 = diag(T, 1)  # extract the diagonal one right of the main diagonal of T
  t2 = diag(T, -1) # extract the diagonal one left of the main diagonal of T

  S = reshape(T, 8, 2) # reshape T as an 8-by-2 matrix
  s = vec(S)           # reshape S as a 16-by-1 vector

  x_rep = repmat(x, 2, 3) # tiles x twice vertically and three times horizontally to form a 6-by-3 matrix

The sum and mean of the entries of an affine expression can be constructed:

.. code-block:: none

  X = Variable(2, 3)
  sum_of_entries = sum(X)    # sums all entries of X
  sum_of_columns = sum(X, 1) # sums along the first dimension of X, creating a row vector
  sum_of_rows = sum(X, 2)    # sums along the second dimension of X, creating a column vector
  mean_of_entries = mean(X)
  mean_of_columns = mean(X, 1)
  mean_of_rows = mean(X, 2)


Linear Equality Constraints
===========================
In LLS, a linear equality constraint is formed between an affine expression and a constant,
or two affine expressions, using the ``==`` operator.
Note that the ``==`` operator has been overloaded to no longer return a boolean,
but rather an object representing the linear equality constraint.
A linear equality constraint is only valid if the left hand side and the right hand side
of the ``==`` have the same size, or if one is scalar. Here are some examples of
linear equality constraints:

.. code-block:: none

  x = Variable(3)
  A = randn(4, 3)
  constraint1 = A * x == randn(4, 1)
  constraint2 = 3 == x[1:2]

Lists of constraints can also be created. Additional constraints can be appended
to a list using the ``+`` operator.

.. code-block:: none

  constraint_list = [A * x == randn(4, 1), 3 == x[1:2]]
  constraint_list += x[3] == 1.6

An empty list of constraints can be created with ``[]``. You can add to an empty
list with the same syntax.

.. code-block:: none

  new_list = []
  new_list += x[2] == 1.2


The ``solve!`` Function
=======================
LLS can solve a system of linear equations using the ``solve!`` funciton. The
exclamation point after ``solve`` is a Julia convention signifying that this
function will have side effects; specifically, it will assign values to
variables after solving. After that, the values of the variables, and any
expressions that depend on them, can be accessed.

.. code-block:: none

  x = Variable()
  y = Variable()
  solve!(x + 3 * y == 2, x - y == 1)
  println(evaluate(x))
  println(evaluate(y))

The arguments to the ``solve!`` function are either one or more comma separated
linear equality constraints or a list of linear equality constraints.
Only systems with unique solutions can
be solved by LLS; see the :ref:`solving-lcls` section for detailed conditions.
The ``solve!`` function will issue an error if these conditions are not satisfied.


Sum of Squares Expressions
==========================
In LLS, a sum of squares expression is the sum of squares of the entries of a scalar, vector,
or matrix. The most basic way to create such an expression is to call the ``sum_squares`` function
on an affine expression argument.
For example, ``sum_squares(A * x - b)`` is the LLS representation of :math:`\|Ax - b\|_2^2`.
To create other sum of squares expressions, the ``+``, ``*``, and ``/`` operators can be used in
conjunction with the following rules:

#. Two sum of squares expressions can be added
#. A sum of squares expression can be multiplied or divided by a postive, scalar constant.
#. A nonnegative scalar constant may be added to a sum of squares expression.

Note that sum of squares expression cannot be subtracted from each other,
or multiplied or divided by a negative number. LLS will issue an error message if
the user attempts any of these.
Here are some examples of building sum of squares expressions:

.. code-block:: none

  A = randn(4, 3)
  b = randn(4, 1)
  x = Variable(3)
  c = 0.1
  reg_least_squares = sum_squares(A * x - b) + c * sum_squares(x)

Similar to an affine expression, a sum of squares expression can be evaluated
to a numerical value if all variables the sum of squares expression depends on
have been populated with values. For example, the following
code prints the value of the sum of squares expression ``reg_least_squares``,
assuming ``x`` has been populated with a value:

.. code-block:: none

  println(evaluate(reg_least_squares))

Often you'll find it useful to first initialize a sum of squares expression
to ``0`` and then add on more sum of squares expressions in a for loop.

.. code-block:: none

  error_term = 0
  for i in 1:3
    error_term += rand() * sum_squares(A[i, :] * x + b[i])
  end

The variance of the entries of an affine expression ``X`` can be expressed as
``sum_squares(mean(X) - X) / (m * n)``, where ``m`` and ``n`` are the number of rows
and number of columns of ``X``, respectively. For convenience, the function ``var``
can be used to directly create this sum of squares expression for variance.

.. code-block:: none

  X = Variable(3, 4)
  variance = var(X)


The ``minimize!`` Function
==========================
LLS can also solve a linearly constrained least squares problem using the
``minimize!`` function:

.. code-block:: none

  A = randn(3, 2)
  b = randn(2, 1)
  x = Variable(3)
  objective = sum_squares(x)
  constraint = A * x == b
  optimal_value = minimize!(objective, constraint)
  println(evaluate(x))

The first argument, or objective, of ``minimize!`` must be a sum of squares expression.
The remaining arguments are for constraints, and can be zero or more comma separated
linear equality constraints, or a list of linear equality constraints.
The ``minimize!`` function
will return the optimal value of the sum of squares expression, while
populating all variables with optimal values.
Here are some usage examples:

.. code-block:: none

  x = Variable(3)
  C = randn(2, 3)
  d = randn(2)
  A = randn(4, 3)
  b = randn(4)

  # no constraints
  objective2 = sum_squares(A * x - b)
  optimum_value_2 = minimize!(objective2)
  println(evaluate(x))

  # list of constraints
  objective1 = sum_squares(x)
  constraints = [C * x == d, x[1] == 0]
  optimum_value_1 = minimize!(objective1, constraints)
  println(evaluate(x))


A linearly constrained least squares can only be solved if it satisfies the
conditions in the :ref:`solving-lcls` section. The ``minimize!`` function will issue
an error these conditions are not satisfied.
