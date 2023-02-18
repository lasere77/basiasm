bits 64 
global _start

section .data
    lose db "you have lose...", 10, 0
    loseLen equ $-lose

    win db "gg you have win this game!!!", 10, 0
    winLen equ $-win

    infoPlayer db "your health is: ", 0
    infoPlayerLen equ $-infoPlayer

    infoMob db "the health of enemy is: ", 0
    infoMobLen equ $-infoMob

    action db "you can attack with 'a' or treated you with 'b' or 'e' for exit.", 10, 0
    actionLen equ $-action

    playerAttack db "you attacked the mob.", 10, 0
    playerAttackLen equ $-playerAttack

    playerAttackStrike db "you crtitically hit the mob!!!", 10, 0
    playerAttackStrikeLen equ $-playerAttackStrike

    mobAttack db "the mob attacked you.", 10, 0
    mobAttackLen equ $-mobAttack

    health db "you have regenerated 20 life points!", 10, 0
    healthLen equ $-health

    n db 10, 0
    nLen equ $-n

    style db "-----------------------------------------------------------", 10, 0
    styleLen equ $-style

    commandNotFound db "!!!!!!!!!!! this command is not found !!!!!!!!!!!", 10, 0
    commandNotFoundLen equ $-commandNotFound

    DAMAGE equ 10
    STRIKE equ 5
    POTION equ 20
    INPUTMAX equ 2

section .bss
    input resb INPUTMAX

    digitSpace resb 100
    digitSpacePos resb 8

section .text
_start:
    push 0         ;Critical Strike
    push 200       ;mob health          
    push 100       ;player health           
    push 1         ;type bool if the prog is running    
    jmp _loop
    jmp _exit

_loop:
    ;check if running
    cmp byte [rsp], 1
    jne _exit

    ;check player health
    cmp word [rsp + 8], 0
    jle _lose 

    ;check mob Health
    cmp word [rsp + 16], 0
    jle _win

    ;Critical Strike
    cmp word [rsp + 24], 3
    jae _criticalStrike

    call _style
    call _info
    call _stdCin

    cmp byte [input], 'a'
    je _attack

    cmp byte [input], 'b'
    je _health

    cmp byte [input], 'e'
    je _exit


    mov rax, 1
    mov rdi, 1
    mov rsi, commandNotFound
    mov rdx, commandNotFoundLen
    syscall

    jmp _loop
    
_style:
    mov rax, 1
    mov rdi, 1
    mov rsi, n
    mov rdx, nLen
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, style
    mov rdx, styleLen
    syscall 

    ret
_info:
    mov rax, 1
    mov rdx, 1
    mov rsi, infoPlayer
    mov rdx, infoPlayerLen
    syscall

    ;print the value of playerHealth
    mov rax, [rsp + 8 + 8]
    call _printRax

    mov rax, 1
    mov rdi, 1
    mov rsi, infoMob
    mov rdx, infoMobLen
    syscall

    ;print the value of mobHealth
    mov rax, [rsp + 16 + 8]
    call _printRax
    
    mov rax, 1
    mov rdi, 1
    mov rsi, n
    mov rdx, nLen
    syscall

    ret

_stdCin:
    ;say the different possible actions
    mov rax, 1
    mov rdi, 1
    mov rsi, action
    mov rdx, actionLen
    syscall

    ;input
    mov rax, 0
    mov rdi, 1
    mov rsi, input
    mov rdx, INPUTMAX
    syscall

    ret
_printRax:;make a line breake in the list and make rcx a ptr
    mov rcx, digitSpace     ;put the value
    mov rbx, 10             ;line break
    mov [rcx], rbx          ;put new ligne in rcx value
    inc rcx                 ;change address of rcx
    mov [digitSpacePos], rcx;put the new address in digitSpacePos

_printRaxLoop:
    ;nb / 10 ;grab the next nubers nb, ex 115 -> 5
    mov rdx, 0
    mov rbx, 10
    div rbx
    add rdx, 48 ;for the ascii tabel

    mov rcx, [digitSpacePos]
    mov [rcx], dl
    inc rcx
    mov [digitSpacePos], rcx

    ;if div return 0 pass
    cmp rax, 0
    jne _printRaxLoop


_printRaxLoop2:
    mov rcx, [digitSpacePos]

    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall

    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx

    cmp rcx, digitSpace
    jge _printRaxLoop2

    ret

_attack:
    ;make damage
    sub word [rsp + 16], DAMAGE
    
    ;proba Strike
    inc word [rsp + 24]

    ;say that the mob has suffered damage
    mov rax, 1
    mov rdi, 1
    mov rsi, playerAttack
    mov rdx, playerAttackLen
    syscall

    jmp _mob

_criticalStrike:
    mov byte [rsp + 24], 0
    ;make samage
    sub word [rsp + 16], DAMAGE + STRIKE
    ;say that the mob has suffered damage
    mov rax, 1
    mov rdi, 1
    mov rsi, playerAttackStrike
    mov rdx, playerAttackStrikeLen
    syscall

    jmp _mob


_health:
    ;add point life for player
    add word [rsp + 8], POTION
    mov rax, 1
    mov rdi, 1
    mov rsi, health
    mov rdx, healthLen
    syscall

    jmp _mob


_mob:
    ;make dammager
    sub byte [rsp + 8], DAMAGE
    ;say that the player has suffered damage
    mov rax, 1
    mov rdi, 1
    mov rsi, mobAttack
    mov rdx, mobAttackLen
    syscall

    jmp _loop

_win:
    mov rax, 1
    mov rdi, 1
    mov rsi, win
    mov rdx, winLen
    syscall

    jmp _exit


_lose:
    mov rax, 1
    mov rdi, 1
    mov rsi, lose
    mov rdx, loseLen
    syscall

    jmp _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall