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
x        dw        ?                             ; converted x coordinate
y        db        ?                             ; converted y coordiante
dir      db        ?                             ; Holds current direction of bx at start of subroutine
dirtbl   dw        nth, est, sth, wst            ; Jump table for direction at bx pointer
                                                 ; ... using dirtbl offset into dataseg
                                                 ; ... plus bx register minus 1
                                                 ; ... will jump to label of loop with North at top
loc      dw        ?                             ; 
;datatbl  dw        15,30,0,0,0,0                 ; datatbl for holding rows, cols, x, y, loc, and dir
;-------------------------------------------------
         .code                                   ;start the code segment
;-------------------------------------------------
; Save any modified registers
;-------------------------------------------------
nextval:                                         ;
         push      ax                            ; Save ax register on the stack
         push      dx                            ; Save dx register on the stack
         push      bx                            ; Save the dx register on stack
         push      si                            ; Save the si register on stack
                                                 ;
;-------------------------------------------------
; Code to calculate linear location of mouse in maze (0 to 449)
;-------------------------------------------------
         mov       al, [si]
         mov       dl, [di]
         dec       al
         dec       dl
         cbw
         mov       [x], ax
         mov       [y], dl
         mov       al, [cols]                    ; Move the number of columns per row into ax register
         mul       [y]                           ; Multiply by the row value now stored in [y] data byte
         add       ax, [x]                       ; Add the column value now stored in [x] data word
                                                 ; .... ax register now holds the linear offset of mouse in maze (0-449)
         mov       [loc], ax                     ; Store linear index value in loc data word (again, 0-449 value)

;-------------------------------------------------
; Code to make 1 move in the maze
;-------------------------------------------------
         jmp       [dirtbl + bx - 1]             ; Jump to the table reference to left of current direction
                                                 ; .... East -> check North (0), South -> check East(1)
                                                 ; .... West -> check South (2), North -> check West(3)
                                                 ;
nth:                                             ; Label for direction to check is north (table index 0)
         mov       si, [loc]                     ; Place the current index value for mouse location in si (0-449)
         sub       si, 30                        ; Subtract # columns to get value at row above (north)
         mov       al, ds:[bp + si]              ; Move the value in the bp maze table at si index into al
         cmp       al, 20h                       ; compare byte of target move location to 20h (space)
         mov       [dir], 4                      ; Store the direction if moving north 
         je        move                          ; If equal to 20h then jump to move label to move the mouse
                                                 ; .... otherwise drop through to the next direction check
                                                 ;
est:                                             ; Label for direction to check is east (table index 1)
         mov       si, [loc]                     ; Place the current index value for mouse location in bx
         add       si, 1                         ; Add 1 to index in bx to get value of space to east
         mov       al, ds:[bp + si]              ; Move the value in the bp maze table at bx index into al
         cmp       al, 20h                       ; compare byte of target move location to 20h (space)
         mov       [dir], 1                      ; Move 1 into [dir] incase need to move east
         je        move                          ; If equal to 20h then jump to move label to move the mouse
                                                 ; .... otherwise drop through to the next direction check
                                                 ;
sth:                                             ; Label for direction to check is south (table index 2)
         mov       si, [loc]                     ; Place the current index value for mouse location in bx
         add       si, 30                        ; Add # columns to bx to get value at row below (south)
         mov       al, ds:[bp + si]              ; Move the value in the bp maze table at bx index into al
         cmp       al, 20h                       ; compare byte of target move location to 20h (space)
         mov       [dir], 2                      ; Move 1 into [dir] incase need to move east
         je        move                          ; If equal to 20h then jump to move label to move the mouse
                                                 ; .... otherwise drop through to the next direction check
                                                 ;
wst:                                             ; Label for direction to check is west (table index 3)
         mov       si, [loc]                     ; Place the current index value for mouse location in bx
         cmp       [x], 0                        ; Compare [x] value to 0
         je        nth                           ; If [x] and 0 are equal then jump to the next check which is North
         sub       si, 1                         ; Subtract 1 from index in bx to get value of space to west
         mov       al, ds:[bp + si]              ; Move the value in the bp maze table at bx index into al
         cmp       al, 20h                       ; compare byte of target move location to 20h (space)
         mov       [dir], 3                      ; Move 1 into [dir] incase need to move east
         je        move                          ; If equal to 20h then jump to move label to move the mouse
                                                 ; .... otherwise drop through to the next direction check
         jmp nth                                 ; Jump to the top if have not yet checked all directions and/or moved

move:
         pop       bx                            ; restore bx register from the stack to original value
         mov       dl, [dir]
         mov       [bx], dl                      ; Move the value of direction into the bx register pointer
         mov       ax, [loc]                     ; Move the linear location value into ax for finding x and y values
         div       [cols]                        ; Divide ax by the number of columns
         inc       ah                            ; increment the ah register (holds the column index)
         inc       al                            ; increment the al register (holds the row index)
         mov       [si], ah                      ; Store the remainder in [si] which is column index
         mov       [di], al                      ; Store the quotient in [di] which is row index


;NOTE --> I SHOULD CREATE ANOTHER SUBROUTINE FOR THE N, E, S, W CHECKS!  WOULD SAVE TONS OF CODE
;WOULD NEED TO SAVE SI, DI TO STACK AS WELL
                                                 ;
;-------------------------------------------------
; Restore registers and return
;-------------------------------------------------
exit:                                            ;
         pop       ax                            ; restore ax register from the stack
         ret                                     ; return
;-------------------------------------------------
         end
