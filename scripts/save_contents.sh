#!/bin/bash
set -e

SAVE_CMD=rcc

SCRIPTS_DIR="scripts"
CONTENT_DIR="content"
STATIC_DIR="static"
STATIC_IMAGES_DIR="${STATIC_DIR}/images"

SAVE_DIR="tmp/save"
SAVE_CONTENT_DIR="${SAVE_DIR}/content"
SAVE_STATIC_DIR="${SAVE_DIR}/static"
SAVE_STATIC_IMAGES_DIR="${SAVE_STATIC_DIR}/images"

MAP_CONFIG="${SCRIPTS_DIR}/mapconfig.json"
DOCS_API_NAME="docsThemeCollection"
DOCS_COLLECTION_ID="test-contentful-nuxt-content"

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
    --filter "locale=${SAVE_LANG}" "include=2" "fields.id=${DOCS_COLLECTION_ID}"
  rsync -a --delete "${DOCS_SAVE_CONTENTS_DIR}/" "${DOCS_CONTENTS_DIR}"
  rsync -a --delete "${DOCS_SAVE_IMAGES_DIR}/" "${DOCS_IMAGES_DIR}"
done
