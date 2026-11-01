# 🖼️ Hardware-Accelerated Sobel Edge Detection & VGA Display

> A complete hardware/software co-design project implementing a $3 \times 3$ **Sobel Edge Detection Filter** in **Verilog HDL** on the **Basys3 FPGA**, featuring an automated Python verification pipeline and real-time VGA monitor output.

---

## 📌 Project Overview

This project implements real-time image processing acceleration directly on FPGA hardware:
* **Software Pipeline (Python):** Preprocesses raw images into 8-bit hex arrays and computes a software "Golden Reference" for 100% mathematical verification.
* **Hardware RTL (Verilog):** Calculates horizontal ($G_x$) and vertical ($G_y$) Sobel gradient convolutions with 8-bit saturation clamping.
* **FPGA VGA Display (Basys3):** Preloads processed edge data into FPGA Block RAM (BRAM) and drives a centered $128 \times 128$ image on a $640 \times 480$ @ 60Hz VGA display using a custom $25\text{ MHz}$ pixel clock controller.

---

## 🏗️ System Architecture

```text
                                    +----------------------------------------+
                                    |         Python Preprocessing           |
                                    |  input.jpg ──► convert_grayscale.py    |
                                    +-------------------┬--------------------+
                                                        │
                                                        ▼
                                                [ input_hex.txt ]
                                                        │
                                                        ▼
+---------------------------------------------------------------------------------------------------+
|                                  Vivado RTL Simulation & FPGA                                     |
|                                                                                                   |
|   [ 100MHz Clk ] ──► [ Clock Divider ] ──► 25MHz Pixel Clock                                      |
|                                                    │                                              |
|   [ BRAM (16KB) ] ──► [ Sobel Filter Core ] ──► [ VGA Controller ] ──► Basys3 Resistor DAC ──► VGA |
+---------------------------------------------------------------------------------------------------+
                                                        │
                                                        ▼
                                             [ output_sim_hex.txt ]
                                                        │
                                                        ▼
                                    +----------------------------------------+
                                    |         Software Verification          |
                                    |  view_output.py ──► output_from_verilog|
                                    +----------------------------------------+
```

---

## 📂 Repository & Deliverables Summary

| File / Module | File Type | Function / Purpose |
| :--- | :--- | :--- |
| `convert_grayscale.py` | Python Script | Resizes `input.jpg` to $128 \times 128$ grayscale and generates `input_hex.txt`. |
| `generate_sobel_ref.py` | Python Script | Computes software baseline reference (`output_ref_hex.txt` & `output_ref.jpg`). |
| `view_output.py` | Python Script | Converts Vivado simulation hex output into `output_from_verilog.jpg`. |
| `sobel_filter.v` | Verilog Design | $3 \times 3$ Sobel matrix gradient computation and saturation logic. |
| `tb_sobel.v` | Verilog Testbench | Behavioral testbench iterating image memory and dumping `output_sim_hex.txt`. |
| `vga_controller.v` | Verilog Design | Generates $640 \times 480$ @ 60Hz VGA timing sync signals (`hsync`, `vsync`, coordinates). |
| `top_basys3.v` | Verilog Top Module | Integrates Clock Divider, BRAM storage, screen centering, and RGB mapping. |
| `basys3_vga.xdc` | Xilinx Constraints | Physical pin mappings for Basys3 clock, reset button, and 14-pin VGA connector. |

---

## ⚡ Step-by-Step Execution Guide

### **STEP 1: Place Your Image**
Place your source image in the root directory and name it exactly:
```text
input.jpg
```

### **STEP 2: Preprocess Image**
Run the conversion script to resize to $128 \times 128$ and format to hexadecimal data:
```bash
python convert_grayscale.py
```
*Creates `input_gray.jpg` and `input_hex.txt`.*

### **STEP 3: Generate Software Golden Reference**
Run the reference script to calculate the software baseline:
```bash
python generate_sobel_ref.py
```
*Outputs `output_ref_hex.txt` and `output_ref.jpg`.*

### **STEP 4: Run Vivado Behavioral Simulation**
1. Open the Xilinx Vivado project located inside the `sobelfilter/` directory.
2. Launch **Behavioral Simulation**.
3. In the **Tcl Console**, execute:
   ```tcl
   run all
   ```
*Generates `output_sim_hex.txt` upon testbench completion at $79,390\text{ ns}$.*

### **STEP 5: Verify & View Hardware Output**
Run the reconstruction script to convert the hardware simulation output back into an image:
```bash
python view_output.py
```
*Generates `output_from_verilog.jpg` (verifiable line-by-line against `output_ref_hex.txt`).*

### **STEP 6: FPGA Program & VGA Display**
1. Open Vivado, click **Run Implementation**, and **Generate Bitstream**.
2. Connect your **Basys3 FPGA board** via USB and attach a **VGA monitor**.
3. Open **Hardware Manager** $\rightarrow$ **Auto Connect** $\rightarrow$ **Program Device** using `top_basys3.bit`.
4. The edge-detected image will display centered on your monitor screen.

---

## 🎛️ Hardware & VGA Technical Specifications

* **VGA Resolution:** $640 \times 480$ @ 60 Hz display mode.
* **Pixel Clock:** $25\text{ MHz}$ (generated via a 2-bit counter clock divider from the $100\text{ MHz}$ Basys3 onboard clock).
* **Image Dimensions:** $128 \times 128$ pixels ($16,384\text{ Bytes}$ stored in FPGA Block RAM).
* **Screen Position:** Centered on display ($X \in [256, 383]$, $Y \in [176, 303]$).
* **Color Output:** 4-bit MSB grayscale routing (`pixel_val[7:4]`) assigned identically to Basys3 Red, Green, and Blue resistor ladder pins.

### Basys3 Pin Map (`basys3_vga.xdc`)

| Signal Name | FPGA Pin | Description |
| :--- | :--- | :--- |
| `clk_100MHz` | `W5` | Onboard 100 MHz Oscillator |
| `reset` | `U18` | Center Push Button (BTNC) |
| `hsync` / `vsync` | `P19` / `R19` | VGA Horizontal & Vertical Sync |
| `vgaRed[3:0]` | `N19, J19, H19, G19` | 4-bit Red Resistor Ladder |
| `vgaGreen[3:0]` | `D17, G17, H17, J17` | 4-bit Green Resistor Ladder |
| `vgaBlue[3:0]` | `J18, K18, L18, N18` | 4-bit Blue Resistor Ladder |

---

## ⚙️ Path Portability Note

> **Important:** This entire project is built using dynamic relative paths (`../../...`). It is fully portable and can be cloned or executed across different operating systems and host machines without breaking file path variables.