import subprocess
import glob
import os
import datetime
import sys
import random

args =sys.argv
frame_rate = 30

if len(args) > 1:
        frame_rate = args[1]
else:
        frame_rate = 30 
        
movie_name = "out.mp4"
filenames = glob.glob('*.png')
path = os.path.abspath("").replace("\\", "/")
current_date = datetime.datetime.now().strftime("%Y-%m-%d")
base_name, extension = movie_name.split(".")
new_filename = f"{base_name}_{current_date}.{extension}"
ran_num = random.randint(100,500)
print(path)
duration = 0.1

with open("ffmpeg_input.txt", "wb") as outfile:
        for filename in filenames:
                    outfile.write(f"file '{path}/{filename}'\n".encode())
                    outfile.write(f"duration {duration}\n".encode())
print(outfile)
command_line = f"ffmpeg -r {frame_rate} -f concat -safe 0 -i ffmpeg_input.txt -c:v libx265 -pix_fmt yuv420p -fps_mode cfr {path}\\{new_filename}"
print(command_line)

pipe = subprocess.Popen(command_line, shell=True, stdout=subprocess.PIPE).stdout
output = pipe.read().decode()
pipe.close()

#### Add interpolation via ffmpeg ####
# command_line = f"ffmpeg -i {path}\\{new_filename} -filter:v minterpolate=fps={frame_rate}:mi_mode=mci -r {frame_rate} {path}\\{ran_num}-{new_filename}"
command_line = f"ffmpeg -i {path}\\{new_filename} -filter:v minterpolate=fps=120:mi_mode=mci -r {frame_rate} {path}\\{ran_num}-{new_filename}"
print(command_line)
pipe = subprocess.Popen(command_line, shell=True, stdout=subprocess.PIPE).stdout
output = pipe.read().decode()
pipe.close()
#
input_name = "ffmpeg_input.txt"
os.remove(input_name)
