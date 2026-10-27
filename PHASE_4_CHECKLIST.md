# Phase 4 Checklist

- [x] Evaluate ArcFace models and select primary (ResNet-50 / w600k_r50)
- [x] Verify embedding dimensionality (512)
- [x] Document input preprocessing rules (112x112, BGR->RGB, (x-127.5)/127.5)
- [x] Implement robust FaceEmbedding internal data structure
- [x] Implement L2 Normalization check
- [x] Implement Cosine Similarity metric
- [x] Implement multi-enrollment Max-Similarity matching strategy
- [x] Validate numerical stability (no NaN/Inf)
- [x] Write Unit Tests for similarity, matcher, and embeddings
- [x] Benchmark embedding latency and throughput
- [x] Define Phase 5 integration contract
- [x] Acknowledge threshold selection is deferred to Phase 6
- [x] DO NOT start Phase 5 automatically
