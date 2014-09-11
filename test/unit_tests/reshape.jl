# reshape test
x = create_var(6, 4)
y = reshape(x, 8, 3)
z = reshape(x, 4, 6)
v = vec(x)
test_expr(y, (x,))
test_expr(z, (x,))
test_expr(v, (x,))

info("All reshape tests passed")
