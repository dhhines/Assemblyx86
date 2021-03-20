//*************************************************************************
//
//  Program: READFILE
//
//  Function / Logic:
//
//    This C program reads an ASCII input file one character at a time.
//
//    End of line is expected to be a Carriage_Return / Line_Feed pair.
//    - The CR is ignored.
//    - After reading and echoing the LF the program prints a message.
//
//
//    Special note about End_Of_File:
//    - When C reads the ASCII End_Of_File character (1Ah)
//      it converts it to the C End_Of_File (FFh). The program
//      recognizes that C EOF character and writes an ASCII EOF
//      character in its place and then terminates.
//
//  Operation:
//
//    Run the program by typing:  readfile < in.txt > out.txt
//    where in.txt is an ASCII file.
//
//  Author: Dana Lasher
//
//  Change log:
//  10/21/2011  - Original version
//
//*************************************************************************

#include <stdio.h>

int main ()
{
  int ch=0;                                      // ch is the character read

  while (1)
    {                                            // Loop forever
    ch=getchar();                                // Read a character
    if (ch == EOF) break;                        // If EOF then exit loop
    putchar (ch);                                // Else echo the character


    // ***********************
    // The code to process the
    // character goes here
    // ***********************


    // Check for end of line
    if (ch == 13) {}                             // Ignore the CR
    if (ch == 10)                                // If LF then ...
       {                                         //  start EOL processing
       printf("end of line");                    // print message
       putchar (13);                             // put CR  This is EOL
       putchar (10);                             // put LF   for the message
       putchar (13);                             // put CR  This is
       putchar (10);                             // put LF   a blank line
       }
    }
  putchar (26);                                  // C detected EOF so ...
  return(0);                                     //  write ASCII EOF and exit
}
