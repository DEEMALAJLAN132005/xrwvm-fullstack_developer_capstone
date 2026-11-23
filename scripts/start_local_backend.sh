#!/usr/bin/env bash
# Start the local dealership data service in a Skills Network Cloud IDE
# that has mongod/mongosh but no Docker daemon.
set -euo pipefail
REPO="/home/project/xrwvm-fullstack_developer_capstone"
echo "Checking MongoDB..."
if ! mongosh --quiet --eval 'db.adminCommand({ping:1}).ok' 2>/dev/null | grep -qx '1'; then
  mkdir -p "/home/project/bestcars-mongodb"
  mongod --dbpath "/home/project/bestcars-mongodb" \
    --bind_ip 127.0.0.1 --port 27017 \
    --logpath "/home/project/bestcars-mongod.log" --fork
fi

echo "Installing Node API dependencies..."
cd "$REPO/server/database"
npm install --no-audit --no-fund

echo "Starting dealership API on port 3030..."
if ! curl -fsS "http://127.0.0.1:3030/" >/dev/null 2>&1; then
  nohup node app.js > "/home/project/bestcars-node-api.log" 2>&1 </dev/null &
fi

ready=0
for attempt in $(seq 1 20); do
  if curl -fsS "http://127.0.0.1:3030/fetchDealers" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" != "1" ]; then
  echo "Dealership API is not ready. Inspect:"
  tail -n 40 "/home/project/bestcars-node-api.log" || true
  exit 1
fi

echo "Collecting live terminal API evidence..."
mkdir -p "$REPO/evidence"
save_evidence () {
  local filename="$1"
  local endpoint="$2"
  local url="http://127.0.0.1:3030$endpoint"
  printf 'curl -X GET "%s"\n' "$url" > "$REPO/evidence/$filename"
  curl --fail --silent --show-error -X GET "$url" >> "$REPO/evidence/$filename"
  printf '\n' >> "$REPO/evidence/$filename"
}
save_evidence getdealerreviews /fetchReviews/dealer/29
save_evidence getalldealers /fetchDealers
save_evidence getdealerbyid /fetchDealer/3
save_evidence getdealersbyState /fetchDealers/Kansas

echo "Backend running successfully."
echo "Evidence saved: getdealerreviews, getalldealers, getdealerbyid, getdealersbyState"
echo "Data counts:"
node -e 'const fs=require("fs");const base=process.argv[1];for(const [f,label] of [["getalldealers","all dealers"],["getdealersbyState","Kansas dealers"],["getdealerreviews","dealer reviews"]]){const s=fs.readFileSync(base+"/"+f,"utf8").split("\n").slice(1).join("\n");const x=JSON.parse(s);console.log(label+": "+x.length)}' "$REPO/evidence"
