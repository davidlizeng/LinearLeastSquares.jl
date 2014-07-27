a = Variable();
b = eye(3);
c = a * b;
a.value = 1;
val1 = eval_internals(c, (a,));
val2 = c.evaluate();
@assert all(val1 .== val2)
