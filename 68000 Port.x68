*-----------------------------------------------------------
* Title      :  Parameter Passing Example for Easy68k
* Written by :  Philip Bourke. Reused by C00306572 Callum Matthews to start Project 2
* Date       :  March-25-2025
* Description:  Demonstrates passing parameters using registers and stack, performing arithmetic operations and running a loop to keep a running sum.
*               Highlights security vulnerabilities related to stack handling, input validation and memory access
*
*               Note: I am writing the example out verbatim to allow me to see how this program runs, and to identify issues
*                     before I port it to x86. (Callum Matthews)
*-----------------------------------------------------------

START   ORG $1000
    CLR.L   D3      ; Running sum initialised to 0
    MOVE.W #3, D4    ; Loop counter set to 3
    
GAME_LOOP:
* Input two numbers and add them using REGISTER_ADDER subroutine
    MOVE.B  #14, D0  ; Task 14: Display a string
    LEA     PROMPT, A1  ; Load address of prompt string
    TRAP    #15         ; System call (No input validation - Vulnerable)
    
    MOVE.B  #4, D0      ; Task 4: Read interger input (No input validation - Vulnerable)
    TRAP    #15         ; execute system call
    MOVE.L  D1, D2      ; Store first number in D2
    
    MOVE.B  #14, D0
    LEA     PROMPT, A1
    TRAP    #15         ;Display prompt again (No Input validation - Vulnerable)
    
    MOVE.B  #4, D0
    TRAP    #15         ; Read second number into D1 (No Input Validation - Vulnerable)
    
    BSR REGISTER_ADDER  ; Call subroutine (D1 = D1 + D2)
    ADD.L D1, D3        ; Add result to running sum
    
    MOVE.B  #14, D0
    LEA RESULT, A1
    TRAP    #15
    MOVE.B  #3, D0
    TRAP    #15
    
    BSR NEW_LINE
    
    * Decrement loop counter and repeat if not zero
    SUBQ.W  #1, D4
    BNE GAME_LOOP
    
    * Display final sum
    MOVE.B #14, D0
    LEA FINAL_RESULT, A1
    TRAP    #15
    MOVE.L  D3, D1
    MOVE.B  #3, D0
    TRAP    #15
            

    SIMHALT             ; halt simulator
*--------------------------------------------------------

* Add numbers using register parameters
REGISTER_ADDER:
    ADD.L   D2, D1  ; Add D2 to D1 (No bounds checking - Vulnerable)
    RTS             ; Return from subroutine
    
*--------------------------------------------------------
* Subroutine to display Carriage Return and Line Feed
NEW_LINE:
    MOVE.B  #14, D0
    LEA CRLF, A1
    TRAP    #15
    RTS
    
*--------------------------------------------------------
* Strings
PROMPT DC.B 'Enter number: ' ,0
RESULT DC.B 'The sum is: ' ,0
FINAL_RESULT DC.B 'Final sum is: ' ,0
CRLF DC.B   $D,$A,0
    

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
