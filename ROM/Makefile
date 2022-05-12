
all: spiimg loadrom.bin loadrom

EDITROMS=edit40_c64kb.bin edit80_c64kb.bin edit40_grfkb_ext.bin edit80_grfkb_ext.bin edit40_c64kb_ext.bin edit80_c64kb_ext.bin 
TOOLS=romcheck

spiimg: zero basic1 edit1 kernal1 basic2 edit2g kernal2 chargen_pet16 chargen_pet1_16 basic4 kernal4 edit40g edit80g iplldr $(EDITROMS) apmonax edit80_grfkb_ext_chk.bin edit80_chk.bin
	# ROM images
	cat iplldr					> spiimg	# 0-4k   : IPL loader
	cat apmonax					>> spiimg	# 4-8k   : @MON monitor (sys40960)
	# standard character ROM (converted to 16 byte/char)
	cat chargen_pet16 				>> spiimg	# 8-16k  : 8k 16bytes/char PET character ROM
	# BASIC 1
	cat basic1 edit1 zero kernal1			>> spiimg	# 16-32k : BASIC1/Edit/Kernel ROMs (16k $c000-$ffff)
	# BASIC 2
	cat basic2 edit2g zero kernal2 			>> spiimg	# 32-48k : BASIC2/Edit/Kernel ROMs (16k $c000-$ffff)
	# BASIC 4
	cat basic4 					>> spiimg	# 48-60k : BASIC4 ROMS (12k $b000-$dfff)
	cat kernal4					>> spiimg	# 60-64k : BASIC4 kernel (4k)
	# editor ROMs (each line 4k)
	cat edit40_grfkb_ext.bin  			>> spiimg	# sjgray ext 40 column editor w/ wedge by for(;;)
	cat edit40_c64kb_ext.bin	 		>> spiimg	# sjgray ext 40 column editor for C64 kbd (experimental)
	cat edit80_grfkb_ext_chk.bin			>> spiimg	# sjgray ext 80 column editor w/ wedge by for(;;)
	cat edit80_c64kb_ext.bin	 		>> spiimg	# sjgray ext 80 column editor for C64 kbd (experimental)
	cat edit40g zero 				>> spiimg	# original BASIC 4 editor ROM graph keybd
	cat edit40_c64kb.bin 		 		>> spiimg	# sjgray base 40 column editor for C64 kbd (experimental)
	cat edit80_chk.bin zero				>> spiimg	# (original) BASIC 4 80 column editor ROM (graph keybd)
	cat edit80_c64kb.bin 		 		>> spiimg	# sjgray base 80 column editor for C64 kbd (experimental)
	# alternate BASIC 1 character ROM (as 16 bytes/char)
	cat chargen_pet1_16				>> spiimg	# 96-104k: BASIC 1 character set

zero: 
	dd if=/dev/zero of=zero bs=2048 count=1

chargen_pet16: charPet2Invers char8to16 chargen_pet
	./charPet2Invers < chargen_pet | ./char8to16 > chargen_pet16

chargen_pet1_16: charPet2Invers char8to16 chargen_pet1
	./charPet2Invers < chargen_pet1 | ./char8to16 > chargen_pet1_16

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

chargen_pet1:
	curl -o chargen_pet1 $(ARCHIVE)/firmware/computers/pet/characters-1.901447-08.bin

edit1:
	curl -o edit1 $(ARCHIVE)/firmware/computers/pet/rom-1-e000.901447-05.bin

kernal1:
	curl -o kernal1_f0 $(ARCHIVE)/firmware/computers/pet/rom-1-f000.901447-06.bin
	curl -o kernal1_f8 $(ARCHIVE)/firmware/computers/pet/rom-1-f800.901447-07.bin
	cat kernal1_f0 kernal1_f8 > kernal1
	rm kernal1_f0 kernal1_f8 

basic1:
	curl -o basic1_c0 $(ARCHIVE)/firmware/computers/pet/rom-1-c000.901447-01.bin
	curl -o basic1_c8 $(ARCHIVE)/firmware/computers/pet/rom-1-c800.901447-02.bin
	curl -o basic1_d0 $(ARCHIVE)/firmware/computers/pet/rom-1-d000.901447-03.bin
	curl -o basic1_d8 $(ARCHIVE)/firmware/computers/pet/rom-1-d800.901447-04.bin
	cat basic1_c0 basic1_c8 basic1_d0 basic1_d8 > basic1
	rm basic1_c0 basic1_c8 basic1_d0 basic1_d8 

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

kernal4t: 
	curl -o kernal4t $(ARCHIVE)/firmware/computers/pet/kernal-4.901465-22.bin

kernal4: kernal4t romcheck
	./romcheck -s 0xf0 -i 0xdff -o kernal4 kernal4t

edit40g:
	curl -o edit40g $(ARCHIVE)/firmware/computers/pet/edit-4-40-n-50Hz.901498-01.bin
	
edit80g:
	curl -o edit80g $(ARCHIVE)/firmware/computers/pet/edit-4-80-n-50Hz.4016_to_8016.bin

cbm-edit-rom: 
	git clone https://github.com/fachat/cbm-edit-rom.git
	cp cbm-edit-rom/edit.asm cbm-edit-rom/edit.asm.org

${EDITROMS}: %.bin: %.asm cbm-edit-rom
	rm -f cbm-edit-rom/editrom.bin
	rm -f cbm-edit-rom/cpetrom.bin
	cp $< cbm-edit-rom/edit.asm
	cd cbm-edit-rom && acme -r editrom.txt editrom.asm
	-test -e cbm-edit-rom/cpetrom.bin && mv cbm-edit-rom/cpetrom.bin cbm-edit-rom/editrom.bin
	cp cbm-edit-rom/editrom.bin $@

edit80_grfkb_ext_chk.bin: edit80_grfkb_ext.bin romcheck
	./romcheck -s 0xe0 -l 0x800 -i 0x7ff -o $@ $<

edit80_chk.bin: edit80g romcheck
	./romcheck -s 0xe0 -l 0x800 -i 0x7ff -o $@ $<
	

# load other PET Editor ROM and reboot

loadrom: loadrom.lst
	petcat -w40 -o $@ $<

loadrom.bin: loadrom.a65
	xa -o $@ $<

${TOOLS}: % : %.c
	cc -Wall -pedantic -o $@ $<
 
# Clean

clean:
	rm -f romtest01 romtest01a romtest02 romtest02a zero chargen_pet16 char8to16 charPet2Invers
	rm -f basic2 edit2g kernal2 chargen_pet basic4 kernal4 edit40g edit80g basic1 edit1 kernal1 chargen_pet1 chargen_pet1_16
	rm -f iplldr edit80_chk.bin edit80_grfkb_ext_chk.bin kernal4t
	rm -f romcheck loadrom loadrom.bin

rebuildclean:
	rm -f $(EDITROMS)


