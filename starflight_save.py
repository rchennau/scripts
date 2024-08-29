import os
import time
import shutil
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from datetime import datetime
import argparse

# Define paths and configuration
# save_folder = ".\PLAY"
# backup_folder = ".\SAVE"

class SaveHandler(FileSystemEventHandler):
    def __init__(self, save_folder, backup_folder):
        self.save_folder = save_folder
        self.backup_folder = backup_folder

    def on_modified(self, event):
        if not event.is_directory and event.src_path.startswith(self.save_folder):
            timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            backup_path = f"{self.backup_folder}/{timestamp}"

            # Create the timestamped backup folder
            os.makedirs(backup_path, exist_ok=True)

            # Copy the entire SAVE folder's contents to the backup folder
            for item in os.listdir(self.save_folder):
                src = f"{self.save_folder}/{item}"
                dst = f"{backup_path}/{item}"
                if os.path.isfile(src):
                    shutil.copy2(src, dst)
                    print(f"Copied file: {item}")
                else:
                    shutil.copytree(src, dst)
                    print(f"Copied folder: {item}")
                print(f"Backup completed at {timestamp}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Save Starflight game data to a backup directory.")
    parser.add_argument('--save_dir', type=str, default='.\PLAY', help='The directory containing the save data.')
    parser.add_argument('--backup_dir', type=str, default='.\SAVE', help='The directory to store backups.')

    args = parser.parse_args()

    save_folder = args.save_dir
    backup_folder = args.backup_dir

    event_handler = SaveHandler(save_folder, backup_folder)
    observer = Observer()
    observer.schedule(event_handler, path=save_folder, recursive=False)
    observer.start()
    
    print(f"Monitoring {save_folder} for changes...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
