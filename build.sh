# build progress and all examples

set -eu

if [[ -v DC ]]; then
    if [ $DC == "" ]; then
        DC=dmd
    fi
else
    DC=dmd
fi

for dir in `find . -name dub.json | grep -v "\.dub" | xargs dirname`; do
    echo
    echo "Running 'dub build --compiler=$DC --root=$dir' ..."
    dub build --compiler=$DC --root=$dir
done