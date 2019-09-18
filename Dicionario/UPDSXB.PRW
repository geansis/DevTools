#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSXB

Abstração do dicionario SXB

@author		helitom.silva
@data		27 de abril de 2012
@method		{create} 		cria um novo objeto
@method 	{addconsult()}  adiciona consulta
@method 	{addindice()}	adiciona indice
@method 	{addcoluna()}	adiciona coluna
@method 	{addfiltro()}	adiciona filtro
@method 	{addretorn()}	adiciona retorno
@method 	{addbotinc()}	adiciona botao de inclusao
@method 	{addbotalt()}	adiciona botao de alteração
@method 	{addbotdel()}	adiciona botao de deleção
@method 	{s}		 		seta os atributos 
@method 	{remove} 		remove consulta
@method		{confirm}		comita consulta
@method		{setlog}		seta o objeto responsavel pelo log
*/

CLASS UPDSXB

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATÉ O CONFIRMA
	DATA OLOG

	METHOD CREATE() CONSTRUCTOR
	METHOD ADDCONSULT()
    METHOD ADDINDICE()
    METHOD ADDCOLUNA()
    METHOD ADDFILTRO()
    METHOD ADDRETORN()
    METHOD ADDBOTINC()
    METHOD ADDBOTALT()
    METHOD ADDBOTDEL()    
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()

ENDCLASS

/*  Breve descricao de como se comporta cada etapa para
    criacao de uma consulta Padrao.

    Exemplo: Consulta Posto de Coleta

	*** XB_TIPO := "1" - Primeira Etapa
	    Tipo que define informacoes de nome, descricoes e Tabela da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "1"                         //Tipo que define informacoes de nome, descricoes e Tabela da consulta
		XB_SEQ    := "01"                        //Sequencia da consulta, neste caso 01.
		XB_COLUNA := "DB"                        //DB, define arquivo de banco
		XB_DESCRI := "Posto de Coleta"           //Descricao da consulta
		XB_CONTEM := "Z07"                       //Tabela a ser consultada

   *** XB_TIPO   := "2" - Segunda etapa
       Tipo que define os indices utilizados para consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "2"                         //Tipo que define os indices utilizados para consulta
		XB_SEQ    := "01"                        //Sequencia ordem que ira aparecer o indice
		XB_COLUNA := "01"                        //Numero de Ordem do Indice na Tabela de Consulta(Dicionario)
		XB_DESCRI := "Codigo do Posto"           //Descricao do Indice
		XB_CONTEM := ""
		
   *** XB_TIPO   := "3" - Terceira etapa
       Tipo que define os Botoes a serem apresentados na Consulta.

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "3"                         Tipo que define os Botoes a serem apresentados na Consulta.
		XB_SEQ    := "01"                        //Sequencia ordem que ira aparecer o botão
		XB_COLUNA := "01"                        //Numero de Ordem do Botão
		XB_DESCRI := "Cadastra Novo"             //Descricao do Botao em Portugues.
		XB_DESSPA := "Registra Nuevo"            //Descricao do Botao em Espanhol.
		XB_DESENG := "Add New"           		 //Descricao do Botao em Ingles.
		XB_CONTEM := ""							 //Função a Ser executada ao clicar no Botão

   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ    := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2 (APPENDA ANTERIOR)
		XB_COLUNA := "01"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI := "Codigo Posto"              //Descriçao da coluna
		XB_CONTEM := "Z07_CODIGO"                //Field da tabela correspondente a coluna da consulta

   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ    := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2
		XB_COLUNA := "02"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI := "Descricao"                 //Descriçao da coluna
		XB_CONTEM := "Z07_NOME"                  //Field da tabela correspondente a coluna da consulta

   *** XB_TIPO   := "5" - Quinta etapa
       Tipo que define o retorno da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "5"                         //Tipo que define o retorno da consulta
		XB_SEQ    := "02"                        //Sequencia do Retorno
		XB_COLUNA := ""
		XB_DESCRI := ""
		XB_CONTEM := "Z07->Z07_CODIGO"           //Campo a ser retornado na consulta
		
   *** XB_TIPO   := "6" - Sexta etapa
       Tipo que define o filtro da consulta

		XB_ALIAS  := cAlias                    //Nome da consulta
		XB_TIPO   := "6"                       //Tipo que define o filtro que será realizado na consulta
		XB_SEQ    := "01"                      //Sequencia
		XB_CONTEM := "tabela->campo = 1"       //Filtro da consulta
   		
*/

METHOD CREATE() CLASS UPDSXB

	::STRUCT := { 'ALIAS' , 'TIPO' , 'SEQ', 'COLUNA', 'DESCRI'  , ;
		          'DESCSPA'  ,'DESCENG'  ,'CONTEM'}
	::MODELS := {}

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

RETURN SELF

/*
@Desc		Adiciona Consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD ADDCONSULT(CCONSULTA, CDESCRI, CDESCSPA, CDESCENG, CTABELA, CTIPO) CLASS UPDSXB
	/*
	*** XB_TIPO := "1" - Primeira e segunda etapa
	    Tipo que define informacoes de nome, descricoes e Tabela da consulta

		XB_ALIAS   := cAlias                      //Nome da consulta
		XB_TIPO    := "1"                         //Tipo que define informacoes de nome, descricoes e Tabela da consulta
		XB_SEQ     := "01"                        //Sequencia da consulta, neste caso 01.
		XB_COLUNA  := "DB"                        //Define tipo de Consulta: Banco (BD), Especifica (RE)
		XB_DESCRI  := "Posto de Coleta"           //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"           //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"           //Descricao da consulta INGLES
		XB_CONTEM  := "Z07"                       //Tabela a ser consultada
	*/
	
	DO CASE
		CASE CTIPO = '1' //Consulta de banco de dados
			CTIPO := 'DB'
		CASE CTIPO = '2' //Consulta Especifica
			CTIPO := 'RE'
		OTHERWISE
			CTIPO := 'DB'		
	ENDCASE
	
	::MODEL := 	{    '' 	,;//XB_ALIAS
					 '1'	,;//XB_TIPO
					 '01'	,;//XB_SEQ
					 'DB'   ,;//XB_COLUNA
					 ''		,;//XB_DESCRI
					 ''		,;//XB_DESCSPA
					 ''		,;//XB_DESCENG
					 ''		} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)
	SELF:S('CONTEM' , CTABELA)
	SELF:S('COLUNA' , CTIPO)

RETURN SELF

/*
@Desc		Adiciona Indice a Consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD ADDINDICE(CCONSULTA, CSEQINDEX, CCODINDEX, CDESCRI, CDESCSPA, CDESCENG, CFORMULA) CLASS UPDSXB
   /*
   *** XB_TIPO   := "2" - Terceira etapa
       Tipo que define os indices utilizados para consulta

		XB_ALIAS   := cAlias                     //Nome da consulta
		XB_TIPO    := "2"                        //Tipo que define os indices utilizados para consulta
		XB_SEQ     := "01"                       //Sequencia ordem que ira aparecer o indice
		XB_COLUNA  := "01"                       //Numero de Ordem do Indice na Tabela de Consulta(Dicionario)
		XB_DESCRI  := "Posto de Coleta"          //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"          //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"          //Descricao da consulta INGLES
   */

	::MODEL := 	{    '' 	,;//XB_ALIAS
					 '2'	,;//XB_TIPO
					 ''		,;//XB_SEQ
					 ''     ,;//XB_COLUNA
					 ''		,;//XB_DESCRI
					 ''		,;//XB_DESCSPA
					 ''		,;//XB_DESCENG
					 ''		} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQINDEX)
	SELF:S('COLUNA' , CCODINDEX)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)
	SELF:S('CONTEM' , CFORMULA)

RETURN SELF

/*
@Desc		Adiciona Coluna a Consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD ADDCOLUNA(CCONSULTA, CSEQINDEX, CSEQCOLUNA, CDESCRI, CDESCSPA, CDESCENG, CFIELDTAB) CLASS UPDSXB
   /*
   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS   := cAlias                      //Nome da consulta
		XB_TIPO    := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ     := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2
		XB_COLUNA  := "02"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI  := "Posto de Coleta"          //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"          //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"          //Descricao da consulta INGLES
		XB_CONTEM  := "Z07_NOME"                  //Field da tabela correspondente a coluna da consulta
   */

	::MODEL := 	{    '' 	,;//XB_ALIAS
					 '4'	,;//XB_TIPO
					 ''		,;//XB_SEQ
					 'DB'	,;//XB_COLUNA
					 ''	    ,;//XB_DESCRI
					 ''		,;//XB_DESCSPA
					 ''		,;//XB_DESCENG
					 ''		} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQINDEX)
	SELF:S('COLUNA'	, CSEQCOLUNA)
	SELF:S('DESCRI'	, CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)
	SELF:S('CONTEM'	, CFIELDTAB)

RETURN SELF

/*
@Desc		Adiciona Filtro a Consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD ADDFILTRO(CCONSULTA, CFILTRO) CLASS UPDSXB
   /*
   *** XB_TIPO   := "6" - Sexta etapa
       Tipo que define o filtro da consulta

		XB_ALIAS  := cAlias                    //Nome da consulta
		XB_TIPO   := "6"                       //Tipo que define o filtro que será realizado na consulta
		XB_SEQ    := "01"                      //Sequencia
		XB_CONTEM := "tabela->campo = 1"       //Filtro da consulta
   */

	::MODEL := 	{    '' 	,;//XB_ALIAS
					 '6'	,;//XB_TIPO
					 '01'	,;//XB_SEQ
					 ''     ,;//XB_COLUNA
					 ''		,;//XB_DESCRI
					 ''		,;//XB_DESCSPA
					 ''		,;//XB_DESCENG
					 ''		} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('CONTEM'	, CFILTRO)

RETURN SELF

/*
@Desc		Adiciona Retorno a Consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD ADDRETORN(CCONSULTA, CSEQRET, CRETORNO) CLASS UPDSXB
   /*
   *** XB_TIPO   := "5" - Quinta etapa
       Tipo que define o retorno da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "5"                         //Tipo que define o retorno da consulta
		XB_SEQ    := "02"                        //Sequencia do Retorno
		XB_CONTEM := "Z07->Z07_CODIGO"           //Campo a ser retornado na consulta
   */

	::MODEL := 	{    '' 	,;//XB_ALIAS
					 '5'	,;//XB_TIPO
					 ''		,;//XB_SEQ
					 ''	    ,;//XB_COLUNA
					 ''		,;//XB_DESCRI
					 ''		,;//XB_DESCSPA
					 ''		,;//XB_DESCENG
					 ''		} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQRET)
	SELF:S('CONTEM'	, CRETORNO)

RETURN SELF

/*
@Desc 		Adiciona Botao de Inclusão
@author		helitom.silva
@data		28 de março de 2014
*/
METHOD ADDBOTINC(CCONSULTA) CLASS UPDSXB

	::MODEL := 	{ '' 				,;//XB_ALIAS
				  '3'				,;//XB_TIPO
				  '01'				,;//XB_SEQ
				  '01'  			,;//XB_COLUNA
				  'Cadastra Novo'	,;//XB_DESCRI
				  'Cadastra Nuevo'	,;//XB_DESCSPA
				  'Add New'			,;//XB_DESCENG
				  '01'				} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS
		          
	SELF:S('ALIAS', CCONSULTA)

RETURN SELF

/*
@Desc 		Adiciona Botao de Alteração
@author		helitom.silva
@data		28 de março de 2014
*/
METHOD ADDBOTALT(CCONSULTA) CLASS UPDSXB
	
	Local nPosCons 	  := aScan(::MODELS, {|X| AllTrim(X[1]) == AllTrim(CCONSULTA) .and. AllTrim(X[2]) == '1'})
	Local nPosCont 	  := aScan(::STRUCT, {|X| AllTrim(X) == 'CONTEM'})
	
	Local cAliasTemp  := AllTrim(::MODELS[nPosCons][nPosCont]) 
	
	::MODELS[nPosCons][nPosCont] := cAliasTemp + 'A'

RETURN SELF

/*
@Desc 		Adiciona Botao de Exclusão
@author		helitom.silva
@data		28 de março de 2014
*/
METHOD ADDBOTDEL(CCONSULTA) CLASS UPDSXB
	
	Local nPosCons 	  := aScan(::MODELS, {|X| AllTrim(X[1]) == AllTrim(CCONSULTA) .and. AllTrim(X[2]) == '1'})
	Local nPosCont 	  := aScan(::STRUCT, {|X| AllTrim(X) == 'CONTEM'})
	
	Local cAliasTemp  := AllTrim(::MODELS[nPosCons][nPosCont]) 
	
	::MODELS[nPosCons][nPosCont] := cAliasTemp + 'D'

RETURN SELF

/*
@Desc		Seta valor ao Atributo
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD S(ATTR, VALOR) CLASS UPDSXB
	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: Não foi possível configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

RETURN SELF

/*
@Desc 		Confirma a Gravação do Registro
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD CONFIRM() CLASS UPDSXB

	LOCAL I

	::OLOG:LOG("As seguintes Etapas da consulta foram adicionados ao dicionário SXB")

	DBSELECTAREA("SXB")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" A Etapa Tipo:"+::MODELS[I][02]+", SEQ:"+::MODELS[I][03]+"]")

		dbGoTop()
		IIf(dbSeek(PADR(::MODELS[I][01],06)+::MODELS[I][02]+::MODELS[I][03]+::MODELS[I][04]),RLock(),dbAppend())
			XB_ALIAS   := ::MODELS[I][01]
			XB_TIPO    := ::MODELS[I][02]
			XB_SEQ     := ::MODELS[I][03]
			XB_COLUNA  := ::MODELS[I][04]
			XB_DESCRI  := ::MODELS[I][05]
			XB_DESCSPA := ::MODELS[I][06]
			XB_DESCENG := ::MODELS[I][07]
			XB_CONTEM  := ::MODELS[I][08]
		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF

/*
@Desc		Remove consulta
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD REMOVE(CCONSULTA) CLASS UPDSXB

	DBSELECTAREA("SXB")
	DBSETORDER(1)

	dbGoTop()
	If dbSeek(CCONSULTA)
		While .Not. Eof() .And. AllTrim(XB_ALIAS) == AllTrim(CCONSULTA)
			If RLock()
				dbDelete()
				dbUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf

RETURN SELF

/*
@Desc		Seta Log
@author		helitom.silva
@data		27 de abril de 2012
*/
METHOD SETLOG(OLOG) CLASS UPDSXB

	::OLOG := OLOG

RETURN SELF