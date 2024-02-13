# Copyright Notice
#
# Copyright (C) 2024 CentraleSupelec
#
# Authors: Julien Bect <julien.bect@centralesupelec.fr> 


args = commandArgs(trailingOnly=TRUE)

## args[1]: location of volcano.R
## args[2]: input csv file (without a header)
## args[3]: output csv file (with a header)

setwd (dirname (args[1]))

suppressMessages(source(args[1]))

data = read.csv(args[2], header=FALSE)

if(ncol(data) != 7)
  stop("Incorrect number of columns")

x = as.matrix(data[,1:x_dim])
s = as.matrix(data[,(x_dim+1):(x_dim+s_dim)])

output = data.frame(J = compute_gof(x, s))

write.csv(output, file=args[3], row.names=FALSE)
