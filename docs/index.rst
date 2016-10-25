=============================
Welcome to LinearLeastSquares
=============================
LinearLeastSquares, or LLS for short, is a library that makes it easy to
formulate and solve least squares optimization problems with linear equality
constraints. With LLS, these types of problems can be created using a
natural syntax that mirrors standard mathematical notation.

LinearLeastSquares is a software package developed for the course, Introduction
to Matrix Methods (EE103), taught by Professor Stephen Boyd at Stanford University. The accompanying text for LinearLeastSquares is `Vectors, Matrices, and
Least Squares <http://ee103.stanford.edu/mma.html>`_.

For example, the classic problem of finding the least norm solution to an
underdetermined system can be easily setup and solved with the following code:

.. code-block:: none

  using LinearLeastSquares

  # Problem data
  p = 20;
  n = 30;
  C = randn(p, n);
  d = randn(p, 1);

  # Build the components of the problem
  x = Variable(n);
  objective = sum_squares(x);
  constraint = C * x == d;

  # Solve the problem
  optimal_value = minimize!(objective, constraint)

This example showcases the Julia implementation of LLS; other
implementations include Python.


In Depth Docs
=============
.. toctree::
  :maxdepth: 2

  The Math <math>
  Tutorial <julia_tutorial>
  Examples <julia_examples>
  Credits <credits>


