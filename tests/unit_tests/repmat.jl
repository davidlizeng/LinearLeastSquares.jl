# repmat test 1
x = Variable(3, 2);
r = repmat(x, 4, 5);
x.value = [5 8; 6 9; 7 0];
val1 = eval_internals(r, (x,));
val2 = r.evaluate();
@assert all(val1 .== val2)

x = Variable();
r = repmat(x, 1, 1);
x.value = [3];
val1 = eval_internals(r, (x,));
val2 = r.evaluate();
@assert all(val1 .== val2)

x = Variable(3, 3);
y = x + [1 2 3; 4 5 6; 7 8 9];
r = repmat(y, 1, 3);
x.value = eye(3);
val1 = eval_internals(r, (x,));
val2 = r.evaluate();
@assert all(val1 .== val2)

x = Variable(3, 3);
y = x + [1 2 3; 4 5 6; 7 8 9];
r = repmat(y, 4, 1);
x.value = eye(3);
val1 = eval_internals(r, (x,));
val2 = r.evaluate();
@assert all(val1 .== val2)

info("All repmat tests passed.")
