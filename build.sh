#!/usr/bin/env bash

cat README.md <(printf '\nLicense\n-------\n\n') LICENSE.txt | \
	sed -e 's/^/# /' | \
	cat - <(printf "\n") server_time.pl
