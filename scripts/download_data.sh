#!/usr/bin/env bash
# Download and extract the KKBox Churn Prediction Challenge (WSDM Cup 2018) data into data/raw/.
#
# Requirements:
#   - kaggle CLI >= 1.8.0 (pip install "kaggle>=1.8.0")
#   - py7zr (pip install py7zr)
#   - KAGGLE_API_TOKEN set in the environment
#   - Competition rules accepted at https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge
#
# Usage: bash scripts/download_data.sh
# Already-extracted files are skipped, so the script is safe to re-run.

set -euo pipefail

COMPETITION="kkbox-churn-prediction-challenge"
RAW_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/raw"

# Smallest first, so analysis can start before the large user_logs file arrives.
FILES=(
  WSDMChurnLabeller.scala
  train.csv.7z
  train_v2.csv.7z
  transactions_v2.csv.7z
  members_v3.csv.7z
  user_logs_v2.csv.7z
  transactions.csv.7z
  user_logs.csv.7z
)

mkdir -p "$RAW_DIR"

for file in "${FILES[@]}"; do
  target="${file%.7z}"
  if [[ -e "$RAW_DIR/$target" ]]; then
    echo "skip   $target (already present)"
    continue
  fi

  echo "fetch  $file"
  kaggle competitions download -c "$COMPETITION" -f "$file" -p "$RAW_DIR" --quiet

  # Kaggle may wrap single-file downloads in a .zip.
  if [[ -f "$RAW_DIR/$file.zip" ]]; then
    python3 -m zipfile -e "$RAW_DIR/$file.zip" "$RAW_DIR"
    rm "$RAW_DIR/$file.zip"
  fi

  if [[ "$file" == *.7z ]]; then
    echo "unzip  $file"
    # Archives contain nested folders (e.g. data/churn_comp_refresh/), so extract to a
    # temporary folder and move the CSV up into data/raw/.
    tmp_dir="$RAW_DIR/.extract_tmp"
    rm -rf "$tmp_dir"
    python3 -c "import sys, py7zr; py7zr.SevenZipFile(sys.argv[1]).extractall(sys.argv[2])" \
      "$RAW_DIR/$file" "$tmp_dir"
    find "$tmp_dir" -type f -name '*.csv' -exec mv {} "$RAW_DIR/" \;
    rm -rf "$tmp_dir" "$RAW_DIR/$file"
  fi
done

echo "done. Files in $RAW_DIR:"
ls -lh "$RAW_DIR"
