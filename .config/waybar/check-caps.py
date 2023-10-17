import subprocess

capslock = None
if subprocess.check_output("xset q | grep LED", shell=True)[65] == 50 :
    capslock = False
if subprocess.check_output("xset q | grep LED", shell=True)[66] == 51 :
    capslock = True
print(f"capslock is : {capslock}")
