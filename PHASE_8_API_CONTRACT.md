# Backend API Contract

## GET /api/health
```json
{
  "status": "ONLINE",
  "service": "Backend"
}
```

## GET /api/ml/health
```json
{
  "status": "ONLINE",
  "service": "ML Service"
}
```

## POST /api/students/register
**Request:** `multipart/form-data` containing `student_id`, `name`, and exactly five camera-captured image frames under the repeated `files` field. Each frame must contain exactly one detectable student face. The student and all embeddings are committed together; invalid samples do not create a partial student.

**Response:**
```json
{
  "student_id": "STU123",
  "name": "Jane Doe",
  "id": "uuid...",
  "status": "ACTIVE",
  "created_at": "2026-10-07T00:00:00Z"
}
```

## DELETE /api/students/{id}
Admin-only. Permanently deletes the student, enrolled face samples, and attendance records for that student. Returns `204 No Content`; returns `404` if the student does not exist.

## POST /api/students/{id}/enroll
**Request:** `multipart/form-data` with one camera-captured frame in `file`.

**Response:**
```json
{
  "status": "success",
  "message": "Face embedding enrolled successfully",
  "quality_score": 0.95,
  "model_version": "mock_arcface_r50"
}
```

## POST /api/recognize/
**Request:**
`multipart/form-data` with image `file`.

**Response:**
```json
{
  "status": "success",
  "faces": [
    {
      "student_id": "uuid...",
      "student_record_id": "STU123",
      "name": "Jane Doe",
      "similarity": 0.82,
      "decision": "MATCH"
    }
  ]
}
```
