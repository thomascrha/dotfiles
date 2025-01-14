#!/bin/bash
chars='@#$%&_+='

length=${1:-16}

{ </dev/urandom LC_ALL=C grep -ao '[A-Za-z0-9]' \
    | head -n$((length - 1))
    echo ${chars: $((RANDOM % ${#chars})):1}
} \
    | shuf \
    | tr -d '\n'
echo
