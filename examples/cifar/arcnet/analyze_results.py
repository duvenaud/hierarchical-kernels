"""Generates all validation and test predictions."""
from deepnet import extract_neural_net_representation as ex
from deepnet import trainer as tr
from deepnet import util
import sys
import glob
import os
import numpy as np

def GetPredictions(model_file, train_op_file, output_dir, dataset='test'):
  board = tr.LockGPU()
  model = util.ReadModel(model_file)
  model.layer[0].data_field.test = '%s_data' % dataset

  train_op = util.ReadOperation(train_op_file)
  train_op.verbose = False
  train_op.get_last_piece = True
  train_op.randomize = False

  layernames = ['output_layer']
  ex.ExtractRepresentations(model_file, train_op, layernames, output_dir)
  tr.FreeGPU(board)

def ComputeErrors(pred_file, truth_file, make_html=False):
  pred = np.load(pred_file)
  truth = np.load(truth_file)

  predictions = pred.argmax(axis=1).reshape(-1, 1)
  diff = predictions - truth
  mistake_indices = diff.nonzero()[0]
  wrong_preds = len(mistake_indices)
  total_size = pred.shape[0]

  accuracy = 100.*float(wrong_preds)/total_size
  print 'Error : %.5f (%d/%d)' % (accuracy, wrong_preds, total_size)
  return predictions, truth, mistake_indices

def Usage():
  print 'python %s <model_file> <train_op_file> <output_dir>' % sys.argv[0]


def main():
  if len(sys.argv) < 3:
    Usage()
    sys.exit(0)
  model_file = sys.argv[1]
  train_op_file = sys.argv[2]
  output_dir = sys.argv[3]
  dataset = 'test'
  GetPredictions(model_file, train_op_file, output_dir, dataset=dataset)
  truth_file = '/ais/gobi3/u/nitish/svhn/rgb/shuffled_test_labels.npy'
  output_file = glob.glob(os.path.join(output_dir, dataset,
                                       'output_layer-*.npy'))[0]
  print 'Using predictions from %s' % output_file
  print 'Using truth from %s' % truth_file
  preds, targets, mistake_indices = ComputeErrors(output_file, truth_file)

if __name__ == '__main__':
  main()

