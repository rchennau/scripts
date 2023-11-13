import os
import subprocess
import argparse

interpolateDir = "interpolated"

def process_files(directory, script):
    files = os.listdir(directory)
    output = files[0] if files else None

    for i in range(0, len(files) - 1):
        interpolated_file_path = f"{i}-{files[i+1]}"
        
        os.makedirs(os.path.join(os.path.dirname(directory), interpolateDir), exist_ok=True)

        file_path1 = os.path.join(directory, output)
        file_path2 = os.path.join(directory, files[i+1])

        # command_line = f"python -m {script} --frame1 {file_path1} --frame2 {file_path2} --model_path pretrained_models/film_net/Style/saved_model --output_frame {os.path.join(directory,interpolateDir,interpolated_file_path)}"
        command_line = f"python -m eval.interpolator_test --frame1 {file_path1} --frame2 {file_path2} --model_path pretrained_models/film_net/Style/saved_model --output_frame {os.path.join(directory,interpolateDir,interpolated_file_path)}"
        print(f"Iteration {i}\nCommand: {command_line}\n")

        result = subprocess.run(command_line, shell=True, stderr=subprocess.STDOUT)

        output = files[i+1]

    print("Done!")
    
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Pyton script to iterate over images in a directory and interpolate them")
    parser.add_argument('--dir', type=str, default='./', help='the directory containing images')
    parser.add_argument('--script', type=str, default='eval.interpolator_test', help='the script to run for interpolation')
    parser.add_argument('--debug', action='store_true', help='Print debug information')

    args = parser.parse_args()

    if args.debug: 
        print(f"Processing images in {args.dir} with script {args.script}")

    process_files(args.dir, "interpolator_test.py")