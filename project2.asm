; -----------------------------------------------------------
; Title        : Parameter Passing Example for x86_64
; Written by   : Callum Matthews C00306572
; Date Created : 27 April 2026
; Description  : Demonstrates passing parameters using registers
;                and stack, performing arithmetic operations,
;                and running a loop to keep a running sum.
;                Direct port of 68000 assembly to x86_64.
; -----------------------------------------------------------

;-------------------------------------------------------
; SYSTEM CALL CONSTANTS
;-------------------------------------------------------
SYS_EXIT    EQU 60                      ; syscall: exit
SYS_READ    EQU 0                       ; syscall: read
SYS_WRITE   EQU 1                       ; syscall: write
SYS_STDIN   EQU 0                       ; stdin file descriptor
SYS_STDOUT  EQU 1                       ; stdout file descriptor

;-------------------------------------------------------
; PROGRAM CONSTANTS
;-------------------------------------------------------
LOOP_COUNT  EQU 3                       ; number of iterations (replaces MOVE.W #3,D4)
BUF_SIZE    EQU 12                      ; input buffer size capped at 12 bytes, prevents buffer overload


global _start                           ; declared for linker (entry point)

; added for c test file, create global variables (REMOVED AGAIN CAUSE NOT WORKING)
;global str_to_int
;global register_adder
;global num1
;global num2


;-------------------------------------------------------
; ENTRY POINT
;-------------------------------------------------------
_start:
    call    initialize                  ; initialize registers and running sum
    call    game_loop                   ; branch to Game Loop
    call    display_final               ; display final sum
    call    system_exit                 ; exit and clean up

;-------------------------------------------------------
; SYSTEM EXIT
; basically my SIMHALT
;-------------------------------------------------------
system_exit:
    mov     rax, SYS_EXIT               ; syscall: exit
    xor     rdi, rdi                    ; exit code 0
    syscall

;-------------------------------------------------------
; WRITE TO STDOUT
;-------------------------------------------------------
sys_write:
    mov     rax, SYS_WRITE              ; syscall: write
    mov     rdi, SYS_STDOUT             ; stdout file descriptor
    syscall
    ret

;-------------------------------------------------------
; READ FROM STDIN
;-------------------------------------------------------
sys_read:
    mov     rax, SYS_READ
    mov     rdi, SYS_STDIN
    syscall
    ret

;-------------------------------------------------------
; WRITE NEWLINE
;-------------------------------------------------------
write_endl:
    mov     [loop_counter], rcx         ; save loop counter - rcx tampered by syscall i reckon
    mov     rsi, newline                ; newline character
    mov     rdx, 1                      ; length 1
    call    sys_write
    mov     rcx, [loop_counter]         ; Restore loop counter
    ret

;-------------------------------------------------------
; INITIALIZE SUBROUTINE
;-------------------------------------------------------
initialize:
    xor     rbx, rbx                    ; running sum initialised to 0
    mov     rcx, LOOP_COUNT             ; loop counter set to 3
    ret

;-------------------------------------------------------
; GAME LOOP SUBROUTINE
; Input two numbers and add them using REGISTER_ADDER
; NOTE: saving rcx because it keeps getting tampered with, i think cause of linux?
;-------------------------------------------------------
game_loop:
    ; Display "Enter number: " prompt
    mov     [loop_counter], rcx         ; save loop counter before syscall
    mov     rsi, prompt                 ; address of prompt string
    mov     rdx, prompt_len             ; length of prompt
    call    sys_write
    mov     rcx, [loop_counter]         ; restore loop counter after syscall

    ; Read first number
    mov     [loop_counter], rcx
    mov     rsi, input_buf              ; read into buffer
    mov     rdx, BUF_SIZE
    call    sys_read
    mov     rcx, [loop_counter]

    mov     rdx, rax                            ; bytes read returned by sys_read
    cmp     byte [input_buf + rdx - 1], 10      ; is last byte a newline?
    jne     invalid_input                        ; input too long if not
    
    ; convert string to integer, store first number
    mov     rsi, input_buf              ; point to input buffer
    call    str_to_int                  ; result in rax
    cmp     rax, -1                     ; check for invalid input
    je      invalid_input
    mov     [num1], rax                 ; store first number

    ; Display prompt again for second number
    mov     [loop_counter], rcx
    mov     rsi, prompt                 ; address of prompt string
    mov     rdx, prompt_len             ; length of prompt
    call    sys_write
    mov     rcx, [loop_counter]

    ; Read second number
    mov     [loop_counter], rcx
    mov     rsi, input_buf
    mov     rdx, BUF_SIZE
    call    sys_read
    mov     rcx, [loop_counter]

    mov     rdx, rax                            ; bytes read returned by sys_read
    cmp     byte [input_buf + rdx - 1], 10      ; is last byte a newline?
    jne     invalid_input                        ; input too long if not

    ; Convert string to integer
    mov     rsi, input_buf
    call    str_to_int                   
    cmp     rax, -1
    je      invalid_input
    mov     [num2], rax                 ; store second number


    call    register_adder              ; Result in rax

    ; Store per-loop result before adding to running sum
    mov     [loop_result], rax         ; store this loop iterations result

    ; Add result to running sum
    add     rbx, rax                    ; rbx = running sum

    ; Display "The sum is: "
    mov     [loop_counter], rcx
    mov     rsi, result                 ; address of result string
    mov     rdx, result_len             ; length of result string
    call    sys_write
    mov     rcx, [loop_counter]

    ; Print this loop's sum (not the running total)
    mov     [loop_counter], rcx
    mov     rax, [loop_result]          ; this loops current sum for printing
    mov     rsi, buffer                 ; point to print buffer
    call    int_to_string               ; convert integer to string
    mov     rsi, rax                    ; result pointer from int_to_string
    lea     rdx, [buffer + 20]          ; end of buffer
    sub     rdx, rsi                    ; calculate length of number string
    call    sys_write
    mov     rcx, [loop_counter]

    ; print a newline
    call    write_endl

    ; Decrement loop counter and repeat if not zero
    dec     rcx                         ; decrement loop counter
    jnz     game_loop                   ; jump back if not zero
    ret

;-------------------------------------------------------
; DISPLAY FINAL
; Replaces: final display block before SIMHALT
;-------------------------------------------------------
display_final:
    ; Print "Final sum is: "
    mov     rsi, final_res              ; address of final result string
    mov     rdx, final_len              ; length of final result string
    call    sys_write

    ; Print final sum value
    mov     rax, rbx                    ; move running sum to rax for printing
    mov     rsi, buffer                 ; point to print buffer
    call    int_to_string               ; convert integer to string
    mov     rsi, rax                    ; result pointer from int_to_string
    lea     rdx, [buffer + 20]          ; end of buffer
    sub     rdx, rsi                    ; calculate length of number string
    call    sys_write

    ; Print newline
    call    write_endl
    ret

;-------------------------------------------------------
; REGISTER_ADDER
; adds num1 + num2, result returned in rax
; basically 68K REGISTER_ADDER
;-------------------------------------------------------
register_adder:
    mov     rax, [num1]                 ; load the first number 
    add     rax, [num2]                 ; add second number 
    jo      overflow_error              ; jump if overflow flag set, this prevents overflow errors
    ret                                 ; return my result in rax reg

;-------------------------------------------------------
; STR_TO_INT
; Converts ASCII string in rsi to integer in rax
; Needed because Linux syscall returns raw ASCII bytes
;-------------------------------------------------------
str_to_int:
    xor     rax, rax                    ; result = 0
    xor     rdx, rdx                    ; clear temp register

.loop:
    movzx   rdx, byte [rsi]             ; load next character
    cmp     rdx, 10                     ; check for newline (end of input)
    je      .done                       ; done if newline

    cmp     rdx, 0                      ; check for null terminator
    je      .done                       ; Done if null
    cmp     rdx, '0'                    ; check character is not below zero
    jl      .invalid                    ; jump to invalid if not digit. Allows for input validation
    cmp     rdx, '9'                    ; check character is not above digit of 9
    jg      .invalid                    ; jump if greater than, as invlaid. again, input validation
    sub     rdx, '0'                    ; convert ascii char to an int


    imul    rax, rax, 10                ; shift result left (multiply by 10)
    add     rax, rdx                    ; add new digit
    inc     rsi                         ; move to next character
    jmp     .loop                       ; repeat


.invalid:
    mov     rax, -1                     ; return -1 to signla invalid input
    ret

.done:
    ret                                 ; return result in rax

;-------------------------------------------------------
; INT_TO_STRING
; Converts integer in rax to string at rsi
; Returns pointer to start of string in rax
;-------------------------------------------------------
int_to_string:
    add     rsi, 19                     ; move to end of buffer
    mov     byte [rsi], 0               ; null terminator
    mov     rdi, 10                     ; divisor

.next_digit:
    xor     rdx, rdx                    ; clear rdx for division
    div     rdi                         ; rax = quotient, rdx = remainder
    add     dl, '0'                     ; convert remainder to ASCII
    dec     rsi                         ; store characters in reverse order
    mov     [rsi], dl                   ; store digit
    test    rax, rax                    ; check if done (rax == 0?)
    jnz     .next_digit                 ; repeat until all digits converted
    mov     rax, rsi                    ; return pointer to first digit in rax
    ret

;-------------------------------------------------------
; INVALID INPUT HANDLER triggered by non-numeric input
;-------------------------------------------------------
invalid_input:
    mov     rsi, errmsg
    mov     rdx, errmsg_len
    call    sys_write
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

;-------------------------------------------------------
; OVERFLOW ERROR HANDLER triggered by integer overflow in register_adder
;-------------------------------------------------------
overflow_error:
    mov     rsi, errmsg
    mov     rdx, errmsg_len
    call    sys_write
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall
;-------------------------------------------------------
; SECTION BSS - Uninitialised data
;-------------------------------------------------------
section .bss
    input_buf       resb    12          ; input buffer capped to 12 bytes to prevent overflow
    buffer          resb    20          ; buffer for int_to_string conversion
    loop_counter    resq    1           ; stores rcx between syscalls
    num1            resq    1           ; number 1 or first input
    num2            resq    1           ; second input or number 2
    loop_result     resq    1           ; result of a loop iterations addition

;-------------------------------------------------------
; SECTION DATA - Initialised data such as lines from 68k ect
;-------------------------------------------------------
section .data
    prompt      db  'Enter number: ', 0         ; PROMPT DC.B 'Enter number: ',0
    prompt_len  equ $ - prompt                  ; Length of prompt string
    result      db  'The sum is: ', 0           ; RESULT DC.B 'The sum is: ',0
    result_len  equ $ - result                  ; Length of result string
    final_res   db  'Final sum is: ', 0         ; FINAL_RESULT DC.B 'Final sum is: ',0
    final_len   equ $ - final_res               ; Length of final result string
    newline     db  10                          ; CRLF DC.B $D,$A,0
    errmsg      db 'Error: invalid input or overflow', 10
    errmsg_len  equ $ - errmsg