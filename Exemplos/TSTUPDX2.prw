#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION TSTUPDX2(cEmpresa)
   
   	DEFAULT CEMPRESA := "99"
     
	SX2 := UPDSX2():CREATE(CEMPRESA)
	
	SX2:ADD('ZZZ', "CADASTRO DE TESTE 1" , "ZZZ_FILIAL+ZZZ_CODIGO+ZZZ_LOJA")
	SX2:S('PATH', "/DATA/")
	
	SX2:CONFIRM()
   
RETURN NIL 
