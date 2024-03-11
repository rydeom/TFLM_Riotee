import struct
import threading
import numpy as np
import serial

import datetime as dt
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.io.wavfile import write

# Open the UART connection
  # Replace '/dev/ttyUSB0' with your UART device path

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)

# Create empty lists to store the data
x_data = []
y_data = []

def read_data():
    uart = serial.Serial('/dev/tty.usbmodem14302', 115200)
    while True:
        # Read a line of data from the UART
        if not uart.is_open:
            uart.open()
        try:
            data = uart.read_until(b'UU')[0:-2]
            if len(data) != 16384:
                print("Not enough data")
                continue
            formatted_data = struct.unpack('8192h', data)

            x_data.extend(range(len(formatted_data)))
            y_data.extend(formatted_data)
            samplerate = 16384
            print(f"Data: {formatted_data}")
            print(np.asarray(formatted_data, dtype=np.int16))
            write("example.wav", samplerate, np.asarray(formatted_data, dtype=np.int16))
        except Exception as e:
            print(f"Error: {e}")
            

def animate(i, xs, ys):
    # Limit x and y lists to 20 items
    xs = xs[-8192:]
    ys = ys[-8192:]

    # Draw x and y lists
    ax.clear()
    ax.plot(xs, ys)

    # Format plot
    ax.set_xticks([])
    ax.set_ylim(-2048, 2048)

x = threading.Thread(target=read_data)
x.start()
# Set up plot to call animate() function periodically
ani = animation.FuncAnimation(fig, animate, fargs=(x_data, y_data), interval=50)
plt.show()

# Close the UART connection
uart.close()
