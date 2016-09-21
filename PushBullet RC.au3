#include <GUIConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Include <Constants.au3>
#Include <String.au3>			;Per gestire le stringe (comando)
#include <Array.au3>			;Per gestire gli array (iden)
#include <ScreenCapture.au3>	;Per screenare lo schermo
#RequireAdmin
#NoTrayIcon 					;Verificarne effettiva funzionalità

#region GUI Tray Menu
Opt("TrayMenuMode", 3) 			;Imposta il tipo di menu da creare (3=no default item, no auto check options)
TraySetIcon(@ScriptDir & "\Resources\tray_icon.ico") 	;Imposta l'icona
TraySetClick(8) 				;Imposta come deve essere aperto il menu

;ELEMENTI MENU
$start=TrayCreateItem("Start")					;Pulsante START
TrayCreateItem("")								;Separatore -
$istruzioni = TrayCreateItem ("Istruzioni") 	;Pulsante ISTRUZIONI
$listacomandi = TrayCreateItem("Lista Comandi") ;Pulsante LISTA COMANDI
$impostatoken = TrayCreateItem ("Imposta Token");Pulsante IMPOSTA TOKEN
TrayCreateItem("") 								;Separatore -
;$languages = TrayCreateItem("Lingua")			;Pulsante LINGUA
$about = TrayCreateItem ("About") 				;Pulsante ABOUT
$esci = TrayCreateItem ("Esci")					;Pulsante ESCI
TraySetState() 									;Imposta lo stato dell'icona (vedi documentazione)
#EndRegion

#Region GUI Impostazioni Token
$tokengui = GUICreate("Imposta Token PushBullet", 301, 135, 192, 124)					;Main Window
GUISetIcon(@ScriptDir & "\Resources\tray_icon.ico", -1)											;Icona
$label1 = GUICtrlCreateLabel("Inserisci qui il Token del tuo account:", 16, 8, 275, 23) ;Label
GUICtrlSetFont(-1, 13, 400, 0, "Arial")
$boxtoken = GUICtrlCreateInput("", 16, 37, 270, 24)										;Textbox Token
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
$btnToken = GUICtrlCreateButton("Imposta Token", 16, 70, 270, 33)						;Button Imposta Token
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
$label3 = GUICtrlCreateLabel("To find your access token go here:", 80, 108, 275, 23)	;Label
GUICtrlSetFont(-1, 7, 400, 0, "Arial")
$label4 = GUICtrlCreateLabel("https://www.pushbullet.com/#settings", 76, 120, 275, 23)	;Label
GUICtrlSetFont(-1, 7, 400, 0, "Arial")
GUISetState(@SW_HIDE)																	;Imposta lo stato della finestra come 'nascosta'
#EndRegion GUI

#Region Variabili e impostazioni
$sessiontoken="" 			;Variabile che contiene il token della sessione
$onoroff="0"	 			;Determina l'avvio e l'arresto del controll remoto
HotKeySet("+!q", "_StopRC")	;Imposta HotKey: SHIFT+ALT+Q per arrestare il servizio (+ = SHIFT / ! = ALT)
#EndRegion

If not IsAdmin() then
   MsgBox(16,"Attenzione!", "Il programma non può funzionare se non viene eseguito con i diritti di amministratore!")
   Exit
EndIf

_LeggiToken() ;All'avvio lo script carica il token precedentemente salvato dal file 'token.ini' e lo imposta nella variabile $sessiontoken

While 1 ;CICLO PRINCIPALE
   $msg = GUIGetMsg()													;Gli eventi generati dall'interazioni con la GUI vanno a finire nella variabile $msg
   Switch $msg															;Passa a $msg
	  case $GUI_EVENT_CLOSE												;Evento chiusura finestra
		 GUISetState(@SW_HIDE,$tokengui) 								;Non termina il programma bensì imposta lo stato della finestra come 'nascosta'
	  Case $btnToken
		 $sessiontoken = GUICtrlRead($boxtoken) 						;Legge il token inserito nella textbox
		 IniWrite (@ScriptDir & "\Resources\token.ini", "AccessToken", "token", $sessiontoken)	;Scrive il token nel file 'token.ini'
		 Sleep(500)
		 MsgBox(64,"Fatto!","Il token è stato salvato con successo")
		 _LeggiToken()
   EndSwitch

   $msg = TrayGetMsg() 													;Gli eventi generati dall'interazioni con il TrayMenu vanno a finire nella variabile $msg
   Switch $msg															;Passa a $msg
   case $esci
	  Exit 																;il programma si chiude
   case $about
	  MsgBox(64,"PushBullet RemoteControl v1.0", "Questo Software è stato sviluppato da LinkOut") ;vengono visualizzati i credits
   case $impostatoken
	  GUISetState(@SW_SHOW,$tokengui) 									;Imposta lo stato della gui come 'visibile'
	  if $sessiontoken <> "" Then										;Se il token è già stato caricato in memoria
		 MsgBox(64,"Token Sessione Corrente","Token Sessione corrente:" & @CRLF & $sessiontoken);viene visualizzato
	  EndIf
   case $listacomandi
	  MsgBox(48,"Lista comandi","Ricorda, i comandi possono essere scritti in:"  & @CRLF & "• Minuscolo (spegni);"  & @CRLF & "• Maiuscolo (SPEGNI);"  & @CRLF & "• Con la prima lettera maiuscola (Spegni)."  & @CRLF & @CRLF & "Verranno sempre riconosciuti.")
	  MsgBox(0,"Lista comandi","Comandi = Invia la lista dei comandi disponibili;"  & @CRLF & "Spegni = Spegne il computer" & @crlf & "Riavvia = Riavvia il computer"  & @CRLF & "Iberna = Iberna il computer;"  & @CRLF & "Screen = Invia uno screenshot dello schermo;" & @CRLF & "Webcam = Invia uno snapshot effettuato dalla webcam;") ;visualizza la lista comandi
   case $istruzioni
	  MsgBox(64,"Istruzioni", "Il funzionamento di PushBullet Remote Control è molto semplice:" & @CRLF & "dopo aver avviato il programma, avvia il servizio di controllo remoto premendo su 'Start'. Fatto, il servizio è in ascolto!" & @CRLF & @CRLF &  "Ora, tramite PushBullet, manda a te stesso un push con scritto 'Comandi' (senza apici) e guarda cosa succede!" & @CRLF & "Per arrestare il servizio usa la combinazione di tasti SHIFT+ALT+Q."  & @CRLF & @CRLF & "Grazie per supportare questo progetto! :)") ;visualizza le istruzioni
   case $start
	  if $sessiontoken <> "" Then
	  TrayItemSetState($start, 129)			;Disabilita e checka il comando
	  TrayItemSetState($istruzioni, 128)	;Disabilita il comando
	  TrayItemSetState($listacomandi, 128)	;Disabilita il comando
	  TrayItemSetState($impostatoken, 128)	;Disabilita il comando
	  TrayItemSetState($about, 128)			;Disabilita il comando
	  TrayItemSetState($esci, 128) 			;Disabilita il comando
	  $onoroff="1"							;Imposta il valore della variabile a $onoroff a '1'
	  MsgBox(64,"RC Avviato","Il controllo remoto è stato avviato. Per arrestarlo premere la combinazioni di tasti (SHIFT + ALT + Q) in qualsiasi momento."&@CRLF&@CRLF&"N.B. E' impossibile interagire col programma se il servizio è attivo.") ;Messaggio di avvio RC
	  _RemoteControl() ;Avvio Controllo remoto
   Else
	  MsgBox(16,"Token mancante","E' necessario impostare un token di accesso prima di poter utilizzare il controllo remoto")
   EndIf

   EndSwitch
   Sleep(10)
WEnd

Func _LeggiToken() 		 ;CARICA ALL'AVVIO IL TOKEN SALVATO NEL FILE .INI
   ;If IniRead("token.ini", "AccessToken", "token", "") = "" Then
	;  MsgBox(16,"Token non impostato","Impostare il token di accesso nell'apposita finestra")
   ;EndIf
   If $sessiontoken="" Then 															;Se la variabile è vuota
	  $sessiontoken = IniRead(@ScriptDir & "\Resources\token.ini", "AccessToken", "token", "") ;carica il token dal file
   EndIf
EndFunc

Func _RemoteControl() 	 ;LEGGE CONTINUAMENTE NUOVI PUSH ED ESEGUE EVENTUALI COMANDI0
   While $onoroff="1" 																		;Finchè la variabile avrà come valore '1' il ciclo continuerà
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1") 										;Crea un oggetto 'richiesta http'
	$oHTTP.Open("Get", "https://api.pushbullet.com/v2/pushes?active=true&limit=3", False) 	;Apre una richieta GET al link
	$oHTTP.SetCredentials($sessiontoken, "", 0) 											;Imposta le credenziali (token)
	$oHTTP.SetRequestHeader("Content-Type", "application/json") 							;Setta l'header della richiesta
	$oHTTP.Send() 																			;invia la richiesta
	$Result = $oHTTP.ResponseText 															;Il testo di risposta viene inserito nella variabile $Result

	;MsgBox(0,"",$Result) DECOMMENTARE PER VISUALIZZARE IL RISULTATO DELLA RISPOSTA DAL SERVER (DEBUGGING)

    ;========= COMANDO #1 LISTA COMANDI========= WIP
	  If StringInStr(StringLower($Result), '"body":"comandi') or StringInStr(StringLower($Result), '"body":"Comandi') or StringInStr(StringLower($Result), '"body":"COMANDI') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   ;Local $lista = "Comandi = Invia la lista dei comandi disponibili;"  & @CRLF & "Spegni = Spegne il computer" & @crlf & "Riavvia = Riavvia il computer"  & @CRLF & "Iberna = Iberna il computer;"  & @CRLF & "Screen = Invia uno screenshot dello schermo;" & @CRLF & "Webcam = Invia uno snapshot effettuato dalla webcam;"
			   _PushFile(@ScriptDir & "\Resources\listacomandi.png","image/png","PBRC - Lista Comandi")	;Invia il push
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			EndIf
	  EndIf

	;========= COMANDO #2 SPEGNI ========= OK
	  If StringInStr(StringLower($Result), '"body":"spegni') or StringInStr(StringLower($Result), '"body":"Spegni') or StringInStr(StringLower($Result), '"body":"SPEGNI') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   $sPD = '{"type": "note", "title": "PBRC - Spegnimento in corso.", "body": ""}'
			   _Push($sPD)				;Invia il push
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			   Shutdown(5)				;Spegne il PC (Shutdown + Force, 1+4)
			EndIf
	  EndIf

    ;========= COMANDO #3 RIAVVIA ========= OK
	  If StringInStr(StringLower($Result), '"body":"riavvia') or StringInStr(StringLower($Result), '"body":"Riavvia') or StringInStr(StringLower($Result), '"body":"RIAVVIA') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   $sPD = '{"type": "note", "title": "PBRC - Riavvio in corso.", "body": "Non sarà più possibile usare il controllo remoto finchè il servizio non verrà avviato manualmente"}'
			   _Push($sPD)				;Invia il push
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			   Shutdown(6) 				;Riavvia il pc (Reboot + Force, 2+4)
			EndIf
	  EndIf

    ;========= COMANDO #4 IBERNA ========= OK
	  If StringInStr(StringLower($Result), '"body":"iberna') or StringInStr(StringLower($Result), '"body":"Iberna') or StringInStr(StringLower($Result), '"body":"IBERNA') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   $sPD = '{"type": "note", "title": "PBRC - Ibernazione in corso.", "body": ""}'
			   _Push($sPD)				;Invia il push
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			   Shutdown(68)				;Iberna il pc (Hibernate + Force, 64+4)
			EndIf
	  EndIf

    ;========= COMANDO #5 SCREEN ========= OK
	  If StringInStr(StringLower($Result), '"body":"screen') or StringInStr(StringLower($Result), '"body":"Screen') or StringInStr(StringLower($Result), '"body":"SCREEN') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   Local $ScreenFile = "screenshot.bmp" 				;Imposta il percorso,nome ed estensione dello screen
			   _ScreenCapture_SetBMPFormat(4)						;Imposta qualità file (massima)
			   _ScreenCapture_Capture($ScreenFile)					;Cattura la schermata
			   _PushFile($ScreenFile,"image/bmp","PBRC - Screen")	;Invia lo screen
			   FileDelete($ScreenFile) 								;Elimina lo screen
			   _EliminaPush($iden[$x])								;Elimina il push per evitare loop infiniti
			EndIf
	  EndIf

    ;========= COMANDO #6 WEBCAM ========= OK
	  If StringInStr(StringLower($Result), '"body":"webcam') or StringInStr(StringLower($Result), '"body":"Webcam') or StringInStr(StringLower($Result), '"body":"WEBCAM')Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			   RunWait(@ScriptDir & "\Resources\Snapshot.exe")
			   _PushFile(@ScriptDir & "\Resources\snapshot.bmp","image/bmp","PBRC - Webcam Snap")
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			   Sleep(1000)
			   FileDelete(@ScriptDir & "\Resources\snapshot.bmp")
			EndIf
	  EndIf

    ;========= COMANDO #7 BLANK=========
	  If StringInStr(StringLower($Result), '"body":" - ') Then
		 Local $comando = _StringBetween($Result, '"body":"', '"', "", False)
		 Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		 $x = 0
			if $iden <> "" and $comando <> "" Then
			   $comando[$x] = StringUpper(StringStripWS($comando[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
			   $iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			   ;_ArrayDisplay($iden) DECOMMENTARE PER VISUALIIZARE GLI IDEN NELL'ARRAY (DEBUGGING)
			   ;SETTARE QUI LA RISPOSTA E POI IL COMANDO
			   $sPD = '{"type": "note", "title": "", "body": " - "}'
			   $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
			   $oHTTP.Open("POST", "https://api.pushbullet.com/v2/pushes", False)
			   $oHTTP.setRequestHeader("Authorization", "Bearer " & $sessiontoken)
			   $oHTTP.SetRequestHeader("Content-Type", "application/json")
			   $oHTTP.Send($sPD)
			   _EliminaPush($iden[$x])	;Elimina il push per evitare loop infiniti
			EndIf
	  EndIf
	  Sleep(5000)
   WEnd
EndFunc

Func _PushFile($File, $FileType, $title) ;INVIA FILE
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$oHTTP.Open("Post", "https://api.pushbullet.com/v2/upload-request", False)
	$oHTTP.SetCredentials($sessiontoken, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	Local $pPush = '{"file_name": "' & $File & '", "file_type": "' & $FileType & '"}'
	$oHTTP.Send($pPush)
	$risposta = $oHTTP.ResponseText
	Local $upload_url 	  = _StringBetween($risposta, 'upload_url":"', '"')
	Local $awsaccesskeyid = _StringBetween($risposta, 'awsaccesskeyid":"', '"')
	Local $acl 			  = _StringBetween($risposta, 'acl":"', '"')
	Local $key 			  = _StringBetween($risposta, 'key":"', '"')
	Local $signature 	  = _StringBetween($risposta, 'signature":"', '"')
	Local $policy 		  = _StringBetween($risposta, 'policy":"', '"')
	Local $file_url 	  = _StringBetween($risposta, 'file_url":"', '"')
	local $content_type   = _StringBetween($risposta, 'content-type":"', '"')
	If IsArray($upload_url) And IsArray($awsaccesskeyid) And IsArray($acl) And IsArray($key) And IsArray($signature) And IsArray($policy) Then
		 $risposta = RunWait(@ScriptDir & "\Resources\curl.exe -i -X POST " & $upload_url[0] & ' -F awsaccesskeyid="' & $awsaccesskeyid[0] & '" -F acl="' & $acl[0] & '" -F key="' & $key[0] & '" -F signature="' & $signature[0] & '" -F policy="' & $policy[0] & '" -F content-type="' & $content_type & '" -F file=@"' & $File & '"', "", @SW_HIDE)
		 $oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
		 $oHTTP.SetCredentials($sessiontoken, "", 0)
		 $oHTTP.SetRequestHeader("Content-Type", "application/json")
		 ;Local $pPush = '{"type": "file", "file_name": "' & $FileName & '", "file_type": "' & $FileType & '", "file_url": "' & $file_url[0] & '", "title": "' & $title & '", "body": "' & $body & '"}'
		 Local $pPush = '{"type": "file", "file_name": "' & $File & '", "file_type": "' & $FileType & '", "file_url": "' & $file_url[0] & '", "title": "' & $title & '"}'
		 $oHTTP.Send($pPush)
		 $risposta2 = $oHTTP.ResponseText
	EndIf
EndFunc

Func _Push($sPD)		 ;INVIA PUSH TESTUALE
	  $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	  $oHTTP.Open("POST", "https://api.pushbullet.com/v2/pushes", False)
	  $oHTTP.setRequestHeader("Authorization", "Bearer " & $sessiontoken)
	  $oHTTP.SetRequestHeader("Content-Type", "application/json")
	  $oHTTP.Send($sPD)
EndFunc

Func _EliminaPush($iden) ;ELIMINA I PUSH DOPO L'ESECUZIONE DEL COMANDO
   	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$oHTTP.Open("Delete", "https://api.pushbullet.com/v2/pushes/" & $iden, False) ;$iden = codice univico identificativo per ogni push
	$oHTTP.SetCredentials($sessiontoken, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()
 EndFunc

Func _StopRC() 			 ;STOPPA IL SERVIZIO
   if $onoroff="1" Then						;Impedisce l'esecuzione della funzione quando il servizio è gia arrestato
	  $onoroff="0"							;Arresta il servizio
	  TrayItemSetState($start, 68)			;Abilita e unchecka il comando
	  TrayItemSetState($istruzioni, 64)		;Abilita il comando
	  TrayItemSetState($listacomandi, 64)	;Abilita il comando
	  TrayItemSetState($impostatoken, 64)	;Abilita il comando
	  TrayItemSetState($about, 64)			;Abilita il comando
	  TrayItemSetState($esci, 64)			;Abilita il comando
	  MsgBox(64,"RC Arrestato","Il controllo remoto è stato arrestato")
	  EndIf
EndFunc