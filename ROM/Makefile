
all: spiimg spiorig loadrom.bin loadrom

EDITROMS=edit80gx.bin edit40gx.bin edit40gc.bin edit80gc.bin edit40gxc.bin edit80gxc.bin

spiimg: zero basic2 edit2g kernal2 chargen_pet16 basic4 kernal4 iplldr $(EDITROMS) apmonax
	# extended ROM images
	cat iplldr					> spiimg	# 0-4k   : IPL loader
	cat apmonax					>> spiimg	# 4-8k   : @MON monitor (sys40960)
	cat chargen_pet16 				>> spiimg	# 8-16k  : 8k 16bytes/char PET character ROM
	cat basic2 edit2g zero kernal2 			>> spiimg	# 16-32k : BASIC2/Edit/Kernel ROMs (16k consecutive, $c000-$ffff)
	cat edit80gx.bin				>> spiimg	# 32-36k : sjgray BASIC 4 80 column editor w/ wedge by for(;;)
	cat basic4 					>> spiimg	# 36-48k : BASIC4 ROMS (12k $b000-$dfff)
	cat edit40gx.bin  				>> spiimg	# 48-52k : sjgray BASIC 4 40 column editor w/ wedge by for(;;)
	cat kernal4					>> spiimg	# 52-56k : BASIC4 kernel (4k)
	cat edit40gxc.bin	 			>> spiimg	# 56-60k : sjgray 40 column editor for C64 keyboard (experimental)
	cat edit80gxc.bin	 			>> spiimg	# 60-64k : sjgray 80 column editor for C64 keyboard (experimental)

spiorig: zero basic2 edit2g kernal2 chargen_pet16 basic4 kernal4 edit40g edit80g edit40gc.bin edit80gc.bin iplldr 
	# just using the standard ROM images
	cat iplldr					> spiorig	# 0-4k   : IPL loader
	cat zero zero					>> spiorig	# 4-8k   : 4k reserve
	cat chargen_pet16 				>> spiorig	# 8-16k  : 8k 16bytes/char PET character ROM
	cat basic2 edit2g zero kernal2 			>> spiorig	# 16-32k : BASIC2/Edit/Kernel ROMs (16k consecutive, $c000-$ffff)
	cat edit80g zero				>> spiorig	# 32-36k : BASIC 4 80 column editor ROM (graph keybd)
	cat basic4 					>> spiorig	# 36-48k : BASIC4 ROMS (12k $b000-$dfff)
	cat edit40g zero 				>> spiorig	# 48-52k : original BASIC 4 editor ROM graph keybd
	cat kernal4					>> spiorig	# 52-56k : BASIC4 kernel (4k)
	cat edit40gc.bin	 			>> spiorig	# 56-60k : sjgray 40 column editor for C64 keyboard (experimental)
	cat edit80gc.bin	 			>> spiorig	# 60-64k : sjgray 80 column editor for C64 keyboard (experimental)

zero: 
	dd if=/dev/zero of=zero bs=2048 count=1

chargen_pet16: charPet2Invers char8to16 chargen_pet
	./charPet2Invers < chargen_pet | ./char8to16 > chargen_pet16

charPet2Invers: charPet2Invers.c
	gcc -o charPet2Invers charPet2Invers.c
	
char8to16: char8to16.c
	gcc -o char8to16 char8to16.c

iplldr: iplldr.a65
	xa -w -o iplldr iplldr.a65

romtest02: romtest02.a65
	xa -w -o romtest02 romtest02.a65

romtest01: romtest01.a65
	xa -w -o romtest01 romtest01.a65 

romtest01a: romtest01a.a65
	xa -w -o romtest01a romtest01a.a65 

romtest02a: romtest02a.a65
	xa -w -o romtest02a romtest02a.a65 

# PET ROMs

ARCHIVE=http://www.zimmers.net/anonftp/pub/cbm

chargen_pet:
	curl -o chargen_pet $(ARCHIVE)/firmware/computers/pet/characters-2.901447-10.bin

edit2g:
	curl -o edit2g $(ARCHIVE)/firmware/computers/pet/edit-2-n.901447-24.bin

kernal2:
	curl -o kernal2 $(ARCHIVE)/firmware/computers/pet/kernal-2.901465-03.bin

basic2:
	curl -o basic2c $(ARCHIVE)/firmware/computers/pet/basic-2-c000.901465-01.bin
	curl -o basic2d $(ARCHIVE)/firmware/computers/pet/basic-2-d000.901465-02.bin
	cat basic2c basic2d > basic2
	rm basic2c basic2d

basic4:
	curl -o basic4b $(ARCHIVE)/firmware/computers/pet/basic-4-b000.901465-23.bin 
	curl -o basic4c $(ARCHIVE)/firmware/computers/pet/basic-4-c000.901465-20.bin 
	curl -o basic4d $(ARCHIVE)/firmware/computers/pet/basic-4-d000.901465-21.bin 
	cat basic4b basic4c basic4d > basic4
	rm basic4b basic4c basic4d

kernal4:
	curl -o kernal4 $(ARCHIVE)/firmware/computers/pet/kernal-4.901465-22.bin

edit40g:
	curl -o edit40g $(ARCHIVE)/firmware/computers/pet/edit-4-40-n-50Hz.901498-01.bin
	
edit80g:
	curl -o edit80g $(ARCHIVE)/firmware/computers/pet/edit-4-80-n-50Hz.4016_to_8016.bin

${EDITROMS}: %.bin: %.asm
	test -e cbm-edit-rom || git clone https://github.com/sjgray/cbm-edit-rom.git
	cp $< cbm-edit-rom/edit.asm
	cd cbm-edit-rom && acme -r editrom.txt editrom.asm
	cp cbm-edit-rom/editrom.bin $@

# load other PET Editor ROM and reboot

loadrom: loadrom.lst
	petcat -w40 -o $@ $<

loadrom.bin: loadrom.a65
	xa -o $@ $<
 
# Clean

clean:
	rm -f romtest01 romtest01a romtest02 romtest02a zero chargen_pet16 char8to16 charPet2Invers
	rm -f basic2 edit2g kernal2 chargen_pet basic4 kernal4 edit40g edit80g 
	rm -f iplldr

rebuildclean:
	rm -f $(EDITROMS)

