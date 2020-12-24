
all: romtest01 romtest02 romtest01a romtest02a bootldr pet2rom

pet2rom: zero basic2 edit2g kernal2 chargen_pet16
	cat chargen_pet16 zero zero zero zero basic2 edit2g zero kernal2 > pet2rom

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
	curl -o basic2a $(ARCHIVE)/firmware/computers/pet/basic-2-c000.901465-01.bin
	curl -o basic2b $(ARCHIVE)/firmware/computers/pet/basic-2-d000.901465-02.bin
	cat basic2a basic2b > basic2
	rm basic2a basic2b

clean:
	rm -f romtest01 romtest01a romtest02 romtest02a zero bootldr pet2rom chargen_pet16 char8to16 charPet2Invers
	rm -f basic2 edit2g kernal2 chargen_pet


	
