maztbl   db        32 dup(1)                     ; Xlat table converts any character that is not
                   0                             ; .... 20h (32 decimal) to a 1 decimal value and the
                   223 dup(1)                    ; .... 20h value gets converted to 0 decimal
dectbl   dw        move, nope                    ; Jump table for move or not able to move decision
                                                 ; .... move will set new values and return to caller
                                                 ; .... nope will try another direction


         xlat                                    ; xlat the value in al register to 0 or 1 value