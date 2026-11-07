from pathlib import Path

outputs_folder =  Path(__file__).resolve().parent.parent / "outputs"
outputs_folder.mkdir(parents=True, exist_ok=True)

def pixel_to_complex(px, py, width, height):
    xdelta = 3 / width
    ydelta = 2.25 / height
    
    a = -2 + px * xdelta
    b = 1.125 - py * ydelta
    return a, b

def escape_iterations(px, py, width, height, i_limit):
    a, b = pixel_to_complex(px, py, width, height)

    x = 0.0
    y = 0.0

    escape_value = 0

    i = 0

    while i < i_limit and escape_value <= 4:
        x, y = x ** 2 - y ** 2 + a, 2 * x * y + b
        escape_value = x ** 2 + y ** 2
        i += 1
    return  i, True if escape_value > 4 else False


def generate_image (width, height, i_limit = 64):
    with open(outputs_folder / f"mandelbrot_{width}_{height}_{i_limit}.txt", "w") as file:
        for j in range(height):
            row = []
            for i in range(width):
                iterations, escaped = escape_iterations(i, j, width, height, i_limit)
                row.append(str(iterations))
            file.write(" ".join(row) + "\n")


width = 320
height = 240

generate_image(width, height)


def load_image(name):
    matrix = []
    with open(outputs_folder / f"{name}.txt", "r") as file:
        for line in file:
            values = line.split()
            row = []
            for value in values:
                row.append(int(value))
            matrix.append(row)
    return matrix

matrix = load_image("mandelbrot_320_240")

print(f"Number of rows = {len(matrix)}; Number of columns = {len(matrix[0])}")
print(f"Value of pixel (0, 0) = {matrix[0][0]}")
print(f"Value of pixel (160, 120) = {matrix[120][160]}")