import numpy as np
from scipy.interpolate import interpn

# Define two images
image1 = np.random.rand(188, 188)
image2 = np.random.rand(188, 188)

# Construct 3D volume from images
arr = np.stack([image1, image2])

# Define the interpolation points
z = np.array([0, 1])

# Define the points to interpolate at
z_new = np.linspace(0, 1, 11)

# Construct the meshgrid
X, Y, Z = np.meshgrid(np.arange(188), np.arange(188), z)
X_new, Y_new, Z_new = np.meshgrid(np.arange(188), np.arange(188), z_new)

# Interpolate the data
interpolated_data = interpn((Z, Y, X), arr, (Z_new, Y_new, X_new))

# The interpolated data is a 4D array with shape (11, 188, 188, 1)
# You can access the interpolated images using the following code:
interpolated_image1 = interpolated_data[0, :, :, 0]
interpolated_image2 = interpolated_data[-1, :, :, 0]