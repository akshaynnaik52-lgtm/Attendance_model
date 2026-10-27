# Phase 1 Dataset Audit

## 1. Executive Summary
The downloaded dataset contains approximately 20,000 images, equally divided between original faces and stylized comic counterparts. While the images are high-quality, tightly cropped faces (512x512), the dataset entirely lacks identity labels or structure (e.g., one folder per person). It is therefore unsuitable for identity recognition evaluation or as a primary face-gallery enrollment set.

## 2. Dataset Inventory
- Source: `face2comics_v1.0.0_by_Sxela`
- Two primary directories: `face/` and `comics/`
- `samples/` directory with 3 images.

## 3. Directory Structure
```text
archive/
└── face2comics_v1.0.0_by_Sxela/
    └── face2comics_v1.0.0_by_Sxela/
        ├── face/   (~10,000 files)
        └── comics/ (~10,000 files)
```

## 4. File Statistics
- Total files: 20,003
- Extensions: 100% `.jpg`
- No metadata files (`.csv`, `.json`, `.txt`) containing identity mappings.

## 5. Image Statistics
- Dimensions: 512x512 pixels
- Channels: 3 (RGB)
- Corrupt files: 0 found in samples

## 6. Image-quality Analysis
- Images are high-resolution, clear, and well-lit.
- Blur and noise are minimal.

## 7. Face Characteristics
- Faces occupy the vast majority of the frame.
- Backgrounds are largely cropped out.
- Pose variation is mostly frontal to near-frontal.

## 8. Identity-Label Analysis
- **A. Identity Labels**: Missing.
- **B. Subject/Person IDs**: Missing.
- **C. Image-level labels**: None.
- Filenames are sequential/random (e.g., `0000.jpg`, `0001.jpg`) and do not indicate identity. We **cannot** assume different images belong to different people, nor that consecutive images are the same person.

## 9. Duplicate Analysis
Exact duplicate detection using MD5 hashing found 0 cross-directory exact matches (as one is comic, one is real). No obvious intra-directory duplicates were found based on hash.

## 10. Leakage Analysis
Since there are no identities, training an identity model on this data is impossible. If used for auxiliary face detection/alignment, there is no leakage risk between train/test because identities are unknown, but random splitting is standard.

## 11. Suitability Matrix
| Task | Suitable? | Evidence | Limitations |
|------|-----------|----------|-------------|
| Face detection | Yes (Aux) | Contains clear faces | Tightly cropped, lacks full-frame contexts |
| Face alignment | Yes | Faces are clear and large | Landmarks might be easy to find compared to real-world |
| Face embedding generation | Yes (Pre-train) | Can pass through network | Cannot compute triplet-loss/ArcFace margin without ID labels |
| Identity recognition | **NO** | No ID labels exist | Cannot map face to a person |
| Recognition evaluation | **NO** | No ID labels exist | Cannot verify if matching is correct |
| Threshold calibration | **NO** | No ID labels exist | Cannot compute False Accept / False Reject rates |

## 12. Deployment-Domain Gap Analysis
The final system will see real classrooms (multiple people, small faces, motion blur, bad lighting, diverse angles). This dataset is single, large, high-quality faces. The domain gap is **massive**.

## 13. Additional Data Requirements
We strictly require an identity-labeled dataset (e.g., LFW, CASIA-WebFace, or user-consented internal data) where:
- Each identity has a unique ID (e.g., `subject_001/`).
- Each identity has multiple images (for enrollment gallery vs query testing).
- Images contain real-world artifacts (lighting, angles).

## 14. Recommendations
- Do **not** use this dataset for face recognition training or threshold calibration.
- Use this dataset only to test the pipeline latency (e.g., passing 10k faces through the embedding model to measure speed).
- Procure an identity-aware dataset for Phase 5 (Recognition Evaluation) and Phase 6 (Threshold Optimization).

## 15. Limitations
- Identity mapping is impossible.
- Lacks demographic metadata.
- Cropping removes background context necessary for robust detection.

## 16. Conclusion
The dataset is an auxiliary visual dataset. It is suitable for face preprocessing experiments but insufficient for identity recognition evaluation. 
