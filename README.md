###############################################################################
Copyright (C) 2018 M. Schaub

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

###############################################################################

This repository contains some simple example code for the dynamical network embedding discussed as discussed in:

Schaub MT, Delvenne J-C, Lambiotte R and Barahona M (2018), "Multiscale Dynamical Embeddings of Complex Networks"
https://arxiv.org/abs/1804.03733, April, 2018.

The embedding is implemented in julia (https://julialang.org/).
To recreate the example of Figure 3A in the above publication, run the script createFigurePlot.jl in julia.
For recreating the ranking diagram of Figure 3B, use the python plotting code provided.

If you are looking for a generalized variant of the Louvain algorithm to find partitions based on dynamical similarities, please see:
https://github.com/michaelschaub/generalizedLouvain


Please note that the data used here was originally collected in:

A. Clauset, S. Arbesman, and D. B. Larremore, "Systematic inequality and hierarchy in faculty hiring networks." Science Advances 1(1), e1400005 (2015).

and can be downloaded here
http://tuvalu.santafe.edu/~aaronc/facultyhiring/

***Please make sure to appropriate citations when using the data and/or the above code. Thanks.***
