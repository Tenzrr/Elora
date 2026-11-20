import re

AGRONOMIST_SYSTEM_PROMPT = """You are Elora, a senior agricultural consultant specializing in tropical crops and home gardens in Sri Lanka.
Supported crops include tomato, chilli, citrus (lime), banana, roses, and chrysanthemum.
Guidelines:
1. Greet with Ayubowan or Hello ONLY when the grower begins with a greeting or asks for an introduction. On specific agricultural questions, never repeat greetings or self introductions; dive straight into the practical advice.
2. Provide concise, direct, and specific answers tailored to the grower's exact question and crop. Limit advice to three to five clear actionable points. Avoid lengthy essays or generic introductions.
3. Formatting rules: Do not output markdown heading symbols (#, ##, ###) or asterisks (*, **). Output clean numbered points or standard bullets. Use Unicode bold or italic styling for key terms when needed.
4. Reference sustainable agronomic practices endorsed by the Department of Agriculture Sri Lanka.
5. Emphasize cultural sanitation, balanced organic compost, proper irrigation, good aeration, and biological pest control.
6. Strictly adhere to safety: never prescribe synthetic pesticide dosages, restricted chemical recipes, or hazardous agrochemicals.
7. When growers ask about chemical sprays or restricted pesticides, advise them to consult their local agricultural instructor (Krushikarma Upadeshaka) or authorized product labels.
"""

RESTRICTED_CHEMICAL_KEYWORDS = [
    r"\bglyphosate\b",
    r"\bcarbofuran\b",
    r"\bparaquat\b",
    r"\bchlorpyrifos\b",
    r"\bmalathion\b",
    r"\bdiazinon\b",
    r"\bmonocrotophos\b",
    r"\bchemical pesticides?\b",
    r"\bchemical spray dosages?\b",
    r"\bsynthetic pesticides?\b",
    r"\bpesticide dosages?\b",
    r"\bfungicide dosages?\b",
    r"\binsecticide dosages?\b",
    r"\bherbicides?\b",
    r"\bweedicides?\b",
    r"\bagrochemicals?\b",
    r"\bchemicals?\s+for\b",
    r"\bchemical\s+(?:treatments?|sprays?|controls?|options?|inputs?|solutions?|mixtures?)\b",
    r"\bsynthetic\s+chemicals?\b",
]

CHEMICAL_SAFETY_REFUSAL_MESSAGE = (
    "For plant safety and environmental protection, Elora does not prescribe synthetic chemical pesticides or chemical spray dosages. "
    "Please consult your local Department of Agriculture extension officer or refer to official certified product labels. "
    "For natural management, we recommend cultural sanitation, organic neem extracts, or biological pest control methods."
)


def is_chemical_pesticide_query(text: str) -> bool:
    normalized = text.lower()
    for pattern in RESTRICTED_CHEMICAL_KEYWORDS:
        if re.search(pattern, normalized):
            return True
    return False


def is_greeting_query(text: str) -> bool:
    normalized = text.lower().strip()
    words = set(re.findall(r"\b\w+\b", normalized))
    if words & {"hello", "hi", "hey", "ayubowan", "vanakkam", "greetings"}:
        return True
    return any(phrase in normalized for phrase in ("good morning", "good afternoon", "good evening", "who are you", "what can you do", "introduce yourself"))
