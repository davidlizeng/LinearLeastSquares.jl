==============
Welcome to LSQ
==============
LSQ is a library that makes it easy to formulate and solve least squares
optimization problems with linear equality constraints. With LSQ, these types
of problems can be created using a natural syntax that mirrors standard
mathematical notation.

For example, the classic problem of finding the least norm solution to an
underdetermined system can be easily setup and solved with the following code:

.. code-block:: none

  using LSQ

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

This example showcases the Julia implementation of LSQ; other
implementations include Python and Matlab.


In Depth Docs
=============
.. toctree::
  :maxdepth: 2

  The Math <math>
  Tutorial <lsqjl>
  Examples <lsqjl_examples>
  Credits <credits>


