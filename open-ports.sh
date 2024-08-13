#! /bin/bash

echo "Scanning TCP ports..."
for p in {1..1023}; do
    (echo >/dev/tcp/localhost/$p) >/dev/null 2>&1 && echo "$p open"
done
