# diagm test
x = Variable(4);
d = diagm(x);
set_value!(x, [1; 2; 3; 4]);
val1 = eval_internals(d, (x,));
val2 = d.evaluate();
@assert all(val1 .== val2);

# diag test 1
x = Variable(3, 4);
d = diag(x, 0);
set_value!(x, [1 2 3 4; 5 6 7 8; 9 10 11 12]);
val1 = eval_internals(d, (x,))
val2 = d.evaluate();
@assert all(val1 .== val2);

# diag test 2
x = Variable(3, 4);
d = diag(x, 2);
set_value!(x, [1 2 3 4; 5 6 7 8; 9 10 11 12]);
val1 = eval_internals(d, (x,))
val2 = d.evaluate();
@assert all(val1 .== val2);

# diag test 3
x = Variable(3, 4);
d = diag(x, -2);
set_value!(x, [1 2 3 4; 5 6 7 8; 9 10 11 12]);
val1 = eval_internals(d, (x,))
val2 = d.evaluate();
@assert all(val1 .== val2);

info("All diag tests passed.")
