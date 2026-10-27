# Phase 2 Data Schema

## 1. Identities (`identities.csv`)
Defines the individuals in the dataset.
- `identity_id` (String/UUID) - Unique anonymous identifier (e.g., `subj_001`)
- `split` (String) - `train`, `val`, or `test` (Used for threshold calibration vs final evaluation)
- `enrollment_status` (Boolean) - True if the person is enrolled in the gallery, False if they are used as an "Unknown" impostor.

## 2. Images (`images.csv`)
Maps every file to its metadata.
- `image_id` (String/UUID) - Unique ID for the image
- `identity_id` (String/UUID) - Foreign key to `identities.csv`
- `file_path` (String) - Relative path (e.g., `evaluation/query/known/subj_001/img1.jpg`)
- `usage_type` (String) - `enrollment` or `query`
- `capture_environment` (String) - `webcam`, `classroom`, `corridor`
- `quality_flag` (Boolean) - True if it passes basic heuristic checks (not purely black/corrupt)

## 3. Verification Trials (`trials.csv`)
Explicit pairs generated for False Accept / False Reject evaluation.
- `trial_id` (String)
- `image_id_1` (String) - Typically an enrollment image
- `image_id_2` (String) - Typically a query image
- `is_genuine` (Boolean) - True if both belong to the same identity, False otherwise.

## 4. Enrollment Database Schema (PostgreSQL Target)
*Note: This is the application schema, simulated by the CSVs above during evaluation.*
- `id` (UUID) - Primary Key
- `student_id` (UUID) - Reference to the application student record
- `embedding` (Vector/Array) - The 512D float array
- `model_version` (String) - e.g., `arcface_r50_v1`
- `created_at` (Timestamp)
