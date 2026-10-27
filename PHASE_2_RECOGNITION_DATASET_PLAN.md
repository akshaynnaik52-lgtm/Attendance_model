# Phase 2 Recognition Dataset Plan

## 1. Objective
To design a scientifically valid dataset strategy and evaluation framework for measuring the performance of a pretrained face recognition model in the context of an academic attendance system.

## 2. Phase 1 Findings
The existing ~10,000 cropped face images (and their comic counterparts) completely lack identity labels. It is impossible to ascertain which images belong to the same person. Therefore, this dataset is scientifically useless for identity recognition evaluation, threshold calibration, or simulating student enrollment.

## 3. Dataset Strategy
Since the ArcFace recognition model is *pretrained*, we do not need millions of images for training. We need a high-quality dataset specifically for **evaluation** and **threshold calibration**. 
**Strategy:** A combination of a standard public evaluation dataset (for initial thresholding and algorithm validation) followed by a small, controlled, consented dataset (to simulate the exact classroom/webcam attendance domain).

## 4. Public Dataset Evaluation
- **LFW (Labeled Faces in the Wild)**: Good for standard verification benchmarking. ~13,000 images, ~5,700 identities. Easy to access. However, mostly celebrity photos, which lacks classroom context.
- **CFP-FP (Celebrities in Frontal-Profile)**: Evaluates frontal vs profile matching. Useful to test extreme angles, but again, celebrity-focused.
- **AgeDB**: Tests age-invariant recognition. Not strictly necessary for an academic semester timeframe.
- **Recommendation**: Use **LFW** pairs strictly for baseline sanity-checking of the ArcFace pipeline. Do NOT rely on it for final thresholding because the domain gap (celebrity photos vs classroom cameras) is too wide.

## 5. Controlled Dataset Design
For final thresholding and real-world evaluation, we will construct a small, controlled dataset collected from consenting participants (e.g., student volunteers).
- **Target Identities**: 20 - 50 identities (representing a standard classroom size).
- **Images per Identity**: 10 - 15 images.
  - **Enrollment**: 3-5 high-quality, controlled frontal/slight-profile images.
  - **Query/Test**: 5-10 images taken in the actual classroom environment (varying distances, lighting, groups).
- **Justification**: A 50-person dataset with 5 enrollment images and 10 query images yields 500 genuine query trials and 24,500 impostor query trials. This is statistically sufficient to calibrate a strict classroom attendance threshold.

## 6. Identity Split Strategy
- **Identity-Disjoint Evaluation**: For threshold calibration, the validation identities must not overlap with the test identities. 
- **Enrollment/Query Split**: Within a specific identity, the images used to build the gallery (enrollment) must be strictly disjoint from the images used to test the system (query).

## 7. Enrollment/Query Design
- **Enrollment**: Emulates a student registering on the web portal. Images must pass strict quality checks (frontal, well-lit, single face).
- **Query**: Emulates the classroom camera. Images may be lower quality, part of a group photo, or poorly lit.

## 8. Verification Trial Design
- **Genuine Pair**: Match Query Image of Person A vs Enrollment Gallery of Person A. (Expected: HIGH similarity).
- **Impostor Pair**: Match Query Image of Person A vs Enrollment Gallery of Person B. (Expected: LOW similarity).

## 9. Identification Evaluation Design
Given a Query Image of Person A, compare it against the *entire* database of enrolled students. 
- **Rank-1 Accuracy**: Is the highest-scoring identity Person A?
- **Thresholded Accuracy**: Is the highest-scoring identity Person A AND does the score exceed the calibrated threshold?

## 10. Open-Set Evaluation
We must test **Unknown-Face Rejection**. We will hold out a subset of identities (e.g., 10 people) who are NEVER enrolled. When their query images are passed to the system, the maximum similarity score against any enrolled student must remain below the threshold, resulting in an "UNKNOWN" decision.

## 11. Data-Quality Policy
- **Enrollment strictness**: Must contain exactly 1 face. Must pass blur/brightness heuristics. 
- **Query permissiveness**: Do NOT filter out blurry, small, or occluded faces from the test set. Real classrooms have bad data; the system must correctly reject it as UNKNOWN or confidently match it if possible, but we must measure this robustness.

## 12. Leakage Prevention
- Images from the same video burst or continuous capture session must not be split across Enrollment and Query.
- Cryptographic hashing (MD5) will be used to ensure exact file duplicates do not exist across splits.

## 13. Privacy/Consent Strategy
- **Consent**: All controlled dataset participants must sign an informed consent form stating the data is for academic attendance ML evaluation.
- **Storage**: Raw images stored securely on encrypted volumes. 
- **Anonymization**: Identities represented as UUIDs (e.g., `student_abc123`), stripping real names from the ML evaluation directories.
- **Deletion**: Clear retention policy to delete raw biometric images at the project's conclusion.

## 14. Existing 10K Dataset Role
The `face2comics` 10k dataset remains untouched. Its final role is **System Throughput Benchmarking**. We will use it to test how many images per second the detection + alignment + embedding pipeline can process on the target hardware. It has no role in identity accuracy evaluation.

## 15. Dataset Versioning
```json
{
  "version": "recognition_eval_v1",
  "collection_date": "2026-10",
  "identity_count": 50,
  "image_count": 750,
  "consent_status": "fully_consented_anonymized"
}
```

## 16. Recommended Final Dataset Structure
```text
dataset/
├── evaluation/
│   ├── enrollment/
│   │   ├── id_001/
│   │   │   ├── enroll_1.jpg
│   │   │   └── enroll_2.jpg
│   │   └── id_002/
│   ├── query/
│   │   ├── known_identities/  (Identities present in enrollment)
│   │   │   ├── id_001/
│   │   │   └── id_002/
│   │   └── unknown_identities/ (Identities NOT in enrollment)
│   │       ├── id_051/
│   │       └── id_052/
└── metadata/
    ├── identities.csv
    └── trials.csv
```

## 17. Risks
- **Collection Bottleneck**: Gathering 50 consented volunteers takes time. (Mitigation: Use LFW for immediate pipeline development, swap to controlled data for final thresholding).

## 18. Recommendations
1. Construct the small consented dataset as the ultimate source of truth.
2. Store multiple embeddings per student (e.g., 3-5) and use the maximum similarity score among them during matching, rather than averaging them into a centroid which degrades extreme poses.
