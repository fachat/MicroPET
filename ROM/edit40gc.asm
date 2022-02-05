; PET/CBM EDIT ROM - Steve J. Gray - Started: Nov 29/2013
; ================
; A Project to create replacement EDIT ROMs for the PET/CBM line of computers.
; Use MAKE.BAT to assemble (ACME.EXE must be in same folder or in search path).
; For complete documentation see:
;      http://www.6502.org/users/sjgray/projects/editrom/index.html
;
; Edit these VARIABLES to choose which features are included.
;
; The most important is the CODEBASE variable. It determines which main code to use, which will determine
; how many features are available:
;
;   CODEBASE=0 for 40-column (30xx/40xx) machines with Universal Dynamic Motherboard
;   CODEBASE=1 for 80-column (80xx/82xx/9000) machines with Universal Dynamic Motherboard
;   CODEBASE=2 for 80-column (8296/8296D) machines (mostly DIN keyboard versions)
;
; Both CODEBASE=0 and CODEBASE=2 have limited customizability. You may change screen/keyboard and a few other options.
; CODEBASE=1 is designed for maximum customizability (for example COLOURPET, ESC codes, Soft40, SS40, Wedge etc).
;
; If there are no options listed it means that support has not been added yet!
;
; NOTE!: Not all combinations may be valid!!
; NOTE!: SuperPET's require a special adapter to use EPROMS and have compatibility issues with 4K edit roms (see web page)
;
;----------------------------------------------------------------------------------------------------------------------------
; The following DATE and COMMENT strings will be placed in the IO area (if used).
; Take care that comments do not overflow into code space!

!macro DATE      { !pet "2021-01-09" }
!macro COMMENT   { !pet "sjg-editrom-80-N" }

;----------------------------------------------------------------------------------------------------------------------------

; VARIABLE	  FEATURE			VALID OPTIONS			NOTES / FUTURE OPTIONS
;---------	  -------			-------------			----------------------
CODEBASE  = 1   ; Code Base			0=4000, 1=8000, 2=8296		
OPTROM    = 0   ; Location of EXT code		0=Ext Edit ($E800-EFFF), 1=$9000, 2=$A000 (note: code could also extend past end of 1)

KEYSCAN   = 3   ; Keyboard Scanner		0=Graphic,1=Business,2=DIN
KEYBOARD  = 3	; Keyboard type:		0=N-QWERTY,1=B-QWERTY,2=DIN,3=C64,4=B-SJG,5=N-SJG,6=B-QWERTZ,7=B-AZERTY,8=CBM-II (req hw mod)
REFRESH   = 0	; Screen refresh:		0=Euro,1=N.America,2=PAL,3=NTSC,4=9",82=8296D#1,83=8296D#2,90=32-line,91=35-line,92=90x35,99=Custom
REPEATOPT = 1	; Key Repeat Option		0=No (Always ON), 1=Yes
COLUMNS   = 40	; Screen Width			40,80,90,32 columns		Special cases 32 or 90.
ROWS      = 25  ; Screen Height			25,35,16 rows			Special cases 16 or 35.
HERTZ     = 50	; Line Frequency (Clock):	50=Euro,60=N.America
IRQFIX    = 1   ; Fix Jiffy Clock		0=No, 1=Yes			Still needs investigating.
BOOTCASE  = 1	; Initial Screen Mode		0=Text/Lower, 1=Upper/Graphics

ESCCODES  = 0	; Add ESC codes? 		0=No, 1=Yes			Enable when using COLOURPET or SS40.
AUTORUN   = 0   ; Set for BANNER and/or WEDGE	0=No, 1=Yes			Enable if you use EITHER banner and/or wedge.
BYPASS    = 0   ; Check for key to bypass 	0=No, 1=Yes			Hold key on ROW9 to bypass.
BANNER    = 0   ; Custom Banner (power on msg)  0=No, N=Banner# (1-16,98, or 99)   Valid when AUTORUN=1. Refer to docs or source. 99=custom message
WEDGE     = 0	; DOS Wedge			0=No, 1=Yes			Valid when AUTORUN=1.
WEDGEMSG  = 0	; Show wedge message?		0=No, 1=Yes
SOFT40    = 0	; 40 columns on 8032s?		0=No, 1=Yes			Do NOT enable SOFT40 and SS40 at the same time!
SS40      = 0	; Software Switchable Soft-40	0=No, 1=Yes			Also set ESCCODES=1.
SS40MODE  = 0   ; Initial SS40 Mode		40 or 80 columns		Valid when SS40=1.
HARD4080  = 0   ; Hardware 40/80 Board          0=No, 1=Yes			Valid when SS40=1.
VIDSWITCH = 0   ; Video Switching               0=No, 1=Yes			Requires ESC Codes! ESC+0 to ESC+9 to Switch CRTC parameters.

COLOURPET = 0	; ColourPET additions?		0=No, 1=Yes			Requires ESC Codes! ESC+0 to ESC+? to set Colour (unless VIDSWITCH=1).
COLOURVER = 0	; ColourPET Hardware Version	0=Beta,1=Release		0=ColourRAM at $8400, 1=$8800 (use for VICE).
COLOURMODE= 0	; ColourPET Hardware Type	0=Digital, 1=Analog
DEFAULTFG = 0	; ColourPET Foreground colour   0 to 15 RGBI 			0=black,1=DKgry,2=DKBlu ,3=LTblu, 4=DKgrn, 5=Grn,   6=DKcyan,7=LTcyan
DEFAULTBG = 0	; ColourPET Background colour   0 to 15 RGBI 			8=DKred,9=LTred,10=DKpur,11=LTpur,12=DKyel,13=LTyel,14=LTgry,15=white
DEFAULTBO = 0   ; ColourPET Border colour       0 to 15 RGBI
BYPASSFG  = 0   ; ColourPET Bypass FG     	0 to 15 RGBI			Colours when AUTOSTART is bypassed.
BYPASSBG  = 0   ; ColourPET Bypass BG     	0 to 15 RGBI

UPET      = 0   ; Is a Micro-PET                0=No, 1=Yes                     For special Reboot

MOT6845   = 0   ; Is CRTC a Motorola6845?       0=No, 1=Yes			Probably 0=No for compatibility.
REBOOT    = 0	; Add keyboard reboot? 		0=No, 1=Yes
EXECUDESK = 0	; Add Execudesk Menu?		0=No, 1=Yes, 2=Yes/OPTROM>0	Note: Requires BOOT to TEXT mode!
SILENT    = 0	; Disable BELL/CHIME		0=Normal, 1=Disabled
CRUNCH    = 0   ; Remove unneeded code?		0=No, 1=Yes			Removes NOPs, filler, and unreachable code.
BACKARROW = 0   ; Patch for screen mode toggle  0=NO, 1=Yes 2K, 2=Yes EXT	Note: B keyboard scanner only.
INFO      = 0   ; Add project info to code area 0=NO, 1=Yes,2=Yes+FONT		INFO=2 shows character set at top of screen
BUGFIX    = 0   ; Correct Known bugs		0=No, 1=Yes			
;
DEBUG 	  = 0	; Add debugging			0=No, 1=Yes

;----------------------------------------------------------------------------------------------------------------------------------------
; To generate Edit ROMs that are Byte-exact matches to actual Commodore ROMS set the
; following options (If an option is not listed assume "0"):
;
; FIXED: to match zimmers archive /firmware/computers/pet/edit-4-40-n-50Hz.901498-01.bin
; 901498-01 -> CODEBASE=0,KEYSCAN=0,KEYBOARD=0,COLUMNS=40,REFRESH=0,BOOTCASE=1,HERTZ=50,REPEATOPT=1,IRQFIX=1   [edit-4-40-n-50Hz]
; 901499-01 -> CODEBASE=0,KEYSCAN=0,KEYBOARD=0,COLUMNS=40,REFRESH=1,BOOTCASE=1,HERTZ=60,REPEATOPT=0   [edit-4-40-n-60Hz]
; 901474-04 -> CODEBASE=1,KEYSCAN=1,KEYBOARD=1,COLUMNS=80,REFRESH=0,BOOTCASE=0,HERTZ=50,REPEATOPT=1   [edit-4-80-b-50Hz]
; 324243-04 -> CODEBASE=2,KEYSCAN=2,KEYBOARD=2,COLUMNS=80,REFRESH=0,BOOTCASE=0,HERTZ=50,REPEATOPT=0   [edit-4-80-din-50Hz] (8296D)
;
; Additional Edit ROMs will be listed as they are tested and verified as byte-exact.
;----------------------------------------------------------------------------------------------------------------------------------------
