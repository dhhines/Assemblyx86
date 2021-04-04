;---------------------------------------------------------------------
;  Program:      Run Length Coding
;
;  Function:     Decompresses 1 dimensional run lengths
;                This subroutine links with a C main program
;
;                Add your additional functional comments
;
;  Owner:        David Hiens
;
;  Changes:
;  Date          Reason
;  ----          ------
;  05/16/2017    Original version ... coded to spec design
;  04/04/2021    Updated version with student specific code
;---------------------------------------------------------------------
         .model    small
         .8086
         public    _rlc
;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
;mask     dw        61455               ;mask for high / low 4-bits in RLC bytes
;clrs     dw        56096               ;colors black and white stored as word
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
         mov       bl,0Fh              ;mask bytes stored in bl register
         cld                           ;clear direction flag for string ops
;---------------------------------------
; reset for processing a new line of 80 pels
;---------------------------------------
reset:                                 ;used to reset for new line processing
         mov       dx,80               ;set dx with line count value of 80
                                       ;.... bh gets high bits, bl gets low bits
         mov       ax,0DB20h           ;move the DBh and 20h values into ax register
                                       ;.... will always use al for string cpy
                                       ;.... use exch al,ah to change color value in al
;---------------------------------------
; Get the 4-bit RLC values for processing
;---------------------------------------
getRLC:
         cmp       byte ptr [si],0     ;compare the byte value at [si] to zero
         je        exit                ;if zero for byte then jump to end as at end of buffer                               ;label for getting next two RLC values
         mov       cl,4                ;move 4 into cl to prep right bit rotate of 4
         ror       byte ptr [si],cl    ;right rotate bits in [si] 4 bit locations
         mov       cl,bl               ;move the mask in bl for RLC 4-bits into cl
         and       cl,[si]             ;and with [si] to get 4-bit RLC value into cl

valtst:
         cmp       cl,0                ;compare cl value to 0
         je        skip                ;jump to skip code section if cl == 0
         cmp       cl,0Fh              ;compare cl to 0Fh to see if need to fill line
         jne       decomp              ;if not equal to 15 (1111 4-bit) then jump to decomp
         mov       cx,dx               ;else move remaining count for line into cl

decomp:
         sub       dx,cx               ;subtract cx value from dx to track line pels copied to di
         rep       stosb               ;move cx number of color into destination buffer from al
         cmp       dx,0                ;check if dx is 0 then all pels for line completed
         je        reset               ;.... if done for line (80 pels) then jump to reset label

skip:
         xchg      al,ah               ;else exchange colors stored in ax to process next code
         cmp       al,0DBh             ;compare clr in al to DBh, determines next op
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