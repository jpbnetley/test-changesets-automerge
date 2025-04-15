if [ "$(jq -r '.mode' .changeset/pre.json)" == "pre" ]; then
  echo "Match"
else
  echo "No match."
fi