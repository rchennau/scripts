import os
import argparse

def get_directory_size(directory, unit="B"):
    """
    Calculates the total size of a directory and its contents.

    Args:
        directory (str): The directory path.
        unit (str, optional): The desired unit for size ("B", "K", "M", "G"). Defaults to "B" (bytes).

    Returns:
        float: The total size of the directory in the specified unit.
    """
    try:
        total_size_bytes = 0
        for root, _, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                try:
                    total_size_bytes += os.path.getsize(filepath)
                except OSError:
                    print(f"Could not access: {filepath}") #Handles permission issues

        size_multiplier = {
            "B": 1,
            "K": 1024,
            "M": 1024 * 1024,
            "G": 1024 * 1024 * 1024
        }.get(unit.upper())

        if not size_multiplier:
            raise ValueError("Invalid unit provided. Must be B, K, M or G")
        return total_size_bytes / size_multiplier

    except ValueError as e:
        print(f"Error: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Calculate the size of a directory.")
    parser.add_argument("directory", help="The directory to calculate the size of.")
    parser.add_argument("-u", "--unit", type=str, default="B", choices=["B", "K", "M", "G"],
                        help="Unit for size (default: B for bytes)")

    args = parser.parse_args()

    size = get_directory_size(args.directory, args.unit)

    if size is not None:
        print(f"Total size of '{args.directory}': {size:.2f}{args.unit.upper()}")
    else:
         print("Could not retrieve the total size.")

if __name__ == "__main__":
    main()
