#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.14.2

 Script Function: manejo de estring
#ce ----------------------------------------------------------------------------

#include-once


Func enc($cadena,$codigo=34)
	;encapsula $cadena con el caratacter indicado en $codigo
	; por omision entre comillas dobles (FIX LOGIC)
	return chr($codigo)&$cadena&chr($codigo)
EndFunc

Func hex2dec($cadena)
	; convierte en nuemero hexadecimal a decimal
	; por error devuelve "" y setea @error
	; tiene en cuenta que $cadena puede no necesitar conversion
	const $hd="0X"	; cabecera hexadecimal
	local $validos	; interno
	;valida si no necesita conversion
	mensaje_("hex2dec("&$cadena&")"," Inicio")
	if StringIsInt($cadena)=1 then return number($cadena)
	; es hexdecimal
	$validos=StringUpper($cadena)
	mensaje_("hex2dec("&$validos&")"," $Validos")
	if StringLeft($validos,2)=$hd then $validos=Stringupper(StringMid($cadena,3))
	mensaje_("hex2dec("&$validos&")"," Sin 0x")
	if StringIsXDigit($validos) then  return dec($validos)
	mensaje_("hex2dec("&$validos&")"," Salida por error")
	SetError(1)
	return ""
EndFunc
