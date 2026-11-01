import cv2
import numpy as np
import os

base_path = os.path.dirname(os.path.abspath(__file__)) 

img_resized = cv2.imread(os.path.join(base_path, "input_gray.jpg"), cv2.IMREAD_GRAYSCALE)

if img_resized is None:
    print("Error: input_gray.jpg not found. Run convert_grayscale.py first!")
    exit()

height, width = img_resized.shape
output_img = np.zeros((height, width), dtype=np.uint8)

for y in range(1, height - 1):
    for x in range(1, width - 1):
        gx = (int(img_resized[y-1, x+1]) + 2*int(img_resized[y, x+1]) + int(img_resized[y+1, x+1])) - \
             (int(img_resized[y-1, x-1]) + 2*int(img_resized[y, x-1]) + int(img_resized[y+1, x-1]))
        
        gy = (int(img_resized[y+1, x-1]) + 2*int(img_resized[y+1, x]) + int(img_resized[y+1, x+1])) - \
             (int(img_resized[y-1, x-1]) + 2*int(img_resized[y-1, x]) + int(img_resized[y-1, x+1]))
        
        magnitude = abs(gx) + abs(gy)
        
        if magnitude > 255:
            magnitude = 255
            
        output_img[y, x] = magnitude

with open(os.path.join(base_path, "output_ref_hex.txt"), "w") as f:
    for row in output_img:
        for pixel in row:
            f.write(f"{pixel:02x}\n")

cv2.imwrite(os.path.join(base_path, "output_ref.jpg"), output_img)
print("Successfully generated reference output")