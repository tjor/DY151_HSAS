#---python 3.6 
import subprocess
import os
import time

result = subprocess.run(['octave','rad_functions/read_hsas_dir.m'],stdout=subprocess.PIPE)
dir = result.stdout.decode("utf-8") 
dir = dir[:-1]
print('Data DIR: ',dir)
sub_dir = [name for name in os.listdir(dir)]
print('All sub_DIR: ', sub_dir)


os.system('proc0_prepare_calibration.m')
for fd in sub_dir:
    os.system('octave proc1_calibrate.m '+ fd)
    os.system('octave proc2_L0_L1.m '+ fd)
    os.system('octave proc3_L2.m '+ fd)
    os.system('octave proc4_plot_L2.m '+ fd)
    time.sleep(2)
    print('# Done for ',fd,'!')
    


