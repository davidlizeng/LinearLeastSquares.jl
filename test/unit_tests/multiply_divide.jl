a = create_var(1, 1)
b = eye(3)
c = a * b
test_expr(c, (a,))

d = create_var(5, 3)
f = a * 3.1 + 5.3 * d
test_expr(f, (a, d))

g = rand(4, 5) * d
test_expr(g, (d,))

h = d * rand(3, 4)
test_expr(h, (d,))

j = d / 4
test_expr(j, (d,))

info("All multiply/divide tests passed")
