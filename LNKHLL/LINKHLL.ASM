;-----------------------------------------------------------
;
; Program: Linkhll
;
; Function:
;
; Owner:
;
; Date:
; 11/21/2016   Original Version
;
;
;---------------------------------------
         .model    small               ;
         .8086                         ;
         public    _linkhll            ;
;---------------------------------------


;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
;
; Data Segment
;
;---------------------------------------


;---------------------------------------
         .code                         ;start the code segment
;---------------------------------------
;
; Code Segment
;
;---------------------------------------
_linkhll:                              ;
         push   bp                     ; save bp to stack
         mov    bp, sp                 ; move stack pointer into bp for use



         ret                           ; return
                                       ;
         end                           ; end source code
;---------------------------------------

