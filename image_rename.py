import os
import datetime
import glob

def rename_files(directory):
    """
    Renames PNG files in a directory with the format: YYYY-MM-DD_NNNNNN.png
    where:
        YYYY-MM-DD is the file creation date.
        NNNNNN is a six-digit sequential number.
    """

    png_files = glob.glob(os.path.join(directory, "*.png"))

    if not png_files:
        print("No PNG files found in the specified directory.")
        return

    counter = 1

    for file_path in png_files:
        # Get file creation date (works on Windows, macOS, and Linux)
        creation_timestamp = os.path.getctime(file_path)
        creation_date = datetime.datetime.fromtimestamp(creation_timestamp)
        date_string = creation_date.strftime("%Y-%m-%d")

        # Create the new filename
        new_filename = f"{date_string}_{counter:06d}.png"
        new_file_path = os.path.join(directory, new_filename)

        # Check for potential filename collisions *before* renaming
        while os.path.exists(new_file_path):
            counter += 1
            new_filename = f"{date_string}_{counter:06d}.png"
            new_file_path = os.path.join(directory, new_filename)

        # Rename the file
        try:
            os.rename(file_path, new_file_path)
            print(f"Renamed '{os.path.basename(file_path)}' to '{new_filename}'")
            counter +=1
        except OSError as e:
            print(f"Error renaming '{os.path.basename(file_path)}': {e}")
            # Consider adding more robust error handling (e.g., logging, skipping)

if __name__ == "__main__":
    # Get the directory from the user.  Use a raw string (r"") for Windows paths.
    target_directory = input("Enter the directory containing the PNG files: ")

    # Check if the directory exists
    if os.path.isdir(target_directory):
        rename_files(target_directory)
    else:
        print(f"Error: The directory '{target_directory}' does not exist.")
