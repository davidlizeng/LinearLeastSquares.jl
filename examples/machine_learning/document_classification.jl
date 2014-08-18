include("MatrixMarket.jl")
using MatrixMarket
using LinearLeastSquares

# read in the data
A = full(MatrixMarket.mmread("largeCorpus.mtx"));

# extract the classes of each document
classes = A[:,1];
# TODO: modify classes so that 4 5 6 are 1 2 3
classes[classes .> 3] = classes[classes .> 3] - 3;
A = A[:, 2:end];

# split into train/test
numData = size(A, 1);
data = randperm(numData);
ind = floor(numData*0.7);
training = data[1:ind];
test = data[ind+1:end];
trainDocuments = A[training,:];
trainClasses = classes[training,:];
testDocuments = A[test,:];
testClasses = classes[test,:];

# change all other than sports to -1 (sports is 1)
holdClass = 1;
trainClasses[trainClasses .!= holdClass] = -1;
trainClasses[trainClasses .== holdClass] = 1;
testClasses[testClasses .!= holdClass] = -1;
testClasses[testClasses .== holdClass] = 1;

# build the problem and solve with LLS
lambda = 100;
w = Variable(size(A, 2));
v = Variable();
objective = sum_squares(trainDocuments * w + v - trainClasses) + lambda * sum_squares(w);
optval = minimize!(objective);

# print out the 5 words most indicative of sports and nonsports
words = String[];
f = open("largeCorpusfeatures.txt");
for i = 1:length(evaluate(w))
  push!(words, readline(f))
end
indices = sortperm(vec(evaluate(w)));
for i = 1:5
  print(words[indices[i]])
end
for i = 0:4
  print(words[indices[length(words) - i]])
end

# calculate training error
yhat = sign(trainDocuments * evaluate(w) + evaluate(v));
trainCE =  1/size(trainClasses,1)*sum(trainClasses .!= yhat)

# calculate performance of our classifier on the test set
yhat2 = sign(testDocuments * evaluate(w) + evaluate(v));
testCE = 1/size(testClasses,1)*sum(testClasses .!= yhat2)
