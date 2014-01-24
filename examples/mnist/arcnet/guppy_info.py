import gpu_lock2 as gpu
from subprocess import call
import sys

if __name__ == '__main__':
	call(['ssh','kswersky@guppy'])
	stats = gpu.nvidia_gpu_stats()
	num_available = 0
	for i in gpu.board_ids():
		if gpu.owner_of_lock(i) == '':
			num_available = num_available + 1

	print num_available
	sys.exit(num_available)