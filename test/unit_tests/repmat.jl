x = create_var(3, 2)
r = repmat(x, 4, 5)
test_expr(r, (x,))

x = create_var(1, 1)
r = repmat(x, 1, 1)
test_expr(r, (x,))

x = create_var(3, 3)
y = x + [1 2 3; 4 5 6; 7 8 9]
r = repmat(y, 1, 3)
test_expr(r, (x,))

x = create_var(3, 3)
y = x + [1 2 3; 4 5 6; 7 8 9]
r = repmat(y, 4, 1)
test_expr(r, (x,))

info("All repmat tests passed")
