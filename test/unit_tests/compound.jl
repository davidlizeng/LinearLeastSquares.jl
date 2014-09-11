# tests for sum, mean, and var, which implemented by calling other atoms

x = create_var(5, 3)
s = sum(x)
m = mean(x)
test_expr(s, (x,))
test_expr(m, (x,))

t = sum(x, 1)
n = mean(x, 1)
test_expr(t, (x,))
test_expr(n, (x,))

u = sum(x, 2)
p = mean(x, 2)
test_expr(u, (x,))
test_expr(p, (x,))

v = var(x)
test_expr(v)

info("All sum/mean/var tests passed")
