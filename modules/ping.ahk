#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%\auto.ahk

SetBatchLines -1

Run ping_check.bat

cooldown_ping := 0

SetTimer, PingTest, 100

PingTest:
{
	AutoPing(cooldown_ping)
	IfWinNotExist, DarkEden
	{
		exitapp
	}
	return
}

AutoPing(ByRef _cooldown_ping)
{
	if(IsDarkeden())
	{
		if(_cooldown_ping+1000 < A_TickCount)
		{
			_cooldown_ping := A_TickCount
			
			ping := ""
			Loop, Read, ping.txt
			{
				ping := A_LoopReadLine
			}
			RegExMatch(ping,"[0-9]{1,5}ms", dataO)
			if(StrLen(dataO) > 0)
				ToolTip, %dataO%, 650, 0
			else
				ToolTip, ???ms, 650, 0
		}

	}
	else
		ToolTip
	return
}

NumpadDel::
	Return



