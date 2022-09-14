#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%\auto.ahk

SetDefaultMouseSpeed,0 
SetKeyDelay,-1
SetControlDelay,-1
SetBatchLines -1 
SetWinDelay,-1
SetMouseDelay,-1

CoordMode, Pixel, Client
CoordMode, Mouse, Client

stone := 0

cooldown_stone := 0

SetTimer, isDarkeden, 100

SetTimer, _isDarkedenCheck, 100

CapsLock::
	if(isDarkeden())
	{
		cooldown_stone := A_TickCount
		ToolTip, autoHunter, 400, 0
		AutoAttack()
	}
	return
	
Delete::	
	if(isDarkeden())
	{
		cooldown_stone := A_TickCount
		ToolTip, autoMove, 400, 0
		MouseClick, L, , , , , D
	}
	return
	
`::
	if(isDarkeden())
	{
		cooldown_stone := A_TickCount
		ToolTip, AutoStonePick, 400, 0
		AutoStonePick(stone, cooldown_stone)
	}
	return
	

1::
	send {f9}
	return
	
2::
send {f10}
return

3::
send {f11}
return

4::
send {f12}
return

5::
send {f7}
return

6::
send {f8}
return

	
end::
	reload
	return

isDarkeden:
	if(!isDarkeden())
	{
		ToolTip
	}
	else
	{
		if(cooldown_stone+3000<A_TickCount)
		{
			ToolTip, stonePick and autoHunter Wating.., 400, 0
		}
	}
	return
	
_isDarkedenCheck:
{
	IfWinNotExist, DarkEden
	{
		exitapp
	}
	return
}

AutoAttack()
{
	if(IsDarkeden())
	{	
		send {CapsLock Up}
		MouseClick, R, , , , , U
		sleep 100
		send {CapsLock Down}
		sleep 100
		MouseClick, R, , , , , D
		sleep 100
		send {CapsLock Up}
	}
}

AutoStonePick(ByRef _stone, ByRef _cooldown_stone)
{
	if(IsDarkeden())
	{
		MouseGetPos, vXX, vYY
		clickX := 0
		clickY := 0
		send {alt down}
		sleep 100
		ImageSearch,vx,vy, 700, 150, 800, 400, *120 ..\imgs\stone1.png
		If ErrorLevel = 0
		{
			clickX := vx
			clickY := vy
		}
		ImageSearch,vx,vy, 700, 150, 800, 400, *120 ..\imgs\stone2.png
		If ErrorLevel = 0
		{
			if(clickY > vy &&  clickY > 0)
			{
				clickX := vx
				clickY := vy
			}
			else if(clickX == 0 && clickY == 0)
			{
				clickX := vx
				clickY := vy
			}
		}
		
		if(clickY > 0)
		{
			_cooldown_stone := A_TickCount
			
			_stone++
			ToolTip, AutoStonePick: %_stone%, 400, 0
			click, %clickX%, %clickY%
			sleep 100
			MouseMove, %vXX%, %vYY%
		}
		

		send {alt up}
	}
		else
			ToolTip
}
	