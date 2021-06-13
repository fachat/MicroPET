
all: bench

clean:
	rm -f bench.basic bench
	rm -f eichcode.data eichcode.bin 

bench: bench.basic
	cat bench.basic | petcat -w2 -l 0401 > bench


bench.basic: eichcode.data benchmark.basic 
	cat benchmark.basic > bench.basic
	cat eichcode.data >> bench.basic

eichcode.data: eichcode.bin
	echo -n "60900 data 658, " > eichcode.data
	ls -l eichcode.bin | cut -d " " -f 5 >> eichcode.data
	cat eichcode.bin | hexdump -e '"61%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> eichcode.data

eichcode.bin: eichcode.a65
	xa eichcode.a65 -o eichcode.bin



