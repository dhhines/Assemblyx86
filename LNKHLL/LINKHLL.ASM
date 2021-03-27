;-----------------------------------------------------------
;
; Program: Linkhll
;
; Function:  The LINKHLL subroutine takes in 4 parameters passed
;            on the stack from the calling C program.  The sub-
;            routine then finds the two largest values and mult-
;            plies them together and returns the value to the
;            calling program.
;
;            Note:  the 4 paramaters are 16-bit words on the stack
;                   and thus the returned value is stored in the
;                   dx:ax register pair.
;
;         Stack view for reference:
;         param v4    bp+10
;         param v3    bp+8
;         param v2    bp+6
;         param v1    bp+4
;         IP - Instruction Pointer (bp+2)
;         BP - Base Pointer (saved SP - Stack Pointer location)
;
; Owner: David Hines
;
; Date:
; 11/21/2016   Original Version
;
;---------------------------------------
         .model    small               ;
         .8086                         ;
         public    _linkhll            ;
;---------------------------------------

;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
                                       ; No local variable declared
;---------------------------------------
         .code                         ;start the code segment
;---------------------------------------
; Save any modified registers
;---------------------------------------
_linkhll:                              ;
         push   bp                     ; save bp to stack
         mov    bp, sp                 ; move stack pointer into bp for use
;---------------------------------------
; move v4 and v3 params into registers to compare
;---------------------------------------
         mov  ax, [bp+10]              ; move v4 into ax -> largest value
         mov  dx, [bp+8]               ; move v3 into dx -> second largest value
         cmp  ax, dx                   ; compare v4 (ax) to v3 (dx)
         ja   skip1                    ; if ax greater than dx
                                       ; .... jump to skip1
         xchg ax, dx                   ; if ax less than exchg with dx
                                       ; .... then fall through to skip1
                                       ; NOTE: ax is largest so far, now test dx against rest of values
;---------------------------------------
; compare bx and v2 param
;---------------------------------------
         skip1:                        ; skip1 label if xchg opcode skipped
         cmp  dx, [bp+6]               ; compare dx to [bp+6]
         ja   skip2                    ; if dx is greater than [bp+6]
                                       ; .... jump to skip2
         xchg dx, [bp+6]               ; if dx less than exchg with [bp+6]
                                       ; .... then fall through to skip2
                                       ; NOTE:  Now dx one of two largest (might be bigger than ax if exch with previous dx)
;---------------------------------------
; compare ax and dx registers
;---------------------------------------
         skip2:                        ; skip2 label if xchg opcode skipped
         cmp  ax, dx                   ; compare ax to dx in case dx is now bigger
         ja   skip3                    ; if ax is greater than dx
                                       ; .... jump to skip3
         xchg ax, dx                   ; if dx less than exchg with ax
                                       ; .... now fall through
;---------------------------------------
; compare dx and v1 param
;---------------------------------------
         skip3:                        ; skip3 label if xchg opcode skipped
         cmp  dx, [bp+4]               ; compare dx to [bp+4]
         ja   product                  ; if dx is greater than [bp+4]
                                       ; .... jump to product
         xchg dx, [bp+4]               ; if dx less than exchange with [bp+4]
                                       ; .... now fall through
;---------------------------------------
; calculate final product and return
;---------------------------------------
         product:                      ; product label for calc of result
         mul dx                        ; get product of two largest values
         pop bp                        ; restore bp register
         ret                           ; return
                                       ;
         end                           ; end source code
;---------------------------------------

