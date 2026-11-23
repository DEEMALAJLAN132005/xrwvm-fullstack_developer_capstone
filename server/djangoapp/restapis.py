"""HTTP clients for the dealership and sentiment-analysis microservices."""
import logging
import os
from urllib.parse import quote

import requests
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

backend_url = os.getenv('backend_url', 'http://localhost:3030').strip().rstrip('/')
sentiment_analyzer_url = os.getenv(
    'sentiment_analyzer_url', 'http://localhost:5050'
).strip().rstrip('/')


def get_request(endpoint, **kwargs):
    """Request JSON from the Express/MongoDB dealer microservice."""
    url = backend_url + '/' + endpoint.lstrip('/')
    try:
        response = requests.get(url, params=kwargs, timeout=15)
        response.raise_for_status()
        return response.json()
    except (requests.RequestException, ValueError) as error:
        logger.error('Dealer request failed: %s (%s)', url, error)
        return None


def analyze_review_sentiments(text):
    """Get positive, neutral or negative classification for review text."""
    url = sentiment_analyzer_url + '/analyze/' + quote(str(text), safe='')
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        return response.json()
    except (requests.RequestException, ValueError) as error:
        logger.error('Sentiment request failed: %s (%s)', url, error)
        return {'sentiment': 'neutral'}


def post_review(data_dict):
    """Insert a review in MongoDB via Express."""
    url = backend_url + '/insert_review'
    try:
        response = requests.post(url, json=data_dict, timeout=20)
        response.raise_for_status()
        return response.json()
    except (requests.RequestException, ValueError) as error:
        logger.error('Posting review failed: %s', error)
        return None
