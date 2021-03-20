;--------------------------------------------------------------------
;   Program:  Key (MASM version)
;
;   Function: Key reads ASCII characters in the range of 20h-7Fh from
;             Standard Input (which can be from keyboard or redirected
;             ASCII text file) without echo (ah=08h and int 21h).
;
;             Characters input to Key are processed immediately, one
;             by one, as they read in from Standard Input (stdin).
;
;             Each character is processed using the following rules:
;             - Characters that are uppercase b/w A - Z are written to
;               Standard Output (stdout)
;             - Characters that are lowercase b/w a - z are converted
;               to the uppercase letter and printed to stdout
;             - Blank (20h) and period (2Eh) are printed to stdout
;             - All other characters input are discarded and Key moves
;               on to the next input character
;             - Key ends processing after reading a period (2Eh) and
;               printing that period to stdout
;
;             Notes about the program specification:
;             - This program only handles ASCII characters in the
;               range of 20h-7Fh
;             - The program output must have the terminating period
;             - No special ASCII characters will be handled such as
;               F1 - F12 keys which generate two calls
;             - There are NO output messages or prompts to the user!
;               It is expected that the user has read the program
;               documentation and understands the program function
;
;   Owner:    DHH
;
;   Date      Reason
;   -----     ------
;   02/26/21  Original version
;
;---------------------------------------
         .model     small              ; 64k code and 64k data
         .8086                         ; only allow 8086 instructions
         .stack     256                ; reserve 256 bytes for the stack
;---------------------------------------


;------------------------------------------------
         .data                                  ; start the data segment
;------------------------------------------------
term_ch  db        2Eh                          ; termination character
spc_ch   db        20h                          ; space character
trnslt   db        32 dup ('!')                 ; Translate table to convert everything
         db        ' '                          ; ....that is not letter to ! for easy cmp
         db        13 dup ('!')                 ; ....all valid characters (period, space, uppercase)
         db        '.'                          ; ....are translated to same value
         db        18 dup ('!')                 ; Lowercase letters are translated to
         db        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ; ....the uppercase equivalent
         db        6 dup ('!')                  ; All other characters are set to !
         db        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ; ....this allows for easy cmp and jumps
         db        133 dup ('!')                ; Values align with dec equiv in ASCII table
;------------------------------------------------


;------------------------------------------------
         .code                                  ; start the code segment
;------------------------------------------------
start:                                          ; label for start of program execution
         mov       ax,@data                     ; establish the addressability to the
         mov       ds,ax                        ; data segment for the Key program
         mov       bx,offset trnslt             ; Point bx to trnslt table offset
;------------------------------------------------
; Read in a character without echo.
;------------------------------------------------
getchar:                                        ; label for get next character loop start
         mov       ah,8                         ; reads input of character without echo
         int       21h                          ; by setting ah=8 and interrupt 21h
;------------------------------------------------
; Input character is now ready to process in al
; to determine print, change or ignore or end
;------------------------------------------------


;------------------------------------------------
; Check character to determine if it is printed
; or will be converted to uppercase or if it
; will be discarded.  If character is 2Eh then end
;------------------------------------------------
         xlat                                   ; Translate character using trnslt table
         cmp       al,'!'                       ; Compare to ! character and if equal
         je        getchar                      ; ..... jump to get next character
         mov       dl,al                        ; Move the input to dl register for processing
;------------------------------------------------


;------------------------------------------------
; Output the character and if period move on to exit
;------------------------------------------------
 output:                                        ; Output label for printing character
         mov       ah,2                         ; Set ah=2 to prepare to output character in dl
         int       21h                          ; Interrupt 21h to output to stdout
         cmp       dl,[term_ch]                 ; Determine if dl holds term char period
         jne       getchar                      ; if no period, get the next character
;------------------------------------------------


;------------------------------------------------
; terminate program execution after term character
;------------------------------------------------
exit:                                           ; label for exit of proram
         mov       ax,4c00h                     ; set DOS code to terminate program
         int       21h                          ; return to DOS
         end       start                        ; end of the program and mark of start
;------------------------------------------------