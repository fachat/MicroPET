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
CODEBASE  = 0   ; Code Base			0=4000, 1=8000, 2=8296		
OPTROM    = 0   ; Location of EXT code          0=$E800-EFFF, 1=$9000, 2=$A000  Normal is 0.

KEYSCAN   = 3   ; Keyboard Scanner		0=Graphic,1=Business,2=DIN
KEYBOARD  = 3	; Keyboard type:		0=N-QWERTY,1=B-QWERTY,2=DIN,3=C64,4=B-SJG,5=N-SJG,6=B-QWERTZ,7=B-AZERTY,8=CBM-II (req hw mod)
REFRESH   = 1	; Screen refresh:		0=Euro,1=N.America,2=PAL,3=NTSC,4=9",82=8296D#1,83=8296D#2,90=32-line,91=35-line,92=90x35,99=Custom
REPEATOPT = 0	; Key Repeat Option		0=No (Always ON), 1=Yes
COLUMNS   = 40	; Screen Width			40,80,90,32 columns		Special cases 32 or 90.
ROWS      = 25  ; Screen Height			25,35,16 rows			Special cases 16 or 35.
HERTZ     = 60	; Line Frequency (Clock):	50=Euro,60=N.America
IRQFIX    = 0   ; Fix Jiffy Clock		0=No, 1=Yes			Still needs investigating.
FONTSET   = 0  ; Initial Screen Font            0=Text/Lower, 1=Upper/Graphics  Generally: 40xx machines=1, 8xxx machines=0

ESCCODES  = 0	; Add ESC codes? 		0=No, 1=Yes			Enable when using COLOURPET or SS40.
VIDSWITCH = 0   ; Video Switching               0=No, 1=Yes                    Requires ESC Codes! ESC+0 to ESC+9 to Switch CRTC parameters.

AUTORUN   = 1   ; Set for BANNER and/or WEDGE	0=No, 1=Yes			Enable if you use EITHER banner and/or wedge.
BYPASS    = 0   ; Check for key to bypass 	0=No, 1=Yes			Hold key on ROW9 to bypass.
BANNER    = 5   ; Custom Banner (power on msg)  0=No, N=Banner# (1-16,98, or 99)   Valid when AUTORUN=1. Refer to docs or source. 99=custom message
WEDGE     = 1	; DOS Wedge			0=No, 1=Yes			Valid when AUTORUN=1.
WEDGEMSG  = 0	; Show wedge message?		0=No, 1=Yes			Valid when AUTORUN=1 and WEDGE>0.
DISKBOOT  = 0  ; Boot first file on disk?      0=No, 1=Yes                     Valid when AUTORUN=1.

SOFT40    = 0	; 40 columns on 8032s?		0=No, 1=Yes			Do NOT enable SOFT40 and SS40 at the same time!
SS40      = 0	; Software Switchable Soft-40	0=No, 1=Yes			Also set ESCCODES=1.
SS40MODE  = 80  ; Initial SS40 Mode		40 or 80 columns		Valid when SS40=1.
HARD4080  = 0   ; Hardware 40/80 Board          0=No, 1=Yes			Valid when SS40=1.

KEYRESET  = 1  ; Add keyboard reset?           0=No, 1=Yes
SILENT    = 0  ; Disable BELL/CHIME            0=Normal, 1=Disabled
CRUNCH    = 1   ; Remove unneeded code?                0=No, 1=Yes                     Removes NOPs, filler, and unreachable code.
BACKARROW = 1   ; SHIFT-Backarrow Hack code?   0=NO, 1=Yes, 2=Yes EXT          Enable Shift-Backarrow, and where to put the code.
BACKACTION= 0   ; Backarrow Action             0=Text/Graphic, 1=40/80         Which Backarrow Action? NOTE: 40/80 requires ESC Codes!
EXECUDESK = 0  ; Add Execudesk Menu?           0=No, 1=Yes, 2=Yes/OPTROM       Note: Requires BOOT to TEXT mode!
COLOURPET = 0	; ColourPET additions?		0=No, 1=Yes			Requires ESC Codes! ESC+0 to ESC+? to set Colour (unless VIDSWITCH=1).
UPET      = 1   ; Is a Ultra-PET/Micro-PET?     0=No, 1=Yes                     For special Reboot - Andre Fachat's project

COLOURVER = 1	; ColourPET Hardware Version	0=Beta,1=Release		0=ColourRAM at $8400, 1=$8800 (use for VICE).
COLOURMODE= 0	; ColourPET Hardware Type	0=Digital, 1=Analog
DEFAULTFG = 5	; ColourPET Foreground colour   0 to 15 RGBI 			0=black,1=DKgry,2=DKBlu ,3=LTblu, 4=DKgrn, 5=Grn,   6=DKcyan,7=LTcyan
DEFAULTBG = 0	; ColourPET Background colour   0 to 15 RGBI 			8=DKred,9=LTred,10=DKpur,11=LTpur,12=DKyel,13=LTyel,14=LTgry,15=white
DEFAULTBO = 0   ; ColourPET Border colour       0 to 15 RGBI
BYPASSFG  = 5   ; ColourPET Bypass FG     	0 to 15 RGBI			Colours when AUTOSTART is bypassed.
BYPASSBG  = 0   ; ColourPET Bypass BG     	0 to 15 RGBI

MOT6845   = 0   ; Is CRTC a Motorola6845?       0=No, 1=Yes			Probably 0=No for compatibility.
INFO      = 0   ; Add project info to code area 0=NO, 1=Yes,2=Yes+FONT		INFO=2 shows character set at top of screen

BUGFIX    = 1   ; Correct Known bugs		0=No, 1=Yes			
DEBUG 	  = 0	; Add debugging			0=No, 1=Yes
NOFILL    = 0   ; Disable FILL?                 0=No, 1=Yes                     Lets you test assemble but will NOT generate usable code!!!!!

