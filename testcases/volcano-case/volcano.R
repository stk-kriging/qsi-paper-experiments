## volcano.R

##### Inputs variables #####
#
# xs:  X location of source UTM coordinates           [m]
# ys:  Y location of source UTM coordinates           [m]
# zs:  Elevation of source with respect to sea level  [m]
#  a:  Source radius                                  [m]
#  p:  Source overpressure                            [MPa]

## Number of input variables
x_dim = 5
s_dim = 2

## Name -> index
n2i <- list(xs=1, ys=2, zs=3, a=4, p=5)

## Index -> name
varnames <- c("xs", "ys", "zs", "a", "p")

## Some special points in the input space
xstar <- c(367000, 7650300,     0,  500,   20)  # Optimum (exact?)
xmin  <- c(364000, 7649000, -3000,   50, -500)  # Min values
xmax  <- c(368000, 7651000, -1000, 1000,  500)  # Max values

## Always useful stuff
Glb_var <<- list(n2i=n2i, x_dim=x_dim, xmax=xmax, xmin=xmin)


####### Load data ###########

data = read.table(file="data_nonoise.csv")

Glb_xyzi <<- list(
  x = as.matrix(data$x),
  y = as.matrix(data$y),
  z = as.matrix(data$z))

Glb_ulos <<- as.matrix(data$ulos)


##### Calculate data covariance matrix #####

# # calculate data Covariance matrix, store it in a Global variable
# # covariance from exponential kernel, var = 5e-4m2, cor_length = 850 m
# # and invert it
# Xdata <- as.matrix (data[,c("x", "y")])  # z's are not accounted for in Xdata
# 
# Glb_CXinv <<- solve(kExp(Xdata,Xdata,c(5e-4,850,850))) # calculated once for all, used in wls_ulos
# 
# rm(Xdata)
rm(data)

#######  useful functions #############################
# Scale from [0 1] to [xmin xmax]
unnorm_var <- function(Xnorm){
  if (is.null(dim(Xnorm))) Xnorm <- matrix(data = Xnorm, nrow=1) # numeric vector
  nbrep <- nrow(Xnorm)
  Xu <- matrix(rep(xmin,times=nbrep),byrow = T,ncol=x_dim) + 
    Xnorm * matrix(rep((xmax-xmin),times=nbrep),byrow = T,ncol=x_dim)
  colnames(Xu) <- varnames
  return(Xu)
}

# Scale from [xmin xmax] to [0 1] 
norm_var <- function(X){
  if (is.null(dim(X))) X <- matrix(data = X, nrow=1)
  nbrep <- nrow(X)
  Xn <- (X - matrix(rep(xmin,times=nbrep),byrow = T,ncol=x_dim)) / 
    matrix(rep((xmax-xmin),times=nbrep),byrow = T,ncol=x_dim)  
  colnames(Xn) <- varnames
  return(Xn)
}

# # normalize the output so that it is centered with a unit std dev
# # because wls ranges from 0 to 10^9, do a scaling in log(1+wls)
# # wls normalization
# normalizeWLS <- function(awls){
#   lawls <- log(1+awls)
#   return((lawls - 8.54)/3.2)
# }

# objective function
compute_gof <- function(x, s)
{
  if((!is.matrix(x)) || (!is.matrix(s)))
    stop("x and s must be matrices.")
  
  if(ncol(x) != x_dim)
    stop("x should have ", x_dim, " columns")
  if(ncol(s) != s_dim)
    stop("s should have ", s_dim, " columns")

  if(nrow(x) != nrow(s))
    stop("x and s should have the same number of rows")

  ## Concatenate x and s
  xs <- cbind(unnorm_var(Xnorm=x), s)
  
  ## Compute goodness-of-fit criterion
  J <- apply(xs, 1, gofcrit_ulos)
  
  return(J)
}


## Weighted Least Squares distance function for ulos vectors

gofcrit_ulos <- function(xs)
{
  ## Compute ulos using the model
  ulos  = compute_ulos(xs)
  
  ## Compute goodness-of-fit criterion
  # gof = t((ulos-Glb_ulos))%*%Glb_CXinv%*%(ulos-Glb_ulos)
  # gof = sum((ulos - Glb_ulos)**2)
  gof = mean(abs((ulos - Glb_ulos)))
  return(gof)
}

compute_ulos <- function(xs)
{
  xx = xs[1:x_dim]
  s = xs[(x_dim+1):(x_dim+s_dim)] 
    
  ## The covariance matrix is passed through global variable 
  ## xs,ys,zs,a and p come from the variables xx
  
  G = 2000 + (s[1] * 2 - 1) * 100   # Shear modulus in MPa
  nu = 0.25 + (s[2] * 2 - 1) * 0.3  # Poisson's ratio
  
  ## vector of direction of line of sight (satellite)
  nlos = c(-0.664,-0.168,0.728)
  
  n2i <- Glb_var$n2i
  
  ## Compute surface displacements
  U <- mogi_3D(G, nu, xx[n2i$xs], xx[n2i$ys], xx[n2i$zs],
               xx[n2i$a], xx[n2i$p], Glb_xyzi)
  
  ## project along LoS
  ulos <- nlos[1]*U$x+nlos[2]*U$y+nlos[3]*U$z
  
  return(ulos)  
}


## Compute surface displacements and tilts

mogi_3D <- function(G,nu,xs,ys,zs,a,p,xyzi)
{
  ##
  ## MOGI(G,nu,xs,ys,zs,a,p,xi,yi,zi) compute surface displacements and tilts created by
  ## a point source located beneath a topography. To account for topography, a
  ## first order solution in which the actual source to ground surface point
  ## is taken into account
  ## 
  ## [uxi,uyi,uzi]=mogi_3D(G,nu,xs,ys,zs,a,p,xi,yi,zi)
  ## Parameters are 
  ## G = shear modulus in MPa, G = E/2(1+nu)
  ## nu = Poisson's ratio
  ## xs, ys, zs = source position (z axis is positive upward),
  ## a = source radius, p = source overpressure in MPa, 
  ## xi, yi, zi = location of ground surface points
  ##
  ## V. Cayol, LMV, sept 2017
  ## (translated into R by R. Le Riche)
  
  DV=pi*a^3*p/G
  C=(1-nu)*DV/pi
  
  xi = xyzi$x
  yi = xyzi$y
  zi = xyzi$z
  
  r = sqrt((xi-xs)^2+(yi-ys)^2)
  f = r^2+(zi-zs)^2
  uzi = C*(zi-zs)/(f^(3/2))
  ur = C*r/(f^(3/2))
  theta = atan2(yi-ys,xi-xs)
  uxi = ur*cos(theta)
  uyi = ur*sin(theta)
  
  U = list(x=uxi,y=uyi,z=uzi)
  return(U)
}
