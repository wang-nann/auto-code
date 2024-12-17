###### Perhaps it is better to run this in a screen session 
import time
from handle_slurm import get_usr_status

watching_queues = ['na100-sug', 'na100-ins', 'nv100-sug', 'nv100-ins', 'na800-sug', 'na800-pcie', 'na100-40g']
limit0 = 50

interval = 20 # s

while True:
	usr_squeue_in_queue = get_usr_status('liuming')
	number_of_jobs = 0
	running = 0
	pending = 0

	for iq in watching_queues:
		# print(iq,end='\t')
		try:
			number_of_jobs += usr_squeue_in_queue[iq].shape[0]
			running += usr_squeue_in_queue[iq][usr_squeue_in_queue[iq][:,4] == 'R'].shape[0]
			pending += usr_squeue_in_queue[iq][usr_squeue_in_queue[iq][:,4] == 'PD'].shape[0]

		except Exception as error:
			#print()
			continue
			# print(error)
		#print(usr_squeue_in_queue[iq].shape[0],end='\t')
		#print(running.shape[0],end='\t')
		#print(pending.shape[0],end='\t')
		#print()
	
	print(number_of_jobs,running,pending)
	if(number_of_jobs < limit0):
		print(time.asctime(time.localtime(time.time())))

	time.sleep(interval)
	
