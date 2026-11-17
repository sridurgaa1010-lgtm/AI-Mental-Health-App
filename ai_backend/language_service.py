
import re
from langdetect import detect, LangDetectException


# Unicode ranges for Indian language scripts
LANGUAGE_RANGES = {
    "Kannada": (0x0C80, 0x0CFF),
    "Malayalam": (0x0D00, 0x0D7F),
    "Hindi": (0x0900, 0x097F),
    "Tamil": (0x0B80, 0x0BFF),
    "Telugu": (0x0C00, 0x0C7F),
}


# Common romanised words and spelling variations
ROMAN_WORDS = {
    "Kannada": [
        "nange", "nanage", "tumba", "thumba",
        "agtide", "agthide", "agutte", "aagutte",
        "illa", "beku", "beda", "yenu", "enu",
        "hegide", "madbeku", "maadbeku"
    ],

    "Malayalam": [
        "enikku", "enik", "njan", "njaan",
        "valare", "aanu", "aane", "undu",
        "illa", "venda", "entha", "engane",
        "sukham", "innu", "pakshe"
    ],

    "Hindi": [
        "mujhe", "mujhko", "main", "mein",
        "mera", "meri", "bahut", "bohot",
        "hai", "hain", "hoon", "nahi",
        "nahin", "kya", "kyun", "kyun",
        "pareshan", "lagta", "lagti",
        "raha", "rahi"
    ],

    "Tamil": [
        "iniku", "inniku", "innaiku", "iniki",
        "enakku", "ennaku", "enaku",
        "naan", "nan", "romba", "ramba",
        "iruken", "eruken", "irukken",
        "irukku", "irukanga", "irukkom",
        "pathi", "patti", "illa",
        "venum", "vendam", "aachu",
        "bayama", "epdi", "eppadi"
    ],

    "Telugu": [
        "naaku", "naku", "nenu", "naaku",
        "chala", "chaala", "baaga", "bagundi",
        "undi", "ledu", "avutundi", "avuthundi",
        "ela", "enti", "enduku", "kavali",
        "kaavali", "ledu"
    ]
}


# Common English words used in code-mixed messages
ENGLISH_WORDS = {
    "i", "am", "is", "are", "was", "the",
    "a", "an", "my", "me", "you", "we",
    "they", "feeling", "sad", "happy",
    "stressed", "anxious", "exam", "exams",
    "study", "studying", "college", "today",
    "tomorrow", "very", "really", "tension",
    "cannot", "can't", "focus", "concentrate",
    "because", "but", "and", "not", "good",
    "bad", "help", "please"
}


def detect_language(text: str):
    message = text.strip().casefold()

    if not message:
        return {
            "language": "Unknown",
            "languages": [],
            "method": "Empty message"
        }

    # Detect languages written in their native scripts
    found_languages = set()

    for character in message:
        code = ord(character)

        for language, (start, end) in LANGUAGE_RANGES.items():
            if start <= code <= end:
                found_languages.add(language)

    has_english_script = bool(re.search(r"[a-zA-Z]", message))

    if found_languages:
        languages = sorted(found_languages)

        if has_english_script:
            languages.append("English")

        if len(languages) > 1:
            return {
                "language": "Mixed",
                "languages": languages,
                "method": "Script detection"
            }

        return {
            "language": languages[0],
            "languages": languages,
            "method": "Script detection"
        }

    # Detect romanised Indian languages
    words = set(re.findall(r"[a-z]+", message))

    language_scores = {}

    for language, keywords in ROMAN_WORDS.items():
        language_scores[language] = sum(
            1 for word in words if word in keywords
        )

    best_language = max(
        language_scores,
        key=language_scores.get
    )

    best_score = language_scores[best_language]

    if best_score > 0:
        languages = [best_language]

        if words.intersection(ENGLISH_WORDS):
            languages.append("English")

        if len(languages) > 1:
            return {
                "language": "Mixed",
                "languages": languages,
                "method": "Romanised keyword detection"
            }

        return {
            "language": best_language,
            "languages": languages,
            "method": "Romanised keyword detection"
        }

    # Fallback for messages written in Latin characters
    try:
        detected = detect(message)

        if detected == "en":
            language = "English"
        else:
            language = detected

        return {
            "language": language,
            "languages": [language],
            "method": "langdetect fallback"
        }

    except LangDetectException:
        return {
            "language": "Unknown",
            "languages": [],
            "method": "Unable to detect"
        }

