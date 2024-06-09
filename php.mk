include Makefile

EXTRA_LIBS:=$(sort $(filter-out ${SKIP_LIBS}, ${EXTRA_LIBS}))

CFLAGS_CLEAN:=$(sort $(filter-out -g -O2, ${CFLAGS_CLEAN}))

print:
	echo ${EXTRA_LIBS}
