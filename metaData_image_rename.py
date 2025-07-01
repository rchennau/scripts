import os
import exifread
import re
from datetime import datetime
import argparse
import cv2  # For image analysis
from PIL import Image  # For image format detection (install: pip install Pillow)

def describe_image(image_path):
    """Analyzes an image and returns a description."""
    try:
        img = cv2.imread(image_path)  # Read the image using OpenCV
        if img is None:  # Check if image was read successfully
            return "Error: Could not read image."

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)  # Convert to grayscale for simpler analysis
        edges = cv2.Canny(gray, 100, 200)  # Edge detection

        num_edges = cv2.countNonZero(edges)  # Count the number of edge pixels

        description = f"Image Analysis:\n"  # Start building the description string
        description += f"  - Dimensions: {img.shape}\n"  # Add image dimensions (height, width, channels)
        description += f"  - Grayscale image\n"  # Indicate grayscale conversion
        description += f"  - Edge Count: {num_edges}\n"  # Add edge count

        # Basic color analysis (you can expand on this):
        average_color = cv2.mean(img)  # Average BGR values
        description += f"  - Average Color (BGR): {average_color}\n"  # Add average color

        # You can add more sophisticated analysis here (e.g., object detection, etc.)

        return description  # Return the description string

    except Exception as e:
        return f"Error during image analysis: {e}"  # Return error message if analysis fails


def extract_metadata_and_rename(image_dir, output_dir, date_format, output_metadata):
    """Extracts metadata, renames based on creation time, and saves."""

    if not os.path.exists(output_dir):  # Create output directory if it doesn't exist
        os.makedirs(output_dir)
    if output_metadata and not os.path.exists(output_metadata):  # Create metadata directory if needed
        os.makedirs(output_metadata)

    file_counter = 1  # Initialize file counter for renaming

    for filename in os.listdir(image_dir):  # Iterate through all files in the input directory
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')):  # Check for image file extensions
            image_path = os.path.join(image_dir, filename)  # Construct the full image path

            try:
                creation_time_str = None  # Initialize creation time string
                metadata_info = {}  # Dictionary to store metadata

                # 1. EXIF Tags (for JPEGs and TIFFs):
                if filename.lower().endswith(('.jpg', '.jpeg', '.tiff')):  # Only check EXIF for these file types
                    try:  # Try to open and read the file (handle potential errors)
                        with open(image_path, 'rb') as f:  # Open in binary read mode for exifread
                            tags = exifread.process_file(f)  # Extract EXIF tags
                        for tag_name, tag_value in tags.items():  # Iterate through EXIF tags
                            metadata_info[tag_name] = tag_value.printable  # Store all EXIF tags
                        for tag_name in ['EXIF DateTimeOriginal', 'EXIF DateTimeDigitized', 'Image DateTime']:  # Check for relevant date tags
                            if tag_name in tags:
                                creation_time_str = tags[tag_name].printable  # Get creation time from EXIF
                                break  # Stop searching after finding the first date tag
                    except Exception as e:
                        print(f"Error reading EXIF data from {filename}: {e}")  # Print error message if EXIF reading fails

                # 2. Filename (if not found in EXIF or for PNGs, etc.):
                if creation_time_str is None:  # If creation time not found in EXIF
                    match = re.search(r'\d{8}', filename)  # Look for 8-digit date (YYYYMMDD) in filename
                    if match:
                        creation_time_str = match.group(0)  # Extract the date string
                        metadata_info['Filename Date'] = creation_time_str  # Add the date to metadata

                if creation_time_str:  # If creation time was found (either in EXIF or filename)
                    try:
                        date_obj = None  # Initialize date object
                        fmts = ["%Y:%m:%d %H:%M:%S", "%Y%m%d", "%Y-%m-%d %H:%M:%S", date_format]  # Define possible date formats
                        for fmt in fmts:  # Try different date formats
                            try:
                                date_obj = datetime.strptime(creation_time_str, fmt)  # Parse the date string
                                break  # Stop trying formats after successful parsing
                            except ValueError:  # If parsing fails, try the next format
                                pass

                        if date_obj:  # If date object was successfully created
                            new_filename = f"{date_obj.strftime('%Y%m%d')}_{file_counter:06d}{os.path.splitext(filename)}"  # Create new filename
                            new_path = os.path.join(output_dir, new_filename)  # Create full path for renamed file
                            os.rename(image_path, new_path)  # Rename the file
                            print(f"Renamed: {filename} to {new_filename}")  # Print renaming message

                            # Output metadata to a file (if requested):
                            if output_metadata:  # If output_metadata directory was specified
                                metadata_filename = f"{os.path.splitext(new_filename)}.txt"  # Create metadata filename
                                metadata_path = os.path.join(output_metadata, metadata_filename)  # Create full path for metadata file
                                with open(metadata_path, 'w') as outfile:  # Open metadata file for writing
                                    for key, value in metadata_info.items():  # Write metadata to file
                                        outfile.write(f"{key}: {value}\n")
                                print(f"Metadata saved to: {metadata_path}")  # Print metadata saving message

                            file_counter += 1  # Increment the file counter
                        else:
                            print(f"Could not parse date format in {filename}: {creation_time_str}")  # Print message if date parsing failed

                    except ValueError as e:
                        print(f"Error parsing date in {filename}: {e} - Date string: {creation_time_str}")  # Print error message if date parsing fails

                else:  # No creation time found (EXIF or filename)
                    print(f"No creation time information found in {filename}. Analyzing image...")  # Print message indicating image analysis
                    image_description = describe_image(image_path)  # Analyze the image
                    metadata_info['Image Description'] = image_description  # Add the description to the metadata

                    # Generate filename based on counter if no date:
                    new_filename = f"unknown_date_{file_counter:06d}{os.path.splitext(filename)}"  # Create filename with "unknown_date"
                    new_path = os.path.join(output_dir, new_filename)  # Create full path
                    os.rename(image_path, new_path)  # Rename the file
                    print(f"Renamed: {filename} to {new_filename}")

                    if output_metadata: # If output_metadata directory was specified
                        metadata_filename = f"{os.path.splitext(new_filename)}.txt" # Create metadata filename
                        metadata_path = os.path.join(output_metadata, metadata_filename) # Create full path for metadata file
                        with open(metadata_path, 'w') as outfile: # Open metadata file for writing
                            for key, value in metadata_info.items(): # Write metadata to file
                                outfile.write(f"{key}: {value}\n")
                        print(f"Metadata saved to: {metadata_path}") # Print metadata saving message

                    file_counter += 1 # Increment the file counter

            except Exception as e:
                print(f"Error processing {filename}: {e}")  # Print error message if processing fails

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Rename images based on date metadata.")  # Create argument parser
    parser.add_argument("input_dir", help="The input directory containing images.")  # Add input directory argument
    parser.add_argument("output_dir", help="The output directory for renamed images.")  # Add output directory argument
    parser.add_argument("-f", "--date_format", default="%Y:%m:%d %H:%M:%S", help="Date format string (strftime format).")  # Add date format argument
    parser.add_argument("-m", "--output_metadata", help="Directory to save metadata files (optional).")  # Add metadata output directory argument

    args = parser.parse_args()  # Parse the command-line arguments

    extract_metadata_and_rename(args.input_dir, args.output_dir, args.date_format, args.output_metadata)  # Call the main function with the arguments
