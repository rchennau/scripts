import os
import subprocess
import argparse
import shutil
from tqdm import tqdm
import time
import gc

interpolateDir = "interpolated"

def sorted_files_by_date(directory):
    files = os.listdir(directory)
    files.sort(key=lambda x: os.path.getctime(os.path.join(directory, x)))
    return files

def process_files(directory, script):
    files = sorted_files_by_date(directory)
    output = files[0] if files else None

    if not files:
        print("No files to process in the provided directory")
        return

    os.makedirs(os.path.join(os.path.dirname(directory), interpolateDir), exist_ok=True)

    total_steps = len(files) - 1
    progress_bar = tqdm(total=total_steps, desc="Progress:", bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt}')
    
    for i in range(0, len(files) - 1):
        interpolated_file_path = f"{i}-{files[i+1]}"
        file_path1 = os.path.join(directory, output)
        file_path2 = os.path.join(directory, files[i+1])
        target_path = os.path.join(directory, interpolateDir)

        command_line = f"python -m {script} --frame1 {file_path1} --frame2 {file_path2} --model_path pretrained_models/film_net/Style/saved_model --output_frame {os.path.join(directory,interpolateDir,interpolated_file_path)}"
        try:
            result = subprocess.run(command_line, shell=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            print(f"Error in recieved while executing the script {script}: {e}")
            return
        
        shutil.copy(file_path1, target_path) 
        shutil.copy(file_path2, target_path) 
        progress_bar.update()
        progress_bar.set_postfix({' File processed: ': file_path1}, refresh=True)
        output = files[i+1]

    print("Done!")
    progress_bar.close()    
    print('Total time take: {} seconds'.format(progress_bar.format_dict['elapsed']))

def main():
    parser = argparse.ArgumentParser(description="Pyton script to iterate over images in a directory and interpolate them")
    parser.add_argument('--dir', type=str, default='./', help='the directory containing images')
    parser.add_argument('--script', type=str, default='eval.interpolator_test', help='the script to run for interpolation')
    parser.add_argument('--debug', action='store_true', help='Print debug information')

    args = parser.parse_args()

    if args.debug: 
        print(f"Processing images in {args.dir} with script {args.script}")

    gc.collect()
    process_files(args.dir, args.script)

if __name__ == '__main__':
    main()