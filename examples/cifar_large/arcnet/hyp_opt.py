"""Optimizes hyperparameters of Deepnet models using Gaussian Processes."""
import numpy as np
import sys, os.path
import math
import time
import os
import copy
from deepnet import trainer

def ModifyHyperparameters(model, params):
  depth = int(params['depth'][0])
  print 'Training a model with depth %s' % depth

  hidden_layer = model.layer[-1]
  hidden_edge = model.edge[-1]
  del model.layer[-1]
  del model.edge[-1]
  
  hidden_layers = []
  hidden_edges = []
  for i in range(1,depth+1):
    hidden_layers.append(copy.deepcopy(hidden_layer))
    hidden_edges.append(copy.deepcopy(hidden_edge))

    hidden_layers[-1].name = 'hidden%d' % i

    if i == 1:
      model.edge[0].node1 = 'input_layer'
      model.edge[0].node2 = 'hidden%d' % i

    hidden_edges[-1].node1 = 'hidden%d' % i
    hidden_edges[-1].node2 = 'hidden%d' % (i+1)

    if i == depth:
      hidden_edges[-1].node2 = 'output_layer'

  model.layer.extend(hidden_layers)
  model.edge.extend(hidden_edges)

  log_base_epsilon = params['log_base_epsilon']
  weight_norm      = params['weight_norm']
  num_units        = 100*params['num_units']
  #dropouts         = params['dropout']

  for i,edge in enumerate(model.edge):
    edge.hyperparams.base_epsilon = np.exp(log_base_epsilon[i])
    edge.hyperparams.weight_norm = weight_norm[i]

  i = 0
  j = 0
  for layer in model.layer:
    if layer.name != 'output_layer':
      layer.hyperparams.dropout = False
      #layer.hyperparams.dropout_prob = dropouts[j]
      j = j + 1
    else:
      layer.hyperparams.dropout = False
    if layer.name != 'input_layer' and layer.name != 'output_layer':
      layer.dimensions = int(num_units[i])
      i = i + 1
  
  print 'Setting params to %s' % params
  print 'New model is\n%s' % model
  return model

def GetTestEntropy(net):
  entropy_best = None
  for stat in net.net.test_stats:
    entropy = stat.cross_entropy / stat.count
    if entropy_best is None or entropy_best > entropy:
      entropy_best = entropy
  return entropy_best

def GetLastValidationError(net):
  stat = net.net.validation_stats[-1]
  verr = 1 - (float(stat.correct_preds) / stat.count)
  return verr

def GetBestValidationError(net):
  verr_best = None
  print net.net.validation_stats
  for stat in net.net.validation_stats:
    verr = 1 - (float(stat.correct_preds) / stat.count)
    if verr_best is None or verr_best > verr:
      verr_best = verr
  return verr_best


def main(job_id, params):
  board = trainer.LockGPU()
  prefix = os.getcwd()
  model_file = os.path.join(prefix, 'deepnet_base.pbtxt')
  train_op_file = os.path.join(prefix, 'train.pbtxt')
  eval_op_file = os.path.join(prefix, 'eval.pbtxt')
  model, train_op, eval_op = trainer.LoadExperiment(model_file, train_op_file,
                                                    eval_op_file)
  model.name = 'deepnet_%d' % job_id
  ModifyHyperparameters(model, params)
  net = trainer.CreateDeepnet(model, train_op, eval_op)
  net.Train()
  trainer.FreeGPU(board)
  value = GetLastValidationError(net)

  return value

def hyp_test():
  prefix = os.getcwd()
  model_file = os.path.join(prefix, 'deepnet_base.pbtxt')
  train_op_file = os.path.join(prefix, 'train.pbtxt')
  eval_op_file = os.path.join(prefix, 'eval.pbtxt')
  model, train_op, eval_op = trainer.LoadExperiment(model_file, train_op_file,
                                                    eval_op_file)
  # params = {'depth'            : np.array([3.]),
  #           'num_units'        : np.array([1,2,3,4,5]),
  #           'log_base_epsilon' : np.array([0.1,0.2,0.3,0.4,0.5,0.6]),
  #           'weight_norm'      : np.array([1.,2.,3.,4.,5.,6.]),
  #           'dropout'          : np.array([0.1,0.2,0.3,0.4,0.5,0.6])}

  params = {'depth'            : np.array([3.]),
            'num_units'        : np.array([1,2,3,4,5]),
            'log_base_epsilon' : np.array([0.1,0.2,0.3,0.4,0.5,0.6]),
            'weight_norm'      : np.array([1.,2.,3.,4.,5.,6.])}

  model.name = 'deepnet_test'
  ModifyHyperparameters(model, params)
  print model
  verr = main(1,params)
  print 'Validation error: %s' % verr

if __name__ == '__main__':
  hyp_test()
