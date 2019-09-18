#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDLOG

	Ferramenta de LOG
	
	@author		fernando.alencar
	@data			11 de outubro de 2011
	@method		{create} 	cria um novo objeto
	@method 		{LINE} 	imprime uma linha no log 	
	@method 		{SAVE} 	
	@method		{SETPATH}	
*/
CLASS UPDLOG 
                
	DATA CLOG
	DATA PATH
	
	METHOD CREATE() CONSTRUCTOR
	METHOD LOG()
	METHOD LINE()
    METHOD SAVE()
	METHOD SETPATH()
	
ENDCLASS           

METHOD CREATE(CLOG) CLASS UPDLOG                  
	IF CLOG == NIL .OR. VALTYPE(CLOG) != 'C'
		::CLOG := ""
	ELSE 
		::CLOG := CLOG
	ENDIF
RETURN ::SELF   

METHOD LOG(MSG) CLASS UPDLOG
	IF MSG == NIL .OR. EMPTY(MSG)
		RETURN ::CLOG
	ENDIF
	CONOUT(MSG)//ENVIA PARA O LOG DO APPSERVER
	::CLOG += MSG + CRLF
RETURN ::CLOG           

METHOD LINE() CLASS UPDLOG  
	::CLOG += REPLICATE( '-', 128 ) + CRLF
RETURN ::CLOG

METHOD SETPATH(PATH) CLASS UPDLOG 
    ::PATH := PATH
RETURN NIL

METHOD SAVE() CLASS UPDLOG 
	MEMOWRITE(::PATH, ::CLOG)
RETURN .F.