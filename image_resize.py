from PIL import Image
import os
import argparse


def resize_images(directory, size):
    for filename in os.listdir(directory):
        if filename.endswith('.jpg') or filename.endswith('.png'):
            img = Image.open(os.path.join(directory, filename))
            img = img.resize((size, size), Image.ADAPTIVE)
            print(f"Image {filename} resized to {size}")
            img.save(os.path.join(directory, filename))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Pyton script to resize images in a directory")
    parser.add_argument('--size', type=int, default=768, help='the size of the new image')
    parser.add_argument('--dir', type=str, default='./', help='the directory containing images')
    parser.add_argument('--debug', action='store_true', help='Print debug information')

    args = parser.parse_args()

    if args.debug: 
        print(f"Resizing images in {args.dir} to {args.size}")
    resize_images(args.dir, args.size)
