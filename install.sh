#!/bin/bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Musée Bolo — personnalisation de la borne ==="

"${DIR}/grub/install.sh"
"${DIR}/plymouth/install.sh"
"${DIR}/lightdm/install.sh"

echo
echo "Personnalisation terminée."
