#!/usr/bin/env bash

source scripts/utilities.sh

separator
cecho "Hisma release script."
cecho
cecho "This script is going to version hisma packages in git and then publish them on pub.dev."
cecho "Additionally, if visma is having a new tag, a new visma docker image will built and"
cecho "pushed to Docker Hub."
cecho

if [ "$(git branch)" == "master" ]; then
    cecho "GIT: You are not on the master branch."
    proceed
fi

if [[ `git status --porcelain` ]]; then
    cecho "GIT: You have modifications and/or untracked files."
    proceed
fi

if [ -n "$(git cherry -v origin/master)" ]; then
    cecho "GIT: There are commits that have not been pushed."
    proceed
fi

cecho "Next steps are going to analyze, test and pana all packages."
proceed

fvm exec melos analyze
echeck "melos analyze failed. Check logs."

message "Check  all packages by melos test:"
fvm exec melos test
echeck "melos test failed. Check logs."

message "Check all packages by melos pana:"
fvm exec melos run --no-select pana
echeck "melos pana failed. Check logs."

separator
cecho "All checks are completed successfully."
cecho "Next step is versioning the packages."
proceed
BEFORE_TAGS=$(git tag)
fvm exec melos version

if [ "$(git tag)" != "$BEFORE_TAGS" ]; then
    git push --follow-tags
else
    separator
    cecho "melos version did not create any tags."
    proceed
fi

separator
cecho "Next step is to test publishing (--dry-run)."
proceed
fvm exec melos publish --dry-run

separator
cecho "Next step is REAL publishing to pub.dev."
proceed
fvm exec melos publish --no-dry-run


separator
cecho "Next steps are creating and publishing visma docker image."
proceed
pushd packages/visma/docker/
./build_and_publish.sh
popd

message "RELEASE IS DONE"
