#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION TSTUPDXB()
    
    /* Estrutura basica para criacao de consulta padrao
	 SXB := UPDSXB():CREATE()
     
    SXB:REMOVE(CCONSULTA) 	 
	 SXB:ADDCONSULT(CCONSULTA, CDESCRI, CDESCSPA, CDESCENG, CTABELA, CTIPO[1=BANCO,2=ESPECIFICA])
	 SXB:ADDINDICE(CCONSULTA, CSEQINDEX, CCODINDEX, CDESCRI, CDESCSPA, CDESCENG, CFORMULA)
    SXB:ADDCOLUNA(CCONSULTA, CSEQINDEX, CSEQCOLUNA, CDESCRI, CDESCSPA, CDESCENG, CFIELDTAB OU EXPRESSAO)	    
    SXB:ADDRETORN(CCONSULTA, CSEQRET, CRETORNO)
    SXB:ADDFILTRO(CCONSULTA, CFILTRO)     
     	    	        	
	 SXB:CONFIRM()	
    */
    
	 SXB := UPDSXB():CREATE()
     
    SXB:REMOVE('SF1H') 	 
	 SXB:ADDCONSULT('SF1H', 'Nota Fiscal de Entrada', , , 'SF1')
	 SXB:ADDINDICE('SF1H', '01', '01', 'Numero + Serie')
    SXB:ADDCOLUNA('SF1H', '01', '01', 'Nota Fiscal', , , 'F1_DOC')	
    SXB:ADDCOLUNA('SF1H', '01', '02', 'Serie', , , 'F1_SERIE')	
    SXB:ADDCOLUNA('SF1H', '01', '03', 'Fornecedor', , , 'F1_FORNECE')
    SXB:ADDCOLUNA('SF1H', '01', '04', 'Loja Forn.', , , 'F1_LOJA')         
    SXB:ADDRETORN('SF1H', '01', 'SF1->F1_DOC')
    SXB:ADDFILTRO('SF1H', 'SF1->F1_DOC <> ""')     
     	    	        	
	 SXB:CONFIRM()
	     
RETURN NIL
