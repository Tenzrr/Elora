FROM python:3.12-slim
WORKDIR /srv/elora
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY backend/requirements-runtime.lock /srv/elora/requirements.lock
RUN pip install --no-cache-dir --require-hashes -r requirements.lock
COPY backend /srv/elora/backend
RUN useradd --uid 10001 --create-home elora
USER elora
EXPOSE 8080
CMD ["python", "-m", "uvicorn", "app.main:app", "--app-dir", "backend", "--host", "0.0.0.0", "--port", "8080", "--no-access-log"]
