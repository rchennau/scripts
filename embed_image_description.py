import os
import png  # For PNG reading/writing (install: pip install pypng)
from PIL import Image  # For image format detection (install: pip install Pillow)
from transformers import BlipProcessor, BlipForConditionalGeneration  # For image captioning (install: pip install transformers)

# Load the BLIP image captioning model and processor
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

def describe_image_local(image_path):
    """Describes an image using the local BLIP model."""
    try:
        image = Image.open(image_path)
        inputs = processor(images=image, return_tensors="pt")
        generated_ids = model.generate(**inputs)
        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)
        return generated_text
    except Exception as e:
        return f"Error during local image description: {e}"


def embed_metadata_in_png(image_path, metadata_text, output_path):
    """Embeds metadata text as a tEXt chunk in a PNG image."""
    try:
        with open(image_path, 'rb') as f:
            png_reader = png.Reader(file=f)
            width, height, rows, metadata = png_reader.read_and_parse()

        # Create a new metadata dictionary or update the existing one
        new_metadata = metadata.copy() if metadata else {}
        new_metadata['Description'] = metadata_text.encode('utf-8')

        # Write the modified PNG back to the output path
        with open(output_path, 'wb') as f:
            png_writer = png.Writer(width, height, metadata=new_metadata)
            png_writer.write_rows(f, rows)

        print(f"Metadata embedded in: {output_path}")

    except Exception as e:
        print(f"Error embedding metadata in PNG: {e}")


if __name__ == "__main__":
    image_path = input("Enter the path to the PNG image: ")
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
    else:
        image_description = describe_image_local(image_path)  # Use local model

        if "Error" not in image_description:
            print(f"Image description: {image_description}")  # Output to standard out
            output_path = input("Enter the path to save the modified image: ")
            embed_metadata_in_png(image_path, image_description, output_path)
        else:
            print(image_description)
