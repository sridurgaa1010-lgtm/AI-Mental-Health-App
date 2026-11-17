
from fastapi import FastAPI
from pydantic import BaseModel, Field

from language_service import detect_language
from emotion_service import detect_emotion
from ml_emotion_service import predict_emotion
from intent_service import detect_intent
from response_service import generate_reply


app = FastAPI(
    title="Supportify AI Backend",
    description="Multilingual student mental wellness support API",
    version="1.6.0"
)


class ChatTurn(BaseModel):
    role: str
    content: str


class StudentMessage(BaseModel):
    message: str
    language: str | None = None
    conversation_history: list[ChatTurn] = Field(default_factory=list)


@app.get("/")
def home():
    return {
        "message": "Welcome to Supportify AI Backend!",
        "status": "running"
    }


@app.post("/detect-language")
def detect_student_language(data: StudentMessage):
    return detect_language(data.message)


@app.post("/detect-emotion")
def detect_student_emotion(data: StudentMessage):
    return detect_emotion(data.message)


@app.post("/predict-emotion")
def predict_student_emotion(data: StudentMessage):
    return predict_emotion(data.message)


@app.post("/detect-intent")
def detect_student_intent(data: StudentMessage):
    return detect_intent(data.message)


@app.post("/chat")
def chat(data: StudentMessage):

    language_result = detect_language(data.message)
    emotion_result = detect_emotion(data.message)
    intent_result = detect_intent(data.message)

    history = [
        turn.model_dump()
        for turn in data.conversation_history[-10:]
    ]

    response_result = generate_reply(
        data.message,
        language_result,
        emotion_result,
        intent_result,
        history
    )

    return {
        "student_message": data.message,
        "detected_language": language_result["language"],
        "detected_languages": language_result["languages"],
        "detected_emotion": emotion_result["emotion"],
        "detected_intent": intent_result["intent"],
        "reply": response_result["reply"],
        "response_language": response_result["response_language"],
        "response_style": response_result["response_style"]
    }
