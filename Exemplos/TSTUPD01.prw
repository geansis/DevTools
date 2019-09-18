#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} TSTUPD01

Atualiza dicionario

@author  Fernando Alencar
@version P11 e P10
@since   13/11/2011
@obs

/*/
User Function TSTUPD01()

	Default oProcess  := Nil
	Default cEmpresa  := "XX"

	oProcess:SetRegua2( 10 )

	oProcess:IncRegua2( 'Atualizando SX1')
	ExecSX1()

	oProcess:IncRegua2( 'Atualizando SX3')
	ExecSX3()

//bug - para funcionar corretamente, é
//necessário executar o sx3 antes do sx2
	oProcess:IncRegua2( 'Atualizando SX2')
	ExecSX2(cEmpresa)

	oProcess:IncRegua2( 'Atualizando SX4')
	ExecSX4()

	oProcess:IncRegua2( 'Atualizando SX5')
	ExecSX5()

	oProcess:IncRegua2( 'Atualizando SX6')
	ExecSX6()

	oProcess:IncRegua2( 'Atualizando SX7')
	ExecSX7()

	oProcess:IncRegua2( 'Atualizando SIX')
	ExecSIX()

	oProcess:IncRegua2( 'Atualizando SXA')
	ExecSXA()

	oProcess:IncRegua2( 'Atualizando SXB')
	ExecSXB()

	Return

/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX1()
	Sleep(100)
	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX2(cEmpresa)

	SX2 := UPDSX2():CREATE(CEMPRESA)

	SX2:ADD('ZZZ', "CADASTRO DE TESTE 1" , "ZZZ_FILIAL+ZZZ_CODIGO+ZZZ_LOJA")
	SX2:S('PATH', "/DATA/")

	SX2:CONFIRM()

	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX3()
	SX3 := UPDSX3():CREATE()

	SX3:CLONE("C6_PRCVEN", "C6_PRCUSD")
	SX3:S("TITULO"	,"Prc. Dolar"	)
	SX3:S("DESCRIC"	,"Preco Dolar")

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6"			)
	SX3:S("CAMPO"		,"A6_NOVO"		)
	SX3:S("TIPO"		,"N"			)
	SX3:S("TAMANHO"	,6				)
	SX3:S("DECIMAL"	,0				)
	SX3:S("PICTURE"	,"999999"		)
	SX3:S("TITULO"	,"CAMPO TST"	)
	SX3:S("DESCRIC"	,"CAMPO TST"	)
	SX3:SETOPCIONAL()

	SX3:ADD()
	SX3:S("ARQUIVO"	,"SA6")
	SX3:S("CAMPO"		,"A6_NOVO2"	)
	SX3:S("TIPO"		,"N"			)
	SX3:S("TAMANHO"	,6				)
	SX3:S("DECIMAL"	,0				)
	SX3:S("PICTURE"	,"999999"		)
	SX3:S("TITULO"	,"CAMPO TST"	)
	SX3:S("DESCRIC"	,"CAMPO TST"	)
	SX3:SETNAOUSADO()

	SX3:CONFIRM()
	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX4()
	Sleep(100)
	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX5()
	Sleep(100)
	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX6()

	SX6 := UPDSX6():CREATE()

	SX6:ADD("MV_NOVOPAR", 'C', "DESCRICAO", 'VALOR')
	SX6:CONFIRM()

	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSX7()

	SX7 := UPDSX7():CREATE()

	SX7:ADD("A1_CGC"	, "011", "'NOME COMPLETO'"	, 'A1_NOME'	)
	SX7:ADD("A1_CODPRO"	, "012", "SB1->B1_NOME"	, 'A1_NOMPRO'	,'SB1', 1, "XFILIAL('SB1')+M->A1_CODPRO")

	SX7:CONFIRM()

	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSIX()

	SIX := UPDSIX():CREATE()

	SIX:ADD('ZZZ', 'ZZZ_FILIAL+ZZZ_COD1', 'TESTE', 'ZZZCODIGO1')
	SIX:ADD('ZZZ', 'ZZZ_FILIAL+ZZZ_COD2', 'TESTE', 'ZZZCODIGO2')
	SIX:ADD('ZZZ', 'ZZZ_FILIAL+ZZZ_COD3', 'TESTE', 'ZZZCODIGO3')

	SIX:CONFIRM()

	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSXA()
	Sleep(200)
	Return


/*/{Protheus.doc}

Atualiza dicionario SX1

@author  Fernando Alencar
@since   20/11/2011
/*/
Static Function ExecSXB()
	Sleep(200)
	Return
