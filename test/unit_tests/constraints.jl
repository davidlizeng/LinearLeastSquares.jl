x = Variable(4, 3)
y = Variable()

x + y == 3
3 == y
rand(4, 3) == x - 4*y
sum(y, 1) == rand(1, 3)

info("All equality constraints tests passed")
