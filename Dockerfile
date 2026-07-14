FROM python:3.12-alpine
WORKDIR /app
COPY . .
ENV PORT=10000
EXPOSE 10000
CMD ["sh", "-c", "python -m http.server $PORT"]
