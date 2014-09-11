x = create_var(3, 4)
y = x'
test_expr(y, (x,))

x = create_var(10, 1)
y = x''
test_expr(y, (x,))

info("All transpose tests passed")
