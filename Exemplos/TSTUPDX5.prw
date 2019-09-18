#include "totvs.ch"
#include "protheus.ch"

USER FUNCTION TSTUPDX5()
    
    /* Estrutura basica para criacao de consulta padrao
	 SX5 := UPDSX5():CREATE()
     
    SX5:REMOVE(CFILIAL, CTABELA) //REMOVE TODOS OS REGISTROS DA TABELA 	 
	 SX5:ADDTABELA(CFILIAL, CTABELA, CDESCRIC, CDSCSPA, CDSCENG)  //ADICIONA TABELA GENERICA
	 SX5:ADDITENS(CFILIAL, CTABELA, CCHAVE, CDESCRIC, CDSCSPA, CDSCENG)  //ADICIONA ITEM NA TABELA GENERICA  
     	  	        
	 SX5:CONFIRM()	
    */
    
	 SX5 := UPDSX5():CREATE()
     
     //SX5:REMOVE('010101', 'Z1')  //PODE REMOVER, MAS SE JA EXISTIR O SISTEMA ALTERA, PORTANTO PODE NAO
                               // HAVER NECESSIDADE DE REMOVER	 
     
    SX5:ADDTABELA('010101', 'Z1', 'Tipos de Banco', 'Tipos de Banco', 'Tipos de Banco') 
	 SX5:ADDITENS('010101', 'Z1', '01', '1 - PDV')
	 SX5:ADDITENS('010101', 'Z1', '02', '2 - Conta Transitória')
    SX5:ADDITENS('010101', 'Z1', '03', '3 - Caixa Geral')	
    SX5:ADDITENS('010101', 'Z1', '04', '4 - Caixa Fundo Fixo')	
    SX5:ADDITENS('010101', 'Z1', '05', '5 - Conta Bancaria')   
     	    	        	
	 SX5:CONFIRM()
	     
RETURN NIL
