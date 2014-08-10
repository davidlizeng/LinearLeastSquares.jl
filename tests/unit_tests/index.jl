# indexing tests
x = Variable(4, 6);
set_value!(x, [1 2 3 4 5 6; 7 8 9 10 11 12; 13 14 15 16 17 18; 19 20 21 22 23 24]);
y = x[1:3, 5:end];
z = x[:];
val1 = eval_internals(y, (x,));
val2 = eval_internals(z, (x,));
val3 = y.evaluate();
val4 = z.evaluate();
@assert all(val1 .== val3)
@assert all(val2 .== val4)

info("All index tests passed.")
