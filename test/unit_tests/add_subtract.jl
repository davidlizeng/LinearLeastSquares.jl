a = create_var(1, 1)
b = eye(3)
c = a + b
test_expr(c, (a,))

p = b + c
test_expr(p, (a,))

x = create_var(3, 4)
d = a - x
test_expr(d, (a, x))

f = x + a
test_expr(f, (a, x))

g = x - a
test_expr(g, (a, x))

info("All add/subtract tests passed")
