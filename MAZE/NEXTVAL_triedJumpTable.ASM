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
cols     db        30                            ; Number of columns per row
mvtbl    dw        -30,1,30,-1,-30,1,30,-1       ; Values to calculating the next move in liner
newdir   dw        4,1,2,3,4,1,2,3               ; Table with new direction based on the mvtbl index
jmptbl   dw        n0, e1, s2, w3                ; Jump table that starts with left mouse check
movval   dw        ?                             ; Value to update the SI index
;-------------------------------------------------
         .code                                   ;start the code segment
;-------------------------------------------------
; Save any modified registers
;-------------------------------------------------
nextval:                                         ;
         push      ax                            ; Save ax register on the stack
         push      cx                            ; Save cx register on the stack
         push      si                            ; Save the si register on stack
         push      bx                            ; Save the bx register on stack
;-------------------------------------------------
; Code to calculate linear location of mouse in maze (0 to 449)
;-------------------------------------------------
         mov       cl, [si]                      ; Move the x value into cl for conversion to word
         mov       ch, 0                         ; Set the ch value to 0 as only want cl value
         mov       al, 30                        ; Move the number of columns per row into al register
         mul       byte ptr [di]                 ; Multiply by the row value stored in [di] data byte
         add       ax, cx                        ; Add the column value now stored in cx data word
                                                 ; .... ax register now holds the linear offset of mouse in maze (0-449)
         sub       ax, 31                        ; subtract 31 to get the 0 indexed linear offset of mouse
         mov       si, ax
;-------------------------------------------------
; Setup BX for direction indexing
;-------------------------------------------------
         mov       bl, [bx]                      ; Move the direction value from bx location into the bl register
         add       bl, bl                        ; Double the size of the direction index for word size values
         mov       bh, 0                         ; Move 0 into bh so only bl value remains for indexing
         jmp       [jmptbl + bx - 2]
;-------------------------------------------------
; Loop checking left mouse algorithm for ability to move
;-------------------------------------------------
;loopstrt:
         ;mov       si, ax                        ; Move the linear maze location into si for checking next possible move
         ;add       si, [mvtbl + bx - 2]          ; Use the mvtbl w/ bx-2 index to add/sub rows or cols to location
         ;mov        cx,
         ;add       bx, 2                         ; Increment bx index value by 2 to turn the mouse for next check
         ;cmp       byte ptr ds:[bp + si], 20h    ; compare byte of target move location to 20h (space)
         ;jne       loopstrt                      ; If not equal to space then start back at top of loop
n0:
         cmp       byte ptr ds:[bp+si-30], 20h   ; compare the maze byte at -30 from curr position to 20h
         mov       bx, -30                       ; store -30 in bx in case match
         mov       cl, 4                         ; store tested direction
         je        move                          ; If a space is matched for move then jump to move code
e1:
         cmp       byte ptr ds:[bp+si+1], 20h    ; compare the maze byte at +1 from curr position to 20h
         mov       bx, 1                         ; store +1 in bx in case match
         mov       cl, 1                         ; store tested direction
         je        move                          ; If a space is matched for move then jump to move code
s2:
         cmp       byte ptr ds:[bp+si+30], 20h   ; compare the maze byte at +30 from curr position to 20h
         mov       bx, 30                        ; store +30 in bx in case match
         mov       cl, 2                         ; store tested direction
         je        move                          ; If a space is matched for move then jump to move code
w3:
         cmp       byte ptr ds:[bp+si-1], 20h    ; compare the maze byte at -1 from curr position to 20h
         mov       bx, -1                        ; store -1 in bx in case match
         mov       cl, 3                         ; store teste direction
         je        move                          ; If a space is matched for move then jump to move code
         jmp       n0                            ; If no match yet then start at the top and drop through
;-------------------------------------------------
; Code to update the x and y values to proper values
;-------------------------------------------------
move:
         add       ax, bx                        ; Move the linear location value into ax for finding x and y values
         div       [cols]                        ; Divide ax by the number of columns
         add       ah, 1                         ; increment the resulting column index
         add       al, 1                         ; increment the resulting row index
;-------------------------------------------------
; Code to set the new direction of move
;-------------------------------------------------
         ;mov       cx, [newdir + bx - 4]         ; Use the newdir w/ bx-4 index to save new direction being checked in cx
         pop       bx                            ; Restore the bx register from the stack
         mov       [bx], cl                      ; Move the value of direction from cl register into the bx pointer location
;-------------------------------------------------
; Code to update the [si] and [di] location values
;-------------------------------------------------
         pop       si                            ; Restore the si register
         mov       [si], ah                      ; Store the remainder in [si] which is column index
         mov       [di], al                      ; Store the quotient in [di] which is row index
;-------------------------------------------------
; Re1ore registers and return
;-------------------------------------------------
exit:                                            ;
         pop       cx                            ; restore cx register
         pop       ax                            ; restore ax register
         ret                                     ; return
;-------------------------------------------------
         end
