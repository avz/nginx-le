#!/bin/sh

awk '
	function isTruthy(str)
	{
		return length(str) > 0
	}

	function lookBlockLength(str, _, len, prev, depth, op)
	{
		len = 0
		prev = 0
		depth = 1

		while (match(str, /\{\{|\}\}/)) {
			op = substr(str, RSTART, RLENGTH)
			str = substr(str, RSTART + RLENGTH)
			len += RSTART + RLENGTH - 1

			if (op == "{{") {
				depth++

				continue
			}

			depth--

			if (depth == 0) {
				return len
			}
		}

		return length(str)
	}

	function execute(str, _, condition, bl) {
		while (match(str, /\{\{/)) {
			print substr(str, 1, RSTART - 1)

			str = substr(str, RSTART + 2)

			if (match(str, /^[A-Z_][A-Z_0-9]*}}/)) {
				print ENVIRON[substr(str, RSTART, RLENGTH - 2)]

				str = substr(str, RSTART + RLENGTH)

				continue
			}

			if (match(str, /^if [A-Z_][A-Z_0-9]*[[:space:]]/)) {
				condition = substr(str, RSTART + 3, RLENGTH - 4)
				str = substr(str, RSTART + RLENGTH)

				bl = lookBlockLength(str)

				if (isTruthy(ENVIRON[condition])) {
					execute(substr(str, 1, bl - 2))
				}

				str = substr(str, bl + 1)

				continue
			}

			print "{{"

			str = substr(str, RSTART + RLENGTH)
		}

		print str
	}

	BEGIN {
		ORS = ""

		buf = ""
	}

	{
		buf = buf $0 "\n"
	}

	END {
		execute(buf)
	}
'
