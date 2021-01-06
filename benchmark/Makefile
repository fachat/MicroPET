
all: BENCH

clean:
	rm -f BENCH.basic BENCH
	rm -f eichcode.data eichcode.bin 
	rm -f benchcode.data benchcode.bin 
	rm -f vbenchcode.data vbenchcode.bin 

BENCH: BENCH.basic
	cat BENCH.basic | petcat -w2 -l 0401 > BENCH


BENCH.basic: eichcode.data benchcode.data benchmark.basic 
	cat benchmark.basic > BENCH.basic
	cat eichcode.data >> BENCH.basic
	#cat benchcode.data >> BENCH.basic
	#cat vbenchcode.data >> BENCH.basic

eichcode.data: eichcode.bin
	echo -n "60900 data 658, " > eichcode.data
	ls -l eichcode.bin | cut -d " " -f 5 >> eichcode.data
	cat eichcode.bin | hexdump -e '"61%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> eichcode.data

eichcode.bin: eichcode.a65
	xa eichcode.a65 -o eichcode.bin

benchcode.data: benchcode.bin
	echo -n "61900 data 656, " > benchcode.data
	ls -l benchcode.bin | cut -d " " -f 5 >> benchcode.data
	cat benchcode.bin | hexdump -e '"62%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> benchcode.data

benchcode.bin: benchcode.a65
	xa benchcode.a65 -w -o benchcode.bin

vbenchcode.data: vbenchcode.bin
	echo -n "62900 data 656, " > vbenchcode.data
	ls -l vbenchcode.bin | cut -d " " -f 5 >> vbenchcode.data
	cat vbenchcode.bin | hexdump -e '"63%03_ad data " 16/1 "%d," "\n"' | sed -e 's/,*$$//g' \
		>> vbenchcode.data

vbenchcode.bin: benchcode.a65
	xa benchcode.a65 -DVIDEOBENCH -w -o vbenchcode.bin


