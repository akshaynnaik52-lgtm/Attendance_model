# Phase 3 Detection & Alignment Baseline

## 1. Objective
Establish a reliable face detection and alignment pipeline. This pipeline consumes raw images and outputs strictly cropped and aligned 112x112 face images suitable for a pretrained ArcFace embedding model, alongside quality scores and landmarks.

## 2. Detector Candidates
- **SCRFD** (Sample and Computation Redistribution for Fast Face Detection)
- **RetinaFace**

## 3. Selected Detector
**SCRFD (via InsightFace)**

## 4. Selection Reasoning
SCRFD is highly optimized, offers superior throughput on CPU/GPU compared to RetinaFace, and explicitly outputs the 5 critical facial landmarks natively required for ArcFace alignment. It handles small faces well and is natively integrated into the InsightFace ecosystem, preventing dependency bloat.

## 5. Model/Weight Information
- **Model**: SCRFD (buffalo_l package from InsightFace)
- **Input Resolution**: Dynamically rescaled to max 640x640 internally.
- **Confidence Threshold**: Configured to 0.5.

## 6. Detection Pipeline
`Image -> InsightFace App -> Filter by Confidence -> Compute Quality Score -> Align -> Return List[FaceDetection]`

## 7. Landmark Extraction
Detector directly outputs 5 points: Left Eye, Right Eye, Nose, Left Mouth Corner, Right Mouth Corner.

## 8. Alignment Method
- **Method**: 2D Affine Similarity Transformation (`cv2.estimateAffinePartial2D` with LMEDS).
- **Template**: Standard 112x112 ArcFace landmark template.

## 9. Quality Filtering
Quality score (`0.0` to `1.0`) is computed based on:
1. Face size relative to 112x112 template.
2. Variance of Laplacian (blur detection).
Low-quality faces are **not discarded** here; they are flagged so Phase 4 or the Attendance Business Logic can decide whether to reject them.

## 10. Multi-Face Handling
The pipeline natively processes images with 0, 1, or N faces. It returns a `List[FaceDetection]`. None are silently discarded unless they fail the baseline confidence threshold.

## 11. Benchmark Methodology
Simulated processing of 100 images measuring latency and throughput on CPU architecture. (Note: Fallback mock used if insightface is missing in CI environment).

## 12. Benchmark Results
See `docs/PHASE_3_BENCHMARK.json`. Shows single-image latency and total faces processed.

## 13. Failure Analysis (Simulated Cases)
- **Missed face**: Usually caused by extreme pitch/yaw (> 90 degrees) or heavy occlusion (thick mask + sunglasses).
- **False detection**: Complex patterns (e.g., fabric) mimicking a face. Handled via higher confidence thresholds.
- **Motion blur**: Detected successfully, but flagged with a low `quality_score`.

## 14. Limitations
- Pure CPU deployment of SCRFD may struggle to hit 30+ FPS for multi-camera streams without batching.
- Alignment relies heavily on the 5 landmarks; if landmarks are jittery, the aligned crop shifts slightly, which can marginally affect recognition embedding precision.

## 15. Phase 4 Integration Contract
Phase 4 will receive a `List[FaceDetection]` per image. Each `FaceDetection` object contains:
```json
{
    "bbox": [x1, y1, x2, y2],
    "confidence": 0.99,
    "landmarks": [[x,y], ...],
    "quality_score": 0.85,
    "aligned_face": "<np.ndarray BGR 112x112>"
}
```
Phase 4 logic can directly pass `aligned_face` into the ArcFace PyTorch model.
