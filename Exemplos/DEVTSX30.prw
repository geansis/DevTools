#Include "Protheus.ch"

USER FUNCTION DEVTSX30()

	SX3 := UPDSX3():CREATE()

//####		SC6			#######################################
/*____		C6_PRCUSD	_______________________________________*/

	SX3:CLONE("C6_PRCVEN", "C6_PRCUSD"	)
	SX3:S("TITULO"	,"Prc. Dolar"		)
	SX3:S("DESCRIC"	,"Preco Dolar"	)

//####		SA6			#######################################
/*____		A6_NOVO	_______________________________________*/

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6"				)
	SX3:S("CAMPO"		,"A6_NOVO"			)
	SX3:S("TIPO"		,"N"				)
	SX3:S("TAMANHO"	,6					)
	SX3:S("DECIMAL"	,0					)
	SX3:S("PICTURE"	,"999999"			)
	SX3:S("TITULO"	,"CAMPO TST"		)
	SX3:S("DESCRIC"	,"CAMPO TST"		)
	SX3:SETOPCIONAL()

/*____		A6_NOVO2	_______________________________________*/

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6"				)
	SX3:S("CAMPO"		,"A6_NOVO2"		)
	SX3:S("TIPO"		,"N"				)
	SX3:S("TAMANHO"	,6					)
	SX3:S("DECIMAL"	,0					)
	SX3:S("PICTURE"	,"999999"			)
	SX3:S("TITULO"	,"CAMPO TST"		)
	SX3:S("DESCRIC"	,"CAMPO TST"		)
	SX3:SETNAOUSADO()

	SX3:CONFIRM()

	RETURN NIL
