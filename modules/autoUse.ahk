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

;다덴창 비활성화하다가 활성화 됐을때 알트키 뗴줘서(미리 눌러져있음) 불편함 없애줌
firstActive := false

; 시작버튼 눌렀는지, 중지버튼 눌럿는지 구분
start_flag := false

;원래 비전 수치
vision := 0

Msgbox, 본 프로그램은 영덴전용 사냥도우미 프로그램입니다.`n다른 곳에서는 사용 불가능합니다.
Msgbox, V1.4.2`n2022.09.05`nKiBou
;;;;;;;;;;

IfWinNotExist, DarkEden
{
	msgbox 영덴을 켜주세요.`n프로그램을 종료합니다.
	exitapp
}

; 다덴 꺼지면 같이 꺼짐
SetTimer, _isDarkedenCheck, 100




Gui Add, Text, x18 y16 w44 h23 +0x200, HP포션
Gui Add, Edit, x72 y16 w40 h21 vgui_hp_set, 75
Gui Add, Text, x128 y16 w67 h23 +0x200, `% 이하 사용

Gui Add, Text, x18 y56 w44 h23 +0x200, MP포션
Gui Add, Edit, x72 y56 w40 h21 vgui_mp_set, 50
Gui Add, Text, x128 y56 w67 h23 +0x200, `% 이하 사용

Gui Add, Text, x30 y96 w44 h23 +0x200, 총알
Gui Add, Edit, x72 y96 w40 h21 vgui_ammo_set, 10
Gui Add, Text, x128 y96 w67 h23 +0x200, 발 이하 사용

Gui Add, Text, x8 y136 w198 h2 +0x10

Gui Add, Text, x18 y150 w110 h23 +0x200, 같은 물약 간 딜레이
Gui Add, Edit, x135 y150 w40 h21 vgui_cooldown, 3.5
Gui Add, Text, x180 y150 w67 h23 +0x200, `초

Gui Add, Text, x18 y181 w110 h23 +0x200, 다른 물약 간 딜레이
Gui Add, Edit, x135 y181 w40 h21 vgui_cooldown_all, 1.0
Gui Add, Text, x180 y181 w67 h23 +0x200, `초

Gui Add, Text, x8 y213 w198 h2 +0x10

Gui Add, Text, x94 y220 w29 h23 +0x200, 벨트
Gui Add, Text, x48 y250 w23 h23 +0x200, F1
Gui Add, Text, x48 y280 w23 h23 +0x200, F2
Gui Add, Text, x48 y310 w23 h23 +0x200, F3
Gui Add, Text, x48 y340 w23 h23 +0x200, F4
Gui Add, Text, x48 y370 w23 h23 +0x200, F5
Gui Add, Text, x48 y400 w23 h23 +0x200, F6
Gui Add, Text, x48 y430 w23 h23 +0x200, F7
Gui Add, Text, x48 y460 w23 h23 +0x200, F8

gosub load_setting

Gui Add, Text, x8 y500 w198 h2 +0x10

Gui Add, Button, x45 y510 w126 h42 gstart_stop_btn vstart_stop_btn, 시작


Gui Show, w217 h560, 영덴용
Return

GuiEscape:
GuiClose:
    ExitApp
	

start_stop_btn:
{
	
	if(!start_flag)
	{
		gosub start_btn_start
	}
	else if(start_flag)
	{
		SetTimer, _In_Game_Repeat, off
		VisionChange(vision)
		gosub start_btn_stop
	}
	return
}


start_btn_start:
{
	gui,submit,nohide
	
	; HP설정 잘못됬나 확인
	if(gui_hp_set<1)
		gui_hp_set := Floor(gui_hp_set)
	else if(gui_hp_set>99)
		gui_hp_set := Ceil(gui_hp_set)
	
	if(gui_hp_set < 1 || gui_hp_set > 99)
	{
		msgbox HP설정을 1~99 사이로 입력 해주세요.
		return
	}
	
	; MP설정 잘못됬나 확인
	if(gui_mp_set<1)
		gui_mp_set := Floor(gui_mp_set)
	else if(gui_mp_set>99)
		gui_mp_set := Ceil(gui_mp_set)
	
	if(gui_mp_set < 1 || gui_mp_set > 99)
	{
		msgbox MP설정을 1~99 사이로 입력 해주세요.
		return
	}
	
	; 총알설정 잘못됬나 확인
	if(gui_ammo_set<1)
		gui_ammo_set := Floor(gui_ammo_set)
	else if(gui_ammo_set>79)
		gui_ammo_set := Ceil(gui_ammo_set)
	
	if(gui_ammo_set < 1 || gui_ammo_set > 79)
	{
		msgbox 총알설정을 1~79 사이로 입력 해주세요.
		return
	}
	
	; 같은 물약 간 딜레이 잘못됏나 확인
	gui_cooldown := Round(gui_cooldown*1000)
	if(gui_cooldown < 2500 || gui_cooldown > 4500)
	{
		msgbox 같은 물약 간 딜레이를 2.5~4.5초 사이로 입력 해주세요.
		return
	}
	
	; 다른 물약 간 딜레이 잘못됏나 확인
	gui_cooldown_all := Round(gui_cooldown_all*1000)
	if(gui_cooldown_all < 500 || gui_cooldown_all > 1500)
	{
		msgbox 다른 물약 간 딜레이를 0.5~1.5초 사이로 입력 해주세요.
		return
	}
	
	; 벨트 f1~f8까지 설정
	quickSlot := [gui_f1, gui_f2, gui_f3, gui_f4, gui_f5, gui_f6, gui_f7, gui_f8]
	
	onHp := false
	onMp := false
	onAmmo := false
	
	isQuickSlot := false
	For index, value in quickSlot
	{
		if(value=="HP포션")
		{
			onHp:=true
			isQuickSlot:=true
		}
		else if(value=="MP포션")
		{
			onMp:=true
			isQuickSlot:=true
		}
		else if(value=="총알")
		{
			onAmmo:=true
			isQuickSlot:=true
		}
	}
	
	if(!isQuickSlot)
	{
		msgbox 벨트 설정을 해주세요.
		return
	}
	
	idleTooltipStr := ""

	hpI := 0
	mpI := 0
	ammoI := 0
	cooldown_hp := 0
	cooldown_mp := 0
	cooldown_ammo := 0
	cooldown_all := 0
	
	gosub save_setting
	
	GuiControl, Disable, gui_hp_set
	GuiControl, Disable, gui_mp_set
	GuiControl, Disable, gui_ammo_set
	
	gui_cooldown_view := Round(gui_cooldown/1000, 1)
	GuiControl, , gui_cooldown, %gui_cooldown_view%
	GuiControl, Disable, gui_cooldown
	gui_cooldown_all_view := Round(gui_cooldown_all/1000, 1)
	GuiControl, , gui_cooldown_all, %gui_cooldown_all_view%
	GuiControl, Disable, gui_cooldown_all
	
	
	GuiControl, Disable, gui_f1
	GuiControl, Disable, gui_f2
	GuiControl, Disable, gui_f3
	GuiControl, Disable, gui_f4
	GuiControl, Disable, gui_f5
	GuiControl, Disable, gui_f6
	GuiControl, Disable, gui_f7
	GuiControl, Disable, gui_f8
	
	GuiControl,, start_stop_btn, 중지
	
	start_flag := true
	
	SetTimer, _start, 100
	
	IfWinActive, DarkEden
	{
	}
	else
	{
		WinActivate, DarkEden
	}
	
	vision := GetVision()
	SetTimer, _In_Game_Repeat, 100

	return
}


_start:
{

	if(IsDarkeden())
	{
		if(!firstActive)
		{
			firstActive := true
			sleep 150
			send {Ralt}
			
		}
		

		
		current_hp_per := GetHpPer()

		if(current_hp_per > 0)
		{
			; 현재 체력, 마나, 총알 정보를 idleTooltipStr 변수에 저장
			IdleTooltipStrSet()
			
			
			; 채팅창 열려있으면 동작안함
			if(IsChatBox())
			{
				idleTooltipStr := idleTooltipStr . " 일시정지(채팅창 열림)"
				ToolTip, %idleTooltipStr%, 0, 0
				return
			}
				
			ToolTip, %idleTooltipStr%, 0, 0
			
			AutoPotionHp(cooldown_hp, cooldown_all, gui_hp_set, quickSlot, gui_cooldown, gui_cooldown_all)
			AutoPotionMp(cooldown_mp, cooldown_all, gui_mp_set, quickSlot, gui_cooldown, gui_cooldown_all)
			AutoPotionAmmo(cooldown_ammo, cooldown_all, gui_ammo_set, quickSlot, gui_cooldown, gui_cooldown_all)
		}
		else
		{
			ToolTip, Stop, 0, 0
		}
	}
	else
	{
		ToolTip
		if(firstActive)
		{
			firstActive := false
		}
	}
	return
}


start_btn_stop:
{
	
	SetTimer, _start, Off
	
	start_flag := false
	
	GuiControl, Enable, gui_hp_set
	GuiControl, Enable, gui_mp_set
	GuiControl, Enable, gui_ammo_set
	GuiControl, Enable, gui_cooldown
	GuiControl, Enable, gui_cooldown_all
	GuiControl, Enable, gui_f1
	GuiControl, Enable, gui_f2
	GuiControl, Enable, gui_f3
	GuiControl, Enable, gui_f4
	GuiControl, Enable, gui_f5
	GuiControl, Enable, gui_f6
	GuiControl, Enable, gui_f7
	GuiControl, Enable, gui_f8
	ToolTip
	
	GuiControl,, start_stop_btn, 실행
	
	return
}

load_setting:

	;셋팅 정보
	IfExist, %A_ScriptDir%\오로물약set.txt
	{
		settingArray := []
		Loop, Read, %A_ScriptDir%\오로물약set.txt
		{
			settingArray.Push(A_LoopReadLine)
		}
		
		if(settingArray.Length() == 13)
		{
			if(settingArray[1] >= 1 && settingArray[1] <= 99)
				selectNum1 := settingArray[1]
			else
				selectNum1 := 75
				
			if(settingArray[2] >= 1 && settingArray[2] <= 99)
				selectNum2 := settingArray[2]
			else
				selectNum2 := 50
				
			if(settingArray[3] >= 1 && settingArray[3] <= 79)
				selectNum3 := settingArray[3]
			else
				selectNum3 := 10
				
				
			if(settingArray[4] >= 2500 && settingArray[4] <= 4500)
				selectNum4 := Round(settingArray[4]/1000,1)
			else
				selectNum4 := Round(3500/1000,1)
				
			if(settingArray[5] >= 500 && settingArray[5] <= 1500)
				selectNum5 := Round(settingArray[5]/1000,1)
			else
				selectNum5 := Round(1000/1000,1)
				
				
		
			if(settingArray[6] >= 1 && settingArray[6] <= 4)
				selectNum6 := settingArray[6]
			else
				selectNum6 := 4
				
			if(settingArray[7] >= 1 && settingArray[7] <= 4)
				selectNum7 := settingArray[7]
			else
				selectNum7 := 4
				
			if(settingArray[8] >= 1 && settingArray[8] <= 4)
				selectNum8 := settingArray[8]
			else
				selectNum8 := 4
				
			if(settingArray[9] >= 1 && settingArray[9] <= 4)
				selectNum9 := settingArray[9]
			else
				selectNum9 := 4
				
			if(settingArray[10] >= 1 && settingArray[10] <= 4)
				selectNum10 := settingArray[10]
			else
				selectNum10 := 4
				
			if(settingArray[11] >= 1 && settingArray[11] <= 4)
				selectNum11 := settingArray[11]
			else
				selectNum11 := 4
				
			if(settingArray[12] >= 1 && settingArray[12] <= 4)
				selectNum12 := settingArray[12]
			else
				selectNum12 := 4
				
			if(settingArray[13] >= 1 && settingArray[13] <= 4)
				selectNum13 := settingArray[13]
			else
				selectNum13 := 4

				
			GuiControl,, gui_hp_set, %selectNum1%
			GuiControl,, gui_mp_set, %selectNum2%
			GuiControl,, gui_ammo_set, %selectNum3%
			
			GuiControl,, gui_cooldown, %selectNum4%
			GuiControl,, gui_cooldown_all, %selectNum5%
			                       
			Gui Add, ComboBox, x88 y250 w83 Choose%selectNum6% vgui_f1, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y280 w83 Choose%selectNum7% vgui_f2, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y310 w83 Choose%selectNum8% vgui_f3, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y340 w83 Choose%selectNum9% vgui_f4, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y370 w83 Choose%selectNum10% vgui_f5, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y400 w83 Choose%selectNum11% vgui_f6, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y430 w83 Choose%selectNum12% vgui_f7, HP포션|MP포션|총알|사용안함
			Gui Add, ComboBox, x88 y460 w83 Choose%selectNum13% vgui_f8, HP포션|MP포션|총알|사용안함
			
		}

	}
	else
	{
		FileDelete, %A_ScriptDir%\오로물약set.txt
		                       
		Gui Add, ComboBox, x88 y250 w83 Choose4 vgui_f1, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y280 w83 Choose4 vgui_f2, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y310 w83 Choose4 vgui_f3, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y340 w83 Choose4 vgui_f4, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y370 w83 Choose4 vgui_f5, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y400 w83 Choose4 vgui_f6, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y430 w83 Choose4 vgui_f7, HP포션|MP포션|총알|사용안함
		Gui Add, ComboBox, x88 y460 w83 Choose4 vgui_f8, HP포션|MP포션|총알|사용안함
	}                          
	                           
	return

save_setting:
	FileDelete, %A_ScriptDir%\오로물약set.txt
	
	FileAppend, %gui_hp_set%`n, %A_ScriptDir%\오로물약set.txt ; 
	FileAppend, %gui_mp_set%`n, %A_ScriptDir%\오로물약set.txt ; 
	FileAppend, %gui_ammo_set%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	FileAppend, %gui_cooldown%`n, %A_ScriptDir%\오로물약set.txt ; 
	FileAppend, %gui_cooldown_all%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f1_str := save_setting(gui_f1)
	FileAppend, %f1_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f2_str := save_setting(gui_f2)
	FileAppend, %f2_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f3_str := save_setting(gui_f3)
	FileAppend, %f3_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f4_str := save_setting(gui_f4)
	FileAppend, %f4_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f5_str := save_setting(gui_f5)
	FileAppend, %f5_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f6_str := save_setting(gui_f6)
	FileAppend, %f6_str%`n, %A_ScriptDir%\오로물약set.txt ;
	
	f7_str := save_setting(gui_f7)
	FileAppend, %f7_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	
	f8_str := save_setting(gui_f8)
	FileAppend, %f8_str%`n, %A_ScriptDir%\오로물약set.txt ; 
	return

save_setting(fStr)
{
	if(fStr == "HP포션")
		return 1
	else if(fStr == "MP포션")
		return 2
	else if(fStr == "총알")
		return 3
	else if(fStr == "사용안함")
		return 4
	return 4
}



IdleTooltipStrSet()
{
	Global gui_hp_set, gui_mp_set, gui_ammo_set, idleTooltipStr, onHp, onMp, onAmmo, cooldown_hp, cooldown_mp, cooldown_ammo, cooldown_all, gui_cooldown, gui_cooldown_all
	
	
	idleTooltipStr := ""

	
	if(onHp)
	{
		current_hp_per := GetHpPer()
		idleTooltipStr := idleTooltipStr . "HP(" . current_hp_per . "%>" . gui_hp_set . "%)"
		hp_use_dealy := (cooldown_hp+gui_cooldown)-A_TickCount
		if(hp_use_dealy > 0)
		{
			hp_use_dealy := Round(hp_use_dealy/1000, 1)
			idleTooltipStr := idleTooltipStr . "(" . hp_use_dealy . "초)"
		}
	}
	if(onMp)
	{
		if(onHp)
			idleTooltipStr := idleTooltipStr . " "
			
		current_mp_per := GetMpPer()
		idleTooltipStr := idleTooltipStr . "MP(" . current_mp_per . "%>" . gui_mp_set . "%)"
		mp_use_dealy := (cooldown_mp+gui_cooldown)-A_TickCount
		if(mp_use_dealy > 0)
		{
			mp_use_dealy := Round(mp_use_dealy/1000, 1)
			idleTooltipStr := idleTooltipStr . "(" . mp_use_dealy . "초)"
		}
	}
	if(onAmmo)
	{
		if(onMp)
				idleTooltipStr := idleTooltipStr . " "
				
		current_ammo := GetAmmoNum()
		idleTooltipStr := idleTooltipStr . "총알(" . current_ammo . ">" . gui_ammo_set . ")"
		ammo_use_dealy := (cooldown_ammo+gui_cooldown)-A_TickCount
		if(ammo_use_dealy > 0)
		{
			ammo_use_dealy := Round(ammo_use_dealy/1000, 1)
			idleTooltipStr := idleTooltipStr . "(" . ammo_use_dealy . "초)"
		}
	}
	
	all_use_dealy := (cooldown_all+gui_cooldown_all)-A_TickCount
	all_use_dealy := Round(all_use_dealy/1000, 1)
	
	if(all_use_dealy > 0)
	{
		idleTooltipStr := idleTooltipStr . " 사용 대기: " . all_use_dealy . "초"
	}
	


	
	return
}

_isDarkedenCheck:
{
	IfWinNotExist, DarkEden
	{
		exitapp
	}
	return
}


_In_Game_Repeat:
	VisionChange(7)
	;MapBoxOn(true)
	return

