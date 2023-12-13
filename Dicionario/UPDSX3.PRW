#INCLUDE 'TOTVS.CH'
#INCLUDE 'IDATOOLS.CH'

/* ANTIGO */
#DEFINE X3_USADO_EMUSO 		"€€€€€€€€€€€€€€ "
#DEFINE X3_USADO_NAOUSADO 	"€€€€€€€€€€€€€€€"
#DEFINE X3_USADO_USADOKEY 	"€€€€€€€€€€€€€€€"
#DEFINE X3_OBRIGATORIO 		"Á€"
#DEFINE X3_RESER 			"þÀ"
#DEFINE X3_RESER_NUMERICO 	"øÇ"
#DEFINE X3_RESERKEY 		"ƒ€"
#DEFINE X3_RES        		"€€"
#DEFINE X3_RESNAO  			"›€"

/* UTILIZANDO ATÉ O MOMENTO */
#DEFINE X3_USADO_FILIAL		"€€€€€€€€€€€€€€€"
#DEFINE X3_RESERV_FILIAL	"€€"

#DEFINE X3_USADO_MSFIL  	"€€€€€€€€€€€€€€€"
#DEFINE X3_RESERV_MSFIL 	"‚€"

#DEFINE X3_USADO_KEY		"€€€€€€€€€€€€€€°"
#DEFINE X3_RESERV_KEY		"ƒ€"

#DEFINE X3_USADO_OBR		"€€€€€€€€€€€€€€ "
#DEFINE X3_RESERV_OBR		"“€"

#DEFINE X3_USADO_OPC		"€€€€€€€€€€€€€€ "
#DEFINE X3_RESERV_OPC		"’A"

#DEFINE X3_USADO_NAO		"€€€€€€€€€€€€€€€"
#DEFINE X3_RESERV_NAO		"’A"

/* UTILIZANDO DICIONARIO NO BANCO */
#DEFINE X3_BUSADO_FILIAL    "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       "
#DEFINE X3_BRESERV_FILIAL	"                "
#DEFINE X3_BOBRIG_FILIAL	"  x     "

#DEFINE X3_BUSADO_MSFIL  	"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       "
#DEFINE X3_BRESERV_MSFIL 	"     x          "
#DEFINE X3_BOBRIG_MSFIL 	"  x     "

#DEFINE X3_BUSADO_KEY		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x xx    "
#DEFINE X3_BRESERV_KEY		"     xx         "
#DEFINE X3_BOBRIG_KEY		"  x     "

#DEFINE X3_BUSADO_OBR		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "
#DEFINE X3_BRESERV_OBR		"xxxxxx x        "
#DEFINE X3_BOBRIG_OBR		"  x     "

#DEFINE X3_BUSADO_OPC		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "
#DEFINE X3_BRESERV_OPC		"  x  x x     x  "
#DEFINE X3_BOBRIG_OPC 	    "  x     "

#DEFINE X3_BUSADO_NAO		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       "
#DEFINE X3_BRESERV_NAO		"  x  x x     x  "
#DEFINE X3_BOBRIG_NAO		"  x     "


/*/{Protheus.doc} UPDSX3
@description Abstraçãoo do dicionário SX3

@author	Fernando Alencar
@since	11/01/2011

@obs method	{create} 	cria um novo objeto
	 method	{add} 	 	adiciona um indice
	 method {s}		 	seta os atributos do indice
	 method {remove} 	remove um indice se existir
	 method {confirm}	comita os indices adicionados
	 method {setlog}	seta o objeto responsavel pelo log

/*/
CLASS UPDSX3

    DATA _STRUCT
    DATA MODEL
    DATA MODELS 		//ACUMULA OS MODELOS ATÃ‰ O CONFIRMA
    DATA OLOG
    DATA CONSTANTS
    DATA LDICBANCO

    METHOD CREATE() CONSTRUCTOR
    METHOD ADD()
    METHOD CLONE()
    METHOD S()
    METHOD REMOVE()
    METHOD CONFIRM()
    METHOD SETLOG()
    METHOD ADDFILIAL()
    METHOD SETFILIAL()
    METHOD ADDMSFIL()
    METHOD SETMSFIL()
    METHOD SETCHAVE()
    METHOD SETOBR()
    METHOD SETOPCIONAL()
    METHOD SETNAOUSADO()
    METHOD GETLOGTXT()
    METHOD UPDTABLE()
    METHOD SETHELP()
    METHOD REMOVEALL()
    METHOD SETORDEM()
    METHOD SETDICBANCO()
    METHOD GETDICBANCO()

ENDCLASS


/*/{Protheus.doc} CREATE
@description Metodo construtor

@author	Fernando Alencar
@since	19/11/2011

@param olog, Objeto, variável {Private} com o objeto do tipo UPDLOG

/*/
METHOD CREATE() CLASS UPDSX3

    IF TYPE("OLOG") != "U"
        ::OLOG 	 := OLOG
    ELSE
        ::OLOG 	 := UPDLOG():CREATE()
    ENDIF

    SELF:SETDICBANCO(.F.)

    ::_STRUCT := { 'ARQUIVO' 	,;
        'ORDEM' 		,;
        'CAMPO'		,;
        'TIPO'		,;
        'TAMANHO'	,;
        "DECIMAL"	,;
        "TITULO"		,;
        "TITSPA"		,;
        "TITENG"   	,;
        'DESCRIC'	,;
        'DESCSPA'	,;
        'DESCENG'  	,;
        'PICTURE' 	,;
        'VALID'		,;
        'USADO'		,;
        'RELACAO'	,;
        'F3'			,;
        'NIVEL'		,;
        'RESERV'		,;
        'CHECK'		,;
        'TRIGGER'	,;
        'PROPRI'		,;
        'BROWSE'		,;
        'VISUAL'		,;
        'CONTEXT'	,;
        'OBRIGAT'	,;
        'VLDUSER'	,;
        'CBOX'		,;
        'CBOXSPA'	,;
        'CBOXENG'	,;
        'PICTVAR'	,;
        'WHEN'		,;
        'INIBRW'		,;
        'GRPSXG'		,;
        'FOLDER'		,;
        'PYME'		,;
        'CONDSQL'	,;
        'CHKSQL'		,;
        'IDXSRV'		,;
        'ORTOGRA'	,;
        'IDXFLD'		,;
        'TELA'		,;
        'AGRUP'		,;
        'HELP'		}

    ::MODELS := {}

RETURN SELF

/*/{Protheus.doc} CLONE
@description clona um campo e adiciona um novo campo ao modelo

@author	Fernando Alencar
@since	19/11/2011

@param	cFieldOri, Caracter, campo do dicionário que será usado para criar o campo cFieldDes
@param	cFieldDes, Caracter, cnome do novo campo
		
/*/
METHOD CLONE(CFIELDORI, CFIELDDES, CARQUIVO) CLASS UPDSX3

    Default CFIELDORI := ""
    Default CFIELDDES := ""
    Default CARQUIVO  := ""

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    SX3->(DbGoTop())
    If SX3->(DbSeek(PadR(CFIELDORI, 10)))

        If Empty( CARQUIVO )
            CARQUIVO  := SX3->X3_ARQUIVO
        EndIf

        cHelp 	:=	GetHelp(CFIELDORI)

        ::MODEL 	:= {CARQUIVO    	,;//ARQUIVO
                        '' 		    	,;//ORDEM
                        CFIELDDES		,;//CAMPO
                        SX3->X3_TIPO	,;//TIPO
                        SX3->X3_TAMANHO	,;//TAMANHO
                        SX3->X3_DECIMAL	,;//DECIMAL
                        SX3->X3_TITULO	,;//TITULO
                        SX3->X3_TITSPA	,;//TITSPA
                        SX3->X3_TITENG  ,;//TITENG
                        SX3->X3_DESCRIC	,;//DESCRIC
                        SX3->X3_DESCSPA	,;//DESCSPA
                        SX3->X3_DESCENG ,;//DESCENG
                        SX3->X3_PICTURE ,;//PICTURE
                        SX3->X3_VALID	,;//VALID
                        SX3->X3_USADO	,;//USADO
                        SX3->X3_RELACAO	,;//RELACAO
                        SX3->X3_F3		,;//F3
                        SX3->X3_NIVEL	,;//NIVEL
                        SX3->X3_RESERV	,;//RESERV
                        SX3->X3_CHECK	,;//CHECK
                        SX3->X3_TRIGGER	,;//TRIGGER
                        SX3->X3_PROPRI	,;//PROPRI
                        SX3->X3_BROWSE	,;//BROWSE
                        SX3->X3_VISUAL	,;//VISUAL
                        SX3->X3_CONTEXT	,;//CONTEXT
                        SX3->X3_OBRIGAT	,;//OBRIGAT
                        SX3->X3_VLDUSER	,;//VLDUSER
                        SX3->X3_CBOX	,;//CBOX
                        SX3->X3_CBOXSPA	,;//CBOXSPA
                        SX3->X3_CBOXENG	,;//CBOXENG
                        SX3->X3_PICTVAR	,;//PICTVAR
                        SX3->X3_WHEN	,;//WHEN
                        SX3->X3_INIBRW	,;//INIBRW
                        SX3->X3_GRPSXG	,;//GRPSXG
                        SX3->X3_FOLDER	,;//FOLDER
                        SX3->X3_PYME	,;//PYME
                        SX3->X3_CONDSQL	,;//CONDSQL
                        SX3->X3_CHKSQL	,;//CHKSQL
                        SX3->X3_IDXSRV	,;//IDXSRV
                        SX3->X3_ORTOGRA	,;//ORTOGRA
                        SX3->X3_IDXFLD	,;//IDXFLD
                        SX3->X3_TELA	,;//TELA
                        SX3->X3_AGRUP	,;//AGRUP
                        cHelp			} //HELP

        AADD(::MODELS, ::MODEL)						  			  	//REGISTRA O MODELO NA LISTA DE MODELOS
    ELSE
        CONOUT("ATENCAO: Não pois possível criar o campo: " + CFIELDDES + ", pois o campo: " + CFIELDORI + " não existe no dicionário SX3!")
        ::OLOG:LOG("ATENCAO: Não pois possível criar o campo: " + CFIELDDES + ", pois o campo: " + CFIELDORI + " não existe no dicionário SX3!")
    ENDIF

RETURN

/*/{Protheus.doc} ADD
@description Adiciona um novo campo ao modelo

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD ADD(CALIAS) CLASS UPDSX3

    ::MODEL := { CALIAS ,;//ARQUIVO
    ''   ,;//ORDEM
    ''	  ,;//CAMPO
    ''	  ,;//TIPO
    0	  ,;//TAMANHO
    0	  ,;//DECIMAL
    ''	  ,;//TITULO
    ''	  ,;//TITSPA
    ''   ,;//TITENG
    ''	  ,;//DESCRIC
    ''	  ,;//DESCSPA
    ''   ,;//DESCENG
    '@!' ,;//PICTURE
    ''	  ,;//VALID
    ''	  ,;//USADO
    ''	  ,;//RELACAO
    ''	  ,;//F3
    1	  ,;//NIVEL
    ''	  ,;//RESERV
    ''	  ,;//CHECK
    'N'  ,;//TRIGGER
    'U'  ,;//PROPRI
    'S'  ,;//BROWSE
    'A'  ,;//VISUAL
    'R'  ,;//CONTEXT
    ''	  ,;//OBRIGAT
    ''	  ,;//VLDUSER
    ''	  ,;//CBOX
    ''	  ,;//CBOXSPA
    ''	  ,;//CBOXENG
    ''	  ,;//PICTVAR
    ''	  ,;//WHEN
    ''	  ,;//INIBRW
    ''	  ,;//GRPSXG
    ''	  ,;//FOLDER
    'S'  ,;//PYME
    ''	  ,;//CONDSQL
    ''	  ,;//CHKSQL
    'N'  ,;//IDXSRV
    'N'  ,;//ORTOGRA
    'N'  ,;//IDXFLD
    ''	  ,;//TELA
    ''	  ,;//AGRUP
    ''	  } //HELP


    AADD(::MODELS, ::MODEL)						  			  	//REGISTRA O MODELO NA LISTA DE MODELOS

RETURN


/*/{Protheus.doc} S
@description Seta o valor do atributo

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD S(ATTR, VALOR) CLASS UPDSX3

    LOCAL nI := ASCAN(::_STRUCT, ATTR)

    IF nI = 0
        ::OLOG:LOG("ATENCAO: Não foi possível configurar o atributo: "+ATTR+"!")
    ELSE
        ::MODEL[nI] := VALOR
    ENDIF

RETURN


/*/{Protheus.doc} CONFIRM
@description Grava o campos adicionados via add na tabela SX3

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD CONFIRM() CLASS UPDSX3

    LOCAL AAREA  := GETAREA()
    LOCAL ATABE  := {}
    LOCAL nI
    LOCAL nJ

    DBSELECTAREA('SX3')
    DBSETORDER(1)

    ::OLOG:LOG("Os seguintes campos foram criados ou atualizados na SX3")

    //PARA CADA CAMPO
    FOR nI := 1 TO LEN(::MODELS)

        ::OLOG:LOG("CAMPO ["+::MODELS[nI][3]+"]")

        CORDEM := ::REMOVE(::MODELS[nI][1],::MODELS[nI][3], .F.) //ALIAS, CAMPO

        SX3->(dbAppend())

        SX3->X3_ARQUIVO 	:=  ::MODELS[nI][1]
        SX3->X3_ORDEM   	:=  CORDEM
        SX3->X3_CAMPO   	:=  ::MODELS[nI][3]
        SX3->X3_TIPO    	:=  ::MODELS[nI][4]
        SX3->X3_TAMANHO 	:=  ::MODELS[nI][5]
        SX3->X3_DECIMAL 	:=  ::MODELS[nI][6]
        SX3->X3_TITULO  	:=  ::MODELS[nI][7]
        SX3->X3_TITSPA  	:=  ::MODELS[nI][8]
        SX3->X3_TITENG  	:=  ::MODELS[nI][9]
        SX3->X3_DESCRIC 	:=  ::MODELS[nI][10]
        SX3->X3_DESCSPA 	:=  ::MODELS[nI][11]
        SX3->X3_DESCENG 	:=  ::MODELS[nI][12]
        SX3->X3_PICTURE 	:=  ::MODELS[nI][13]
        SX3->X3_VALID   	:=  ::MODELS[nI][14]
        SX3->X3_USADO   	:=  ::MODELS[nI][15]
        SX3->X3_RELACAO 	:=  ::MODELS[nI][16]
        SX3->X3_F3 	    	:=  ::MODELS[nI][17]
        SX3->X3_NIVEL   	:=  ::MODELS[nI][18]
        SX3->X3_RESERV  	:=  ::MODELS[nI][19]
        SX3->X3_CHECK   	:=  ::MODELS[nI][20]
        SX3->X3_TRIGGER 	:=  ::MODELS[nI][21]
        SX3->X3_PROPRI  	:=  ::MODELS[nI][22]
        SX3->X3_BROWSE  	:=  ::MODELS[nI][23]
        SX3->X3_VISUAL  	:=  ::MODELS[nI][24]
        SX3->X3_CONTEXT 	:=  ::MODELS[nI][25]
        SX3->X3_OBRIGAT 	:=  ::MODELS[nI][26]
        SX3->X3_VLDUSER 	:=  ::MODELS[nI][27]
        SX3->X3_CBOX    	:=  ::MODELS[nI][28]
        SX3->X3_CBOXSPA 	:=  ::MODELS[nI][29]
        SX3->X3_CBOXENG 	:=  ::MODELS[nI][30]
        SX3->X3_PICTVAR 	:=  ::MODELS[nI][31]
        SX3->X3_WHEN    	:=  ::MODELS[nI][32]
        SX3->X3_INIBRW  	:=  ::MODELS[nI][33]
        SX3->X3_GRPSXG  	:=  ::MODELS[nI][34]
        SX3->X3_FOLDER  	:=  ::MODELS[nI][35]
        SX3->X3_PYME    	:=  ::MODELS[nI][36]
        SX3->X3_CONDSQL 	:=  ::MODELS[nI][37]
        SX3->X3_CHKSQL  	:=  ::MODELS[nI][38]
        SX3->X3_IDXSRV  	:=  ::MODELS[nI][39]
        SX3->X3_ORTOGRA 	:=  ::MODELS[nI][40]
        SX3->X3_IDXFLD  	:=  ::MODELS[nI][41]
        SX3->X3_TELA    	:=  ::MODELS[nI][42]
        SX3->X3_AGRUP   	:=  ::MODELS[nI][43]

        SX3->(dbUnLock())

        IF EMPTY(::MODELS[nI][44])
            ::SETHELP(::MODELS[nI][3], OemToAnsi(::MODELS[nI][10]))
        ELSE
            ::SETHELP(::MODELS[nI][3], OemToAnsi(::MODELS[nI][44]))
        ENDIF

        IF .NOT. ASCAN(ATABE,{|ATBL| ATBL = ::MODELS[nI][1]}) > 0
            AADD(ATABE, ::MODELS[nI][1])
        ENDIF

    NEXT

    FOR nJ := 1 TO LEN(ATABE)
        ::UPDTABLE(ATABE[nJ])
    NEXT

    ::OLOG:LINE()

    ::MODELS := {}

    RESTAREA(AAREA)

RETURN


/*/{Protheus.doc} REMOVE
@description Remove um campo da SX3 caso ele exista e retorna a ordem do atributo

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD REMOVE(CALIAS, CCAMPO, LATUA) CLASS UPDSX3

    LOCAL BEXISTE := .F.
    LOCAL CORDEM  := "00"
    DEFAULT LATUA := .T.

    DBSELECTAREA("SX3")
    SX3->(DBSETORDER(1))
    SX3->(DBGOTOP())
    SX3->(DBSEEK(AllTrim(CALIAS)))

    If SX3->(Found())
        WHILE .Not. SX3->(EOF()) .and. AllTrim(SX3->X3_ARQUIVO) = AllTrim(CALIAS)
            CORDEM := SX3->X3_ORDEM

            If AllTrim(SX3->X3_CAMPO) == Alltrim(SUBSTR(CCAMPO,1,10))
                BEXISTE:= .T.
                EXIT
            EndIf

            SX3->(DBSkip())
        ENDDO
    EndIf

    //SE O CAMPO EXISTE, ENTÃƒO DELETA O CAMPO E RETORNA ORDEM
    //SENÃƒO, RETORNA A ULTIMA ORDEM + 1
    IF BEXISTE
        IF SX3->(RLOCK())
            SX3->(DBDELETE())
            SX3->(MSUNLOCK())

            IF LATUA
                ::UPDTABLE(CALIAS)
            ENDIF
        ENDIF
    ELSE
        CORDEM := Soma1(CORDEM)
    ENDIF

RETURN CORDEM


/*/{Protheus.doc} ADDFILIAL
@description ADICIONA UM CAMPO DO TITULO FILIAL NO ALIAS

@author	Fernando Alencar
@since	20/03/2012

/*/
METHOD ADDFILIAL(CALIAS) CLASS UPDSX3

    Local nTam 		:= TAMSX3("A1_FILIAL")[1]
    Local CFILNAME	:= IIF(SUBSTR(CALIAS,1,1) = 'S', SUBSTR(CALIAS,2), CALIAS) + "_FILIAL"

    SX3:ADD(CALIAS)
    SX3:S("CAMPO"	, CFILNAME	)
    SX3:S("TIPO"	, "C"		)
    SX3:S("TAMANHO"	, nTam		)
    SX3:S("DECIMAL"	, 0			)
    SX3:S("PICTURE"	, ""		)
    SX3:S('TITULO'  , 'Filial'  )
    SX3:S('TITSPA'  , 'Sucursal')
    SX3:S('TITENG'  , 'Branch'  )
    SX3:S('DESCRIC' , 'Filial do Sistema')
    SX3:S('DESCSPA' , 'Sucursal del sistema')
    SX3:S('DESCENG' , 'System Branch')
    SX3:SETFILIAL()

RETURN


/*/{Protheus.doc} SETFILIAL
@description Define Campo como Filial

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD SETFILIAL()  CLASS UPDSX3

    SELF:S("USADO", X3_USADO_FILIAL	)
    SELF:S("RESERV", X3_RESERV_FILIAL )

RETURN


/*/{Protheus.doc} ADDMSFIL
@description Adiciona um campo do Tipo MSFIL (Reservado)

@author	Helitom Silva
@since	19/11/2011

/*/
METHOD ADDMSFIL(CALIAS) CLASS UPDSX3

    Local NTAM 		:= TAMSX3("E1_MSFIL")[1]
    Local CFILNAME	:= IIF(SUBSTR(CALIAS, 1, 1) = 'S', SUBSTR(CALIAS,2), CALIAS) + "_MSFIL"

    SX3:ADD(CALIAS)
    SX3:S("CAMPO"	, CFILNAME	)
    SX3:S("TIPO"	, "C"		)
    SX3:S("TAMANHO"	, NTAM		)
    SX3:S("DECIMAL"	, 0			)
    SX3:S("PICTURE"	, ""		)
    SX3:S("TITULO"	, "Filial Orig."	)
    SX3:S("DESCRIC"	, "Filial de Inclusao"	)
    SX3:SETMSFIL()

RETURN


/*/{Protheus.doc} SETMSFIL
@description Define Campo como MsFil

@author	Helitom Silva
@since	19/11/2011

/*/
METHOD SETMSFIL() CLASS UPDSX3

    If SELF:GETDICBANCO()
        SELF:S("USADO", X3_BUSADO_MSFIL	)
        SELF:S("RESERV", X3_BRESERV_MSFIL )
        SELF:S("OBRIGAT", X3_BOBRIG_MSFIL )
    Else
        SELF:S("USADO", X3_USADO_MSFIL	)
        SELF:S("RESERV", X3_RESERV_MSFIL )
    EndIf

RETURN


/*/{Protheus.doc} SETOPCIONAL
@description Seta o campo para estar disponível na enchoice

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD SETOPCIONAL()  CLASS UPDSX3

    If SELF:GETDICBANCO()
        SELF:S("USADO", X3_BUSADO_OPC	)
        SELF:S("RESERV", X3_BRESERV_OPC )
        SELF:S("OBRIGAT", X3_BOBRIG_OPC )
    Else
        SELF:S("USADO", X3_USADO_OPC )
        SELF:S("RESERV", X3_RESERV_OPC )
    EndIf

RETURN


/*/{Protheus.doc} SETCHAVE
@description Seta o campo para estar disponível na enchoice e ser obrigatorio

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD SETCHAVE()  CLASS UPDSX3

    If SELF:GETDICBANCO()
        SELF:S("USADO", X3_BUSADO_KEY	)
        SELF:S("RESERV", X3_BRESERV_KEY )
        SELF:S("OBRIGAT", X3_BOBRIG_KEY )
    Else
        SELF:S("USADO", X3_USADO_KEY )
        SELF:S("RESERV", X3_RESERV_KEY	)
    EndIf

RETURN


/*/{Protheus.doc} SETOBR
@description Seta o campo para estar disponível na enchoice e ser obrigatório

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD SETOBR()  CLASS UPDSX3

    If SELF:GETDICBANCO()
        SELF:S("USADO", X3_BUSADO_OBR	)
        SELF:S("RESERV", X3_BRESERV_OBR )
        SELF:S("OBRIGAT", X3_BOBRIG_OBR )
    Else
        SELF:S("USADO", X3_USADO_OBR )
        SELF:S("RESERV", X3_RESERV_OBR	)
    EndIf

RETURN


/*/{Protheus.doc} SETNOTUSADO
@description Seta o campo como não disponivel na enchoice

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD SETNAOUSADO()  CLASS UPDSX3

    If SELF:GETDICBANCO()
        SELF:S("USADO", X3_BUSADO_NAO	)
        SELF:S("RESERV", X3_BRESERV_NAO )
        SELF:S("OBRIGAT", X3_BOBRIG_NAO )
    Else
        SELF:S("USADO", X3_USADO_NAO )
        SELF:S("RESERV", X3_RESERV_NAO )
    EndIf

RETURN


/*/{Protheus.doc} GETLOGTXT
@description Retorna o objeto de log

@author	Fernando Alencar
@since	19/11/2011

/*/
METHOD GETLOGTXT()  CLASS UPDSX3
RETURN ::OLOG:LOG()


/*/{Protheus.doc} UPDTABLE
@description Replica no banco as alteracoes feitas na tabela no Dicionario de Dados

@author	Helitom Silva
@since	11/05/2012

/*/
METHOD UPDTABLE(CTABELA) CLASS UPDSX3

    TcInternal( 25, 'CLOB' )
    X31UpdTable( CTABELA )
    If __GetX31Error()
        MsgAlert(__GetX31Trace())
    EndIf
    TcInternal( 25, 'OFF' )

RETURN


/*/{Protheus.doc} SETHELP
@description Replica no banco as alteracoes feitas na tabela no Dicionario de Dados

@author	Fernando Alencar
@since	11/05/2012

/*/
METHOD SETHELP(cCampo, cHelp) CLASS UPDSX3

    Local aHelp := {}

    aAdd( aHelp, SubStr( cHelp,  1 , 40 ) )
    aAdd( aHelp, SubStr( cHelp,  41 , 80 ) )
    aAdd( aHelp, SubStr( cHelp,  81 , 120 ) )
    aAdd( aHelp, SubStr( cHelp,  121 , 160 ) )
    aAdd( aHelp, SubStr( cHelp,  161 , 200 ) )
    aAdd( aHelp, SubStr( cHelp,  201 , 240 ) )

    PutHelp( "P" + cCampo, aHelp, aHelp, aHelp, .T. )


RETURN


/*/{Protheus.doc} REMOVE
@description Remove um campo da SX3 caso ele exista e retorna a ordem do atributo

@author	Helitom Silva
@since	04/10/2012

/*/
METHOD REMOVEALL(CALIAS, LATUA) CLASS UPDSX3

    LOCAL BEXISTE := .F.

    DEFAULT LATUA := .T.

    DBSELECTAREA("SX3")
    SX3->(DBSETORDER(1))
    SX3->(DBGOTOP())
    SX3->(DBSEEK(AllTrim(CALIAS)))

    IF Found()
        WHILE .Not. SX3->(EOF()) .and. AllTrim(SX3->X3_ARQUIVO) = AllTrim(CALIAS)
            IF SX3->(RLOCK())
                SX3->(DBDELETE())
                SX3->(MSUNLOCK())
            ENDIF

            SX3->(DBSkip())
        ENDDO
        BEXISTE := .T.
    ENDIF

    IF BEXISTE
        IF LATUA
            ::UPDTABLE(CALIAS)
        ENDIF
    ENDIF

RETURN


/*/{Protheus.doc} SETORDEM
@description Modifica a ordem de um campo da SX3

@author	Geanderson S. Silva
@since	23/07/2014

/*/
METHOD SETORDEM( CALIAS, CCAMPO, CNOVORD ) CLASS UPDSX3

    LOCAL 	LATUA 	:= .F.
    LOCAL 	CCPOTMP	:= ""
    LOCAL	CCPOANT	:= ""
    LOCAL 	ACAMPOS	:= {}
    LOCAL   CPOSTMP	:= ""
    LOCAL   CPOSATU	:= ""
    LOCAL   CORDATU	:= ""
    LOCAL   NFILTRO	:= 0
    LOCAL   NX, NY	:= 0

    DEFAULT CALIAS 	:= ""
    DEFAULT CCAMPO	:= ""
    DEFAULT CNOVORD	:= ""

    IF LEN(CNOVORD) < 2

        CNOVORD := STRZERO(VAL(CNOVORD),2)

    ENDIF

    DBSELECTAREA("SX3")
    SX3->(DBSETORDER(2))
    SX3->(DBGOTOP())
    IF SX3->(DBSEEK(CCAMPO))

        CORDATU := SX3->X3_ORDEM

        IF CNOVORD = CORDATU

            RETURN

        ENDIF

    ELSE

        RETURN

    ENDIF

    SX3->(DBSETORDER(1))
    SX3->(DBGOTOP())
    IF !SX3->( DBSEEK( AllTrim(CALIAS) + CNOVORD ) )

        SX3->(DBSETORDER(2))
        SX3->(DBGOTOP())

        IF SX3->(DBSEEK(CCAMPO))

            SX3->(RLOCK())
            SX3->X3_ORDEM 	:= CNOVORD
            LATUA 			:= .T.
            SX3->(MSUNLOCK())

        ENDIF

    ELSE

        IF VAL(CORDATU) < VAL(CNOVORD)

            NFILTRO := 1

        ELSE

            NFILTRO := 2

        ENDIF

        SX3->(DBSETORDER(1))
        SX3->(DBGOTOP())
        IF SX3->(DBSEEK(AllTrim(CALIAS)))

            WHILE .Not. SX3->(EOF()) .and. AllTrim(SX3->X3_ARQUIVO) = AllTrim(CALIAS)

                If Val(SX3->X3_ORDEM) == Val(CNOVORD) .AND. SX3->X3_RESERV = X3_RES

                    CNOVORD	:= Soma1(CNOVORD)

                ENDIF

                If NFILTRO = 1 .AND. Val(SX3->X3_ORDEM) <= Val(CNOVORD)

                    AADD( ACAMPOS, { SX3->X3_CAMPO, SX3->X3_ORDEM, SX3->X3_RESERV = X3_RES, } )

                ELSEIF NFILTRO = 2 .AND. Val(SX3->X3_ORDEM) >= Val(CNOVORD)

                    AADD( ACAMPOS, { SX3->X3_CAMPO, SX3->X3_ORDEM, SX3->X3_RESERV = X3_RES, } )

                EndIf

                SX3->(DBSkip())

            ENDDO

        ENDIF

        FOR NX := 1 TO LEN(ACAMPOS)

            CCPOTMP := ACAMPOS[NX][1]
            CPOSTMP := ACAMPOS[NX][2]

            IF ACAMPOS[NX][3]

                IF	ACAMPOS[NX][2] = CNOVORD

                    CNOVORD 		:= Soma1(CNOVORD)

                ENDIF

                IF NFILTRO = 2

                    ACAMPOS[NX][4] 	:= ACAMPOS[NX][2]

                ENDIF

                LOOP

            ENDIF

            IF NFILTRO = 1

                IF ACAMPOS[NX][1] = CCAMPO

                    SX3->(DBSETORDER(2))
                    SX3->(DBGOTOP())

                    IF SX3->(DBSEEK(CCAMPO))

                        SX3->(RLOCK())
                        SX3->X3_ORDEM 	:= CNOVORD
                        LATUA 			:= .T.
                        SX3->(MSUNLOCK())

                    ENDIF

                ENDIF

            ELSEIF NFILTRO = 2

                IF ACAMPOS[NX][2] = CNOVORD .AND. Empty(ACAMPOS[NX][4])

                    SX3->(DBSETORDER(2))
                    SX3->(DBGOTOP())
                    IF SX3->(DBSEEK(CCAMPO))

                        SX3->(RLOCK())
                        SX3->X3_ORDEM 	:= CNOVORD
                        ACAMPOS[NX][4] 	:= CNOVORD
                        LATUA 			:= .T.
                        SX3->(MSUNLOCK())
                        CCPOANT				:= ACAMPOS[NX][1]
                        CPOSATU				:= ACAMPOS[NX][2]
                        LOOP
                    ENDIF

                ELSEIF !ACAMPOS[NX][3] .AND. !Empty(CCPOANT)

                    SX3->(DBSETORDER(2))
                    SX3->(DBGOTOP())
                    IF SX3->(DBSEEK(CCPOANT))

                        SX3->(RLOCK())
                        SX3->X3_ORDEM 	:= ACAMPOS[NX][2]
                        ACAMPOS[NX][4] 	:= CPOSATU
                        SX3->(MSUNLOCK())
                        CCPOANT		:= ""
                        CPOSATU		:= ""

                    ENDIF

                ENDIF

            ENDIF

            FOR NY := 1 TO LEN(ACAMPOS)

                IF NFILTRO = 1

                    CCPOTMP := ACAMPOS[NY][1]

                    IF !ACAMPOS[NY][3]

                        SX3->(DBSETORDER(2))
                        SX3->(DBGOTOP())
                        IF SX3->(DBSEEK(CCPOTMP)) .AND. ( Alltrim(CCAMPO) <> Alltrim(CCPOTMP) ) .AND. Empty(ACAMPOS[NY][4])

                            ACAMPOS[NY][4]		:= SX3->X3_ORDEM
                            SX3->(RLOCK())
                            SX3->X3_ORDEM 	:= CPOSTMP
                            SX3->(MSUNLOCK())
                            Exit

                        ENDIF

                    ENDIF

                ELSEIF NFILTRO = 2

                    IF !ACAMPOS[NY][3] .AND. Empty(ACAMPOS[NY][4])

                        SX3->(DBSETORDER(2))
                        SX3->(DBGOTOP())
                        IF SX3->(DBSEEK(CCPOTMP)) .AND. ( Alltrim(CCAMPO) <> Alltrim(CCPOTMP) )

                            SX3->(RLOCK())
                            SX3->X3_ORDEM 	:= ACAMPOS[NY][2]
                            SX3->(MSUNLOCK())
                            CPOSTMP	:= ACAMPOS[NY][2]
                            CCPOTMP	:= ACAMPOS[NY][1]

                        ENDIF

                        ACAMPOS[NY][4] 	:= CPOSTMP

                    ENDIF

                ENDIF

            NEXT

        NEXT

    ENDIF

RETURN

/*/{Protheus.doc} UPDSX3::SETDICBANCO
@description Define se o dicionário está no banco de dados
@type method
@version  
@author Helitom Silva
@since 04/05/2023
@param p_lDicBanco, Logico, Se o dicionario estiver no banco de dados informar .T. caso contrario .F.
@return variant, return_description
/*/
METHOD SETDICBANCO(p_lDicBanco) CLASS UPDSX3

    Default p_lDicBanco := .F.

    Self:lDicBanco := p_lDicBanco

RETURN


/*/{Protheus.doc} UPDSX3::GETDICBANCO
@description Define se o dicionário está no banco de dados
@type method
@version  
@author Helitom Silva
@since 04/05/2023
@return lDicBanco, Logico, Se o dicionario estiver no banco de dados retorna .T. caso contrario .F.
/*/
METHOD GETDICBANCO() CLASS UPDSX3
RETURN Self:lDicBanco
