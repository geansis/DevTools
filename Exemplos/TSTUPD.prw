#Include 'Protheus.ch'

/*/{Protheus.doc} TSTUPD

@author Evandro Vendrametto
@since 25/11/2013
@version 1.0	

@return ${Nil}, ${Nil}

@description Compatibilizadores da rotina.

/*/
User Function TSTUPD()
	
	Local aData := {}
	
	aAdd(aData, {"TSTUPD1", "campos das tabelas do loja 01"})
	aAdd(aData, {"TSTUPD2", "Cadastro 02"})
	aAdd(aData, {"TSTUPD3", "Cadastro 03"})
	aAdd(aData, {"TSTUPD4", "Ajuste 04"})
	aAdd(aData, {"TSTUPD5", "Cadastro 05"})
	aAdd(aData, {"TSTUPD6", "Cadastros 06"})
	aAdd(aData, {"TSTUPD7", "Lançamentos 07"})
	aAdd(aData, {"TSTUPD8", "Cadastro de Clientes 08"})
	
Return aData

Static Function SalvaLog(cLog)
	Local cFile := "C:/PLOG/codupd.txt"
	MemoWrite( cFile, cLog )
Return