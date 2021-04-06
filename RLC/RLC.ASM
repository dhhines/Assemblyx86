;---------------------------------------------------------------------
;  Program:      Run Length Coding
;
;  Function:     Decompresses 1 dimensional run lengths
;                This subroutine links with a C main program
;
;                Focused on using XOR, ROR and XCHG to minimize the
;                movement of data around between memory and registers.
;                Used rotate right and bitwise masks to isolate the 4-bit
;                rlc codes without destorying the data at the [SI] byte
;                location.
;
;  Owner:        David Hines
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
         push      ds                  ;push the data segment address value to stack
         pop       es                  ;pop the value from the stack into extra segment register
         mov       bx,0100h            ;for tracking codes processed per byte
         mov       cx,0                ;clear cx register for use
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
         je        exit                ;if zero for byte then jump to end as at end of buffer
         mov       cl,4                ;move 4 into cl to prep right bit rotate of 4
         ror       byte ptr [si],cl    ;right rotate bits in [si] 4 bit locations
         mov       cl,0Fh              ;move the mask in bl for RLC 4-bits into cl
         and       cl,[si]             ;and with [si] to get 4-bit RLC value into cl
         je        pstdcmp             ;jump to postdcmp label if cl == 0
;---------------------------------------
; test the value in cl for line fill (0Fh)
;---------------------------------------
valtst:
         cmp       cl,0Fh              ;compare cl to 0Fh to see if need to fill line
         jne       decomp              ;if not equal to 15 (1111 4-bit) then jump to decomp
         mov       cx,dx               ;else move remaining count for line into cl
;---------------------------------------
; decompression of the current run
;---------------------------------------
decomp:
         sub       dx,cx               ;subtract cx value from dx to track line pels copied to di
         rep       stosb               ;decompress bytes by number in cl using value in al for color
;---------------------------------------
; setup for the next run processing
;---------------------------------------
pstdcmp:
         xchg      al,ah               ;exchange colors stored in ax to process next code
         xor       bl,bh               ;set next 4-bit code to be processed
                                       ;.... 0=incr SI to next byte, 1=get next RLC in byte
         jne       chkline             ;if zf=0, jump to chkline label
         inc       si                  ;else increment si to get next RLC byte for processing
;---------------------------------------
; check if hit end of line and reset for new line
;---------------------------------------
chkline:
         cmp       dx,0                ;check if dx is 0 then all pels for line completed
         je        reset               ;.... if done for line (80 pels) then jump to reset label
         jmp       getRLC              ;start back at the top to process next RLC
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