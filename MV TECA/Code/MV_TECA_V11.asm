;****************************************************************************
;
;                          MV_TECA_V11.asm 8/20/06
;
;           Real Time Variable Display, and Configurator for MS_TECA_V11
;
;         By Robert Hiebert with technical assistance from Dan Williams
;           and all those who contributed to the Megasquirt projects
;
;****************************************************************************

;****************************************************************************
;
; This is a custom and compratively primitive version of Megaview,
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
; and displays "DuF TtA TrA DF1 DFF "
; "DuF" is  EPC Duty Factor from "TO" table, stall or shift tables, or,
;      absolute values "EPC_TCC", or "EPC_decel", and uses "df"
; "TtA" is Trans Oil Temp Corection Adder, and uses "TOTAdd"
; "TrA" is EPC Trim Correction Adder, and uses "TrimAdd"
; "DF1" is "df" after TOT cor, before Trim cor and uses "df1"
; "DFF" is "df1" after Trim cor, (Final EPC Duty Factor) and uses "dff"
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
; "SSs Delay Time  20mS", usus "SSs_Del"
; "ExBrk Del Time  20mS", uses "ExBrk_del"
; "RPM TCC Min   RPM/20", uses "TCC_min_RPM"
; "MPH Stall Max  MPH*2", uses "MPH_stall"
; "TPS DOT Min  V/S*100", uses "TPSrate"
; "TPS Cls Thrt cnt ADC", uses "CT_cnt"
; "TPS WO Thrt cnt  ADC", uses "WOT_cnt"
; "TPS span (WOT - CT) ", uses "TPSspan"
; "TPS Cls Thrt min % %", uses "CT_min"
;; "EPCPW Dither Adder  ", uses "DithAdd"
;; "Bat Volt Cor max val", uses "BatFac"
; "EPC Trim Cor max val", uses "TrimFac"
; "Tun Config Bit Field", uses "TuneConfig"
; "RPMk Hi 6=039 8=029 ", uses "rpmk", 6CYL=$27=39T, 8cyl=$1D=29T
; "RPMk Lo 6=016 8=076 ", uses "rpmk+1", 6cyl=$10=16T, 8cyl=$4C=76T
; "TOT Temp cor max val", uses "TOTempFac"
;; "Auto IAC start IACpw", uses "AIAC"
;; "Auto IAC time 100mS ", uses "AIACcmp"
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
;  PTA0      - Display Scroll Left / Decrease Selected Variable
;  PTA1      - Display Scroll Right / Increase Selected Variable
;  PTA2      - Display Freeze / Select Configuration variable
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

.header 'MV_TECA'                ; Listing file title
.pagewidth 130                   ; Listing file width
.pagelength 90                   ; Listing file height

.nolist                          ; Turn off listing file
     include "gp32.equ"          ; Include HC 908 equates
.list                            ; Turn on listing file
     org	   ram_start         ; Origin  Memory location $0040=64
                                 ;(start of RAM)
     include "MV_TECA_V11.inc"    ; Include definitions for MV_TECA_V11.asm

;****************************************************************************
;
; ----------------- Configure system and set up clock ----------------------
;
;****************************************************************************

     org     rom_start              ; Origin at memory location
                                    ; ($8000 = 32,768)(start of ROM)

START:

;****************************************************************************
; - Set Configuration Register 1
;****************************************************************************

     mov     #$3B,CONFIG1     ; Move %00111011 into Configuration Register 1
                              ;(COP timeout period=2p18-2p4 CGMXCLK cycles)
                              ;(LVI disabled during stop mode)
                              ;(LVI module resets disabled)
                              ;(LVI module power disabled)
                              ;(LVI operates in 5-V mode)
                              ;(Stop mode recovery after 4096 CGMXCLKC cycls)
                              ;(Stop instruction enabled)
                              ;(COP module disabled)

;****************************************************************************
; - Set Configuration Register 2
;****************************************************************************

     mov     #$01,CONFIG2     ; Move %00000001 into Configuration Register 2
                              ;(Oscillator disabled during stop mode)
                              ;(Internal data bus clock used as clock source
                              ; for SCI)

;****************************************************************************
; - Set The Stack Pointer to the bottom of RAM
;****************************************************************************

     ldhx     #ram_last+1           ; Load index register with value in
                                    ; "ram_last" +1 ($023F+1=$0240=576)
     txs                            ; Transfer value in index register Lo
                                    ; byte to stack

;****************************************************************************
; - Initialize the PLL Control Register for a bus frequency of 8.003584mhz
;****************************************************************************

     mov     #$02,PCTL      ; Move %00000010 into PLL Control Register
                            ;(PLL Interrupts Disabled)
                            ;(No change in lock condition(flag))
                            ;(PLL off)
                            ;(CGMXCLK divided by 2 drives CGMOUT)
                            ;(VCO pwr of 2 mult = 1(E=0))
                            ;(Prescale mult = 4(P=2))
     mov     #$03,PMSH      ; Move %00000011 into PLL Multiplier Select
                            ; Register Hi (Set N MSB)
     mov     #$D1,PMSL      ; Move %11010001 into PLL Multiplier Select
                            ; Register Lo (Set N LSB)($84 for 7.37 MHz)
     mov     #$D0,PMRS      ; Move %11010000 into PLL VCO Range Select
                            ; Register (Set L) ($C0 for 7.37 MHz)
     mov     #$01,PMDS      ; Move %00000001 into Reference Divider Select
                            ; Register (Set "RDS0" bit (default value of 1)
     bset    AUTO,PBWC      ; Set "Auto" bit of PLL Bandwidth Control Register
     mov     #$32,PCTL      ; Move %00100000 into PLL Control Register
                            ;(PLL On)

PLL_WAIT:
     brclr   LOCK,PBWC,PLL_WAIT     ; If "Lock" bit of PLL Bandwidth Control
                                    ; Register is clear, branch to PLL_WAIT:
     bset    BCS,PCTL               ; Set "BCS" bit of PLL Control Register
                                    ;(CGMXCLK divided by 2 drives CGMOUT)
                                    ;(Select VCO as base clock)


;****************************************************************************
;
; ----------------------------- Set up RS 232 ------------------------------
;
;****************************************************************************

;****************************************************************************
; - Enable/disable loop mode
;****************************************************************************

     mov     #$40,SCC1     ; Move %01000000 into SCI Control Register 1
                           ;(Normal operation enabled)
                           ;(Set "ENSCI" bit)(SCI enabled)
                           ;(Transmitter output not inverted)
                           ;(8 bit SCI characters)
                           ;(Idle line wakeup)
                           ;(Idle character bit countbegins after start bit)
                           ;(Parity function disabled)
                           ;(Even Parity)
     bset    PTY,SCC1      ; Set "PTY" bit of SCI Control Register 1
                           ;(Odd Parity)???

;****************************************************************************
; - This register initialize interrupts request and activates the
;   transmitter and receiver and wakeup mode
;****************************************************************************

     mov     #$0C,SCC2     ; Move %00001100 into SCI Control Register 2
                           ;(SCTIE not enabled to generate CPU interrupt)
                           ;(TCIE not enabled to generate CPU interrupt)
                           ;(SCRIE not enabled to generate CPU interrupt)
                           ;(ILIE not enabled to generate CPU interrupt)
                           ;(Set "TE" bit)(Transmitter enabled)
                           ;(Set "RE" bit)(Receiver enabled)
                           ;(Normal Operation)
                           ;(No break characters being transmitted)

;****************************************************************************
; - This register initialize the DMA services and error interrupts
;****************************************************************************

     clr     SCC3          ; Clear SCI Control Register 3
                           ;(DMA not enabled to service SCI receiver)
                           ;(SCTE DMA service requests disabled)
                           ;(SCI error CPU interrupt requests for OR bit
                           ; disabled)
                           ;(SCI error CPU interrupt requests for NE bit
                           ; disabled)
                           ;(SCI error CPU interrupt requests for FE bit
                           ; disabled)
                           ;(SCI error CPU interrupt requests for PE bit
                           ; disabled)

;****************************************************************************
; - This register sets baud rate
;****************************************************************************

     lda      #$30           ; Load accumulator with %00110000
     sta      SCBR           ; Copy to SCI Baud Rate Register
                             ; 8003584mhz/(64*13*1)=9619.7 baud

;****************************************************************************
; ------------- Set up the port data-direction registers --------------------
;               Set directions,
;               Preset state of pins to become outputs
;               Set all unused pins to outputs initialized Lo
;****************************************************************************

;****************************************************************************
; - Set up VFD control line I/Os
;****************************************************************************

; Port B
     clr     PORTB           ; Clear Port B Data Register
                             ;(Preinit all pins low)
     lda     #$FF            ; Load accumulator with %11111111
                             ;(port direction setup 1 = output)
     sta     DDRB            ; Copy to Port A Data Direction Register
                             ; Set all as outputs
                             ; NA,RS,R/W,En,NA,NA,NA,NA

; Port C
     clr     PORTC           ; Clear Port C Data Register
                             ;(Preinit all pins low)
     lda     #$FF            ; Load accumulator with %11111111
                             ; (set up port directions, 1 = out)
     sta     DDRC            ; Copy to Port C Data Direction Register
                             ; Set all as outputs
                             ; NA,NA,NA,NA,DB7,DB6,DB5,DB4

;****************************************************************************
; - Set up for push button inputs
;****************************************************************************

; Port A
     mov     #$FF,PTAPUE     ; Move %11111111 into Port A pullup register
                             ;(Set all pullups)
     clr     PORTA           ; Clear Port A Data Regisister
                             ;(preinit all pins Lo)
     lda     #$F0            ; Load accumulator with %11110000
                             ;(port direction setup 1 = output)
     sta     DDRA            ; Copy to Port A Data Direction Register
                             ; Inputs on PTA3,2,1,0
                             ; Tog Mode,Frz/Sel,Scrl Rt/Inc.Scrl Lft/Dec
                             ; Outputs on PTA7,6,5,4 (not used)

;****************************************************************************
; - Set up Ports D and E.(The Motorola manual states that it is not
;   necessarry to set up Port E when SCI is enabled, but we'll do it anyway).
;****************************************************************************

; Port D
     clr     PORTD           ; Clear Port D Data Register
                             ;(Preinit all pins low)
     lda     #$FF            ; Load accumulator with %11111111
                             ; (init port directions 1 = out)
     sta     DDRD            ; Copy to Port D Data Direction Register
                             ; Set all as outputs
                             ; NA,NA,NA,NA,NA,NA,NA,NA

; Port E
     clr     PORTE           ; Clear Port E Data Register (to avoid glitches)
     lda     #$01            ; Load accumulator with %00000001
                             ; (set up port directions, 1 = out)
                             ; (Serial Comm Port)
     sta     DDRE            ; Copy to Port E Data Direction Register


;***************************************************************************
; - Initialize the variables
;***************************************************************************

     clra                    ; Clear accumulator
     clrh                    ; Clear index register Hi byte
     clrx                    ; Clear index register Lo byte
     clr     Sw0DB           ; Switch #0 de-bounce timer counter variable
     clr     Sw0ARC          ; Switch #0 auto-repeat command timer counter
     clr     Sw0AR           ; Switch #0 auto-repeat timer counter variable
     clr     Sw1DB           ; Switch #1 de-bounce timer counter variable
     clr     Sw1ARC          ; Switch #1 auto-repeat command timer counter
     clr     Sw1AR           ; Switch #1 auto-repeat timer counter variable
     clr     Sw2DB           ; Switch #2 de-bounce timer counter variable
     clr     Sw2ARC          ; Switch #2 auto-repeat command timer counter
     clr     Sw2AR           ; Switch #2 auto-repeat timer counter variable
     clr     Sw3DB           ; Switch #3 de-bounce timer counter variable
     clr     Sw3ARC          ; Switch #3 auto-repeat command timer counter
     clr     Sw3AR           ; Switch #3 auto-repeat timer counter variable
     clr     LPflags         ; Switch last pass status bit field variable
     clr     ARCflags        ; Switch auto-repeat command status bit field
     clr     ARflags         ; Switch auto-repeat status bit field variable
     clr     Swflags         ; Switch status bit field variable
     clr     ModeCntr        ; Counter for determining "mode" bit status
     clr     FrzCntr         ; Counter for determining "frz" bit status
     clr     SelCntr         ; Counter for determining "sel" bit status
     clr     flags           ; Bit field for operating status flags (1 of 2)
     clr     ScrnCnt         ; Counter for display screen numbers
     clr     ScrnCnt_prv     ; Screen count number previous
     clr     ScrnCnt_Lst     ; Screen count number last
     clr     ConCnt          ; Counter for Constant numbers
     clr     ConCnt_prv      ; Constant number previous
     clr     ConCnt_Lst      ; Constant number last
     clr     CurCon          ; Value of current selected constant
     clr     ConVal          ; Value for constant data
     clr     mS              ; Milliseconds counter
     clr     mSx5            ; 5 Milliseconds counter
     clr     ByteCnt         ; Count of bytes to receive via SCI
     clr     ByteGoal        ; Desired number of bytes to receive via SCI
     clr     readbuf         ; Buffer for temporary storage of received byte
     clr     value           ; Value sent to VFD(instruction or data)
     clr     LineNum         ; Line number for VFD(for instruction)
     clr     ColNum          ; Column number for VFD(for instruction)
     clr     DatVal          ; Data value for VFD
     clr     ComVal          ; Value for VFD command data
     clr     TopVal          ; Value for VFD top line data
     clr     DisVal          ; Value for VFD bottom line variable data
     clr     BotLin0         ; Bottom Line Column 0
     clr     BotLin1         ; Bottom Line Column 1
     clr     BotLin2         ; Bottom Line Column 2
     clr     BotLin3         ; Bottom Line Column 3
     clr     BotLin4         ; Bottom Line Column 4
     clr     BotLin5         ; Bottom Line Column 5
     clr     BotLin6         ; Bottom Line Column 6
     clr     BotLin7         ; Bottom Line Column 7
     clr     BotLin8         ; Bottom Line Column 8
     clr     BotLin9         ; Bottom Line Column 9
     clr     BotLin10        ; Bottom Line Column 10
     clr     BotLin11        ; Bottom Line Column 11
     clr     BotLin12        ; Bottom Line Column 12
     clr     BotLin13        ; Bottom Line Column 13
     clr     BotLin14        ; Bottom Line Column 14
     clr     BotLin15        ; Bottom Line Column 15
     clr     BotLin16        ; Bottom Line Column 16
     clr     BotLin17        ; Bottom Line Column 17
     clr     BotLin18        ; Bottom Line Column 18
     clr     BotLin19        ; Bottom Line Column 19
     clr     BotLin0L        ; Bottom Line Column 0, last pass
     clr     BotLin1L        ; Bottom Line Column 1, last pass
     clr     BotLin2L        ; Bottom Line Column 2, last pass
     clr     BotLin3L        ; Bottom Line Column 3, last pass
     clr     BotLin4L        ; Bottom Line Column 4, last pass
     clr     BotLin5L        ; Bottom Line Column 5, last pass
     clr     BotLin6L        ; Bottom Line Column 6, last pass
     clr     BotLin7L        ; Bottom Line Column 7, last pass
     clr     BotLin8L        ; Bottom Line Column 8, last pass
     clr     BotLin9L        ; Bottom Line Column 9, last pass
     clr     BotLin10L       ; Bottom Line Column 10, last pass
     clr     BotLin11L       ; Bottom Line Column 11, last pass
     clr     BotLin12L       ; Bottom Line Column 12, last pass
     clr     BotLin13L       ; Bottom Line Column 13, last pass
     clr     BotLin14L       ; Bottom Line Column 14, last pass
     clr     BotLin15L       ; Bottom Line Column 15, last pass
     clr     BotLin16L       ; Bottom Line Column 16, last pass
     clr     BotLin17L       ; Bottom Line Column 17, last pass
     clr     BotLin18L       ; Bottom Line Column 18, last pass
     clr     BotLin19L       ; Bottom Line Column 19, last pass
     clr     AC_100          ; 8 bit ASCII conversion 100s column
     clr     AC_10           ; 8 bit ASCII conversion 10s column
     clr     AC_1            ; 8 bit ASCII conversion 1s column

     mov     #$FF,ScrnCnt_Lst     ; Move decimal 255 into "ScrnCnt_Lst"
     mov     #$FF,ConCnt_Lst      ; Move decimal 255 into "ConCnt_Lst"

;***************************************************************************
; - Delay while power stabilizes, allow MS and VFD to come up.
;   One pass through the primary loop takes ~1.5uS, so this delay is ~300mS
;   (minimum delay is 260mS)
;***************************************************************************

     jsr     DELAY300     ; Jump to subroutine at DELAY300:

;****************************************************************************
; Set up TIM2 as a free running ~1us counter. Set Channel 0 output compare
; to generate the ~1000us(1.0mS) clock tick interupt vector "TIM2CH0_ISR:"
;****************************************************************************

     mov     #$33,T2SC       ; Move %00110011 into Timer2
                             ; Status and Control Register
                             ;(Disable interrupts, stop timer)
                             ;(Prescale and counter cleared))
                             ;(Prescale for bus frequency / 8)
     mov     #$FF,T2MODH     ; Move decimal 255 into T2 modulo reg Hi
     mov     #$FF,T2MODL     ; Move decimal 255 into T2 modulo reg Lo
                             ;(free running timer)
     mov     #$03,T2CH0H     ; Move decimal 3 into T1CH0 O/C register Hi
     mov     #$E8,T2CH0L     ; Move decimal 232 into T1CH0 O/C register Lo
                             ;(~1000uS)=(~1.0mS)
     mov     #$54,T2SC0      ; Move %01010100 into Timer2
                             ; channel 0 status and control register
                             ; (Output compare, interrupt enabled)
     mov     #$03,T2SC       ; Move %00000011 into Timer2
                             ; Status and Control Register
                             ; Disable interrupts, counter Active
                             ; Prescale for bus frequency / 8
                             ; 8,003584hz/8=1000448hz
                             ; = .0000009995sec

;****************************************************************************
; - Enable Interrupts
;****************************************************************************

     cli              ; Clear interrupt mask ( Turn on all interrupts now )

;***************************************************************************
; ------------------------------ Initialize VFD ---------------------------
;
;  PTB4       - VFD Display Enable
;  PTB5       - VFD Display R/W
;  PTB6       - VFD Display RS
;  PTC0       - VFD Display data DB4
;  PTC1       - VFD Display data DB5
;  PTC2       - VFD Display data DB6
;  PTC3       - VFD Display data DB7
;
;***************************************************************************

;***************************************************************************
; - Clear EN, R/W, and RS
;***************************************************************************

     mov     #$00,PORTB     ; Move 0 into PortB(Clear all Port B)
                            ;("En"=0,"R/W"=0,"RS"=0)

;***************************************************************************
; - Initialize for 8 bit mode (Function Set)(do this 3 times)
;***************************************************************************

     mov     #$03,PORTC       ; Move %00000011 into PortC
                              ;(Set bit 0=DB4, and bit1=DB5)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

     mov     #$03,PORTC       ; Move %00000011 into PortC
                              ;(Set bit 0=DB4, and bit1=DB5)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

     mov     #$03,PORTC       ; Move %00000011 into PortC
                              ;(Set bit 0=DB4, and bit1=DB5)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Set 4 bit bus mode Hi nibble (Function Set)
;***************************************************************************

     mov     #$02,PORTC       ; Move %00000010 into PortC
                              ;(Set bit1=DB5)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Set 4 bit bus mode Hi nibble (Function Set)
;***************************************************************************

     mov     #$02,PORTC       ; Move %00000010 into PortC
                              ;(Set bit1=DB5)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)


;***************************************************************************
; - Set 4 bit bus mode Lo nibble (Function Set)
;***************************************************************************

     mov     #$08,PORTC       ; Move %00001000 into PortC(Set bit7=DB3)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Set brightness to 100% Hi nibble (Brightness Set)
;***************************************************************************

     bset    Reg_Sel,PORTB    ; Set "Reg_Sel" bit of PortB(RS=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set brightness to 100% Lo nibble (Brightness Set)
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Reg_Sel,PORTB    ; Clear "Reg_Sel" bit of PortB(RS=0)

;***************************************************************************
; - Set display off, cursor off, blinking off Hi nibble
;   (Display On/Off control)
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set display off, cursor off, blinking off Lo nibble
;   (Display On/Off control)
;***************************************************************************

     mov     #$08,PORTC       ; Move %00001000 into PortC(Set bit7=DB3)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Set display clear Hi nibble(Display Clear)
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set display clear Lo nibble(Display Clear)
;***************************************************************************

     mov     #$01,PORTC       ; Move %00000001 into PortC (Set bit0=DB0))
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Delay for command to execute (min 2.3mS)
;   One pass through the primary loop takes ~1.5uS, bus frequency of ~8mHZ
;***************************************************************************

     clr     tmp2       ; Clear tmp2 variable

WAIT_6:
     clr     tmp1       ; Clear tmp1 variable

WAIT_5:
     lda     tmp1       ; Load accumulator with value in tmp1 variable
     inca               ; Increment value in accumulator
     sta     tmp1       ; Copy to tmp1 variable
     cmp     #$FF       ; Compare value in accumulator with decimal 255
     blo     WAIT_5     ; If C bit of CCR is set, (A<M), branch to WAIT_5:
     lda     tmp2       ; Load accumulator with value in tmp2 variable
     inca               ; Increment value in accumulator
     sta     tmp2       ; Copy to tmp2 variable
     cmp     #$07       ; Compare value in accumulator with decimal 7
     blo     WAIT_6     ; If C bit of CCR is set, (A<M), branch to WAIT_6:
                        ;(~2.6mS delay)

;***************************************************************************
; - Set display on, cursor off, blinking off Hi nibble
;   (Display On/Off control)
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set display on, cursor off, blinking off Lo nibble
;   (Display On/Off control)
;***************************************************************************

     mov     #$0C,PORTC       ; Move %00001100 into PortC
                              ;(Set bit7=DB3 and bit6=DB2)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Set cursor increment Hi nibble(Entry Mode Set)
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC (Clear all Port C)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set cursor increment Lo nibble(Entry Mode Set)
;***************************************************************************

     mov     #$06,PORTC       ; Move %00000110 into PortC
                              ;(Set bit6=DB2 and bit5=DB1)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Upload the Constants group 1 from MS_TECA RAM to MV_TECA RAM.
;***************************************************************************

     bset    mde,flags          ; Set "mde" bit of "flags" variable
                                ;("Configuration" mode)
     bset    RcvG1,flags        ; Set "RcvG1" bit of "flags" variable
     lda     SCS1               ; Load accumulator with value in SCI
                                ; Control Register 1
                                ;(Clear transmitter empty bit)
                                ;(Clears all by read)
     mov     #'V',SCDR          ; Move ASCII'V' to SCI Data Register
                                ;(Transmitter is running, so data
                                ; shift starts now!)
     clr     ByteCnt            ; Clear "ByteCnt" variable
;     mov     #$80,ByteGoal      ; Move decimal 128 into "ByteGoal" var
                                ;(number of configuration constants)
     mov     #$81,ByteGoal
     bset    SCRIE,SCC2         ; Set "SCRIE" bit of SCI Control Register 2
                                ;(SCRF enabled to generate CPU Interrupt)
     jsr     DELAY300           ; Jump to subroutine at DELAY300:
                                ;(Wait for data transfer to complete)
     bclr    RcvG1,flags        ; Clear "RcvG1" bit of "flags" variable


;***************************************************************************
; - Upload the Constants group 2 from MS_TECA RAM to MV_TECA RAM.
;***************************************************************************

     bset    RcvG2,flags        ; Set "RcvG2" bit of "flags" variable
     lda     SCS1               ; Load accumulator with value in SCI
                                ; Control Register 1
                                ;(Clear transmitter empty bit)
                                ;(Clears all by read)
     mov     #'I',SCDR          ; Move ASCII'I' to SCI Data Register
                                ;(Transmitter is running, so data
                                ; shift starts now!)
     clr     ByteCnt            ; Clear "ByteCnt" variable
;     mov     #$80,ByteGoal      ; Move decimal 128 into "ByteGoal" var
                                ;(number of configuration constants)
     mov     #$81,ByteGoal
     bset    SCRIE,SCC2         ; Set "SCRIE" bit of SCI Control Register 2
                                ;(SCRF enabled to generate CPU Interrupt)
     jsr     DELAY300           ; Jump to subroutine at DELAY300:
                                ;(Wait for data transfer to complete)
     bclr    RcvG2,flags        ; Clear "RcvG2" bit of "flags" variable
     bclr    mde,flags          ; Clear "mde" bit of "flags" variable
                                ;("Display" mode)


;****************************************************************************
;****************************************************************************
;*                        M A I N  E V E N T  L O O P                       *
;****************************************************************************
;****************************************************************************

LOOPY:
     jsr     SW0_CHK     ; Jump to subroutine at SW0_CHK:
                         ;(Check he state of the Display Scroll Left /
                         ; Decrease Selected Variable button on PTA0)
     jsr     SW1_CHK     ; Jump to subroutine at SW1_CHK:
                         ;(Check he state of the Display Scroll Right /
                         ; Increase Selected Variable button on PTA1)
     jsr     SW2_CHK     ; Jump to subroutine at SW2_CHK:
                         ;(Check he state of the Display Freeze / Select
                         ; Configuration variable button on PTA2)

;****************************************************************************
; - Check to see what mode we are in and branch accordingly.
;****************************************************************************

     brset   mde,flags,CONFIG_CHK_JMP   ; If "mde" bit of "flags variable is
                                        ; set, branch to CONFIG_CHK_JMP:
                                        ;("mde" = 1 = configuration mode)
     bra     DSPLY_CHK                  ; Branch to DSPLY_CHK:
                                        ;("mde" = 0 = display mode)

CONFIG_CHK_JMP:
     jmp     CONFIG_CHK                 ; Jump to CONFIG_CHK:(long branch)


;****************************************************************************
;****************************************************************************
;*                             DISPLAY SECTION                              *
;****************************************************************************
;****************************************************************************

DSPLY_CHK:

;****************************************************************************
; - First, check to see which screen we are in, if we are in any of the SCI
;   screens(8,9,10,11 or 12), branch to the appropriate section. Otherwise,
;   check to see if any of the input buttons are flagged, and if so,
;   branch accordingly.
;***************************************************************************

     lda     ScrnCnt                  ; Load accumulator with value in
                                      ; "ScrnCnt" variable
     cbeqa   #$08,GET_G1_SC_JMP       ; Compare value in accumulator with
                                      ; decimal 8, branch to
                                      ; GET_G1_SC_JMP: if equal
     cbeqa   #$09,GET_G2_SC_JMP       ; Compare value in accumulator with
                                      ; decimal 9, branch to
                                      ; GET_G2_SC_JMP: if equal
     cbeqa   #$0A,SND_G1_SC_JMP       ; Compare value in accumulator with
                                      ; decimal 10, branch to
                                      ; SND_G1_SC_JMP: if equal
     cbeqa   #$0B,SND_G2_SC_JMP       ; Compare value in accumulator with
                                      ; decimal 11, branch to
                                      ; SND_G2_SC_JMP: if equal
     cbeqa   #$0C,BN_CON_SC_JMP       ; Compare value in accumulator with
                                      ; decimal 12, branch to
                                      ; BN_CON_SC_JMP: if equal
     jmp     COMP_W_6                 ; Jump to COMP_W_6:


GET_G1_SC_JMP:
     jmp     GET_G1_SC     ; Jump to GET_G1_SC:(long branch)

GET_G2_SC_JMP:
     jmp     GET_G2_SC     ; Jump to GET_G2_SC:(long branch)

SND_G1_SC_JMP:
     jmp     SND_G1_SC     ; Jump to SND_G1_SC:(long branch)

SND_G2_SC_JMP:
     jmp     SND_G2_SC     ; Jump to SND_G2_SC:(long branch)

BN_CON_SC_JMP:
     jmp     BN_CON_SC     ; Jump to BN_CON_SC:(long branch)


GET_G1_SC:

;****************************************************************************
; - We are in Display mode. The desired screen count number is decimal 8
;   (Upload Cons Grp1 Scrn). Using the screen count number, determine the
;   appropriate array for the top line of the display and print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP8         ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP8:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP8:

;***************************************************************************
; - Check to see if "Upload Cons Grp1" has been commanded, if so, carry out
;   the command, otherwise continue with the "Display" section.
;***************************************************************************

     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,DO_GET_G1  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; DO_GET_G1
                                       ;(Toggle Mode button is pressed)
     jmp     COMP_W_6                  ; Branch to COMP_W_6:
                                       ;(Button not pressed, continue
                                       ; in "Display" mode)

DO_GET_G1:
     bset    mde,flags          ; Set "mde" bit of "flags" variable
     bset    RcvG1,flags        ; Set "RcvG1" bit of "flags" variable
     lda     SCS1               ; Load accumulator with value in SCI
                                ; Control Register 1
                                ;(Clear transmitter empty bit)
                                ;(Clears all by read)
     mov     #'V',SCDR          ; Move ASCII'V' to SCI Data Register
                                ;(Transmitter is running, so data
                                ; shift starts now!)
     clr     ByteCnt            ; Clear "ByteCnt" variable
;     mov     #$80,ByteGoal      ; Move decimal 128 into "ByteGoal" var
                                ;(number of configuration constants)
     mov     #$81,ByteGoal


;**************************************************************************
; - Enable receiver full interrupt.
;**************************************************************************

     bset    SCRIE,SCC2     ; Set "SCRIE" bit of SCI Control Register 2
                            ;(SCRF enabled to generate CPU Interrupt)

;***************************************************************************
; -  "Upload Cons Grp1" has been been commanded, and the command byte has
;    been sent. Print the next instruction on the top line of the VFD,
;    and wait for the second button press.
;***************************************************************************

     mov     #$0D,ScrnCnt     ; Move Decimal 13 into "ScrnCnt" variable
                              ;(Upload G1 Done screen)
     jsr     PRNT_TOPLN_DSP   ; Jump to subroutine at PRNT_TOPLN_DSP:
     jsr     BUTTON_WAIT      ; Jump to subroutine at BUTTON_WAIT:
     clr     ScrnCnt          ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv      ; Clear "ScrnCnt_prv" variable
     mov     #$12,ScrnCnt_Lst ; Move decimal 18 into "ScrnCnt_Lst"
     bclr    mde,flags        ; Clear "mde" bit of "flags" variable
     bclr    RcvG1,flags      ; Clear "RcvG1" bit of "flags" variable
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable
     jmp     LOOPY            ; Jump to LOOPY
                              ;(End of program loop in
                              ; "Upload Cons Grp1 Screen")


GET_G2_SC:

;****************************************************************************
; - We are in Display mode. The desired screen count number is decimal 9
;   (Upload Cons Grp2 Scrn). Using the screen count number, determine the
;   appropriate array for the top line of the display and print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP9         ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP9:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP9:

;***************************************************************************
; - Check to see if "Upload Cons Grp2" has been commanded, if so, carry out
;   the command, otherwise continue with the "Display" section.
;***************************************************************************

     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,DO_GET_G2  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; DO_GET_G2
                                       ;(Toggle Mode button is pressed)
     jmp     COMP_W_6                  ; Branch to COMP_W_6:
                                       ;(Button not pressed, continue
                                       ; in "Display" mode)

DO_GET_G2:
     bset    mde,flags          ; Set "mde" bit of "flags" variable
     bset    RcvG2,flags        ; Set "RcvG2" bit of "flags" variable
     lda     SCS1               ; Load accumulator with value in SCI
                                ; Control Register 1
                                ;(Clear transmitter empty bit)
                                ;(Clears all by read)
     mov     #'I',SCDR          ; Move ASCII'I' to SCI Data Register
                                ;(Transmitter is running, so data
                                ; shift starts now!)
     clr     ByteCnt            ; Clear "ByteCnt" variable
;     mov     #$80,ByteGoal      ; Move decimal 128 into "ByteGoal" var
                                ;(number of configuration constants)
     mov     #$81,ByteGoal


;***************************************************************************
; -  "Upload Cons Grp2" has been been commanded, and the command byte has
;    been sent. Print the next instruction on the top line of the VFD,
;    and wait for the second button press.
;***************************************************************************

     mov     #$0E,ScrnCnt     ; Move Decimal 14 into "ScrnCnt" variable
                              ;(Upload Cons Grp1 Done screen)
     jsr     PRNT_TOPLN_DSP   ; Jump to subroutine at PRNT_TOPLN_DSP:
     jsr     BUTTON_WAIT      ; Jump to subroutine at BUTTON_WAIT:
     clr     ScrnCnt          ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv      ; Clear "ScrnCnt_prv" variable
     mov     #$12,ScrnCnt_Lst ; Move decimal 18 into "ScrnCnt_Lst"
     bclr    mde,flags        ; Clear "mde" bit of "flags" variable
     bclr    RcvG2,flags      ; Clear "RcvG2" bit of "flags" variable
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable
     jmp     LOOPY            ; Jump to LOOPY
                              ;(End of program loop in
                              ; "Upload ST Group Screen")


SND_G1_SC:

;****************************************************************************
; - We are in Display mode. The desired screen count number is decimal 10
;   (Download G1 value Scrn). Using the screen count number, determine the
;   appropriate array for the top line of the display and print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP10        ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP10:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP10:

;***************************************************************************
; - Check to see if "Download G1 value" has been commanded, if so, carry out
;   the command, otherwise continue with the "Display" section.
;***************************************************************************

     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,DO_SND_V1  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; DO_SND_V1
                                       ;(Toggle Mode button is pressed)
     jmp     COMP_W_6                  ; Branch to COMP_W_6:
                                       ;(Button not pressed, continue
                                       ; in "Display" mode)

DO_SND_V1:
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
                             ;(Clears all by read)
     mov     #'W',SCDR       ; Move ASCII'W' to SCI Data Register
                             ;(Transmitter is running, so data shift
                             ; starts now!)
     jsr     DELAY300        ; Jump to subroutine at DELAY300:(This delay
                             ; time was found to be necessary and was
                             ; determined by experimentation)
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
     mov     CurCon,SCDR     ; Move value in "CurCon" to SCI Data Register
                             ;(Current constant offset)
     jsr     DELAY300        ; Jump to subroutine at DELAY300:
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
     mov     ConVal,SCDR     ; Move value in "ConVal" to SCI Data Register
                             ;(Current constant value)


;***************************************************************************
; -  "Download G1 value" has been been commanded, and the command bytes
;    have been sent. Print the next instruction on the top line of the VFD,
;    and wait for the second button press.
;***************************************************************************

     mov     #$0F,ScrnCnt     ; Move Decimal 15 into "ScrnCnt" variable
                              ;(Download V1 Done screen)
     jsr     PRNT_TOPLN_DSP   ; Jump to subroutine at PRNT_TOPLN_DSP:
     jsr     BUTTON_WAIT      ; Jump to subroutine at BUTTON_WAIT:
     clr     ScrnCnt          ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv      ; Clear "ScrnCnt_prv" variable
     mov     #$12,ScrnCnt_Lst ; Move decimal 18 into "ScrnCnt_Lst"
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable
     jmp     LOOPY            ; Jump to LOOPY
                              ;(End of program loop in
                              ; "Download G1 value Screen")

SND_G2_SC:

;****************************************************************************
; - We are in Display mode. The desired screen count number is decimal 11
;   (Download G2 value Scrn). Using the screen count number, determine the
;   appropriate array for the top line of the display and print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP11        ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP11:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP11:

;***************************************************************************
; - Check to see if "Download G2 value" has been commanded, if so, carry out
;   the command, otherwise continue with the "Display" section.
;***************************************************************************
     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,DO_SND_V2  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; DO_SND_V2
                                       ;(Toggle Mode button is pressed)
     jmp     COMP_W_6                  ; Branch to COMP_W_6:
                                       ;(Button not pressed, continue
                                       ; in "Display" mode)

DO_SND_V2:
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
                             ;(Clears all by read)
     mov     #'J',SCDR       ; Move ASCII'J' to SCI Data Register
                             ;(Transmitter is running, so data shift
                             ; starts now!)
     jsr     DELAY300        ; Jump to subroutine at DELAY300:(This delay
                             ; time was found to be necessary and was
                             ; determined by experimentation)
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
     mov     CurCon,SCDR     ; Move value in "CurCon" to SCI Data Register
                             ;(Current constant offset)
     jsr     DELAY300        ; Jump to subroutine at DELAY300:
     lda     SCS1            ; Load accumulator with value in SCI Control
                             ; Register 1(Clear transmitter empty bit)
     mov     ConVal,SCDR     ; Move value in "ConVal" to SCI Data Register
                             ;(Current constant value)

;***************************************************************************
; -  "Download G2 value" has been been commanded, and the command bytes
;    have been sent. Print the next instruction on the top line of the VFD,
;    and wait for the second button press.
;***************************************************************************

     mov     #$10,ScrnCnt     ; Move Decimal 16 into "ScrnCnt" variable
                              ;(Download V2 Done screen)
     jsr     PRNT_TOPLN_DSP   ; Jump to subroutine at PRNT_TOPLN_DSP:
     jsr     BUTTON_WAIT      ; Jump to subroutine at BUTTON_WAIT:
     clr     ScrnCnt          ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv      ; Clear "ScrnCnt_prv" variable
     mov     #$12,ScrnCnt_Lst ; Move decimal 18 into "ScrnCnt_Lst"
     bclr    mde,flags        ; Clear "mde" bit of "flags" variable
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable
     jmp     LOOPY            ; Jump to LOOPY
                              ;(End of program loop in
                              ; "Download G2 value Screen")

BN_CON_SC:

;****************************************************************************
; - We are in Display mode. The desired screen count number is decimal 12
;   (Burn Constants Scrn). Using the screen count number, determine the
;   appropriate array for the top line of the display and print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************


     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP12        ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP12:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP12:

;***************************************************************************
; - Check to see if "Burn Constants" has been commanded, if so, carry out
;   the command, otherwise continue with the "Display" section.
;***************************************************************************

     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,DO_BN_CNS  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; DO_BN_CNS:
                                       ;(Toggle Mode button is pressed)
     jmp     COMP_W_6                  ; Branch to COMP_W_6:
                                       ;(Button not pressed, continue
                                       ; in "Display" mode)

DO_BN_CNS:
     lda     SCS1               ; Load accumulator with value in SCI
                                ; Control Register 1
                                ;(Clear transmitter empty bit)
                                ;(Clears all by read)
     mov     #'B',SCDR          ; Move ASCII'B' to SCI Data Register
                                ;(Transmitter is running, so data
                                ; shift starts now!)

;***************************************************************************
; -  "Burn Constants" has been been commanded, and the command byte has
;    been sent. Print the next instruction on the top line of the VFD,
;    and wait for the second button press.
;***************************************************************************

     mov     #$11,ScrnCnt     ; Move Decimal 17 into "ScrnCnt" variable
                              ;(Burn Constants Done screen)
     jsr     PRNT_TOPLN_DSP   ; Jump to subroutine at PRNT_TOPLN_DSP:
     jsr     BUTTON_WAIT      ; Jump to subroutine at BUTTON_WAIT:
     clr     ScrnCnt          ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv      ; Clear "ScrnCnt_prv" variable
     mov     #$12,ScrnCnt_Lst ; Move decimal 18 into "ScrnCnt_Lst"
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable
     jmp     LOOPY            ; Jump to LOOPY
                              ;(End of program loop in
                              ; "Burn Constants Screen")


;***************************************************************************
; -  If we are in any of the real time variable display screens, ignore the
;    "Toggle Mode" button.
;***************************************************************************

COMP_W_6:
     cmp     #$06                      ; Compare with decimal 6
     blo     NO_CONFIG                 ; If (A)<(M), branch to NO_CONFIG:
                                       ;(No configuration screen has been
                                       ; selected so ignore mode button)
     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)
     brset   Sw3cls,Swflags,TOG_MODE1  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; TOG_MODE1:
                                       ;(Toggle Mode button is pressed)

NO_CONFIG:
     brset   Sw2cls,Swflags,TOG_FRZ     ; If "Sw2cls" bit of "Swflags"
                                        ; variable is set, branch to
                                        ; TOG_FRZ
                                        ;(Freeze/Select button is pressed)
     brset   Sw1cls,Swflags,SCRL_D_RT   ; If "Sw1cls" bit of "Swflags"
                                        ; variable is set, branch to
                                        ; SCRL_D_RT
                                        ;(Scroll Right/Increment button is
                                        ; pressed)
     brset   Sw0cls,Swflags,SCRL_D_LFT  ; If "Sw0cls" bit of "Swflags"
                                        ; variable is set, branch to
                                        ; SCRL_D_LFT
                                        ;(Scroll Left/Decrement button is
                                        ; pressed)
     jmp     DSPLY_MODE                 ; Jump to DSPLY_MODE:


TOG_MODE1:
     jsr     CHANGE_MODE      ; Jump to subroutine at CHANGE_MODE:
     jmp     LOOPY            ; Jump to LOOPY:
                              ;(Mode has changed, so start again)

TOG_FRZ:

;****************************************************************************
; - Toggle "frz" bit of "flags" variable whenever "Freeze/Select" button
;   is pressed, while in Display mode.
;****************************************************************************

     com     FrzCntr          ; Ones compliment "FrzCntr"
                              ;(flip state of "FrzCntr"
     bne     SET_FRZ          ; If the Z bit of CCR is clear, branch
                              ; to SET_FRZ:
     bclr    frz,flags        ; Clear "frz" bit of "flags" variable
                              ; ("frz" = 0 = variables 250mS update)
     bra     TOG_FRZ_DONE     ; Branch to TOG_FRZ_DONE:

SET_FRZ:
     bset    frz,flags        ; Set "frz" bit "flags" variable
                              ;("frz" = 1 = variables frozen)

TOG_FRZ_DONE:
     bclr    Sw2cls,Swflags   ; Clear "Sw2cls" bit of "Swflags" variable
     jmp     DSPLY_MODE       ; Jump to DSPLY_MODE:

SCRL_D_RT:

;****************************************************************************
; - Increment the Display Screen number.
;****************************************************************************

INC_SCRNCNT:
     lda     ScrnCnt_prv     ; Load accumulator with value in "ScrnCnt_prv"
     cmp     #$0C            ; Compare with decimal 12
     beq     RTN_TO_0_D      ; If Z bit of CCR is set, branch to RTN_TO_0_D
                             ;("ScrnCnt_prv" = 12 so return to screen 0)
     inc     ScrnCnt         ; Increment "ScrnCnt" variable
     bra     SCRL_D_RT_DONE  ; Branch to SCRL_D_RT_DONE:

RTN_TO_0_D:
    clr     ScrnCnt          ; Clear "ScrnCnt" variable(ScrnCnt = 0)

SCRL_D_RT_DONE:
     mov     ScrnCnt,ScrnCnt_prv  ; Move value in "ScrnCnt" to ScrnCnt_prv"
     bclr    Sw1cls,Swflags       ; Clear "Sw1cls" bit of "Swflags" variable
     jmp     DSPLY_MODE           ; Jump to DSPLY_MODE:


SCRL_D_LFT:

;****************************************************************************
; - Decrement the Display Screen number.
;****************************************************************************


DEC_SCRNCNT:
     lda     ScrnCnt_prv      ; Load accumulator with value in "ScrnCnt_prv"
     beq     RTN_TO_12        ; If Z bit of CCR is set, branch to RTN_TO_12
                              ;("ScrnCnt_prv" = 0 so return to screen 12)
     dec     ScrnCnt          ; Decrement "ScrnCnt" variable
     bra     SCRL_D_LFT_DONE  ; Branch to SCRL_D_LFT_DONE:

RTN_TO_12:
    mov     #$0C,ScrnCnt      ; Move decimal 12 into "ScrnCnt" variable

SCRL_D_LFT_DONE:
     mov     ScrnCnt,ScrnCnt_prv  ; Move value in "ScrnCnt" to ScrnCnt_prv"
     bclr    Sw0cls,Swflags       ; Clear "Sw0cls" bit of "Swflags" variable


DSPLY_MODE:

;****************************************************************************
; - We are in Display mode. The desired screen count number has been
;   determined. If the screen count number is anything other than the first
;   10 screens, clear the bottom line of the screen and jump back to the main
;   loop.
;****************************************************************************

SCRN_CNT_CHK:
     lda     ScrnCnt           ; Load accumulator with value in "ScrnCnt"
     cmp     #$07              ; Compare with decimal 7
     bls     TOPLIN_SUB        ; If (A)<= decimal 7, branch to TOPLIN_SUB:
     jsr     LOAD_SPACE        ; Jump to subroutine at LOAD_SPACE:
     jsr     VFD_START_BOT     ; Jump to subroutine at VFD_START_BOT:
     jmp     BOTLIN_CHK_D      ; Jump to BOTLIN_CHK_D

;****************************************************************************
; - We are in one of the first 8 screens. Using the screen count number,
;   determine the appropriate array for the top line of the display and
;   print it.
;
; - First, compare the desired screen count number with the screen count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

TOPLIN_SUB:
     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cmp     ScrnCnt_Lst          ; Compare with "ScrnCnt_Lst"
     beq     NO_CHNG_TOP          ; If Z bit of CCR is clear, branch to
                                  ; NO_CHNG_TOP:(ScrnCnt_Lst = ScrnCnt)
     jsr     PRNT_TOPLN_DSP       ; Jump to subroutine at PRNT_TOPLN_DSP:
     mov     ScrnCnt,ScrnCnt_Lst  ; Copy value in "ScrnCnt" to ScrnCnt_Lst"

NO_CHNG_TOP:

DISP_BOT:

;****************************************************************************
; - We have 20 variables in RAM in ordered list(BotLin0 through BotLin19)
;   which have been initialized to ASCII $20(blank space). The variable
;   "DisVal" contains the offset value from the entry point of the ordered
;   list of variables, beginning at the variable "secH". "DisVal" matches
;   the variable's abbreviation on the top line on the display. Using
;   "DisVal", we do an ASCII conversion of each variable, and overwrite the
;   3 blank spaces on the bottom line beneath the matching variable
;   abreviation, with the appropriate numbers.
;****************************************************************************


;****************************************************************************
; - Load the over-write values for the bottom line string.
;****************************************************************************

     jsr     LOAD_SPACE             ; Jump to subroutine at LOAD_SPACE:

;****************************************************************************
; - Determine which screen we are in, and prepare the appropriate string for
;   the bottom line of the VFD
;****************************************************************************

     lda     ScrnCnt              ; Load accumulator with value in "ScrnCnt"
     cbeqa   #$07,CONFIG_SCRNS    ; Compare and branch to CONFIG_SCRNS:,
                                  ; if equal to decimal 7
     cbeqa   #$06,CONFIG_SCRNS    ; Compare and branch to CONFIG_SCRNS:,
                                  ; if equal to decimal 6
     cbeqa   #$05,PW_COR_JMP      ; Compare and branch to PW_COR_JMP:,
                                  ; if equal to decimal 5
     cbeqa   #$04,DF_TUN_JMP      ; Compare and branch to DF_TUN_JMP:,
                                  ; if equal to decimal 4
     cbeqa   #$03,IACPW_RPM_JMP   ; Compare and branch to IACPW_RPM_JMP:,
                                  ; if equal to decimal 3
     cbeqa   #$02,DF_PRS_JMP      ; Compare and branch to DF_PRS_JMP:,
                                  ; if equal to decimal 2
     cbeqa   #$01,GUAGES_JMP      ; Compare and branch to GUAGES_JMP:,
                                  ; if equal to decimal 1
     cbeqa   #$00,STATUS_JMP      ; Compare and branch to STATUS_JMP:,
                                  ; if equal to decimal 0
     jmp     LOOPY                ; Jump to LOOPY(sanity check)

;****************************************************************************
; - We are in either of the 2 screens which lead you to the configuration
;   section. Clear the bottom line and loop back.
;****************************************************************************

CONFIG_SCRNS:
     jsr     VFD_START_BOT     ; Jump to subroutine at VFD_START_BOT:
     jmp     BOTLIN_CHK_D      ; Jump to BOTLIN_CHK_D

;****************************************************************************
; - We are in one of the other real time display screens, jump to the
;   appropriate section.
;****************************************************************************

PW_COR_JMP:
     jmp     PW_COR            ; Jump to PW_COR:(Long branch)

DF_TUN_JMP:
     jmp     DF_TUN            ;Jump to DF_TUN:(Long branch)

IACPW_RPM_JMP:
     jmp     IACPW_RPM         ; Jump to IACPW_RPM:(Long branch)

DF_PRS_JMP:
     jmp     DF_PRS            ; Jump to DF_PRS:(Long branch)

GUAGES_JMP:
     jmp     GUAGES            ; Jump to GUAGES:(Long branch)

STATUS_JMP:
     jmp     STATUS            ; Jump to STATUS:(Long branch)


PW_COR:
     lda     df                ; Load accumulator with value in "df"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_1ST_3        ; Jump to subroutine at LOAD_1ST_3:
     lda     TOTAdd            ; Load accumulator with value in "TOTAdd"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_2ND_3        ; Jump to subroutine at LOAD_2ND_3:
     lda     TrimAdd           ; Load accumulator with value in "TrimAdd"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_3D_3         ; Jump to subroutine at LOAD_3D_3:
     lda     df1               ; Load accumulator with value in "df1"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_4TH_3        ; Jump to subroutine at LOAD_4TH_3:
     lda     dff               ; Load accumulator with value in "dff"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_5TH_3        ; Jump to subroutine at LOAD_5TH_3:
     jmp     CHK_FRZ_DISP      ; Jump to CHK_FRZ_DISP:


DF_TUN:
     lda     RPM               ; Load accumulator with value in "RPM"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_1ST_3        ; Jump to subroutine at LOAD_1ST_3:
     lda     KPA               ; Load accumulator with value in "KPA"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_2ND_3        ; Jump to subroutine at LOAD_2ND_3:
     lda     TPSp              ; Load accumulator with value in "TPSp"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_3D_3         ; Jump to subroutine at LOAD_3D_3:
     lda     TrimAdd           ; Load accumulator with value in "TrimAdd"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_4TH_3        ; Jump to subroutine at LOAD_4TH_3:
     lda     df                ; Load accumulator with value in "df"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_5TH_3        ; Jump to subroutine at LOAD_5TH_3:
     jmp     CHK_FRZ_DISP      ; Jump to CHK_FRZ_DISP:

IACPW_RPM:
     lda     secH              ; Load accumulator with value in "secH"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_1ST_3        ; Jump to subroutine at LOAD_1ST_3:
     lda     secL              ; Load accumulator with value in "secL"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_2ND_3        ; Jump to subroutine at LOAD_2ND_3:
     lda     IAC               ; Load accumulator with value in "IAC"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_3D_3         ; Jump to subroutine at LOAD_3D_3:
     lda     IACpw             ; Load accumulator with value in "IACpw"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_4TH_3        ; Jump to subroutine at LOAD_4TH_3:
     lda     RPM               ; Load accumulator with value in "RPM"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_5TH_3        ; Jump to subroutine at LOAD_5TH_3:
     jmp     CHK_FRZ_DISP      ; Jump to CHK_FRZ_DISP:


DF_PRS:
     lda     df                ; Load accumulator with value "df"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_1ST_3        ; Jump to subroutine at LOAD_1ST_3:
     lda     TPSp              ; Load accumulator with value "TPSp"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_2ND_3        ; Jump to subroutine at LOAD_2ND_3:
     lda     EPCpwH            ; Load accumulator with value "EPCpwH"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_3D_3         ; Jump to subroutine at LOAD_3D_3:
     lda     EPCpwL            ; Load accumulator with value "EPCpwL"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_4TH_3        ; Jump to subroutine at LOAD_4TH_3:
     lda     Lpsi              ; Load accumulator with value "Lps1"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_5TH_3        ; Jump to subroutine at LOAD_5TH_3:
     jmp     CHK_FRZ_DISP      ; Jump to CHK_FRZ_DISP:

GUAGES:
     lda     RPM               ; Load accumulator with value in "RPM"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_1ST_3        ; Jump to subroutine at LOAD_1ST_3:
     lda     MPH               ; Load accumulator with value in "MPH"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_2ND_3        ; Jump to subroutine at LOAD_2ND_3:
     lda     Lpsi              ; Load accumulator with value in "Lpsi"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_3D_3         ; Jump to subroutine at LOAD_3D_3:
     lda     TOTemp            ; Load accumulator with value in "TOTemp"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_4TH_3        ; Jump to subroutine at LOAD_4TH_3:
     lda     Volts             ; Load accumulator with value in "Volts"
     sta     DisVal            ; Copy to "DisVal" variable
     jsr     CONV_8BIT_ASCII   ; Jump to subroutine at CONV_8BIT_ASCII:
     jsr     LOAD_5TH_3        ; Jump to subroutine at LOAD_5TH_3:
     jmp     CHK_FRZ_DISP      ; Jump to CHK_FRZ_DISP:

STATUS:
     lda     mlpsp          ; Load accumulator with value in MLPS position
     cbeqa   #P,PARK        ; Compare with value #P, if equal,
                            ; branch to PARK:
     cbeqa   #R,REVERSE     ; Compare with value #R, if equal,
                            ; branch to REVERSE:
     cbeqa   #N,NEUTRAL     ; Compare with value #N, if equal,
                            ; branch to NEUTRAL:
     cbeqa   #D,DRIVE       ; Compare with value #D, if equal,
                            ; branch to DRIVE:
     cbeqa   #M2,MAN2       ; Compare with value #m2, if equal,
                            ; branch to MAN2:
     cbeqa   #M1,MAN1       ; Compare with value #M1, if equal,
                            ; branch to MAN1:
     bra     OOR_MLP        ; Branch to OOR_MLP:(out of range MLP)

PARK:
     mov     #'P',Botlin0    ; Move "P" into "Botlin0"
     mov     #' ',Botlin1    ; Move "space" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

REVERSE:
     mov     #'R',Botlin0    ; Move "R" into "Botlin0"
     mov     #' ',Botlin1    ; Move "space" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

NEUTRAL:
     mov     #'N',Botlin0    ; Move "N" into "Botlin0"
     mov     #' ',Botlin1    ; Move "space" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

DRIVE:
     mov     #'D',Botlin0    ; Move "D" into "Botlin0"
     mov     #' ',Botlin1    ; Move "space" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

MAN2:
     mov     #'M',Botlin0    ; Move "M" into "Botlin0"
     mov     #'2',Botlin1    ; Move "2" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

MAN1:
     mov     #'M',Botlin0    ; Move "M" into "Botlin0"
     mov     #'1',Botlin1    ; Move "1" into "Botlin1"
     bra     MLPSP_DONE      ; Branch to MLPSP_DONE:

OOR_MLP:
     mov     #'?',Botlin0    ; Move "?" into "Botlin0"
     mov     #'?',Botlin1    ; Move "?" into "Botlin1"

MLPSP_DONE:

     lda     gearcnt          ; Load accumulator with value in "gearcnt"
     cbeqa   #first,ONE       ; Compare with value #first, if equal,
                              ; branch to ONE:
     cbeqa   #second,TWO      ; Compare with value #second, if equal,
                              ; branch to TWO:
     cbeqa   #third,THREE     ; Compare with value #third, if equal,
                              ; branch to THREE:
     cbeqa   #forth,FOUR      ; Compare with value #forth, if equal,
                              ; branch to FOUR:
     bra     OOR_GR           ; Branch to OOR_GR:(out of range grcnt)

ONE:
     mov     #'1',Botlin3      ; Move "1" into "Botlin3"
     bra     GEARCNT_DONE      ; Branch to GEARCNT_DONE:

TWO:
     mov     #'2',Botlin3      ; Move "2" into "Botlin3"
     bra     GEARCNT_DONE      ; Branch to GEARCNT_DONE:

THREE:
     mov     #'3',Botlin3      ; Move "3" into "Botlin3"
     bra     GEARCNT_DONE      ; Branch to GEARCNT_DONE:

FOUR:
     mov     #'4',Botlin3      ; Move "4" into "Botlin3"
     bra     GEARCNT_DONE      ; Branch to GEARCNT_DONE:

OOR_GR:
     mov     #'?',Botlin3    ; Move "?" into "Botlin3"

GEARCNT_DONE:
     brset   CCSon,trans2,CCS     ; If "CCSon" bit of "trans2" variable is
                                  ; set, branch to CCS:
     mov     #'N',Botlin6         ; Move "N" into "Botlin6"
     bra     CCS_DONE             ; Branch to CCS_DONE:

CCS:
     mov     #'Y',Botlin6         ; Move "Y" into "Botlin6"

CCS_DONE:
     brset   TCCon,trans2,TCC     ; If "TCCon" bit of "trans2" variable is
                                  ; set, branch to TCC:
     mov     #'N',Botlin9         ; Move "N" into "Botlin9"
     bra     TCC_DONE             ; Branch to TCC_DONE:

TCC:
     mov     #'Y',Botlin9         ; Move "Y" into "Botlin9"

TCC_DONE:
     brset   DFCon,trans2,DFC     ; If "DFCon" bit of "trans2" variable is
                                  ; set, branch to DFC:
     mov     #'N',Botlin12        ; Move "N" into "Botlin12"
     bra     DFC_DONE             ; Branch to DFC_DONE:

DFC:
     mov     #'Y',Botlin12        ; Move "Y" into "Botlin12"

DFC_DONE:
     brset   PSIbrk,trans,PSI     ; If "PSIbrk" bit of "trans" variable is
                                  ; set, branch to PSI:
     mov     #'N',Botlin15        ; Move "N" into "Botlin15"
     bra     PSI_DONE             ; Branch to PSI_DONE:

PSI:
     mov     #'Y',Botlin15        ; Move "Y" into "Botlin15"

PSI_DONE:
     brset   BRKon,trans2,BRK     ; If "BRKon" bit of "trans2" variable is
                                  ; set, branch to BRK:
     mov     #'N',Botlin18        ; Move "N" into "Botlin18"
     bra     BRK_DONE             ; Branch to BRK_DONE:

BRK:
     mov     #'Y',Botlin18        ; Move "Y" into "Botlin18"

BRK_DONE:


;***************************************************************************
; - Check to see if we have had a "display freeze" command and branch
;   accordingly.
;***************************************************************************

CHK_FRZ_DISP:
     brset    frz,flags,NO_CHNG_DB     ; If "frz" bit of "flags" variable
                                       ; is set, branch to NO_CHNG_DB:


;****************************************************************************
; - Compare all the characters on the bottom line commanded, to those of the
;   previous bottom line. If they are different, update the bottom line,
;   otherwise, skip over. This is to eliminate display  "digit rattle"
;   caused by rapid screen updates.
;****************************************************************************

BOTLIN_CHK_D:
     jsr     CMP_BOTLIN                   ; Jump to subroutine at CMP_BOTLIN:
     brclr   LinChng,flags,NO_CHNG_DB     ; If "LinChng" bit of "flags"
                                          ; variable is clear, branch to
                                          ; NO_CHNG_DB:

;****************************************************************************
; - Set up the VFD to place the first character in the bottom line, extreme
;   left hand position
;****************************************************************************

     jsr     VFD_START_BOT      ; Jump to subroutine at VFD_START_BOT:

;***************************************************************************
; - Print the bottom line of the VFD display
;***************************************************************************

PRINT_BOT_D:
     ldhx    #BotLin0                 ; Load index register with address of
                                      ; entry point for bottom line of VFD
     jsr     PRINT_LINE               ; Jump to subroutine at PRINT_LINE:

NO_CHNG_DB:
     jmp     LOOPY          ; Jump to LOOPY:(End of program loop while in
                            ; "Display" mode)



;****************************************************************************
;****************************************************************************
;*                         CONFIGURATION SECTION                            *
;****************************************************************************
;****************************************************************************

CONFIG_CHK:

;****************************************************************************
; - Check to see if any of the input flags are set, and if so, branch
;   accordingly.
;****************************************************************************

     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,TOG_MODE2  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; TOG_MODE2:
                                       ;(Toggle Mode button is pressed)
     brset   Sw2cls,Swflags,TOG_SEL    ; If "Sw2cls" bit of "Swflags" variable
                                       ; is set, branch to TOG_SEL
                                       ;(Freeze/Select button is pressed)

CONFIG_CHK_DONE:
     jmp     CONFIG_MODE      ; Jump to CONFIG_MODE:

TOG_MODE2:
     jsr     CHANGE_MODE      ; Jump to subroutine at CHANGE_MODE:
     jmp     LOOPY            ; Jump to LOOPY:
                              ;(Mode has changed, so start again)

TOG_SEL:

;****************************************************************************
; - Toggle "sel" bit of "flags" variable whenever "Freeze/Select" button
;   is pressed, while in Configure mode.
;****************************************************************************

     com     SelCntr             ; Ones compliment "SelCntr"
                                 ;(flip state of "SelCntr"
     bne     SET_SEL             ; If the Z bit of CCR is clear, branch
                                 ; to SET_SEL:
     bclr    sel,flags           ; Clear "sel" bit of "flags" variable
                                 ; ("sel" = 0 = no constant selected)
     bra     TOG_SEL_DONE        ; Branch to TOG_SEL_DONE:

SET_SEL:
     bset    sel,flags           ; Set "sel" bit "flags" variable
                                 ;("sel" = 1 = current constant selected)

TOG_SEL_DONE:
     bclr    Sw2cls,Swflags      ; Clear "Sw2cls" bit of "Swflags" variable


CONFIG_MODE:

;****************************************************************************
; - Check to see if the current constant is selected or not,
;   and branch accordingly.
;****************************************************************************

     brset   sel,flags,SEL_SET     ; If "sel" bit of "flags" bit is set,
                                   ; branch to SEL_SET:
                                   ;(current constant is selected, so check
                                   ; if it should be changed or not)
     bra     CHK_SCRL              ; Branch to CHK_SCRL:

SEL_SET:
     jmp     DISP_CON_BOT          ; Jump to DISP_CON_BOT:(Long branch)

CHK_SCRL:

;****************************************************************************
; - Current constant is not selected, so check if we should scroll to the
;   next or previous constant, or stay where we are.
;****************************************************************************

     brset   Sw0cls,Swflags,SCRL_C_LFT  ; If "Sw0cls" bit of "Swflags" var
                                        ; is set, branch to SCRL_C_LFT:
                                        ;(Scroll Left/Decrement button is
                                        ; pressed)
     brset   Sw1cls,Swflags,SCRL_C_RT   ; If "Sw1cls" bit of "Swflags" var
                                        ; is set, branch to SCRL_C_RT:
                                        ;(Scroll Right/Increment button is
                                        ; pressed)

CHK_SCRL_DONE:
     jmp     DISP_CON_TOP               ; Jump to DISP_CON_TOP:

SCRL_C_RT:

;****************************************************************************
; - Constants pages Group 1 and 2 are different sizes, so the constant
;   count limits will be different. Using the "ScrnCnt" variable, determine
;   which Constant group we are using, and branch accordingly
;****************************************************************************

     lda     ScrnCnt     ; Load accumulator with value in "ScrnCnt" variable
     cmp     #$07        ; Compare with decimal 7(Con Screen 2)
     beq     INC_CONCNT2 ; If Z bit of CCR is set, branch to INC_CONCNT2:

;****************************************************************************
; - Increment the Constant number,Group 1.
;****************************************************************************

INC_CONCNT:
     lda     ConCnt_prv      ; Load accumulator with value in "ConCnt_prv"
     cmp     #$7F            ; Compare with decimal 127
     beq     RTN_TO_0_C      ; If Z bit of CCR is set, branch to RTN_TO_0_C
                             ;("ConCnt_prv" = 127 so return to "ConCnt = 0)
     inc     ConCnt          ; Increment "ConCnt" variable
     bra     SCRL_C_RT_DONE  ; Branch to SCRL_C_RT_DONE:

RTN_TO_0_C:
    clr     ConCnt           ; Clear "ConCnt" variable(ConCnt = 0)

SCRL_C_RT_DONE:
     mov     ConCnt,ConCnt_prv   ; Move value in "ConCnt" to "ConCnt_prv"
     mov     ConCnt,CurCon       ; Move value in "ConCnt" to "CurCon"
     bclr    Sw1cls,Swflags      ; Clear "Sw1cls" bit of "Swflags" variable
     jmp     DISP_CON_TOP        ; Jump to DISP_CON_TOP:

;****************************************************************************
; - Increment the Constant number,Group 2.
;****************************************************************************

INC_CONCNT2:
     lda     ConCnt_prv      ; Load accumulator with value in "ConCnt_prv"
     cmp     #$3F            ; Compare with decimal 63
     beq     RTN_TO_0_C2     ; If Z bit of CCR is set, branch to RTN_TO_0_C2
                             ;("ConCnt_prv" = 63 so return to "ConCnt = 0)
     inc     ConCnt          ; Increment "ConCnt" variable
     bra     SCRL_C_RT2_DONE ; Branch to SCRL_C_RT2_DONE:

RTN_TO_0_C2:
    clr     ConCnt           ; Clear "ConCnt" variable(ConCnt = 0)

SCRL_C_RT2_DONE:
     mov     ConCnt,ConCnt_prv   ; Move value in "ConCnt" to "ConCnt_prv"
     mov     ConCnt,CurCon       ; Move value in "ConCnt" to "CurCon"
     bclr    Sw1cls,Swflags      ; Clear "Sw1cls" bit of "Swflags" variable
     jmp     DISP_CON_TOP        ; Jump to DISP_CON_TOP:

SCRL_C_LFT:

;****************************************************************************
; - Constants pages Group 1 and 2 are different sizes, so the constant
;   count limits will be different. Using the "ScrnCnt" variable, determine
;   which Constant group we are using, and branch accordingly
;****************************************************************************

     lda     ScrnCnt     ; Load accumulator with value in "ScrnCnt" variable
     cmp     #$07        ; Compare with decimal 7(Con Screen 2)
     beq     DEC_CONCNT2 ; If Z bit of CCR is set, branch to DEC_CONCNT2:

;****************************************************************************
; - Decrement the Constant number, Group 1.
;****************************************************************************

DEC_CONCNT:
     lda     ConCnt_prv      ; Load accumulator with value in "ConCnt_prv"
     beq     RTN_TO_127      ; If Z bit of CCR is set, branch to RTN_TO_127:
     dec     ConCnt          ; Decrement "ConCnt" variable
     bra     SCRL_C_LFT_DONE ; Branch to SCRL_C_LFT_DONE:

RTN_TO_127:
    mov     #$7F,ConCnt      ; Move decimal 127 into "ConCnt" variable

SCRL_C_LFT_DONE:
     mov     ConCnt,ConCnt_prv    ; Move value in "ConCnt" to "ConCnt_prv"
     mov     ConCnt,CurCon        ; Move value in "ConCnt" to CurCon"
     bclr    Sw0cls,Swflags       ; Clear "Sw0cls" bit of "Swflags" variable
     jmp     DISP_CON_TOP        ; Jump to DISP_CON_TOP:

;****************************************************************************
; - Decrement the Constant number, Group 2.
;****************************************************************************

DEC_CONCNT2:
     lda     ConCnt_prv       ; Load accumulator with value in "ConCnt_prv"
     beq     RTN_TO_63        ; If Z bit of CCR is set, branch to RTN_TO_63:
     dec     ConCnt           ; Decrement "ConCnt" variable
     bra     SCRL_C_LFT2_DONE ; Branch to SCRL_C_LFT2_DONE:

RTN_TO_63:
    mov     #$3F,ConCnt       ; Move decimal 63 into "ConCnt" variable

SCRL_C_LFT2_DONE:
     mov     ConCnt,ConCnt_prv    ; Move value in "ConCnt" to "ConCnt_prv"
     mov     ConCnt,CurCon        ; Move value in "ConCnt" to CurCon"
     bclr    Sw0cls,Swflags       ; Clear "Sw0cls" bit of "Swflags" variable

DISP_CON_TOP:

;****************************************************************************
; - We are in Configuration mode. Because the addresses of the tables for
;   character strings are 2 bytes long, we are limited to 128 offset values
;   from any starting point. We have more than 128 constants, so the list
;   is broken up into 2 parts, each with it's own starting screen. "Con
;   Screen 1" starts with "TO_0_0", and contains the TO table, RPM_RANGE,
;   KPA_RANGE, TPS_RANGE, EPC_STALL, EPC_12, EPC_23, and EPC_34 tables.
;   "Con Screen 2" starts with "EPC_TCC" and contains the configurable
;   constants. Using the "ScrnCnt" variable, determine which section of the
;   constants we should be using.
;   The desired constant count number has been determined. Using the constant
;   count number, determine the appropriate array for the top line of the
;   display. Also, determine the appropriate constant for the bottom line
;   of the display.
;****************************************************************************

;****************************************************************************
; - Set up the VFD to place the first character in the top line, extreme
;   left hand position
;****************************************************************************

     jsr     VFD_START_TOP     ; Jump to subroutine at VFD_START_TOP:

;****************************************************************************
; - Using the value in "ScrnCnt" determine which of the two constant table
;   indexes we should be in.
;****************************************************************************

     lda     ScrnCnt     ; Load accumulator with avlue in "ScrnCnt" variable
     cmp     #$07        ; Compare with decimal 7(Con Screen 2)
     beq     CON_SCRN_2  ; If Z bit of CCR is set, branch to CON_SCRN_7:
     cmp     #06         ; Compare with decimal 6(Con Screen 1)
     beq     CON_SCRN_1  ; If Z bit of CCR is set, branch to CON_SCRN_1:
     bclr    mde,flags   ; Clear "mde" bit of "flags" variable
     jmp     LOOPY       ; Jump to LOOPY:
                         ;(Return to "Display" mode)(sanity check)

CON_SCRN_2:
     clrh
     ldhx    #G2_CONS_TL_TB_IND ; Load index register with the address of
                                ; the first value in the Constants
                                ; Group 2 Top Line Table Index vector
                                ; table
     bra     VECTOR_ADDRESS     ; Branch to VECTOR_ADDRESS:

CON_SCRN_1:
     clrh
     ldhx    #G1_CONS_TL_TB_IND ; Load index register with the address of
                                ; the first value in the Constants
                                ; Group 1 Top Line Table Index vector
                                ; table


;***************************************************************************
; - Using the Constants Top Line Table Index vector table, and the "ConCnt"
;   offset value, load H:X with the address of the desired Constants Top
;   Line Table Index.
;***************************************************************************

VECTOR_ADDRESS:
     lda     ConCnt            ; Load accumulator with the value in "ConCnt"
     jsr     GET_VECT_ADDR     ; Jump to subroutine at GET_VECT_ADDR:

;***************************************************************************
; - Print the top line of the VFD display
;
; - First, compare the desired constant count number with the constant count
;   number on the last pass through the main loop. If it is the same, skip
;   over, otherwise update the top line of the display. This is to eliminate
;   "digit rattle" caused by rapid screen updates.
;***************************************************************************

     lda     ConCnt             ; Load accumulator with value in "ConCnt"
     cmp     ConCnt_Lst         ; Compare with "ConCnt_Lst"
     beq     NO_CHNG_CT         ; If Z bit of CCR is clear, branch to
     mov     ConCnt,ConCnt_Lst  ; Copy value in "ConCnt" to ConCnt_Lst"
                                ; NO_CHNG_CT:(ConCnt_Lst = ConCnt)
     jsr     PRINT_LINE         ; Jump to subroutine at PRINT_LINE:

NO_CHNG_CT:

DISP_CON_BOT:

;****************************************************************************
; - We have 20 variables in RAM in ordered list(BotLin0 through BotLin19)
;   which have been initialized to ASCII $20(blank space). The variable
;   "CurCon" contains the offset value from the entry point of the ordered
;   list of constants beginning at the variable "TO_0_0". "CurCon" matches
;   the current Constants Top Line on the display. Using "CurCon", we do an
;   ASCII conversion of the variable, and overwrite the first 3 blank spaces
;   on the bottom line with appropriate numbers. The rest of the line
;   remains blank.
;****************************************************************************

;****************************************************************************
; - Using the value in "ScrnCnt" determine which of the two constant table
;   indexes we should be in.
;****************************************************************************

     lda     ScrnCnt     ; Load accumulator with avlue in "ScrnCnt" variable
     cmp     #$07        ; Compare with decimal 7(Con Screen 2)
     beq     G2_CONS     ; If Z bit of CCR is set, branch to G2_CONS:
     cmp     #06         ; Compare with decimal 6(Con Screen 1)
     beq     G1_CONS     ; If Z bit of CCR is set, branch to G1_CONS:
     bclr    mde,flags   ; Clear "mde" bit of "flags" variable
     jmp     LOOPY       ; Jump to LOOPY:
                         ;(Return to "Display" mode)(sanity check)


;****************************************************************************
; - Load the value of the current "G1" constant and update if required.
;****************************************************************************

G1_CONS:
     lda     CurCon       ; Load accumulator with value in "CurCon" var
                          ;(offset from beginning of ordered list section)
     clrh                 ; Clear index register Hi byte
     tax                  ; Transfer value in accumulator to index
                          ; register Lo byte(offset)
     lda     TO_0_0,x     ; Load accumulator with value in location
                          ; "TO_0_0", offset in index register Lo byte
     sta     ConVal       ; Copy value in accumulator to "ConVal" variable
     brclr   sel,flags,NOT_SEL_G1   ; If "sel" bit of "flags" variable is
                                    ; clear, branch to NOT_SEL_G1:

;****************************************************************************
; - Update RAM
;****************************************************************************

     jsr     UPDATE_CON   ; Jump to subroutine at UPDATE_CON:
     lda     CurCon       ; Load accumulator with value in "CurCon"
     clrh                 ; Clear index register Hi byte
     tax                  ; Transfer value in accumulator to index register
                          ; Lo byte
     lda     ConVal       ; Load accumulator with value in "ConVal"
     sta     TO_0_0,x     ; Copy to location at "TO_0_0", offset in index
                          ; register Lo byte(update the RAM value)
NOT_SEL_G1:
     bra     DO_CON_CONV  ; Branch to DO_CON_CONV:

;****************************************************************************
; - Load the value of the current "G2" constant and update if required.
;****************************************************************************

G2_CONS:
     lda     CurCon       ; Load accumulator with value in "CurCon" var
                          ;(offset from beginning of ordered list section)
     clrh                 ; Clear index register Hi byte
     tax                  ; Transfer value in accumulator to index
                          ; register Lo byte(offset)
     lda     EPC_TCC,x     ; Load accumulator with value in location
                          ; "EPC_TCC", offset in index register Lo byte
     sta     ConVal       ; Copy value in accumulator to "ConVal" variable
     brclr   sel,flags,NOT_SEL_G2    ; If "sel" bit of "flags" variable is
                                     ; clear, branch to NOT_SEL_G2:

;****************************************************************************
; - Update RAM
;****************************************************************************

     jsr     UPDATE_CON   ; Jump to subroutine at UPDATE_CON:
     lda     CurCon       ; Load accumulator with value in "CurCon"
     clrh                 ; Clear index register Hi byte
     tax                  ; Transfer value in accumulator to index register
                          ; Lo byte
     lda     ConVal       ; Load accumulator with value in "ConVal"
     sta     EPC_TCC,x    ; Copy to location at "EPC_TCC", offset in index
                          ; register Lo byte(update the RAM value)

NOT_SEL_G2:

;****************************************************************************
; - Do the conversion from 8 bit variable to 3 byte ASCII string
;****************************************************************************

DO_CON_CONV:
     jsr     CONV_8BIT_ASCII     ; Jump to subroutine at CONV_8BIT_ASCII:

;****************************************************************************
; - Load the over-write values for the bottom line string.
;****************************************************************************

LOAD_BOT:
     jsr     LOAD_SPACE              ; Jump to subroutine at LOAD_SPACE:
     jsr     LOAD_1ST_3              ; Jump to subroutine at LOAD_1ST_3:
     brclr   sel,flags,BOTLIN_CHK_C  ; If "sel" bit of "flags" variable
                                     ;  is clear, branch to BOTLIN_CHK_C:
     lda     #'S'                    ; Load accumulator with ASCII 'S'
     sta     BotLin11                ; Copy to "BotLin11"
     lda     #'E'                    ; Load accumulator with ASCII 'E'
     sta     BotLin12                ; Copy to "BotLin12"
     lda     #'L'                    ; Load accumulator with ASCII 'L'
     sta     BotLin13                ; Copy to "BotLin13"
     lda     #'E'                    ; Load accumulator with ASCII 'E'
     sta     BotLin14                ; Copy to "BotLin14"
     lda     #'C'                    ; Load accumulator with ASCII 'C'
     sta     BotLin15                ; Copy to "BotLin15"
     lda     #'T'                    ; Load accumulator with ASCII 'T'
     sta     BotLin16                ; Copy to "BotLin16"
     lda     #'E'                    ; Load accumulator with ASCII 'E'
     sta     BotLin17                ; Copy to "BotLin17"
     lda     #'D'                    ; Load accumulator with ASCII 'D'
     sta     BotLin18                ; Copy to "BotLin18"
     lda     #'!'                    ; Load accumulator with ASCII '!'
     sta     BotLin19                ; Copy to "BotLin19"

;****************************************************************************
; - Compare all the characters on the bottom line commanded, to those of the
;   previous bottom line. If they are different, update the bottom line,
;   otherwise, skip over. This is to eliminate display  "digit rattle"
;   caused by rapid screen updates.
;****************************************************************************

BOTLIN_CHK_C:
     jsr     CMP_BOTLIN                   ; Jump to subroutine at CMP_BOTLIN:
     brclr   LinChng,flags,NO_CHNG_CB     ; If "LinChng" bit of "flags"
                                          ; variable is clear, branch to
                                          ; NO_CHNG_CB:

****************************************************************************
; - Set up the VFD to place the first character in the bottom line, extreme
;   left hand position
;****************************************************************************

START_BOT_C:
     jsr     VFD_START_BOT      ; Jump to subroutine at VFD_START_BOT:

;***************************************************************************
; - Print the bottom line of the VFD display
;***************************************************************************

     ldhx    #BotLin0         ; Load index register with address of entry
                              ; point for bottom line of VFD
     jsr     PRINT_LINE       ; Jump to subroutine at PRINT_LINE:

NO_CHNG_CB:
     jmp     LOOPY            ; Jump to LOOPY: (End of program loop)



;****************************************************************************
;
; * * * * * * * * * * * * * * Interrupt Section * * * * * * * * * * * * * *
;
; NOTE!!! If the interrupt service routine modifies the H register, or uses
; the indexed addressing mode, save the H register (pshh) and then restore
; it (pulh) prior to exiting the routine
;
;****************************************************************************

;****************************************************************************
;
; -------- Following interrupt service routines in priority order ----------
;
; TIM2CH0_ISR: - TIM2 CH0 Interrupt (1000uS clock tick)(1.0mS)
;
; SCIRCV_ISR:  - SCI receive
;
; SCITX_ISR:   - SCI transmit (Not used)
;
;
;***************************************************************************

;****************************************************************************
;============================================================================
; - TIM2 CH0 Interrupt (1000uS clock tick)(1.0mS)
; - Generate time rates:
;   Milliseconds,(for contact de-bounce counters)
;   5 Milleseconds,(for auto-repeat and auto-repeat command counters)
;   250 Milliseconds,(for real time variable display updates)
;============================================================================
;****************************************************************************

TIM2CH0_ISR:
     pshh                  ; Push value in index register Hi byte to stack
     lda     T2SC0         ; Load accumulator with value in TIM2 CH0 Status
                           ; and Control Register (Arm CHxF flag clear)
     bclr    CHxF,T2SC0    ; Clear CHxF bit of TIM2 CH0 Status and
                           ; Control Register
     lda     T2CH0L        ; Load accumulator with value in TIM2 CH0 OC
                           ; register Lo byte
     add     #$E8          ; Add (A)<-(A)+(#) decimal 232
     tax                   ; Transfer value in accumulator to index
                           ; register Lo byte
     lda     T2CH0H        ; Load accumulator with value in TIM2 CH0 OC
                           ; register Hi byte
     adc     #$03          ; Add with carry decimal 768 (A)<-(A)+(#)+(C)
                           ;(total = ~1000uS)
     sta     T2CH0H        ; Copy result to TIM2 CH0 OC register Hi byte
     stx     T2CH0L        ; Copy value in index register Lo byte
                           ; to TIM2 CH0 OC register Lo byte
                           ;(new output compare value)

;============================================================================
;*********************** 1.0 millisecond section ****************************
;============================================================================


;****************************************************************************
; - Check the value of the contact de-bounce counter variables, if other
;   than zero, decrement them.
;****************************************************************************

     lda     Sw0DB              ; Load accumulator with value in "Sw0DB"
                                ; variable
     beq     Sw0DB_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; Sw0DB_CHK_DONE:
     dec     Sw0DB              ; Decrement "Sw0DB" variable

Sw0DB_CHK_DONE:

     lda     Sw1DB              ; Load accumulator with value in "Sw1DB"
                                ; variable
     beq     Sw1DB_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; Sw1DB_CHK_DONE:
     dec     Sw1DB              ; Decrement "Sw1DB" variable

Sw1DB_CHK_DONE:

     lda     Sw2DB              ; Load accumulator with value in "Sw2DB"
                                ; variable
     beq     Sw2DB_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; Sw2DB_CHK_DONE:
     dec     Sw2DB              ; Decrement "Sw2DB" variable

Sw2DB_CHK_DONE:

     lda     Sw3DB              ; Load accumulator with value in "Sw3DB"
                                ; variable
     beq     Sw3DB_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; Sw3DB_CHK_DONE:
     dec     Sw3DB              ; Decrement "Sw3DB" variable

Sw3DB_CHK_DONE:


;****************************************************************************
; - Increment millisecond counter
;****************************************************************************

INC_mS:
     inc     mS                  ; Increment Millisecond counter
     lda     mS                  ; Load accumulator with value in
                                 ; Millisecond counter
     cmp     #$05                ; Compare it with decimal 5
     bne     TIM2CH0_ISR_DONE    ; If the Z bit of CCR is clear,
                                 ; branch to TIM2CH0_ISR_DONE:

;============================================================================
;************************** 5 Millisecond section ***************************
;============================================================================

;****************************************************************************
; - Check the value of the contact auto-repeat command counter variables,
;   if other than zero, decrement them.
;****************************************************************************

     lda     Sw0ARC             ; Load accumulator with value in "Sw0ARC"
                                ; variable
     beq     SW0ARC_CHK_DONE    ; If "Z" bit of "CCR is set, branch to
                                ; SW0ARC_CHK_DONE:
     dec     Sw0ARC             ; Decrement "Sw0ARC" variable

SW0ARC_CHK_DONE:

     lda     Sw1ARC             ; Load accumulator with value in "Sw1ARC"
                                ; variable
     beq     SW1ARC_CHK_DONE    ; If "Z" bit of "CCR is set, branch to
                                ; SW1ARC_CHK_DONE:
     dec     Sw1ARC             ; Decrement "Sw1ARC" variable

SW1ARC_CHK_DONE:

     lda     Sw2ARC             ; Load accumulator with value in "Sw2ARC"
                                ; variable
     beq     SW2ARC_CHK_DONE    ; If "Z" bit of "CCR is set, branch to
                                ; SW2ARC_CHK_DONE:
     dec     Sw2ARC             ; Decrement "Sw2ARC" variable

SW2ARC_CHK_DONE:

     lda     Sw3ARC             ; Load accumulator with value in "Sw3ARC"
                                ; variable
     beq     SW3ARC_CHK_DONE    ; If "Z" bit of "CCR is set, branch to
                                ; SW3ARC_CHK_DONE:
     dec     Sw3ARC             ; Decrement "Sw3ARC" variable

SW3ARC_CHK_DONE:


;****************************************************************************
; - Check the value of the contact auto-repeat counter variables, if other
;   than zero, decrement them.
;****************************************************************************

     lda     Sw0AR              ; Load accumulator with value in "Sw0AR"
                                ; variable
     beq     SW0AR_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; SW0AR_CHK_DONE:
     dec     Sw0AR              ; Decrement "Sw0AR" variable

SW0AR_CHK_DONE:

     lda     Sw1AR              ; Load accumulator with value in "Sw1AR"
                                ; variable
     beq     SW1AR_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; SW1AR_CHK_DONE:
     dec     Sw1AR              ; Decrement "Sw1AR" variable

SW1AR_CHK_DONE:

     lda     Sw2AR              ; Load accumulator with value in "Sw2AR"
                                ; variable
     beq     SW2AR_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; SW2AR_CHK_DONE:
     dec     Sw2AR              ; Decrement "Sw2AR" variable

SW2AR_CHK_DONE:

     lda     Sw3AR              ; Load accumulator with value in "Sw3AR"
                                ; variable
     beq     SW3AR_CHK_DONE     ; If "Z" bit of "CCR is set, branch to
                                ; SW3AR_CHK_DONE:
     dec     Sw3AR              ; Decrement "Sw3AR" variable

SW3AR_CHK_DONE:


;****************************************************************************
; - Increment 5 millisecond counter
;****************************************************************************

INC_mSx5:
     clr     mS                  ; Clear Millisecond counter
     inc     mSx5                ; Increment 5 Millisecond counter
     lda     mSx5                ; Load accumulator with value in
                                 ; 5 Millesecond counter
     cmp     #$32                ; Compare it with decimal 50
     bne     TIM2CH0_ISR_DONE    ; If the Z bit of CCR is clear,
                                 ; branch to TIM2CH0_ISR_DONE:

;============================================================================
;************************* 250 Millisecond section **************************
;============================================================================


;***************************************************************************
; - If we are in display mode, and in any of the real time display screens,
;   send a command byte to MS_ECU to update the real time variables.
;***************************************************************************

     brset   mde,flags,UPDATE_DONE     ; If "mde" bit of "flags" varialbe
                                       ; is set, branch to UPDATE_DONE:
                                       ;(We are in "Configure" mode)
     lda     ScrnCnt                   ; Load accumulator with value in
                                       ; "ScrnCnt" variable
     cmp     #$07                      ; Compare with decimal 7(Last of
                                       ; the real time display screens)
     bhi     UPDATE_DONE               ; If (A)>($07), branch to
                                       ; UPDATE_DONE:

;***************************************************************************
; - Send the letter 'A' command to update the real time variables.
;***************************************************************************

     lda     SCS1                    ; Load accumulator with value in SCI
                                     ; Control Register 1
                                     ;(Clear transmitter empty bit)
                                     ;(Clears all by read)
     mov     #'A',SCDR               ; Move ASCII'A' to SCI Data Register
                                     ;(Transmitter is running, so data
                                     ; shift starts now!)
     clr     ByteCnt                 ; Clear "ByteCnt" variable
     mov     #$22,ByteGoal           ; Move decimal 34 into "ByteGoal"
                                     ;(one more than the number of real
                                     ; time variables for display (33)

;**************************************************************************
; - Enable receiver full interrupt.
;**************************************************************************

     bset    SCRIE,SCC2     ; Set "SCRIE" bit of SCI Control Register 2
                            ;(SCRF enabled to generate CPU Interrupt)

UPDATE_DONE:
     clr     mSx5           ; Clear 5 Millisecond counter

TIM2CH0_ISR_DONE:
     pulh                  ; Pull value from stack to index register Hi byte
     rti                   ; Return from interrupt


;***************************************************************************
;
; ---------------- MS_ECU Serial Communications Interface -----------------
;
; Communications are established when a command character is sent, the
; particular character sets the mode:
;
; "A" = Receive realtime variables via txport.(36 bytes)(MS->MV)
; "V" = Receive the VE table and constants via txport (128 bytes)(MS->MV)
; "W"+delay+<offset>+delay+<new byte> = Send new VE table or constant
;                          byte value and store in offset location(MV->MS)
; "B" = Jump to flash burner routine and burn VE table and constants,
;       and ST table and constants values in MS_ECU RAM into flash ROM
; "I" = Receive the ST table and constants via txport (80 bytes)(MS->MV)
; "J"+delay+<offset>+delay+<new byte> = Send new ST table or constant
;                          byte value and store in offset location(MV->MS)
;
;***************************************************************************

;***************************************************************************
;===========================================================================
; - SCI Receive Interrupt
;===========================================================================
;***************************************************************************

;***************************************************************************
; - Enter here when have received RS 232 byte
;   (SCRF bit of SCS1 set)
;***************************************************************************

SCIRCV_ISR:
     pshh                 ; Push value in index register Hi byte to Stack

;***************************************************************************
; - Clear status register to allow next interrupt
;***************************************************************************

     lda     SCS1     ; Load accumulator with value in SCI Register 1

;***************************************************************************
; - Transfer received byte from register to buffer
;***************************************************************************

     lda     SCDR        ; Load accumulator with value in SCI Data Register
     sta     readbuf     ; Copy to "readbuf" variable

;***************************************************************************
; - Check to see what mode we are in, and branch accordingly
;***************************************************************************

     brset   mde,flags,RCVNG_CON   ; If "mde" bit of "flags" variable is
                                   ; set, branch to RCVNG_CON:
                                   ;(in Config mode)

;***************************************************************************
; - We are in "Display" mode, transfer received byte from buffer to real
;   time variable.
;***************************************************************************

RCVNG_VAR:
     ldx     ByteCnt           ; Load index register Lo byte with value in
                               ; "ByteCnt" variable
     clrh                      ; Clear index register hi byte
     lda     readbuf           ; Load accumulator with value in "readbuf"
     sta     SecH,x            ; Copy to address at "SecH", offset in index
                               ; register Lo byte
     bra     NEXT_RCV_BYTE     ; Branch to NEXT_RCV_BYTE:


;***************************************************************************
; - We are in "Configure" mode. Check the "flags" variable to determine
;   where the received bytes should go.
;***************************************************************************

RCVNG_CON:
     brset   RcvG1,flags,RCVNG_G1      ; If "RcvG1" bit of "flags" variable
                                       ; is set, branch to RCVNG_G1:
     brset   RcvG2,flags,RCVNG_G2      ; If "RcvG2" bit of "flags" variable
                                       ; is set, branch to RCVNG_G2:
     jmp     SCIRCV_ISR_DONE           ; Jump to SCIRCV_ISR_DONE:
                                       ;(Sanity check)

;***************************************************************************
; - We are receiving data from the Cons Grp1. Transfer received byte from
;   buffer to configurable constant.
;***************************************************************************

RCVNG_G1:
     ldx     ByteCnt          ; Load index register Lo byte with value in
                              ; "ByteCnt" variable
     clrh                     ; Clear index register hi byte
     lda     readbuf          ; Load accumulator with value in "readbuf"
     sta     TO_0_0,x         ; Copy to address at "TO_0_0", offset in
                              ; index register Lo byte

     bra     NEXT_RCV_BYTE    ; Branch to NEXT_RCV_BYTE:

;***************************************************************************
; - We are receiving data from Cons Grp2. Transfer received byte from
;   buffer to configurable constant.
;***************************************************************************

RCVNG_G2:
     ldx     ByteCnt          ; Load index register Lo byte with value in
                              ; "ByteCnt" variable
     clrh                     ; Clear index register hi byte
     lda     readbuf          ; Load accumulator with value in "readbuf"
     sta     EPC_TCC,x        ; Copy to address at "EPC_TCC", offset in
                              ; index register Lo byte

NEXT_RCV_BYTE:
     inc     ByteCnt          ; Increment value in "ByteCnt"(ByteCnt=ByteCnt+1)
     lda     ByteCnt          ; Load accumulator w3ith value in "ByteCnt"
     cmp     ByteGoal         ; Compare value in accumulator (ByteCnt")to
                              ; value in "ByteGoal" variable
     bls     SCIRCV_ISR_DONE  ; If C or Z bits of CCR are set,(A<=M),
                              ; branch to SCIRCV_ISR_DONE:

;***************************************************************************
; - Done receiving - kill receive interrupt enable
;***************************************************************************

     clr     ByteCnt           ; Clear "ByteCnt" variable
     bclr    SCRIE,SCC2        ; Clear "SCRIE" bit of SCI Control Register 2
                               ;(SCRF not enabled to generate CPU interrupt)

SCIRCV_ISR_DONE:
     pulh                ; Pull value from stack to index register Hi byte
     rti                 ; Return from interrupt


;**************************************************************************
;==========================================================================
; - SCI Transmit Interrupt
;==========================================================================
;**************************************************************************

;**************************************************************************
; - Enter here when the RS232 transmit buffer is empty
;   (SCTE bit of SCS1 is set)(Not used)
;**************************************************************************

SCITX_ISR:
     rti                ; Return from interrupt


;**************************************************************************
;==========================================================================
;- Dummy ISR vector ( This should never be called, but, just in case.)
;==========================================================================
;**************************************************************************

Dummy:
     rti     ; Return from interrupt


;***************************************************************************
;
; ---------------------------- SUBROUTINES --------------------------------
;
;  - SW0_CHK
;  - SW1_CHK
;  - SW2_CHK
;  - SW3_CHK
;  - DELAY300
;  - BUTTON_WAIT
;  - PRNT_TOPLN_DSP
;  - LOAD_SPACE
;  - UPDATE_CON
;  - CONV_8BIT_ASCII
;  - LOAD_1ST_3
;  - LOAD_2ND_3
;  - LOAD_3D_3
;  - LOAD_4TH_3
;  - LOAD_5TH_3
;  - PRINT_LINE
;  - CHANGE_MODE
;  - GET_VECT_ADDR
;  - ADD_A_TO_HX
;  - LDA_W_HX_PL_A
;  - VFD_START_TOP
;  - VFD_START_BOT
;  - VFD_SEND
;  - Long Delay(for VFD instruction/data transfer)
;  - Short Delay(for VFD instruction/data transfer)
;  - VFD Display
;  - CMP_BOTLIN
;  - Ordered Table Search
;  - Linear Interpolation
;  - 32 x 16 divide
;  - Round after division
;  - 16 x 16 multiply
;***************************************************************************


;****************************************************************************
; - This subroutine checks the state of the Display Scroll Left / Decrease
;   Selected Variable button on PTA0 and updates the switch status flag.
;   The switch status flag is cleared every pass through the main loop after
;   the routine relevent to that flag is completed.
;   Edge detection is provided from both open to closed, and closed to open.
;   Auto-repeat at 2HZ is commanded as long as the contacts remain closed
;   for a period of 1 second or more.
;   Auto-repeat is prevented in the open state.
;****************************************************************************

SW0_CHK:
     lda     Sw0DB                ; Load accumulator with value in Switch
                                  ; #0 de-bounce counter variable
     bne     SW0_CHK_DONE         ; If Z bit of CCR is clear, branch to
                                  ; SW0_CHK_DONE: ("Sw0DB" not = 0,
                                  ; de-bounce in progress, skip over)
     brset   Sw0,porta,SW0_OPN    ; If "Sw0" bit of Port A is set,(Hi)
                                  ; branch to Sw0_OPN: (contacts are open)
     brset   Sw0LP,LPflags,SW0_ARC_CHK  ; If "Sw0LP" bit of "LPflags"
                             ; variable is set, branch to SW0_ARC_CHK:
                             ; (contacts closed, bit is already set,
                             ; check for auto-repeat command)
     mov     #$64,Sw0DB      ; Move decimal 100 into Switch #0
                             ; de-bounce counter variable (100mS)
     bset    Sw0LP,LPflags   ; Set "Sw0LP" bit of "LPflags" variable
     jmp     SW0_CLS         ; Jump to SW0_CLS:

SW0_ARC_CHK:
     brset   Sw0LP,ARCflags,SW0_ARC_PROG  ; If "Sw0LP" bit of "ARCflags"
                             ; variable is set, branch to SW0_ARC_PROG:
                             ;(auto-repeat command check in progress)
     mov     #$C8,Sw0ARC     ; Move decimal 200 into Switch #0
                             ; auto-repeat command counter variable(1Sec)
     bset    Sw0LP,ARCflags  ; Set "Sw0LP" bit of "ARCflags" variable
     jmp     SW0_CHK_DONE    ; Jump to SW0_CHK_DONE:

SW0_ARC_PROG:
     lda     Sw0ARC              ; Load accumulator with value in Switch
                                 ; #0 auto repeat command timer counter
     bne     SW0_CHK_DONE        ; If Z bit of CCR is clear, branch to
                                 ; SW0_CHK_DONE: ("Sw0ARC" not = 0,
                                 ; auto-repeat command check in progress,
                                 ; skip over)
     brset   Sw0LP,ARflags,SW0_AR_PROG   ; If "Sw0LP" bit of "ARflags"
                                 ; variable is set, branch to SW0_AR_PROG:
                                 ;(auto-repeat check in progress)
     mov     #$64,Sw0AR          ; Move decimal 100 into Contact Set #0
                                 ; auto-repeat counter variable(500mS)
     bset    Sw0LP,ARflags       ; Set "Sw0LP" bit of "ARflags" variable

SW0_AR_PROG:
     lda     Sw0AR               ; Load accumulator with value in Contact
                                 ; Set #0 auto repeat timer counter var
     bne     SW0_CHK_DONE        ; If Z bit of CCR is clear, branch to
                                 ; SW0_CHK_DONE: ("Sw0DB" not = 0,
                                 ; auto-repeat check in progress,
                                 ; skip over)
SW0_CLS:
     bset    Sw0cls,Swflags      ; Set "Sw0cls" bit of "Swflags" variable
     bclr    Sw0LP,ARflags       ; Clear "Sw0LP" bit of "ARflags" variable
     jmp     SW0_CHK_DONE        ; Jump to SW0_CHK_DONE:

SW0_OPN:
     brclr   Sw0LP,LPflags,SW0_CHK_DONE  ; If "Sw0LP" bit of "LPflags"
                              ; variable is clear, branch to SW0_CHK_DONE:
                              ; (contact set open, and bit is already
                              ; clear, so skip over)
     mov     #$64,Sw0DB       ; Move decimal 100 into Contact Set #0
                              ; de-bounce counter variable (100mS)
     bclr    Sw0LP,LPflags    ; Clear "Sw0LP" bit of "LPflags" variable
     clr     Sw0AR            ; Clear Sw0 auto-repeat timer counter
     bclr    Sw0LP,ARflags    ; Clear "Sw0LP" bit of "ARflags" variable
     clr     Sw0ARC           ; Clear "Sw0" auto-repeat command timer counter
     bclr    Sw0LP,ARCflags   ; Clear "Sw0LP" bit of "ARCflags" variable
     bclr    Sw0cls,Swflags   ; Clear "Sw0cls" bit of "Swflags" variable

SW0_CHK_DONE:
     rts                      ; Return from subroutine


;****************************************************************************
; - This subroutine checks the state of the Display Scroll Right / Increase
;   Selected Variable button on PTA1 and updates the switch status flag.
;   The switch status flag is cleared every pass through the main loop after
;   the routine relevent to that flag is completed.
;   Edge detection is provided from both open to closed, and closed to open.
;   Auto-repeat at 2HZ is commanded as long as the contacts remain closed
;   for a period of 1 second or more.
;   Auto-repeat is prevented in the open state.
;****************************************************************************

SW1_CHK:
     lda     Sw1DB                ; Load accumulator with value in Switch
                                  ; #1 de-bounce counter variable
     bne     SW1_CHK_DONE         ; If Z bit of CCR is clear, branch to
                                  ; SW1_CHK_DONE: ("Sw0DB" not = 0,
                                  ; de-bounce in progress, skip over)
     brset   Sw1,porta,SW1_OPN    ; If "Sw1" bit of Port A is set,(Hi)
                                  ; branch to Sw1_OPN: (contacts are open)
     brset   Sw1LP,LPflags,SW1_ARC_CHK  ; If "Sw1LP" bit of "LPflags"
                             ; variable is set, branch to SW1_ARC_CHK:
                             ; (contacts closed, bit is already set,
                             ; check for auto-repeat command)
     mov     #$64,Sw1DB      ; Move decimal 100 into Switch #1
                             ; de-bounce counter variable (100mS)
     bset    Sw1LP,LPflags   ; Set "Sw1LP" bit of "LPflags" variable
     jmp     SW1_CLS         ; Jump to SW1_CLS:

SW1_ARC_CHK:
     brset   Sw1LP,ARCflags,SW1_ARC_PROG  ; If "Sw1LP" bit of "ARCflags"
                             ; variable is set, branch to SW1_ARC_PROG:
                             ;(auto-repeat command check in progress)
     mov     #$C8,Sw1ARC     ; Move decimal 200 into Switch #1
                             ; auto-repeat command counter variable(1Sec)
     bset    Sw1LP,ARCflags  ; Set "Sw1LP" bit of "ARCflags" variable
     jmp     SW1_CHK_DONE    ; Jump to SW1_CHK_DONE:

SW1_ARC_PROG:
     lda     Sw1ARC              ; Load accumulator with value in Switch
                                 ; #0 auto repeat command timer counter
     bne     SW1_CHK_DONE        ; If Z bit of CCR is clear, branch to
                                 ; SW1_CHK_DONE: ("Sw1ARC" not = 0,
                                 ; auto-repeat command check in progress,
                                 ; skip over)
     brset   Sw1LP,ARflags,SW1_AR_PROG   ; If "Sw1LP" bit of "ARflags"
                                 ; variable is set, branch to SW1_AR_PROG:
                                 ;(auto-repeat check in progress)
     mov     #$64,Sw1AR          ; Move decimal 100 into Contact Set #1
                                 ; auto-repeat counter variable(500mS)
     bset    Sw1LP,ARflags       ; Set "Sw1LP" bit of "ARflags" variable

SW1_AR_PROG:
     lda     Sw1AR               ; Load accumulator with value in Contact
                                 ; Set #1 auto repeat timer counter var
     bne     SW1_CHK_DONE        ; If Z bit of CCR is clear, branch to
                                 ; SW1_CHK_DONE: ("Sw1DB" not = 0,
                                 ; auto-repeat check in progress,
                                 ; skip over)
SW1_CLS:
     bset    Sw1cls,Swflags      ; Set "Sw1cls" bit of "Swflags" variable
     bclr    Sw1LP,ARflags       ; Clear "Sw1LP" bit of "ARflags" variable
     jmp     SW1_CHK_DONE        ; Jump to SW1_CHK_DONE:

SW1_OPN:
     brclr   Sw1LP,LPflags,SW1_CHK_DONE  ; If "Sw1LP" bit of "LPflags"
                              ; variable is clear, branch to SW1_CHK_DONE:
                              ; (contact set open, and bit is already
                              ; clear, so skip over)
     mov     #$64,Sw1DB       ; Move decimal 100 into Contact Set #1
                              ; de-bounce counter variable (100mS)
     bclr    Sw1LP,LPflags    ; Clear "Sw1LP" bit of "LPflags" variable
     clr     Sw1AR            ; Clear "Sw1" auto-repeat timer counter
     bclr    Sw1LP,ARflags    ; Clear "Sw1LP" bit of "ARflags" variable
     clr     Sw1ARC           ; Clear "Sw1" auto-repeat command timer counter
     bclr    Sw1LP,ARCflags   ; Clear "Sw1LP" bit of "ARCflags" variable
     bclr    Sw1cls,Swflags   ; Clear "Sw1cls" bit of "Swflags" variable

SW1_CHK_DONE:
     rts                      ; Return from subroutine


;****************************************************************************
; - This subroutine checks the state of the Display Freeze / Select
;   Configuration variable button on PTA2 and updates the switch status flag.
;   The switch status flag is cleared every pass through the main loop after
;   the routine relevent to that flag is completed.
;   Edge detection is provided from both open to closed, and closed to open.
;   Auto-repeat is prevented in both states.
;****************************************************************************

SW2_CHK:
     lda     Sw2DB                ; Load accumulator with value in Switch
                                  ; #2 de-bounce counter variable
     bne     SW2_CHK_DONE         ; If Z bit of CCR is clear, branch to
                                  ; SW2_CHK_DONE: ("Sw2DB" not = 0,
                                  ; de-bounce in progress, skip over)
     brset   Sw2,porta,SW2_OPN    ; If "Sw2" bit of Port A is set,(Hi)
                                  ; branch to SW2_OPN: (contacts are open)
     brset   Sw2LP,LPflags,SW2_CHK_DONE  ; If "Sw2LP" bit of "LPflags"
                              ; variable is set, branch to SW2_CHK_DONE:
                              ;(contacts are closed, but bit is already
                              ; set, so skip over)
     mov     #$64,Sw2DB       ; Move decimal 100 into Switch #2
                              ; de-bounce counter variable (100mS)
     bset    Sw2LP,LPflags    ; Set "Sw2LP" bit of "LPflags" variable
     bset    Sw2cls,Swflags   ; Set "Sw2cls" bit of "Swflags" variable
     bra     SW2_CHK_DONE     ; Branch to SW2_CHK_DONE:

SW2_OPN:
     brclr   Sw2LP,LPflags,SW2_CHK_DONE  ; If "Sw2LP" bit of "LPflags"
                              ; variable is clear, branch to SW2_CHK_DONE:
                              ; (contacts are open, but bit is already
                              ; clear, so skip over)
     mov     #$64,Sw2DB       ; Move decimal 100 into Switch #2
                              ; de-bounce counter variable (100mS)
     bclr    Sw2LP,LPflags    ; Clear "Sw2LP" bit of "LPflags" variable
     bclr    Sw2cls,Swflags   ; Clear "Sw2cls" bit of "Swflags" variable

SW2_CHK_DONE:
     rts                      ; Return from subroutine


;****************************************************************************
; - This subroutine checks the state of the Toggle Mode, Display /
;   Configure button on PTA3 and updates the switch status flag.
;   The switch status flag is cleared every pass through the main loop after
;   the routine relevent to that flag is completed.
;   Edge detection is provided from both open to closed, and closed to open.
;   Auto-repeat is prevented in both states.
;****************************************************************************

SW3_CHK:
     lda     Sw3DB                ; Load accumulator with value in Switch
                                  ; #3 de-bounce counter variable
     bne     SW3_CHK_DONE         ; If Z bit of CCR is clear, branch to
                                  ; SW3_CHK_DONE: ("Sw3DB" not = 0,
                                  ; de-bounce in progress, skip over)
     brset   Sw3,porta,SW3_OPN    ; If "Sw3" bit of Port A is set,(Hi)
                                  ; branch to SW3_OPN: (contacts are open)
     brset   Sw3LP,LPflags,SW3_CHK_DONE  ; If "Sw3LP" bit of "LPflags"
                              ; variable is set, branch to SW3_CHK_DONE:
                              ;(contacts are closed, but bit is already
                              ; set, so skip over)
     mov     #$64,Sw3DB       ; Move decimal 100 into Switch #3
                              ; de-bounce counter variable (100mS)
     bset    Sw3LP,LPflags    ; Set "Sw3LP" bit of "LPflags" variable
     bset    Sw3cls,Swflags   ; Set "Sw3cls" bit of "Swflags" variable
     bra     SW3_CHK_DONE     ; Branch to SW3_CHK_DONE:

SW3_OPN:
     brclr   Sw3LP,LPflags,SW3_CHK_DONE  ; If "Sw3LP" bit of "LPflags"
                              ; variable is clear, branch to SW3_CHK_DONE:
                              ; (contacts are open, but bit is already
                              ; clear, so skip over)
     mov     #$64,Sw3DB       ; Move decimal 100 into Switch #3
                              ; de-bounce counter variable (100mS)
     bclr    Sw3LP,LPflags    ; Clear "Sw3LP" bit of "LPflags" variable
     bclr    Sw3cls,Swflags   ; Clear "Sw3cls" bit of "Swflags" variable

SW3_CHK_DONE:
     rts                      ; Return from subroutine


;***************************************************************************
; - This subroutine is a ~300mS delay used at start up for power
;   stabilization and between transmit bytes for downloading VE and ST
;   constants.
;***************************************************************************

DELAY300:
     clr     tmp1     ; Clear tmp1 variable

WAIT_1:
     clr     tmp2     ; Clear tmp2 variable

WAIT_2:
     clr     tmp3     ; Clear tmp3 variable

WAIT_3:
     lda     tmp3     ; Load accumulator with value in tmp3
     inca             ; Increment value in accumulator
     sta     tmp3     ; Copy to tmp3
     cmp     #$C8     ; Compare value in accumulator with decimal 200
     blo     WAIT_3   ; If C bit of CCR is set, (A<M), branch to WAIT_3:
     lda     tmp2     ; Load accumulator with value in tmp2
     inca             ; Increment value in accumulator
     sta     tmp2     ; Copy to tmp2
     cmp     #$C8     ; Compare value in accumulator with decimal 200
     blo     WAIT_2   ; If C bit of CCR is set, (A<M), branch to WAIT_2:
     lda     tmp1     ; Load accumulator with value in tmp1
     inca             ; Increment value in accumulator
     sta     tmp1     ; Copy to tmp1
     cmp     #$05     ; Compare value in accumulator with decimal 5
     blo     WAIT_1   ; If C bit of CCR is set, (A<M), branch to WAIT_1:
     rts              ; Return from subroutine


;***************************************************************************
; -  This subroutine is a loop, waiting for the prompted press of the
;    Display/Configure button.
;***************************************************************************

BUTTON_WAIT:
;***************************************************************************
; -  Wait for first button press return.
;***************************************************************************

BTN_WAIT1:
     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brset   Sw3cls,Swflags,BTN_WAIT1  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is set, branch to
                                       ; BTN_WAIT1
                                       ;(Toggle Mode button is still
                                       ; pressed, loop back)

;***************************************************************************
; -  Wait for second button press.
;***************************************************************************

BTN_WAIT2:
     jsr     SW3_CHK                   ; Jump to subroutine at SW3_CHK:
                                       ;(Check he state of the Toggle Mode,
                                       ; Display / Configure button
                                       ; on PTA3)

     brclr   Sw3cls,Swflags,BTN_WAIT2  ; If "Sw3cls" bit of "Swflags"
                                       ; variable is clear, branch to
                                       ; BTN_WAIT1
                                       ;(Toggle Mode button is still
                                       ; not pressed, loop back)
     rts                               ; Return from subroutine


;****************************************************************************
; - This subroutine prints the top line of the VFD while in "Display" mode
;****************************************************************************

PRNT_TOPLN_DSP:

;****************************************************************************
; - Set up the VFD to place the first character in the top line, extreme
;   left hand position
;****************************************************************************

     jsr     VFD_START_TOP     ; Jump to subroutine at VFD_START_TOP:

;***************************************************************************
; - Using the Variables Top Line Table Index vector table, and the "ScrnCnt"
;   offset value, load H:X with the address of the desired Variables Top
;   Line Table.
;***************************************************************************

     ldhx    #VARS_TL_TB_IND    ; Load index register with the address of
                                ; the first value in the Variables Top Line
                                ; Table Index vector table
     lda     ScrnCnt            ; Load accumulator with the value in "ScrnCnt"
     jsr     GET_VECT_ADDR      ; Jump to subroutine at GET_VECT_ADDR:

;***************************************************************************
; - Print the top line of the VFD display
;***************************************************************************

     jsr     PRINT_LINE         ; Jump to subroutine at PRINT_LINE:
     rts                        ; Return from subroutine


;***************************************************************************
; - This subroutine initializes bottom line of the VFD with blank spaces
;***************************************************************************

LOAD_SPACE:
     lda     #$20         ; Load accumulator with ASCII ' '(space)
     sta     BotLin0      ; Copy to "BotLin0" variable
     sta     BotLin1      ; Copy to "BotLin1" variable
     sta     BotLin2      ; Copy to "BotLin2" variable
     sta     BotLin3      ; Copy to "BotLin3" variable
     sta     BotLin4      ; Copy to "BotLin4" variable
     sta     BotLin5      ; Copy to "BotLin5" variable
     sta     BotLin6      ; Copy to "BotLin6" variable
     sta     BotLin7      ; Copy to "BotLin7" variable
     sta     BotLin8      ; Copy to "BotLin8" variable
     sta     BotLin9      ; Copy to "BotLin9" variable
     sta     BotLin10     ; Copy to "BotLin10" variable
     sta     BotLin11     ; Copy to "BotLin11" variable
     sta     BotLin12     ; Copy to "BotLin12" variable
     sta     BotLin13     ; Copy to "BotLin13" variable
     sta     BotLin14     ; Copy to "BotLin14" variable
     sta     BotLin15     ; Copy to "BotLin15" variable
     sta     BotLin16     ; Copy to "BotLin16" variable
     sta     BotLin17     ; Copy to "BotLin17" variable
     sta     BotLin18     ; Copy to "BotLin18" variable
     sta     BotLin19     ; Copy to "BotLin19" variable
     rts                  ; Return from subroutine

;***************************************************************************
; - This subroutine updates the value in the current selected constant.
;   the current constant is selected, and saved as "ConVal". Check if we
;   should increment it, decrement it, or leave it as is.
;***************************************************************************

UPDATE_CON:
     brset   Sw0cls,Swflags,DECREMENT  ;If "Sw0cls"bit of "Swflags" variable
                                       ; is set, branch to DECREMENT:
                                       ;(Scroll Left/Decrement button is
                                       ; pressed)
     brset   Sw1cls,Swflags,INCREMENT  ;If "Sw1cls"bit of "Swflags" variable
                                       ; is set, branch to INCREMENT:
                                       ;(Scroll Right/Increment button is
                                       ; pressed)
CHK_CHNG_DONE:
     jmp     UPDATE_CON_DONE           ; Jump to UPDATE_CON_DONE:

INCREMENT:

;****************************************************************************
; - Increment the Constant value.
;****************************************************************************

INC_CON:
     inc     ConVal              ; Increment "Conval" variable

INC_DONE:
     bclr    Sw1cls,Swflags      ; Clear "Sw1cls" bit of "Swflags" variable
     jmp     UPDATE_CON_DONE     ; Jump to UPDATE_CON_DONE:


DECREMENT:

;****************************************************************************
; - Decrement the Constant value.
;****************************************************************************

DEC_CON:
     dec     ConVal              ; Decrement "ConVal" variable

DEC_DONE:
     bclr    Sw0cls,Swflags      ; Clear "Sw0cls" bit of "Swflags" variable

UPDATE_CON_DONE:
     rts                         ; Return from subroutine


;****************************************************************************
; - This subroutine takes a byte value in the accumulator, transfers it to
;   the index register Lo byte, and converts it to a 3 variable string,
;   stored temporarily in variables "AC_100", AC_10", and "AC_1"
;****************************************************************************

CONV_8BIT_ASCII:
     clrh                      ; Clear index register hi byte
     tax                       ; Transfer value in accumulator to index
                               ; register Lo byte(8 bit value)
     lda     ASCII_CONV_100,x  ; Load accumulator with value in
                               ; ASCII_CONV_100 table, offset in index
                               ; register Lo byte(ASCII 100s value)
     sta     AC_100            ; Copy to "AC_100" variable
     lda     ASCII_CONV_10,x   ; Load accumulator with value in
                               ; ASCII_CONV_10 table, offset in index
                               ; register Lo byte(ASCII 10s value)
     sta     AC_10             ; Copy to "AC_10" variable
     lda     ASCII_CONV_1,x    ; Load accumulator with value in
                               ; ASCII_CONV_1 table, offset in index
                               ; register Lo byte(ASCII 1s value)
     sta     AC_1              ; Copy to "AC_1" variable
     rts                       ; Return from subroutine


;****************************************************************************
; - This subroutine loads the over-write values to the bottom line string,
;   first 3 columns.
;****************************************************************************

LOAD_1ST_3:
     lda     AC_100     ; Load accumulator with value in "AC_100"(100s col)
     sta     BotLin0    ; Copy to "BotLin0"(1st column on left, bottom line)
     lda     AC_10      ; Load accumulator with value in "AC_10"(10s col)
     sta     BotLin1    ; Copy to "BotLin1"(2nd column on left, bottom line)
     lda     AC_1       ; Load accumulator with value in "AC_1"(1s col)
     sta     BotLin2    ; Copy to "BotLin2"(3d column on left, bottom line)
     rts                ; Return from subroutine

;****************************************************************************
; - This subroutine loads the over-write values to the bottom line string,
;   second 3 columns.
;****************************************************************************

LOAD_2ND_3:
     lda     AC_100     ; Load accumulator with value in "AC_100"(100s col)
     sta     BotLin4    ; Copy to "BotLin4"(5th column on left, bottom line)
     lda     AC_10      ; Load accumulator with value in "AC_10"(10s col)
     sta     BotLin5    ; Copy to "BotLin5"(6th column on left, bottom line)
     lda     AC_1       ; Load accumulator with value in "AC_1"(1s col)
     sta     BotLin6    ; Copy to "BotLin6"(7th column on left, bottom line)
     rts                ; Return from subroutine

;****************************************************************************
; - This subroutine loads the over-write values to the bottom line string,
;   third 3 columns.
;****************************************************************************

LOAD_3D_3:
     lda     AC_100     ; Load accumulator with value in "AC_100"(100s col)
     sta     BotLin8    ; Copy to "BotLin8"(9th column on left, bottom line)
     lda     AC_10      ; Load accumulator with value in "AC_10"(10s col)
     sta     BotLin9    ; Copy to "BotLin9"(10th column on left, bottom line)
     lda     AC_1       ; Load accumulator with value in "AC_1"(1s col)
     sta     BotLin10   ; Copy to "BotLin10"(11th column on left, bottom line)
     rts                ; Return from subroutine

;****************************************************************************
; - This subroutine loads the over-write values to the bottom line string,
;   forth 3 columns.
;****************************************************************************

LOAD_4TH_3:
     lda     AC_100     ; Load accumulator with value in "AC_100"(100s col)
     sta     BotLin12   ; Copy to "BotLin12"(13th column on left, bottom line)
     lda     AC_10      ; Load accumulator with value in "AC_10"(10s col)
     sta     BotLin13   ; Copy to "BotLin13"(14th column on left, bottom line)
     lda     AC_1       ; Load accumulator with value in "AC_1"(1s col)
     sta     BotLin14   ; Copy to "BotLin14"(15th column on left, bottom line)
     rts                ; Return from subroutine

;****************************************************************************
; - This subroutine loads the over-write values to the bottom line string,
;   fifth 3 columns.
;****************************************************************************

LOAD_5TH_3:
     lda     AC_100     ; Load accumulator with value in "AC_100"(100s col)
     sta     BotLin16   ; Copy to "BotLin16"(17th column on left, bottom line)
     lda     AC_10      ; Load accumulator with value in "AC_10"(10s col)
     sta     BotLin17   ; Copy to "BotLin17"(18th column on left, bottom line)
     lda     AC_1       ; Load accumulator with value in "AC_1"(1s col)
     sta     BotLin18   ; Copy to "BotLin18"(19th column on left, bottom line)
     rts                ; Return from subroutine

;***************************************************************************
; - This subroutine takes the address of the desired Line Table loaded
;   in H:X. Using the value in "ColNum" offset value, load the "value"
;   variable with the contents of the appropriate ASCCI value in the table
;   and display them on the top line of the VFD.
;***************************************************************************

PRINT_LINE:
     clr     ColNum            ; Clear "ColNum" variable
                               ;(ColNum = 0 = 1st column on left)
     lda     ColNum            ; Load accumulator with value in "ColNum"

NEXT_CHAR:
     jsr     LDA_W_HX_PL_A     ; Jump to subroutine at LDA_W_HX_PL_A:
     sta     value             ; Copy to "value" variable
     jsr     VFD_SEND          ; Jump to subroutine at VFD_SEND:
     inc     ColNum            ; Increment "ColNum" (ColNum=ColNum+1)
     lda     ColNum            ; Load accumulator with value in "ColNum"
     cmp     #$14              ; Compare (A) with decimal 20
     beq     CHARS_DONE        ; If Z bit of CCR is set, branch to
                               ; CHARS_DONE:
                               ;(finished sending all display characters)
     bra     NEXT_CHAR         ; Branch to NEXT_CHAR:

CHARS_DONE:
     rts                       ; Return from subroutine


;****************************************************************************
; - This subroutine toggles "mde" bit of "flags" variable whenever
;   "Toggle Mode" button is pressed.
;****************************************************************************

CHANGE_MODE:
     com     ModeCntr          ; Ones compliment "ModeCntr"
                               ;(flip state of "ModeCntr"
     bne     SET_MODE          ; If the Z bit of CCR is clear, branch
                               ; to SET_MODE:
     bclr    mde,flags         ; Clear "mde" bit of "flags" variable
                               ; ("mde" = 0 = display)
     clr     ScrnCnt           ; Clear "ScrnCnt" variable
     clr     ScrnCnt_prv       ; Clear "ScrnCnt_prv" variable
                               ;(Return to first screen, "Display" mode)
     mov     #$14,ScrnCnt_Lst  ; Move decimal 20 into "ScrnCnt_Lst"
     bclr    frz,flags         ; Clear "frz" bit of "flags" variable
     bra     TOG_MODE_DONE     ; Branch to TOG_MODE_DONE:

SET_MODE:
     bset    mde,flags         ; Set "mde" bit "flags" variable
                               ;("mde" = 1 = configure)
     clr     ConCnt            ; Clear "ConCnt" variable
     clr     ConCnt_prv        ; Clear "ConCnt_prv" variable
                               ;(Return to first constant in section)
     mov     #$FF,ConCnt_Lst   ; Move decimal 255 into "ConCnt_Lst"
     clr     CurCon            ; Clear "CurCon" variable
     clr     ConVal            ; Clear "ConVal" variable
     bclr    sel,flags         ; Clear "sel" bit of "flags" variable


TOG_MODE_DONE:
     bclr    Sw3cls,Swflags    ; Clear "Sw3cls" bit of "Swflags" variable
     rts                       ; Return from subroutine



;***************************************************************************
; - This subroutine loads H:X with the desired vectored address found in a
;   vector address table. (H:X) originally holds the address of beginning of
;   the vector address table. (A) holds the offset value to the desired
;   vector address.
;   The accumulator has to be multiplied by 2 before addition to the index
;   register H:X, since each entry in the vector table is of 2 byte length.
;   Since the indexed addressing mode for LDHX is missing, we cannot load
;   H:X with the content of memory that H:X is pointing to. To do so, we
;   load (A) with the Hi byte of the vector address, using indexed
;   addressing with zero offset, and load (X) with the Lo byte of the vector
;   address, again, using indexed addressing, but, with an offset of 1.
;   After copying (A) to (H) via push/pull operations, (H:X) contains the
;   vector address.
;   NOTE! After the final "pulh" instruction, a "jmp ,x" will jump the
;   program to the desired vector address.
;***************************************************************************

GET_VECT_ADDR:
     lsla             ; Logical shift left accumulator(multiply by 2)
     pshx             ; Push value in index register Lo byte to stack
     pshh             ; Push value in index register Hi byte to stack
     add     2,SP     ; Add ((A)<-(A)+(M)) In this case, 2=2nd location
                      ; on stack, and SP=A, so (A=X+A)
     tax              ; Transfer value in accumulator to index register Lo
                      ; byte(Copy result in to index register Lo byte)
     pula             ; Pull value from stack to accumulator((H)->(A))
     adc     #$00     ; Add with carry ((A)<-(A)+(M)+(C))
                      ;(This just adds the carry, if applicable)
     psha             ; Push value in accumulator to stack
                      ;(modified (H) -> stack)
     pulh             ; Pull value from stack to index register Hi byte
                      ;(modified (H)->(H)
     pula             ; Pull value from stack to accumulator
                      ;(clean up stack)
     lda     ,x       ; Load accumulator with value in index register Lo
                      ;(vector Hi byte)
     ldx     1,x      ; Load index register Lo byte with value in 1st
                      ; location on stack(vector Lo byte)
     psha             ; Push value in accumulator to stack
     pulh             ; Pull value from stack to accumulator((A)->(H)
                      ;((H:X) now contains the desired vector address)
     rts              ; Return from subroutine


;***************************************************************************
; - This subroutine does an effective address calculation, adding the
;   unsigned 8 bit value in the accumulator, to the index register (H:X).
;   Since there is no instruction available which can add the contents of
;   A to H:X, the contents of H:X must first be saved to memory(stack), to
;   allow a memory to register addition operation. H:X is modified.
;   (A) contains the value of the offset from address at (H:X)
;***************************************************************************

ADD_A_TO_HX:
     pshx            ; Push value in index register Lo byte to stack
     pshh            ; Push value in index register Hi byte to stack
     psha            ; push value in accumulator to stack
     tsx             ; Transfer value in stack to index register Lo byte
                     ;((A)->(X))
     add     2,x     ; Add ((A)<-(A)+(M)) In this case, 2=2nd location on
                     ; stack, and x=A, so (A=X+A)
     sta     2,x     ; Copy result to 2nd location on stack
     clra            ; Clear accumulator(A=0)
     adc     1,x     ; Add with carry ((A)<-(A)+(M)+(C)) In this case
                     ; 1=1st location on stack, and x=A=0, so (A=H+C+A)
     sta     1,x     ; Copy result to 1st location on stack
     pula            ; Pull value from stack to accumulator
     pulh            ; Pull value from stack to index register Hi byte
     pulx            ; Pull value from stack to index register Lo byte
                     ;(H:X) now contains ((H:X+(A))
     rts             ; return from subroutine


;***************************************************************************
; - This subroutine loads into A, the contents of a location pointed to by
;   H:X plus A. H:X is preserved. This operation emulates a "lda A,X"
;   instruction, so called "accumulator-offset indexed addressing mode",
;   which is not available on the HC08 family instruction set.
;   (A) contains the value of the offset from address at (H:X)
;***************************************************************************

LDA_W_HX_PL_A:
     pshx             ; Push value in index register Lo byte to stack
     pshh             ; Push value in index register Hi byte to stack
                      ;(These 2 instructions save the original (H:X))
     pshx             ; Push value in index register Lo byte to stack
     pshh             ; Push value in index register Hi byte to stack
                      ;(These 2 instructions are for the working H:X
     add     2,SP     ; Add ((A)<-(A)+(M)) In this case, 2=2nd location
                      ; on stack, and SP=A, so (A=X+A)
     tax              ; Transfer value in accumulator to index register Lo
                      ; byte(Copy result in to index register Lo byte)
     pula             ; Pull value from stack to accumulator((H)->(A))
     adc     #$00     ; Add with carry ((A)<-(A)+(M)+(C))
                      ;(This just adds the carry, if applicable)
     psha             ; Push value in accumulator to stack
                      ;(modified (H) to stack)
     pulh             ; Pull value from stack to index register Hi byte
                      ;(modified (H) to (H)
     ais     #$01     ; Add immediate value of 1 to SP register
                      ;(clean up stack)
     lda     ,x       ; Load accumulator with value in index register Lo
                      ; byte
                      ;(A now contains the value in the location at H:X+A)
     pulh             ; Pull value from stack to index register Hi byte
     pulx             ; Pull value from stack to index register Lo byte
                      ;(these 2 instructions restore (H:X))
     rts              ; return from subroutine

;***************************************************************************
; - This subroutine sends an instruction byte to position the cursor in the
;   top left corner of the display.
;***************************************************************************

VFD_START_TOP:

;***************************************************************************
; - Set up to send an instruction  byte.
;***************************************************************************

     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B(PTB4)
     bclr    Rd_Wrt,PORTB     ; Clear "Rd_Wrt" bit of Port B(PTB5)
                              ;(Write Operation)
     bclr    Reg_Sel,PORTB    ; Clear "Reg_Sel" bit of Port B(PTB6)
                              ;(Send an instruction value)


;***************************************************************************
; - Set cursor top left Hi nibble
;***************************************************************************

     mov     #$08,PORTC       ; Move %00001000 into PortC
                              ;(Set bit4=DB7)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set cursor top left Lo nibble
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     rts                      ; Return from subroutine


;***************************************************************************
; - This subroutine sends an instruction byte to position the cursor in the
;   bottom left corner of the display.
;***************************************************************************

VFD_START_BOT:

;***************************************************************************
; - Set up to send an instruction  byte.
;***************************************************************************

     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B(PTB4)
     bclr    Rd_Wrt,PORTB     ; Clear "Rd_Wrt" bit of Port B(PTB5)
                              ;(Write Operation)
     bclr    Reg_Sel,PORTB    ; Clear "Reg_Sel" bit of Port B(PTB6)
                              ;(Send an instruction value)


;***************************************************************************
; - Set cursor bottom left Hi nibble
;***************************************************************************

     mov     #$0C,PORTC       ; Move %00001100 into PortC
                              ;(Set bit4=DB7 and bit3=DB6)
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Set cursor bottom left Lo nibble
;***************************************************************************

     mov     #$00,PORTC       ; Move %00000000 into PortC
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     rts                      ; Return from subroutine


;***************************************************************************
; - This subroutine takes a single ASCII value, held in "value" variable
;   and sets the appropriate bits of Port C. Interface with the VFD display
;   is 4 bit, so, to send an 8 bit value, bits 4,5,6 and 7 are sent first,
;   then the bits 0,1,2 and 3 are sent.
;***************************************************************************

VFD_SEND:

;***************************************************************************
; - Data Bit 4 (PTC0)
;***************************************************************************

CHK_DB4:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB4m       ; Logical AND (A)&(M)%00010000
     bne     SET_DB4     ; If Z bit of CCR is clear, branch to SET_DB4:
     bclr    DB4,PORTC   ; Clear "DB4" bit of Port C(bit0)
     bra     CHK_DB5     ; Branch to CHK_DB5

SET_DB4:
     bset    DB4,PORTC   ; Set "DB4" bit of Port C(bit0)

;***************************************************************************
; - Data Bit 5 (PTC1)
;***************************************************************************

CHK_DB5:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB5m       ; Logical AND (A)&(M)%00100000
     bne     SET_DB5     ; If Z bit of CCR is clear, branch to SET_DB5:
     bclr    DB5,PORTC   ; Clear "DB5" bit of Port C(bit1)
     bra     CHK_DB6     ; Branch to CHK_DB6

SET_DB5:
     bset    DB5,PORTC   ; Set "DB5" bit of Port C(bit1)

;***************************************************************************
; - Data Bit 6 (PTC2)
;***************************************************************************

CHK_DB6:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB6m       ; Logical AND (A)&(M)%01000000
     bne     SET_DB6     ; If Z bit of CCR is clear, branch to SET_DB6:
     bclr    DB6,PORTC   ; Clear "DB6" bit of Port C(bit2)
     bra     CHK_DB7     ; Branch to CHK_DB7

SET_DB6:
     bset    DB6,PORTC   ; Set "DB6" bit of Port C(bit2)

;***************************************************************************
; - Data Bit 7 (PTC3)
;***************************************************************************

CHK_DB7:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB7m       ; Logical AND (A)&(M)%10000000
     bne     SET_DB7     ; If Z bit of CCR is clear, branch to SET_DB7:
     bclr    DB7,PORTC   ; Clear "DB7" bit of Port C(bit3)
     bra     HI_NIB      ; Branch to HI_NIB:

SET_DB7:
     bset    DB7,PORTC   ; Set "DB7" bit of Port C(bit3)

;***************************************************************************
; - Send the Hi nibble
;***************************************************************************

HI_NIB:
     bset    Reg_Sel,PORTB    ; Set "Reg_Sel" bit of PortB(RS=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:

;***************************************************************************
; - Clear Enable line to set up Lo nibble
;***************************************************************************

     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)

;***************************************************************************
; - Data Bit 0 (PTC0)
;***************************************************************************

CHK_DB0:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB0m       ; Logical AND (A)&(M)%00000001
     bne     SET_DB0     ; If Z bit of CCR is clear, branch to SET_DB0:
     bclr    DB0,PORTC   ; Clear "DB0" bit of Port C(bit0)
     bra     CHK_DB1     ; Branch to CHK_DB1

SET_DB0:
     bset    DB0,PORTC   ; Set "DB0" bit of Port C(bit0)

;***************************************************************************
; - Data Bit 1 (PTC1)
;***************************************************************************

CHK_DB1:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB1m       ; Logical AND (A)&(M)%00000010
     bne     SET_DB1     ; If Z bit of CCR is clear, branch to SET_DB1:
     bclr    DB1,PORTC   ; Clear "DB1" bit of Port C(bit1)
     bra     CHK_DB2     ; Branch to CHK_DB2

SET_DB1:
     bset    DB1,PORTC   ; Set "DB1" bit of Port C(bit1)

;***************************************************************************
; - Data Bit 2 (PTC2)
;***************************************************************************

CHK_DB2:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB2m       ; Logical AND (A)&(M)%00000100
     bne     SET_DB2     ; If Z bit of CCR is clear, branch to SET_DB2:
     bclr    DB2,PORTC   ; Clear "DB2" bit of Port C(bit2)
     bra     CHK_DB3     ; Branch to CHK_DB3

SET_DB2:
     bset    DB2,PORTC   ; Set "DB2" bit of Port C(bit2)

;***************************************************************************
; - Data Bit 3 (PTC3)
;***************************************************************************

CHK_DB3:
     lda     value       ; Load accumulator with value in "value" variable
     bit     #DB3m       ; Logical AND (A)&(M)%00001000
     bne     SET_DB3     ; If Z bit of CCR is clear, branch to SET_DB3:
     bclr    DB3,PORTC   ; Clear "DB3" bit of Port C(bit3)
     bra     LO_NIB      ; Branch to LO_NIB:

SET_DB3:
     bset    DB3,PORTC   ; Set "DB3" bit of Port C(bit3)

;***************************************************************************
; - Send the Lo nibble
;***************************************************************************

LO_NIB:
     bset    Enable,PORTB     ; Set "Enable" bit of Port B (PTB4)("En"=1)
     jsr     LONG_DELAY       ; Jump to subroutine at LONG_DELAY:
                              ;(timing requirement)

;***************************************************************************
; - Clear Enable and Register Select to set up for next transmit
;***************************************************************************

     bclr    Enable,PORTB     ; Clear "Enable" bit of Port B (PTB4)("En"=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     bclr    Reg_Sel,PORTB    ; Clear "Reg_Sel" bit of PortB(RS=0)
     jsr     SHORT_DELAY      ; Jump to subroutine at SHORT_DELAY:
     rts                      ; Return from subroutine


;****************************************************************************
; - This is the delay time from the point at which the data bits have been
;   configured, and the "enable" bit set, to the point at which the "enable"
;   bit is cleared.(min 0.45uS)
;   One pass through the loop takes ~1.5uS, bus frequency of ~8mHZ
;****************************************************************************

LONG_DELAY:
     clr     tmp1       ; Clear tmp1 variable

WAIT_4:
     lda     tmp1       ; Load accumulator with value in tmp1 variable
     inca               ; Increment value in accumulator
     sta     tmp1       ; Copy to tmp1 variable
     cmp     #$02       ; Compare value in accumulator with decimal 2
     blo     WAIT_4     ; If C bit of CCR is set, (A<M), branch to
                        ; WAIT_4:(~3uS delay for timing requirements)
     rts                ; Return from subroutine


;****************************************************************************
; - This is the delay time from the point at which the "enable" bit has been
;   cleared, to the point where the data bits can be re-configured.
;   (min 0.01uS) One NOP takes ~0.125uS, bus frequency of ~8mHZ
;****************************************************************************

SHORT_DELAY:
     nop                ; No operation(1 bus cycle)
     rts                ; Return from subroutine


;****************************************************************************
; - This subroutine compares all the characters on the bottom line commanded,
;   to those of the previous bottom line. If they are different, update the
;   bottom line, otherwise, skip over. This is to eliminate display
;   "digit rattle" caused by rapid screen updates.
;****************************************************************************

CMP_BOTLIN:
     lda     Botlin0         ; Load accumulator with value in "Botlin0"
     cmp     Botlin0L        ; Compare it with the value in "Botlin0L"
     beq     NO_CHNG_BL0     ; If Z bit of CCR is set, branch to NO_CHNG_BL0
                             ;(A=M)
     sta     Botlin0L        ; Copy "Botlin0" to "Botlin0L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL0:
     lda     Botlin1         ; Load accumulator with value in "Botlin1"
     cmp     Botlin1L        ; Compare it with the value in "Botlin1L"
     beq     NO_CHNG_BL1     ; If Z bit of CCR is set, branch to NO_CHNG_BL1
                             ;(A=M)
     sta     Botlin1L        ; Copy "Botlin1" to "Botlin1L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL1:
     lda     Botlin2         ; Load accumulator with value in "Botlin2"
     cmp     Botlin2L        ; Compare it with the value in "Botlin2L"
     beq     NO_CHNG_BL2     ; If Z bit of CCR is set, branch to NO_CHNG_BL2
                             ;(A=M)
     sta     Botlin2L        ; Copy "Botlin2" to "Botlin2L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL2:
     lda     Botlin3         ; Load accumulator with value in "Botlin3"
     cmp     Botlin3L        ; Compare it with the value in "Botlin3L"
     beq     NO_CHNG_BL3     ; If Z bit of CCR is set, branch to NO_CHNG_BL3
                             ;(A=M)
     sta     Botlin3L        ; Copy "Botlin3" to "Botlin3L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL3:
     lda     Botlin4         ; Load accumulator with value in "Botlin4"
     cmp     Botlin4L        ; Compare it with the value in "Botlin4L"
     beq     NO_CHNG_BL4     ; If Z bit of CCR is set, branch to NO_CHNG_BL4
                             ;(A=M)
     sta     Botlin4L        ; Copy "Botlin4" to "Botlin4L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL4:
     lda     Botlin5         ; Load accumulator with value in "Botlin5"
     cmp     Botlin5L        ; Compare it with the value in "Botlin5L"
     beq     NO_CHNG_BL5     ; If Z bit of CCR is set, branch to NO_CHNG_BL5
                             ;(A=M)
     sta     Botlin5L        ; Copy "Botlin5" to "Botlin5L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL5:
     lda     Botlin6         ; Load accumulator with value in "Botlin6"
     cmp     Botlin6L        ; Compare it with the value in "Botlin6L"
     beq     NO_CHNG_BL6     ; If Z bit of CCR is set, branch to NO_CHNG_BL6
                             ;(A=M)
     sta     Botlin6L        ; Copy "Botlin6" to "Botlin6L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL6:
     lda     Botlin7         ; Load accumulator with value in "Botlin7"
     cmp     Botlin7L        ; Compare it with the value in "Botlin7L"
     beq     NO_CHNG_BL7     ; If Z bit of CCR is set, branch to NO_CHNG_BL7
                             ;(A=M)
     sta     Botlin7L        ; Copy "Botlin7" to "Botlin7L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL7:
     lda     Botlin8         ; Load accumulator with value in "Botlin8"
     cmp     Botlin8L        ; Compare it with the value in "Botlin8L"
     beq     NO_CHNG_BL8     ; If Z bit of CCR is set, branch to NO_CHNG_BL8
                             ;(A=M)
     sta     Botlin8L        ; Copy "Botlin8" to "Botlin8L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL8:
     lda     Botlin9         ; Load accumulator with value in "Botlin9"
     cmp     Botlin9L        ; Compare it with the value in "Botlin9L"
     beq     NO_CHNG_BL9     ; If Z bit of CCR is set, branch to NO_CHNG_BL9
                             ;(A=M)
     sta     Botlin9L        ; Copy "Botlin9" to "Botlin9L"
     jmp     BOTLIN_CHNG     ; Jump to BOTLIN_CHNG:

NO_CHNG_BL9:
     lda     Botlin10         ; Load accumulator with value in "Botlin10"
     cmp     Botlin10L        ; Compare it with the value in "Botlin10L"
     beq     NO_CHNG_BL10     ; If Z bit of CCR is set, branch to NO_CHNG_BL10
                              ;(A=M)
     sta     Botlin10L        ; Copy "Botlin10" to "Botlin10L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL10:
     lda     Botlin11         ; Load accumulator with value in "Botlin11"
     cmp     Botlin11L        ; Compare it with the value in "Botlin11L"
     beq     NO_CHNG_BL11     ; If Z bit of CCR is set, branch to NO_CHNG_BL11
                              ;(A=M)
     sta     Botlin11L        ; Copy "Botlin11" to "Botlin11L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL11:
     lda     Botlin12         ; Load accumulator with value in "Botlin12"
     cmp     Botlin12L        ; Compare it with the value in "Botlin12L"
     beq     NO_CHNG_BL12     ; If Z bit of CCR is set, branch to NO_CHNG_BL12
                              ;(A=M)
     sta     Botlin12L        ; Copy "Botlin12" to "Botlin12L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL12:
     lda     Botlin13         ; Load accumulator with value in "Botlin13"
     cmp     Botlin13L        ; Compare it with the value in "Botlin13L"
     beq     NO_CHNG_BL13     ; If Z bit of CCR is set, branch to NO_CHNG_BL13
                              ;(A=M)
     sta     Botlin13L        ; Copy "Botlin13" to "Botlin13L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL13:
     lda     Botlin14         ; Load accumulator with value in "Botlin14"
     cmp     Botlin14L        ; Compare it with the value in "Botlin14L"
     beq     NO_CHNG_BL14     ; If Z bit of CCR is set, branch to NO_CHNG_BL14
                              ;(A=M)
     sta     Botlin14L        ; Copy "Botlin14" to "Botlin14L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL14:
     lda     Botlin15         ; Load accumulator with value in "Botlin15"
     cmp     Botlin15L        ; Compare it with the value in "Botlin15L"
     beq     NO_CHNG_BL15     ; If Z bit of CCR is set, branch to NO_CHNG_BL15
                              ;(A=M)
     sta     Botlin15L        ; Copy "Botlin15" to "Botlin15L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL15:
     lda     Botlin16         ; Load accumulator with value in "Botlin16"
     cmp     Botlin16L        ; Compare it with the value in "Botlin16L"
     beq     NO_CHNG_BL16     ; If Z bit of CCR is set, branch to NO_CHNG_BL16
                              ;(A=M)
     sta     Botlin16L        ; Copy "Botlin16" to "Botlin16L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL16:
     lda     Botlin17         ; Load accumulator with value in "Botlin17"
     cmp     Botlin17L        ; Compare it with the value in "Botlin17L"
     beq     NO_CHNG_BL17     ; If Z bit of CCR is set, branch to NO_CHNG_BL17
                              ;(A=M)
     sta     Botlin17L        ; Copy "Botlin17" to "Botlin17L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL17:
     lda     Botlin18         ; Load accumulator with value in "Botlin18"
     cmp     Botlin18L        ; Compare it with the value in "Botlin18L"
     beq     NO_CHNG_BL18     ; If Z bit of CCR is set, branch to NO_CHNG_BL18
                              ;(A=M)
     sta     Botlin18L        ; Copy "Botlin18" to "Botlin18L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL18:
     lda     Botlin19         ; Load accumulator with value in "Botlin19"
     cmp     Botlin19L        ; Compare it with the value in "Botlin19L"
     beq     NO_CHNG_BL19     ; If Z bit of CCR is set, branch to NO_CHNG_BL19
                              ;(A=M)
     sta     Botlin19L        ; Copy "Botlin19" to "Botlin19L"
     jmp     BOTLIN_CHNG      ; Jump to BOTLIN_CHNG:

NO_CHNG_BL19:
     bra     NO_CHNG_BOTLIN   ; Branch to NO_CHNG_BOTLIN:

BOTLIN_CHNG:
     bset    LinChng,flags    ; Set "Linchng" bit of "flags" variable
     bra     CMP_BOTLIN_DONE  ; Branch to CMP_BOTLIN_DONE:

NO_CHNG_BOTLIN:
     bclr    LinChng,flags    ; Clear "Linchng" bit of "flags" variable

CMP_BOTLIN_DONE:
     rts                      ; Return from subroutine

;***************************************************************************
;
; -------------------- Ordered Table Search Subroutine ---------------------
;
;  X is pointing to the start of the first value in the table
;  tmp1:2 initially hold the start of table address,
;  then they hold the bound values
;  tmp3 is the end of the table ("n" elements - 1)
;  tmp4 is the comparison value
;  tmp5 is the index result - if zero then comp value is less
;  than beginning of table, and if equal to "n" elements then it is
;  rail-ed at upper end
;
;***************************************************************************

ORD_TABLE_FIND:
     clr     tmp5     ; Clear tmp5 variable
     ldhx    tmp1     ; Load high part of index register with value in tmp1
     lda     ,x	      ; Load accumulator with low part of index register???
     sta     tmp1     ; Copy to tmp1 variable
     sta     tmp2     ; Copy to tmp2 variable

REENT:
     incx                    ; Increment low part of index register
     inc     tmp5            ; Increment tmp5 variable
     mov     tmp2,tmp1       ; Move value in tmp2 variable to tmp1 variable
     lda     ,x              ; Load accumulator with value in index reg Lo??
     sta     tmp2            ; Copy to tmp2 variable
     cmp     tmp4            ; Compare it with tmp4 variable
     bhi     GOT_ORD_NUM     ; If higher, branch to GOT_ORD_NUM lable
     lda     tmp5            ; Load accumulator with value in tmp5 variable
     cmp     tmp3            ; Compare it with value in tmp3 variable
     bne     REENT           ; If the Z bit of CCR is clesr, branch to REENT:

GOT_ORD_NUM:
     rts                     ; Return from subroutine


;****************************************************************************
;
; ------------------ Linear Interpolation - 2D Subroutine -------------------
;
; Graph Plot         Z2
;                   Y2
;               X
;               Y
;         X1
;         Y1
;            (y2 - y1)
;  Y = Y1 +  --------- * (x - x1)
;            (x2 - x1)
;
;   tmp1 = x1
;   tmp2 = x2
;   tmp3 = y1
;   tmp4 = y2
;   tmp5 = x
;   tmp6 = y
;***************************************************************************

LININTERP:
     clr     tmp7          ; Clear tmp7 variable (This is the negative slope
                           ; detection bit) (tmp7 = 0)
     mov     tmp3,tmp6     ; Move value in tmp3 variable to tmp6 variable
                           ; (Y1 to tmp6)

CHECK_LESS_THAN:
     lda     tmp5               ; Load accumulator with value in tmp5 variable
                                ; (x)
     cmp     tmp1               ; Compare it with value in tmp1 variable
                                ; (x1)
     bhi     CHECK_GREATER_THAN ; If higher, branch to CHECK_GREATER_THAN:
                                ; (X>X1)
     bra     DONE_WITH_INTERP	; Branch to DONE_WITH_INTERP: (else (Y=Y1))

CHECK_GREATER_THAN:
     lda     tmp5             ; Load accumulator with value in tmp5 variable
                              ; (x)
     cmp     tmp2             ; Compare it with value in tmp2 variable
                              ; (X2)
     blo     DO_INTERP        ; If lower, branch to DO_INTERP lable
                              ; (X<X2)
     mov     tmp4,tmp6        ; Move value in tmp4 variable to tmp6 variable
                              ; (Y2 to tmp6)
     bra     DONE_WITH_INTERP ; Branch to DONE_WITH_INTERP lable (else (Y=Y2))

DO_INTERP:
     mov     tmp3,tmp6        ; Move value in tmp3 variable to tmp6 variable
                              ; (Y1 to tmp6)
     lda     tmp2             ; Load accumulator with value in tmp2 variable
                              ; (X2)
     sub     tmp1             ; Subtract tmp1 from tmp2 (A=X2-X1)
     beq     DONE_WITH_INTERP ; If the Z bit of CCR is set, branch to
                              ;DONE_WITH_INTERP:  else (Y=Y1)
     psha                     ; Push value in accumulator to stack
                              ; (X2-X1)(stack 1)
     lda     tmp4             ; Load accumulator with value in tmp4 variable
                              ; (Y2)
     sub     tmp3             ; Subtract tmp3 from tmp4 (A=Y2-Y1)
     bcc     POSINTERP        ; If C bit of CCR is clear, branch to POSINTERP:
     nega                     ; Negate accumulator      ??????????
     inc     tmp7             ; Increment tmp7 variable (tmp7 = 1)

POSINTERP:
     psha                     ; Push value in accumulator to stack
                              ; (negated Y2-Y1) (stack 2)
     lda     tmp5             ; Load accumulator with value in tmp5 variable
                              ; (X)
     sub     tmp1             ; Subtract tmp1 from tmp5 (A=X-X1)
     beq     ZERO_SLOPE	      ; If the Z bit of CCR is set,
                              ; branch to ZERO_SLOPE lable  (Y=Y1)
     pulx                     ; Pull value from stack to index register Lo
                              ;(negated Y2-Y1) (stack 2)
     mul                      ; Multiply it by the value in the accumulator
                              ; A=(negated Y2-Y1)*(X-X1)
     pshx                     ; Push the index register L to the stack
                              ; (stack 2)
     pulh                     ; Pull this value to index register Hi(stack 2)
     pulx                     ; Pull the next value to index register Lo
                              ;(stack 1)
     div                      ; Divide A<-(H:A)/(X);H<-Remainder
     psha                     ; Push the value in the accumulator onto stack
                              ; (stack 1)
     lda     tmp7             ; Load accumulator with value in tmp7 variable
     bne     NEG_SLOPE        ; If the Z bit of CCR is clear,
                              ; branch to NEG_SLOPE: (Y=Y1)
     pula                     ; Pull value from stack to accumulator (stack 1)
     add     tmp3             ; Add it with value in tmp3 variable
     sta     tmp6             ; Copy it to tmp6 variable
     bra     DONE_WITH_INTERP ; Branch to  DONE_WITH_INTERP:

NEG_SLOPE:
     pula                     ; Pull value from stack to accumulator(stack 1)
     sta     tmp7             ; Copy to tmp7 variable
     lda     tmp3             ; Load accumulator with value in tmp3  Y1)
     sub     tmp7             ; Subtract tmp7 from tmp3
     sta     tmp6             ; Copy result to tmp6 variable
     bra     DONE_WITH_INTERP ; Branch to  DONE_WITH_INTERP:

ZERO_SLOPE:
        pula    ; Pull value from stack to accumulator (clean stack)(stack 2)
        pula    ; Pull value from stack to accumulator (clean stack)(stack 1)

DONE_WITH_INTERP:
        rts      ; Return from subroutine

;****************************************************************************
;
; ----------------- 32 x 16 Unsigned Divide Subroutine ---------------------
;
; This routine takes the 32-bit dividend stored in INTACC1.....INTACC1+3
; and divides it by the 16-bit divisor stored in INTACC2:INTACC2+1.
; The quotient replaces the dividend and the remainder replaces the divisor.
;
;***************************************************************************

UDVD32    EQU     *
*
DIVIDEND  EQU     INTACC1+2
DIVISOR   EQU     INTACC2
QUOTIENT  EQU     INTACC1
REMAINDER EQU     INTACC1
*
        PSHH                            ;save h-reg value
        PSHA                            ;save accumulator
        PSHX                            ;save x-reg value
        AIS     #-3                     ;reserve three bytes of temp storage
        LDA     #!32                    ;
        STA     3,SP                    ;loop counter for number of shifts
        LDA     DIVISOR                 ;get divisor msb
        STA     1,SP                    ;put divisor msb in working storage
        LDA     DIVISOR+1               ;get divisor lsb
        STA     2,SP                    ;put divisor lsb in working storage

****************************************************************************
*     Shift all four bytes of dividend 16 bits to the right and clear
*     both bytes of the temporary remainder location
****************************************************************************

        MOV     DIVIDEND+1,DIVIDEND+3   ;shift dividend lsb
        MOV     DIVIDEND,DIVIDEND+2     ;shift 2nd byte of dividend
        MOV     DIVIDEND-1,DIVIDEND+1   ;shift 3rd byte of dividend
        MOV     DIVIDEND-2,DIVIDEND     ;shift dividend msb
        CLR     REMAINDER               ;zero remainder msb
        CLR     REMAINDER+1             ;zero remainder lsb

****************************************************************************
*     Shift each byte of dividend and remainder one bit to the left
****************************************************************************

SHFTLP  LDA     REMAINDER               ;get remainder msb
        ROLA                            ;shift remainder msb into carry
        ROL     DIVIDEND+3              ;shift dividend lsb
        ROL     DIVIDEND+2              ;shift 2nd byte of dividend
        ROL     DIVIDEND+1              ;shift 3rd byte of dividend
        ROL     DIVIDEND                ;shift dividend msb
        ROL     REMAINDER+1             ;shift remainder lsb
        ROL     REMAINDER               ;shift remainder msb

*****************************************************************************
*     Subtract both bytes of the divisor from the remainder
*****************************************************************************

        LDA     REMAINDER+1          ;get remainder lsb
        SUB     2,SP                 ;subtract divisor lsb from remainder lsb
        STA     REMAINDER+1          ;store new remainder lsb
        LDA     REMAINDER            ;get remainder msb
        SBC     1,SP                 ;subtract divisor msb from remainder msb
        STA     REMAINDER            ;store new remainder msb
        LDA     DIVIDEND+3           ;get low byte of dividend/quotient
        SBC     #0                   ;dividend low bit holds subtract carry
        STA     DIVIDEND+3           ;store low byte of dividend/quotient

*****************************************************************************
*     Check dividend/quotient lsb. If clear, set lsb of quotient to indicate
*     successful subraction, else add both bytes of divisor back to remainder
*****************************************************************************

        BRCLR   0,DIVIDEND+3,SETLSB     ;check for a carry from subtraction
                                        ;and add divisor to remainder if set
        LDA     REMAINDER+1             ;get remainder lsb
        ADD     2,SP                    ;add divisor lsb to remainder lsb
        STA     REMAINDER+1             ;store remainder lsb
        LDA     REMAINDER               ;get remainder msb
        ADC     1,SP                    ;add divisor msb to remainder msb
        STA     REMAINDER               ;store remainder msb
        LDA     DIVIDEND+3              ;get low byte of dividend
        ADC     #0                      ;add carry to low bit of dividend
        STA     DIVIDEND+3              ;store low byte of dividend
        BRA     DECRMT                  ;do next shift and subtract

SETLSB  BSET    0,DIVIDEND+3            ;set lsb of quotient to indicate
                                        ;successive subtraction
DECRMT  DBNZ    3,SP,SHFTLP             ;decrement loop counter and do next
                                        ;shift

*****************************************************************************
*     Move 32-bit dividend into INTACC1.....INTACC1+3 and put 16-bit
*     remainder in INTACC2:INTACC2+1
*****************************************************************************

        LDA     REMAINDER               ;get remainder msb
        STA     1,SP                    ;temporarily store remainder msb
        LDA     REMAINDER+1             ;get remainder lsb
        STA     2,SP                    ;temporarily store remainder lsb
        MOV     DIVIDEND,QUOTIENT       ;
        MOV     DIVIDEND+1,QUOTIENT+1   ;shift all four bytes of quotient
        MOV     DIVIDEND+2,QUOTIENT+2   ; 16 bits to the left
        MOV     DIVIDEND+3,QUOTIENT+3   ;
        LDA     1,SP                    ;get final remainder msb
        STA     INTACC2                 ;store final remainder msb
        LDA     2,SP                    ;get final remainder lsb
        STA     INTACC2+1               ;store final remainder lsb

*****************************************************************************
*     Deallocate local storage, restore register values, and return from
*     subroutine
*****************************************************************************

        AIS     #3                      ;deallocate temporary storage
        PULX                            ;restore x-reg value
        PULA                            ;restore accumulator value
        PULH                            ;restore h-reg value
        RTS                             ;return

*****************************************************************************


;****************************************************************************
; ----------  ----- ROUND after div (unsigned) Subroutine -------------------
;
;  1)  check for div overflow (carry set), rail result if detected
;  2)  if (remainder * 2) > divisor then     ; was remainder > (divisor / 2)
;  2a)    increment result, rail if over-flow
;
;****************************************************************************

DIVROUND:
     bcs     DIVROUND0     ; If C bit of CCR is set, branch to DIVROUND0:
                           ; (div overflow? yes, branch)
     stx     local_tmp     ; Copy value in index register Lo byte to
                           ; local_tmp variable (divisor)
     pshh                  ; Push value in index register Hi byte onto
                           ; stack (retrieve remainder)
     pulx                  ; Pull value on stack to index register Lo byte
     lslx                  ; Logical shift left index register lo byte (* 2)
     bcs     DIVROUND2     ; If C bit of CCR is set, branch to DIVROUND2:
                           ;(over-flow on left-shift, (remainder * 2) > $FF)
     cpx     local_tmp     ; Compare value in local_tmp variable with value
                           ; in index register Lo byte
                           ;(compare (remainder * 2) to divisor)
     blo     DIVROUND1     ; If lower, branch to DIVROUND1:


DIVROUND2:
     inca                   ; Increment accumulator (round-up result)
     bne      DIVROUND1     ; If Z bit of CCR is clear, branch to DIVROUND1:
                            ; (result roll over? no, branch)


DIVROUND0:
     lda     #$FF     ; Load accumulator with decimal 255 (rail result)


DIVROUND1:
     rts              ; return from subroutine


;****************************************************************************
;
; ------------------- 16 x 16 Unsigned Multiply Subroutine -----------------
;
;     tmp8...tmp5 = tmp4:tmp3 * tmp2:tmp1
;
;               tmp3*tmp1
;   +      tmp4*tmp1
;   +      tmp3*tmp2
;   + tmp4*tmp2
;   = ===================
;     tmp8 tmp7 tmp6 tmp5
;
;****************************************************************************

UMUL32:
     lda     tmp1	       ; Load accumulator with value in tmp1 variable
     ldx     tmp3	       ; Load index register Lo byte with value in tmp3
     mul                 ; Multiply X:A<-(X)*(A)
     sta     tmp5	       ; Ccopy result to tmp5
     stx     tmp6	       ; Copy value in index register Lo byte to tmp6
;
     lda     tmp2	       ; Load accumulator with value in tmp2
     ldx     tmp4	       ; Load index register Lo byte with value in tmp4
     mul                 ; Multiply X:A<-(X)*(A)
     sta     tmp7	       ; Copy result to tmp7
     stx     tmp8	       ; Copy value in index register Lo byte to tmp8
;
     lda     tmp1	       ; Load accumulator with value in tmp1
     ldx     tmp4	       ; Load index register Lo byte with value in tmp4
     mul                 ; Multiply X:A<-(X)*(A)
     add     tmp6	       ; Add without carry, A<-(A)+(M)
     sta     tmp6	       ; Copy result to tmp6
     txa                 ; Transfer value in index register Lo byte
                         ; to accumulator
     adc     tmp7	       ; Add with carry, A<-(A)+(M)+(C)
     sta     tmp7	       ; Copy result to tmp7
     bcc     UMUL32a     ; If C bit of CCR is clear, branch to UMUL32a:
     inc     tmp8	       ; Increment value in tmp8


UMUL32a:
     lda     tmp2	       ; Load accumulator with value in tmp2
     ldx     tmp3	       ; Load index register Lo byte with value in tmp3
     mul                 ; Multiply X:A<-(X)*(A)
     add     tmp6	       ; Add without carry, A<-(A)+(M)
     sta     tmp6	       ; Copy result to tmp6
     txa                 ; Transfer value in index register Lo byte
                         ; to accumulator
     adc     tmp7	       ; Add with carry, A<-(A)+(M)+(C)
     sta     tmp7	       ; Copy result to tmp7
     bcc     UMUL32b     ; If C bit of CCR is clear, branch to UMUL32b:
     inc     tmp8	       ; increment value in tmp8 variable


UMUL32b:
      rts                ; return from subroutine

;***************************************************************************
; ----------------------------- Include Files -----------------------------
;***************************************************************************

     org     $E700       ; Origin at Memory Location $E700=59136(uses768)

     include "ASCII_Conv_100.inc"     ; Converts 8 bit value to ASCII,
                                      ; 100s column
     include "ASCII_Conv_10.inc"      ; Converts 8 bit value to ASCII,
                                      ; 10s column
     include "ASCII_Conv_1.inc"       ; Converts 8 bit value to ASCII,
                                      ; 1s column


;***************************************************************************
; --------------------------- VFD Lookup Tables ---------------------------
;***************************************************************************

     org     $EA00       ; Origin at Memory Location $EA60=59904(uses5538)

;***************************************************************************
; - These tables are the character strings for the top lines of the VFD
;   while in "Display" mode.
;***************************************************************************

VARS0_TL_TB:
     db     'ML Gr CC TC FC EP EB'
            ; Manual Lever Position
            ; Current Gear
            ; Coast Clutch applied?
            ; Torque Converter Clutch Applied?
            ; Decel Fuel Cut Permissive?
            ; Exhaust Brake Pressure permissive?
            ; Exhaust Brake Applied?

VARS1_TL_TB:
     db     'RPM MPH Prs TOT Vlt '
            ; Engine RPM in RPM /20
            ; Vehicle Speed in MPH
            ; Line Pressure in PSI
            ; Transmission Oil Temperature in degreesF+40
            ; System Voltage in volts *10

VARS2_TL_TB:
     db     'DuF TPP PWH:PWL Prs '
            ; EPC Duty Factor from "TO" table, stall or shift tables,
            ; or, absolute values "EPC_TCC", or "EPC_decel"
            ; Throttle Position in percent
            ; Final EPC PW Hi byte
            ; Final EPC PW Lo byte
            ; Line Pressure in PSI

VARS3_TL_TB:
     db     'SeH SeL IAC Ipw RPM '
            ; Time since MS_TECA power up seconds Hi byte
            ; Time since MS_TECA power up seconds Lo byte
            ; Idle Air Control Sensor 8 bit ADC reading
            ; Idle Air Control pulse width in 100uS
            ; Engine RPM in RPM /20

VARS4_TL_TB:
     db     'RPM MAP TPP TrA DuF '
            ; Engine RPM in RPM /20
            ; Manifold Absolute Pressure in KPA
            ; Throttle Position in percent
            ; EPC Trim Correction Adder
            ; EPC Duty Factor from "TO" table, stall or shift tables,
            ; or, absolute values "EPC_TCC", or "EPC_decel"

VARS5_TL_TB:
     db     'DuF TtA TrA DF1 DFF '
            ; EPC Duty Factor from "TO" table, stall or shift tables, or,
            ; absolute values "EPC_TCC", or "EPC_decel",
            ; TOT correction adder
            ; Trim correctioin adder
            ; "df" after TOT cor, before Trim cor
            ; "df1" after Trim cor(Final EPC Duty Factor)

G1_CONS_TL_TB:
     db     'Cons Group1 Prs Mode'
            ; Directions to the first half of Configurable constants

G2_CONS_TL_TB:
     db     'Cons Group2 Prs Mode'
            ; Directions to the second half of Configurable constants

GET_G1_CONS:
     db     'UpLd G1 Cons Prs Mde'
            ; Directions to up load Group 1 of constants from MS_TECA

GET_G2_CONS:
     db     'UpLd G2 Cons Prs Mde'
            ; Directions to up load Group 2 of constants from MS_TECA

SEND_G1_VAL:
     db     'DnLd G1 val Prs Mode'
            ; Directions to down load  selected G1 constant to MS_TECA

SEND_G2_VAL:
     db     'DnLd G2 val Prs Mode'
            ; Directions to down load  selected G1 constant to MS_TECA

BURN_CONS:
     db     'Burn Cons Press Mode'
            ; Directions to burn constants in MS_TECA RAM to MS_TECA ROM

GET_G1_CONS_FIN:
     db     'UpLd G1 Done Prs Mde'
            ;Up load G1 constants from MS_TECA finished, Press "Mode" to exit

GET_G2_CONS_FIN:
     db     'UpLd G2 Done Prs Mde'
            ;Up load G2 constants from MS_TECA finished, Press "Mode" to exit

SEND_G1_VAL_FIN:
     db     'DnLd V1 Done Prs Mde'
            ;Down load selcted G1 constant to MS_TECA finished,
            ;Press "Mode" to exit

SEND_G2_VAL_FIN:
     db     'DnLd V2 Done Prs Mde'
            ;Down load selected G2 constant to MS_TECA finished,
            ;Press "Mode" to exit

BURN_CONS_FIN:
     db     'Burn Done Press Mode'
            ; Burn constants in MS_TECA RAM to MS_TECA ROM finished,
            ; press "Mode" to exit


;***************************************************************************
; - This is the first table of character strings for the top lines of the
;   VFD while in "Configure" mode.
;***************************************************************************

TO_0_0_TOP:
     db     'TO KPArow 0 RPMcol 0'
            ; "TO" table, KPA row 0, RPM column 0

TO_0_1_TOP:
     db     'TO KPArow 0 RPMcol 1'
            ; "TO" table, KPA row 0, RPM column 1

TO_0_2_TOP:
     db     'TO KPArow 0 RPMcol 2'
            ; "TO" table, KPA row 0, RPM column 2

TO_0_3_TOP:
     db     'TO KPArow 0 RPMcol 3'
            ; "TO" table, KPA row 0, RPM column 3

TO_0_4_TOP:
     db     'TO KPArow 0 RPMcol 4'
            ; "TO" table, KPA row 0, RPM column 4

TO_0_5_TOP:
     db     'TO KPArow 0 RPMcol 5'
            ; "TO" table, KPA row 0, RPM column 5

TO_0_6_TOP:
     db     'TO KPArow 0 RPMcol 6'
            ; "TO" table, KPA row 0, RPM column 6

TO_0_7_TOP:
     db     'TO KPArow 0 RPMcol 7'
            ; "TO" table, KPA row 0, RPM column 7

TO_1_0_TOP:
     db     'TO KPArow 1 RPMcol 0'
            ; "TO" table, KPA row 1, RPM column 0

TO_1_1_TOP:
     db     'TO KPArow 1 RPMcol 1'
            ; "TO" table, KPA row 1, RPM column 1

TO_1_2_TOP:
     db     'TO KPArow 1 RPMcol 2'
            ; "TO" table, KPA row 1, RPM column 2

TO_1_3_TOP:
     db     'TO KPArow 1 RPMcol 3'
            ; "TO" table, KPA row 1, RPM column 3

TO_1_4_TOP:
     db     'TO KPArow 1 RPMcol 4'
            ; "TO" table, KPA row 1, RPM column 4

TO_1_5_TOP:
     db     'TO KPArow 1 RPMcol 5'
            ; "TO" table, KPA row 1, RPM column 5

TO_1_6_TOP:
     db     'TO KPArow 1 RPMcol 6'
            ; "TO" table, KPA row 1, RPM column 6

TO_1_7_TOP:
     db     'TO KPArow 1 RPMcol 7'
            ; "TO" table, KPA row 1, RPM column 7

TO_2_0_TOP:
     db     'TO KPArow 2 RPMcol 0'
            ; "TO" table, KPA row 2, RPM column 0

TO_2_1_TOP:
     db     'TO KPArow 2 RPMcol 1'
            ; "TO" table, KPA row 2, RPM column 1

TO_2_2_TOP:
     db     'TO KPArow 2 RPMcol 2'
            ; "TO" table, KPA row 2, RPM column 2

TO_2_3_TOP:
     db     'TO KPArow 2 RPMcol 3'
            ; "TO" table, KPA row 2, RPM column 3

TO_2_4_TOP:
     db     'TO KPArow 2 RPMcol 4'
            ; "TO" table, KPA row 2, RPM column 4

TO_2_5_TOP:
     db     'TO KPArow 2 RPMcol 5'
            ; "TO" table, KPA row 2, RPM column 5

TO_2_6_TOP:
     db     'TO KPArow 2 RPMcol 6'
            ; "TO" table, KPA row 2, RPM column 6

TO_2_7_TOP:
     db     'TO KPArow 2 RPMcol 7'
            ; "TO" table, KPA row 2, RPM column 7

TO_3_0_TOP:
     db     'TO KPArow 3 RPMcol 0'
            ; "TO" table, KPA row 3, RPM column 0

TO_3_1_TOP:
     db     'TO KPArow 3 RPMcol 1'
            ; "TO" table, KPA row 3, RPM column 1

TO_3_2_TOP:
     db     'TO KPArow 3 RPMcol 2'
            ; "TO" table, KPA row 3, RPM column 2

TO_3_3_TOP:
     db     'TO KPArow 3 RPMcol 3'
            ; "TO" table, KPA row 3, RPM column 3

TO_3_4_TOP:
     db     'TO KPArow 3 RPMcol 4'
            ; "TO" table, KPA row 3, RPM column 4

TO_3_5_TOP:
     db     'TO KPArow 3 RPMcol 5'
            ; "TO" table, KPA row 3, RPM column 5

TO_3_6_TOP:
     db     'TO KPArow 3 RPMcol 6'
            ; "TO" table, KPA row 3, RPM column 6

TO_3_7_TOP:
     db     'TO KPArow 3 RPMcol 7'
            ; "TO" table, KPA row 3, RPM column 7


TO_4_0_TOP:
     db     'TO KPArow 4 RPMcol 0'
            ; "TO" table, KPA row 4, RPM column 0

TO_4_1_TOP:
     db     'TO KPArow 4 RPMcol 1'
            ; "TO" table, KPA row 4, RPM column 1

TO_4_2_TOP:
     db     'TO KPArow 4 RPMcol 2'
            ; "TO" table, KPA row 4, RPM column 2

TO_4_3_TOP:
     db     'TO KPArow 4 RPMcol 3'
            ; "TO" table, KPA row 4, RPM column 3

TO_4_4_TOP:
     db     'TO KPArow 4 RPMcol 4'
            ; "TO" table, KPA row 4, RPM column 4

TO_4_5_TOP:
     db     'TO KPArow 4 RPMcol 5'
            ; "TO" table, KPA row 4, RPM column 5

TO_4_6_TOP:
     db     'TO KPArow 4 RPMcol 6'
            ; "TO" table, KPA row 4, RPM column 6

TO_4_7_TOP:
     db     'TO KPArow 4 RPMcol 7'
            ; "TO" table, KPA row 4, RPM column 7

TO_5_0_TOP:
     db     'TO KPArow 5 RPMcol 0'
            ; "TO" table, KPA row 5, RPM column 0

TO_5_1_TOP:
     db     'TO KPArow 5 RPMcol 1'
            ; "TO" table, KPA row 5, RPM column 1

TO_5_2_TOP:
     db     'TO KPArow 5 RPMcol 2'
            ; "TO" table, KPA row 5, RPM column 2

TO_5_3_TOP:
     db     'TO KPArow 5 RPMcol 3'
            ; "TO" table, KPA row 5, RPM column 3

TO_5_4_TOP:
     db     'TO KPArow 5 RPMcol 4'
            ; "TO" table, KPA row 5, RPM column 4

TO_5_5_TOP:
     db     'TO KPArow 5 RPMcol 5'
            ; "TO" table, KPA row 5, RPM column 5

TO_5_6_TOP:
     db     'TO KPArow 5 RPMcol 6'
            ; "TO" table, KPA row 5, RPM column 6

TO_5_7_TOP:
     db     'TO KPArow 5 RPMcol 7'
            ; "TO" table, KPA row 5, RPM column 7

TO_6_0_TOP:
     db     'TO KPArow 6 RPMcol 0'
            ; "TO" table, KPA row 6, RPM column 0

TO_6_1_TOP:
     db     'TO KPArow 6 RPMcol 1'
            ; "TO" table, KPA row 6, RPM column 1

TO_6_2_TOP:
     db     'TO KPArow 6 RPMcol 2'
            ; "TO" table, KPA row 6, RPM column 2

TO_6_3_TOP:
     db     'TO KPArow 6 RPMcol 3'
            ; "TO" table, KPA row 6, RPM column 3

TO_6_4_TOP:
     db     'TO KPArow 6 RPMcol 4'
            ; "TO" table, KPA row 6, RPM column 4

TO_6_5_TOP:
     db     'TO KPArow 6 RPMcol 5'
            ; "TO" table, KPA row 6, RPM column 5

TO_6_6_TOP:
     db     'TO KPArow 6 RPMcol 6'
            ; "TO" table, KPA row 6, RPM column 6

TO_6_7_TOP:
     db     'TO KPArow 6 RPMcol 7'
            ; "TO" table, KPA row 6, RPM column 7

TO_7_0_TOP:
     db     'TO KPArow 7 RPMcol 0'
            ; "TO" table, KPA row 7, RPM column 0

TO_7_1_TOP:
     db     'TO KPArow 7 RPMcol 1'
            ; "TO" table, KPA row 7, RPM column 1

TO_7_2_TOP:
     db     'TO KPArow 7 RPMcol 2'
            ; "TO" table, KPA row 7, RPM column 2

TO_7_3_TOP:
     db     'TO KPArow 7 RPMcol 3'
            ; "TO" table, KPA row 7, RPM column 3

TO_7_4_TOP:
     db     'TO KPArow 7 RPMcol 4'
            ; "TO" table, KPA row 7, RPM column 4

TO_7_5_TOP:
     db     'TO KPArow 7 RPMcol 5'
            ; "TO" table, KPA row 7, RPM column 5

TO_7_6_TOP:
     db     'TO KPArow 7 RPMcol 6'
            ; "TO" table, KPA row 7, RPM column 6

TO_7_7_TOP:
     db     'TO KPArow 7 RPMcol 7'
            ; "TO" table, KPA row 7, RPM column 7

RPMRANGETO_0_TOP:
     db     'TO Tab RPM c0 RPM/20'
            ; "TO" table RPM range, RPM column 0, RPM /20

RPMRANGETO_1_TOP:
     db     'TO Tab RPM c1 RPM/20'
            ; "TO" table RPM range, RPM column 1, RPM /20

RPMRANGETO_2_TOP:
     db     'TO Tab RPM c2 RPM/20'
            ; "TO" table RPM range, RPM column 2, RPM /20

RPMRANGETO_3_TOP:
     db     'TO Tab RPM c3 RPM/20'
            ; "TO" table RPM range, RPM column 3, RPM /20

RPMRANGETO_4_TOP:
     db     'TO Tab RPM c4 RPM/20'
            ; "TO" table RPM range, RPM column 4, RPM /20

RPMRANGETO_5_TOP:
     db     'TO Tab RPM c5 RPM/20'
            ; "TO" table RPM range, RPM column 5, RPM /20

RPMRANGETO_6_TOP:
     db     'TO Tab RPM c6 RPM/20'
            ; "TO" table RPM range, RPM column 6, RPM /20

RPMRANGETO_7_TOP:
     db     'TO Tab RPM c7 RPM/20'
            ; "TO" table RPM range, RPM column 7, RPM /20

KPARANGETO_0_TOP:
     db     'TO Tab KPA row0 KPA '
            ; "TO" table KPA range, KPA row 0, KPA

KPARANGETO_1_TOP:
     db     'TO Tab KPA row1 KPA '
            ; "TO" table KPA range, KPA row 1, KPA

KPARANGETO_2_TOP:
     db     'TO Tab KPA row2 KPA '
            ; "TO" table KPA range, KPA row 2, KPA

KPARANGETO_3_TOP:
     db     'TO Tab KPA row3 KPA '
            ; "TO" table KPA range, KPA row 3, KPA

KPARANGETO_4_TOP:
     db     'TO Tab KPA row4 KPA '
            ; "TO" table KPA range, KPA row 4, KPA

KPARANGETO_5_TOP:
     db     'TO Tab KPA row5 KPA '
            ; "TO" table KPA range, KPA row 5, KPA

KPARANGETO_6_TOP:
     db     'TO Tab KPA row6 KPA '
            ; "TO" table KPA range, KPA row 6, KPA

KPARANGETO_7_TOP:
     db     'TO Tab KPA row7 KPA '
            ; "TO" table KPA range, KPA row 7, KPA

TPSRANGE_0_TOP:
     db     'Throttle Open % c0 %'
            ; "TPS_range" table, col 0, percent

TPSRANGE_1_TOP:
     db     'Throttle Open % c1 %'
            ; "TPS_range" table, col 1, percent

TPSRANGE_2_TOP:
     db     'Throttle Open % c2 %'
            ; "TPS_range" table, col 2, percent

TPSRANGE_3_TOP:
     db     'Throttle Open % c3 %'
            ; "TPS_range" table, col 3, percent

TPSRANGE_4_TOP:
     db     'Throttle Open % c4 %'
            ; "TPS_range" table, col 4, percent

TPSRANGE_5_TOP:
     db     'Throttle Open % c5 %'
            ; "TPS_range" table, col 5, percent

TPSRANGE_6_TOP:
     db     'Throttle Open % c6 %'
            ; "TPS_range" table, col 6, percent

TPSRANGE_7_TOP:
     db     'Throttle Open % c7 %'
            ; "TPS_range" table, col 7, percent

EPCSTALL_0_TOP:
     db     'EPCdf Stall c0 0-255'
            ; "EPC_stall" table, col 0, 0.5uS

EPCSTALL_1_TOP:
     db     'EPCdf Stall c1 0-255'
            ; "EPC_stall" table, col 1, 0.5uS

EPCSTALL_2_TOP:
     db     'EPCdf Stall c2 0-255'
            ; "EPC_stall" table, col 2, 0.5uS

EPCSTALL_3_TOP:
     db     'EPCdf Stall c3 0-255'
            ; "EPC_stall" table, col 3, 0.5uS

EPCSTALL_4_TOP:
     db     'EPCdf Stall c4 0-255'
            ; "EPC_stall" table, col 4, 0.5uS

EPCSTALL_5_TOP:
     db     'EPCdf Stall c5 0-255'
            ; "EPC_stall" table, col 5, 0.5uS

EPCSTALL_6_TOP:
     db     'EPCdf Stall c6 0-255'
            ; "EPC_stall" table, col 6, 0.5uS

EPCSTALL_7_TOP:
     db     'EPCdf Stall c7 0-255'
            ; "EPC_stall" table, col 7, 0.5uS

EPC12_0_TOP:
     db     'EPCdf 1-->2 c0 0-255'
            ; "EPC_12" table, col 0, 0.5uS

EPC12_1_TOP:
     db     'EPCdf 1-->2 c1 0-255'
            ; "EPC_12" table, col 1, 0.5uS

EPC12_2_TOP:
     db     'EPCdf 1-->2 c2 0-255'
            ; "EPC_12" table, col 2, 0.5uS

EPC12_3_TOP:
     db     'EPCdf 1-->2 c3 0-255'
            ; "EPC_12" table, col 3, 0.5uS

EPC12_4_TOP:
     db     'EPCdf 1-->2 c4 0-255'
            ; "EPC_12" table, col 4, 0.5uS

EPC12_5_TOP:
     db     'EPCdf 1-->2 c5 0-255'
            ; "EPC_12" table, col 5, 0.5uS

EPC12_6_TOP:
     db     'EPCdf 1-->2 c6 0-255'
            ; "EPC_12" table, col 6, 0.5uS

EPC12_7_TOP:
     db     'EPCdf 1-->2 c7 0-255'
            ; "EPC_12" table, col 7, 0.5uS

EPC23_0_TOP:
     db     'EPCdf 2-->3 c0 0-255'
            ; "EPC_23" table, col 0, 0.5uS

EPC23_1_TOP:
     db     'EPCdf 2-->3 c1 0-255'
            ; "EPC_23" table, col 1, 0.5uS

EPC23_2_TOP:
     db     'EPCdf 2-->3 c2 0-255'
            ; "EPC_23" table, col 2, 0.5uS

EPC23_3_TOP:
     db     'EPCdf 2-->3 c3 0-255'
            ; "EPC_23" table, col 3, 0.5uS

EPC23_4_TOP:
     db     'EPCdf 2-->3 c4 0-255'
            ; "EPC_23" table, col 4, 0.5uS

EPC23_5_TOP:
     db     'EPCdf 2-->3 c5 0-255'
            ; "EPC_23" table, col 5, 0.5uS

EPC23_6_TOP:
     db     'EPCdf 2-->3 c6 0-255'
            ; "EPC_23" table, col 6, 0.5uS

EPC23_7_TOP:
     db     'EPCdf 2-->3 c7 0-255'
            ; "EPC_23" table, col 7, 0.5uS

EPC34_0_TOP:
     db     'EPCdf 3-->4 c0 0-255'
            ; "EPC_34" table, col 0, 0.5uS

EPC34_1_TOP:
     db     'EPCdf 3-->4 c1 0-255'
            ; "EPC_34" table, col 1, 0.5uS

EPC34_2_TOP:
     db     'EPCdf 3-->4 c2 0-255'
            ; "EPC_34" table, col 2, 0.5uS

EPC34_3_TOP:
     db     'EPCdf 3-->4 c3 0-255'
            ; "EPC_34" table, col 3, 0.5uS

EPC34_4_TOP:
     db     'EPCdf 3-->4 c4 0-255'
            ; "EPC_34" table, col 4, 0.5uS

EPC34_5_TOP:
     db     'EPCdf 3-->4 c5 0-255'
            ; "EPC_34" table, col 5, 0.5uS

EPC34_6_TOP:
     db     'EPCdf 3-->4 c6 0-255'
            ; "EPC_34" table, col 6, 0.5uS

EPC34_7_TOP:
     db     'EPCdf 3-->4 c7 0-255'
            ; "EPC_34" table, col 7, 0.5uS

NOT_IMP1_TOP:
     db     'Cons Grp1  placehold'
            ; Out of range value for future expansion


;***************************************************************************
; - This is the second table of character strings for the top lines of the
;   VFD while in "Configure" mode.
;***************************************************************************

EPC_TCC_TOP:
     db     'EPCdf TCC App  0-255'
            ; EPC duty factor for TCC application

EPC_DECEL_TOP:
     db     'EPCdf DFC App  0-255'
            ; EPC duty factor for decel conditions

EPC_RISE_TOP;
     db     'EPC Rise Time   20mS'
            ; EPC rise time delay(20mS resolution)

EPC_HOLD_TOP:
     db     'EPC Hold Time   20mS'
            ; EPC hold time delay(20mS resolution)

SS1_DEL_TOP:
     db     'SS1 Delay Time  20mS'
            ; SS1 apply time delay(20mS res)(M2-D2 shift)

CCS_DEL_TOP:
     db     'CCS Delay Time  20mS'
            ; CCS apply/release time delay(20mS res)(D4 shifts)

SSs_DEL_TOP:
     db     'SSs Delay Time  20mS'
            ; SSs release time delay(20mS res)(D4 shifts)

EXBRK_DEL_TOP:
     db     'ExBrk Del Time  20mS'
            ; Exhaust Brake apply time delay(20mS res)

TCC_MIN_RPM_TOP:
     db     'RPM TCC Min   RPM/20'
            ; TCC apply minimum RPM permissive

MPH_STALL_TOP:
     db     'MPH Stall Max  MPH*2'
            ; MPH maximum for stall EPC

TPS_RATE_TOP:
     db     'TPS DOT Min   RPM/20'
            ; TPS DOT rate threshold for EPC stall settings

CT_CNT_TOP:
     db     'TPS Cls Thrt cnt ADC'
            ; Closed throttle position ADC count

WOT_CNT_TOP:
     db     'TPS WO Thrt cnt  ADC'
            ; Wide Open throttle position ADC count

TPS_SPAN_TOP;
     db     'TPS span (WOT - CT) '
            ; TPS span for TPS calibration(WOT_cnt - CT_cnt)

CT_MIN_TOP:
     db     'TPS Cls Thrt Min % %'
            ; Closed throttle position minimum %

;DITH_ADD_TOP:
;     db     'EPCPW Dither Adder  '
            ; EPC PW dither adder value

;BAT_FAC_TOP:
;     db     'Bat Volt Cor max val'
            ; EPC PW Battery Voltge Correction max value

TRIM_FAC_TOP:
     db     'EPC Trim Cor max val'
            ; EPC PW Trim Correction max value

TUNECONFIG_TOP:
     db     'Tun Config Bit Field'
            ; Tuning configuration bit field variable

RPMK_TOP:
     db     'RPMk Hi 6=039 8=029 '
            ; RPM constant Hi byte, 6cyl = $39, 8cyl = $29

RPMK+1_TOP:
     db     'RPMk Lo 6=016 8=076 '
            ; RPM constant Lo byte, 6cyl = $16, 8cyl = $76

TOTEMP_FAC_TOP:
     db     'TOT Temp cor max val'
            ; Trans Oil Temp correction max value

;AIAC_TOP:
;     db     'Auto IAC start IACpw'
            ; Auto IAC initial IACpw value

;AIAC_CMP_TOP:
;     db     'Auto IAC time 100mS '
            ; Auto IAC duration counter compare value

TOT_HI_TOP:
     db     'TOT cor rail Hi F-40'
            ; TOT correction Hi limit (degreesF - 40)

TOT_LO_TOP:
     db     'TOT cor rail Lo F-40'
            ; TOT correction Lo limit (degreesF - 40)

NOT_IMP2_TOP:
     db     'Cons Grp2  placehold'
            ; Out of range value for future expansion


;***************************************************************************
; - This table is the first 16 bit vector address index, for the tables of
;   the character strings, for the top lines of the VFD while in
;   "Configure" mode.
;***************************************************************************

G1_CONS_TL_TB_IND:
     dw     TO_0_0_TOP
     dw     TO_0_1_TOP
     dw     TO_0_2_TOP
     dw     TO_0_3_TOP
     dw     TO_0_4_TOP
     dw     TO_0_5_TOP
     dw     TO_0_6_TOP
     dw     TO_0_7_TOP
     dw     TO_1_0_TOP
     dw     TO_1_1_TOP
     dw     TO_1_2_TOP
     dw     TO_1_3_TOP
     dw     TO_1_4_TOP
     dw     TO_1_5_TOP
     dw     TO_1_6_TOP
     dw     TO_1_7_TOP
     dw     TO_2_0_TOP
     dw     TO_2_1_TOP
     dw     TO_2_2_TOP
     dw     TO_2_3_TOP
     dw     TO_2_4_TOP
     dw     TO_2_5_TOP
     dw     TO_2_6_TOP
     dw     TO_2_7_TOP
     dw     TO_3_0_TOP
     dw     TO_3_1_TOP
     dw     TO_3_2_TOP
     dw     TO_3_3_TOP
     dw     TO_3_4_TOP
     dw     TO_3_5_TOP
     dw     TO_3_6_TOP
     dw     TO_3_7_TOP
     dw     TO_4_0_TOP
     dw     TO_4_1_TOP
     dw     TO_4_2_TOP
     dw     TO_4_3_TOP
     dw     TO_4_4_TOP
     dw     TO_4_5_TOP
     dw     TO_4_6_TOP
     dw     TO_4_7_TOP
     dw     TO_5_0_TOP
     dw     TO_5_1_TOP
     dw     TO_5_2_TOP
     dw     TO_5_3_TOP
     dw     TO_5_4_TOP
     dw     TO_5_5_TOP
     dw     TO_5_6_TOP
     dw     TO_5_7_TOP
     dw     TO_6_0_TOP
     dw     TO_6_1_TOP
     dw     TO_6_2_TOP
     dw     TO_6_3_TOP
     dw     TO_6_4_TOP
     dw     TO_6_5_TOP
     dw     TO_6_6_TOP
     dw     TO_6_7_TOP
     dw     TO_7_0_TOP
     dw     TO_7_1_TOP
     dw     TO_7_2_TOP
     dw     TO_7_3_TOP
     dw     TO_7_4_TOP
     dw     TO_7_5_TOP
     dw     TO_7_6_TOP
     dw     TO_7_7_TOP
     dw     RPMRANGETO_0_TOP
     dw     RPMRANGETO_1_TOP
     dw     RPMRANGETO_2_TOP
     dw     RPMRANGETO_3_TOP
     dw     RPMRANGETO_4_TOP
     dw     RPMRANGETO_5_TOP
     dw     RPMRANGETO_6_TOP
     dw     RPMRANGETO_7_TOP
     dw     KPARANGETO_0_TOP
     dw     KPARANGETO_1_TOP
     dw     KPARANGETO_2_TOP
     dw     KPARANGETO_3_TOP
     dw     KPARANGETO_4_TOP
     dw     KPARANGETO_5_TOP
     dw     KPARANGETO_6_TOP
     dw     KPARANGETO_7_TOP
     dw     TPSRANGE_0_TOP
     dw     TPSRANGE_1_TOP
     dw     TPSRANGE_2_TOP
     dw     TPSRANGE_3_TOP
     dw     TPSRANGE_4_TOP
     dw     TPSRANGE_5_TOP
     dw     TPSRANGE_6_TOP
     dw     TPSRANGE_7_TOP
     dw     EPCSTALL_0_TOP
     dw     EPCSTALL_1_TOP
     dw     EPCSTALL_2_TOP
     dw     EPCSTALL_3_TOP
     dw     EPCSTALL_4_TOP
     dw     EPCSTALL_5_TOP
     dw     EPCSTALL_6_TOP
     dw     EPCSTALL_7_TOP
     dw     EPC12_0_TOP
     dw     EPC12_1_TOP
     dw     EPC12_2_TOP
     dw     EPC12_3_TOP
     dw     EPC12_4_TOP
     dw     EPC12_5_TOP
     dw     EPC12_6_TOP
     dw     EPC12_7_TOP
     dw     EPC23_0_TOP
     dw     EPC23_1_TOP
     dw     EPC23_2_TOP
     dw     EPC23_3_TOP
     dw     EPC23_4_TOP
     dw     EPC23_5_TOP
     dw     EPC23_6_TOP
     dw     EPC23_7_TOP
     dw     EPC34_0_TOP
     dw     EPC34_1_TOP
     dw     EPC34_2_TOP
     dw     EPC34_3_TOP
     dw     EPC34_4_TOP
     dw     EPC34_5_TOP
     dw     EPC34_6_TOP
     dw     EPC34_7_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP
     dw     NOT_IMP1_TOP

;***************************************************************************
; - This table is the second 16 bit vector address index, for the tables of
;   the character strings, for the top lines of the VFD while in
;   "Configure" mode.
;***************************************************************************

G2_CONS_TL_TB_IND:
     dw     EPC_TCC_TOP
     dw     EPC_DECEL_TOP
     dw     EPC_RISE_TOP
     dw     EPC_HOLD_TOP
     dw     SS1_DEL_TOP
     dw     CCS_DEL_TOP
     dw     SSs_DEL_TOP
     dw     EXBRK_DEL_TOP
     dw     TCC_MIN_RPM_TOP
     dw     MPH_STALL_TOP
     dw     TPS_RATE_TOP
     dw     CT_CNT_TOP
     dw     WOT_CNT_TOP
     dw     TPS_SPAN_TOP
     dw     CT_MIN_TOP
;     dw     DITH_ADD_TOP
;     dw     BAT_FAC_TOP
     dw     TRIM_FAC_TOP
     dw     TUNECONFIG_TOP
     dw     RPMK_TOP
     dw     RPMK+1_TOP
     dw     TOTEMP_FAC_TOP
;     dw     AIAC_TOP
;     dw     AIAC_CMP_TOP
     dw     TOT_HI_TOP
     dw     TOT_LO_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP
     dw     NOT_IMP2_TOP


;***************************************************************************
; - This table is the 16 bit vector address index, for the tables of the
;   character strings, for the top lines of the VFD while in "Display" mode.
;***************************************************************************

VARS_TL_TB_IND:
     dw     VARS0_TL_TB         ; ScrnCnt=0  'ML Gr CC TC FC EP EB'
     dw     VARS1_TL_TB         ; ScrnCnt=1  'RPM MPH Prs TOT Vlt '
     dw     VARS2_TL_TB         ; ScrnCnt=2  'DuF TPP PWH:PWL Prs '
     dw     VARS3_TL_TB         ; ScrnCnt=3  'SeH SeL IAC Ipw RPM '
     dw     VARS4_TL_TB         ; ScrnCnt=4  'RPM MAP TPP TrA DuF '
     dw     VARS5_TL_TB         ; ScrnCnt=5  'DuF TtA TrA DF1 DFF '
     dw     G1_CONS_TL_TB       ; ScrnCnt=6  'Cons Group1 Prs Mode'
     dw     G2_CONS_TL_TB       ; ScrnCnt=7  'Cons Group2 Prs Mode'
     dw     GET_G1_CONS         ; ScrnCnt=8  'UpLd G1 Cons Prs Mde'
     dw     GET_G2_CONS         ; ScrnCnt=9  'UpLd G2 Cons Prs Mde'
     dw     SEND_G1_VAL         ; ScrnCnt=10 'DnLd G1 val Prs Mode'
     dw     SEND_G2_VAL         ; ScrnCnt=11 'DnLd G2 val Prs Mode'
     dw     BURN_CONS           ; ScrnCnt=12 'Burn Cons Press Mode'
     dw     GET_G1_CONS_FIN     ; ScrnCnt=13 'UpLd G1 Done Prs Mde'
     dw     GET_G2_CONS_FIN     ; ScrnCnt=14 'UpLd G2 Done Prs Mde'
     dw     SEND_G1_VAL_FIN     ; ScrnCnt=15 'DnLd V1 Done Prs Mde'
     dw     SEND_G2_VAL_FIN     ; ScrnCnt=16 'DnLd V2 Done Prs Mde'
     dw     BURN_CONS_FIN       ; ScrnCnt=17 'Burn Done Press Mode'

;****************************************************************************
; - Interrupt Vector table
;****************************************************************************

     org     vec_timebase  ; Origin at $FFDC = 65500


	dw	Dummy          ;Time Base Vector
	dw	Dummy          ;ADC Conversion Complete
	dw	Dummy          ;Keyboard Vector
	dw	SCITX_ISR      ;SCI Transmit Vector
	dw	SCIRCV_ISR     ;SCI Receive Vector
	dw	Dummy          ;SCI Error Vecotr
	dw	Dummy          ;SPI Transmit Vector
	dw	Dummy          ;SPI Receive Vector
	dw    Dummy          ;TIM2 Overflow Vector
	dw	Dummy          ;TIM2 Ch1 Vector
	dw	TIM2CH0_ISR    ;TIM2 Ch0 Vector
	dw	Dummy          ;TIM1 Overflow Vector
	dw	Dummy          ;TIM1 Ch1 Vector
	dw	Dummy          ;TIM1 Ch0 Vector
	dw	Dummy          ;PLL Vector
	dw	Dummy          ;IRQ Vector
	dw	Dummy          ;SWI Vector
	dw	Start          ;Reset Vector

	end

