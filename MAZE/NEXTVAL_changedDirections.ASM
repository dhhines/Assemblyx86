;---------------------------------------------------------------------
; Program:   nextval subroutine
;
; Function:  Find next mouse move in an array 15 by 30.
;            We can move into a position if its contents is blank ( 20h ).
;
; Input:     Calling sequence is:
;            x    pointer   si
;            y    pointer   di
;            dir  pointer   bx
;            maze pointer   bp
;
; Output:    x,y,dir modified in caller's data segment
;
; Owner:     Dana A. Lasher
;
; Date:      Update Reason
; --------------------------
; 11/06/2016 Original version
;
;
;-------------------------------------------------
         .model    small                         ;64k code and 64k data
         .8086                                   ;only allow 8086 instructions
         public    nextval                       ;allow extrnal programs to call
;-------------------------------------------------


;-------------------------------------------------
         .data                                   ;start the data segment
;-------------------------------------------------
rows     db        15                            ; Maze rows constant
cols     db        30                            ; Maze columns constant
x        db        ?                             ; converted x coordinate
y        db        ?                             ; converted y coordiante
dir      db        ?                             ; Holds current direction of bx at start of subroutine
maze     db        ?                             ; Used to reference the bp offset
dirtbl   dw        nth, est, sth, wst            ; Jump table for direction at bx pointer
                                                 ; ... using dirtbl offset into dataseg
                                                 ; ... plus bx register minus 1
                                                 ; ... will jump to label of loop with North at top
loctbl   db        0,0,1,2,3,4,5,6,7,8,9,10,     ;
                   11,12,13,14,15,16,17,18,19,   ;
                   20,21,22,23,24,25,26,27,28,   ;
                   29
loc      dw        ?                             ; Location data word for storing linear address of mouse in maze (0 - 449)
xtbl     db
ytbl     db
;-------------------------------------------------
         .code                                   ;start the code segment
;-------------------------------------------------
; Save any modified registers
;-------------------------------------------------
nextval:                                         ;
         push      ax                            ; Save ax register on the stack
         push      dx                            ; Save the dx register on the stack
                                                 ;
;-------------------------------------------------
; Code to calculate linear location of mouse in maze (0 to 449)
;-------------------------------------------------
         ;mov       [dir], [bx]                   ; Save the current direction value from bx address pointer
         ;mov       bx, offset loctbl             ; Point bx register to the offset for loctbl
         ;mov       al, [si]                      ; Move the value in si register (x position) into al
         ;xlat                                    ; Xlat the value in al register using loctbl values
         ;mov       [x], al                       ; Move the xlatted value into [x] variable byte
         ;mov       al, [di]                      ; Move the value in di register (y position) into al
         ;xlat                                    ; Xlat the value in al register using loctbl values
         ;mov       [y], al                       ; Move the xlatted value into [y] variable byte
         mov       [x], [si]                     ;  Move value of si into [x] data byte variable
         mov       al, [cols]                    ; Move the number of elements per row into al register
         mul       [y]                           ; Multiply by the row value now stored in [y] variable
         add       ax, [x]                       ; Add the column value now stored in [x] variable
                                                 ; .... ax register now holds the linear offset of mouse in maze (0 - 449)
         mov       [loc], ax                     ; Store offset value in loc data word

;-------------------------------------------------
; Code to make 1 move in the maze
;-------------------------------------------------
         mov       bx, [dir]                     ;
         jmp       [dirtbl + bx - 1]             ; Jump to the table reference for left direction of current direction
                                                 ; .... East -> check North (0), South -> check East(1)
                                                 ; .... West -> check South (2), North -> check West(3)
                                                 ;
                                                 ;
nth:                                             ; Label for direction to check is north (table index 0)
         mov       al, ds:[bp + di - 1]          ; Move the value at the next direction to check into al register
         cmp       al, 20h                       ; compare byte of potential move to 20h (space)
         mov       [dir], 4                      ; Move 4 into [dir] incase have a space to move north
         je        move                          ; If equal to 20h then jump to move label to move the mouse
                                                 ; .... otherwise drop through to the next direction check
                                                 ;
est:                                             ; Label for direction to check is east (table index 1)


sth:                                             ; Label for direction to check is south (table index 2)


wst:                                             ; Label for direction to check is west (table index 3)


         jmp nth                                 ; Jump to the top if have not yet checked all directions and/or moved

move:
                                                 ; does something here
                                                 ;
;-------------------------------------------------
; Restore registers and return
;-------------------------------------------------
exit:                                            ;
         pop       dx                            ; restore dx register from the stack
         pop       ax                            ; restore ax register from the stack
         ret                                     ; return
;-------------------------------------------------
         end
