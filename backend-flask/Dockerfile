FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

FROM python:3.10-slim-buster

WORKDIR /backend-flask


COPY execute_script.sh ./usr/local/bin/


ENV FLASK_ENV=development

EXPOSE ${PORT}

CMD [ "/usr/local/bin/execute_script"]
