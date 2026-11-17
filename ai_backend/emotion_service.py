
import re


EMOTION_KEYWORDS = {
    "Happy": [
        "happy", "happier", "joyful", "excited", "great",
        "wonderful", "good mood", "feeling good",
        "santhosham", "santosham", "khush", "khushi",
        "magizhchi", "magizhchiyaga",
        "santosha", "santhoshav"
    ],

    "Sad": [
        "sad", "unhappy", "crying", "depressed",
        "heartbroken", "feeling low", "feeling down",
        "azhugiren", "alugiren", "kashtam",
        "varutham", "dukhi", "udaas", "dil dukhi",
        "vishamam", "vishamama",
        "nannagilla", "manassu vishamam"
    ],

    "Anxious": [
        "anxious", "nervous", "scared", "afraid",
        "fear", "worried", "overthinking",
        "bayama", "bayam", "acham",
        "bhayam", "dar lag", "ghabrahat",
        "peduthunnanu", "bhayavagide",
        "pediyanu"
    ],

    "Stressed": [
        "stressed", "stress", "overwhelmed",
        "pressure", "tension", "exhausted",
        "too much pressure", "can't handle",
        "tumba tension", "romba tension",
        "bahut tension", "valare tension",
        "chala tension", "ottada",
        "manasika samardha"
    ],

    "Angry": [
        "angry", "anger", "furious", "irritated",
        "annoyed", "frustrated", "mad",
        "kovam", "kobam", "kopam",
        "gussa", "krodha", "deshyam",
        "kopam varuthu"
    ]
}


def detect_emotion(text: str):
    message = text.casefold().strip()

    if not message:
        return {
            "emotion": "Neutral",
            "confidence": "Low",
            "method": "Keyword baseline"
        }

    # Replace punctuation with spaces for easier matching.
    normalised_message = re.sub(
        r"[^a-z0-9\s]",
        " ",
        message
    )

    normalised_message = re.sub(
        r"\s+",
        " ",
        normalised_message
    ).strip()

    scores = {}

    for emotion, keywords in EMOTION_KEYWORDS.items():
        score = 0

        for keyword in keywords:
            keyword = keyword.casefold()

            # Match complete phrases or words.
            pattern = r"(?<!\w)" + re.escape(keyword) + r"(?!\w)"

            if re.search(pattern, normalised_message):
                score += 1

        scores[emotion] = score

    best_emotion = max(scores, key=scores.get)

    if scores[best_emotion] == 0:
        best_emotion = "Neutral"

    return {
        "emotion": best_emotion,
        "confidence": "Low",
        "method": "Multilingual keyword baseline"
    }
