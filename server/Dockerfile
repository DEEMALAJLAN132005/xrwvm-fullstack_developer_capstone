# React assets are built once and served from Django.
FROM node:20-alpine AS react-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install --no-audit --no-fund
COPY frontend/ ./
ENV CI=false
RUN npm run build

FROM python:3.11-slim-bookworm
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DJANGO_DEBUG=false
WORKDIR /app
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt
COPY . .
COPY --from=react-builder /frontend/build/ /app/frontend/build/
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["/bin/sh", "-c", "python manage.py migrate --noinput && exec gunicorn djangoproj.wsgi:application --bind 0.0.0.0:8000 --workers 1 --timeout 120"]
