#SingleInstance Force
#Persistent
SetBatchLines,-1
HookProcAdr := RegisterCallback( "HookProc", "F" )
hWinEventHook := SetWinEventHook( 0x3, 0x3, 0, HookProcAdr, 0, 0, 0 )
OnExit, HandleExit
Return

HookProc( hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime )
{
	if Event ; EVENT_SYSTEM_FOREGROUND = 0x3
	{
		OutputDebug, In HookProc
	}
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags)
{
	DllCall("CoInitialize", Uint, 0)
	return DllCall("SetWinEventHook"
	, Uint,eventMin
	, Uint,eventMax
	, Uint,hmodWinEventProc
	, Uint,lpfnWinEventProc
	, Uint,idProcess
	, Uint,idThread
	, Uint,dwFlags)
}

UnhookWinEvent()
{
	Global
	DllCall( "UnhookWinEvent", Uint,hWinEventHook )
	DllCall( "GlobalFree", UInt,&HookProcAdr ) ; free up allocated memory for RegisterCallback
}

HandleExit:
UnhookWinEvent()
ExitApp
Return