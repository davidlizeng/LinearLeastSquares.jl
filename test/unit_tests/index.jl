# indexing tests
x = create_var(4, 6)
y = x[1:3, 5:end]
z = x[:]
test_expr(y, (x,))
test_expr(z, (x,))

info("All index tests passed")
