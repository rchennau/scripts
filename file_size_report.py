import os
import argparse

def find_large_files(directory, min_size, unit="M", exclude_dirs=None, depth=None):
    """
    Finds files in a directory (and its subdirectories) larger than a specified size,
    with an option to exclude multiple directories.

    Args:
        directory (str): The directory to start searching from.
        min_size (float): The minimum file size to consider (in the specified unit).
        unit (str): The unit for min_size ("B", "K", "M", or "G").
        exclude_dirs (list, optional): A list of directories to exclude from the search (defaults to None).
        depth (int, optional): Maximum depth to search subdirectories, or None to search all.

    Returns:
        list: A list of tuples, where each tuple contains (filepath, size_in_unit).
    """
    try:
        size_multiplier = {
            "B": 1,
            "K": 1024,
            "M": 1024 * 1024,
            "G": 1024 * 1024 * 1024
        }.get(unit.upper())

        if not size_multiplier:
            raise ValueError("Invalid unit provided. Must be B, K, M or G")

        min_size_bytes = min_size * size_multiplier
        large_files = []
        for root, dirs, files in os.walk(directory):

            if exclude_dirs:
                for exclude_dir in exclude_dirs:
                    if os.path.abspath(root).startswith(os.path.abspath(exclude_dir)):
                        dirs[:] = [] # Skip this entire directory (and its subdirectories)
                        break

            if depth is not None:
                rel_depth = root[len(directory.rstrip(os.sep)) + len(os.sep):].count(os.sep)
                if rel_depth > depth:
                    continue


            for file in files:
                filepath = os.path.join(root, file)
                try:
                    size_bytes = os.path.getsize(filepath)
                    if size_bytes >= min_size_bytes:
                        size_in_unit = size_bytes / size_multiplier
                        large_files.append((filepath, size_in_unit))
                except OSError:
                    print(f"Could not access: {filepath}")  # Handles permission issues

        return large_files
    except ValueError as e:
        print(f"Error: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Find large files in a directory.")
    parser.add_argument("directory", help="The directory to search.")
    parser.add_argument("-s", "--size", type=float, default=100, help="Minimum file size (default: 100)")
    parser.add_argument("-u", "--unit", type=str, default="M", choices=["B", "K", "M", "G"], help="Unit for file size (default: M for MB)")
    parser.add_argument("-e", "--exclude", type=str, action="append",  help="Directory to exclude from the search. Can specify multiple times.")
    parser.add_argument("-d", "--depth", type=int, default=None, help="Depth to search subdirectories (default: infinite)")


    args = parser.parse_args()

    large_files = find_large_files(args.directory, args.size, args.unit, args.exclude, args.depth)


    if large_files:
        print("Large files found:")
        for filepath, size in large_files:
            print(f"- {filepath} ({size:.2f}{args.unit.upper()})")
    else:
        print("No large files found.")

if __name__ == "__main__":
    main()
