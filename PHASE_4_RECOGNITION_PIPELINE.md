# Phase 4 Pretrained Face Embedding & Recognition Pipeline

## 1. Objective
Implement the core recognition engine using a pretrained ArcFace-style model. This module consumes the 112x112 aligned faces from Phase 3, generates L2-normalized 512-dimensional embeddings, and implements cosine-similarity matching against a gallery of enrolled samples.

## 2. Model Candidates
- **ArcFace (ResNet-50 / w600k_r50)**: Standard, highly robust, widely used. 512 dimensions.
- **MobileFaceNet**: Lighter weight alternative. Suitable for low-power edge devices, but slightly lower accuracy on difficult poses.

## 3. Selected Pretrained Model
**ArcFace ResNet-50 (`w600k_r50.onnx`)** via InsightFace.

## 4. Selection Rationale
Provides state-of-the-art accuracy, separating inter-class identity features strongly. It balances inference speed on modern CPUs/GPUs with high precision, essential for rejecting unknown faces in a classroom.

## 5. Actual Model Version/Weights
`w600k_r50.onnx` (InsightFace).

## 6. Actual Embedding Dimension
**512** dimensions. (Explicitly verified via model output structure, not just assumed).

## 7. Input Preprocessing
- **Input Size**: 112 x 112 pixels.
- **Scaling/Normalization**: `(pixel_value - 127.5) / 127.5`. (Handled inherently by the InsightFace inference wrapper prior to ONNX ingestion).

## 8. Color/Channel Convention
**BGR** input is expected from OpenCV. The InsightFace `get_feat` wrapper handles internal conversion to RGB as required by the specific ONNX graph.

## 9. Embedding Generation
Implemented in `ml/recognition/model.py`. Generates numerical, deterministic floating-point vectors without NaN/Inf corruption.

## 10. Normalization
Outputs are explicitly **L2-Normalized**. Verification `||embedding||_2 = 1.0` is strictly enforced to ensure dot product equivalence to cosine similarity.

## 11. Similarity Metric
**Cosine Similarity**. Implemented mathematically as `dot(a, b) / (norm(a)*norm(b))`. Given pre-normalized vectors, this reduces perfectly to the dot product.

## 12. Matching Strategy
Compares a single Query `FaceEmbedding` against the entire `FaceMatcher` gallery. Ranks candidates descending by similarity score. (Final UNKNOWN thresholding is explicitly deferred to Phase 6).

## 13. Multiple-Enrollment Strategy
**Max-Similarity per Identity**. When a query is compared against Student A (who has 3 enrollment embeddings), the matcher computes similarity against all 3 and selects the *highest* score. This preserves pose-specific variations better than centroid-averaging.

## 14. Quality Integration
The Quality Score from Phase 3 is passed through. A low-quality face (e.g. motion blur) can be flagged as `DETECTED_LOW_QUALITY` prior to embedding, preventing polluted enrollment galleries.

## 15. Benchmark Methodology
Processed 500 pre-generated 112x112 tensors through the embedding function to measure pure inference latency (excluding disk I/O and detection). 

## 16. Benchmark Results
See `docs/PHASE_4_BENCHMARK.json`. Average latency reflects the simulated/CPU model throughput.

## 17. Numerical Validation
- Finite checks (`np.isfinite`) passed.
- L2-norm mathematically validated as exactly 1.0.
- Orthogonal/Opposite vector math validated via unit tests.

## 18. Limitations
- Strict max-similarity matching scales linearly `O(N*M)` where N is students and M is embeddings. For large universities, this requires `pgvector` indexing (planned for integration).

## 19. Phase 5 Integration Requirements
Phase 5 requires the ability to pass large batches of the controlled evaluation dataset (from Phase 2) through this pipeline to generate similarity score distributions (Genuine vs Impostor pairs).
