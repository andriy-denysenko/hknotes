IniWrite, test1, test.ini, general, test_key1
IniWrite, test2, test.ini, general, test_key2
IniWrite, test3, test.ini, subjective, test_key3
settings := LoadSettings("test.ini")
MsgBox, % settings["general"]["test_key1"]
SaveSettings(settings, "test1.ini")
MsgBox, Done

return

LoadSettings(file){
	OutputDebug, Reading settings
	objSettings := {}
	IniRead, sections, %file%
	Loop, Parse, sections, `n, `r
	{
		section := A_LoopField
		objSettings[section] := {}
		IniRead, kvpairs, %file%, %A_LoopField%
		OutputDebug, Reading section '%section%'; A_LoopField=%A_LoopField%
		Loop, Parse, kvpairs, `n, `r
		{
			OutputDebug, Inner loop A_LoopField=%A_LoopField%
			kvpair := StrSplit(A_LoopField, "=")
			objSettings[section][kvpair[1]] := kvpair[2]
		}
	}
	OutputDebug, Done reading settings
	return objSettings
}

SaveSettings(objSettings, file){
	OutputDebug, Writing settings
	for section, kvpairs in objSettings{
		OutputDebug, Writing section '%section%'
		for key, value in kvpairs{
			IniWrite, value, %file%, %section%, %key%
			if(ErrorLevel > 0){
				msg = Error writing into the ini-file.`r`nThe script will close now.
				MsgBox, 16, Error - %ScriptNameNoExt%, %msg%
				;goto HandleExit
			}
		}
	}
	OutputDebug, Done writing settings
}