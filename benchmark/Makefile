
all: bench

clean:
	rm -f bench.lst bench
	rm -f eichcode.data eichcode_f.bin eichcode_v.bin

bench: bench.lst
	cat bench.lst | petcat -w2 -l 0401 > bench


bench.lst: eichcode.data benchmark.basic 
	cat benchmark.basic > bench.lst
	cat eichcode.data >> bench.lst

eichcode.data: eichcode_f.bin eichcode_v.bin
	echo -n "60900 data 768, " > eichcode.data
	ls -l eichcode_f.bin | cut -d " " -f 5 >> eichcode.data
	cat eichcode_f.bin | hexdump -e '"61%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> eichcode.data
	echo -n "62900 data 34816, " >> eichcode.data
	ls -l eichcode_v.bin | cut -d " " -f 5 >> eichcode.data
	cat eichcode_v.bin | hexdump -e '"63%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> eichcode.data

eichcode_f.bin: eichcode.a65
	xa eichcode.a65 -DRUNADDR=768 -o eichcode_f.bin

eichcode_v.bin: eichcode.a65
	xa eichcode.a65 -DRUNADDR=34816 -o eichcode_v.bin



