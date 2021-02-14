
all: low32k map readflash

clean:
	rm -f low32k map readflash

map: map.a65
	xa -w -M map.a65 -o map

low32k: low32k.a65
	xa -w -M low32k.a65 -o low32k

readflash: readflash.lst
	petcat -w40 -o readflash readflash.lst

