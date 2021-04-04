;---------------------------------------------------------------------
;  Program:      Run Length Coding
;
;  Function:     Decompresses 1 dimensional run lengths
;                This subroutine links with a C main program
;
;                Add your additional functional comments
;
;  Owner:
;
;  Changes:
;  Date          Reason
;  ----          ------
;  05/16/2017    Original version ... coded to spec design
;---------------------------------------------------------------------
         .model    small
         .8086
         public    _rlc
;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
                                       ;no variables declared
;---------------------------------------
         .code                         ;start the code segnment
;---------------------------------------
; Save the registers ... 'C' requires (bp,si,di)
; Access the input and output lists
;---------------------------------------
_rlc:                                  ;
         push      bp                  ;save 'C' register
         mov       bp,sp               ;set bp to point to stack
         push      si                  ;save 'C' register
         push      di                  ;save 'C' register
         mov       si,[bp+4]           ;si points to the input compressed data
         mov       di,[bp+6]           ;di points to the empty output buffer
;---------------------------------------
; Start of RLC code preparing registers and flags
;---------------------------------------
         mov       cx,0                ;set cx to 0 to prepare for loading later
         mov       ax,0                ;clear the ax register
         cld                           ;clear direction flag for string ops
         mov       bx,F00Fh            ;mask bytes stored in bx register
                                       ;.... bh gets high bits, bl gets low bits

;---------------------------------------
; reset for processing a new line of 80 pels
;---------------------------------------
reset:                                 ;used to reset for new line processing
         cmp       [si],0              ;compare the byte value at [si] to zero
         je        exit                ;if zero for byte then jump to end as at end of buffer
         mov       dx,80               ;set dx with line count value of 80
         mov       ax,DB20h            ;move the DBh and 20h values into ax register
                                       ;.... will always use al for string cpy
                                       ;.... use exch al,ah to change color value in al
;---------------------------------------
; Get the 4-bit RLC values for processing
;---------------------------------------
getRLC:                                ;label for getting next two RLC values
         mov       cl,bh               ;move the mask in bh for RLC 4-bits into cl
         and       cl,[si]             ;and with [si] to get high 4-bit value into cl
         exch      bl,bh               ;exchange values in bl and bh for next mask operation

valtst:
         cmp       cl,0Fh              ;compare cl to 0Fh to see if need to fill line
         jne       decomp              ;if not equal to 15 (1111 4-bit) then jump to decomp
         mov       cx,dx               ;else move remaining count for line into cx

decomp:
         sub       dx,cx               ;subtract cx value from dx to track line pels to be copied to di
         rep       stosb               ;move cx number of color into destination buffer
         cmp       dx,0                ;check if dx is 0, all pels for line completed
         je        reset               ;.... if done for line (80 pels) then jump to reset label
         exch      al,ah               ;else exchange colors stored in ax to process next code
         cmp       bh,0Fh              ;compare mask in bh to 0Fh, determine next op
         je        getRLC              ;if equal, jump back to getRLC for next code processing
         inc       si                  ;else increment si to get next RLC byte for processing
         jmp       getRLC              ;then jump to getRLC label

;---------------------------------------
; Restore registers and return
;---------------------------------------
exit:                                  ;
         pop       di                  ;restore 'C' register
         pop       si                  ;restore 'C' register
         pop       bp                  ;restore 'C' register
         ret                           ;return
;---------------------------------------
         end

