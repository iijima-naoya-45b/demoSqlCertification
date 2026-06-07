#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"
frontendDir="${projectRoot}/frontend"

cd "${frontendDir}"

if [[ ! -d node_modules ]]; then
    echo "node_modules が見つかりません。npm install を実行します..."
    npm install
fi

echo "=== React フロントエンド起動 (port 5173) ==="
echo "API プロキシ: http://localhost:8080"
echo ""

npm run dev
