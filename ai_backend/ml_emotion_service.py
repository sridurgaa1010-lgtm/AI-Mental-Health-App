
import joblib
from pathlib import Path

# Find the saved model
MODEL_PATH = (
    Path(__file__).resolve().parent
    / "models"
    / "emotion_model.pkl"
)

# Load the trained model
model = joblib.load(MODEL_PATH)


def predict_emotion(text: str):
    # Predict the emotion
    prediction = model.predict([text])[0]

    # Get the model's highest class score
    probabilities = model.predict_proba([text])[0]
    model_score = float(max(probabilities))

    return {
        "emotion": prediction,
        "model_score": round(model_score, 3),
        "method": "TF-IDF + Logistic Regression",
        "status": "Experimental baseline"
    }
