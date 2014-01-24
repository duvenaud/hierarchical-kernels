from deepnet import util
from deepnet import visualize
import sys

m = util.ReadModel(sys.argv[1])
w = util.ParameterAsNumpy(m.edge[0].param[0])
pvh = visualize.display_convw2(w, 5, 8, 8, 1)
raw_input('Press enter.')

