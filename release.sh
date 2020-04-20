#!/usr/bin/env bash

# release bumps the version number and pushes the new tag for a given module
function release() {
    MODULE=$1

    # Tag with 0.1.0 if this is the first ever version
    if ! git tag -l | grep -q "^${MODULE}-[0-9]*\.[0-9]*\.[0-9]*$"; then
        echo "First release"
        git tag ${MODULE}-0.1.0
        return
    fi

    # Stop if this commit is tagged for this module already
    if git tag --points-at HEAD | grep -q "^${MODULE}-[0-9]*\.[0-9]*\.[0-9]*$"; then
        echo "Version already tagged"
        return
    fi

    # Get the latest version of this module
    local VERSION=$(git tag -l | grep "^${MODULE}-[0-9]*\.[0-9]*\.[0-9]*$" | sed "s/${MODULE}-//" | sort -V | tail -n 1)
    # split into array
    local VERSION_BITS=(${VERSION//./ })

    #get number parts and increase minor one by 1
    local VNUM1=${VERSION_BITS[0]}
    local VNUM2=${VERSION_BITS[1]}
    local VNUM3=0
    local VNUM2=$((VNUM2+1))
    NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
    git tag ${MODULE}-${NEW_TAG}
    git push --tags
}

# promote promotes this commit for a given module to a given promotion stage
function promote() {
    MODULE=$1
    PROMOTE_TO=$2
    local VERSION=$(git tag --points-at HEAD |  grep "^${MODULE}-[0-9]*\.[0-9]*\.[0-9]*$")
    git tag "${VERSION}-${PROMOTE_TO}" || echo "Version already promoted to ${PROMOTE_TO}"
    git push --tags
}

# latest gets the latest version number for a given module and promotion stage
function latest() {
    MODULE=$1
    PROMOTED_TO=$2
    local VERSION=$(git tag -l | grep "^${MODULE}-[0-9]*\.[0-9]*\.[0-9]*-${PROMOTED_TO}$" | sed "s/${MODULE}-//" | sed "s/-${PROMOTED_TO}//" | sort -V | tail -n 1)
    echo ${VERSION}
}

# latest gets the latest git tag for a given module and promotion stage
function latest_tag() {
    MODULE=$1
    PROMOTED_TO=$2
    echo ${MODULE}-$(latest ${MODULE} ${PROMOTED_TO})
}