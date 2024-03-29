#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSIX

Abstra��o do dicionario SIX

@author		fernando.alencar
@data			11 de outubro de 2011
@method		{create} 	cria um novo objeto
@method 		{add} 	 	adiciona um indice
@method 		{s}		 	seta os atributos do indice
@method 		{remove} 	remove um indice se existir
@method		{confirm}	comita os indices adicionados
@method		{setlog}	seta o objeto responsavel pelo log
*/

CLASS UPDSIX

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS AT� O CONFIRMA
	DATA ULT_IND
	DATA OLOG

	METHOD CREATE() CONSTRUCTOR
	METHOD ADD()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()
	METHOD SXGETORDEM()
	METHOD UPDTABLE() 

ENDCLASS

METHOD CREATE() CLASS UPDSIX

	::STRUCT := { 'INDICE' , 'ORDEM' , 'CHAVE', 'DESCRICAO', 'DESCSPA'  , ;
		'DESCENG', 'PROPRI', 'F3'   , 'NICKNAME' , 'SHOWPESQ' }
	::MODELS := {}

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

RETURN SELF

/*
ADICIONA UM NOVO INDICE AO DICIONARIO
*/
METHOD ADD(CINDICE, CCHAVE, CDESC, CNICKNAME) CLASS UPDSIX

	::MODEL := 	{;
						 ''  	,;//INDICE
						 '' 	,;//ORDEM
						 ''		,;//CHAVE
						 ''		,;//DESCRICAO
						 ''		,;//DESCSPA
						 ''		,;//DESCENG
						 'C'	,;//PROPRI
						 ''		,;//F3
						 ''  	,;//NICKNAME
						 'S'	};//SHOWPESQ

	AADD(::MODELS, ::MODEL)						  			  	//REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('INDICE'		, CINDICE)
	SELF:S('CHAVE'		, CCHAVE)
	SELF:S('DESCRICAO'	, CDESC)
	SELF:S('NICKNAME'	, CNICKNAME)

RETURN

/*
SETA O VALOR DO ATRIBUTO
*/
METHOD S(ATTR, VALOR) CLASS UPDSIX

	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: N�o foi poss�vel configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

RETURN

/*
CONFIRMA A GRAVA��O DO REGISTRO
*/
METHOD CONFIRM() CLASS UPDSIX

	LOCAL ATABE  := {}
	LOCAL I
	LOCAL J

	::OLOG:LOG("Os seguintes indices ser�o criados na tabela SIX")

	DBSELECTAREA("SIX")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::MODELS[I][2] := _GETORDEM(::MODELS[I][1], ::MODELS[I][3])

		::REMOVE(::MODELS[I][1], ::MODELS[I][2])

		::OLOG:LOG(" INDICE ["+::MODELS[I][1]+"] ORDEM ["+::MODELS[I][2]+"]")

		DBAPPEND()
		INDICE    		:= ::MODELS[I][1]
		ORDEM     		:= ::MODELS[I][2]
		CHAVE     		:= ::MODELS[I][3]
		DESCRICAO 		:= ::MODELS[I][4]
		DESCSPA			:= ::MODELS[I][5]
		DESCENG			:= ::MODELS[I][6]
		PROPRI    		:= ::MODELS[I][7]
		F3		  		:= ::MODELS[I][8]
		NICKNAME  		:= ::MODELS[I][9]
		SHOWPESQ  		:= ::MODELS[I][10]
		DBUNLOCK()

		IF .NOT. ASCAN(ATABE,{|ATBL| ATBL = ::MODELS[I][1]}) > 0
			AADD(ATABE, ::MODELS[I][1])
		ENDIF

	NEXT

	FOR J := 1 TO LEN(ATABE)
		::UPDTABLE(ATABE[J])
	NEXT

	::OLOG:LINE()

	::MODELS := {}

RETURN

/*
REMOVE O INDICE SE EXISTIR
*/
METHOD REMOVE(CINDICE, CORDEM, LTODOS) CLASS UPDSIX
	
	LOCAL AAREA := GETAREA()
	
	DEFAULT CINDICE := ""
	DEFAULT CORDEM  := ""
	DEFAULT LTODOS  := .F.
	
	DBSELECTAREA("SIX")
	SIX->(DBSETORDER(1))
	SIX->(DBGOTOP())
	
	IF !LTODOS
		IF SIX->(DBSEEK(CINDICE+CORDEM))
			IF SIX->(RLock())
				SIX->(dbDelete())
				SIX->(dbUnLock())
			ENDIF
		ENDIF
	ELSE
		IF SIX->(DBSEEK(CINDICE))
			WHILE SIX->(!EOF()) .AND. (SIX->INDICE = CINDICE)
				IF SIX->(RLock())
					SIX->(dbDelete())
					SIX->(dbUnLock())				
				ENDIF
				
				SIX->(DBSKIP())
			END
		ENDIF	
	ENDIF
	
	RESTAREA(AAREA)

RETURN .F.

METHOD SETLOG(OLOG) CLASS UPDSIX

	::OLOG := OLOG
	
RETURN

/*
BUSCA O ULTIMO INDICE
*/
STATIC FUNCTION _GETORDEM(CINDICE, CCHAVE)

	LOCAL CORDEM := '0'

	IF DBSEEK(CINDICE)
		WHILE .NOT. EOF() .AND. INDICE = CINDICE
			//SE O INDICE A CHAVE FOREM IGUAIS, ENT�O RETORNA O ORDEM PARA SER DELETADO
			IF TRIM(CHAVE) == TRIM(CCHAVE)
				RETURN ORDEM
			ELSE
				CORDEM = ORDEM
			ENDIF
			dbSkip()
		ENDDO
	ENDIF

RETURN SOMA1(CORDEM)

METHOD SXGETORDEM(CINDICE, CCHAVE) CLASS UPDSIX

	LOCAL CORDEM := '0'
    LOCAL AAREA := GETAREA()

	DBSELECTAREA("SIX")
	DBSETORDER(1)
	DBGOTOP()

	IF DBSEEK(CINDICE)
		WHILE .NOT. EOF() .AND. INDICE = CINDICE
			//SE O INDICE A CHAVE FOREM IGUAIS, ENT�O RETORNA O ORDEM PARA SER DELETADO
			IF TRIM(CHAVE) == TRIM(CCHAVE)
				RETURN ORDEM
			ELSE
				CORDEM = ORDEM
			ENDIF
			dbSkip()
		ENDDO
	ENDIF

    RESTAREA(AAREA)

RETURN SOMA1(CORDEM)


/*/{Protheus.doc} UPDTABLE
@description Replica no banco as alteracoes feitas na tabela no Dicionario de Dados

@author Helitom Silva
@since  04/02/2015

@param CTABELA, Caracter, Nome da Tabela

/*/
METHOD UPDTABLE(CTABELA) CLASS UPDSIX

	TcInternal( 25, 'CLOB' )
	X31UpdTable( CTABELA )
	If __GetX31Error()
		MsgAlert(__GetX31Trace())
	EndIf
	TcInternal( 25, 'OFF' )

RETURN