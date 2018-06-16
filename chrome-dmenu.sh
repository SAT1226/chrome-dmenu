#!/bin/bash
# config
DMENU="dmenu -b -l 20"
BOOKMARK_FILE="$HOME/.config/google-chrome/Default/Bookmarks"
HISTORY_FILE="$HOME/.config/google-chrome/Default/History"
CHROME_BIN="google-chrome-stable"
PYTHON_BIN="python3"
PREFIXES=(
    "g https://www.google.com/search?q= https://www.google.com/"
    "d https://www.duckduckgo.com/?q= https://www.duckduckgo.com/"
    "y https://www.youtube.com/results?search_query= https://www.youtube.com/"
    "h https://github.com/search?q= https://github.com/"
)
cd `dirname $0`

# prefix launcher
function prefix_launcher() {
    for i in "${PREFIXES[@]}"; do
        PREFIX=(${i[@]})

        if [ "${PREFIX[0]}" == ${1:0:1} ]; then
            if [ ${#1} -eq "1" ]; then
                $CHROME_BIN "${PREFIX[2]}"
            else
                QUERY=`echo "$1" | sed -r 's/^.[[:space:]]+(.*)$/\1/'`

                if [ "$QUERY" != "$1" ]; then
                    $CHROME_BIN "${PREFIX[1]}$QUERY"
                fi
            fi
            exit
        fi
    done
}

# history dmenu
function history_dmenu() {
    OLDIFS=$IFS
    IFS='
'
    SELECT_HISTORIES=`${PYTHON_BIN} history.py "$HISTORY_FILE" | eval ${DMENU}`
    for SELECT_HISTORY in `echo "$SELECT_HISTORIES"`
    do
        IFS=$OLDIFS
        echo "$SELECT_HISTORY"
        prefix_launcher "$SELECT_HISTORY"

        if [ "$SELECT_HISTORY" != "" ]; then
            URL=`echo "$SELECT_HISTORY" | sed -r 's/.+\[(.+)\]$/\1/'`
            $CHROME_BIN "$URL"
        fi
    done
    IFS=$OLDIFS
}

# args
if [ "$1" == "--help" ]; then
    echo "$0 [--history] [default_url]"
    exit
fi
if [ "$1" == "--history" ]; then
    history_dmenu
    exit
fi

# check file
if [ ! -e "$BOOKMARK_FILE" ]; then
    echo "Chrome Bookmark Not Found!: $BOOKMARK_FILE"
    exit 1
fi

if [ ! -e "$HISTORY_FILE" ]; then
    echo "Chrome History Not Found!: $HISTORY_FILE"
    exit 1
fi

# default url
BOOKMARK_NAMES=""
if [ "$1" != "" ]; then
    # too long
    if [ ${#1} -gt "150" ]; then
        STR=`echo "$1" | tr -d '\n' | cut -c 1-150`"..."
    else
        STR=`echo "$1" | tr -d '\n'`
    fi
    BOOKMARK_NAMES="0000:[$STR]
"
fi

BOOKMARK_NAMES+=`${PYTHON_BIN} bookmark.py --name "$BOOKMARK_FILE"`
BOOKMARK_URLS=`${PYTHON_BIN} bookmark.py --url "$BOOKMARK_FILE"`

SELECT_NAMES=`echo "$BOOKMARK_NAMES" | eval ${DMENU}`
OLDIFS=$IFS
IFS='
'

for SELECT_NAME in `echo "$SELECT_NAMES"`
do
    IFS=$OLDIFS
    if [ "$SELECT_NAME" != "" ]; then
        SELECT_LINE=`echo "$SELECT_NAME" | sed -r 's/^([0-9]+):.+$/\1/'`

        # History select
        if [ "${SELECT_NAME}" == "H" ]; then
            history_dmenu
            exit
        fi
        prefix_launcher "$SELECT_NAME"

        # Bookmark
        if [ "$SELECT_LINE" != "0000" ]; then
            expr "$SELECT_LINE" + 1 >/dev/null 2>&1

            # isNumeric?
            if [ $? -lt 2 ]; then
                URL=`echo "$BOOKMARK_URLS" | sed -n "$SELECT_LINE"p | sed -r 's/^[0-9]+:(.+)$/\1/'`
                if [ "$SELECT_LINE" == "$SELECT_NAME" ]; then
                    URL="about:blank"
                fi
            else
                URL="about:blank"
            fi
        else
            URL="$1"
        fi

        $CHROME_BIN "$URL"
    fi
done
IFS=$OLDIFS
