
all: romtest01 romtest02 romtest01a romtest02a bootldr bootimg

bootimg: zero basic2 edit2g kernal2 chargen_pet16 basic4 kernal4 edit40g edit80g bootldr
	# Note: need to stay below upper 16k, as this is mapped to bank 15 on init
	# 8k charrom, 8k basic2, 4k editor2 (2k reserve), 4k kernal2
	# 4k edit80g (2k reserve), 12k basic4, 2k edit40g, 2k empty, 4k kernel4
	cat chargen_pet16 				> bootimg	# 0-8k
	cat basic2 edit2g zero kernal2 			>> bootimg	# 8-24k
	cat edit80g zero				>> bootimg	# 24-28k
	cat basic4 edit40g zero kernal4			>> bootimg	# 28-48k
	cat zero zero zero zero zero zero		>> bootimg	# 48-60k
	cat bootldr					>> bootimg	# 60-64k

zero: 
	dd if=/dev/zero of=zero bs=2048 count=1

chargen_pet16: charPet2Invers char8to16 chargen_pet
	./charPet2Invers < chargen_pet | ./char8to16 > chargen_pet16

charPet2Invers: charPet2Invers.c
	gcc -o charPet2Invers charPet2Invers.c
	
char8to16: char8to16.c
	gcc -o char8to16 char8to16.c

bootldr: bootldr.a65
	xa -w -o bootldr bootldr.a65

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

clean:
	rm -f romtest01 romtest01a romtest02 romtest02a zero bootldr chargen_pet16 char8to16 charPet2Invers
	rm -f basic2 edit2g kernal2 chargen_pet basic4 kernal4 edit40g edit80g bootimg

	
