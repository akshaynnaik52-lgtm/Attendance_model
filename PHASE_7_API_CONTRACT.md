# ML Service API Contract

## GET `/api/v1/health`
Checks if the service is running.
**Response**:
```json
{
    "status": "healthy",
    "version": "1.0.0"
}
```

## GET `/api/v1/model-info`
Returns information about the loaded models and calibration versions.
**Response**:
```json
{
    "detector_model": "scrfd_buffalo_l",
    "recognition_model": "mock_arcface_r50",
    "embedding_dimension": 512,
    "preprocessing_version": "synthetic_v1",
    "threshold_version": "v0_mock_uncalibrated"
}
```

## POST `/api/v1/embed`
Generates embeddings from an image. Primary endpoint for the backend during student enrollment or login before querying Postgres pgvector.
**Request**: 
- `file`: `multipart/form-data` image file.

**Response**:
```json
{
    "status": "success",
    "faces": [
        {
            "bbox": [10.5, 20.1, 100.5, 120.3],
            "confidence": 0.99,
            "quality_score": 0.85
        }
    ],
    "embeddings": [
        [0.012, -0.045, ...]
    ],
    "dimension": 512,
    "model_version": "mock_arcface_r50",
    "preprocessing_version": "synthetic_v1",
    "processing_time_ms": 14.2
}
```

## POST `/api/v1/recognize`
Performs stateless identification given an image and a set of candidate embeddings.
**Request**:
- `file`: `multipart/form-data` image file.
- `candidates_json`: Form field containing stringified JSON mapping identities to enrollment vectors. Example: `{"student_1": [[0.1, ...]], "student_2": [[0.2, ...]]}`

**Response**:
```json
{
    "status": "success",
    "faces": [
        {
            "bbox": [...],
            "detection_confidence": 0.99,
            "quality_score": 0.85,
            "candidate_identity": "student_1",
            "similarity": 0.82,
            "decision": "MATCH"
        }
    ],
    "model_version": "mock_arcface_r50",
    "processing_time_ms": 15.5
}
```

## Error Handling
- `400 Bad Request`: Invalid image format, missing file, or invalid JSON.
- `503 Service Unavailable`: Model failed to load.
