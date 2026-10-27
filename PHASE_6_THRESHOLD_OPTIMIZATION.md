# Phase 6 Threshold & Recognition Optimization

## Objective
Create the complete threshold calibration and recognition optimization framework. The final production threshold must minimize dangerous false acceptances (FAR) while maintaining acceptable recognition recall (FRR).

## Critical Notice
**PRODUCTION RECOGNITION THRESHOLD NOT CALIBRATED — REAL IDENTITY-AWARE DATA REQUIRED.**
All thresholds generated in this phase use synthetic mock embeddings and are labelled `DEVELOPMENT_ONLY`.

## Threshold Principle
False Acceptance is strictly more dangerous than False Rejection for an academic attendance system. The calibration framework evaluates multiple operational points (FAR = 1%, 0.1%, 0.01%) and extracts the precise threshold required to maintain those strict boundaries.

## Threshold Method
- Sweeps similarity range [-1.0 to 1.0].
- Computes TPR, FPR, FAR, FRR at 1000 threshold steps.
- Uses independent calibration and validation splits.
- Selects threshold by enforcing `FAR <= target_far` and maximizing `Recall`.

## Open-Set Unknown Threshold
The maximum similarity of unknown queries (calculated in Phase 5) is cross-referenced with the selected threshold to ensure unknowns naturally fall below the rejection line.

## Recognition Strategy Decision
**Maximum Similarity**. Evaluated against centroid strategies, maximum similarity across 3-5 enrollment embeddings preserves pose and lighting variations better without corrupting the geometric identity manifold. This strategy remains in place.

## Output
- `docs/PHASE_6_THRESHOLD_RESULTS.json`
- Synthetic calibration pipeline created at `scripts/calibrate_threshold.py`.
