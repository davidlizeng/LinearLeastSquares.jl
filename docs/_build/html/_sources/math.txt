===================
The Math Behind LLS
===================

Linearly Constrained Least Squares
==================================
LLS solves **linearly constrained least squares** (or LCLS) problems,
which have the form:

.. math::
  \begin{array}{ll}
    \mbox{minimize} & \|Ax - b\|_2^2 \\
    \mbox{subject to} & Cx = d
  \end{array}

where the unknown variable :math:`x` is a vector of size :math:`n`. The values for
:math:`A`, :math:`b`, :math:`C`, and :math:`d` are given and have sizes
:math:`m\times n`, :math:`m`, :math:`p\times n`, and :math:`p`,
respectively.
LLS finds a value for :math:`x` that satisfies the linear equality
constraints :math:`Cx = d` and minimizes the objective, the sum of the squares of
the entries of :math:`Ax - b`.

When there are no equality constraints, LCLS reduces to the simple unconstrained
least squares problem (LS):

.. math::
  \begin{array}{ll}
    \mbox{minimize}  & \|Ax-b\|_2^2
  \end{array}.

When the objective is absent, LCLS reduces to finding :math:`x` that satisfies
:math:`Cx=d`, i.e., solving a set of linear equations.

.. _solving-lcls:

Solving LCLS
============
There is a unique solution to the LCLS problem if and only if there is a
unique solution to the following system of linear equations in the variable
:math:`x` and a new variable :math:`z`:

.. math::
  \begin{bmatrix} 2A^TA & C^T \\ C & 0 \end{bmatrix}
  \begin{bmatrix} x \\ z \end{bmatrix} =
  \begin{bmatrix} 2A^Tb \\ d \end{bmatrix},

i.e., the matrix on the left is invertible. This occurs when the matrix
:math:`C` has independent rows, and the matrix
:math:`\begin{bmatrix} A\\ C\end{bmatrix}` has indepedent columns.

When there are no equality constraints, the unconstrained least squares problem
has a unique solution if and only if the system of linear equations:

.. math::
  2A^TA x = 2A^Tb

has a unique solution, which occurs when :math:`A^TA` is invertible, i.e., the
columns of :math:`A` are independent.

When the objective is absent, the system of linear equations :math:`Cx = d` has
a unique solution if and only if :math:`C` is invertible.

LLS allows you to specify an LCLS problem in a natural way.  It translates your
specification into the general form in this section, and then solves the
appropriate set of linear equations.
