# Helpers

Vapor `Request` extensions for form handling.

## Extensions

| Extension | Description |
|-----------|-------------|
| `Request+FormDetection` | Detect form submissions and HTML expectations |
| `Request+FormDecoding` | Decode and validate form data |

## Request+FormDetection

| Property | Type | Description |
|----------|------|-------------|
| `isFormSubmission` | `Bool` | True if Content-Type is form-urlencoded or multipart |
| `isWaitingForHTML` | `Bool` | True if Accept header contains text/html |

## Request+FormDecoding

| Method | Description |
|--------|-------------|
| `decodeContentAsFormOfType(_:)` | Decode request body as form, validate |
| `decodeQueryAsFormOfType(_:)` | Decode query params as form, validate |
