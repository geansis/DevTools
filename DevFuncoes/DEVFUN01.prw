#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "AP5MAIL.CH"

#DEFINE	CR	Chr(13) + Chr(10)

Static __nHdlSMTP := 0

/*/{Protheus.doc} DEFFUN01   
@description Funcao para envio de email

@author  Julio Storino
@since   17/04/2012
@version 1.0 - JGOMAIL

@author  Helitom Silva
@since   30/09/2014
@version 2.0 - Revisado e reorganizado para o projeto

@param p_cMail, Caracter, String com o ou os e-mails dos destinatarios, pode ser informado com , ou ; separando-os.                                                                         
@param p_cSubject, Caracter, Assunto do e-mail.                                                                                          
@param p_cBody, Caracter, Texto do e-mail, aceita HTML.                                                                                  
@param p_cError, Caracter, Variavel recebida por referencia que contera os  possiveis erros durante a operacao, deve ser  tratada no retorno da funcao de onde foi chamada. Se retornar vazio e porque nao houve erros.                                                                     
@param p_cInfo, Caracter, Variavel recebida por referencia que contera informacoes detalhadas sobre a operacao de envio. deve ser tratada no retorno da funcao de onde foi chamada. Retorno vazio nao houve informacoes.      
@param p_aAnexo, Array, Array contendo os anexos na forma do caminho onde se encontram, podemdo ser o caminho absoluto ou o caminho relativo no server a partir da pasta protheus_data.                                     
@param p_aPars, Array, Array com os parametros de conexao ao servidor de email para envio, conforme a seguinte estrutura:    
                                                                       
@obs Dados do parametro p_aPars:
   
	 01 - Boolean Indica se usa SSL                      
     02 - Boolean Indica se usa TSL                      
     03 - Boolean Indica se precisa autenticacao SMTP    
     04 - Texto Endereco do servidor POP3                
     05 - Texto Endereco do servidor SMTP                
     06 - Numerico Porta do servidor POP                 
     07 - Numerico Porta do servidor SMTP                
     08 - Texto Usuario que ira realizar a autenticacao  
     09 - Texto Senha do usuario de autenticacao         
     10 - Texto Usuario que envia o e-mail               
     11 - Numerico Timeout SMTP                          
                                                         
     Se for passado vazio, os seguintes parametros serao 
     utilizados.                                         
                                                         
     MV_RELSSL	01 - Indica se usa SSL             
     MV_RELTLS	02 - Indica se usa TSL             
     MV_RELAUTH	03 - Indica se precisa autentic. SMTP  
     ""			04 - Endereco do servidor POP3     
     MV_RELSERV	05 - Endereco do servidor SMTP         
     MV_RELPOP2	06 - Porta do servidor POP             
     MV_RELSMPT	07 - Porta do servidor SMTP            
     MV_RELAUSR	08 - Usuario de autenticacao           
     MV_RELPSW	09 - Senha de autenticacao         
     MV_RELACNT	10 - Usuario que envia o e-mail        
     60    		11 - Timeout SMTP  

/*/
User function DEVFUN01(p_cMail, p_cSubject, p_cBody, p_cError, p_cInfo, p_aAnexo, p_aPars, p_oServer)

	//Local p_oServer  	:= Nil
	Local oMessage 		:= Nil
	Local cTic			:= ""
	Local cInfoTmp		:= ""
	Local nRet			:= 0
	Local nErr     		:= 0
	Local aMail			:= {}
	Local cEMail		:= ""
	Local cEmailTmp		:= ""
	Local cEmailOri		:= ""
	Local lEmailOK		:= .T.

	Local _nI, _nZ		:= 0

	Local _lUsaSSL		:= .T.
	Local _lUsaTLS		:= .T.
	Local _lSMTPAuth	:= .T.
	Local cPopAddr  	:= ""
	Local cSMTPAddr 	:= ""
	Local nPOPPort  	:= 0
	Local nSMTPPort 	:= 0
	Local cLogin     	:= ""
	Local cPass     	:= ""
	Local cFrom			:= ""
	Local nSMTPTime 	:= 0

	Default p_cMail		:= ""
	Default p_cSubject	:= "Sem assunto"
	Default p_cBody		:= "NiHil"
	Default p_cError	:= ""
	Default p_cInfo		:= ""
	Default p_aAnexo	:= {}

	If Empty(p_aPars)
		p_aPars 	:= {}
		aAdd( p_aPars , GetNewPar("MV_RELSSL"	, .T.) 									)	/* 01 - Indica se usa SSL */
		aAdd( p_aPars , GetNewPar("MV_RELTLS"	, .T.) 									)	/* 02 - Indica se usa TSL */
		aAdd( p_aPars , GetNewPar("MV_RELAUTH"	,.T.) 									)	/* 03 - Indica se precisa fazer autenticacao SMTP */
		aAdd( p_aPars , ""		  							 							)	/* 04 - Endereco do servidor POP3 */
		aAdd( p_aPars , GetNewPar("MV_RELSERV"	, "smtp.gmail.com") 					)   /* 05 - Endereco do servidor SMTP */
		aAdd( p_aPars , GetNewPar("MV_RELPOP3"	, 00)	  	 						   	)	/* 06 - Porta do servidor POP */
		aAdd( p_aPars , GetNewPar("MV_RELSMTP"	, 25)			             	   		)	/* 07 - Porta do servidor SMTP */
		aAdd( p_aPars , GetNewPar("MV_RELAUSR"	, "relatorio@relatorio.com.br") 		) 	/* 08 - Usuario que ira realizar a autenticacao */
		aAdd( p_aPars , GetNewPar("MV_RELPSW"	, "protheus")  						 	)	/* 09 - Senha do usuario de autenticacao */
		aAdd( p_aPars , GetNewPar("MV_RELACNT"	, "relatorio@relatorio.com.br") 		)	/* 10 - Usuario que envia o e-mail */
		aAdd( p_aPars , 60         		  												)	/* 11 - Timeout SMTP */
	EndIf

	_lUsaSSL		:= p_aPars[01]	 														/* 01 - Indica se usa SSL */
	_lUsaTLS		:= p_aPars[02] 															/* 02 - Indica se usa TSL */
	_lSMTPAuth	:= p_aPars[03]																/* 03 - Indica se precisa fazer autenticacao SMTP */
	cPopAddr  	:= p_aPars[04]		  														/* 04 - Endereco do servidor POP3 */
	cSMTPAddr 	:= p_aPars[05]   		  													/* 05 - Endereco do servidor SMTP */
	nPOPPort  	:= p_aPars[06]			  													/* 06 - Porta do servidor POP */
	nSMTPPort 	:= p_aPars[07]        		  												/* 07 - Porta do servidor SMTP */
	cLogin     	:= p_aPars[08] 																/* 08 - Usuario que ira realizar a autenticacao */
	cPass     	:= p_aPars[09] 						  										/* 09 - Senha do usuario de autenticacao */
	cFrom			:= p_aPars[10]															/* 10 - Usuario que envia o e-mail */
	nSMTPTime 	:= p_aPars[11]         		  												/* 11 - Timeout SMTP */

	/*Trata caso o paramentro p_cMail venha como Array ! */
	If ValType(p_cMail) = "A"
		For _nI := 1 To Len(p_cMail)
			cEmailTmp += p_cMail[_nI] + ';'
		Next _nI
		p_cMail := cEmailTmp
		cEmailTmp := ""
	EndIf

	/*Prepara uma array com os e-mail (caso tenham vindo com separador , ou ; Troca possiveis , por ; - padronizacao de separacao de e-mails */
	p_cMail := StrTran(p_cMail,',',';')
	aMail   := StrToKArr(p_cMail, ';') //U_LINCOL(p_cMail,';')

	/*Prepara os destinatarios. */
	For _nI := 1 To Len(aMail)

		/*Guardo e-mail original para Log */
		cEMailOri += aMail[_nI] + If(_nI < Len(aMail),',','')

  		/*Tento ajustar algumas coisas comuns ao informar um e-mail */
		cEmailTmp := Lower(aMail[_nI])

		If U_MailOK( @cEmailTmp , @cInfoTmp )
			cEMail += cEmailTmp + If(_nI < Len(aMail),',','')
		EndIf

	Next _nI

	/* Complementa o erro com mais informacoes */
	cTic += "-------------------------------------------------" + CR
	cTic += "[LOGIN    ]-" + cLogin + CR
	cTic += "[PASS     ]-" + cPass + CR
	cTic += "[FROM     ]-" + cFrom + CR
	cTic += "[TO_ORI   ]-" + cEmailOri + CR
	cTic += "[TO_OK    ]-" + cEmail + CR
	cTic += "[SUBJECT  ]-" + p_cSubject + CR
	cTic += "[SMTPADDR ]-" + cSMTPAddr + CR
	cTic += "[USASSL   ]-" + If(_lUsaSSL,'SIM','NAO') + CR
	cTic += "[USATLS   ]-" + If(_lUsaTLS,'SIM','NAO') + CR
	cTic += "[USAAUTH  ]-" + If(_lSMTPAuth,'SIM','NAO') + CR

	/* Verifica se houve pelo menos 1 e-mail valido para envio ou tudo que veio eh invalido */
	If Empty(cEmail)		/* Tudo Invaliado */
		p_cInfo += "[ERROR]Email(s) informado(s) invalido(s)!" + CR
		p_cInfo += cInfoTmp + CR + CR + cTic
		Return( Nil )
	Else
		p_cInfo += "Para o(s) destinatario(s) abaixo, o email foi enviado corretamente !" + CR + Space(10) + cEmail + CR + CR
	
		If !Empty(cInfoTmp)
			p_cInfo +=	"Para o(s) destinatario(s) abaixo, nao foi possivel enviar !" + CR + Space(10) + p_cInfo
		EndIf
	EndIf

	If Empty(p_oServer)

		/* Instancia um novo TMailManager */
		p_oServer := tMailManager():New()

		/* Usa SSL na conexao */
		If	_lUsaSSL
			p_oServer:SetUseSSL(.T.)
		Else
			p_oServer:SetUseSSL(.F.)
		EndIf

		/* Usa TLS na conexao */
		If	_lUsaTLS
			p_oServer:SetUseTLS(.T.)
		Else
			p_oServer:SetUseTLS(.F.)
		EndIf
	
		/* Inicializa */
		p_oServer:init(cPopAddr, cSMTPAddr, cLogin, cPass, nPOPPort, nSMTPPort)
	
		/* Define o Timeout SMTP */
		if p_oServer:SetSMTPTimeout(nSMTPTime) != 0
			p_cError += "[ERROR]Falha ao definir timeout"
			p_cError += CR + CR + cTic
			Return( Nil )
		endif
	
		/* Conecta ao servidor */
		nErr := p_oServer:smtpConnect()
		If nErr <> 0
			p_cError += "[ERROR]" + p_oServer:getErrorString(nErr)
			p_cError += CR + CR + cTic
			p_oServer:smtpDisconnect()
			Return( Nil )
		EndIf
	
		If _lSMTPAuth
			nRet := p_oServer:SMTPAuth(cLogin, cPass)
			If nRet <> 0
				nRet := p_oServer:SMTPAuth(cFrom, cPass)
				If nRet != 0
					p_cError += "[ERROR]Falha na autenticação SMTP"
					p_cError += CR + CR + cTic
					Return( Nil )
				Endif
			Endif
		EndIf

	EndIf

	/* Cria uma nova mensagem (TMailMessage) */
	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom    := cFrom
	oMessage:cTo      := cEMail
	//	oMessage:cCC      := _cCC
	oMessage:p_cSubject := p_cSubject
	oMessage:p_cBody    := p_cBody

	/* Anexa arquivos */
	For _nI := 1 To Len(p_aAnexo)
		If oMessage:AttachFile( p_aAnexo[_nI] ) < 0
			p_cError += "[ERROR]Erro ao atachar o arquivo"
			p_cError += CR + CR + cTic
			Return
		Else
			oMessage:AddAtthTag( "Content-Disposition: attachment; filename=" + Substr(p_aAnexo[_nI],RAt("\",p_aAnexo[_nI])+1) )
		EndIf
	Next _nI

	/* Envia a mensagem */
	nErr := oMessage:send(p_oServer)

	If nErr <> 0
		p_cError += '[ERROR]' + p_oServer:getErrorString(nErr)
		p_cError += CR + CR + cTic
		//p_oServer:smtpDisconnect()
		//p_oServer := Nil
		Return
	EndIf

	/* Disconecta do Servidor */
	//p_oServer:smtpDisconnect()

Return