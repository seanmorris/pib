include Makefile

EXTRA_LIBS:=$(sort $(filter-out ${SKIP_LIBS}, ${EXTRA_LIBS}))

print:
	echo ${EXTRA_LIBS}
