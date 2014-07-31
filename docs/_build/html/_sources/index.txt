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
implmentations include Python and Matlab.


In Depth Tutorials
==================
.. toctree::
  :maxdepth: 2

  math
  lsqjl
  lsqjl_examples


Credits
=======
LSQ has been implemented in following languages:

- Python: `lsqpy <https://github.com/keegango/lsqpy>`_ by Keegan Go
- Julia: `LSQ.jl <https://github.com/davidlizeng/LSQ.jl>`_ by David Zeng and Karanveer Mohan
- Matlab: lsq by Alex Lemon

All implementations of LSQ are released under GPL.

The design of LSQ was inspired by Steven Diamond's
`CVXPY <http://cvxpy.readthedocs.org/en/latest/>`_,
a similar software packages for solving the much more general class of
convex optimization problems.

A huge thanks to Stephen Boyd for his feedback in both the design and
documentation of LSQ.


