from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import openai
import os
from dotenv import load_dotenv
import logging
from typing_extensions import override
from openai import OpenAI, AssistantEventHandler

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
project_id = os.getenv("OPENAI_PROJECT_ID")

if not api_key:
    logger.error("OpenAI API key is missing. Please set it in the .env file.")
    raise ValueError("OpenAI API key is missing")

client = OpenAI(api_key=api_key, project=project_id)

thread_id = "thread_9i2XlaaHde1L2qlOBlThc4l0"
assistant_id = "asst_4dY2Iow6NOAFcDfnUaKWPPK2"

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

            # Send a newline to indicate the end of the response
            await websocket.send_text("\n")
            logger.info("Finished streaming response")

        except Exception as e:
            logger.error(f"Error in WebSocket connection: {str(e)}")
            await websocket.close()
            break

class WebSocketEventHandler(AssistantEventHandler):
    def __init__(self, websocket: WebSocket):
        self.websocket = websocket

    @override
    async def on_text_created(self, text) -> None:
        await self.websocket.send_text("\nassistant > ")
      
    @override
    async def on_text_delta(self, delta, snapshot):
        await self.websocket.send_text(delta.value)
      
    async def on_tool_call_created(self, tool_call):
        await self.websocket.send_text(f"\nassistant > {tool_call.type}\n")
  
    async def on_tool_call_delta(self, delta, snapshot):
        if delta.type == 'code_interpreter':
            if delta.code_interpreter.input:
                await self.websocket.send_text(delta.code_interpreter.input)
            if delta.code_interpreter.outputs:
                await self.websocket.send_text("\n\noutput >")
                for output in delta.code_interpreter.outputs:
                    if output.type == "logs":
                        await self.websocket.send_text(f"\n{output.logs}")

@app.websocket("/asst")
async def assistant_websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    logger.info("Assistant WebSocket connection established")
    
    while True:
        try:
            # Receive the client message
            user_input = await websocket.receive_text()
            logger.info(f"Received input: {user_input}")

            # Create a message in the thread
            message = client.beta.threads.messages.create(
                thread_id=thread_id,
                role="user",
                content=user_input
            )

            # Create a run with the assistant
            run = client.beta.threads.runs.create(
                thread_id=thread_id,
                assistant_id=assistant_id,
            )

            # Create an event handler for WebSocket
            event_handler = WebSocketEventHandler(websocket)

            # Stream the response
            logger.info("Streaming response from OpenAI Assistant")
            with client.beta.threads.runs.stream(
                thread_id=thread_id,
                assistant_id=assistant_id,
                event_handler=event_handler,
            ) as stream:
                await stream.until_done()

            # Send a newline to indicate the end of the response
            await websocket.send_text("\n")
            logger.info("Finished streaming Assistant response")

        except Exception as e:
            logger.error(f"Error in Assistant WebSocket connection: {str(e)}")
            await websocket.close()
            break

if __name__ == "__main__":
    import uvicorn

    logger.info("Starting FastAPI server")
    uvicorn.run(app, host="0.0.0.0", port=8000)
