Welcome to LSQ
==============
LSQ is a library that makes it easy to formulate and solve least squares
optimization problems with linear equality constraints. With LSQ, these types
of problems can be created using a natural syntax that mirrors standard
mathematical notation. Currently LSQ has been implemented in three different
laguages: Python, Julia, and Matlab.

Linearly Constrained Least Squares
==================================
LSQ solves **linearly constrained least squares** (or LCLS) problems,
which have the form

  .. math::
    \begin{array}{ll}
      \mbox{minimize} & \|Ax - b\|_2^2 \\
      \mbox{subject to} & Cx = d
    \end{array}

where the unknown variable :math:`x` is a vector of size :math:`n`. The values for
:math:`A`, :math:`b`, :math:`C`, and :math:`d` are given and have sizes
:math:`m\times n`, :math:`m`, :math:`p\times n`, and :math:`p`,
respectively.
LSQ finds the unique value for :math:`x` that both satisfies the linear equality
constraints :math:`Cx = d` and minimizes the objective, the sum of the squares of
the entries of :math:`Ax - b`.


Solving LCLS
============
There is a unique solution to the LCLS problem if and only if there is a
unique solution to the following linear system of equations in the variable
:math:`x` and a new variable :math:`z`

  .. math::
    \begin{bmatrix} 2A^TA & C^T \\ C & 0 \end{bmatrix}
    \begin{bmatrix} x \\ z \end{bmatrix} =
    \begin{bmatrix} 2A^Tb \\ d \end{bmatrix}

This occurs when the the matrix :math:`C` has independent rows, and the matrix
:math:`\begin{bmatrix} A\\ C\end{bmatrix}` has indepedent columns.

There are a couple special cases that LSQ can also handle. If :math:`p = 0`,
then LSQ solves the unconstrained minimization of :math:`\|Ax - b\|_2^2`, which
will have a unique solution as long as :math:`A` has independent columns.
If :math:`m = 0`, then LSQ solves the system of linear equations :math:`Cx = d`,
which will have a unique solution if :math:`C` is square and invertible.


LSQ.jl Basics
=============
TODO: Open up with an example, maybe regularized least squares?


Variables and Constants
=======================
One of the goals of solving the LCLS problem is to obtain the optimal
values for the variables. To declare variables in LSQ, use the following
syntax to specify their size

  .. code-block:: none

    x = Variable();      # A scalar variable
    y = Variable(3);     # Create a vector variable with 3 rows and 1 columns
    z = Variable(10, 4); # A matrix variable that has 10 rows and 4 columns

LSQ currently only supports variables up to 2 dimensions in size. Variables
have no value upon creation, but after solving a problem, LSQ will populate
the variable with its optimal value. This value can be accessed in the
following ways

  .. code-block:: none

    # x is a variable with value populated
    println(evaluate(x)) # evaluate function
    println(x.value)     # value attribute

Constants refer to any numerical scalars, vectors, or matrices of fixed value.
Together with variables serve as the building blocks for more complex expressions.


Affine Expressions
==================
Affine expression are linear functions of variables plus a constant.
Variables are themselves affine expressions.
The most basic way to build more affine expressions from variables is to use the overloaded
binary arithmetic operators ``+, -, *, /``. The following operations are
supported

#. Addition or subtraction between two affine expressions, provided they are the same size or one is scalar.
#. Addition or subtraction between an affine expression and a constant, provided they are the same size or one is scalar.
#. Scalar or matrix multiplication between an affine expression and a constant.
#. Division of an affine expression by a scalar, nonzero constant.

Here are some examples of using binary operators to construct affine expressions

  .. code-block:: none

    w = Variable();     # scalar
    x = Variable(3);    # 3-by-1 vector
    Y = Variable(2, 3); # 2-by-3 matrix
    z = Variable();     # scalar
    b = [1 2 3];        # 1-by-3 vector
    C = randn(3, 4);    # 3-by-4 matrix

    affine1 = w + b * x / 1.3 - 6.1;   # scalar
    affine2 = (affine1 - Y) * C;       # 2-by-4 matrix

An affine expression can be evaluated to a numerical value if all variables the affine
expression depends on have been populated with values. The syntax for doing so is

  .. code-block:: none

    println(evaluate(affine1))

TODO: describe shaping and indexing functions, sum, mean, etc.


Linear Equality Constraints
===========================
In LSQ, a linear equality constraint is formed between an affine expression and a constant,
or two affine expressions, using the ``==`` operator.
Note that the ``==`` operator has been overloaded to no longer return a boolean,
but rather object representing the linear equality constraint.
A linear equality constraint is only valid if the left hand side and the right hand side
of the ``==`` have the same size, or if one is scalar. Here are some examples of
linear equality constraints

  .. code-block:: none

    x = Variable(3);
    A = randn(4, 3);
    constraint1 = A * x == randn(4, 1);
    constraint2 = 3 == x[1:2];

Lists of constraints can also be created. Additional constraints can be appended
to a list using the ``+`` operator.

  .. code-block:: none

    constraint_list = [A * x == randn(4, 1), 3 == x[1:2]];
    constraint_list += x[3] == 1.6;


The ``solve!`` Method
=====================
LSQ can solve a system of linear equations using the ``solve!`` method.
After a system is solved, values of variables can be accessed.

  .. code-block:: none

    x = Variable();
    y = Variable();
    solve!([x + 3 * y = 2; x - y = 1]);
    println(evaluate(x));
    println(evaluate(y));

The arguments to the ``solve!`` method are either one linear equality constraint
or a list of linear equality constraints. Only systems with unique solutions can
be solved by LSQ; see the `Solving LCLS`_ section for detailed conditions.
The ``solve!`` method will throw an error if these conditions are nor satisfied.


Sum of Squares Expressions
==========================
In LSQ, a sum of sqaures expression is the sum of squares of the entries of a scalar, vector,
or matrix. The most basic way to create such an expression is the ``sum_squares`` function.
For example, ``sum_squares(A * x - b)`` is the LSQ representation of :math:`\|Ax - b\|_2^2`.
The argument of the ``sum_squares`` function must be an affine expression. To create
other sum of squares expressions, the ``+`` and ``*`` operators can be used in
conjunction with the following rules

#. Two sum of squares expressions can be added
#. A sum of squares expression can be multiplied or divided by a postive, scalar constant.

Here are some examples of building sum of squares expressions

  .. code-block:: none

    A = randn(4, 3);
    b = randn(4, 1);
    x = Variable(3);
    c = 0.1;
    reg_least_squares = sum_squares(A * x - b) + c * sum_squares(x)

Similar to an affine expression, a sum of squares expression can be evaluated
to a numerical value if all variables the sum of squares expression depends on
have been populated with values. The syntax for doing so is

  .. code-block:: none

    println(evaluate(reg_least_squares))

TODO: Talk abt the variance function.


The ``minimize!`` Method
========================
LSQ can also solve a linearly constrained least squares problem using the
``minimize!`` method.

  .. code-block:: none

    A = randn(3, 2);
    b = randn(2, 1);
    x = Variable(3);
    objective = sum_squares(x);
    constraint = A * x == b;
    optimal_value = minimize!(objective, constraint);
    println(evaluate(x));

The first argument, or objective, of ``minimize!`` must be a sum of squares expression.
The second argument is for constriants, and can be empty, a single linear equality
constraint, or a list of linear equality constraints.
The ``minimize!`` function
will return the optimal value of the sum of squares expression, while
populating all variables with optimal values.
Here are some usage examples

  .. code-block:: none

    x = Variable(3);
    C = randn(2, 3);
    d = randn(2, 1);
    A = randn(4, 3);
    b = randn(4, 1);

    # list of constraints
    objective1 = sum_squares(x);
    constraints = [C * x == d, x[1] == 0];
    optimum_value_1 = minimize!(objective1, constraints);
    println(evaluate(x));

    # no constraints
    objective2 = sum_squares(A * x - b)
    optimum_value_2 = minimize!(objective2);
    println(evaluate(x));

A linearly constrained least squares can only be solved if it satisfies the
conditions in the `Solving LCLS`_ section. The ``minimize!`` method will throw
an error these conditions are not satisfied.


