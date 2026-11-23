#!/usr/bin/env bash
# Prepare the Best Cars capstone in an IBM Skills Network Cloud IDE.
set -euo pipefail

REPO="https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone.git"
DIR="/home/project/xrwvm-fullstack_developer_capstone"
mkdir -p /home/project
if [[ -d "$DIR/.git" ]]; then
  echo "Using existing checkout: $DIR"
  git -C "$DIR" pull --ff-only
else
  git clone "$REPO" "$DIR"
fi

echo "Installing Python dependencies..."
# The Skills Network Cloud IDE may lack the standard-library venv package.
if ! python3 -m venv /home/project/bestcars-venv; then
  echo "Built-in venv unavailable; using virtualenv..."
  python3 -m pip install --user virtualenv
  python3 -m virtualenv /home/project/bestcars-venv
fi
source /home/project/bestcars-venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r "$DIR/server/requirements.txt"

echo "Building React frontend..."
cd "$DIR/server/frontend"
npm install --no-audit --no-fund
CI=false npm run build

echo "Running Django migrations..."
cd "$DIR/server"
python manage.py migrate

echo "Starting the local MongoDB + Express backend..."
cd "$DIR/server/database"
docker build -t nodeapp .
if docker compose version >/dev/null 2>&1; then
  docker compose up -d
elif command -v docker-compose >/dev/null 2>&1; then
  docker-compose up -d
else
  echo "ERROR: Docker Compose is unavailable. Start the database manually."
  exit 1
fi

echo "Starting Django on port 8000..."
cd "$DIR/server"
if ! curl -fsS http://127.0.0.1:8000/ >/dev/null 2>&1; then
  nohup /home/project/bestcars-venv/bin/python manage.py runserver 0.0.0.0:8000 > "$DIR/django_server" 2>&1 </dev/null &
fi

echo "Capturing local API results..."
sleep 5
mkdir -p "$DIR/evidence"
cd "$DIR/evidence"
for spec in \
  "getdealerreviews /fetchReviews/dealer/29" \
  "getalldealers /fetchDealers" \
  "getdealerbyid /fetchDealer/3" \
  "getdealersbyState /fetchDealers/Kansas"; do
  file="${spec%% *}"
  endpoint="${spec#* }"
  url="http://127.0.0.1:3030$endpoint"
  echo "curl -X GET \"$url\"" > "$file"
  curl --silent --show-error -X GET "$url" >> "$file" || true
  printf '\n' >> "$file"
done
url="http://127.0.0.1:8000/djangoapp/get_cars"
echo "curl -X GET \"$url\"" > getallcarmakes
curl --silent --show-error -X GET "$url" >> getallcarmakes || true
printf '\n' >> getallcarmakes


# Create a disposable test account only inside this lab database.
# Its credentials are kept in the local evidence folder (not in Git).
cd "$DIR/server"
export CAPSTONE_TEST_USER="capstone_demo"
export CAPSTONE_TEST_PASS="$(python -c 'import secrets; print(secrets.token_urlsafe(18))')"
python manage.py shell -c 'import os; from django.contrib.auth.models import User; u, _ = User.objects.get_or_create(username=os.environ["CAPSTONE_TEST_USER"]); u.set_password(os.environ["CAPSTONE_TEST_PASS"]); u.email="demo@example.com"; u.save()'
cd "$DIR/evidence"
printf '%s\n' "Username: $CAPSTONE_TEST_USER" "Password: $CAPSTONE_TEST_PASS" > demo_login_credentials.txt
chmod 600 demo_login_credentials.txt
payload="$(printf '{"userName":"%s","password":"%s"}' "$CAPSTONE_TEST_USER" "$CAPSTONE_TEST_PASS")"
login_url="http://127.0.0.1:8000/djangoapp/login"
echo "curl -X POST -H 'Content-Type: application/json' -d '$payload' '$login_url'" > loginuser
curl --silent --show-error -c session.cookies -X POST -H 'Content-Type: application/json' -d "$payload" "$login_url" >> loginuser || true
printf '\n' >> loginuser
logout_url="http://127.0.0.1:8000/djangoapp/logout"
echo "curl -X GET -b session.cookies '$logout_url'" > logoutuser
curl --silent --show-error -b session.cookies -X GET "$logout_url" >> logoutuser || true
printf '\n' >> logoutuser
chmod 600 loginuser logoutuser session.cookies

echo ""
echo "Complete. Inspect these real outputs:"
echo "  $DIR/django_server"
echo "  $DIR/evidence/"
echo "Open the Django app at the lab's port 8000 preview."
echo "If a service is not ready, rerun the corresponding curl command."
