import matplotlib.pyplot as plt
from scipy.io.wavfile import write
import numpy as np





data = []
with open("data_speech.txt", "r") as file:
    for line in file:
        data.append(int(line.strip()) + 740)
        
samplerate = 16000
data_list = list(data)
print(f"Data: {np.asarray(data_list, dtype=np.int16)}")
# Save data_list to a text file
write('test.wav', samplerate, np.asarray(data_list, dtype=np.int16))        

print(f"Data: {len(data)}")

plt.plot(data)
plt.xlabel('Index')
plt.ylabel('Value')
plt.title('Data Plot')
plt.show()