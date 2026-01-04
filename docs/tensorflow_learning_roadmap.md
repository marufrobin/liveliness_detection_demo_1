# TensorFlow Learning Roadmap (Flutter & Computer Vision Focus)

This roadmap is tailored for a mobile developer (Flutter) effectively wanting to implement advanced Computer Vision features like **Face Anti-Spoofing**. It skips general data science fluff and focuses on what you need for this project.

## Phase 1: The Basics (Week 1-2)
**Goal:** Understand what a "Tensor" is and how a Neural Network "sees" an image.

1.  **Core Concepts**
    *   **Tensors**: Understand that they are just multidimensional arrays (Matrices) of numbers.
    *   **Operations**: Matrix multiplication, ReLu, Softmax (the math functions that make decisions).
    *   **Model Structure**: Inputs (Pixels) -> Hidden Layers -> Outputs (Categories).
2.  **Keras API (High Level)**
    *   Learn to build a simple "Sequential" model.
    *   *Exercise*: Build a classifier for the MNIST dataset (Handwritten digits). It's the "Hello World" of ML.
    *   *Resource*: [TensorFlow Basic Classification Tutorial](https://www.tensorflow.org/tutorials/keras/classification)

## Phase 2: Computer Vision & CNNs (Week 3-4)
**Goal:** Understand **Convolutional Neural Networks (CNNs)**. This is the engine of all image recognition.

1.  **Convolutions**: How filters "slide" over an image to detect edges, textures, and shapes.
2.  **Pooling**: How to shrink images while keeping important features.
3.  **Transfer Learning**: **Critical for you.** Instead of training from scratch, learn how to take a big model (like MobileNet) and "fine-tune" it on your own small dataset.
    *   *Exercise*: Classify "Cats vs Dogs" using a pre-trained MobileNetV2.
    *   *Resource*: [Transfer Learning with TF Hub](https://www.tensorflow.org/tutorials/images/transfer_learning)

## Phase 3: Face Anti-Spoofing Specifics (Week 5-6)
**Goal:** Learn the specific tricks required to detect Liveness.

1.  **The Problem**: Why a photo looks different from a real face to a computer (Texture, Blur, Moiré patterns).
2.  **YUV vs RGB**: Understanding camera color spaces. Models usually want RGB, but cameras give YUV.
3.  **Binary Classification**: You are building a model that outputs just two numbers: `[Real_Probability, Fake_Probability]`.
4.  **Datasets**: Look at datasets like **replay-attack** or **OULU-NPU** to understand what training data looks like.

## Phase 4: TensorFlow Lite (TFLite) & Mobile (Week 7+)
**Goal:** Running it on the phone efficiently.

1.  **Quantization**: How to turn a 100MB model into a 3MB model by reducing precision (Float32 -> Int8) without losing much accuracy.
2.  **Interpreter**: How to load a `.tflite` file in Flutter.
3.  **Image Processing Pipeline**:
    *   Camera Stream (YUV) -> Convert to Bytes -> Resize (e.g., 224x224) -> Normalize (0..1) -> Input to Model.
    *   *Note*: This pipeline is often harder than the ML part itself!

## Recommended Resources
*   **Course**: "DeepLearning.AI TensorFlow Developer Professional Certificate" (Coursera) - *Best overall foundation.*
*   **YouTube**: "TensorFlow Computer Vision" by freeCodeCamp.
*   **Book**: "TinyML" by Pete Warden (Great for understanding mobile limits).

## Fast Track (For your current project)
If you want to skip the deep theory and just work on the **Anti-Spoofing** feature:
1.  **Don't train a model yet.** Download a pre-trained **MiniFASNet** `.tflite` file.
2.  Focus entirely on **Phase 4 (TFLite & Mobile)**.
3.  Learn how to use the `tflite_flutter` package to feed camera bytes to that file.
