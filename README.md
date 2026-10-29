# FPGA Mandelbrot Renderer

A work-in-progress Mandelbrot fractal renderer written in SystemVerilog for the **Digilent Basys 3 (Xilinx Artix-7)** FPGA development board.

The project explores fixed-point arithmetic, iterative fractal computation, RTL verification, and eventually real-time VGA video output. Development and simulation use **AMD Vivado/XSim**.

## Project status

**In development.** The current focus is the Mandelbrot math engine, fixed-point arithmetic, and simulation. VGA timing and display integration are planned; this repository should not yet be treated as a completed real-time VGA renderer.

## Design overview

For each complex-plane coordinate $c = a + bi$, the Mandelbrot iteration is:

$$
z_{n+1} = z_n^2 + c, \qquad z_0 = 0
$$

Writing \(z = x + yi\) gives:

$$
x_{n+1} = x_n^2 - y_n^2 + a
$$

$$
y_{n+1} = 2x_ny_n + b
$$

A point is considered to have escaped once $x^2 + y^2 > 4$. The intended display will use the iteration count to determine pixel color.

### Current design parameters

| Parameter | Value / goal |
| --- | --- |
| FPGA board | Digilent Basys 3 (Artix-7) |
| HDL | SystemVerilog |
| Clock source | 100 MHz onboard clock |
| Internal arithmetic | Signed Q4.14 fixed-point (4 integer bits including sign, 14 fractional bits) |
| Initial render resolution | 320 × 240 pixels |
| Real-axis range | −2 to +1 |
| Imaginary-axis range | +1.125 to −1.125 |
| Iteration limit used in testing | 64 |
| Planned video interface | VGA |

## Repository layout

```text
.
├── rtl/
│   ├── mandelbrot.sv          # Mandelbrot computation
│   ├── fixed_point_mult.sv    # Fixed-point multiplier
│   └── fractal_top.sv         # Top-level integration (in progress)
├── tb/
│   ├── mandelbrot_tb.sv       # Mandelbrot testbench
│   ├── mandelbrot_tb_sim.wcfg # Optional XSim waveform configuration
│   └── outputs/              # Generated logs and simulation output (ignored by Git)
├── sim.sh                    # Vivado/XSim simulation helper
└── README.md
```

## Running simulations

### Requirements

- Windows with **AMD Vivado** (developed using Vivado 2025.2)
- **Git Bash**
- Vivado's `bin` directory on your `PATH`, so `xvlog.bat`, `xelab.bat`, and `xsim.bat` are available

Run commands from the repository root. The script creates `tb/outputs/` automatically for terminal and file modes if needed (Git does not track empty directories).

The `sim.sh` helper expects a testbench named `tb/<module>_tb.sv`. It compiles that testbench with `rtl/*.sv`, elaborates `<module>_tb`, and runs XSim.

**Run in the terminal:**

```bash
bash sim.sh mandelbrot
```

**Open the XSim GUI:**

```bash
bash sim.sh mandelbrot gui
```

If `tb/mandelbrot_tb_sim.wcfg` exists, the script loads that waveform configuration.

**Save simulation output to a text file:**

```bash
bash sim.sh mandelbrot file
```

The simulation output is written to `tb/outputs/mandelbrot_tb_output.txt`. Compile and elaboration logs are written to `tb/outputs/xvlog.log` and `tb/outputs/xelab.log` in terminal/file modes.

**Remove generated files from `tb/outputs/`:**

```bash
bash sim.sh clean
```

The clean option removes ordinary, non-hidden files directly inside `tb/outputs/`; it does not remove XSim's `xsim.dir/`, nested directories, or hidden files. It also does not create `tb/outputs/` if that directory is missing.

## Verification

The Mandelbrot testbench compares RTL fixed-point calculations against reference calculations using SystemVerilog `real` values. Testing includes pixel-coordinate mapping and iterative escape behavior, with allowances for fixed-point quantization.

## Planned work

- Complete and verify the Mandelbrot computation engine
- Evaluate arithmetic latency, resource usage, and timing
- Add VGA timing and pixel/color generation
- Integrate and test the design on the Basys 3 board

## Notes

This is a learning and portfolio project. The implementation and architecture may change as development progresses.
