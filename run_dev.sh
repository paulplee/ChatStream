#!/bin/bash

# Create a logs directory if it doesn't exist
mkdir -p logs

# Start the FastAPI backend with verbose logging
(
    cd backend && \
    python3 -m venv venv && \
    source venv/bin/activate && \
    pip install -r requirements.txt && \
    uvicorn main:app --reload --log-level info --host 0.0.0.0 --port 8000 2>&1 | tee ../logs/backend.log
) &

# Start the Flutter frontend in debug mode with verbose logging
(
    cd frontend && \
    flutter pub get && \
    flutter run -d chrome 2>&1 | tee ../logs/frontend.log
) &

# Wait for both processes to finish
wait
