;---------------------------------------------------------------------
; File:     armkey.s
;
; Function: This program reads input from an ASCII file and then outpus
;           the text to an output ASCII file with modified results.
;           All alpha characters will be output as capital characters and
;           non-alpha characters will be discarded except for spaces.
;           The EOF character from the input file will stop execution and
;           exit the program.
;
;           ARM SWI read assumes the file uses CR/LF as the end of line sequence
;           which will be replaced with single binary 0 (used to indicate the
;           End of Line during processing).
;
;           Program Function:
;           - It opens an imput file named key.in
;           - It opens an output file named key.out
;           - It reads one line of text from the input file
;           - Upper case letters (A-Z) are moved to the output string
;           - Lower case letters (a-z) made upper case then moved to output string
;           - Blank characters (20h) are moved to the output string
;           - Hex zero (00h) is moved to output string and signals End of Line (EOL)
;           - At EOL, a CR/LF is added to the output string and string is moved
;             to output file
;           - It closes the input and output file
;
; Author:   David Hines
;
; Changes:  Date        Reason
;           ----------------------------------------------------------
;           04/20/2021  Original version
;
;
;---------------------------------------------------------------------


;----------------------------------
; Software Interrupt values
;----------------------------------
         .equ swiOpen,   0x66     ;Open  a file
         .equ swiClose,  0x68     ;Close a file
         .equ swiPrstr,  0x69     ;Write a null-ending string
         .equ swiRdstr,  0x6a     ;Read a string and terminate with null char
         .equ swiExit,   0x11     ;Stop execution
;----------------------------------

         .global   _start
         .text

_start:
;----------------------------------
; open input file
; - r0 points to the file name
; - r1 0 for input
; - the open swi is 66h
; - after the open r0 will have the file handle
;----------------------------------
         ldr  r0, =inKey          ;r0 points to the Key.in file name
         ldr  r1, =0              ;r1 =0 specifies the file is input
         swi  swiOpen             ;open the file ... r0 will be the file handle
         ldr  r1, =inKeyHndl      ;r1 points to handle location
         str  r0, [r1]            ;store the file handle
;----------------------------------


;----------------------------------
; open output file
; - r0 points to the file name
; - r1 1 for output
; - the open swi is 66h
; - after the open r0 will have the file handle
;----------------------------------
         ldr  r0, =outKey         ;r0 points to the file name
         ldr  r1, =1              ;r1 = 1 specifies the file is output
         swi  swiOpen             ;open the file ... r0 will be the file handle
         ldr  r1, =outKeyHndl     ;r1 points to output handle variable location
         str  r0, [r1]            ;store the file handle
;----------------------------------


;----------------------------------
; read a string from the input file
; - r0 contains the file handle
; - r1 points to the input string buffer
; - r2 contains the max number of characters to read
; - the read swi is 6ah
; - the input string will be terminated with 0
;----------------------------------
_read:
         ldr  r0, =inKeyHndl      ;r0 points to the input file handle
         ldr  r0, [r0]            ;r0 has the input file handle
         ldr  r1, =InString       ;r1 points to the input string
         ldr  r2, =80             ;r2 has the max size of the input string
         swi  swiRdstr            ;read a string from the input file
         cmp  r0,#0               ;no characters read means EOF
         beq  _exit               ;so close and exit
;----------------------------------


;----------------------------------
; Move the input string to the output string
; This code uses post increment of the input pointer,
; but not for the output pointer ... just to show both techniques
;----------------------------------
         ldr  r0, =InString       ;r0 points to the input  string
         ldr  r1, =OutString      ;r1 points to the output string
         ldr  r3, =LkupTbl        ;r3 points to the lookup table
_loop:                            ;
         ldrb r2, [r0]            ;load the value at r0 address into r2
         cmp  r2, #0              ;was it the null terminator
         beq  _finloop            ;yes ... end loop
                                  ;
         ldrb r2, [r3, r2]        ;get the next input byte and convert byte
                                  ;.... using LkupTbl pointed to by r3

         add r0, r0, #1           ;increment the InString pointer r0
         cmp r2, #42              ;compare to '*' and skip if equal
         beq  _skip               ;
         strb r2, [r1], #1        ;otherwise store r2 in the output buffer
                                  ;....and post increment the output pointer
_skip:
         b    _loop               ;loop
_finloop:                         ;
         strb r2, [r1], #1        ;output null terminator before moving on
;----------------------------------


;----------------------------------
; Write the output string
;----------------------------------
_write:                           ;
         ldr  r0, =outKeyHndl     ;r0 points to the output file handle
         ldr  r0, [r0]            ;r0 has the output file handle
         ldr  r1, =OutString      ;r1 points to the output string
         swi  swiPrstr            ;write the null terminated string
                                  ;
         ldrb r1, [r1]            ;get the first byte of the line
         cmp  r1, #0x1A           ;if line was DOS eof then do not write CRLF
         beq  _read               ;so do next read
                                  ;
         ldr  r1, =CRLF           ;r1 points to the CRLF string
         swi  swiPrstr            ;write the null terminated string
                                  ;
         bal  _read               ;read the next line
;----------------------------------


;----------------------------------
; Close input and output files
; Terminate the program
;----------------------------------
_exit:                            ;
         ldr  r0, =inKeyHndl      ;r0 points to the input file handle
         ldr  r0, [r0]            ;r0 has the input file handle
         swi  swiClose            ;close the file
                                  ;
         ldr  r0, =outKeyHndl     ;r0 points to the output file handle
         ldr  r0, [r0]            ;r0 has the output file handle
         swi  swiClose            ;close the file
                                  ;
         swi  swiExit             ;terminate the program
;----------------------------------


         .data
;--------------------------------------------------------
inKeyHndl:     .skip 4                                  ;4 byte field to hold the input file handle
outKeyHndl:    .skip 4                                  ;4 byte field to hold the output file handle
                                                        ;
inKey:         .asciz "KEY.IN"                          ;Input  file name, null terminated
                                                        ;
InString:      .skip 80                                 ;reserve 80 bytes for input string
OutString:     .skip 80                                 ;reserve 80 bytes for output string
                                                        ;
CRLF:          .byte 13, 10, 0                          ;CR LF
                                                        ;
outKey:        .asciz "KEY.OUT"                         ;Output file name, null terminated
                                                        ;
LkupTbl:       .byte  0x00                              ;
               .ascii "*******************************" ;
               .ascii " "                               ;
               .ascii "********************************";
               .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"      ;
               .ascii "******"                          ;
               .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"      ;
               .ascii "*****"                           ;
;--------------------------------------------------------


         .end
