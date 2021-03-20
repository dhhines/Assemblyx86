;------------------------------------------------------------------------
;   Program:  Tabs (MASM version)
;
;   Function: Tabs reads ASCII characters from a text file that is
;             redirected from Standard Input, edits the lines with
;             the proper spacing and outputs the updated lines of text
;             to an ASCII text file which is redirected from Standard
;             Output.
;
;             The spacing for the text is determined by the tab stop
;             position which will replace any tab characters (O9h) in the
;             file with the default of 10 space characters (20h).
;
;             Optionally, the user can input a tab space parameter at the
;             command line with the values of 1 through 9 which will
;             change the default of 10 spaces to the input value.
;
;             Each line of text is processed using the following rules:
;             - All characters in the range of 20h-7Fh will be written
;               to the output file except for tab characters 09h
;             - Tab characters will be expanded to the proper number of
;               spaces as defined by the default or command line values
;               and then will continue outputting text
;             - If the provided text file does not contain any tabs then
;               the output file will be a byte for byte replica of the
;               input file
;
;             Notes about the program specification:
;             - Input files will contain 0 or more lines and there is
;               no limit to the number of lines or characters
;             - The first character of each line will be at position 0
;             - This program handles ASCII characters from 20h-7Fh
;             - The program also handles specific control characters
;               which are tab(09h), line feed (0Ah), carriage return (0Dh),
;               and the DOS End of File (EOF = 1Ah).
;             - All lines of text will end with the 0D0Ah pair and will
;               never appear as individual characters
;             - Files will always terminate with the EOF character 1Ah
;
;   Owner:    DHH
;
;   Date      Reason
;   -----     ------
;   03/06/21  Original version
;
;------------------------------------------------
         .model     small                       ; 64k code and 64k data
         .8086                                  ; only allow 8086 instructions
         .stack     256                         ; reserve 256 bytes for the stack
;------------------------------------------------


;------------------------------------------------
         .data                                  ; start the data segment
;------------------------------------------------
eof_ch   db        1Ah                          ; DOS end of file (EOF) character
asc_lf   db        0Ah                          ; ASCII line feed character
asc_tb   db        09h                          ; ASCII tab character
asc_sp   db        20h                          ; ASCII space character
num_sp   db        10                           ; Default number of spaces is 10
count    db        0                            ; count of characters output before tab
digdec   db        48                           ; subtract from ASCII digit to get decimal value
valtbl   db        49 dup(10)                   ; Indirect addressing table for clp
         db        1                            ; decimal value for ASCII digit 1
         db        2                            ; decimal valut for ASCII digit 2
         db        3                            ; decimal valut for ASCII digit 3
         db        4                            ; decimal valut for ASCII digit 4
         db        5                            ; decimal valut for ASCII digit 5
         db        6                            ; decimal valut for ASCII digit 6
         db        7                            ; decimal valut for ASCII digit 7
         db        8                            ; decimal valut for ASCII digit 8
         db        9                            ; decimal valut for ASCII digit 9
         db        198 dup(10)                  ; remainder of table has decimal 10 as value
spcstr   db        10 dup(20h),'$'              ; String of 10 spaces terminated by '$'
;------------------------------------------------


;------------------------------------------------
         .code                                  ; start the code segment
;------------------------------------------------
start:                                          ; label for start of program execution
         mov       ax,@data                     ; establish the addressability to the
         mov       ds,ax                        ; data segment for the Tabs program
         mov       si, offset spcstr            ; initialize si pointer to spcstr offset    //THIS IS WHERE I AM GOING WRONG  NEED TO OFFSET INTO STRING BASED ON #SPACES input
;------------------------------------------------                                           //RIGHT NOW I AM ALWAYS STARTING AT THE ZEROTH POSITION REGARDLESS>>> DUH


;------------------------------------------------
; Get command line parameter (clp) if one provided
;------------------------------------------------
getclp:                                         ; label for code to capture clp if exists
         mov        bx,0                        ; Clear the bx register
         mov        bl,byte ptr es:[82h]        ; store the byte at 82h in bl
         mov        dh,[valtbl + bx]            ; set dh to the value at offset plus byte in bx
         mov        [num_sp], dh                ; save the number of spaces in num_sp data byte
;------------------------------------------------

;------------------------------------------------
; resets the counter to 0 then falls thru to getchar
;------------------------------------------------
rstcntr:                                        ; Label for the reset counter routine
         mov       [count], 0                   ; ; replace the current count with zero
;------------------------------------------------
; Read in a character without echo.
;------------------------------------------------
getchar:                                        ; label for get next character loop start
         mov       ah,8                         ; reads input of character without echo
         int       21h                          ; by setting ah=8 and interrupt 21h
         cmp       al,[asc_tb]                  ; Compare to tab character and if not equal
         jne       output                       ; ..... jump to output character
                                                ; ..... otherwise fall through to exptab label
;------------------------------------------------


;------------------------------------------------
; Routine for handling tab character and expanding to spaces
;------------------------------------------------
exptab:                                         ; Label for expand tab to spaces routine
         mov       ax,0                         ; clear the ax register for use
         mov       al,[count]                   ; move the current count into al
         div       [num_sp]                     ; divide al by tab stop position spaces number
         mov       bx,0                         ; Clear the bx register
         mov       bl,ah                        ; Move the number of bytes already output in ah into bl
         lea       dx, [si + bx]                ; lea the si pointer plus number of bytes already output
         mov       ah,9                         ; set ah=9 to prepare to output of string
         int       21h                          ; Interrupt 21h to output to stdout
         jmp       rstcntr                      ; Jump to rstcnt to set count=0 and get next character
;------------------------------------------------



;------------------------------------------------
; Output the character and if period move on to exit
;------------------------------------------------
 output:                                        ; Output label for printing character
         mov       dl,al                        ; Move the input to dl register for processing
         mov       ah,2                         ; Set ah=2 to prepare to output character in dl
         int       21h                          ; Interrupt 21h to output to stdout
         inc       [count]                      ; Increment the counter for output characters
         cmp       dl,[asc_lf]                  ; Compare to line feed character
         je        rstcntr                      ; .... jump to reset counter routine
         cmp       dl,[eof_ch]                  ; Determine if dl holds EOF character
         jne       getchar                      ; if no EOF, get the next character
                                                ; .... otherwise fall through to exit label
;------------------------------------------------


;------------------------------------------------
; terminate program execution after term character
;------------------------------------------------
exit:                                           ; label for exit of proram
         mov       ax,4c00h                     ; set DOS code to terminate program
         int       21h                          ; return to DOS
         end       start                        ; end of the program and mark of start
;------------------------------------------------