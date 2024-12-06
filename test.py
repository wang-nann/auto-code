import subprocess
queue = subprocess.run("squeue", shell=True, stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8",timeout=1)

print(queue)
