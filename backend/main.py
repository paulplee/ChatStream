from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import openai
import os
from dotenv import load_dotenv
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

app = FastAPI()
model = "gpt-4o-mini"
# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Load OpenAI API key from environment variable
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    logger.error("OpenAI API key is missing. Please set it in the .env file.")
    raise ValueError("OpenAI API key is missing")


if hasattr(openai, "OpenAI"):  # New version (1.x.x)
    client = openai.OpenAI(api_key=api_key)
else:  # Old version (0.x.x)
    openai.api_key = api_key


@app.websocket("/chat")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    logger.info("WebSocket connection established")
    while True:
        try:
            # Receive and send back the client message
            question = await websocket.receive_text()
            logger.info(f"Received question: {question}")
            await websocket.send_text(f"User: {question}")

            # Create a chat completion with streaming
            logger.info("Calling OpenAI API")
            if hasattr(openai, "OpenAI"):  # New version (1.x.x)
                stream = client.chat.completions.create(
                    model=model,
                    messages=[{"role": "user", "content": question}],
                    stream=True,
                )
                # Stream the response
                logger.info("Streaming response from OpenAI")
                for chunk in stream:
                    if chunk.choices[0].delta.content is not None:
                        content = chunk.choices[0].delta.content
                        await websocket.send_text(content)
                        logger.debug(f"Sent chunk: {content}")
            else:  # Old version (0.x.x)
                stream = openai.ChatCompletion.create(
                    model=model,
                    messages=[{"role": "user", "content": question}],
                    stream=True,
                )
                # Stream the response
                logger.info("Streaming response from OpenAI")
                for chunk in stream:
                    if chunk["choices"][0]["delta"].get("content"):
                        content = chunk["choices"][0]["delta"]["content"]
                        await websocket.send_text(content)
                        logger.debug(f"Sent chunk: {content}")

            # Send a newline to indicate the end of the response
            await websocket.send_text("\n")
            logger.info("Finished streaming response")

        except Exception as e:
            logger.error(f"Error in WebSocket connection: {str(e)}")
            await websocket.close()
            break


if __name__ == "__main__":
    import uvicorn

    logger.info("Starting FastAPI server")
    uvicorn.run(app, host="0.0.0.0", port=8000)
