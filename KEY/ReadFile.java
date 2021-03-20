/******************************************************************************/
/**                                                                          **/
/** Program: ReadFile                                                        **/
/**                                                                          **/
/**  Function / Logic:                                                       **/
/**                                                                          **/
/**    This java program reads an ASCII input file one character at a time.  **/
/**                                                                          **/
/**    End of line is expected to be a Carriage_Return / Line_Feed pair.     **/
/**    - The CR is ignored.                                                  **/
/**    - After reading and echoing the LF the program prints a message.      **/
/**                                                                          **/
/**                                                                          **/
/**  Operation:                                                              **/
/**                                                                          **/
/**    Run the program by typing:  readfile < in.txt > out.txt               **/
/**    where in.txt is an ASCII file.                                        **/
/**                                                                          **/
/**  Author: Dana Lasher                                                     **/
/**                                                                          **/
/**  Change log:                                                             **/
/**  10/21/2011  - Original version                                          **/
/**                                                                          **/
/******************************************************************************/


import java.io.*;            /** System.in.read() can throw an IOException   **/

public class ReadFile
{

private static final int     CR = 13;        /** decimal carriage return     **/
private static final int     LF = 10;        /** decimal line feed           **/
private static final int DOSEOF = 26;        /** decimal DOS EOF             **/

public static void main(String[] args)
  {
  int ch;                                    /** character read              **/

  try                                        /** in case of an IOException   **/
    {
    while(true)
      {
      ch = System.in.read();                 /** read a character            **/
      if (ch == DOSEOF) break;               /** exit if char is DOSEOF      **/
      if (ch == -1    ) break;               /** exit if char Java Linux EOF **/
      System.out.write(ch);                  /** write the character         **/


      /*****************************/
      /** The code to process the **/
      /** character goes here     **/
      /*****************************/


      /** Check for end of line                                              **/
      if (ch == CR) { }                      /** if CR, do nothing           **/
      else if(ch == LF)                      /** if LF, at the end of a line **/
        {
        System.out.printf("end of line");    /** print a message             **/
        System.out.write(CR);                /** print CR                    **/
        System.out.write(LF);                /** print LF                    **/
        System.out.write(CR);                /** add another CR              **/
        System.out.write(LF);                /** and LF for readability      **/
        }
      }
    } catch (IOException e) {                /** catch the exception         **/
      System.out.println("exception"); }     /** print message               **/

    System.out.printf("%c", DOSEOF);         /** Done ... print DOS EOF      **/
  }
}
