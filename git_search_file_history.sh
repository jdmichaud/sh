if [ "$#" -ne 2 ]; then
  echo "Wrong number of parameters ($#)"
  echo "usage: git_search_file_history filename search-string"
  exit 1
fi

git rev-list --all $1 | (
  while read revision; do
    git grep -F $2 $revision $1
  done
)

