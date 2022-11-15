;****************************************************************************
;
;           MV_TECA_V11.inc (header file for MV_TECA_V11.asm 8/20/06
;
;           Real Time Variable Display, and Configurator for MS_TECA_V11
;
;         By Robert Hiebert with technical assistance from Dan Williams
;           and all those who contributed to the Megasquirt projects
;
;****************************************************************************

;****************************************************************************
;
; This is a custom and comparatively primitive version of Megaview,
; by B. A. Bowling And A. C. Grippo
; It is application specific for MS_TECA and is written in assembler, using
; "Win IDE" from P+E Microcomputer Systems, to avoid any unpleasant "C"
; compiler issues.
; Like MS_ECU and MS_TECA, it is extensively commented, as much for our
; benefit, as for those who may wish to modify it for their own use.
;
;****************************************************************************

;****************************************************************************
;
; --------------------------------- Operation -------------------------------
;
; On power up, the unit defaults to "display" mode, screen #0. In this mode,
; the user has a choice of 6,(0-5), screens which display the variables name
; abbreviation on the top line, and their corresponding real time values on
; the bottom line, or the status abbreviation on the top line, and their
; corresponding real time status on the lower line. The lower line is
; updated every 250 miliseconds.
; Screen numbers 6 and 7 are entry points for constant configuration while
; in "Configuration" mode.
; Screen numbers numbers 8, 9, 10, and 11 are the SCI command screens.
; Screen number 12 is the burn constants screen.
; Screen numbers numbers 13, 14, 15, and 16 are SCI command done screens.
; Screen number 17 is the burn constants done screen.
;
; Screen 0 is for the transmission and MS_TECA status, and displays
; "ML Gr CC TC FC EP EB"
; "ML" is Manual Lever Position, (P,R,N,D,M2, or M1) and uses "mlpsp"
; "Gr" is Current Gear, (1,2,3, or 4)and uses "mlpsp" and "gear"
; "CC" is Coast Clutch applied status, (Y or N), and uses "trans2"
; "TC" is Torque Converter Clutch applied status, (Y or N), uses "trans2"
; "FC" is DFC permissive status, (Y or N), and uses "trans2"
; "EP" is Exhaust brake permissive, below max exhaust pressure status,
;  (Y or N), and uses "trans2"
; "EB" is Exhaust brake applied status, (Y or N), and uses "trans2"
;
; Screen 1 is for the guages, and displays "RPM MPH Prs TOT Vlt "
; "RPM" is Engine RPM in RPM /20, and uses "rpm"
; "MPH" is Vehicle Speed, in MPH*2, and uses "mph"
; "Prs" is Line Pressure in PSI, and uses "Lpsi"
; "TOT" is Transmission Oil Temperature in degreesF+40, and uses "TOTemp"
; "Vlt" is System Voltage in volts*10, and uses "volts"
;
; Screen 2 is to establish EPC Duty Factor/pulse width/line pressure
; relationship, and displays "DuF TPP PWH:PWL Prs "
; "DuF" is  EPC Duty Factor from "TO" table, stall or shift tables, or,
;      absolute values "EPC_TCC", or "EPC_decel", and uses "df"
; "TPP" is Throttle Position in percent, and uses "TPSp"
; "PWH" is final EPC PW Hi byte and uses "EPCpwH"
; "PWL" is final EPC PW Lo byte and uses "EPCpwL"
; "Prs" is Line Pressure in PSI, and uses "Lpsi"
;
; Screen 3 is to establish IAC pulse width/engine RPM relationship,
; and displays "SeH SeL IAC Ipw RPM "
; "SeH is time since MS_TECA power up seconds Hi byte
; "SeL is time since MS_TECA power up seconds Lo byte
; "IAC" is Idle Air Control Sensor 8 bit ADC reading and uses "IAC"
; "IACpw" is Idle Air Control pulse width in 100uS, and uses "IACpw"
; "RPM" is Engine RPM in RPM /20, and uses "rpm"
;
; Screen 4 is for Duty Factor tuning, and displays "RPM MAP TPP TrA DuF "
; "RPM" is Engine RPM in RPM /20, and uses "rpm"
; "MAP" is Manifold Absolute Pressure in KPA, and uses uses "kpa"
; "TPP" is Throttle Position in percent, and uses "TPSp"
; "TrA" is EPC Trim Correction Adder, and uses "TrimAdd"
; "DuF" is  EPC Duty Factor from "TO" table, stall or shift tables, or,
;      absolute values "EPC_TCC", or "EPC_decel", and uses "df"
;
; Screen 5 is for Duty Factor observations, before and after corrections,
; and displays "DuF DF1 DF2 DF3 DFF "
; "DuF" is  EPC Duty Factor from "TO" table, stall or shift tables, or,
;      absolute values "EPC_TCC", or "EPC_decel", and uses "df"
; "DF1" is "df" after Bat cor, before TOT cor and uses "df1"
; "DF2" is "df1" after TOT cor, before Trim cor and uses "df2"
; "DF3" is "df2" after Trim cor, before Dither cor and uses "df3"
; "DFF" is "df2" after Dither cor(Final EPC Duty Factor) and uses "dff"
;
; Screen 6 displays "Cons Group1 Prs Mode"
; This is the entry point of the first group of constants, and is
; accessed by pressing the "Toggle Mode" button
;
; Screen 7 displays "Cons Group2 Prs Mode"
; This is the entry point of the second group of constants, and is
; accessed by pressing the "Toggle Mode" button
;
; Screen 8 displays "UpLd G1 Cons Prs Mde"
; This is the entry point to upload the first group of constants from
; MS_TECA, and is accessed by pressing the "Toggle Mode" button
;
; Screen 9 displays "UpLd G2 Cons Prs Mde"
; This is the entry point to upload the second group of constants from
; MS_TECA, and is accessed by pressing the "Toggle Mode" button
;
; Screen 10 displays "DnLd G1 val Prs Mode"
; This is the entry point to download the selected Cons1 value to
; MS_TECA, and is accessed by pressing the "Toggle Mode" button
;
; Screen 11 displays "DnLd G2 val Prs Mode"
; This is the entry point to download the selected Cons2 value to
; MS_TECA, and is accessed by pressing the "Toggle Mode" button
;
; Screen 12 displays "Burn Cons Press Mode"
; This is the entry point to the Burn Constants from MS_TECA RAM to
; Flash section, and is accessed by pressing the "Toggle Mode" button
;
; Screen 13 displays "UpLd G1 Done Prs Mde"
; This screen indicates that the Cons1 group has been uploaded, and
; prompts the user to return to display screen #0 by pressing the
; "Toggle Mode" button
;
; Screen 14 displays "UpLd G2 Done Prs Mde"
; This screen indicates that the Cons2 group has been uploaded, and
; prompts the user to return to display screen #0 by pressing the
; "Toggle Mode" button
;
; Screen 15 displays "DnLd V1 Done Prs Mde"
; This screen indicates that the selected Cons1 value has been
; downloaded to MS_TECA RAM, and prompts the user to return to
; display screen #0 by pressing the "Toggle Mode" button
;
; Screen 16 displays "DnLd V2 Done Prs Mde"
; This screen indicates that the selected Cons2 value has been
; downloaded to MS_TECA RAM, and prompts the user to return to
; display screen #0 by pressing the "Toggle Mode" button
;
; Screen 17 displays "Burn Done Press Mode"
; This screen indicates that the MS_TECA configuration constants
; have been burned from RAM to Flash, and prompts the user to
; return to display screen #0 by pressing the "Toggle Mode" button
;
; There are 4 control buttons on the display. From right to left:
; PTA3 - Toggle Mode, Display / Configure
; PTA2 - Display Freeze / Select Configuration Constant
; PTA1 - Display Scroll Right / Increase Selected Constant
; PTA0 - Display Scroll Left / Decrease Selected Constant
;
; While in "Display" mode, pressing PTA2 once freezes the screen so the real
; time variables are not up dated. Pressing PTA2 again will unfreeze the
; screen. This is intended for use with the "tuning" screens.
; While in "Display" mode, pressing PTA1 will advance to the next display
; screen.
; While in "Display mode, pressing PTA0 will retreat to the previous display
; screen.
;
; Holding PTA0 or PTA1 down for more than 1/2 second will "auto repeat" the
; function at a rate of 4HZ.
;
; While in "Display" mode, screens 7 and less, Pressing PTA3 has no effect.
; In display screen 8, Pressing PTA3 changes to "Configure" mode, and
; selects the first index of constants.
; In display screen 9, Pressing PTA3 changes to "Configure" mode, and
; selects the second index of constants.
; While in "Configure" mode, Pressing PTA3 will return to the first
; Display screen.
;
; While in "Configure" mode, pressing PTA1 will advance to the next
; configurable constant in the ordered list.
; While in "Configure" mode, pressing PTA0 will retreat to the previous
; configurable constant in the ordered list.
; While in "Configure" mode presssing PTA2 will select the current diplayed
; configurable constant for editing, and display "SELECTED" on the right
; lower line. Pressing PTA2 again will unselect the constant and clear
; the right lower line.
; While a configurable constant is "selected", pressing PTA1 will increment
; the value by 1. Pressing PTA0 will decrement the value by 1.
;
; Holding PTA0 or PTA1 down for more than 1/2 second will "auto repeat" the
; function at a rate of 4HZ.
;
; In "Configure" mode The Flash Configurable Constants values are displayed,
; on the lower line, in the ordered list im which they appear in the MS_TECA
; source.
;
; First is the "TO" table. The display line is shown below.
;
; "TO KPArow 0 RPMcol 0", This is modified for the 64 TO values by
;  incrmenting the column and row numbers, and uses the "TO,x" constants.
;
; Next we have the RPM bins for the "TO" table
;
; "TO Tab RPM c0 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c1 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c2 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c3 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c4 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c5 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c6 RPM/20", uses "RPM_range,x"
; "TO Tab RPM c7 RPM/20", uses "RPM_range,x"
;
; Next we have the KPA bins for the "TO" table
;
; "TO Tab KPA row0 KPA ", uses "KPA_range,x"
; "TO Tab KPA row1 KPA ", uses "KPA_range,x"
; "TO Tab KPA row2 KPA ", uses "KPA_range,x"
; "TO Tab KPA row3 KPA ", uses "KPA_range,x"
; "TO Tab KPA row4 KPA ", uses "KPA_range,x"
; "TO Tab KPA row5 KPA ", uses "KPA_range,x"
; "TO Tab KPA row6 KPA ", uses "KPA_range,x"
; "TO Tab KPA row7 KPA ", uses "KPA_range,x"
;
; Next we have the % bins for the "TPS_range" table
;
; "Throttle Open % c0 %", uses "TPS_range,x"
; "Throttle Open % c1 %", uses "TPS_range,x"
; "Throttle Open % c2 %", uses "TPS_range,x"
; "Throttle Open % c3 %", uses "TPS_range,x"
; "Throttle Open % c4 %", uses "TPS_range,x"
; "Throttle Open % c5 %", uses "TPS_range,x"
; "Throttle Open % c6 %", uses "TPS_range,x"
; "Throttle Open % c7 %", uses "TPS_range,x"
;
; Next we have the EPC duty factor bins for the "EPC_stall" table
;
; "EPCdf Stall c0 0-255", uses "EPC_stall,x"
; "EPCdf Stall c1 0-255", uses "EPC_stall,x"
; "EPCdf Stall c2 0-255", uses "EPC_stall,x"
; "EPCdf Stall c3 0-255", uses "EPC_stall,x"
; "EPCdf Stall c4 0-255", uses "EPC_stall,x"
; "EPCdf Stall c5 0-255", uses "EPC_stall,x"
; "EPCdf Stall c6 0-255", uses "EPC_stall,x"
; "EPCdf Stall c7 0-255", uses "EPC_stall,x"
;
; Next we have the EPC duty factor bins for the "EPC_12" table
;
; "EPCdf 1-->2 c0 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c1 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c2 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c3 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c4 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c5 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c6 0-255", uses "EPC_12,x"
; "EPCdf 1-->2 c7 0-255", uses "EPC_12,x"
;
; Next we have the EPC duty factor bins for the "EPC_23" table
;
; "EPCdf 2-->3 c0 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c1 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c2 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c3 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c4 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c5 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c6 0-255", uses "EPC_23,x"
; "EPCdf 2-->3 c7 0-255", uses "EPC_23,x"
;
; Next we have the EPC duty factor bins for the "EPC_34" table
;
; "EPCdf 3-->4 c0 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c1 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c2 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c3 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c4 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c5 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c6 0-255", uses "EPC_34,x"
; "EPCdf 3-->4 c7 0-255", uses "EPC_34,x"
;
; Finally, are the configurable constants in the ordered list, with the
; value the variable represents
;
; "EPCdf TCC App  0-255", uses "EPC_TCC"
; "EPCdf DFC App  0-255", uses "EPC_decel"
; "EPC Rise Time   20mS", uses "EPC_rise"
; "EPC Hold Time   20mS", uses "EPC_hold"
; "SS1 Delay Time  20mS", uses "SS1_del"
; "CCS Delay Time  20mS", uses "CCS_del"
; "ExBrk Del Time  20mS", uses "ExBrk_del"
; "RPM TCC Min   RPM/20", uses "TCC_min_RPM"
; "MPH Stall Max  MPH*2", uses "MPH_stall"
; "TPS DOT Min  V/S*100", uses "TPSrate"
; "TPS Cls Thrt cnt ADC", uses "CT_cnt"
; "TPS WO Thrt cnt  ADC", uses "WOT_cnt"
; "TPS span (WOT - CT) ", uses "TPSspan"
; "TPS Cls Thrt min % %", uses "CT_min"
; "EPCPW Dither Adder  ", uses "DithAdd"
; "Bat Volt Cor max val", uses "BatFac"
; "EPC Trim Cor max val", uses "TrimFac"
; "Tun Config Bit Field", uses "TuneConfig"
; "RPMk Hi 6=039 8=029 ", uses "rpmk", 6CYL=$27=39T, 8cyl=$1D=29T
; "RPMk Lo 6=016 8=076 ", uses "rpmk+1", 6cyl=$10=16T, 8cyl=$4C=76T
; "TOT Temp cor max val", uses "TOTempFac"
; "Auto IAC start IACpw", uses "AIAC"
; "Auto IAC time 100mS ", uses "AIACcmp"
; "TOT cor rail Hi F-40", uses "TOThi"
; "TOT cor rail Lo F-40", uses "TOTlo"
; "Cons Grp2  placehold", is displayed for out of range value
;
; To edit a value in either the "group1" or "group2" of configurable
; constants, scroll through the display screens to either screen 6 or 7
; and press PTA3 to bring up that range of screens. Scroll to the desired
; screen and press PTA2 to select it. Increment value with PTA1,
; or decrement it with PTA0. When you reach the desired value, unselect
; by pressing PTA2, then return to display screen #0 by pressing PTA3.
; Scroll to either screen 10 or 11 as required, and press PTA3 to download
; the group1 or group2 value to MS_TECA RAM. Press PTA3 again when prompted,
; to return to display screen #0. If you are satisfied with the new value,
; scroll to screen 12 and press PTA3 to burn all values in MS_TECA RAM to
; Flash. Press PTA3 at the prompt, to return to display screen #0
;
; On start up, MV_TECA loads the group1 and group2 of constants from MS_ECU
; to MV_TECA before the main loop begins. This can also be done at any time
; by scrolling to either screen 8 or 9, select it with PTA3, then press
; PTA3 again at the prompt to return to display screen #0.
;
;****************************************************************************

;****************************************************************************
;
; -------------------------- MV_TECA Hardware Wiring  ------------------------
;
;****************************************************************************
;
; ----- Inputs [port name - function] -----
;
;  PTA0      - Display Scroll Left / Decrease Selected Constant
;  PTA1      - Display Scroll Right / Increase Selected Constant
;  PTA2      - Display Freeze / Select Configuration Constant
;  PTA3      - Toggle Mode, Display / Configure
;
; ----- Outputs [port name - function] -----
;
;  PTB4       - VFD Display Enable
;  PTB5       - VFD Display R/W
;  PTB6       - VFD Display RS
;  PTC0       - VFD Display data DB4
;  PTC1       - VFD Display data DB5
;  PTC2       - VFD Display data DB6
;  PTC3       - VFD Display data DB7
;
;****************************************************************************

;****************************************************************************
; ------------------------ Input Port Equates -------------------------------
;****************************************************************************

Sw0     equ 0     ; PTA0 - Display Scroll Left / Decrease Selected Con
Sw1     equ 1     ; PTA1 - Display Scroll Right / Increase Selected Con
Sw2     equ 2     ; PTA2 - Display Freeze / Select Configuration Con
Sw3     equ 3     ; PTA3 - Toggle Mode, Display / Configure

;****************************************************************************
; ------------------------ Output Port Equates ------------------------------
;****************************************************************************

Enable     equ 4     ; PTB4 - VFD Display Enable
Rd_Wrt     equ 5     ; PTB5 - VFD Display R/W
Reg_Sel    equ 6     ; PTB6 - VFD Display RS
DB0        equ 0     ; PTC0 - VFD Display data DB0 (4 bit mode)
DB1        equ 1     ; PTC1 - VFD Display data DB1 (4 bit mode)
DB2        equ 2     ; PTC2 - VFD Display data DB2 (4 bit mode)
DB3        equ 3     ; PTC3 - VFD Display data DB3 (4 bit mode)
DB4        equ 0     ; PTC0 - VFD Display data DB4
DB5        equ 1     ; PTC1 - VFD Display data DB5
DB6        equ 2     ; PTC2 - VFD Display data DB6
DB7        equ 3     ; PTC3 - VFD Display data DB7

;****************************************************************************
; ------------------------ Output Mask Equates ------------------------------
;****************************************************************************

DB0m     equ $01     ; %00000001 - PTC0 - VFD Display data DB0 (4 bit mode)
DB1m     equ $02     ; %00000010 - PTC1 - VFD Display data DB1 (4 bit mode)
DB2m     equ $04     ; %00000100 - PTC2 - VFD Display data DB2 (4 bit mode)
DB3m     equ $08     ; %00001000 - PTC3 - VFD Display data DB3 (4 bit mode)
DB4m     equ $10     ; %00010000 - PTC0 - VFD Display data DB4
DB5m     equ $20     ; %00100000 - PTC1 - VFD Display data DB5
DB6m     equ $40     ; %01000000 - PTC2 - VFD Display data DB6
DB7m     equ $80     ; %10000000 - PTC3 - VFD Display data DB7


;****************************************************************************
; -------------- "Flags" Operating Status bit field equates -----------------
;****************************************************************************

mde      equ 0  ; 1 = Configure mode             0 = Display mode
frz      equ 1  ; 1 = Dsply Vars frozen          0 = Dsply vars 250mS update
sel      equ 2  ; 1 = Current Constant Selected  0 = No Constant selected
RcvG1    equ 3  ; 1 = Receiving Cons Grp1        0 = Not receiving Cons Grp1
RcvG2    equ 4  ; 1 = Receiving Cons Grp2        0 = Not receiving Cons Grp2
LinChng  equ 5  ; 1 = Bot Line changed           0 = Bot Line not changed

;****************************************************************************
; ----------------- "LPflags","ARCflags","ARflags" equates ------------------
;****************************************************************************

Sw0LP     equ 0     ; 1 = last pass closed(Lo)   0 = last pass open(Hi)
Sw1LP     equ 1     ; 1 = last pass closed(Lo)   0 = last pass open(Hi)
Sw2LP     equ 2     ; 1 = last pass closed(Lo)   0 = last pass open(Hi)
Sw3LP     equ 3     ; 1 = last pass closed(Lo)   0 = last pass open(Hi)

;****************************************************************************
; --------------------------- "Swflags" equates -----------------------------
;****************************************************************************

Sw0cls     equ 0     ; 1 = contacts closed(Lo)     0 = contacts open(Hi)
Sw1cls     equ 1     ; 1 = contacts closed(Lo)     0 = contacts open(Hi)
Sw2cls     equ 2     ; 1 = contacts closed(Lo)     0 = contacts open(Hi)
Sw3cls     equ 3     ; 1 = contacts closed(Lo)     0 = contacts open(Hi)

;****************************************************************************
; ------------------ "mlpsp","mlpsp_prv" Status equates ---------------------
;****************************************************************************

P      equ 1     ; MLPS in "Park" position             0 = out of range
R      equ 2     ; MLPS in "Reverse" position          0 = out of range
N      equ 3     ; MLPS in "Neutral" position          0 = out of range
D      equ 4     ; MLPS in "Drive" position            0 = out of range
M2     equ 5     ; MLPS in "Manual Second" position    0 = out of range
M1     equ 6     ; MLPS in "Manual First" position     0 = out of range
SF     equ 7     ; MLPS Sensor Failure                 0 = out of range

;****************************************************************************
; ------- "gearcnt","gearcnt_prv","gear","gear_prv" Status equates ----------
;****************************************************************************

first     equ 1     ; Drive 1
second    equ 2     ; Drive 2
third     equ 3     ; Drive 3
forth     equ 4     ; Drive 4

;****************************************************************************
; ---------------- "trans" Operating Status bit field equates ---------------
;****************************************************************************

Estop     equ 0     ; 1 = Engine stopped             0 = Engine not stopped
Vstop     equ 1     ; 1 = Vehicle stopped            0 = Vehicle not stopped
ClsThrt   equ 2     ; 1 = TPS at closed throttle     0 = TPS not Close Throt
RPMtcc    equ 3     ; 1 = RPM TCC app permissive     0 = No RPM TCC perm.
MPHstall  equ 4     ; 1 = MPH at stall condition     0 = MPH above stall
accel     equ 5     ; 1 = TPS DOT EPC mode           0 = No TPS DOT EPC mode
PSIbrk    equ 6     ; 1 = Exh Brk Exh prs permissive 0 = No ExhBrk prs perm.
D1D2      equ 7     ; 1 = In Drive 1 or 2            0 = Not in Drive 1 or 2

;****************************************************************************
; --------------- "trans2" Operating Status bit field equates ---------------
;****************************************************************************

CCSon     equ 0     ; 1 = CCS on                     0 = CCS off
TCCon     equ 1     ; 1 = TCC on                     0 = TCC off
DFCon     equ 2     ; 1 = DFC permissive             0 = No DFC permissive
Brkon     equ 3     ; 1 = Exhaust Brake on           0 = Exh Brk off
SSprog    equ 4     ; 1 = Gear Change in progress    0 = No GC in progress
TCprog    equ 5     ; 1 = TCC apply in progress      0 = No TCC in progress
EPCmov    equ 6     ; 1 = EPC moving conditions      0 = EPC not move cond

;****************************************************************************
; -------------------------- RAM Variables ---------------------------------
; - I/O Registers from $000 to $003F(0 to 63)(64 bytes)
; - RAM from $0040 to $023F(64 to 575)(512 bytes)
;****************************************************************************

;***************************************************************************
; - Misc. Variables
;***************************************************************************

;Memory Location $0040 (decimal 64)

Sw0DB:          ds 1     ; Switch #0 de-bounce timer counter variable
Sw0ARC:         ds 1     ; Switch #0 auto-repeat command timer counter var
Sw0AR:          ds 1     ; Switch #0 auto-repeat timer counter variable
Sw1DB:          ds 1     ; Switch #1 de-bounce timer counter variable
Sw1ARC:         ds 1     ; Switch #1 auto-repeat command timer counter var
Sw1AR:          ds 1     ; Switch #1 auto-repeat timer counter variable
Sw2DB:          ds 1     ; Switch #2 de-bounce timer counter variable
Sw2ARC:         ds 1     ; Switch #2 auto-repeat command timer counter var
Sw2AR:          ds 1     ; Switch #2 auto-repeat timer counter variable
Sw3DB:          ds 1     ; Switch #3 de-bounce timer counter variable
Sw3ARC:         ds 1     ; Switch #3 auto-repeat command timer counter var
Sw3AR:          ds 1     ; Switch #3 auto-repeat timer counter variable
LPflags:        ds 1     ; Switch last pass status bit field variable
ARCflags:       ds 1     ; Switch auto-repeat command status bit field
ARflags:        ds 1     ; Switch auto-repeat status bit field variable
Swflags:        ds 1     ; Switch status bit field variable

;Memory Location $0050 (decimal 80)

ModeCntr:       ds 1     ; Counter for determining "mode" bit status
FrzCntr:        ds 1     ; Counter for determining "frz" bit status
SelCntr:        ds 1     ; Counter for determining "sel" bit status
flags:          ds 1     ; Bit field for operating status flags (1 of 2)
ScrnCnt:        ds 1     ; Counter for display screen numbers
ScrnCnt_prv:    ds 1     ; Screen count number previous
ScrnCnt_Lst:    ds 1     ; Screen count number last
ConCnt:         ds 1     ; Counter for Constant numbers
ConCnt_prv:     ds 1     ; Constant number previous
ConCnt_Lst:     ds 1     ; Constant number last
CurCon:         ds 1     ; Value of current selected constant
ConVal:         ds 1     ; Value for constant data

;****************************************************************************
; ----------------------- Time Clock Variables ------------------------------
;****************************************************************************

mS:             ds 1	 ; Milliseconds counter
mSx5:           ds 1     ; 5 Milliseconds counter

;***************************************************************************
; - Serial Communications Interface Variables
;***************************************************************************

ByteCnt:        ds 1     ; Count of bytes to receive via SCI
ByteGoal:       ds 1     ; Desired number of bytes to receive via SCI

;Memory Location $0060 (decimal 96)

readbuf:        ds 1     ; Buffer for temporary storage of received byte


;***************************************************************************
; - VFD Variables
;***************************************************************************

value:          ds 1     ; Value sent to VFD(instruction or data)
LineNum:        ds 1     ; Line number for VFD(for instruction)
ColNum:         ds 1     ; Column number for VFD(for instruction)
DatVal:         ds 1     ; Data value for VFD
ComVal:         ds 1     ; Value for VFD command data
TopVal:         ds 1     ; Value for VFD top line data
DisVal:         ds 1     ; Value for VFD bottom line variable data


;***************************************************************************
; - Variables to display VFD bottom line
;***************************************************************************

BotLin0:      ds 1     ; Bottom Line Column 0
BotLin1:      ds 1     ; Bottom Line Column 1
BotLin2:      ds 1     ; Bottom Line Column 2
BotLin3:      ds 1     ; Bottom Line Column 3
BotLin4:      ds 1     ; Bottom Line Column 4
BotLin5:      ds 1     ; Bottom Line Column 5
BotLin6:      ds 1     ; Bottom Line Column 6
BotLin7:      ds 1     ; Bottom Line Column 7

;Memory Location $0070 (decimal 112)

BotLin8:      ds 1     ; Bottom Line Column 8
BotLin9:      ds 1     ; Bottom Line Column 9
BotLin10:     ds 1     ; Bottom Line Column 10
BotLin11:     ds 1     ; Bottom Line Column 11
BotLin12:     ds 1     ; Bottom Line Column 12
BotLin13:     ds 1     ; Bottom Line Column 13
BotLin14:     ds 1     ; Bottom Line Column 14
BotLin15:     ds 1     ; Bottom Line Column 15
BotLin16:     ds 1     ; Bottom Line Column 16
BotLin17:     ds 1     ; Bottom Line Column 17
BotLin18:     ds 1     ; Bottom Line Column 18
BotLin19:     ds 1     ; Bottom Line Column 19

;***************************************************************************
; - Variables to display VFD bottom line, last pass through main loop
;***************************************************************************

BotLin0L:      ds 1     ; Bottom Line Column 0, last pass
BotLin1L:      ds 1     ; Bottom Line Column 1, last pass
BotLin2L:      ds 1     ; Bottom Line Column 2, last pass
BotLin3L:      ds 1     ; Bottom Line Column 3, last pass

;Memory Location $0090 (decimal 144)

BotLin4L:      ds 1     ; Bottom Line Column 4, last pass
BotLin5L:      ds 1     ; Bottom Line Column 5, last pass
BotLin6L:      ds 1     ; Bottom Line Column 6, last pass
BotLin7L:      ds 1     ; Bottom Line Column 7, last pass
BotLin8L:      ds 1     ; Bottom Line Column 8, last pass
BotLin9L:      ds 1     ; Bottom Line Column 9, last pass
BotLin10L:     ds 1     ; Bottom Line Column 10, last pass
BotLin11L:     ds 1     ; Bottom Line Column 11, last pass
BotLin12L:     ds 1     ; Bottom Line Column 12, last pass
BotLin13L:     ds 1     ; Bottom Line Column 13, last pass
BotLin14L:     ds 1     ; Bottom Line Column 14, last pass
BotLin15L:     ds 1     ; Bottom Line Column 15, last pass
BotLin16L:     ds 1     ; Bottom Line Column 16, last pass
BotLin17L:     ds 1     ; Bottom Line Column 17, last pass
BotLin18L:     ds 1     ; Bottom Line Column 18, last pass
BotLin19L:     ds 1     ; Bottom Line Column 19, last pass

;Memory Location $0080 (decimal 128)

;***************************************************************************
; - Variables to hold ASCII conversions
;***************************************************************************

AC_100:     ds 1     ; 8 bit ASCII conversion 100s column
AC_10:      ds 1     ; 8 bit ASCII conversion 10s column
AC_1:       ds 1     ; 8 bit ASCII conversion 1s column

;****************************************************************************
; - Variables for integer math
;****************************************************************************

INTACC1:      rmb 4
INTACC2:      rmb 4

;****************************************************************************
; - Temporary variables
;****************************************************************************

tmp1:     ds 1
tmp2:     ds 1
tmp3:     ds 1
tmp4:     ds 1
tmp5:     ds 1

;Memory Location $00A0 (decimal 160)

tmp6:     ds 1
tmp7:     ds 1
tmp8:     ds 1
tmp9:     ds 1
tmp10:    ds 1
tmp11:    ds 1
tmp12:    ds 1
tmp13:    ds 1
tmp14:    ds 1
tmp15:    ds 1
tmp16:    ds 1
tmp17:    ds 1
tmp18:    ds 1
tmp19:    ds 1
tmp20:    ds 1
tmp21:    ds 1

;Memory Location $00A0 (decimal 160)

local_tmp:   ds 1

;****************************************************************************
; - RS232 Real Time Variables
;****************************************************************************

secH:           ds 1     ; Seconds counter, Hi byte
secL:           ds 1	 ; Seconds counter, Lo byte
RPM:            ds 1     ; Engine RPM/20 (0 to 5100 rpm in byte variable)
MPH:            ds 1     ; MPH*2 (0 to 128 MPH in byte variable)
trans:          ds 1     ; Transmission status bit field variable(1 of 2)
trans2:         ds 1     ; Transmission status bit field variable(2 of 2)
gearcnt:        ds 1     ; Current gear count(sequential gear selector)
MAP:            ds 1     ; Manifold Absolute Pressure 8 bit ADC reading
MLPS:           ds 1     ; Manual Lever Position Switch 8 bit ADC reading
TOT:            ds 1     ; Transmission Oil Temperature 8 bit ADC reading
Lprs:           ds 1     ; Line Pressure 8 bit ADC reading
BAT:            ds 1     ; Battery Voltage 8 bit ADC reading
IAC:            ds 1     ; Engine Idle Air Control Sensor 8 bit ADC reading
Trim:           ds 1     ; Electronic Pressure Control trim 8 bit ADC rdng
TPS:            ds 1     ; Throttle Position Sensor 8 bit ADC reading

;Memory Location $00B0 (decimal 176)

KPA:            ds 1     ; Manifold Absolute Pressure in KPA
MLPSp:          ds 1     ; Manual Lever Position Switch position
TOTemp:         ds 1     ; Transmission Oil Temperature variable
                         ;(degrees F - 40 to fit range in byte variable)
Lpsi:           ds 1     ; Line pressure in PSI
Volts:          ds 1     ; Battery voltage to 0.1V resolution
IACpw:          ds 1     ; IAC pulse width variable(0-60, 100uS resolution)
TPSp:           ds 1     ; TPSscale * 100 / TPSspan = TPSp(TPS percent)
TOTempDif:      ds 1     ; Difference between "TOTemp" and 180(140F)
TOTempP:        ds 1     ; TOTemp percent calculation value (TOTemp/180)
TOTAdd:         ds 1     ; Trans Oil Temp correction Add/Subtract value
TrimDif:        ds 1     ; Difference between "Trim" and 128(mid point)
TrimP:          ds 1     ; Trim percent calculation value (TrimDif/128)
TrimAdd:        ds 1     ; EPC Trim correction Add/Subtract value
df:             ds 1     ; EPC Duty Factor from "TO" table, stall or shift
                         ; tables, or, absolute values "EPC_TCC", or
                         ; "EPC_decel" (scaled to 256)
df1:            ds 1     ; "df" after TOT cor, before Trimr cor
dff:            ds 1     ; "df" after Trim cor(Final EPC Duty Factor)

;Memory Location $00C0 (decimal 192)

EPCpwH:         ds 1     ; EPC Pulse Width Hi byte
EPCpwL:         ds 1     ; EPC Pulse Width Lo byte

;****************************************************************************
; - This marks the end of the real time download variables, 33 in total
;****************************************************************************
;****************************************************************************
; ------------------------- Configuration Constants -------------------------
;****************************************************************************

;****************************************************************************
; - First group of 128 bytes
;****************************************************************************

;****************************************************************************
; - Torque table configuration constants
;****************************************************************************

TO_0_0:             ds 1     ; TO Table, KPA row 0, RPM col 0
TO_0_1:             ds 1     ; TO Table, KPA row 0, RPM col 1
TO_0_2:             ds 1     ; TO Table, KPA row 0, RPM col 2
TO_0_3:             ds 1     ; TO Table, KPA row 0, RPM col 3
TO_0_4:             ds 1     ; TO Table, KPA row 0, RPM col 4
TO_0_5:             ds 1     ; TO Table, KPA row 0, RPM col 5
TO_0_6:             ds 1     ; TO Table, KPA row 0, RPM col 6
TO_0_7:             ds 1     ; TO Table, KPA row 0, RPM col 7
TO_1_0:             ds 1     ; TO Table, KPA row 1, RPM col 0
TO_1_1:             ds 1     ; TO Table, KPA row 1, RPM col 1
TO_1_2:             ds 1     ; TO Table, KPA row 1, RPM col 2
TO_1_3:             ds 1     ; TO Table, KPA row 1, RPM col 3
TO_1_4:             ds 1     ; TO Table, KPA row 1, RPM col 4
TO_1_5:             ds 1     ; TO Table, KPA row 1, RPM col 5

;Memory Location $00D0 (decimal 208)

TO_1_6:             ds 1     ; TO Table, KPA row 1, RPM col 6
TO_1_7:             ds 1     ; TO Table, KPA row 1, RPM col 7
TO_2_0:             ds 1     ; TO Table, KPA row 2, RPM col 0
TO_2_1:             ds 1     ; TO Table, KPA row 2, RPM col 1
TO_2_2:             ds 1     ; TO Table, KPA row 2, RPM col 2
TO_2_3:             ds 1     ; TO Table, KPA row 2, RPM col 3
TO_2_4:             ds 1     ; TO Table, KPA row 2, RPM col 4
TO_2_5:             ds 1     ; TO Table, KPA row 2, RPM col 5
TO_2_6:             ds 1     ; TO Table, KPA row 2, RPM col 6
TO_2_7:             ds 1     ; TO Table, KPA row 2, RPM col 7
TO_3_0:             ds 1     ; TO Table, KPA row 3, RPM col 0
TO_3_1:             ds 1     ; TO Table, KPA row 3, RPM col 1
TO_3_2:             ds 1     ; TO Table, KPA row 3, RPM col 2
TO_3_3:             ds 1     ; TO Table, KPA row 3, RPM col 3
TO_3_4:             ds 1     ; TO Table, KPA row 3, RPM col 4
TO_3_5:             ds 1     ; TO Table, KPA row 3, RPM col 5

;Memory Location $00E0 (decimal 224)

TO_3_6:             ds 1     ; TO Table, KPA row 3, RPM col 6
TO_3_7:             ds 1     ; TO Table, KPA row 3, RPM col 7
TO_4_0:             ds 1     ; TO Table, KPA row 4, RPM col 0
TO_4_1:             ds 1     ; TO Table, KPA row 4, RPM col 1
TO_4_2:             ds 1     ; TO Table, KPA row 4, RPM col 2
TO_4_3:             ds 1     ; TO Table, KPA row 4, RPM col 3
TO_4_4:             ds 1     ; TO Table, KPA row 4, RPM col 4
TO_4_5:             ds 1     ; TO Table, KPA row 4, RPM col 5
TO_4_6:             ds 1     ; TO Table, KPA row 4, RPM col 6
TO_4_7:             ds 1     ; TO Table, KPA row 4, RPM col 7
TO_5_0:             ds 1     ; TO Table, KPA row 5, RPM col 0
TO_5_1:             ds 1     ; TO Table, KPA row 5, RPM col 1
TO_5_2:             ds 1     ; TO Table, KPA row 5, RPM col 2
TO_5_3:             ds 1     ; TO Table, KPA row 5, RPM col 3
TO_5_4:             ds 1     ; TO Table, KPA row 5, RPM col 4
TO_5_5:             ds 1     ; TO Table, KPA row 5, RPM col 5

;Memory Location $00F0 (decimal 240)

TO_5_6:             ds 1     ; TO Table, KPA row 5, RPM col 6
TO_5_7:             ds 1     ; TO Table, KPA row 5, RPM col 7
TO_6_0:             ds 1     ; TO Table, KPA row 6, RPM col 0
TO_6_1:             ds 1     ; TO Table, KPA row 6, RPM col 1
TO_6_2:             ds 1     ; TO Table, KPA row 6, RPM col 2
TO_6_3:             ds 1     ; TO Table, KPA row 6, RPM col 3
TO_6_4:             ds 1     ; TO Table, KPA row 6, RPM col 4
TO_6_5:             ds 1     ; TO Table, KPA row 6, RPM col 5
TO_6_6:             ds 1     ; TO Table, KPA row 6, RPM col 6
TO_6_7:             ds 1     ; TO Table, KPA row 6, RPM col 7
TO_7_0:             ds 1     ; TO Table, KPA row 7, RPM col 0
TO_7_1:             ds 1     ; TO Table, KPA row 7, RPM col 1
TO_7_2:             ds 1     ; TO Table, KPA row 7, RPM col 2
TO_7_3:             ds 1     ; TO Table, KPA row 7, RPM col 3
TO_7_4:             ds 1     ; TO Table, KPA row 7, RPM col 4
TO_7_5:             ds 1     ; TO Table, KPA row 7, RPM col 5

;Memory Location $0100 (decimal 256)

TO_7_6:             ds 1     ; TO Table, KPA row 7, RPM col 6
TO_7_7:             ds 1     ; TO Table, KPA row 7, RPM col 7

;****************************************************************************
; - Torque table RPM column, KPA row configuration constants
;****************************************************************************

RPMrangeTO_0:       ds 1     ; TO table RPM range column 0
RPMrangeTO_1:       ds 1     ; TO table RPM range column 1
RPMrangeTO_2:       ds 1     ; TO table RPM range column 2
RPMrangeTO_3:       ds 1     ; TO table RPM range column 3
RPMrangeTO_4:       ds 1     ; TO table RPM range column 4
RPMrangeTO_5:       ds 1     ; TO table RPM range column 5
RPMrangeTO_6:       ds 1     ; TO table RPM range column 6
RPMrangeTO_7:       ds 1     ; TO table RPM range column 7
KPArangeTO_0:       ds 1     ; TO table KPA range row 0
KPArangeTO_1:       ds 1     ; TO table KPA range row 1
KPArangeTO_2:       ds 1     ; TO table KPA range row 2
KPArangeTO_3:       ds 1     ; TO table KPA range row 3
KPArangeTO_4:       ds 1     ; TO table KPA range row 4
KPArangeTO_5:       ds 1     ; TO table KPA range row 5

;Memory Location $0110 (decimal 272)

KPArangeTO_6:       ds 1     ; TO table KPA range row 6
KPArangeTO_7:       ds 1     ; TO table KPA range row 7

;****************************************************************************
; - TPS range table column configuration constants
;****************************************************************************

TPSrange_0:       ds 1     ;  TPS range column 0
TPSrange_1:       ds 1     ;  TPS range column 1
TPSrange_2:       ds 1     ;  TPS range column 2
TPSrange_3:       ds 1     ;  TPS range column 3
TPSrange_4:       ds 1     ;  TPS range column 4
TPSrange_5:       ds 1     ;  TPS range column 5
TPSrange_6:       ds 1     ;  TPS range column 6
TPSrange_7:       ds 1     ;  TPS range column 7

;****************************************************************************
; - EPC_stall table column configuration constants
;****************************************************************************

EPC_stall_0:       ds 1     ;  EPC_stall column 0
EPC_stall_1:       ds 1     ;  EPC_stall column 1
EPC_stall_2:       ds 1     ;  EPC_stall column 2
EPC_stall_3:       ds 1     ;  EPC_stall column 3
EPC_stall_4:       ds 1     ;  EPC_stall column 4
EPC_stall_5:       ds 1     ;  EPC_stall column 5

;Memory Location $0120 (decimal 288)

EPC_stall_6:       ds 1     ;  EPC_stall column 6
EPC_stall_7:       ds 1     ;  EPC_stall column 7

;****************************************************************************
; - EPC_12 table column configuration constants
;****************************************************************************

EPC_12_0:       ds 1     ;  EPC_12 column 0
EPC_12_1:       ds 1     ;  EPC_12 column 1
EPC_12_2:       ds 1     ;  EPC_12 column 2
EPC_12_3:       ds 1     ;  EPC_12 column 3
EPC_12_4:       ds 1     ;  EPC_12 column 4
EPC_12_5:       ds 1     ;  EPC_12 column 5
EPC_12_6:       ds 1     ;  EPC_12 column 6
EPC_12_7:       ds 1     ;  EPC_12 column 7

;****************************************************************************
; - EPC_23 table column configuration constants
;****************************************************************************

EPC_23_0:       ds 1     ;  EPC_23 column 0
EPC_23_1:       ds 1     ;  EPC_23 column 1
EPC_23_2:       ds 1     ;  EPC_23 column 2
EPC_23_3:       ds 1     ;  EPC_23 column 3
EPC_23_4:       ds 1     ;  EPC_23 column 4
EPC_23_5:       ds 1     ;  EPC_23 column 5

;Memory Location $0130 (decimal 304)

EPC_23_6:       ds 1     ;  EPC_23 column 6
EPC_23_7:       ds 1     ;  EPC_23 column 7

;****************************************************************************
; - EPC_34 table column configuration constants
;****************************************************************************

EPC_34_0:       ds 1     ;  EPC_34 column 0
EPC_34_1:       ds 1     ;  EPC_34 column 1
EPC_34_2:       ds 1     ;  EPC_34 column 2
EPC_34_3:       ds 1     ;  EPC_34 column 3
EPC_34_4:       ds 1     ;  EPC_34 column 4
EPC_34_5:       ds 1     ;  EPC_34 column 5
EPC_34_6:       ds 1     ;  EPC_34 column 6
EPC_34_7:       ds 1     ;  EPC_34 column 7
Blank_1_0:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_1:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_2:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_3:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_4:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_5:      ds 1     ; Place holder to make up 128 byte increments

;Memory Location $0140 (decimal 320)

Blank_1_6:      ds 1     ; Place holder to make up 128 byte increments
Blank_1_7:      ds 1     ; Place holder to make up 128 byte increments


;****************************************************************************
; - Second group of 64 bytes
;****************************************************************************
;****************************************************************************
; - Misc. configuration constants
;****************************************************************************

EPC_TCC:       ds 1     ; EPC duty factor for TCC application
EPC_decel:     ds 1     ; EPC duty factor for decel conditions
EPC_rise:      ds 1     ; EPC rise time delay(20mS resolution)
EPC_hold:      ds 1     ; EPC hold time delay(20mS resolution)
SS1_del:       ds 1     ; SS1 apply time delay(20mS res)(M2-D2 shift)
CCS_del:       ds 1     ; CCS apply/release time delay(20mS res)(D4 shifts)
ExBrk_del:     ds 1     ; Exhaust Brake apply time delay(20mS res)
TCC_min_RPM:   ds 1     ; TCC apply minimum RPM permissive
MPH_stall:     ds 1     ; MPH maximum for stall EPC
TPSrate:       ds 1     ; TPS DOT rate threshold for EPC stall settings
CT_cnt:        ds 1     ; Closed throttle position ADC count
WOT_cnt:       ds 1     ; Wide Open throttle position ADC count
TPSspan:       ds 1     ; WOT_cnt - CT_cnt = TPSspan
CT_min:        ds 1     ; Closed throttle position minimum %

;Memory Location $0150 (decimal 336)

TrimFac:       ds 1     ; EPC Trim adjustment max value
TuneConfig:    ds 1     ; Tuning configuration variable
RPMkH:         ds 1     ; Hy byte constant for RPM/20 calculations
RPMkL:         ds 1     ; Lo byte constant for RPM/20 calculations
TOTempFac:     ds 1     ; Trans Oil Temp adjustment max value
TOThi:         ds 1     ; TOT correction Hi Limit (degreesF + 40)
TOTlo:         ds 1     ; TOT correction Lo Limit (degreesF + 40)
Blank_2_0:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_1:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_2:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_3:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_4:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_5:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_6:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_7:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_8:     ds 1     ; Place holder to make up 64 byte increments

;Memory Location $0160 (decimal 352)

Blank_2_9:     ds 1     ; Place holder to make up 64 byte increments
Blank_2_10:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_11:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_12:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_13:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_14:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_15:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_16:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_17:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_18:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_19:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_20:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_21:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_22:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_23:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_24:    ds 1     ; Place holder to make up 64 byte increments

;Memory Location $0170 (decimal 368)

Blank_2_25:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_26:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_27:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_28:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_29:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_30:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_31:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_32:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_33:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_34:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_35:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_36:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_37:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_38:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_39:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_40:    ds 1     ; Place holder to make up 64 byte increments

;Memory Location $0180 (decimal 384)

Blank_2_41:    ds 1     ; Place holder to make up 64 byte increments
Blank_2_42:    ds 1     ; Place holder to make up 64 byte increments

