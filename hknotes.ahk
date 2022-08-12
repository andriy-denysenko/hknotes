OutputDebug, DBGVIEWCLEAR
; MVP
;
; Notes are stored in txt files in a 'AppData/notes' folder.
; File structure with line numbers:
; MVP:
;Title (1 line)
;Content (multiline)
; Future:
;[1]Title (1 line)
;[2]window-titles=Window titles (comma-separated, regex)
;[3]pos=LEFT,TOP
;[4]size=WIDTH,HEIGHT
;[5]tags=tag1,...(comma-separated); suggest tags based on frequent words
;[6]categories=cat1,...
;[...] all lines with [A-Za-z0-9_\-]+=
;
; INI:
; [fs]
; NotesDir=
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

; Based on hook example by Serenity: https://www.autohotkey.com/board/topic/32662-tool-wineventhook-messages/

; BEGIN Serenity's code
#SingleInstance Force
#Persistent
SetBatchLines,-1
EVENT_SYSTEM_FOREGROUND := 0x3
HookProcAdr := RegisterCallback( "HookProc", "F" )
hWinEventHook := SetWinEventHook( EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, 0, HookProcAdr, 0, 0, 0 )
OnExit, HandleExit
; END Serenity's code

global APP_TITLE = HKNotes
global Settings := {}
global ScriptNameNoExt := ""
SplitPath, A_ScriptFullPath,,,, ScriptNameNoExt
global IniFile := A_ScriptDir "\AppData\" ScriptNameNoExt ".ini"
global NoteFileFilter := "*.txt"

if(!FileExist(IniFile)){
	gosub SetDefaults
}

settings := LoadSettings(IniFile)

OutputDebug, Loading notes...
global Notes := LoadNotes()

names =
for name, note in Notes
{
	OutputDebug, Loading note '%name%'
	names = %names%|%name%
}
names := SubStr(names, 2)

; GUIs ======================================================================
Gui, NoteList:New, +Resize, %APP_TITLE%
Gui, NoteList:Add, ListBox, w200 r20 vNoteName, %names%
Gui, NoteList:Add, Edit, w500 r25 vNoteContent xp+205 yp
Gui, NoteList:Show, Autosize, %APP_TITLE%

Return

LoadNotes(){
	global settings
	notes := {}
	dir := settings["Paths"]["NotesDir"]
	OutputDebug, Searching '%dir%\%NoteFileFilter%'
	Loop, Files, %dir%\%NoteFileFilter%
	{
		SplitPath, A_LoopFileFullPath,,,,Name
		OutputDebug, Reading file '%Name%'
		FileReadLine, title, %A_LoopFileFullPath%, 1
		; Pass errors silently
		; TODO: ask what to do or delete empty files?
		if(ErrorLevel > 0){
			continue
		}
		FileRead, content, %A_LoopFileFullPath%
		lines := StrSplit(content, "`n", "`r", 2)

		notes[name] := {"title":lines[1], "content":lines[2]}
	}
	return notes
}

SetDefaults:
	settings["Paths"] := {}
	settings["Paths"]["NotesDir"] := A_ScriptDir "\AppData\notes"
	if (!SaveSettings(settings, IniFile)){
		goto HandleExit
	}
return

SaveSettings(objSettings, file){
	for section, kvpairs in objSettings{
		for key, value in kvpairs{
			IniWrite, %value%, %file%, %section%, %key%
			if(ErrorLevel > 0){
				msg = Error writing into the ini-file.`r`nThe script will close now.
				MsgBox, 16, Error - %ScriptNameNoExt%, %msg%
				return False
			}
		}
	}
}

LoadSettings(file){
	objSettings := {}
	IniRead, sections, %file%
	Loop, Parse, sections, `n, `r
	{
		section := A_LoopField
		objSettings[section] := {}
		IniRead, kvpairs, %file%, %A_LoopField%
		Loop, Parse, kvpairs, `n, `r
		{
			kvpair := StrSplit(A_LoopField, "=")
			objSettings[section][kvpair[1]] := kvpair[2]
			OutputDebug, % "Reading " kvpair[1] "=" kvpair[2]
		}
	}
	return objSettings
}

; BEGIN Serenity's code
HookProc( hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime )
{
	if Event ; EVENT_SYSTEM_FOREGROUND = 0x3
	{
		WinGetTitle, WinTitle, A
		OutputDebug, Active window: '%WinTitle%'
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

; END Serenity's code

; BEGIN Serenity's code
HandleExit:
UnhookWinEvent()
ExitApp
Return
; END Serenity's code