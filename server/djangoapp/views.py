"""Django JSON endpoints used by the Best Cars React frontend."""
import json
import logging

from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .models import CarMake, CarModel
from .populate import initiate
from .restapis import get_request, analyze_review_sentiments, post_review

logger = logging.getLogger(__name__)


def _json_body(request):
    try:
        data = json.loads(request.body.decode('utf-8'))
        return data if isinstance(data, dict) else {}
    except (ValueError, UnicodeDecodeError):
        return {}


@csrf_exempt
def login_user(request):
    if request.method != 'POST':
        return JsonResponse({'status': 405, 'message': 'Use POST'}, status=405)
    data = _json_body(request)
    username = data.get('userName', '')
    user = authenticate(
        request, username=username, password=data.get('password', '')
    )
    if user is None:
        return JsonResponse(
            {'status': 'Failed', 'message': 'Invalid credentials'}, status=401
        )
    login(request, user)
    return JsonResponse({
        'userName': user.username,
        'firstName': user.first_name,
        'lastName': user.last_name,
        'status': 'Authenticated',
    })


@csrf_exempt
def logout_request(request):
    username = request.user.username if request.user.is_authenticated else ''
    logout(request)
    return JsonResponse({'userName': username, 'status': 'Logged out'})


@csrf_exempt
def registration(request):
    if request.method != 'POST':
        return JsonResponse({'status': 405, 'message': 'Use POST'}, status=405)
    data = _json_body(request)
    username = str(data.get('userName') or data.get('username') or '').strip()
    password = data.get('password', '')
    email = str(data.get('email', '')).strip()
    if not username or not password or not email:
        return JsonResponse({
            'status': 'Failed',
            'message': 'Username, email and password are required',
        }, status=400)
    try:
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name=str(data.get('firstName', '')).strip(),
            last_name=str(data.get('lastName', '')).strip(),
        )
    except IntegrityError:
        return JsonResponse({
            'status': 'Failed', 'message': 'Username already exists'
        }, status=409)
    return JsonResponse({'status': 'Registered', 'userName': user.username})


def get_cars(request):
    if not CarMake.objects.exists() or not CarModel.objects.exists():
        initiate()
    car_models = CarModel.objects.select_related('car_make').order_by(
        'car_make__name', 'name'
    )
    cars = [
        {'CarModel': model.name, 'CarMake': model.car_make.name}
        for model in car_models
    ]
    return JsonResponse({'CarModels': cars})


def get_dealerships(request, state='All'):
    endpoint = '/fetchDealers' if state == 'All' else '/fetchDealers/' + state
    dealers = get_request(endpoint)
    if dealers is None:
        return JsonResponse({
            'status': 503, 'message': 'Dealer backend unavailable', 'dealers': []
        }, status=503)
    return JsonResponse({'status': 200, 'dealers': dealers})


def get_dealer_details(request, dealer_id):
    dealer = get_request('/fetchDealer/' + str(dealer_id))
    if dealer is None:
        return JsonResponse({
            'status': 503, 'message': 'Dealer backend unavailable', 'dealer': []
        }, status=503)
    return JsonResponse({'status': 200, 'dealer': dealer})


def get_dealer_reviews(request, dealer_id):
    reviews = get_request('/fetchReviews/dealer/' + str(dealer_id))
    if reviews is None:
        return JsonResponse({
            'status': 503, 'message': 'Reviews backend unavailable', 'reviews': []
        }, status=503)
    for review in reviews:
        result = analyze_review_sentiments(review.get('review', ''))
        review['sentiment'] = result.get('sentiment', 'neutral')
    return JsonResponse({'status': 200, 'reviews': reviews})


@csrf_exempt
def add_review(request):
    if request.method != 'POST':
        return JsonResponse({'status': 405, 'message': 'Use POST'}, status=405)
    if not request.user.is_authenticated:
        return JsonResponse({
            'status': 403, 'message': 'Unauthorized'
        }, status=403)
    data = _json_body(request)
    if not data.get('review') or not data.get('dealership'):
        return JsonResponse({
            'status': 400, 'message': 'Review and dealership are required'
        }, status=400)
    data['name'] = request.user.get_full_name() or request.user.username
    result = post_review(data)
    if result is None:
        return JsonResponse({
            'status': 502, 'message': 'Could not save review'
        }, status=502)
    return JsonResponse({'status': 200, 'review': result})
