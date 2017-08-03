;-------------------------------------------------------------------------------------
; FILE: Lab 4 ENGR270
; DESC: Modification of Interrupt Example
; DATE: 8-3-17
; AUTH: Jessi Iler, Kevin Black
; DEVICE: PICmicro (PIC18F1220)
;-------------------------------------------------------------------------------------
 list p=18F1220 ; processor type
 radix hex ; default radix for data
 config WDT=OFF, LVP=OFF, OSC = INTIO2 ; Disable Watchdog timer, Low V. Prog, and RA6 as a clock
#include p18f1220.inc ; This header file includes address and bit definitions for all SFRs
#define countID 0x80
#define countOD 0x81
 org 0x000 ; Executes after reset
 GOTO StartL
 org 0x008 ; Executes after high priority interrupt
 GOTO HPRIO
 org 0x018 ; Executes after low priority interrupt
 GOTO LPRIO
 org 0x20
 
HPRIO: ; high priority interrupt
 ADDLW .5 ; when interrupt 0 occurs 
 BCF PORTB,4 ;Disable right
 BSF PORTB,3 ;Enable left
 MOVLW .20
 CALL Delay
 BCF PORTB,4 ;Disable right
 BCF PORTB,3 ;Disable left
 BCF INTCON, INT0IF ; Clear Interrupt
 RETFIE ; Return from interrupt

LPRIO: ; Low priority interrupt
 BTFSC INTCON3, INT1IF ; Check for Interrupt 1
 BRA Intr1
 RETFIE ; Return from interrupt
Intr1: ; take care of Interrupt 1
 ADDLW 0xFB ; W?(W-5). {note: SUBLW .5 will not work}
 BCF PORTB,3 ;Disable left
 BSF PORTB,4 ;Enable right
 MOVLW .20
 CALL Delay
 BCF PORTB,3 ;Disable left
 BCF PORTB,4 ;Disable right
 BCF INTCON3, INT1IF ; Clear interrupt 1 flag
 RETFIE ; Return from interrupt

StartL: ; Initialization code to be executed during reset
 ; Initialize all I/O ports
 CLRF PORTA ; Initialize PORTA
 CLRF PORTB ; Initialize PORTB
 MOVLW 0x7F ; Set all A\D Converter Pins as
 MOVWF ADCON1 ; digital I/O pins
 MOVLW 0x0D ; Value used to initialize data direction
 MOVWF TRISA ; Set Port A direction
 MOVLW 0xC7 ; Value used to initialize data direction 
 MOVWF TRISB ; Set Port B direction
 MOVLW 0x00 ; clear Wreg
 ; Enable NT0 and INT1
 BSF INTCON, GIEL ; enable low priority interrupts
 BSF INTCON, INT0IE ; enable INT0
 BSF INTCON3, INT1IE ; enable INT1
 BCF INTCON3, INT1IP ; INT1 is set to low priority
 BSF RCON, IPEN ; enable priority levels on interrupts
 BCF INTCON, INT0IF ;flags must be cleared to allow an interrupt
 BCF INTCON3, INT1IF ;
 BSF INTCON, GIEH ; enable high priority interrupts
 MOVLW .5 ; Set starting delay to 0.5 seconds

MainL: ;Main loop
 BTG PORTB,5 ; LED Toggle
 CALL Delay
 BRA MainL ; probably should be GOTO?
;Function to delay for Wreg x 0.1 seconds

Delay:
 MOVWF countOD
DelayOL: ; delay Outer loop
 CLRF countID
DelayIL: ; Delay Inner Loop
 INCF countID
 BNZ DelayIL
 DECF countOD
 BNZ DelayOL
 RETURN ; end delay function
 end ; end of program


