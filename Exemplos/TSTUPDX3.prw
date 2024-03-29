#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION TSTUPDX3()

	SX3 := UPDSX3():CREATE()
	SX3:SETDICBANCO(.T.) //Seta que utilizará as configurações de dicionário no banco de dados

	SX3:CLONE("C6_PRCVEN", "C6_PRCUSD")
	SX3:S("TITULO"	,"Prc. Dolar"	)
	SX3:S("DESCRIC"	,"Preco Dolar"	)

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6")
	SX3:S("CAMPO"	,"A6_NOVO"	)
	SX3:S("TIPO"	,"N"		)
	SX3:S("TAMANHO"	,6		)
	SX3:S("DECIMAL"	,0		)
	SX3:S("PICTURE"	,"999999"		)
	SX3:S("TITULO"	,"CAMPO TST"	)
	SX3:S("DESCRIC"	,"CAMPO TST"	)
	SX3:SETOPCIONAL()

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6")
	SX3:S("CAMPO"	,"A6_NOVO2"	)
	SX3:S("TIPO"	,"N"		)
	SX3:S("TAMANHO"	,6		)
	SX3:S("DECIMAL"	,0		)
	SX3:S("PICTURE"	,"999999"		)
	SX3:S("TITULO"	,"CAMPO TST"	)
	SX3:S("DESCRIC"	,"CAMPO TST"	)
	SX3:SETNAOUSADO()
	
	//Modifica ordem do campo
	SX3:SETORDEM( "SA6", "A6_NOVO", "10"  )

	SX3:CONFIRM()

RETURN NIL
