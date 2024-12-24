INCLUDE Irvine32.inc  ; Include the Irvine32 library for I/O functions

.data
    prompt BYTE "Enter a message: $", 0    ; Prompt for user input
    msg BYTE 100 DUP(0)   ; Reserve space for the input message (up to 100 chars)
    result BYTE 100 DUP(0) ; Reserve space for the encrypted message (same size as input)
    msgLength DWORD 0      ; Variable to hold the length of the message
    newline BYTE 0Dh, 0Ah, 0  ; Newline characters

.code
main:
    ; Display the prompt to the user
    mov edx, OFFSET prompt    ; Load the address of the prompt
    call WriteString          ; Call WriteString to display the prompt

    ; Take user input (maximum 100 characters)
    mov edx, OFFSET msg       ; Load the address where input will be stored
    mov ecx, 100              ; Set the maximum number of characters to read
    call ReadString           ; Call ReadString to get the input from the user

    ; Calculate the message length (find the null terminator in the string)
    mov esi, OFFSET msg       ; Point ESI to the input string
    mov ecx, 0                ; ECX will hold the length of the string

find_length:
    cmp byte ptr [esi + ecx], 0  ; Check if we've reached the null terminator
    je done_length              ; Jump if null terminator found
    inc ecx                      ; Increment counter (length)
    jmp find_length              ; Repeat the loop

done_length:
    mov [msgLength], ecx         ; Store the length of the message

    ; Encrypt the message using the Caesar cipher (+3 shift)
    mov esi, OFFSET msg          ; Point ESI to the input message
    mov edi, OFFSET result       ; Point EDI to the result buffer
    mov ecx, [msgLength]         ; Load message length into ECX

encrypt_loop:
    mov al, byte ptr [esi]       ; Load the current character into AL
    cmp al, 0                    ; Check if it's the null terminator
    je done_encryption           ; If null terminator, we're done

    ; Check if the character is uppercase ('A'-'Z')
    cmp al, 'A'
    jl check_lowercase           ; If less than 'A', check for lowercase
    cmp al, 'Z'
    jg check_lowercase           ; If greater than 'Z', check for lowercase
    add al, 3                    ; Shift uppercase by 3
    cmp al, 'Z'
    jle store_result             ; If within bounds, store the result
    sub al, 26                   ; Wrap around (if > 'Z', subtract 26)
    jmp store_result

check_lowercase:
    cmp al, 'a'
    jl store_result              ; If less than 'a', store without change
    cmp al, 'z'
    jg store_result              ; If greater than 'z', store without change
    add al, 3                    ; Shift lowercase by 3
    cmp al, 'z'
    jle store_result             ; If within bounds, store the result
    sub al, 26                   ; Wrap around (if > 'z', subtract 26)

store_result:
    mov byte ptr [edi], al       ; Store the result character in the result buffer
    inc esi                      ; Move to the next character in the input string
    inc edi                      ; Move to the next position in the result buffer
    loop encrypt_loop            ; Repeat for all characters

done_encryption:
    ; Null-terminate the result string
    mov byte ptr [edi], 0        ; Add null terminator to the encrypted string

    ; Output the result string
    mov edx, OFFSET result       ; Load the address of the encrypted string
    call WriteString             ; Display the encrypted string

    ; Add a newline for better formatting
    mov edx, OFFSET newline      ; Load the newline characters
    call WriteString             ; Output the newline

    exit                         ; Exit the program
end main