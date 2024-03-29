#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSIX

Abstra��o do dicionario SX5

@author		helitom silva
@data		16 de Maio de 2012
@method		{create} 	cria um novo objeto
@method 	{add} 	 	adiciona um registro a tabela generica
@method 	{s}		 	seta os atributos do indice
@method 	{remove} 	remove uma tabela generica se existir
@method		{confirm}	comita uma tabela generica adicionada
@method		{setlog}	seta o objeto responsavel pelo log
*/

CLASS UPDSX5

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATE O CONFIRMA
	DATA OLOG
	DATA CFILIAL

	METHOD CREATE() CONSTRUCTOR
	METHOD ADDTABELA()
	METHOD ADDITENS()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()

ENDCLASS

/*{ProtheusDoc} CREATE

METODO CONSTRUTOR DA CLASSE UPDSX5

@author		helitom.silva
@data		20 de outubro de 2011
*/
METHOD CREATE() CLASS UPDSX5

	::STRUCT := {'FILIAL', 'TABELA', 'CHAVE', 'DESCRI', 'DSCSPA', 'DSCENG'}
	::MODELS := {}

	::CFILIAL := xFilial('SX5')

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

RETURN SELF

/*{ProtheusDoc} ADDTABELA

Inclus�o TABELA GENERICA

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD ADDTABELA(CFILIAL, CTABELA, CDESCRI, CDSCSPA, CDSCENG, LCOMPART) CLASS UPDSX5

    DEFAULT CFILIAL  := ""
	DEFAULT LCOMPART := .T.
	
    IF EMPTY(CFILIAL) .AND. !LCOMPART
       CFILIAL := ::CFILIAL
    ENDIF

	::MODEL := 	{ ::CFILIAL  	,;//FILIAL
					  '00' 		,;//TABELA
					   ''			,;//CHAVE - TABELA
					   ''			,;//DESCRIC
					   ''			,;//DSCSPA
					   ''			} //DSCENG

	AADD(::MODELS, ::MODEL)	  //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('FILIAL'	, CFILIAL)
	SELF:S('CHAVE'  , CTABELA)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DSCSPA' , CDSCSPA)
	SELF:S('DSCENG'	, CDSCENG)

RETURN SELF

/*{ProtheusDoc} ADDITENS

Inclus�o ITEM DA TABELA GENERICA

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD ADDITENS(CFILIAL, CTABELA, CCHAVE, CDESCRI, CDSCSPA, CDSCENG, LCOMPART) CLASS UPDSX5

	DEFAULT CFILIAL  := ""
	DEFAULT LCOMPART := .F.
	
    IF EMPTY(CFILIAL) .AND. !LCOMPART
       CFILIAL := ::CFILIAL
    ENDIF

	::MODEL := { ::CFILIAL  	,;//FILIAL
				   '' 			,;//TABELA
				   ''			,;//CHAVE
				   ''			,;//DESCRIC
				   ''			,;//DSCSPA
				   ''			} //DSCENG

	AADD(::MODELS, ::MODEL)	  //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('FILIAL'	, CFILIAL)
	SELF:S('TABELA'	, CTABELA)
	SELF:S('CHAVE'  , CCHAVE)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DSCSPA' , CDSCSPA)
	SELF:S('DSCENG'	, CDSCENG)

RETURN SELF

/*{ProtheusDoc} S

Altera atributo do dicionario SX5

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD S(ATTR, VALOR) CLASS UPDSX5
	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: N�o foi poss�vel configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

RETURN SELF

/*{ProtheusDoc} CONFIRM

CONFIRMA A GRAVA��O DO REGISTRO

@author		helitom.silva
@data		20 de outubro de 2011
*/
METHOD CONFIRM() CLASS UPDSX5

	LOCAL I

	::OLOG:LOG("Os seguintes param�tros foram adicionados ao dicion�rio SX5")

	DBSELECTAREA("SX5")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" TABELA GENERICA ["+::MODELS[I][02]+"]")

        DBGOTOP()
		IIF(DBSEEK(::MODELS[I][01]+::MODELS[I][02]+::MODELS[I][03]), RLOCK(), DBAPPEND())

			X5_FILIAL    	:= ::MODELS[I][01]
			X5_TABELA  		:= ::MODELS[I][02]
			X5_CHAVE     	:= ::MODELS[I][03]
			X5_DESCRI 	   := ::MODELS[I][04]
			X5_DESCSPA		:= ::MODELS[I][05]
			X5_DESCENG		:= ::MODELS[I][06]

		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF


/*{ProtheusDoc} REMOVE

REMOVE TABELA DO DICIONARIO

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD REMOVE(CFILIAL, CTABELA, CCHAVE, LTABELA) CLASS UPDSX5

	::OLOG:LOG("As seguintes Tabelas Genericas foram excluidas do dicion�rio SX5")
	
	DEFAULT CCHAVE  := CTABELA
	DEFAULT LTABELA := .F.
	 
    IF EMPTY(CFILIAL)
       CFILIAL := ::CFILIAL
    ENDIF

	DBSELECTAREA("SX5")
	DBSETORDER(1)
    DBGOTOP()

	::OLOG:LOG(" TABELA GENERICA FILIAL[" + CFILIAL + " TABELA: " + CTABELA + "]")

	WHILE .Not. SX5->(EOF())

		IF LTABELA		
			IF SX5->X5_FILIAL = CFILIAL .and. ((SX5->X5_TABELA == CTABELA) .or. (SX5->X5_TABELA = '00' .and. SX5->X5_CHAVE = CTABELA))

				RLOCK()
					DBDELETE()
				DBUNLOCK()

			ENDIF
		ELSE
			IF SX5->X5_FILIAL = CFILIAL .and. SX5->X5_TABELA == CTABELA .and. SX5->X5_CHAVE == CCHAVE

				RLOCK()
					DBDELETE()
				DBUNLOCK()

			ENDIF		
		ENDIF
		
		SX5->(DBSKIP())
		
	END

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF