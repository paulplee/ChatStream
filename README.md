# ChatStream

ChatStream is a chat application that uses OpenAI's Assistant API to answer user questions. This project serves as a technical demo, showcasing best practices in architecture and coding for similar projects in the future.

## Technologies Used

- Backend:
  - FastAPI (Python)
  - WebSockets for real-time communication
  - OpenAI API for generating responses
- Frontend:
  - Flutter (Dart) for cross-platform support
  - Provider package for state management
  - WebSocket for real-time communication with the backend

## Features

1. Real-time chat interface
2. Integration with OpenAI's GPT model for generating responses
3. Streaming responses from the AI, displayed word by word
4. Cross-platform support (Web, iOS, Android, macOS, Windows, Linux)
5. Familiar chat interface with chat bubbles and timestamps

## Running the Application Locally

### Prerequisites

- Python 3.7+
- Flutter SDK
- OpenAI API key

### Quick Start

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/chatstream.git
   cd chatstream
   ```

2. Create a `.env` file in the `backend` directory and add your OpenAI API key:
   ```
   echo "OPENAI_API_KEY=your_actual_openai_api_key" > backend/.env
   ```

3. Run the development script:
   ```
   chmod +x run_dev.sh
   ./run_dev.sh
   ```

This script will set up the virtual environment, install dependencies, and start both the backend and frontend servers with verbose logging.

### Logs

The `run_dev.sh` script creates log files for both the backend and frontend in the `logs` directory:

- Backend log: `logs/backend.log`
- Frontend log: `logs/frontend.log`

You can monitor these logs in real-time using the `tail` command:

```
tail -f logs/backend.log
tail -f logs/frontend.log
```

### Manual Setup

If you prefer to set up the backend and frontend separately, follow these steps:

#### Backend Setup

1. Navigate to the `backend` directory:
   ```
   cd backend
   ```

2. Create a virtual environment and activate it:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```

3. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the `backend` directory and add your OpenAI API key:
   ```
   OPENAI_API_KEY=your_actual_openai_api_key
   ```

5. Run the FastAPI server with debug logging:
   ```
   uvicorn main:app --reload --log-level debug
   ```

The backend server will start running on `http://localhost:8000`.

#### Frontend Setup

1. Make sure you have Flutter installed on your system. If not, follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

2. Navigate to the `frontend` directory:
   ```
   cd frontend
   ```

3. Get the required dependencies:
   ```
   flutter pub get
   ```

4. Run the Flutter application in debug mode:
   ```
   flutter run -d chrome --verbose  # For web
   # Or use the appropriate command for your target platform
   ```

The frontend application will start and connect to the backend server.

## Troubleshooting

If you encounter any issues while setting up or running the application, try the following steps:

1. Check the logs:
   - Backend log: `logs/backend.log`
   - Frontend log: `logs/frontend.log`
   Look for any error messages or warnings that might indicate the source of the problem.

2. Ensure that your OpenAI API key is correctly set in the `backend/.env` file.

3. Verify that all required dependencies are installed:
   - For the backend: `pip list`
   - For the frontend: `flutter pub deps`

4. Check if the backend server is running and accessible:
   ```
   curl http://localhost:8000
   ```
   You should receive a response if the server is running.

5. Verify the WebSocket connection:
   - Check the frontend logs for any WebSocket connection errors.
   - Look for "WebSocket connected successfully" message in the logs.

6. Test the OpenAI API connection:
   - Check the backend logs for any API-related errors.
   - Ensure your API key has sufficient credits and permissions.

7. If you're still experiencing issues:
   - Restart both the backend and frontend servers.
   - Clear your browser cache if running the frontend in a web browser.
   - Ensure that your firewall or antivirus software is not blocking the WebSocket connection.

## API Endpoints

The backend exposes a single WebSocket endpoint:

- `/chat`: WebSocket endpoint for real-time chat communication

### Example CURL command for testing the WebSocket connection:

```bash
curl --include \
     --no-buffer \
     --header "Connection: Upgrade" \
     --header "Upgrade: websocket" \
     --header "Host: localhost:8000" \
     --header "Origin: http://localhost:8000" \
     --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
     --header "Sec-WebSocket-Version: 13" \
     http://localhost:8000/chat
```

Note: This CURL command initiates a WebSocket connection but doesn't send or receive messages. For full WebSocket communication, you'll need to use a WebSocket client or the provided Flutter frontend.

## Deployment

This project can be self-hosted or deployed to a public cloud service like AWS or Azure. Make sure to set up the necessary environment variables and adjust the WebSocket URL in the frontend code to match your deployed backend URL.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).