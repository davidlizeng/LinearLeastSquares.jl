# hcat test
x = create_var(3, 1)
y = create_var(3, 2)
z = create_var(3, 3)
h = [x y z]
test_expr(h, (x, y, z))

# vcat test
x = create_var(1, 3)
y = create_var(2, 3)
z = create_var(3, 3)
v = [x; y; z]
test_expr(v, (x, y, z))
# v = [x, z, y]
# test_expr(v, (x, y, z))

# hvcat test
hv = [x x; y y; z z]
test_expr(hv, (x, y, z))

info("All stack tests passed")
