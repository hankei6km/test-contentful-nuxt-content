#!/bin/bash
set -e

PREVIEW_FLAG="false"

function _usage {
  printf "Usage: save:contents [-p [true | false] request preview contets(default:%s)]\n" \
    "${PREVIEW_FLAG}" 
}

while getopts p: FLAG ; do
  case "${FLAG}" in
    p) PREVIEW_FLAG="${OPTARG}";;
    *) _usage ; exit 1;;
  esac
done

# shift "$((OPTIND - 1))"
# ARGS=( "${@}" )

SAVE_CMD=rcc

SCRIPTS_DIR="scripts"
CONTENT_DIR="content"
STATIC_DIR="static"
STATIC_IMAGES_DIR="${STATIC_DIR}/images"

SAVE_DIR="tmp/save"
SAVE_CONTENT_DIR="${SAVE_DIR}/content"
SAVE_STATIC_DIR="${SAVE_DIR}/static"
SAVE_STATIC_IMAGES_DIR="${SAVE_STATIC_DIR}/images"

MAP_CONFIG="${SCRIPTS_DIR}/mapconfig.yaml"
DOCS_API_NAME="docsThemeCollection"
DOCS_COLLECTION_ID="test-contentful-nuxt-content"
DOCS_PREVIEW=""
PAGE_SIZE="10"

if test "${PREVIEW_FLAG}" = "true" ; then
  DOCS_PREVIEW="preview=true"
fi

if test -d "${SAVE_DIR}" ; then
  rm -r "${SAVE_DIR}"
fi

if test ! -d "${STATIC_IMAGES_DIR}" ; then
  mkdir -p "${STATIC_IMAGES_DIR}" 
fi

SAVE_LANGS=("ja" "en-US")
# SAVE_LANGS=("ja" )
for SAVE_LANG in "${SAVE_LANGS[@]}"; do
  echo "${SAVE_LANG}"
  DOCS_CONTENTS_DIR="${CONTENT_DIR}/${SAVE_LANG/-[A-Z][A-Z]/}"
  DOCS_IMAGES_DIR="${STATIC_IMAGES_DIR}/${SAVE_LANG/-[A-Z][A-Z]/}"

  DOCS_SAVE_CONTENTS_DIR="${SAVE_CONTENT_DIR}/pages"
  DOCS_SAVE_IMAGES_DIR="${SAVE_STATIC_IMAGES_DIR}/pages"

  mkdir -p "${DOCS_SAVE_CONTENTS_DIR}"
  mkdir -p "${DOCS_SAVE_IMAGES_DIR}"

  npx "${SAVE_CMD}" --map-config "${MAP_CONFIG}" \
    save \
    --static-root "${SAVE_STATIC_DIR}" \
    "${DOCS_API_NAME}" "${DOCS_SAVE_CONTENTS_DIR}" "${DOCS_SAVE_IMAGES_DIR}" \
    --page-size "${PAGE_SIZE}" \
    --vars "locale=${SAVE_LANG}" "id=${DOCS_COLLECTION_ID}" "${DOCS_PREVIEW}"
  rsync -a --delete "${DOCS_SAVE_CONTENTS_DIR}/" "${DOCS_CONTENTS_DIR}"
  rsync -a --delete "${DOCS_SAVE_IMAGES_DIR}/" "${DOCS_IMAGES_DIR}"
done
