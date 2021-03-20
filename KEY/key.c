/**--------------------------------------------------------------------
*   Program:  Key (MASM version)
*
*   Function: Key reads ASCII characters in the range of 20h-7Fh from
*             Standard Input (which can be from keyboard or redirected
*             ASCII text file) without echo (ah=08h and int 21h).
*
*             Characters input to Key are processed immediately, one
*             by one, as they read in from Standard Input (stdin).
*
*             Each character is processed using the following rules:
*             - Characters that are uppercase b/w A - Z are written to
*               Standard Output (stdout)
*             - Characters that are lowercase b/w a - z are converted
*               to the uppercase letter and printed to stdout
*             - Blank (20h) and period (2Eh) are printed to stdout
*             - All other characters input are discarded and Key moves
*               on to the next input character
*             - Key ends processing after reading a period (2Eh) and
*               printing that period to stdout
*
*             Notes about the program specification:
*             - This program only handles ASCII characters in the
*               range of 20h-7Fh
*             - The program output must have the terminating period
*             - No special ASCII characters will be handled such as
*               F1 - F12 keys which generate two calls
*             - There are NO output messages or prompts to the user!
*               It is expected that the user has read the program
*               documentation and understands the program function
*
*   Owner:    DHH
*
*   Date      Reason
*   -----     ------
*   02/26/21  Original version
*/

#include <stdlib.h>
#include <stdio.h>

#define MIN_CAP 0x41 //Lowest Hex value for uppercase letter
#define MAX_CAP 0x5A //Highest Hex value for uppercase letter
#define MIN_LWR 0x61 //Lowest Hex value for lowercase letter
#define MAX_LWR 0x7A //Highest Hex value for lowercase letter
#define HEX_SUB 0x20 //Value to subract from lowercase to convert to uppercase
#define ASC_PRD 0x2E //Hex value of period which is also termination value
#define ASC_SPC 0x20 //Hex value of space
#define DOS_INT 0x21 //DOS interrupt value to print to stdout

int main()
{
    //data byte to hold each input character for evaluation
    char ch;

    // read the input to ch variable while !EOF
    while ((ch = getchar()) != EOF) {

        // if valid character (period - 2Eh) then print to stdout and terminate program
        if (ch == ASC_PRD){
            putchar(ch);
            break;
        }
        // if within range of uppercase letters or ASCII space then output immediately
        else if (ch == ASC_SPC || (ch >= MIN_CAP && ch <= MAX_CAP))
            putchar(ch);
        // if within range of lowercase letters then subtract 0x1A to byte value to make uppercase
        else if (ch >= MIN_LWR && ch <= MAX_LWR)
            putchar(ch - HEX_SUB);
        else
            continue;
    }
    return EXIT_SUCCESS;
}
