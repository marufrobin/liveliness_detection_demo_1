# TensorFlow Lite Face Anti-Spoofing Guide

This guide explains how to use a ML-based approach (Passive Liveness) using TensorFlow Lite to detect if a face is real or a spoof (video/photo).

## The Concept
Unlike the "Active" flash method (which checks for light reflection), the "Passive" ML method looks for visual artifacts that the human eye might miss:
*   **Moiré Patterns**: Wavy interference lines from filming a screen.
*   **Surface Blur**: The difference in texture between real skin and a glossy screen.
*   **Bezels**: The edges of the phone/tablet screen.

## Recommended Model
The most popular open-source model for mobile is **MiniFASNet (Mini Face Anti-Spoofing Network)**.
It is small (~3MB), fast, and designed for mobile.

**Where to get the model:**
You can find pre-trained `.tflite` models in repositories like:
*   `minivision-ai/Silent-Face-Anti-Spoofing` (The original)
*   `shubham0204/OnDevice-Face-Recognition-Android` (Has TFLite conversions)

## Implementation Steps

### 1. Add Dependencies
Add `tflite_flutter` to your `pubspec.yaml` to run the model.
```yaml
dependencies:
  tflite_flutter: ^0.10.1
  # You already have camera and google_mlkit_face_detection
  image: ^4.0.17 # Useful for image resizing/manipulation
```

### 2. Import the Model
1.  Download `FASNet.tflite` (or similar).
2.  Place it in your `assets/` folder.
3.  Update `pubspec.yaml`:
    ```yaml
    flutter:
      assets:
        - assets/FASNet.tflite
    ```

### 3. Initialize the Interpreter
In your Code (e.g., a new `LivenessService` class):

```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class LivenessService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('FASNet.tflite');
  }
}
```

### 4. Process Camera Frames
This is the hardest part. You need to convert the `CameraImage` (which is YUV420) into a format the model expects (usually a **cropped 80x80 RGB Bitmap**).

**Workflow:**
1.  **Detect Face**: Use ML Kit to get the Face Bounding Box.
2.  **Crop**: Cut out just the face from the camera frame.
    *   *Note*: You must expand the crop slightly (scale x1.2) to include the background/edges, as that's where "spoof" artifacts often live.
3.  **Resize**: Resize the crop to the model's input size (e.g., 80x80).
4.  **Normalize**: Convert pixel values (0-255) to float (0.0-1.0) if required.

### 5. Run Inference
```dart
// Input: [1, 80, 80, 3] (Batch, Height, Width, Channels)
var input = [normalizedImageBytes];

// Output: [1, 3] (Real, Spoof_Type_A, Spoof_Type_B) or just [1, 2] (Real, Fake)
var output = List.filled(1 * 2, 0).reshape([1, 2]);

_interpreter.run(input, output);

// Check result
double realScore = output[0][0];
double fakeScore = output[0][1];

if (realScore > fakeScore) {
  // Is Real
} else {
  // Is Fake
}
```

## Comparison: Flash vs TensorFlow

| Feature | Screen Flash (Active) | TensorFlow (Passive) |
| :--- | :--- | :--- |
| **Accuracy (Replay Attacks)** | **High**. Physics-based (Reflection) is hard to cheat. | **Medium/High**. Good models catch it, but high-res 4K screens can fool simple models. |
| **User Experience** | **Intrusive**. Flashes lights in user's face. | **Seamless**. Invisible to user. |
| **Complexity** | **Medium**. Logic is complex, but no external files needed. | **High**. Needs image processing (YUV->RGB->Resize) and model management. |
| **App Size** | Small (Code only). | Larger (+3MB to +10MB for model). |

## Recommendation
If this is a high-security banking/finance demo (suggested by "Brac EPL" in your path):
**Combine Both.**
1.  Run **TensorFlow** continuously in the background. If it detects a spoof, block immediately.
2.  If TensorFlow is unsure (or as a final check), trigger the **Screen Flash** sequence.

For now, sticking to the **Screen Flash** method I designed previously is likely the **fastest way to get a working "Anti-Replay" demo** without needing to debug complex YUV conversion and TFLite tensor shapes.
