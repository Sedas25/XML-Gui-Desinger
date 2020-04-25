#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:

 Script Function: rutinas para la depuracion de programa

#ce ----------------------------------------------------------------------------

Func mensaje_($titulo, $txt1="", $txt2="", $txt3="", $txt4="", $txt5="", $txt6="", $txt7="", $txt8="", $txt9="", $txta="")
	; Logica FIJA
	; muestra un mensaje por el DBGview (Debug de programa)
	; no devuelve ningun valor por la funcion
	dim $mess
	const $cd=chr(34)
	$mess=$txt1&$txt2&$txt3&$txt4&$txt5&$txt6&$txt7&$txt8&$txt9&$txta
	$mess=$titulo&": "&$mess
	ConsoleWrite($mess&@CRLF)
    Dllcall("Kernel32.dll","none","OutputDebugString","STR",$mess)
Endfunc