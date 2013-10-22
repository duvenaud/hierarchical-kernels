# Converts numpy to matlab
#
# David Duvenaud
# Oct 2013


import numpy as np
import os
import scipy.io

numpy_dir = 'numpy/'

for file in os.listdir(numpy_dir):
	data = np.load(numpy_dir + file)
	print data
	scipy.io.savemat( 'matlab/arcnet/' + file.rsplit( ".", 1 )[ 0 ] + '.mat', data)

