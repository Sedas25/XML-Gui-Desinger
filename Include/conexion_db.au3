#include-once
#Au3Stripper_Off
#include <sqlite.au3>
#Au3Stripper_On
global const $sentencias="sentencias"	; tabla con las sentencias preparadas

Func dbopen($database)
   ;carga las funciones del sqlite y abre una base de datos
   ;$database corresponde al nombre del archivo con la db
   ;devuelve el numero de conexion (positivo) ó numero de error (negativo)
  ;tambien crea las variables con metadata de la db

   Global $db_datos=""	;datos
   Global $db_filas=0	;cantidad de registros
   Global $db_columnas=0	;cantidad de campos por registro
   Global $db_error=0	;codigo de error
   Global $db_funcion=0	;ultima funcion llamada
   Global $db_handle=0	;manejador de la db
   Global $db_campos=0	;cantidad total de campos traidos

   local $hDB,$dll_load=0
   ;ConsoleWrite(" dbopen("&$database&")"&@CRLF)
   $dll_load=_SQLite_Startup() ;"",False,0,"")
   ;ConsoleWrite("$dllload="&$dll_load&" @error="&@error&@CRLF)
   If @error=0 then
	  $hDB = _SQLite_Open($database,$SQLITE_OPEN_READWRITE,$SQLITE_ENCODING_UTF8)
	  ConsoleWrite("$hDB="&$hDB&" @error="&@error&@CRLF)
   EndIf
   If @error=0 Then
		$db_handle=$hDB
		return $db_handle
	  Else
		$db_error=0-@error
		return $db_error
   EndIf
EndFunc

Func dbclose($hDB)
   ;cierra la conexion a la db $hDB
   ;closedatabase conection
   _SQLite_Close($hDB)
   $db_error=0
   $db_handle=0
EndFunc

Func query($hDB, $query, byref $result)
;get data from Db for Execute SQL sentence
;pararameters:
; $hDB: Database conection
; $query: SQL sentence
; $result: Devolution  data, base 0 index, row 0 contain fields names
; function  return: number of data's (positive) ó error code (negative)
;trae el resultado de ejecutar el codigo SQL de $query sobre la conexion $hDB
;La funcion devvuelve la cantidad de valores recuperados, los valores se devuelven en $resul
;ademas completa las variables  $db_funcion,$db_filas,$db_columna

; en modificacion para que acepte multiples sentencias SQL, teniendo en cuenta si la sentencia modifica en la DB ó No.
; solo los datos correspondientes a la ultima sentencia SQL se devuelven, si este es un SELECT.

   const $sss=";"	; separador de sentencias sql
   Local $iRows=0, $iColumns=0
   local $j=0		;cantidad uso general
   local $i=0		;contador de uso general
   local $sql		;sentencias sql individual

   ;ConsoleWrite("query() Entrada: $query="&$query&@CRLF)
   ;$query=repvar($query)
   if StringRight($query,1)=$sss Then ;el ultimo caracter es un ; lo retira
	  $j=StringLen($query)-1
	  $query=StringLeft($query,$j)
   EndIf
   ;$j=StringInStr($query,$sss,0) ; cantidad de partes
   $sql=StringSplit($query,$sss,0)
   $j=$sql[0]
   for $i=1 to $j
	  $result=""
      ;ConsoleWrite("query() $i="&$i&" $sql[$i]="&$sql[$i]&@CRLF)
	  _SQLite_GetTable2d($hDB,$sql[$i],$Result,$iRows,$iColumns)
	  $db_funcion=11
	  $db_filas=$iRows
	  $db_columnas=$iColumns
	  $db_datos=""
   Next
   if $result="" then
	  SetError(-2)
	  $db_error=-2
   EndIf
   ;ConsoleWrite("query() Salida: $db_filas="&$db_filas&" $db_columna="&$db_columna&@CRLF)
   return $iRows*$iColumns
EndFunc

Func dbbuscar($tabla,$criterio,$campos)
   ;devuelve un unico valor de la db
   local $consul,$return,$result
  ;local $cant=0
   $consul="select "&$campos&" from "&$tabla&" where "&$criterio
   ;ConsoleWrite("dbbuscar() $consul="&$consul&@CRLF)
   $db_campos=query($db_handle,$consul,$result)
   $db_error=@error
   if @error=0 and $db_campos=1 then return $result[1][0]
   if @error=0 and $db_campos<>1 then
	  $db_error=-1
	  return ""
   EndIf
EndFunc


#cs
Func dbquery($tabla,$criterio,$campos)
   ;devuelve varios valores de multiples campos y registro (traidos de la db)
   ;los valores son separados por |
   ConsoleWrite("dbquery() entrada: tabla="&$tabla&" criterio="&$criterio&" campos="&$campos&@CRLF)
   const $vacio=""
   const $sepa="|"
   local $consul,$return,$result,$out="",$i,$j
   local $cant=0
   $consul=armaquery($tabla,$criterio,$campos)
   ConsoleWrite("dbquery() $consul="&$consul&@CRLF)
   $cant=query(-1,$consul,$result)
   $db_error=@error
   ;ConsoleWrite("dbquery() $db_error="&$db_error&" $db_filas="&$db_filas&" $db_columnas="&$db_columnas&" vlores="&$cant&@CRLF)
   if @error>0 then return $vacio
   $db_error=-1
   if $cant=0 then return $vacio
   for $j=1 to $db_filas
	  for $i=0 to $db_columnas - 1
		 ;ConsoleWrite("dbquery() $result["&$j&"]["&$i&"]="&$result[$j][$i]&@CRLF)
		 $out=$out&$sepa&$result[$j][$i]
		 ;ConsoleWrite("dbquery() $out="&$out&@CRLF)
	  next
   Next
   $return=StringMid($out,2)
   ;ConsoleWrite("dbquery() salida: $return="&$return&@CRLF)
   return $return
EndFunc
#ce

#cs
Func dblista($tabla,$criterio,$campos)
   ;devuelve varios valores de un mismo registro ó de un mismo campo (traidos de la db)
   ;ConsoleWrite("dblista() entrada: $tabla="&$tabla&" $criterio="&$criterio&" $campos="&$campos&@CRLF)
   const $vacio=""
   const $sepa="|"
   local $consul,$return,$result,$out="",$i
   ;local $cant=0
   $consul=armaquery($tabla,$criterio,$campos)
   $db_campos=query($db_handle,$consul,$result)
   $db_error=@error
   ;ConsoleWrite("dblista() $db_error="&$db_error&" $db_filas="&$db_filas&" $db_columnas="&$db_columnas&@CRLF)

   if @error>0 then return $vacio
   $db_error=-1 ; consulta vacia
  ; if number($db_filas)=0 or number($db_columnas)=0 then return $vacio
   $db_error=-2 ; incongruencia entre lo solicitado y encontrado
   if number($db_filas)>1 and number($db_columnas)>1 then return $vacio
   if number($db_columnas)=1 then
	  for $i=1 to $db_filas
		 ;ConsoleWrite("dblista() $result["&$i&"][0]="&$result[$i][0]&@CRLF)
		 $out=$out&$sepa&$result[$i][0]
	  next
   EndIf
   if number($db_filas)=1 then
	  for $i=1 to $db_columnas - 1
		 ;ConsoleWrite("dblista() $result[1]["&$i&"]="&$result[1][$i]&@CRLF)
		 $out=$out&$sepa&$result[1][$i]
	  next
   EndIf
   $out=StringMid($out,2,99999)
   ;ConsoleWrite("dblista() salida: $out="&$out&@CRLF)
   return $out
EndFunc
#ce

func armaquery($tabla,$criterio,$campos)
   ; make SQLsentence from table, critery and  fields names
   ;arma la sentencia SQL a partir de los valores de $tabla,$criterio,$campos)
   return "select "&$campos&" from "&$tabla&" where "&$criterio
   ;return $ret
EndFunc

Func dblista2($sql,$campo_nro=0)
   ; if $campo_nro=0 execute $sql sentence and return data separate by $sepa
   ; if $campo_nro>0 execute $sql sentence and return a unique data
   ; wraper de funcion query, ejecuta una/s sentecia/s SQL y trae el resultado concatenado por $sepa
   ; similar a dbquery(), pero a apartir de un sentencia SQL y sin control de cantidad de campos
   ; trae todos los campos de cada registro excepto que se indique el nro en $campo_nro (base 1). (0 para todos los campos)
   ;ConsoleWrite("dblista2() entrada: SQL="&$sql&" $campo_nro="&$campo_nro&@CRLF)
   const $vacio=""	;valor vacio
   const $sepa="|"	;separador
   ;local $consul
   local $return	;retorno de la funcion
   local $result	;matriz de valores traidos de la db
   local $out=""	;armado intermedio del resultado
   local $i,$j		;uso general
   local $cant=0	;cantidad de campos traidos de la sb
   $cant=query(-1,$sql,$result)
   $db_error=@error
   ;ConsoleWrite("dblista2() $db_error="&$db_error&" $db_filas="&$db_filas&" $db_columnas="&$db_columnas&" valores="&$cant&@CRLF)
   if @error>0 then return $vacio
   $campo_nro=$campo_nro-1
   for $j=1 to $db_filas
	  for $i=0 to $db_columnas - 1
		 ;ConsoleWrite("dblista2() $result["&$j&"]["&$i&"]="&$result[$j][$i]&@CRLF)
		 if $i=$campo_nro or $campo_nro=-1 then $out=$out&$sepa&$result[$j][$i]
		 ;ConsoleWrite("dblista2() $out="&$out&@CRLF)
	  next
   Next
   $return=StringMid($out,2)
   ;ConsoleWrite("dblista2() salida: $return="&$return&@CRLF)
   return $return
endfunc

#cs
func orden_modo($actual,$nuevo)
   ; agrega al campo por el cual se ordena ASC ó DESC segun la siguiente logica
   ; si $actual es distinto a $nuevo simpre agrega ASC
   ; si ambos son iguales alterna DESC y ASC
   ; retorna el resultado por la funcion
   const $sp=" "
   const $up="ASC"
   const $down="DESC"
   ;ConsoleWrite("orden_modo() Entrada: $actual="&$actual&" $nuevo="&$nuevo&@CRLF)
   local $res	;resultado de funcion
   local $direc	;agregado
   local $act=StringSplit($actual&$sp,$sp,0)
   local $new=StringSplit($nuevo&$sp,$sp,0)
   ;ConsoleWrite("orden_modo() Stripeado: $act[1]="&$act[1]&" $new[1]="&$new[1]&" $act[2]="&$act[2]&@CRLF)
   if $act[1]=$new[1] and $act[2]=$up Then
	  $direc=$down
   Else
	  $direc=$up
   EndIf
   $res=$new[1]&$sp&$direc
   ;ConsoleWrite("orden_modo() salida: "&$res&@CRLF)
   return $res
endfunc
#ce

func repvar($sentencia)
   ;Logica fija
   ;remplaza en $sentencia las variables por su valor
   ;utiliza como separador los caracteres espacio , < , > y =
   ;el resultado se se devuelve por la salida estandard de la funcion
   ;Las variables a remplazar deben ser globales
   const $sp=" <=>(),;/+-&*';|"	;separadores
   const $esc="\"				; escape
   local $resul=""	;salida de la funcion
   local $j=StringLen($sentencia) ;largo de $sentencia
   local $i				; contador de uso generL
   local $e=0			; estado . 0 buscando inicio, 1 buscando final
   local $x=0			; Escape activo? 1=si, 0=no
   local $p1=0			; posicion del ultimo caracter $ encontrado
   ;local $p2=0			; posicion separador encontrado, 0 por no
   local $c=""			; caracter actual
   local $f=0			; encontro un $ ó un separador. 1=si, 0= no
   local $tmp			;provisorio

   ;ConsoleWrite("repvar() inicio: $sentencia="&$sentencia&@CRLF)
	for $i=1 to $j
		$c=StringMid($sentencia,$i,1)
		$f=0
		if $c=$esc then
			$x=1
			;ConsoleWrite("repvar() encuentra excepcion $i="&$i&@CRLF)
			ContinueLoop
		EndIf
		if $e=0 and $c="$" and $x=0 then ; encontro comienzo de la variable
			$p1=$i
			$f=1
			$e=1
			$x=0
			;ConsoleWrite("repvar() encuentra inicio $i="&$i&@CRLF)
			ContinueLoop
		EndIf
		if $e=1 and (StringInStr($sp,$c)>0) and $x=0  then ;encontro el final de una variable ó la sentencia
			$tmp=stringmid($sentencia,$p1,$i-$p1)
			if StringInStr($tmp,"[]")=0 Then
					$resul=$resul&Execute($tmp)&$c
			EndIf
			$f=1
			$e=0
			$x=0
			;ConsoleWrite("repvar() encuentra final $i="&$i&" $tmp="&$tmp&" eval($tmp)="&eval($tmp)&" es una matriz? "&VarGetType(eval($tmp))&" @error="&@error&@CRLF)
			ContinueLoop
		EndIf
		$x=0
		if $f=0 and $e=0 and $x=0 Then	;debe replicar el caracter en la salida
			$resul=$resul&$c
		EndIf
	next
	if $e=1 then	;llego al fin de cadena y falta procesar variable
	   $tmp=stringmid($sentencia,$p1,$i-$p1)
	   $resul=$resul&Execute($tmp)
	endif
   ;ConsoleWrite("repvar() salida: $resul="&$resul&@CRLF)
   ;ConsoleWrite("repvar() salida: Seperador XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"&@CRLF)
   return $resul
EndFunc

#cs
func mat2cadena (byref $valores,byref $salida,$palabra)
   ;Logica Fija
   ;convierte el contenido de una matriz a una cadena en hexdecimal
   ;$valores: matriz con la informacion
   ;$salida: cadena de salida
   ;palabra: Largo ocupado por cada valor
   local $i,$j,$d
   $d=ubound($valores,0)
   ;ConsoleWrite("mat2cadena(): dimensiones de "&$valores&"="&$d&@CRLF)
   if $d=0 then
	  $salida=$valores
	  return 0
   EndIf
   if $d=2 Then
	  local $cadena="X'"
 	  for $i=0 to ubound($valores,1)-1
		 for $j=0 to ubound($valores,2)-1
			;consolewrite("$i $j $valor "&$i&" "&$j&" "&@CRLF)
			$cadena=$cadena&hex($valores[$i][$j],$palabra)
		 Next
	  Next
	  $salida=$cadena&"'"
	  return $j*$i
   EndIf
EndFunc

func array_search(byref $matriz,$valo,$fila_ini,$colu,$devo=0)
   ;busca un valor en $matriz
   ; la busqueda es columna indicada en $colu (base 0)
   ; y devuelve siempre el valor en la columna indicada en $devo, correspondiente a la misma fila
   ; si no lo encuentra setea @error y devuelve un valor vacio
   ;ConsoleWrite("array_search() entrada: $matriz[1][1]="&$matriz[1][1]&" $valo="&$valo&" $fila_ini="&$fila_ini&" $colu&="&$colu&@CRLF)
   local $i=0					;indice de uso general
   local $j=ubound($matriz,1)-1	;cantidad de filas
   ;ConsoleWrite("array_search() cantidad de filas="&$j&@CRLF)
   local $ret=""
   for $i=$fila_ini to $j
	  ;ConsoleWrite("array_search() $matriz["&$i&"][0]"&$matriz[$i][0]&@CRLF)
	  if $valo=$matriz[$i][$colu] Then
		 $ret=$matriz[$i][$devo]
		 ExitLoop
	  EndIf
	  if $ret="" then SetError(-1)
   Next
   ;ConsoleWrite("array_search() salida: $ret="&$ret&@CRLF)
   Return $ret
EndFunc
#ce

func dbprep($clave)
; Logica de Negocio
;ejecuta en la db una sentencia SQL preparada almacenada en la tabla sentencias
; la busqueda en la tabla la realiza en la DB por el campo nombre
; devuelve 0 ó 1 por exito; un numero negativo por falla con el nro de error
   ;ConsoleWrite("dbprep() entrada: clave="&$clave&@CRLF)
   local $ret	;devolucion de funcion
   local $sql=dbbuscar($sentencias,"nombre='"&$clave&"' and habilitado=1","sentencias")
   ;ConsoleWrite("dbprep() SQL="&$sql&@CRLF)
   if @error>0 then return (0-@error)
   $sql=repvar($sql)
   ;ConsoleWrite("dbprep() SQL="&$sql&@CRLF)
   $ret=number(dblista2($sql))
   ;ConsoleWrite("dbprep() salida $ret="&$ret&@CRLF)
   return $ret
EndFunc

func dbprep2($clave)
   ;Logica de negocios
   ; ejecuta una sentencia preparada guardada en la tabla 'sentencias'
   ; la busqueda en la tabla la realiza en la DB por el campo nombre
   ; devuelve el valor recibido de la db ó "" por error
   ; es un unico valor
  ;ConsoleWrite("dbprep2() entrada: clave="&$clave&@CRLF)
   local $ret	;devolucion de funcion
   local $sql=dbbuscar($sentencias,"nombre='"&$clave&"' and habilitado=1","sentencias")
   local $cant ; cantidad de traidos de la db
   ;ConsoleWrite("dbprep2() SQL original="&$sql&@CRLF)
   if @error>0 then return ""
   $sql=repvar($sql)
   ;ConsoleWrite("dbprep2() SQL ejecutado="&$sql&@CRLF)
   $cant=query(-1,$sql,$ret)
   ;ConsoleWrite("dbprep2() $db_error="&$db_error&" $db_columnas="&$db_columnas&" $db_filas="&$db_filas&" cant="&$cant&@CRLF)
;   ConsoleWrite("dbprep2() salida $ret="&$ret[1][0]&@CRLF)
   if $cant=1 then $ret=$ret[1][0]
   return $ret
EndFunc

func dbprep3($clave,$sepa)
   ;Logica Fija
   ; ejecuta una sentencia preparada guardada en la tabla 'sentencias'
   ; la busqueda en la tabla la realiza en la DB por el campo nombre
   ; devuelve los valores recibido de la db ó "" por error
   ; es un unico valor con los valores concatenados usando el separador
  ;ConsoleWrite("dbprep3() entrada: clave="&$clave&@CRLF)
   local $ret	;devolucion de funcion
   local $resul	; matriz de los resultados
   local $sql=dbbuscar($sentencias,"nombre='"&$clave&"' and habilitado=1","sentencias")
   local $cant ; cantidad de traidos de la db
   local $i	; contador uso general
   ;ConsoleWrite("dbprep3() SQL="&$sql&@CRLF)
   if @error>0 then return ""
   $sql=repvar($sql)
   ;ConsoleWrite("dbprep3() SQL="&$sql&@CRLF)
   $cant=query(-1,$sql,$resul)
   ;ConsoleWrite("dbprep3() $db_error="&$db_error&" $db_columnas="&$db_columnas&" $db_filas="&$db_filas&@CRLF)
   ;ConsoleWrite("dbprep3() salida $resul[1][0]="&$resul[1][0]&@CRLF)
   if $db_error<>0 then return $ret
   for $i=1 to $db_filas
		;ConsoleWrite("dbprep3() $resul[1]["&$i&"]="&$resul[$i][0]&@CRLF)
		$ret=$ret&$sepa&$resul[$i][0]
	  next
   $ret=StringMid($ret,2,99999)
   ;ConsoleWrite("dbrep3() salida: $ret="&$ret&@CRLF)
   return $ret
EndFunc

#cs
func mat2rsc(byref $matriz,$rsc_id,$tipo,$metadata)
   ;pasa el contenido de una ,matriz a una tabla de recursos en db, donde los guarda como registros
   ;para interactuar con db usa querys almacenados en la tabla 'sentencias'
   ;los valores de 'tipo' son predeterminados.
   ;los querys a utilizar son predeterminados dependen del valor de 'Tipo', mas uno para recursos nuevos
   ;devuelve por la funcion el rsc_id  (recurso id) si tuvo exito ó el codigo de error (negativos)

   ;$matriz: Con la onformacion
   ;$rsc_id: id del recurso
   ;$tipo: tipo de recurso. Valores posibles: 'grafico'
   ;$metadata: Informacion extra del recurso cadena con nombre,descripcion,ancho,alto y duracion separados por |
   ;            Estos valores van a la db , si algun valor no correspondiera debe estar completo con NULL

   ;codigos de error
   ;-1 no pudo agregar registro nuevo

   ; constantes generales
   const $sql_insert="rsc_insert"
   const $sql_grafico=""

   Global $_id=$rsc_id ;id del recurso
   local $tmp=StringSplit($metadata,"|",0)
   local $contenido=""; contenido a guardar en la db
   local $datos=StringReplace($metadata,"|","','",0)	; metadata del recurso.
   local $dime=UBound($matriz,0)						; cantidad de dimensiones
   local $1era=ubound($matriz,1)  						; 1era dimension de la matriz recibida
   local $2da=1										; 2da dimension de la matriz recibida
   local $i,$j											; indices
   local $ancho=number($tmp[3])
   local $alto=number($tmp[4])
   if $dime>1 then $2da=ubound($matriz,2)


   if $rsc_id=0 then
	  $_id=number(dbprep($sql_insert))
	  if $_id=0 then return -1
   EndIf
EndFunc

func string2cadena (byref $valores,byref $salida,$palabra=2)
   ;Logica Fija
   ;convierte el contenido de una string con salto de lineas y caracteres extraños
   ; una cadena en hexdecimal
   ;$valores: informacion a convertir
   ;$salida: cadena de salida
   ;palabra: Largo ocupado por cada valor, por omision 1
   ;devuelve por la funcion el largo de la salida
   local $i,$j,$d,$n
   ;ConsoleWrite("String2cadena(): entrada &largo($valores)="&stringlen($valores)&" $palabra="&$palabra&@CRLF)
   local $cadena="X'"
   $n=StringLen($valores)
   for $i=1 to $n-1
	  $j=Asc(StringMid($valores,$i,1))
	  ;consolewrite("string2cadena() $i $j "&$i&" "&$j&@CRLF)
	  $cadena=$cadena&hex($j,$palabra)
   Next
   $salida=$cadena&"'"
   ;ConsoleWrite("String2cadena(): salida "&$salida&"="&$salida&@CRLF&@CRLF)
   return stringlen($salida)
EndFunc
#ce

func dbprep4($clave, byref $resul)
   ;Logica de negocios
   ; ejecuta una sentencia preparada guardada en la tabla 'sentencias'
   ; la busqueda en la tabla la realiza en la DB por el campo nombre
   ; vuelca los valores recibidos en una matriz de valores
   ;devuelve la cantidad de campos recuperados de la db ó -1 por error
   ;
   ;ConsoleWrite("dbprep4() entrada: clave="&$clave&@CRLF)
   local $ret	;devolucion de funcion
   local $sql=dbbuscar($sentencias,"nombre='"&$clave&"' and habilitado=1","sentencias")
   local $cant ; cantidad de traidos de la db
   ;ConsoleWrite("dbprep4() SQL="&$sql&@CRLF)
   if @error>0 then return -1
   $sql=repvar($sql)
   ;ConsoleWrite("dbprep4() SQL="&$sql&@CRLF)
   $cant=query(-1,$sql,$resul)
   ;ConsoleWrite("dbprep4() $db_error="&$db_error&" $db_columnas="&$db_columnas&" $db_filas="&$db_filas&" cant="&$cant&@CRLF)
   ;ConsoleWrite("dbprep4() salida $ret="&$cant&@CRLF)
   return $cant
EndFunc

#cs
func cadena2string (byref $valores,byref $salida,$palabra=2)
   ;Logica Fija
   ;convierte una cadena en hexdecimal en un string con salto de lineas y caracteres extraños
   ;$valores: informacion a convertir
   ;$salida: cadena de salida
   ;palabra: Largo ocupado por cada valor, por omision 2
   ;devuelve por la funcion el largo de la salida
   const $cl=2	;largo cabecera
   local $i,$j,$d,$n
   $n=StringLen($valores)
   ;ConsoleWrite("cadena2string(): entrada &largo($valores)="&stringlen($valores)&" $palabra="&$palabra&@CRLF)
   ;ConsoleWrite("cadena2string(): entrada $valores="&@CRLF&$valores&@CRLF)
   local $cadena=""

   ;if ($n/$palabra)<>Int($n/$palabra) then $valores=$valores&chr(32) ;agrega pad
   for $i=1 to $n-2 Step $palabra
	  $j=dec(StringMid($valores,$i+$cl,$palabra))
	  ;consolewrite("cadena2string() $i $j "&$i&" "&$j&@CRLF)
	  $cadena=$cadena&chr($j)
   Next
    $salida=$cadena
   ;ConsoleWrite("cadena2string(): salida "&$salida&"="&$salida&@CRLF)
   return stringlen($salida)
EndFunc
#ce


