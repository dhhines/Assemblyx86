/**--------------------------------------------------------------------
*   Program:  Tabs (MASM version)
*
*   Function: Tabs reads ASCII characters from a text file that is
*             redirected from Standard Input, edits the lines with
*             the proper spacing and outputs the updated lines of text
*             to an ASCII text file which is redirected from Standard
*             Output.
*
*             The spacing for the text is determined by the tab stop
*             position which will replace any tab characters (O9h) in the
*             file with the default of 10 space characters (20h).
*
*             Optionally, the user can input a tab space parameter at the
*             command line with the values of 1 through 9 which will
*             change the default of 10 spaces to the input value.
*
*             Each line of text is processed using the following rules:
*             - All characters in the range of 20h-7Fh will be written
*               to the output file except for tab characters 09h
*             - Tab characters will be expanded to the proper number of
*               spaces as defined by the default or command line values
*               and then will continue outputting text
*             - If the provided text file does not contain any tabs then
*               the output file will be a byte for byte replica of the
*               input file
*
*             Notes about the program specification:
*             - Input files will contain 0 or more lines and there is
*               no limit to the number of lines or characters
*             - The first character of each line will be at position 0
*             - This program handles ASCII characters from 20h-7Fh
*             - The program also handles specific control characters
*               which are tab(09h), line feed (0Ah), carriage return (0Dh),
*               and the DOS End of File (EOF = 1Ah).
*             - All lines of text will end with the 0D0Ah pair and will
*               never appear as individual characters
*             - Files will always terminate with the EOF character 1Ah
*
*   Owner:    DHH
*
*   Date      Reason
*   -----     ------
*   03/06/21  Original version
*/

#include <stdlib.h>
#include <stdio.h>

#define ASC_TAB 0x09 //Hex value for a tab character
#define ASC_SPC 0x20 //Hex value for a space character
#define ASC_CR  0x0D //Hex value of carriage return
#define ASC_LF  0x0A //Hex value of line feed
#define DOS_EOF 0x1A //DOS end of file character
#define DFT_SPC 10   //Default spacing for tab stop position

int main(int argc, char *argv[])
{
    //data byte to hold each input character for evaluation
    char ch;

    //number of spaces to replace any tab characters
    int spaces = DFT_SPC;
    //count of the characters printed; will be reset after each new line
    int count = 0;

    if (argc > 1)
        spaces = atoi(argv[1]);

    // read the input to ch variable while !EOF
    while ((ch = getchar()) != EOF) {
        // if DOS_EOF character (0x1A) then break out of loop and exit
        if (ch == DOS_EOF)
            break;
        // if tab character (0x09) then expand by number of spaces
        else if (ch == ASC_TAB){
            for (int i = 0; i < spaces - count; i++)
                putchar(0x20);
            count = 0;
        }
        else if (ch == ASC_CR || ch == ASC_LF){
            count = 0;
            putchar(ch);
        }
        else {
            putchar(ch);
            count++;
        }
    }

    return EXIT_SUCCESS;
}
