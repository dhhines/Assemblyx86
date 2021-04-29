;--------------------------------------------------------------------
;   Program:  MOV (MASM version)
;
;   Function: The MOV program is a exercise illustrating the way an
;             architecture can be complete in capability while using
;             only the most basic Opcodes such as mov and int.
;
;             The MOV program reads three ASCII characters in from keyboard
;             input as X, Y and Z.
;
;             X is 'A-Z' or '0-9' charachter
;             Y is '0-9' character
;             Z is '+' or some other character
;
;             The Y value is converted to the digit hex equivalent using a
;             conversion table (indirect addressing) and then added to the
;             X value.
;
;             The MOV program will output X+Y if Z='+' or X if Z!='+'
;
;             Through a series of mov operations and using specially crafted
;             lookup tables the program is able to perform conditional operations
;             without requiring the use of CMP or JMP operations.
;
;   Owner:    David Hines
;
;   Date      Reason
;   -----     ------
;   04/28/21  Original version
;
;------------------------------------------------
         .model     small                       ; 64k code and 64k data
         .8086                                  ; only allow 8086 instructions
         .stack     256                         ; reserve 256 bytes for the stack
;------------------------------------------------


;------------------------------------------------
         .data                                  ; start the data segment
;------------------------------------------------
x        db        0                            ;variable x
dum_x    db        0                            ;dummy variable
y        db        0                            ;variable y
z        db        0                            ;variable z
plus     db        2Bh                          ;set to '+' ASCII hex value
lkup     db        48 dup (0)                              ;lookup table to conver hex
         db        00h,01h,02h,03h,04h,05h,06h,07h,08h,09h ;.... from ASCII digits to integers
addtbl   db        000,001,002,003,004,005,006,007,008,009 ;
         db        010,011,012,013,014,015,016,017,018,019 ;
         db        020,021,022,023,024,025,026,027,028,029 ;
         db        030,031,032,033,034,035,036,037,038,039 ;
         db        040,041,042,043,044,045,046,047,048,049 ;
         db        050,051,052,053,054,055,056,057,058,059 ;
         db        060,061,062,063,064,065,066,067,068,069 ;
         db        070,071,072,073,074,075,076,077,078,079 ;
         db        080,081,082,083,084,085,086,087,088,089 ;
         db        090,091,092,093,094,095,096,097,098,099 ;
         db        100,101,102,103,104,105,106,107,108,109 ;
         db        110,111,112,113,114,115,116,117,118,119 ;
         db        120,121,122,123,124,125,126,127,128     ;
                                                           ;
;-----------------------------------------------------------


;------------------------------------------------
         .fardata                               ;256 bytes of work memory for selection code
;------------------------------------------------
         db        256 dup(0)                   ;byte vars need 256 bytes of work memory
;------------------------------------------------


;------------------------------------------------
         .code                                  ; start the code segment
start:   mov       ax,@data                     ;initialize
         mov       ds,ax                        ; the ds register
         mov       ax,@fardata                  ;initialize
         mov       es,ax                        ; the es register
         mov       bx,0                         ;clear the bx register
         mov       cx,0                         ;clear the cx register
;------------------------------------------------


;------------------------------------------------
; Read and echo the X input to the console
;------------------------------------------------
         mov       ah,8                         ;read code
         int       21h                          ;read interrupt
         mov       [x],al                       ;save x
         mov       dl,al                        ;ready to echo x
         mov       ah,2                         ;write code
         int       21h                          ;write interrupt
;------------------------------------------------

;------------------------------------------------
; Read and echo the Y input to the console
;------------------------------------------------
         mov       ah,8                         ;read code
         int       21h                          ;read interrupt
         mov       [y],al                       ;save x
         mov       dl,al                        ;ready to echo x
         mov       ah,2                         ;write code
         int       21h                          ;write interrupt
;------------------------------------------------

;------------------------------------------------
; Read and echo the Z input to the console
;------------------------------------------------
         mov       ah,8                         ;read code
         int       21h                          ;read interrupt
         mov       [z],al                       ;save x
         mov       dl,al                        ;ready to echo x
         mov       ah,2                         ;write code
         int       21h                          ;write interrupt
;------------------------------------------------


;------------------------------------------------
; Convert the y value and calculate x + y
;-------------------------------------------------
         mov       bl, [y]                      ;move [y] into bl register
         mov       cl, [lkup + bx]              ;convert digit to hex value and store in cl
         mov       si, cx                       ;move the converted value from cx to si
         mov       bl, [x]                      ;load [x] into the bl register
         mov       cl, [addtbl + bx + si]       ;get the value of [x] + [y] into cl register

;------------------------------------------------


;------------------------------------------------
; Determine if z=='+''
; if (z=='+') then x=al else dum_x=al
;------------------------------------------------
         mov       bl,[plus]                    ;bx pts to es memory addr=[plus]
         mov       byte ptr es:[bx],1           ;es memory at memory addr=[plus] set to 1
                                                ;
         mov       bl,[z]                       ;bx pts to es memory addr=[z]
         mov       byte ptr es:[bx],0           ;es memory at memory addr=[z] set to 0
                                                ;
         mov       bl,[plus]                    ;bx pts to es memory addr[plus]
         mov       bl,es:[bx]                   ;bx=0 if (z=='+')  bx=1 if (z!='+')
                                                ;
         mov       byte ptr[x+bx],cl            ;x=x+y if (z=='+')  dum_x=x if (z!='+')
;------------------------------------------------


;------------------------------------------------
; Output the value of either X+Y or X
;------------------------------------------------
         mov       ah,2                         ;write code
         mov       dl,[x]                       ;write x
         int       21h                          ;write interrupt
;------------------------------------------------


;------------------------------------------------
; Terminate the program
;------------------------------------------------
         mov       ax,4c00h                     ;get the termination code
         int       21h                          ;terminate
                                                ;
         end       start                        ;end program
;------------------------------------------------



