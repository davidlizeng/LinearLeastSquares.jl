Welcome to LSQ
==============
LSQ is a library that makes it easy to formulate and solve least squares
optimization problems with linear equality constraints. With LSQ, these types
of problems can be created using a natural syntax that mirrors standard
mathematical notation. Currently LSQ has been implemented in three different
laguages: Python, Julia, and Matlab.

Mathematics behind LSQ
======================
General equality constrained optimization problems over a variable :math:`x`
can be defined as having the following form

  .. math::
    \begin{array}{ll}
      \mbox{minimize} & f(x)\\
      \mbox{subject to} & g_i(x) = 0, \ \forall i = 1,2,\ldots
    \end{array}

Here, the function :math:`f(x)` is known as the **objective**, and the
equations :math:`g_i(x) = 0` are known as the **equality constraints**.
LSQ aims to tackle only one class of such optimization problems, which we will
call **least squares problems**. A least squares problem in the variable
:math:`x` can be framed as the following

  .. math::
    \begin{array}{ll}
      \mbox{minimize} & \|Ax + b\|_2^2 \\
      \mbox{subject to} & Cx = d
    \end{array}

where :math:`A, b, C, d` are constants.
If :math:`C` has linearly independent rows and :math:`Ay \ne 0` for all
:math:`y \in \mathcal{N}(C)`, then solving our original least squares problem
is equivalent to solving the following linear system for variables :math:`x`
and :math:`z`

  .. math::
    \begin{bmatrix} 2A^TA & C^T \\ C & 0 \end{bmatrix}
    \begin{bmatrix} x \\ z \end{bmatrix} =
    \begin{bmatrix} -2A^Tb \\ d \end{bmatrix}

Furthermore, the solution to this system is guaranteed to be unique, and the
unique :math:`x` that solves this system will also be the unique solution to
the original least squares problem. LSQ solves least squares problems by
building this system of linear equations, and then
calling built-in linear equation solvers to solve for :math:`x` and :math:`z`.
As such, LSQ will fail to solve the problem if the least squares problem does
not provide a matrix :math:`C` with linearly independent rows and a matrix
:math:`A` such that :math:`Ay \ne 0` for all :math:`y \in \mathcal{N}(C)`.

LSQ.jl Basics
=============
Recall that the least squares problem is defined as

  .. math::
    \begin{array}{ll}
      \mbox{minimize} & \|Ax + b\|_2^2 \\
      \mbox{subject to} & Cx = d
    \end{array}

We will build up the LSQ syntax, step by step, to eventually create and solve
a problem of this form.

Variables
---------
One of the goals of solving the least squares problem is to obtain the optimal
values for the variables. To declare variables in LSQ, use the following
syntax to specify their size

  .. code-block:: none

    x = Variable(); # A scalar variable
    y = Variable(3); # Create a vector variable with 3 rows and 1 columns
    z = Variable(10, 4); # A matrix variable that has 10 rows and 4 columns

LSQ currently only supports variables up to 2 dimensions in size.

Affine Expressions
------------------
Affine expression of variables is used to emulate the mathematical concept of
affine transformations on variables. Affine expressions of variables can be
built up following the rules below

#. Variables are themselves affine expressions
#. Adding or subtracting two affine expressions yields an affine expression
#. Adding or subtracting constants from an affine expression yields an affine expression
#. Multiplying an affine expression by a constant yields an affine expression

The most basic way of building affine expressions of variables is to use the
binary arithmetic operators ``+, .+, -, .-, *, \``. The ``+, -`` operators
require the left hand side and the right hand side to be of the same size. If
you wish to add or subtract a scalar to an expression of a different size, use
the ``.+, .-`` operators instead.

  .. code-block:: none

    x = Variable(3); # A 3-by-1 vector
    y = Variable(2); # A 2-by-1 vector
    z = Variable(3);
    w = Variable(); # A scalar variable
    c = [1; 2; 3]; # A 3-by-1 vector

    affine1 = x - z;
    affine2 = x - c + z;

    affine3 = x .+ w;
    affine4 = y .+ 1;

The multiplication operator ``*`` supports both scalar multiplication and
matrix multiplication. Matrix-Matrix multiplication must obey the normal size constraint
i.e. a m x n matrix can only be multiplied on the right by a n x p matrix.
Note that affine expressions can only be multiplied by
constants; two affine expressions cannot be multiplied!

  .. code-block:: none

    x = Variable(3); # A 3-by-1 vector variable
    y = Variable(); # A scalar variable

    c = [1; 2; 3]; # A 3-by-1 vector
    b = [1 2 3]; # A 1-by-3 matrix
    I = eye(3); # A 3-by-3 identity matrix

    affine1 = 5 * x;
    affine2 = y * c;

    affine3 = b * x;
    affine4 = I * x;

The division operator ``/`` functions similarly, except that only scalar
division by a constant is supported.

  .. code-block:: none

    x = Variable(3); # A 3-by-1 vector variable
    y = Variable(); # A scalar variable

    affine1 = x / 5;
		affine2 = y / 5;


.. TODO describe shaping and indexing atoms, explain why these stay affine

Equality Constraints
--------------------

The constraints of a least squares problem, :math:`Cx = d` is equivalent to the
form ``affine expression = affine expression``. For example, the equality
constraint involving affine expressions in :math:`y` and :math:`z` can be
easily transformed to the :math:`Cx = d` form

  .. math::
    Ay + Bz - k = Dy - h \implies \begin{bmatrix} A - D & B \end{bmatrix}
    \begin{bmatrix} y \\ z \end{bmatrix} = k - h

The ``==`` operator creates equality constraints between two affine expressions.

  .. code-block:: none

    x = Variable();
    y = Variable();

    x == y + 2; # An equality constraint

An equality constraint can also be assigned and referenced later.

  .. code-block:: none

		# The following is equivalent to
		# eqconst1 = (x == y + 2);
    eqconst1 = x == y + 2;

Similar to addition or subtraction, an equality constraint can only be created
if two expressions have equal dimensions or if one expression is a scalar.
In the latter case, each entry of the matrix is set equal to the scalar.

  .. code-block:: none

    x = Variable(3, 10);
    y = Variable(4, 10);
    z = Variable();

    eqconst1 = x == y[1:3, :]; # Indexing resized y to be 3 by 10
    eqconst2 = x == z;

Sum of Squares Expressions
--------------------------

A sum of squares expression is used to represent the mathematical concept of
norm squared in a way that covers both vectors and matrices. For a general m by n
matrix :math:`M`, the sum of squares of :math:`M` is

  .. math::
		S = \sum_{i=0}^{m}\sum_{j=0}^{n} M_{ij}^2.

That is, the expression :math:`\|Ax + b\|_2^2` is equivalent to
the following code

  .. code-block:: none

    sum_squares(A * x + b);

Like affine expressions, sum of squares expressions can be constructed following
certain rules

#. The argument of a sum of squares expression must be an affine expression
#. The sum of two sum of squares expressions yields a sum of squares expression
#. Multiplying a sum of squares expression by a positive constant yields a sum of squares expression

Since the output of a sum of squares expression is a scalar value, there are no
size restrictions when adding two sum of squares expressions

  .. code-block:: none

    y = Variable(18);
    z = Variable(20);

    sumsq1 = sum_squares(y) + sum_squares(z);
    sumsq2 = 10 * sum_squares(z);

Any sum of squares expression is equivalent to some mathematical expression of
the form :math:`\|Ax + b\|_2^2`. Adding sum of squares expressions or
multiplying them by positive constants will preseve this property.

  .. math::
    \begin{align*}
    \|Ey + f\|_2^2 + \|Gz + h\|_2^2 & =
    \left\| \begin{bmatrix}E & 0 \\ 0 & G\end{bmatrix}
    \begin{bmatrix}y \\ z\end{bmatrix} +
    \begin{bmatrix} f \\ h\end{bmatrix} \right\|_2^2 \\
    c\|Ax + b\|_2^2 & = \left\|\sqrt{c}Ax + \sqrt{c}b\right\|_2^2
    \end{align*}

This means that any sum of squares expression can serve as the objective of
a least squares problem, and that, conversely, the objective of any least
squares problem can be framed as a sum of squares expression.

Solve Functions
---------------
At the top level, LSQ provides functions for compiling the sum of squares
objective and the equality constraints into one problem for solving. These
functions will also populate the variables with optimal values. Following
Julia convention, the names of these functions will contain a ``!`` character
to denote the fact that they will modify the arguments (variables are populated
with optimal values).

The ``minimize!`` function minimizes a sum squares expression over
equality constraints. For example, the following code finds the least norm
solution to an underdetermined system

  .. code-block:: none

    A = randn(3, 2);
    b = randn(2, 1);
    x = Variable(3);
    objective = sum_squares(x);
    constraint = A * x == b;
    optimal_value = minimize!(objective, constraint);
    println(x.value);

The optimal value of :math:`\|Ax - b\|_2^2` is stored in ``optimal_value``, and
the optimal value of ``x`` can be accessed via ``x.value``.

The ``minimize!`` function can also be called with a list of equality
constraints, or with none at all

  .. code-block:: none

    x = Variable(3);
    A = randn(3, 3); C = randn(3, 3);
    b = randn(3, 1); d = randn(3, 1);
    objective = sum_squares(x);
    constraints = [A * x == b, C * x == d];
    optimum_value_1 = minimize!(objective, constraints);
    println(x.value);
    optimum_value_2 = minimize!(objective);
    println(x.value);

LSQ also supports a ``satisfy!`` function, which aims to satisfy a system of
linear equations

  .. code-block:: none

    x = Variable(3); y = Variable(3)
    A = randn(3, 3); C = randn(3, 3);
    b = randn(3, 1); d = randn(3, 1);
    constraints = [A * x == b, C * y == d];
    satisfy!(constraints);
    println(x.value);
    println(y.value);

The variables values that satisfy the system will be stored in the ``value``
field of the variable, similar to the ``minimize!`` function.

