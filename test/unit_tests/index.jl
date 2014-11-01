# indexing tests
x = create_var(4, 6)
y = x[1:3, 5:end]
z = x[:]
t = [1, 2, 3]
f = t * x[2, 3]
test_expr(y, (x,))
test_expr(z, (x,))
test_expr(f, (x,))

info("All index tests passed")
