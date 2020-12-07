FROM python:3.8-slim

WORKDIR /code

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY secret-key.config .

EXPOSE 30000

CMD ["python", "app.py", "30000"]