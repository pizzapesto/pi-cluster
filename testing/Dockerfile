FROM python:3.13-slim

WORKDIR /app

COPY testing/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY testing/app ./app

CMD [ "python", "app/main.py" ]