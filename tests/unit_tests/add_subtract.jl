a = Variable();
b = eye(3);
c = a + b;
set_value!(a, 1);
val1 = eval_internals(c, (a,));
val2 = c.evaluate();
@assert all(val1 .== val2)

info("All add/subtract tests passed")
