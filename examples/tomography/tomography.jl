using LSQ

line_mat_x = readdlm("tux_sparse_x.txt");
line_mat_y = readdlm("tux_sparse_y.txt");
line_mat_val = readdlm("tux_sparse_val.txt");
line_vals = readdlm("tux_sparse_lines.txt");

# Form the sparse matrix from the data
# Image is 50 x 50
img_size = 50
# The number of pixels in the image
num_pixels = img_size * img_size

line_mat = spzeros(3300, num_pixels);

num_vals = length(line_mat_val)

for i in 1:num_vals
  x = int(line_mat_x[i]);
  y = int(line_mat_y[i]);
  line_mat[x + 1, y + 1] = line_mat_val[i];
end

x = Variable(num_pixels)
objective = sum_squares(line_mat * x - line_vals);
p = minimize(objective);
solve!(p)

import PyPlot.plt
import PyPlot.cm
plt.imshow(reshape(x.value, img_size,img_size), cmap = get_cmaps()[29]
