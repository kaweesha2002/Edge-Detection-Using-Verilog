import cv2
import numpy as np
import os

base_path = os.path.dirname(os.path.abspath(__file__))

pixels = []
with open(os.path.join(base_path, "output_sim_hex.txt"), "r") as f:
    for line in f:
        pixels.append(int(line.strip(), 16))

verilog_image = np.array(pixels, dtype=np.uint8).reshape((128, 128))

cv2.imwrite(os.path.join(base_path, "output_from_verilog.jpg"), verilog_image)
print("Open 'output_from_verilog.jpg' in your folder to see edge detection results")