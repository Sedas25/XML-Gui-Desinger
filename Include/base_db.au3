#cs ----------------------------------------------------------------------------
funciones muy alto nivel para Logica DB

#ce ----------------------------------------------------------------------------

func carga_variables($consulta)
	;carga variables desde la DB (LOGICA FIJA)
	; las variables deben estar declaradas como Globales
	Local $a						;matriz de 2 dimensiones
	Local $ret=0					;devolucion de la funcion
	Local $n=dbprep4($consulta,$a)
	mensaje_("carga_variables()",$consulta," ",$n)
	if $n<1 then return -1
	$n=ubound($a,1)-1
	for $i=1 to $n
		Local $devo=Assign($a[$i][0],$a[$i][1],6)
		mensaje_("carga_variables()",$a[$i][0],($devo=1?" Exitosa":" Error"))
		$ret+=$devo
	next
	;if $debug=1 then _ArrayDisplay($a,"Variables")
	return $ret
EndFunc

func salva_variable($nombre,$valor)
	; save a variable from program to table variable in database
	; the variable  can not exist.
	; $_tmp1 and $tmp2 are global
	const $sva="save_variable"
	local $ret
	$_tmp1=$nombre
	$_tmp2=$valor
	$ret=dbprep($sva)
	return $ret
EndFunc