# Screen Flash Liveness Detection Logic

This document outlines the logic for implementing **Active Liveness Detection using Screen Flashing** (also known as Reflection Analysis). This method defeats video replay attacks because a physical screen (playing a video) does not reflect light the same way real skin does.

## The Core Concept
1.  **Assume Control**: We control the light in the environment by turning the phone screen into a colored flashlight.
2.  **Challenge**: We flash a sequence of known colors (e.g., **Red** -> **None** -> **Red** or **Dark** -> **Bright** -> **Dark**).
3.  **Response**: We analyze the reflection on the user's face. 
    *   **Real Face**: Shows a spike in the corresponding color intensity (Red channel increases when screen is Red).
    *   **Fake Face (Screen/Paper)**: Does not show the synchronized intensity change, or shows a different reflection pattern (glossy screen reflection vs diffuse skin reflection).

---

## 1. The State Machine

You need to implement a state machine in your `FaceDetectionPage` to manage the process.

**States:**
1.  `IDLE`: Waiting for camera to initialize.
2.  `DETECTING_FACE`: Looking for a face that is centered, big enough, and stable.
3.  `PREPARING_FLASH`: Face found. Lock UI. Tell user "Hold still".
4.  `FLASHING_SEQUENCE`: Rapidly changing screen colors while recording data.
5.  `ANALYZING`: Processing the captured data.
6.  `SUCCESS/FAILURE`: Result.

---

## 2. The Verification Workflow (Pseudocode)

### Step A: Prerequisites
Ensure the face is close enough and centered.
```dart
if (face.width > 0.4 && isCentered(face)) {
  startFlashSequence();
}
```

### Step B: The Flash Sequence
We will cycle through a specific list of colors. Each "tick" lasts typically 300ms–500ms to allow the camera sensor to adjust (exposure) and capture enough frames.

**Sequence:** `[Colors.transparent, Colors.red.withOpacity(0.8), Colors.transparent]`

*   **Frame 0-10 (Base)**: Measure ambient light on face (Baseline).
*   **Frame 11-20 (Flash)**: Turn screen RED. Measure reflected light.
*   **Frame 21-30 (Base)**: Turn screen OFF. Measure return to baseline.

### Step C: Data Collection (Per Frame)
Inside your `startImageStream`, for every frame during the sequence:

1.  **Crop to Face**: Extract the pixel data for the region of the face (e.g., the nose/cheek area). **Do not** use the whole image (avoid background noise).
2.  **Calculate Average Color**: Calculate the average R, G, and B values for that face region.
    ```dart
    // For a specific frame 'i'
    double avgRed = calculateAveragePixelIntensity(faceRegion, 'R');
    double avgGreen = calculateAveragePixelIntensity(faceRegion, 'G');
    double avgBlue = calculateAveragePixelIntensity(faceRegion, 'B');
    
    recordedData.add({timestamp, colorMode, avgRed, avgGreen, avgBlue});
    ```

### Step D: Verification Logic (The Math)
After the sequence finishes, analyze `recordedData`.

**Success Condition (Real Person):**
When the screen was **RED**:
1.  The `avgRed` value should be significantly higher than the `avgRed` during the "Base" content.
2.  The `avgRed` increase should be higher than the increase in `avgGreen` or `avgBlue` (dominance).

**Fail Condition (Spoof):**
1.  **No Change**: The values stayed flat (Video recording didn't catch the reflection).
2.  **Wrong Color**: The video might have its own lighting changes that don't match our sequence timestamps.

---

## 3. Implementation Blueprint

### modified `face_detection_screen.dart` Structure

```dart
class _FaceDetectionPageState extends State<FaceDetectionPage> {
  
  // 1. Add Flash UI Overlay
  Color _flashOverlayColor = Colors.transparent;

  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(...),
        // The Flash Overlay
        Container(
          width: double.infinity,
          height: double.infinity,
          color: _flashOverlayColor, 
        ),
        // ... rest of UI
      ]
    );
  }

  // 2. The Analysis Loop
  void processFrame(CameraImage image) {
     if (currentState == FLASHING_SEQUENCE) {
         // Extract pixels from the face bounding box
         // Calculate Average R, G, B
         // Store in list
     }
  }

  // 3. The Sequencer
  void startFlashSequence() async {
      setState(() => currentState = FLASHING_SEQUENCE);
      
      // Phase 1: Baseline
      await Future.delayed(300ms);
      
      // Phase 2: Red Flash
      setState(() => _flashOverlayColor = Colors.red.withOpacity(0.5));
      currentExpectedColor = "RED"; 
      await Future.delayed(500ms); // Capture frames here
      
      // Phase 3: Back to Normal
      setState(() => _flashOverlayColor = Colors.transparent);
      currentExpectedColor = "NONE";
      await Future.delayed(300ms);
      
      // Finish
      verifyLiveness();
  }
}
```

## 4. Key Challenges to Handle
1.  **Exposure Compensation**: When the screen turns Red, the camera might try to auto-adjust exposure, making the image darker. 
    *   *Fix*: If possible, lock camera exposure before starting the sequence.
2.  **YUV to RGB**: Camera streams usually give YUV420. You need to convert the Y (Luma) and UV (Chroma) to RGB to get accurate Red values.
    *   *Simplification*: You can just check Y (Brightness) increase if you use a WHITE flash instead of RED. White flash is easier but slightly less secure than Color flash. I recommend starting with **White Flash** (Brightness Jump) as it's easier to implement.

## Recommendation for V1
Start with a **Brightness Challenge (White Flash)**.
1.  Establish baseline brightness of face.
2.  Flash screen White (maximum brightness).
3.  Check if face brightness (`Y` component in YUV) increases by a threshold (e.g., >10%).
4.  If it doesn't increase, it's a screen (screens don't reflect the new light effectively if the video is recorded in a different room).
