
INTENT_KEYWORDS = {
    "Exam Support": [
        "exam", "exams", "test", "results", "marks",
        "revision", "ಪರೀಕ್ಷೆ", "परीक्षा", "தேர்வு",
        "పరీక్ష", "പരീക്ഷ"
    ],

    "Focus Support": [
        "concentrate", "concentration", "focus",
        "distracted", "procrastinating", "can't study",
        "cannot study", "ಏಕಾಗ್ರತೆ", "ध्यान",
        "கவனம்", "ఏకాగ్రత", "ശ്രദ്ധ"
    ],

    "Emotional Support": [
        "overwhelmed", "stressed", "stress", "anxious",
        "worried", "sad", "lonely", "ಒತ್ತಡ", "ದುಃಖ",
        "तनाव", "चिंता", "സമ്മർദ്ദം", "கவலை", "బాధ"
    ],

    "Journaling": [
        "write", "journal", "express", "share my feelings",
        "ದಿನಚರಿ", "लिखना", "எழுத", "రాయాలి", "എഴുതാൻ"
    ],

    "Relaxation": [
        "relax", "breathing", "calm", "peaceful",
        "ಶಾಂತ", "आराम", "அமைதி", "ప్రశాంతత", "ശാന്തം"
    ]
}


def detect_intent(text: str):
    message = text.casefold()

    scores = {}

    for intent, keywords in INTENT_KEYWORDS.items():
        scores[intent] = sum(
            1 for keyword in keywords
            if keyword.casefold() in message
        )

    # Give focus-related phrases priority when they match.
    if scores["Focus Support"] > 0:
        return {
            "intent": "Focus Support",
            "method": "Keyword baseline"
        }

    best_intent = max(scores, key=scores.get)

    if scores[best_intent] == 0:
        return {
            "intent": "General Conversation",
            "method": "Keyword baseline"
        }

    return {
        "intent": best_intent,
        "method": "Keyword baseline"
    }
