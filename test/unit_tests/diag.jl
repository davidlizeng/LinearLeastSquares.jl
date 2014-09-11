# diagm test
x = create_var(4, 1)
d = diagm(x)
test_expr(d, (x,))

# main diagonal
x = create_var(3, 4)
d = diag(x, 0)
test_expr(d, (x,))

# off diagonals
x = create_var(3, 4)
d = diag(x, 2)
test_expr(d, (x,))

x = create_var(3, 4)
d = diag(x, -2)
test_expr(d, (x,))

info("All diag tests passed")
