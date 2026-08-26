#!/usr/bin/env bash

test_description='Test clip (-c) marks content sensitive on Wayland when supported'
cd "$(dirname "$0")"
. ./setup.sh

export PATH="$TEST_HOME:$PATH"
export WAYLAND_DISPLAY="fake-wayland-display"

test_expect_success 'setup' '
	"$PASS" init $KEY1 &&
	echo "s3cr3t" | "$PASS" insert -e clip-test
'

# clip() backgrounds a second wl-copy call (restoring the previous clipboard
# value after CLIP_TIME) that fires asynchronously and would otherwise race
# with the next test if they shared a log file -- each test gets its own via
# mktemp instead of a fixed path.

test_expect_success 'clip passes --sensitive to wl-copy when it supports the flag' '
	export WL_COPY_LOG="$(mktemp)" &&
	export FAKE_WL_COPY_SENSITIVE=1 &&
	"$PASS" -c clip-test &&
	grep -q -- "--sensitive" "$WL_COPY_LOG"
'

test_expect_success 'clip omits --sensitive when wl-copy does not support the flag' '
	export WL_COPY_LOG="$(mktemp)" &&
	unset FAKE_WL_COPY_SENSITIVE &&
	"$PASS" -c clip-test &&
	test -s "$WL_COPY_LOG" &&
	! grep -q -- "--sensitive" "$WL_COPY_LOG"
'

test_done
