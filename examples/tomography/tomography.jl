using LinearLeastSquares
using Gadfly

line_mat_x = readdlm("tux_sparse_x.txt")
line_mat_y = readdlm("tux_sparse_y.txt")
line_mat_val = readdlm("tux_sparse_val.txt")
line_vals = readdlm("tux_sparse_lines.txt")

# Form the sparse matrix from the data
# Image is 50 x 50
img_size = 50
# The number of pixels in the image
num_pixels = img_size * img_size

line_mat = spzeros(3300, num_pixels)

num_vals = length(line_mat_val)

for i in 1:num_vals
  x = int(line_mat_x[i])
  y = int(line_mat_y[i])
  line_mat[x + 1, y + 1] = line_mat_val[i]
end

x = Variable(num_pixels)
objective = sum_squares(line_mat * x - line_vals)
optval = minimize!(objective)

rows = zeros(img_size*img_size)
cols = zeros(img_size*img_size)
for i = 1:img_size
  for j = 1:img_size
    rows[(i-1)*img_size + j] = i
    cols[(i-1)*img_size + j] = img_size + 1 - j
  end
end

p = plot(
  x=rows, y=cols, color=reshape(evaluate(x), img_size, img_size), Geom.rectbin,
  Scale.ContinuousColorScale(Scale.lab_gradient(color("black"), color("white")))
)
#draw(PNG("tomography.png", 16cm, 14cm), p)
