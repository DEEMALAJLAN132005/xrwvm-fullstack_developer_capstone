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
python3 -m venv /home/project/bestcars-venv
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

echo ""
echo "Complete. Inspect these real outputs:"
echo "  $DIR/django_server"
echo "  $DIR/evidence/"
echo "Open the Django app at the lab's port 8000 preview."
echo "If a service is not ready, rerun the corresponding curl command."
