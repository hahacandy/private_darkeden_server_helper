#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


IsDarkeden()
{
	IfWinActive, DarkEden
		return true
	else
		return false
}


AutoPotionHp(ByRef _cooldown_hp, ByRef _cooldown_all, _setHp, _quickSlot, _cooldown_dealy, _cooldown_dealy_all)
{

	if(_cooldown_hp+_cooldown_dealy < A_TickCount && _cooldown_all+_cooldown_dealy_all < A_TickCount)
	{

		current_hp_per := GetHpPer()
		
		if(_setHp >= current_hp_per)
		{
			if(UseItemKeySend(_quickSlot, "hp"))
			{
				_cooldown_hp := A_TickCount
				_cooldown_all := A_TickCount

			}
		}

	}

	return
}

AutoPotionMp(ByRef _cooldown_mp, ByRef _cooldown_all, _setMp, _quickSlot, _cooldown_dealy, _cooldown_dealy_all)
{

	if(_cooldown_mp+_cooldown_dealy < A_TickCount && _cooldown_all+_cooldown_dealy_all < A_TickCount)
	{

		current_mp_per := GetMpPer()
		
	
		if(_setMp >= current_mp_per)
		{
			if(UseItemKeySend(_quickSlot, "mp"))
			{
				_cooldown_mp := A_TickCount
				_cooldown_all := A_TickCount

			}
		}
	}


	return
}

AutoPotionAmmo(ByRef _cooldown_ammo, ByRef _cooldown_all, _setAmmo, _quickSlot, _cooldown_dealy, _cooldown_dealy_all)
{

	if(_cooldown_ammo+_cooldown_dealy < A_TickCount && _cooldown_all+_cooldown_dealy_all < A_TickCount)
	{
			
			current_ammo := GetAmmoNum()
			if(_setAmmo >= current_ammo)
			{
				if(UseItemKeySend(_quickSlot, "ammo"))
				{
					_cooldown_ammo := A_TickCount
					_cooldown_all := A_TickCount

				}
			}

	}

	return
}

GetHpPer()
{
   value:=Round((getCurrentHp()/getMaxHp())*100) ; 현재체력 / 최대체력
   return value
}

getCurrentHp()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7978520,"DarkEden")
   return value
}

getMaxHp()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7978528,"DarkEden")
   return value
}

GetMpPer()
{
	value:=Round((getCurrentMp()/getMaxMp())*100)
	return value
}

getCurrentMp()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7978524,"DarkEden")
   return value
}

getMaxMp()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7978532,"DarkEden")
   return value
}

GetAmmoNum()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7760840,"DarkEden")
   value:=ReadMemory(value+60,"DarkEden")
   return value
}


GetVision()
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7873300,"DarkEden")
   value:=ReadMemory(value+1272,"DarkEden")
   return value
}

VisionChange(vision_value)
{
   value:=getProcessBaseAddress("DarkEden")
   SetFormat, integer, d
   value += 0
   value:=ReadMemory(value+7873300,"DarkEden")
   value+=1272
   
   WriteMemory(vision_value, value,"DarkEden")
   return
}

MapBoxOn(mapOn:=true)
{
	value:=getProcessBaseAddress("DarkEden")
	SetFormat, integer, d
	value += 0
	value:=ReadMemory(value+0x0079AAD0,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x24,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x28,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x3C,"DarkEden")
	value:=value+0x30
	
	if(mapOn)
		WriteMemory(0, value,"DarkEden")
	else
		WriteMemory(1, value,"DarkEden")
		
	return
}

IsChatBox()
{
	value:=getProcessBaseAddress("DarkEden")
	SetFormat, integer, d
	value += 0
	value:=ReadMemory(value+0x0079AAD0,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x24,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x28,"DarkEden")
	value:=ReadMemory(value+0xC,"DarkEden")
	value:=ReadMemory(value+0x44,"DarkEden")
	value:=ReadMemory(value+0x5C,"DarkEden")
	
	if(value == 16843008)
		return false
	else
		return true
}

getProcessBaseAddress(WindowTitle)
{
    SetFormat, IntegerFast, hex
    WinGet, hWnd, ID, %WindowTitle%
    BaseAddress := DllCall(A_PtrSize = 4
        ? "GetWindowLong"
        : "GetWindowLongPtr", "Uint", hWnd, "Uint", -6)
    return BaseAddress
}

ReadMemory(MADDRESS,PROGRAM)
{
	winget, pid, PID, %PROGRAM%
	VarSetCapacity(MVALUE,4,0)
	ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
	DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Str",MVALUE,"UInt",4,"UInt *",0)
	Loop 4
	result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
	return, result  
}

WriteMemory(WVALUE,MADDRESS,PROGRAM)
{
	winget, pid, PID, %PROGRAM%

	ProcessHandle := DllCall("OpenProcess", "int", 2035711, "char", 0, "UInt", PID, "UInt")
	DllCall("WriteProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS, "Uint*", WVALUE, "Uint", 4, "Uint *", 0)

	DllCall("CloseHandle", "int", ProcessHandle)
return
}

UseItemKeySend(_quickSlot, _type)
{
	sendKeyFlag := false
	For index, key in _quickSlot
	{
		sendKey := "f" . index
		

		if(key == "HP포션" && _type == "hp") ; 체력포션
		{
			if(sendKey == "f4") ;f4누를때 알트키 눌려있으면 떔
			{
				send {lalt up}
				send {ralt up}
			}
			send {%sendKey%}
			sendKeyFlag := true
		}
		else if(key == "MP포션" && _type == "mp") ; 마나포션
		{
			if(sendKey == "f4") ;f4누를때 알트키 눌려있으면 떔
			{
				send {lalt up}
				send {ralt up}
			}
			send {%sendKey%}
			sendKeyFlag := true
		}
		else if(key == "총알" && _type == "ammo") ; 총알
		{
			if(sendKey == "f4") ;f4누를때 알트키 눌려있으면 떔
			{
				send {lalt up}
				send {ralt up}
			}
			send {%sendKey%}
			sendKeyFlag := true
		}
		
	}
	if(sendKeyFlag)
	{
		return true
	}
	else
	{
		return false
	}
	
}








