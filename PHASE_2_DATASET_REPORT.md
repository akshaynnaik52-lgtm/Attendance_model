# Phase 2 Dataset Report

## 1. 10,000 Face Images Analysis
- **Count**: 10,000 face images
- **Resolution**: 512x512, tightly cropped individual faces.
- **Suitability**: They do NOT contain backgrounds or contextual classroom environments. They are mostly single faces taking up a significant portion of the image.
- **Action**: These images will be treated as an **auxiliary dataset**. They cannot be used directly as the primary detection dataset because doing so would result in a model that only learns to classify large faces rather than localizing small, occluded, or diverse faces in a large classroom scene.

## 2. Detection Dataset Strategy
The target real-time classroom attendance detector needs to recognize full-frame environments. We must construct a primary dataset that contains:
- Classrooms, lecture halls, group photos.
- Variations in distances, lighting, and occlusion.
- Different face sizes (from small background faces to large foreground faces).

## 3. Data Sources Needed
Since the original dataset is just cropped faces:
- **Primary Source**: We need publicly available properly-licensed dataset(s) for crowd/face detection (e.g., WIDER FACE, CrowdHuman) or user-collected classroom images.
- **Auxiliary Source**: The existing 10,000 images will serve as auxiliary data or for synthetic data generation.

## 4. Synthetic Data
- We will construct a synthetic pipeline using the auxiliary face crops combined with empty classroom backgrounds.
- This will inject variation in scale, position, and orientation.
- **Limitations**: Synthetic images may lack realistic lighting interactions, shadows, and natural occlusion. It will purely supplement real full-frame data, not replace it.

## 5. Annotation Strategy
- We will use YOLO object detection format (class_id, x_center, y_center, width, height) with class `0` = face.
- Automated annotations via heavy models (like RetinaFace) can be used on unlabeled classroom images, BUT must be manually verified and corrected to avoid pseudo-label degradation.

## 6. Dataset Split
- Recommended split: 70% Train, 20% Validation, 10% Test.
- **Leakage Prevention**: We will ensure images from the same continuous video/session or same background are kept entirely within a single split. We will run exact and perceptual hashing to remove near-duplicates.

## 7. Important Decisions / Q&A
**1. Can the existing 10,000 face images directly train a strong face detector?**
No.
**2. If not, why?**
They are tightly cropped individual faces. A detector trained on this would fail to detect small or multiple faces in a complex classroom environment. It would only learn to classify a large face filling the screen.
**3. What role should the 10,000 images play?**
They will be used as an auxiliary dataset for generating synthetic multi-face images or for fine-tuning face embeddings/classifiers later if needed.
**4. How many actual full-frame detection images are required?**
A minimum of 3,000 to 5,000 well-annotated full-frame multi-face images (e.g., yielding 30,000+ face bounding boxes) are required for robust baseline YOLO training.
**5. Should synthetic data be used?**
Yes, as a supplementary source to handle edge cases (extreme angles, small scales) but not as the sole dataset.
**6. What additional real data is required?**
Properly licensed crowd or classroom datasets (e.g., WIDER FACE) or manually collected and annotated classroom photos.
**7. What annotation strategy should be used?**
YOLO format (txt files). Automated generation followed by strict manual validation to ensure ground-truth quality.
**8. Is the final dataset ready for Phase 3?**
The infrastructure (directories, scripts, architecture) is ready. The *actual* image gathering and manual validation of the real full-frame classroom data needs to be completed before full training, but we are ready to build the Phase 3 YOLO baseline structure.
