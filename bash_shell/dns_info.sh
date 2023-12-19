#!/bin/bash
###################################################
# Created by Roger Nem                            #
# - Obtain DNS info of domains                    #
###################################################

while read URL; do

    OUT=$( curl --max-time 3 -qSfsw '\n%{http_code}' "$URL" ) 2>/dev/null

    # get exit code
    EXITCODE=$?

    DEST=$( curl --max-time 3 -Ls -o /dev/null -w %{url_effective} "$URL" )

    # ISSUE
    if [[ $EXITCODE -ne 0 ]]; then
        if [[ $EXITCODE -ne 22 ]]; then
            case $EXITCODE in
                6) RET="404-Host Not Found" ;; # curl: (6) Couldn't resolve host = 404 - Host not found
                7) RET="504-Gateway Timeout" ;; # curl: (7) couldn't connect to host = 504 - Gateway timeout
                28) RET="504-Gateway Timeout" ;;
                56) RET="504-Gateway Timeout" ;; # curl: (56) Failure when receiving data from the peer = 504 - Gateway timeout
            esac
            #echo "issue: $URL - $EXITCODE - $RET"
        fi
    # ALL OK
    else
        RET=$(echo "$OUT" | tail -n1)
        #echo "ok: $URL: $EXITCODE, $RET"
    fi

    # RESULT
    if [[ $URL == "www."* ]]; then
        #CNAME=$(dig NS +short $URL | cut -d' ' -f1 | tr '\n\r' ' ' | sed 's/.net./.net/g' )
        # tr: remove line breaks, cut values separated by space and get the first value, sed deletes the last character *.com., *.net., etc.
        CNAME=$(dig CNAME +short $URL | sed 's/.$//' )
        A=""
    else
        CNAME=""
        #A=$(dig $URL +short | sed ':a;N;$!ba;s/\n/,/g' | cut -d' ' -f1 | tr "\n\r" ' ' )
        A=$(dig $URL +short | tr "\n\r" ',' )
    fi

    #OUTPUT
    echo "$URL,$RET,$DEST,$CNAME,$A"

done < input_domains_to_check.txt
