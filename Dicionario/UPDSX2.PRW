#INCLUDE 'PROTHEUS.CH'

/*
AbstraÁ„o do dicionario SX2

@author		fernando.alencar
@data		11 de outubro de 2011
@method		{create} 	cria um novo objeto
@method 	{add} 	 	adiciona um indice
@method 	{s}		 	seta os atributos do indice
@method 	{remove} 	remove um indice se existir
@method 	{confirm}	comita os indices adicionados
@method 	{setlog}	seta o objeto responsavel pelo log
*/
CLASS UPDSX2

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS AT… O CONFIRMA«√O
	DATA OLOG
	DATA EMPRESA

	METHOD CREATE() CONSTRUCTOR
	METHOD ADD()
	METHOD CLONE()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()
    METHOD SETCOMPARTILHADO()
    METHOD SETEXCLUSIVO()

ENDCLASS


METHOD CREATE(CEMPRESA) CLASS UPDSX2

	DEFAULT CEMPRESA := "99"

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

	::EMPRESA 	:= CEMPRESA

	::STRUCT := { 'CHAVE' ,'PATH' , 'ARQUIVO' , 'NOME','NOMESPA','NOMEENG',;
				  'ROTINA', 'MODO', 'MODOUN','MODOEMP', 'DELET','TTS',;
				  'UNICO','PYME','MODULO', 'DISPLAY','SYSOBJ','USROBJ' }
	
	::MODELS := {}

RETURN .T.

METHOD ADD(CCHAVE, CNOME, CUNICO) CLASS UPDSX2

	::MODEL := 	{ ''  		,;//CHAVE
				  ''		,;//PATH
				  ''		,;//ARQUIVO
				  ''		,;//NOME
			 	  ''		,;//NOMESPA
				  ''		,;//NOMEENG
				  ''		,;//ROTINA
				  'E'		,;//MODO
				  'E'  		,;//MODOUN
				  'E'		,;//MODOEMP
				  0			,;//DELET
				  ''  		,;//TTS
				  '' 		,;//UNICO
				  'N'		,;//PYME
				  0			,;//MODULO
				  ''		,;//DISPLAY
				  ''		,;//SYSOBJ
				  ''		} //USROBJ

	AADD(::MODELS, ::MODEL)

	SELF:S('CHAVE', CCHAVE)
	SELF:S('NOME' , CNOME)
	SELF:S('UNICO', CUNICO)

RETURN .T.

/*{ProtheusDoc} UPDSX3:CLONE

	Clona uma tabela e adiciona ao modelo

	@param		cTableOri tabela do dicion√°rio que ser√° usado para criar a tabela cTableDes
	@param		cTableDes nome da nova tabela
	@developer	helitom.silva
	@data		17 de fevereiro de 2014
*/
METHOD CLONE(CTABLEORI, CTABLEDES) CLASS UPDSX2
	
	Default CTABLEDES := CTABLEORI
	
	IF Empty(AllTrim(CTABLEORI))
		RETURN
	ENDIF
	
	DbSelectArea("SX2")
	DbSetOrder(1)
	IF DbSeek(CTABLEORI)

		::MODEL 	:= { CTABLEDES	 ,;
			              X2_PATH    ,;
			              CTABLEDES + cEmpAnt + "0"  ,; 
			              X2_NOME    ,;
			              X2_NOMESPA ,;
			              X2_NOMEENG ,;
			              X2_ROTINA  ,;
			              X2_MODO    ,;
			              X2_MODOUN  ,;
			              X2_MODOEMP ,;
			              X2_DELET   ,;
			              X2_TTS   	 ,;
			              X2_UNICO   ,;
			              X2_PYME    ,;
			              X2_MODULO  ,;
			              X2_DISPLAY ,;
			              X2_SYSOBJ  ,;
			              X2_USROBJ  }

		AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS
	ELSE
		CONOUT("ATENCAO: N√£o pois poss√≠vel criar a tabela: " + CTABLEDES + ", pois a tabela: " + CTABLEORI + "n√£o existe no dicion√°rio SX2!")
		::OLOG:LOG("ATENCAO: N√£o pois poss√≠vel criar a tabela: " + CTABLEDES + ", pois a tabela: " + CTABLEORI + "n√£o existe no dicion√°rio SX2!")
	ENDIF

RETURN SELF

METHOD S(ATTR, VALOR) CLASS UPDSX2

	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: N„o foi possÌvel configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

RETURN SELF

METHOD CONFIRM() CLASS UPDSX2

	LOCAL I

	DBSELECTAREA('SX2')
	DBSETORDER(1)

	::OLOG:LOG("As seguintes tabelas foram criados no dicion·rio SX2")

//PARA CADA TABELA ADICIONADO A LISTA
	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG("TABELA ["+::MODELS[I][1]+"]")

		::REMOVE(::MODELS[I][1])

		DBAPPEND()
		X2_CHAVE   		:= ::MODELS[I][01]
		X2_PATH   		:= ::MODELS[I][02]
		X2_ARQUIVO 		:= Iif(Empty(::MODELS[I][03]), ::MODELS[I][01] + Iif(cEmpAnt<>"99",cEmpAnt,::EMPRESA) + "0", ::MODELS[I][03]) //cAlias+cCodEmp+"0"
		X2_NOME    		:= ::MODELS[I][04]
		X2_NOMESPA   	:= ::MODELS[I][05]
		X2_NOMEENG    	:= ::MODELS[I][06]
		X2_ROTINA   	:= ::MODELS[I][07]
		X2_MODO   		:= ::MODELS[I][08]
		X2_MODOUN   	:= ::MODELS[I][09]
		X2_MODOEMP   	:= ::MODELS[I][10]
		X2_DELET   		:= ::MODELS[I][11]
		X2_TTS   		:= ::MODELS[I][12]
		X2_UNICO   		:= ::MODELS[I][13]
		X2_PYME   		:= ::MODELS[I][14]
		X2_MODULO   	:= ::MODELS[I][15]
		X2_DISPLAY  	:= ::MODELS[I][16]
		X2_SYSOBJ  		:= ::MODELS[I][17]
		X2_USROBJ   	:= ::MODELS[I][18]
		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}

	SX2->(DBCLOSEAREA())

RETURN SELF

METHOD REMOVE(CALIAS) CLASS UPDSX2

	DBSELECTAREA("SX2")
	DBSETORDER(1)
	DBGOTOP()

	IF DBSEEK( CALIAS )
		IF RLOCK()
			DBDELETE()
			DBUNLOCK()
		ENDIF
	ENDIF

RETURN .T.


METHOD SETCOMPARTILHADO() CLASS UPDSX2

	SELF:S('MODO'	, 'C')
	SELF:S('MODOUN'	, 'C')
	SELF:S('MODOEMP', 'C')

RETURN

METHOD SETEXCLUSIVO() CLASS UPDSX2

	SELF:S('MODO'	, 'E')
	SELF:S('MODOUN'	, 'E')
	SELF:S('MODOEMP', 'E')

RETURN

METHOD SETLOG(OLOG) CLASS UPDSX2
	::OLOG := OLOG
RETURN SELF
