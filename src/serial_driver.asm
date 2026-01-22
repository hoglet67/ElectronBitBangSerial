;;
;; A simple bit-banged serial output driver for the Electron Plus 1
;;
;;
;; 115200 baud 8N1 output to bit 7 of the printer Electron Plus 1
;; Printer Port
;;
;; Bit order:
;;   0 D0 D1 D2 D3 D4 D5 D6 D7 1
;;
;; Ideal timing is 8.68us per bit:
;;  0 ( 0.00) - Start
;;  9 ( 8.68) - D0
;; 17 (17.36) - D1
;; 26 (26.04) - D2
;; 35 (34.72) - D3
;; 43 (43.40) - D4
;; 52 (52.08) - D5
;; 61 (60.76) - D6
;; 69 (69.44) - D7
;; 78 (78.12) - Stop
;;
;; Will only work in MODE 4..7 (1MHz no contention)

port = &FC71

wrchv = &20E

org &A80

.start

.serial_install
        PHP
        SEI
        LDA wrchv
        STA patch+1
        LDA wrchv+1
        STA patch+2
        LDA #<serial_out
        STA wrchv
        LDA #>serial_out
        STA wrchv + 1
        PLP
        RTS

.serial_out

        PHP
        SEI             ; disable interrupts
        PHA

        CLC
        ROR A
        STA port        ; Start bit at time 0

        ROR A           ; 2
        BIT &00         ; 3
        STA port        ; 4 D0 at time 9

        ROR A           ; 2
        NOP             ; 2
        STA port        ; 4 D1 at time 17

        ROR A           ; 2
        BIT &00         ; 3
        STA port        ; 4 D2 at time 26

        ROR A           ; 2
        BIT &00         ; 3
        STA port        ; 4 D3 at time 35

        ROR A           ; 2
        NOP             ; 2
        STA port        ; 4 D4 at time 43

        ROR A           ; 2
        BIT &00         ; 3
        STA port        ; 4 D5 at time 52

        ROR A           ; 2
        BIT &00         ; 3
        STA port        ; 4 D6 at time 61

        ROR A           ; 2
        NOP             ; 2
        STA port        ; 4 D7 at time 69

        LDA #&FF        ; 2
        BIT &00         ; 3
        STA port        ; 4 Stop at time 78

        PLA
        PLP
.patch
        JMP &0000       ; Jump to original OSWRCH

.end

SAVE "SERIAL", start, end, &FF0000+start, &FF0000+start
