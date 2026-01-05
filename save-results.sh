#!/bin/bash
mkdir -p results/history
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_ID="run_${TIMESTAMP}"
echo "Saving results: $RUN_ID"

# Create a temporary JSON file with the run data
cat > results/history/${RUN_ID}.json << 'ENDJSON'
{
  "run_id": "PLACEHOLDER_RUN_ID",
  "timestamp": "PLACEHOLDER_TIMESTAMP",
  "date_display": "PLACEHOLDER_DATE",
  "smoke": {},
  "stress": {},
  "spike": {},
  "full_load": {}
}
ENDJSON

# Update the run_id, timestamp, and date_display
sed -i "s|PLACEHOLDER_RUN_ID|${RUN_ID}|g" results/history/${RUN_ID}.json
sed -i "s|PLACEHOLDER_TIMESTAMP|$(date -Iseconds)|g" results/history/${RUN_ID}.json
sed -i "s|PLACEHOLDER_DATE|$(date '+%Y-%m-%d %H:%M')|g" results/history/${RUN_ID}.json

# Try to load summary files if they exist
if [ -f "results/smoke_summary.json" ]; then
  SMOKE_DATA=$(cat results/smoke_summary.json | jq -c . 2>/dev/null || echo '{}')
  sed -i "s|\"smoke\": {}|\"smoke\": ${SMOKE_DATA}|g" results/history/${RUN_ID}.json
fi

if [ -f "results/stress_summary.json" ]; then
  STRESS_DATA=$(cat results/stress_summary.json | jq -c . 2>/dev/null || echo '{}')
  sed -i "s|\"stress\": {}|\"stress\": ${STRESS_DATA}|g" results/history/${RUN_ID}.json
fi

if [ -f "results/spike_summary.json" ]; then
  SPIKE_DATA=$(cat results/spike_summary.json | jq -c . 2>/dev/null || echo '{}')
  sed -i "s|\"spike\": {}|\"spike\": ${SPIKE_DATA}|g" results/history/${RUN_ID}.json
fi

if [ -f "results/full_load_summary.json" ]; then
  FULL_LOAD_DATA=$(cat results/full_load_summary.json | jq -c . 2>/dev/null || echo '{}')
  sed -i "s|\"full_load\": {}|\"full_load\": ${FULL_LOAD_DATA}|g" results/history/${RUN_ID}.json
fi

node generate-unified-report.js
echo "Done! Open: firefox results/report.html"
