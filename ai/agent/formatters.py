import re

LATIN_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
SANS_BOLD_CHARS = "".join(chr(0x1D5D4 + i) for i in range(26)) + "".join(chr(0x1D5EE + i) for i in range(26)) + "".join(chr(0x1D7EC + i) for i in range(10))
BOLD_TRANSLATION_TABLE = str.maketrans(LATIN_CHARS, SANS_BOLD_CHARS)

LATIN_ITALIC_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
SANS_ITALIC_CHARS = "".join(chr(0x1D608 + i) for i in range(26)) + "".join(chr(0x1D622 + i) for i in range(26))
ITALIC_TRANSLATION_TABLE = str.maketrans(LATIN_ITALIC_CHARS, SANS_ITALIC_CHARS)


def to_sans_bold(text: str) -> str:
    return text.translate(BOLD_TRANSLATION_TABLE)


def to_sans_italic(text: str) -> str:
    return text.translate(ITALIC_TRANSLATION_TABLE)


def sanitize_agronomic_text(text: str, is_user_greeting: bool = False) -> str:
    if not text:
        return ""

    lines = [line.strip() for line in text.split("\n")]

    if not is_user_greeting:
        while lines:
            first = lines[0]
            if not first:
                lines.pop(0)
                continue
            if re.match(r"^(ayubowan|hello|hi|vanakkam|greetings|welcome)\b", first, re.IGNORECASE):
                lines.pop(0)
                continue
            if re.match(r"^i am elora\b", first, re.IGNORECASE):
                lines.pop(0)
                continue
            break

    cleaned_lines: list[str] = []
    for line in lines:
        if not line:
            if cleaned_lines and cleaned_lines[-1] != "":
                cleaned_lines.append("")
            continue

        if re.fullmatch(r"[\*\-_]{3,}", line):
            continue

        header_match = re.match(r"^#{1,6}\s+(.*)$", line)
        if header_match:
            hdr = header_match.group(1).strip()
            hdr = re.sub(r"\*\*(.*?)\*\*", r"\1", hdr)
            hdr = re.sub(r"__(.*?)__", r"\1", hdr)
            cleaned_lines.append(to_sans_bold(hdr))
            continue

        bullet_match = re.match(r"^[\*\-•]\s+(.*)$", line)
        if bullet_match:
            body = bullet_match.group(1)
            body = re.sub(r"\*\*(.*?)\*\*", lambda m: to_sans_bold(m.group(1)), body)
            body = re.sub(r"__(.*?)__", lambda m: to_sans_bold(m.group(1)), body)
            body = re.sub(r"\*(.*?)\*", lambda m: to_sans_italic(m.group(1)), body)
            body = re.sub(r"_(.*?)_", lambda m: to_sans_italic(m.group(1)), body)
            cleaned_lines.append(f"• {body}")
            continue

        line = re.sub(r"\*\*(.*?)\*\*", lambda m: to_sans_bold(m.group(1)), line)
        line = re.sub(r"__(.*?)__", lambda m: to_sans_bold(m.group(1)), line)
        line = re.sub(r"\*(.*?)\*", lambda m: to_sans_italic(m.group(1)), line)
        line = re.sub(r"_(.*?)_", lambda m: to_sans_italic(m.group(1)), line)
        cleaned_lines.append(line)

    result = "\n".join(cleaned_lines).strip()
    return re.sub(r"\n{3,}", "\n\n", result)
