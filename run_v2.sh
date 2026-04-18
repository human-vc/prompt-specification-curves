#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==========================================================="
echo "v2 collection: B1 (Haiku catch-up) + B2 (6 new items)"
echo "Estimated cost: ~\$176 at provider list prices"
echo "Estimated wall clock: 7-12 hours"
echo "==========================================================="
read -p "Continue? [y/N] " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

echo
echo ">>> [1/3] B1: Claude Haiku 4.5 on the original three items"
python3 pilot.py lhs --n_specs 100 \
    --items gov_spending immigration gun_control \
    --only_models claude-haiku-4-5 \
    --spec_id_offset 1000 \
    --output v2_haiku_legacy.json

echo
echo ">>> [2/3] B2: All six systems on the six new ANES items"
python3 pilot.py lhs --n_specs 500 \
    --items defense_spending healthcare abortion guaranteed_jobs aid_to_blacks environment_business \
    --output v2_new_items.json

echo
echo ">>> [3/3] Analysis on the new-items dataset"
python3 pilot.py analyze              --output v2_new_items.json
python3 pilot.py fisher               --output v2_new_items.json
python3 pilot.py threshold            --output v2_new_items.json --n_permutations 10000
python3 pilot.py profile_sensitivity  --output v2_new_items.json
python3 pilot.py system_decomp        --output v2_new_items.json
python3 pilot.py hierarchical_decomp  --output v2_new_items.json
python3 pilot.py anes                 --output v2_new_items.json

echo
echo "==========================================================="
echo "v2 complete. Outputs:"
echo "  results/v2_haiku_legacy.json     (Haiku on legacy 3 items)"
echo "  results/v2_new_items.json        (6 systems on 6 new items)"
echo "  figures/                         (regenerated plots)"
echo "==========================================================="
