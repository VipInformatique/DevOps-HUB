#!/bin/bash

# 🏁 Sprawdzenie argumentu -y
AUTO_CONFIRM=false
if [[ "$1" == "-y" ]]; then
    AUTO_CONFIRM=true
fi

# 🔍 Znalezienie daty instalacji systemu
INSTALL_DATE=$(ls -lt --time-style=long-iso /var/log/installer 2>/dev/null | tail -n 1 | awk '{print $6}')
if [ -z "$INSTALL_DATE" ]; then
    INSTALL_DATE=$(ls -lt --time-style=long-iso /var/log/ | grep 'installer' | tail -n 1 | awk '{print $6}')
fi
if [ -z "$INSTALL_DATE" ]; then
    INSTALL_DATE=$(sudo tune2fs -l $(df / | tail -1 | awk '{print $1}') | grep 'Filesystem created:' | awk '{print $3, $4, $5}')
fi
if [ -z "$INSTALL_DATE" ]; then
    INSTALL_DATE=$(ls -lt --time-style=long-iso /etc | tail -n 1 | awk '{print $6}')
fi
if [ -z "$INSTALL_DATE" ]; then
    echo "❌ Nie można określić daty instalacji. Przerywam."
    exit 1
fi

echo "✅ System Ubuntu został zainstalowany: $INSTALL_DATE"

# Konwersja na format YYYY-MM-DD
INSTALL_DATE=$(date -d "$INSTALL_DATE" +%Y-%m-%d)

# 🔥 Znalezienie plików utworzonych po instalacji
echo "🔍 Szukam plików utworzonych po tej dacie ($INSTALL_DATE)..."

find / -xdev -newermt "$INSTALL_DATE" -type f | while read file; do
    if $AUTO_CONFIRM; then
        rm -f "$file"
        echo "🗑️ Usunięto: $file"
    else
        echo "❓ Usunąć: $file? (t/n)"
        read -r answer
        if [[ "$answer" == "t" ]]; then
            rm -f "$file"
            echo "🗑️ Usunięto: $file"
        else
            echo "⏭️ Pominięto: $file"
        fi
    fi
done

echo "✅ Operacja zakończona."
