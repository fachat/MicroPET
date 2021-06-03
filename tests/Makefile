
all: low32k map readflash rtcc batmem

clean:
	rm -f low32k map readflash batmem rtcc

map: map.a65
	xa -w -M map.a65 -o map

low32k: low32k.a65
	xa -w -M low32k.a65 -o low32k

readflash: readflash.lst
	petcat -w40 -o readflash readflash.lst

rtcc: rtcc.lst
	petcat -w40 -o rtcc rtcc.lst

batmem: batmem.lst
	petcat -w40 -o batmem batmem.lst

