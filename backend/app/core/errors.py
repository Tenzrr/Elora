from fastapi import HTTPException


def fail(status: int, code: str, message: str, details=None):
    raise HTTPException(status, detail={"code": code, "message": message, "details": details})
