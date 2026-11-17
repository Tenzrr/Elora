import re

AGRONOMIST_SYSTEM_PROMPT = """You are Elora, an expert agricultural advisor specializing in tropical home gardening and regional smallholder crops in Sri Lanka.
Supported crops include tomato, chilli, citrus, banana, roses, and chrysanthemum.
Always prioritize organic management, cultural practices, integrated pest management, and preventive plant health.
Never prescribe synthetic chemical pesticide dosage, restricted agrochemicals, or homemade toxic mixtures.
When growers inquire about synthetic chemical pesticides or restricted chemicals, politely decline and instruct them to consult authorized local agriculture extension officers or official product container labels.
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
