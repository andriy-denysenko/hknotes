#Persistent

; MVP
;
; Notes are stored in an ini-file:
;    [id]
;    text=
;    window_title=
;    pos=
;    size=
; Newlines are converted into \n's then vice versa
;
; Commands:
; New (tray, hk)
; Hide
; Hide all for active window
; Show all for active window
; List
;
; GUIs:
; List window with window list and note list for selected window
; Note windows for each note for an active window
;
; Active window is checked in a loop

OnExit, ExitScript

EVENT_SYSTEM_FOREGROUND := 3
WINEVENT_OUTOFCONTEXT := 0
WINEVENT_SKIPOWNPROCESS = 2

global HOOK = -1

OutputDebug, Setting hook

HOOK := SetHook()
if (HOOK == 0){
	OutputDebug, Error setting hook
	goto ExitScript
}

OutputDebug, Hook set: '%HOOK%'

return

SetHook(){
	WinEventProcCallback := RegisterCallback("WinEventProcCallback")
	return DllCall("SetWinEventHook", "UInt", EVENT_SYSTEM_FOREGROUND, "UInt", EVENT_SYSTEM_FOREGROUND, "Ptr", 0, "Ptr", WinEventProcCallback, "UInt", 0, "UInt", 0, "UInt", WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS)
}
; WinEventProcCallback
WinEventProcCallback(hWinEventHook, dwEvent, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
	OutputDebug, "Active window: " WinGetActiveTitle()
}

Unhook(hWinEventHook){
	return DllCall("UnhookWinEvent", "Ptr", hWinEventHook)
}

ExitScript:
	OutputDebug, Unsetting hook
	result := Unhook(HOOK)
	OutputDebug, Hook unset with result: '%result%'
	ExitApp