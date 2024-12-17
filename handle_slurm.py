import subprocess
import numpy as np
import re
import textwrap

user_name = 'liuming'


def split_with_parenthesis(string):
	# 正则表达式：匹配（）括号，且不拆分其中的内容
	pattern = r'\s+(?=(?:[^()]*\([^()]*\))*[^()]*$)'  # 匹配空格，但仅当它后面不是括号内的内容
	parts = re.split(pattern, string)
	return parts


sinfo = subprocess.run('sinfo', stdout=subprocess.PIPE,encoding="utf-8")
sinfo_output = sinfo.stdout
sinfo_words = split_with_parenthesis(sinfo_output)[:-1]
sinfo_words = np.array(sinfo_words).reshape(len(sinfo_words)//6,6)
queues = list(set(sinfo_words[1:,0]))

squeue = subprocess.run('squeue', stdout=subprocess.PIPE,encoding="utf-8")
squeue_output = squeue.stdout
squeue_words = split_with_parenthesis(squeue_output)[1:-1]
squeue_words = np.array(squeue_words).reshape(len(squeue_words)//8,8)

no_jobs = squeue_words.shape[0]-1


print("####################################################################################\n")
print('Available queues are:', textwrap.fill(' '.join(queues),50))
print('\nNumber of jobs in all queues:', no_jobs)

print("\nGeneral status")
print('queue name\ttotal\trunning\tpending')
squeue_in_queue = {}
for iq in queues:
	print('%-12s'%iq,end='\t')
	squeue_in_queue[iq] = squeue_words[squeue_words[:,1]==iq]
	print(squeue_in_queue[iq].shape[0],end='\t')
	running = squeue_in_queue[iq][squeue_in_queue[iq][:,4] == 'R']
	print(running.shape[0],end='\t')
	pending = squeue_in_queue[iq][squeue_in_queue[iq][:,4] == 'PD']
	print(pending.shape[0],end='\t')
	print()

print("\nUser %s's status"%user_name)
print('queue name\ttotal\trunning\tpending')
usr_squeue_in_queue = {}
tmp = squeue_words[squeue_words[:,3]==user_name]
for iq in queues:
	print('%-12s'%iq,end='\t')
	usr_squeue_in_queue[iq] = tmp[tmp[:,1]==iq]
	print(usr_squeue_in_queue[iq].shape[0],end='\t')
	running = usr_squeue_in_queue[iq][usr_squeue_in_queue[iq][:,4] == 'R']
	print(running.shape[0],end='\t')
	pending = usr_squeue_in_queue[iq][usr_squeue_in_queue[iq][:,4] == 'PD']
	print(pending.shape[0],end='\t')
	print()

print("\n####################################################################################")


