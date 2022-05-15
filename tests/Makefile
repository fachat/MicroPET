
ASM=map 8296screen virtpet
BASIC=readflash rtcc batmem sdcard

all: ${ASM} ${BASIC}

clean:
	rm -f ${ASM} ${BASIC}

${ASM}: %: %.a65
	xa -w -M $< -o $@

${BASIC}: %: %.lst
	petcat -w40 -o $@ $<


