x = create_var(1, 1)
y = create_var(3, 1)
s = sum_squares(x) + sum_squares(y)
test_expr(s)

s = 4 * s
test_expr(s)

s = s * 2
test_expr(s)

s = s / 4
test_expr(s)

s = 0
s += sum_squares(x)
s += sum_squares(y)
s += 5
s += sum_squares(9)
s += sum_squares()
test_expr(s)

s = sum_squares(x)
@test_throws ErrorException  s + (-3)

info("All sum squares tests passed")
