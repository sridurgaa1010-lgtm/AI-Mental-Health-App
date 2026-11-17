
def generate_reply(
    message,
    language_result,
    emotion_result,
    intent_result,
    conversation_history=None
):
    languages = language_result.get("languages", [])
    language_method = language_result.get("method", "")

    supported_languages = [
        "Kannada", "Malayalam", "Hindi",
        "Tamil", "Telugu"
    ]

    language = next(
        (lang for lang in languages if lang in supported_languages),
        "English"
    )

    emotion = emotion_result.get("emotion", "Neutral")

    romanised = (
        "Romanised" in language_method
        or (
            language_result.get("language") == "Mixed"
            and language_method != "Script detection"
        )
    )

    history = conversation_history or []

    previous_user_messages = [
        turn.get("content", "")
        for turn in history
        if turn.get("role") == "user"
    ]

    previous_context = " ".join(previous_user_messages).lower()
    current_message = message.lower().strip()

    # Detect common follow-up questions.
    followup_phrases = [
        "enna pannalam",
        "enna panlam",
        "enna panrathu",
        "enna seiyanum",
        "epdi panrathu",
        "epdi overcome panrathu",
        "what should i do",
        "what can i do",
        "how can i handle",
        "how to overcome",
        "any suggestions",
        "any solution",
        "how do i manage",
        "then what",
        "and then",
        "next what",
        "what now",
        "how to solve",
        "solution enna",
        "adhukku enna",
        "athu epdi",
        "help me"
    ]

    is_followup = any(
        phrase in current_message
        for phrase in followup_phrases
    )

    # Understand the previous conversation topic.
    exam_context = any(
        word in previous_context
        for word in [
            "exam", "test", "study", "studies",
            "marks", "syllabus", "revision",
            "assignment", "college", "exam stress"
        ]
    )

    stress_context = any(
        word in previous_context
        for word in [
            "stress", "tension", "pressure",
            "overwhelmed", "worried", "anxious",
            "nervous", "bayam", "kavalai"
        ]
    )

    # Contextual follow-up responses.
    followup_replies = {
        "English": {
            "exam": (
                "Let's make your exam preparation easier. "
                "First, choose one small topic. Study it for "
                "25 minutes, take a 5-minute break, and then "
                "try a few practice questions. Which subject "
                "is worrying you the most?"
            ),
            "general": (
                "Let's figure it out together. Start with one "
                "small step instead of trying to solve everything "
                "at once. Tell me a little more about what is "
                "happening, and we can work through it."
            )
        },
        "Tamil": {
            "roman": (
                "Seri, namma simple-ah start pannalam. "
                "First oru small topic choose pannu. "
                "25 minutes padichittu 5 minutes break edu. "
                "Apram konjam questions practice pannu. "
                "Endha subject unakku romba kashtama irukku?"
            ),
            "native": (
                "சரி, எளிமையாகத் தொடங்கலாம். முதலில் ஒரு சிறிய "
                "பகுதியைத் தேர்ந்தெடு. 25 நிமிடங்கள் படித்துவிட்டு "
                "5 நிமிடங்கள் ஓய்வெடு. பிறகு சில கேள்விகளைப் "
                "பயிற்சி செய். எந்தப் பாடம் உனக்குக் கடினமாக "
                "இருக்கிறது?"
            )
        },
        "Kannada": {
            "roman": (
                "Sari, naavu simple aagi start maadona. "
                "Modalu ondu chikka topic choose maadu. "
                "25 minutes odi, 5 minutes break tegeduko. "
                "Aamele kelavu questions practice maadu. "
                "Yava subject ninge kashta aagta ide?"
            ),
            "native": (
                "ಸರಿ, ಸರಳವಾಗಿ ಪ್ರಾರಂಭಿಸೋಣ. ಮೊದಲು ಒಂದು ಚಿಕ್ಕ "
                "ವಿಷಯವನ್ನು ಆಯ್ಕೆಮಾಡು. 25 ನಿಮಿಷ ಓದಿ, 5 ನಿಮಿಷ "
                "ವಿರಾಮ ತೆಗೆದುಕೊ. ನಂತರ ಕೆಲವು ಪ್ರಶ್ನೆಗಳನ್ನು "
                "ಅಭ್ಯಾಸ ಮಾಡು. ಯಾವ ವಿಷಯ ನಿನಗೆ ಕಷ್ಟವಾಗುತ್ತಿದೆ?"
            )
        },
        "Malayalam": {
            "roman": (
                "Sheri, namukku simple aayi start cheyyam. "
                "Aadyam oru cheriya topic choose cheyyu. "
                "25 minutes padichittu 5 minutes break edukku. "
                "Pinne kurachu questions practice cheyyu. "
                "Eth subject aanu ninakku kooduthal budhimuttu?"
            ),
            "native": (
                "ശരി, നമുക്ക് ലളിതമായി തുടങ്ങാം. ആദ്യം ഒരു ചെറിയ "
                "വിഷയം തിരഞ്ഞെടുക്കൂ. 25 മിനിറ്റ് പഠിച്ച ശേഷം "
                "5 മിനിറ്റ് വിശ്രമിക്കൂ. പിന്നീട് കുറച്ച് ചോദ്യങ്ങൾ "
                "പരിശീലിക്കൂ. ഏത് വിഷയമാണ് നിനക്ക് കൂടുതൽ "
                "ബുദ്ധിമുട്ടായി തോന്നുന്നത്?"
            )
        },
        "Hindi": {
            "roman": (
                "Chalo, simple tareeke se shuru karte hain. "
                "Pehle ek chhota topic choose karo. "
                "25 minutes padho aur 5 minutes break lo. "
                "Phir kuch questions practice karo. "
                "Kaunsa subject tumhe sabse zyada difficult lag raha hai?"
            ),
            "native": (
                "चलो, आसान तरीके से शुरू करते हैं। पहले एक छोटा "
                "विषय चुनो। 25 मिनट पढ़ो और 5 मिनट आराम करो। "
                "फिर कुछ सवालों का अभ्यास करो। तुम्हें कौन-सा "
                "विषय सबसे मुश्किल लग रहा है?"
            )
        },
        "Telugu": {
            "roman": (
                "Sare, simple ga start cheddam. Mundu oka "
                "chinna topic choose chesuko. 25 minutes "
                "chaduvukoni 5 minutes break teesuko. "
                "Tarvata konni questions practice cheyyi. "
                "Neeku ye subject ekkuva kastanga undi?"
            ),
            "native": (
                "సరే, సులభంగా ప్రారంభిద్దాం. ముందుగా ఒక చిన్న "
                "విషయాన్ని ఎంచుకో. 25 నిమిషాలు చదివి 5 నిమిషాలు "
                "విరామం తీసుకో. తర్వాత కొన్ని ప్రశ్నలను సాధన చేయి. "
                "నీకు ఏ విషయం ఎక్కువ కష్టంగా అనిపిస్తోంది?"
            )
        }
    }

    if is_followup and previous_user_messages:
        style = "roman" if romanised else "native"

        if language == "English":
            reply = followup_replies["English"][
                "exam" if exam_context else "general"
            ]
        elif exam_context or stress_context:
            reply = followup_replies[language][style]
        else:
            reply = followup_replies[language][style]

        return {
            "reply": reply,
            "response_language": language,
            "response_style": "Romanised" if romanised else "Native script"
        }

    replies = {
        "English": {
            "Sad": "I'm sorry you're feeling this way. Do you want to tell me what happened? We can take it one step at a time.",
            "Stressed": "It sounds like things feel overwhelming right now. Let's slow down and handle one thing at a time.",
            "Anxious": "It's okay to feel worried sometimes. Take a slow breath. What's making you feel this way?",
            "Angry": "It sounds like something has really upset you. Would you like to talk about it?",
            "Happy": "That's lovely to hear! What made your day better?",
            "Neutral": "I'm here to listen. What's on your mind?"
        },
        "Tamil": {
            "roman": {
                "Sad": "Aiyo, ipdi feel panradhu kashtama irukkum. Enna nadandhuchu nu solluviya?",
                "Stressed": "Romba tension-ah irukka pola. Konjam relax pannalam. Oru vishayama paathukalam.",
                "Anxious": "Bayapadadha, konjam deep breath edu. Unakku enna worry-ah irukku?",
                "Angry": "Edho unnai romba upset pannirukku pola. Enna aachu nu solluviya?",
                "Happy": "Super! Unakku happy-ah irukka enna nadandhuchu?",
                "Neutral": "Un manasula enna irukku? Naan kekkuren."
            },
            "native": {
                "Sad": "இப்படி உணர்வது கஷ்டமாக இருக்கலாம். என்ன நடந்தது என்று சொல்ல விரும்புகிறாயா?",
                "Stressed": "நிறைய அழுத்தமாக உணர்கிறாய் போல. கொஞ்சம் ஓய்வெடுத்து, ஒவ்வொன்றாகப் பார்த்துக்கொள்ளலாம்.",
                "Anxious": "கவலையாக இருப்பது பரவாயில்லை. மெதுவாக மூச்சை இழுத்து விடு. என்ன கவலை?",
                "Angry": "ஏதோ உன்னை மிகவும் வருத்தப்படுத்தியிருக்கிறது போல. என்ன நடந்தது?",
                "Happy": "அருமை! உனக்கு மகிழ்ச்சியைத் தந்தது என்ன?",
                "Neutral": "உன் மனதில் என்ன இருக்கிறது? நான் கேட்கத் தயாராக இருக்கிறேன்."
            }
        },
        "Kannada": {
            "roman": {
                "Sad": "Ayyo, hinge feel aagodu kashta. En aaythu anta heltiya?",
                "Stressed": "Tumba tension aagta ide anisutte. Swalpa relax aagu. Ondondagi nodona.",
                "Anxious": "Chinte maadbeda, nidhaanavaagi usiru tegeduko.",
                "Angry": "Yaaro athava yeno ninna upset maadide anisutte. En aaythu?",
                "Happy": "Chennagide! Ninge khushi aagiddu yaavudrinda?",
                "Neutral": "Ninna manasalli en ide? Naanu kelthini."
            },
            "native": {
                "Sad": "ಹೀಗೆ ಅನಿಸುವುದು ಕಷ್ಟವಾಗಿರಬಹುದು. ಏನಾಯಿತು ಎಂದು ಹೇಳುತ್ತೀಯಾ?",
                "Stressed": "ತುಂಬಾ ಒತ್ತಡದಲ್ಲಿರುವಂತೆ ಕಾಣುತ್ತದೆ. ಸ್ವಲ್ಪ ವಿಶ್ರಾಂತಿ ತೆಗೆದುಕೊಳ್ಳೋಣ.",
                "Anxious": "ಚಿಂತೆಯಾಗುವುದು ಸಹಜ. ನಿಧಾನವಾಗಿ ಉಸಿರಾಡು. ನಿನಗೆ ಏನು ಚಿಂತೆ?",
                "Angry": "ಏನೋ ನಿನ್ನನ್ನು ಬೇಸರಗೊಳಿಸಿದೆ ಅನಿಸುತ್ತದೆ. ಏನಾಯಿತು?",
                "Happy": "ಚೆನ್ನಾಗಿದೆ! ನಿನಗೆ ಸಂತೋಷ ತಂದದ್ದು ಯಾವುದು?",
                "Neutral": "ನಿನ್ನ ಮನಸ್ಸಿನಲ್ಲಿ ಏನಿದೆ? ನಾನು ಕೇಳುತ್ತೇನೆ."
            }
        },
        "Malayalam": {
            "roman": {
                "Sad": "Ayyo, ingane feel cheyyunnathu budhimuttayirikkum. Entha sambhavichathu?",
                "Stressed": "Valare tension undennu thonnunnu. Kurachu relax cheyyam. Oru karyam veetham nokkam.",
                "Anxious": "Pedikkenda, pathukke shwasam edukku. Enthaanu ninne worry aakkunnathu?",
                "Angry": "Entho ninne vishamippichittundu ennu thonnunnu. Entha sambhavichathu?",
                "Happy": "Adipoli! Ninakku santhosham thannathu enthaanu?",
                "Neutral": "Ninte manassil enthaanu? Njan kelkkam."
            },
            "native": {
                "Sad": "ഇങ്ങനെ തോന്നുന്നത് ബുദ്ധിമുട്ടായിരിക്കാം. എന്താണ് സംഭവിച്ചത്?",
                "Stressed": "വളരെയധികം സമ്മർദ്ദം അനുഭവപ്പെടുന്നുണ്ടെന്ന് തോന്നുന്നു. കുറച്ച് വിശ്രമിക്കാം.",
                "Anxious": "പേടിക്കേണ്ട, പതുക്കെ ശ്വാസമെടുക്കൂ. എന്താണ് നിന്നെ വിഷമിപ്പിക്കുന്നത്?",
                "Angry": "എന്തോ നിന്നെ വിഷമിപ്പിച്ചെന്ന് തോന്നുന്നു. എന്താണ് സംഭവിച്ചത്?",
                "Happy": "അടിപൊളി! നിനക്ക് സന്തോഷം നൽകിയ കാര്യം എന്താണ്?",
                "Neutral": "നിന്റെ മനസ്സിൽ എന്താണ്? ഞാൻ കേൾക്കാം."
            }
        },
        "Hindi": {
            "roman": {
                "Sad": "Aisa feel karna mushkil ho sakta hai. Kya hua? Tum mujhse baat kar sakte ho.",
                "Stressed": "Lagta hai tum par bahut pressure hai. Thoda relax karo. Ek-ek cheez sambhalte hain.",
                "Anxious": "Chinta hona normal hai. Dheere se saans lo. Kis baat ki tension hai?",
                "Angry": "Lagta hai kisi baat ne tumhe pareshan kiya hai. Kya hua?",
                "Happy": "Bahut achha! Aaj tumhe kis baat se khushi mili?",
                "Neutral": "Tumhare mann mein kya chal raha hai? Main sun raha hoon."
            },
            "native": {
                "Sad": "ऐसा महसूस करना मुश्किल हो सकता है। क्या हुआ? अगर चाहो तो मुझसे बात कर सकते हो।",
                "Stressed": "लगता है तुम पर बहुत दबाव है। थोड़ा आराम करो। एक-एक करके सब संभालते हैं।",
                "Anxious": "चिंता होना सामान्य है। धीरे से साँस लो। किस बात की चिंता है?",
                "Angry": "लगता है किसी बात ने तुम्हें परेशान किया है। क्या हुआ?",
                "Happy": "बहुत अच्छा! आज तुम्हें किस बात से खुशी मिली?",
                "Neutral": "तुम्हारे मन में क्या चल रहा है? मैं सुन रहा हूँ।"
            }
        },
        "Telugu": {
            "roman": {
                "Sad": "Ila feel avvadam kastanga undochu. Em jarigindi? Natho cheppukovachu.",
                "Stressed": "Chala tension ga unnattu undi. Konchem relax avvu. Okkokati chuskundam.",
                "Anxious": "Bayapadaku, mellaga oopiri teesuko. Neeku deni gurinchi worry ga undi?",
                "Angry": "Edho ninnu baadha pettinattu undi. Em jarigindi?",
                "Happy": "Chala bagundi! Neeku santosham kaliginchindi enti?",
                "Neutral": "Nee manasulo em undi? Nenu vintanu."
            },
            "native": {
                "Sad": "ఇలా అనిపించడం కష్టంగా ఉండవచ్చు. ఏమైంది? నీకు ఇష్టమైతే నాతో చెప్పుకోవచ్చు.",
                "Stressed": "చాలా ఒత్తిడిగా ఉన్నట్లు ఉంది. కొంచెం విశ్రాంతి తీసుకో. ఒక్కొక్కటిగా చూసుకుందాం.",
                "Anxious": "భయపడకు, నెమ్మదిగా శ్వాస తీసుకో. నీకు దేని గురించి ఆందోళనగా ఉంది?",
                "Angry": "ఏదో నిన్ను బాధపెట్టినట్లు ఉంది. ఏమైంది?",
                "Happy": "చాలా బాగుంది! నీకు సంతోషాన్ని కలిగించింది ఏమిటి?",
                "Neutral": "నీ మనసులో ఏముంది? నేను వింటాను."
            }
        }
    }

    if language == "English":
        reply = replies["English"].get(
            emotion,
            replies["English"]["Neutral"]
        )
    else:
        style = "roman" if romanised else "native"
        reply = replies[language][style].get(
            emotion,
            replies[language][style]["Neutral"]
        )

    return {
        "reply": reply,
        "response_language": language,
        "response_style": "Romanised" if romanised else "Native script"
    }
