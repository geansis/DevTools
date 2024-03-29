#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
           
           
/*/{Protheus.doc} FCONECT
@description Abre uma conex�o com o banco sem consumir conex�o

@author  Ricardo Tomasi
@author  Kivson Maciel
@author  Fernando Alencar
@version P11 e P10
@since   15/09/2011

@param	 cCodEmp, Caracter, codigo da empresa Opcional
@param 	 cCodFil, Caracter, codigo da filial Opcional

/*/
User Function FCONECT(cCodEmp, cCodFil)
   
	Local cTipo      := ""
	Local cBanco     := ""
	Local cServer    := ""
	Local cServerIni := ""
	
	Default cCodEmp := "99"
	Default cCodFil := "01"
	
	Static nHndTcp  := -1  
	
	/* Atende protheus 11 */
	cServerIni := "appserver.ini"

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "TopConnect", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "TopConnect", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "TopConnect", "Server"  , "", cServerIni )
	EndIf                                      

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "DBAccess", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "DBAccess", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "DBAccess", "Server"  , "", cServerIni )
	EndIf


	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetSrvProfString( "TopDatabase", "" )
		cBanco  := GetSrvProfString( "TopAlias"   , "" )
		cServer := GetSrvProfString( "TopServer"  , "" )
	EndIf  
	
	/* Atende protheus 10 */
	cServerIni := "totvsappserver.ini"

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "TopConnect", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "TopConnect", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "TopConnect", "Server"  , "", cServerIni )
	EndIf                                      

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "DBAccess", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "DBAccess", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "DBAccess", "Server"  , "", cServerIni )
	EndIf


	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetSrvProfString( "TopDatabase", "" )
		cBanco  := GetSrvProfString( "TopAlias"   , "" )
		cServer := GetSrvProfString( "TopServer"  , "" )
	EndIf  


	nHndTcp := TcLink( cTipo+"/"+cBanco,cServer,7890)

	If nHndTcp < 0 
		UserException("Erro ("+Substr(Str(nHndTcp),1,4)+") ao conectar...")
	EndIf

	Set deleted off
	
	#IFDEF TOP
	    TCInternal( 5, '*OFF' ) /* Desliga Refresh no Lock do Top */
	#ENDIF
	 
	RpcSetType( 2 )
	RpcSetEnv( cCodEmp, cCodFil )

Return .T.