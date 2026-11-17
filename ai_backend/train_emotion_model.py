
import os
import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report


# Load both datasets
english_data = pd.read_csv("data/emotion_samples.csv")
multilingual_data = pd.read_csv("data/multilingual_emotion_samples.csv")

data = pd.concat(
    [english_data, multilingual_data],
    ignore_index=True
)

# Remove duplicate and empty rows
data = data.dropna(subset=["text", "emotion"])
data = data.drop_duplicates()

print("Combined dataset loaded!")
print("Total examples:", len(data))
print("\nEmotion distribution:")
print(data["emotion"].value_counts())


# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(
    data["text"],
    data["emotion"],
    test_size=0.2,
    random_state=42,
    stratify=data["emotion"]
)


# Build the ML pipeline
model = Pipeline([
    (
        "tfidf",
        TfidfVectorizer(
            analyzer="char",
            ngram_range=(2, 5),
            max_features=10000
        )
    ),
    (
        "classifier",
        LogisticRegression(max_iter=1000)
    )
])


# Train
print("\nTraining multilingual emotion model...")
model.fit(X_train, y_train)


# Evaluate
predictions = model.predict(X_test)

print("\nModel evaluation")
print("----------------")
print(f"Accuracy: {accuracy_score(y_test, predictions):.2%}")

print("\nClassification report:")
print(classification_report(
    y_test,
    predictions,
    zero_division=0
))


# Save model
os.makedirs("models", exist_ok=True)

joblib.dump(
    model,
    "models/emotion_model.pkl"
)

print("\nMultilingual model saved successfully!")
