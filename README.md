Raiders of the Lost Architecture: Kernels for Bayesian Optimization in Conditional Parameter Spaces
====================

In practical Bayesian optimization, we must often search over structures with differing numbers of parameters.
For instance, we may wish to search over neural network architectures with an unknown number of layers.
To relate performance data gathered for different architectures, we define a new kernel for conditional parameter spaces that explicitly includes information about which parameters are relevant in a given structure.
We show that this kernel improves model quality and Bayesian optimization results over several simpler baseline kernels.


Authors
-------

Kevin Swersky - University of Toronto - (kswersky@cs.utoronto.edu)
David Duvenaud - University of Cambridge - (dkd23@cam.ac.uk)
Jasper Snoek - Harvard University - (jsnoek@seas.harvard.edu)
Frank Hutter - Freiburg University - (fh@informatik.uni-freiburg.de)
Michael A. Osborne - University of Oxford - (mosb@robots.ox.ac.uk)

[Preprint](http://mlg.eng.cam.ac.uk/duvenaud/papers/arc-kernel-workshop.pdf)




