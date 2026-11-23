FROM python:3.9.18-slim-bookworm


WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
RUN python3 -m nltk.downloader -d /usr/local/nltk_data vader_lexicon
ENV NLTK_DATA=/usr/local/nltk_data
COPY . .
RUN ls
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
