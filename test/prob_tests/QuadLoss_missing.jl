using LowRankModels
import StatsBase: sample, Weights

# test quadratic loss

## generate data
srand(1);
m,n,k = 1000,300,3;
p = .5 # missing probability
kfit = k+1
# variance of measurement
sigmasq = .1

# coordinates of covariates
X_real = randn(m,k)
# directions of observations
Y_real = randn(k,n)

XY = X_real*Y_real;
A = XY + sqrt(sigmasq)*randn(m,n)

# missing values
M = sprand(m,n,p)
I,J = findn(M) # observed indices (vectors)
obs = [(I[a],J[a]) for a = 1:length(I)] # observed indices (list of tuples)

# and the model
losses = QuadLoss()
rx, ry = QuadReg(.1), QuadReg(.1);
glrm = GLRM(A,losses,rx,ry,kfit,obs=obs)
#scale=false, offset=false, X=randn(kfit,m), Y=randn(kfit,n));

# fit w/o initialization
@time X,Y,ch = fit!(glrm);
XYh = X'*Y;
println("After fitting, parameters differ from true parameters by $(vecnorm(XY - XYh)/sqrt(prod(size(XY)))) in RMSE\n")

# initialize
init_svd!(glrm)
XYh = glrm.X' * glrm.Y
println("After initialization with the svd, parameters differ from true parameters by $(vecnorm(XY - XYh)/sqrt(prod(size(XY)))) in RMSE\n")

# fit w/ initialization
@time X,Y,ch = fit!(glrm);
XYh = X'*Y;
println("After fitting, parameters differ from true parameters by $(vecnorm(XY - XYh)/sqrt(prod(size(XY)))) in RMSE\n")


Ahat = impute(glrm);
rmse = norm(A - Ahat) / sqrt(prod(size(A)))
println("Imputations differ from true matrix values by $rmse in RMSE")