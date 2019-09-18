#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION TSTUPDXA()

	SXA := UPDSXA():CREATE()
   
   SXA:REMOVE('ZA1', '1', .T.)// REMOVE TODOS
   SXA:REMOVE('ZA1', '1', .F.)// REMOVE APENAS PASTA 1
   
	SXA:ADDPASTA('ZA1', '1', 'Dados Gerais', 'Datos Generales','General Data')
	SXA:ADDPASTA('ZA1', '2', 'Dados Credor', 'Datos Prestamista','Data Lender')
	SXA:ADDPASTA('ZA1', '3', 'Dados Testemunhas', 'Datos de Testigos','Data Witnesses')

	SXA:CONFIRM()

   //Obs.: Para vincular os campos as pastas na criacao dos campos na SX3
   //      informe no campo X3_FOLDER o numero da ordem da pasta.
   //Ou use o metodo ADDCAMPOS(CALIAS, CORDEM, ACAMPOS) como exemplo abaixo:
   
   WCAMPOS := {'ZA1_CODIGO', 'ZA1_CODCLI'}
   SXA:ADDCAMPOS('ZA1', '1', WCAMPOS)
   
RETURN NIL
