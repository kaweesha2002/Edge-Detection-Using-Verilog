import cv2
import numpy as np
import os

base_path = os.path.dirname(os.path.abspath(__file__)) # dynamic path identification

img_color = cv2.imread(os.path.join(base_path, "input.jpg"))
img_gray = cv2.cvtColor(img_color, cv2.COLOR_BGR2GRAY)
img_resized = cv2.resize(img_gray, (128, 128))

cv2.imwrite(os.path.join(base_path, "input_gray.jpg"), img_resized)
print("Successfully saved Grayscale input")

with open(os.path.join(base_path, "input_hex.txt"), "w") as f:
    for row in img_resized:
        for pixel in row:
            f.write(f"{pixel:02x}\n")