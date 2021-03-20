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
         db        1                            ;
         db        2                            ;
         db        3                            ;
         db        4                            ;
         db        5                            ;
         db        6                            ;
         db        7                            ;
         db        8                            ;
         db        9                            ;
         db        198 dup(10)                  ;
;------------------------------------------------


;------------------------------------------------
         .code                                  ; start the code segment
;------------------------------------------------
start:                                          ; label for start of program execution
         mov       ax,@data                     ; establish the addressability to the
         mov       ds,ax                        ; data segment for the Tabs program
;------------------------------------------------


;------------------------------------------------
; Get command line parameter (clp) if one provided
;------------------------------------------------
getclp:                                         ; label for code to capture clp if exists
         cmp        byte ptr es:[80h], 0        ; compare the bytes in extra segment to 0
         mov        bl, [num_sp]
         je         getchar                     ; If no clp then jump to getchar
         mov        bl, byte ptr es:[82h]       ; move the clp to the bl register          //NOTE-Should probably create table and use SI
         sub        bl, [digdec]                ; convert from ASCII to decimal for digits
;------------------------------------------------

;------------------------------------------------
; clears the counter then falls thru to getchar
;------------------------------------------------
clrcntr:                                        ; Label for the clear counter routine
         mov       [count], 0                   ; replace the current count with zero
;------------------------------------------------
; Read in a character without echo.
;------------------------------------------------
getchar:                                        ; label for get next character loop start
         mov       ah,8                         ; reads input of character without echo
         int       21h                          ; by setting ah=8 and interrupt 21h
         cmp       al,[asc_tb]                  ; Compare to tab character and if not equal
         jne       output                       ; ..... jump to output character
                                                ; ..... otherwise fall through to setspcs label
;------------------------------------------------


;------------------------------------------------
; Routine for handling tab character and expanding to spaces
;------------------------------------------------
setspcs:                                        ; Label for set spaces routine
         mov       cl, bl                       ; Move the
         mov       ch, 0                        ; ... and ensure cx register is zero since count is data byte
         sub       cl, [count]                  ; subtract count for proper tab stop position
         mov       dl, [asc_sp]                 ; move the space ASCII value into dl register
looptop:                                        ; Label for top of loop outputing spaces
         mov       ah,2                         ; set ah=2 to prepare to output character in dl
         int       21h                          ; Interrupt 21h to output to stdout
         loop      looptop                      ; Loop until cx is zero
         mov       [count], 0                   ; Clear the counter
         jmp       getchar                      ; Jump to get the next character from stdin
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
         je        clrcntr                      ; .... jump to clear counter routine
         cmp       bl,[count]                   ; Compare count to number spaces
         jb        clrcntr                      ; .... jump to clear counter if CF=1
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