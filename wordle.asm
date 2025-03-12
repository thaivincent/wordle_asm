;; A program that reads a target string, an a a second string of equal legnth which is
;; your guess, the program then outputs feedback based on Wordle rules.
;; Register Summary
;; $8 = Input memory address
;; $9 = Output memory address
;; $10 = Target word
;; $11 = Guess word
;; $12 = Length of word
;; $13 = "." char 
;; $14 = "+" char
;; $15 = "?" char
;; $16 = Target word pointer
;; $17 = Guess word pointer
;; $18 = Target word counter
;; $19 = Guess word counter
;; $21 = # of exact matches
;; $22 = # of partial matches
;; $23 = # of misses

            lis $8                 
            .word 0xFFFF0004        ; Saving input adress into $8
            lis $9
            .word 0xFFFF000C        ; Saving output address into $9
            lis $13
            .word 0x2E                ; Saving . char to register $13
            lis $14
            .word 0x2B                ; Saving + char to register $14
            lis $15 
            .word 0x3F                ; Saving ? char to register $15

            addi $21, $0, 0        ; Initialize # of exact matches
            addi $22, $0, 0        ; Initialize # of partial matches
            addi $23, $0, 0        ; Initialize # of misses
 
readtw:                 
            lw $1, 0($8)            ; Read 1 char from input
            lis $3                  ; Save "Enter" into $3
            .word 0xA                
            beq $3, $1, readgw      ; If the char read in from stdin is enter, then start reading guess word
            addi $30, $30, -4       ; Reserve space on the stack
            sw $1, 0($30)           ; Store the char onto stack 
            addi $12, $12, 1        ; Increment length counter
            addi $4, $4, 1          ; Save a copy  of the length counter in $4
            beq $0, $0, readtw      ; Read from input untill enter is encountered               
            
readgw:     beq $4, $0, stopread
            lw $1, 0($8)
            addi $30, $30, -4       ; Reserve space on the stack
            sw $1, 0($30)           ; Store the char onto stack 
            addi $4, $4, -1         ; Decrement counter by 1
            beq $0, $0, readgw      ; Repeat            

stopread:    
        
            add $19, $0, $12        ; Save length into $19
            add $16, $0, $30        ; Initialize $16 to the top of the stack
            add $17, $0, $30        ; Initialize $17 to the top of the stack
            addi $6, $12, -1        ; Set $6 to length - 1
            addi $3, $0, 4          ; Initialize $3 to 4

            mult $3, $6             ; Calculate the position of the first letter of target on stack (len - 1 * 4)
            mflo $4
            add $16, $16, $4        ; Increase pointer from last letter of target word to first letter
            addi $4, $4, 4          ; Increase $4 by 4
            add $17, $16, $4        ; Adding 4 * len to the pointer at the first word of the target will move it to the first word of the guess.

            add $20, $16, $0        ; Save a copy of the start of target word

            add $18, $0, $12        ; Set Target word count as length of the string  
            add $19, $0, $12        ; Set Guess word count as length of the string          


checkmatch:    beq $19, $0, endcheck 
            lw $2, 0($16)           ; Load char at address $16 to $2 - current target char     
            lw $3, 0($17)           ; Load char at adresss $17 to $3 - current guess char

            sub $6, $2, $3          ; Test for equality, if $6 = $0, then first letter of both words are equal
            beq $0, $6, check_ind   ; If equal, go to check_ind
            bne $0, $18, checknext  ; If target counter is not 0, check next char
            beq $0, $18, miss       ; If target counter is 0, this char is not in target
check_ind:
            sub $1, $18, $19          ; Find the difference between the 2 counters
        
            beq $0, $1, exact_match   ; If difference in counters is 0, it is a perfect match
            bne $0, $1, partial_match ; If difference is greater or less it is a partial match

exact_match:
            addi $21, $21, 1        ; Increment  match counter
            sw $13, 0($9)           ; Print "." char
            beq $0,$0, next_guess

partial_match:
            addi $22, $22, 1        ; Increment partial match counter
            sw $14, 0($9)           ; Print "+" char
            beq $0,$0, next_guess
miss:
            addi $23, $23, 1
            sw $15, 0($9)           ; Print "?" char
            beq $0,$0, next_guess   

checknext:
            addi $16, $16, -4        ; Move Target pointer up
            addi $18, $18, -1        ; Decrement Target counter
            beq $0, $0, checkmatch

next_guess:
            addi $17, $17, -4       ; Move Guess pointer up
            addi $19, $19, -1       ; Decrement Guess counter
            add $16, $0, $20        ; Reset Target pointer
            add $18, $0, $12        ; Reset Target Counter
            beq $0, $0, checkmatch  
endcheck:
            lis $1                  
            .word 0xA
            sw $1, 0($9)            ; Print newline
            jr $31

        