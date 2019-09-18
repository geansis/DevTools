#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION DEVTSIX0()

   LOCAL OLOG := PARAMIXB[1]

	SIX := UPDSIX():CREATE(OLOG)

	SIX:ADD()
	SIX:S('INDICE'	 	, 'ZCP')
	SIX:S('ORDEM'	 		, '0')
	SIX:S('CHAVE'	 		, 'ZCP_FILIAL+ZCP_CLIENT+ZCP_LOJA+ZCP_COND+ZCP_FPGTO')
	SIX:S('DESCRICAO'		, 'Filial+Cod. Cliente+Loja Cliente+Cond. de Pgto+Forma de Pgto')
	SIX:S('PROPRI'	 	, 'U')
	SIX:S('SHOWPESQ' 		, 'S')

	SIX:ADD()
	SIX:S('INDICE'	 	, 'ZFP')
	SIX:S('ORDEM'	 		, '0')
	SIX:S('CHAVE'	 		, 'ZFP_FILIAL+ZFP_CODIGO')
	SIX:S('DESCRICAO'		, 'Filial+Codigo')
	SIX:S('PROPRI'	 	, 'U')
	SIX:S('SHOWPESQ' 		, 'S')

	SIX:CONFIRM()

RETURN NIL


//sintaxe antiga
Static Function AjustaSIX()

Local cAlias := ""
Local cOrdem := ""

//===========================================================================
cAlias := "ZCP"
cOrdem := "0"
dbGoTop()
If dbSeek(cAlias)
	While .Not. Eof() .And. INDICE = cAlias
		If RLock()
			dbDelete()
			dbUnLock()
		EndIf
		dbSkip()
	EndDo
EndIf
cOrdem := Soma1(cOrdem)
dbAppend()
	INDICE    := cAlias
	ORDEM     := cOrdem
	CHAVE     := "ZCP_FILIAL+ZCP_CLIENT+ZCP_LOJA+ZCP_COND+ZCP_FPGTO"
	DESCRICAO := "Filial+Cod. Cliente+Loja Cliente+Cond. de Pgto+Forma de Pgto"
	PROPRI    := "U"
	SHOWPESQ  := "S"
dbUnLock()
//---------------------------------------------------------------------------
//===========================================================================
cAlias := "ZFP"
cOrdem := "0"
dbGoTop()
If dbSeek(cAlias)
	While .Not. Eof() .And. INDICE = cAlias
		If RLock()
			dbDelete()
			dbUnLock()
		EndIf
		dbSkip()
	EndDo
EndIf
cOrdem := Soma1(cOrdem)
dbAppend()
	INDICE    := cAlias
	ORDEM     := cOrdem
	CHAVE     := "ZFP_FILIAL+ZFP_CODIGO"
	DESCRICAO := "Filial+Codigo"
	PROPRI    := "U"
	SHOWPESQ  := "S"
dbUnLock()
//---------------------------------------------------------------------------
Return(.t.)