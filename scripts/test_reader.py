import sys
sys.path.append('/usr/lib/security/howdy')
from recorders.ffmpeg_reader import ffmpeg_reader
import numpy as np

print("Testing ffmpeg_reader...")
reader = ffmpeg_reader('/dev/video2', 'v4l2')
ret, frame = reader.read()

if ret:
    print(f"Success! Frame shape: {frame.shape}")
    print(f"Average brightness: {np.mean(frame)}")
    if np.mean(frame) < 1:
        print("WARNING: Frame is extremely dark (IR emitter likely off)")
    else:
        print("Frame has data (IR emitter might be working or ambient light)")
else:
    print("Failed to read frame")
