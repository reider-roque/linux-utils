function drop_word() {
    local WORD="$1"
    echo "$WORD: Retrieving id..."
    local RESP=$(curl -s 'https://mobile-api.lingualeo.com/GetWords' -H 'Referer: https://lingualeo.com/ru/dictionary/vocabulary/my' -H 'Origin: https://lingualeo.com' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: text/plain;charset=UTF-8' --data-binary "{\"apiVersion\":\"1.0.0\",\"op\":\"loadWordsMyDict\",\"attrList\":{\"id\":\"id\",\"wordValue\":\"wd\",\"origin\":\"wo\",\"wordType\":\"wt\",\"wordSets\":\"ws\",\"created\":\"cd\",\"learningStatus\":\"ls\",\"progress\":\"pi\",\"transcription\":\"scr\",\"pronunciation\":\"pron\",\"association\":\"as\",\"combinedTranslation\":\"trc\"},\"search\":\"$WORD\",\"perPage\":30,\"page\":1,\"category\":\"\",\"status\":\"\",\"training\":null,\"userData\":{\"nativeLanguage\":\"lang_id_src\"},\"ctx\":{\"config\":{\"isCheckData\":true,\"isLogging\":true}},\"token\":\"8b2b1800fdcd90dcbc4a2b0e276fefd220362eefdf8f7541e2e5918aed73786cc7f021cc4f4bb882\"}" --compressed)
    
    # DEBUG
    # echo $RESP | jq -C . | less -R && exit
    
    local IDS=($(echo $RESP | jq ".data[] | select(.wordValue==\"$WORD\").id"))
    if [[ -z "${IDS// }" ]]; then
        echo "$WORD: [ERROR] No id found. Skipping."
        return 1
    fi
    echo "$WORD: Found ids: ${IDS[*]}"
    
    # Rarely there are more than one ID per word
    for ID in "${IDS[@]}"; do
        echo "$WORD: Removing id $ID..."
        local RESP=$(curl -s 'https://mobile-api.lingualeo.com/SetWords' -H 'Referer: https://lingualeo.com/ru/dictionary/vocabulary/my' -H 'Origin: https://lingualeo.com' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36' -H 'DNT: 1' -H 'Content-Type: text/plain;charset=UTF-8' --data-binary "{\"apiVersion\":\"1.0.0\",\"op\":\"actionWithWords {action: delete}\",\"data\":[{\"action\":\"delete\",\"wordIds\":[$ID],\"wordSetId\":1}],\"userData\":{\"nativeLanguage\":\"lang_id_src\"},\"ctx\":{\"config\":{\"isCheckData\":true,\"isLogging\":true}},\"token\":\"8b2b1800fdcd90dcbc4a2b0e276fefd220362eefdf8f7541e2e5918aed73786cc7f021cc4f4bb882\"}" --compressed)

        local STATUS=$(echo ${RESP} | jq '.status')
        echo "$WORD: $ID removed: $STATUS"
    done

    return 0 # Success
}

FAIL_REMOVALS=()
GOOD_REMOVALS=()
for arg in "$@"; do
    drop_word "$arg" && GOOD_REMOVALS+=("$arg") || FAIL_REMOVALS+=("$arg")
done

echo "Failed removals: ${FAIL_REMOVALS[*]}"
printf "Successful removals:"
for el in "${GOOD_REMOVALS[@]}"; do
    printf ' %s OR' "$el"
done
printf '\n'
