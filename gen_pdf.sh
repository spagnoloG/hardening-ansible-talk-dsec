# !/bin/bash

set -eux

# URL to check
url="http://localhost:1948/"

if curl --output /dev/null --silent --head --fail "$url"; then
  echo "Generating pdf from: $url"
else
  echo "The URL $url is not reachable. Please start the server and try again."
  echo "To start the server, run: docker-compose up -d"
  exit 1
fi

docker run --rm -t --net=host -v "`pwd`/slides":/slides astefanutti/decktape "$url/index.md" "ansible_hardening.pdf" --size 1920x1080
