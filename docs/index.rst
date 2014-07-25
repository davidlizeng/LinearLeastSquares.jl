==============
Welcome to LSQ
==============
LSQ is a library that makes it easy to formulate and solve least squares
optimization problems with linear equality constraints. With LSQ, these types
of problems can be created using a natural syntax that mirrors standard
mathematical notation.

Credits
=======
LSQ has been implemented in following languages:

- Python: `lsqpy <https://github.com/keegango/lsqpy>`_ by Keegan Go
- Julia: `LSQ.jl <https://github.com/davidlizeng/LSQ.jl>`_ by David Zeng and Karanveer Mohan
- Matlab: lsq by Alex Lemon

The design was inspired by Steven Diamond's `CVXPY <http://cvxpy.readthedocs.org/en/latest/>`_,
a similar software packages for solving the much more general class of
convex optimization problems.

A huge thanks to Stephen Boyd for his feedback in both the design and
documentation of LSQ.


License
=======
All implementations of LSQ are released under GPL.


In Depth Tutorials
==================
.. toctree::
  :maxdepth: 2

  The Math Behind LSQ <math>
  LSQ.jl Tutorial <lsqjl>
