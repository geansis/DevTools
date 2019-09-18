#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "SMXFUN.CH"	
#INCLUDE "SDIC.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ISAMQRY.CH"


/*/{Protheus.doc} DevFuncoes
@description Neste arquivo sao armazenadas funcoes genericas

@author Helitom Silva
@since  05/06/2012

/*/


/*/{Protheus.doc} HSoNumeros
@description Avaliação se uma string tenha apenas numeros

@author Helitom Silva
@since  05/06/2012

@param p_cString, Caracter, String a ser avaliada.

@return lRet, Logico, Se a string contem apenas numeros retorna .T.

/*/
User Function HSoNumeros(p_cString, p_lAlert)

	Local lRet := .t.
	Local nX   := 0

	Default p_cString := ""
	Default p_lAlert  := .T.

	p_cString := AllTrim(p_cString)

	If .Not. Empty(p_cString)
		For nX := 1 to Len(p_cString)
			If ! Substr(p_cString, nX, 1) $ '0123456789'
				lRet := .f.
				 
				If p_lAlert	
					MsgAlert('Informação invalida, por favor, informe apenas números!')
				EndIf
               
				Return lRet
				
			EndIf
		Next
	EndIf

Return lRet


/*/{Protheus.doc} HSeleArq
@description Retorna um caminho do arquivo selecionado ou para ser salvo.

@author Helitom Silva
@since  05/06/2012

@param p_cTitulo, Caracter, Titulo da janela.
@param p_cMasc, Caracter, Mascara para aparecer apenas arquivo com extencao especifica. Exemplo: Arquivos csv (*.csv) |*.csv| ou "Arquivos Texto (*.TXT) |*.txt|
@param p_lSalva, Logico, Se .T. mostra botao de salvar senao mostra botao de abrir para selecionar o arquivo.

@return cRet, Caracter, Caminho do arquivo selecionado ou salvo

/*/
User Function HSeleArq(p_cTitulo, p_cMasc, p_lSalva)

	Local cRet := ""

	Default p_cMasc  := "Arquivos Texto (*.TXT) |*.txt|"
	Default p_lSalva := .f.

	/* Declaração de Variaveis Private dos Objetos */
	SetPrvt("oDlg1","oPanel1","oSay1","oGet1","oSBtn1","oBtn1")

	/* Definicao do Dialog e todos os seus componentes */
	oDlg1      := MSDialog():New( 091,232,161,694,p_cTitulo,,,.F.,,,,,,.T.,,,.T. )
	oPanel1    := TPanel():New( 000,000,"",oDlg1,,.F.,.F.,,,226,029,.T.,.F. )

	oSay1      := TSay():New( 004,004,{||"Informe o Caminho do Arquivo"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oGet1      := TGet():New( 012,004,{|u| If(PCount()>0,cRet:=u,cRet)},oPanel1,144,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

	oSBtn1     := SButton():New( 011,152,iif(p_lSalva,13,14),{|| (cRet:=cGetFile(p_cMasc,""),oGet1:Refresh())},oPanel1,,"", )
	oBtn1      := TButton():New( 011,188,"OK",oPanel1,{|| oDlg1:End()},030,011,,,,.T.,,"",,,,.F. )

	oDlg1:Activate(,,,.T.)

Return cRet


/*/{Protheus.doc} _C
@description Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario.

@author Norbert/Ernani/Mansano
@since  10/05/2005

@param p_nTam, Numerico, Tamanho/Posição a ser refeita.

/*/
Static Function _C(p_nTam)

	Local nHResH	:=	oMainWnd:nClientWidth	/* Resolucao horizontal do monitor */
	Local nHResV	:=	oMainWnd:nClientHeight	/* Resolucao vertical   do monitor */

	If (nHResH == 776)	/* Resolucao 800x600 */
		p_nTam *= 0.68
	ElseIf (nHResH == 1000)	/* Resolucao 1024x768 */
		p_nTam *= 0.89
	ElseIf (nHResH == 1128)	/* Resolucao 1152x864 */
		p_nTam *= 1
	ElseIf (nHResH == 1256 .And. nHResV == 453)	/* Resolucao 1280x600 */
		p_nTam *= 0.68
	ElseIf (nHResH == 1256 .And. nHResV == 573)	/* Resolucao 1280x720 */
		p_nTam *= 0.88
	ElseIf (nHResH == 1256 .And. nHResV == 621)	/* Resolucao 1280x768 */
		p_nTam *= 0.96
	ElseIf (nHResH == 1256 .And. nHResV == 813)	/* Resolucao 1280x960 */
		p_nTam *= 1
	Else	/* Resolucao 1280x1024 */
		p_nTam *= 1
	EndIf

	/* ³Tratamento para tema "Flat" */
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			p_nTam *= 0.90
		EndIf
	EndIf
	
Return Int(p_nTam)


/*/{Protheus.doc} ADVParSQL
@description Retorna um filtro SQL, baseado em instrução de filtro ADVPL

@author Helitom Silva
@since  21/08/2012

@param p_cFilADV, Caracter, String com Filtro de sintaxe ADVPL

@return cRet, Caracter, String com filtro de Sintaxe SQL

/*/
User Function ADVParSQL(p_cFilADV)
	
	Local cRet := p_cFilADV
	
	cRet := StrTran(Upper(cRet)	,".AND."  ," AND ")
	cRet := StrTran(Upper(cRet)	,".OR."   ," OR ")
	cRet := StrTran(cRet       	,"=="     ," = ")
	cRet := StrTran(cRet       	,"!="     ,"<>")
	cRet := StrTran(cRet       	,'"'      ,"'")
	cRet := StrTran(Upper(cRet)	,"ALLTRIM"," ")
	cRet := StrTran(cRet       	,'$'      ," IN ")
	cRet := StrTran(Upper(cRet)	,"DTOS"   ,"")
	cRet := StrTran(cRet		,"->"     ,".")
	
Return cRet


/*/{Protheus.doc} HDataExt
@description Retorna Data por extenso

@author Helitom Silva
@since  21/07/2013

@param p_dData, Data, Informação no formato data

@return cDataExt, Caracter, Data por extenso

/*/
User Function HDataExt(p_dData)

	Local cData 	  := DtoS(p_dData)	
	Local cDataExt   := ''	
	Local cDia 	  	  := ''
	Local cMes 	  	  := ''
	Local cAno 	  	  := ''
	Local nMes 	  	  := 0
		
	cDia := Extenso(Val(SubStr(cData, 7, 2)), .t.)
	nMes := Val(SubStr(cData, 5, 2))
	cAno := Extenso(Val(SubStr(cData, 1, 4)), .t.)	

	Do Case
		Case nMes == 1
			cMes := "Janeiro"
		Case nMes == 2
			cMes := "Fevereiro"
		Case nMes == 3
			cMes := "Março"
		Case nMes == 4
			cMes := "Abril"
		Case nMes == 5
			cMes := "Maio"
		Case nMes == 6
			cMes := "Junho"
		Case nMes == 7
			cMes := "Julho"
		Case nMes == 8
			cMes := "Agosto"
		Case nMes == 9
			cMes := "Setembro"
		Case nMes == 10
			cMes := "Outubro"
		Case nMes == 11
			cMes := "Novembro"
		Case nMes == 12
			cMes := "Dezembro"
	EndCase

	cDataExt := Upper(cDia + ' de ' + cMes + ' de ' + cAno)
	
Return cDataExt


/*/{Protheus.doc} HRetColor
@description Retorna Codido de Cor RGB

@author Helitom Silva
@since  03/08/2013

@param p_nRed, Numerico, Quantidade de Vermelho (0..255)
@param p_nGreen, Numerico, Quantidade de Verde (0..255)
@param p_nBlue, Numerico, Quantidade de Azul (0..255)

@return nRet, Numerico, codigo da cor

/*/
User Function HRetColor(p_nRed, p_nGreen, p_nBlue)

	Local	nRet := 255
	
	Default p_nRed   := 0
	Default p_nGreen := 0
    Default p_nBlue  := 0
   
   	nRet := p_nRed + (p_nGreen * 256) + (p_nBlue * 65536)
   
Return nRet


/*/{Protheus.doc} HArVlCima
@description Arrendondar valor para acima

@author Helitom Silva
@since  03/08/2013

@param p_nValor, Numerico, Valor
@param p_nCasDec, Numerico, Casas decimais

@return nRet, Numerico, Valor arredondado para cima, conforme casas decimais

/*/
User Function HArVlCima(p_nValor, p_nCasDec)
	
	Local nRet	 	:= 0
	Local cValor 	:= Str(p_nValor)
	Local cInteiro  := Substr(cValor, 1, At('.', cValor) - 1)
	Local cDecimal	:= Substr(cValor, At('.', cValor) + 1)
	
	If Val(cDecimal) > 0
			
		If Len(cDecimal) > p_nCasDec
			cDecimal := If(Val(Substr(cDecimal, p_nCasDec)) > 0, cValToChar(Val(cDecimal) + 1), cValToChar(Val(cDecimal)))
		Else
			cDecimal := Substr(cDecimal, 1, p_nCasDec)
		EndIf
		
	Else
	
		cDecimal := Replicate('0', p_nCasDec)
		
	EndIf
	
	If Val(cDecimal) > Val(Replicate('9', p_nCasDec))		
		cInteiro := cValToChar(Val(cInteiro) + 1)
		cDecimal := Replicate('0', p_nCasDec)
			
		cValor := cInteiro + '.' + cDecimal
	Else
		cValor := cInteiro + '.' + cDecimal
	EndIf
	
	nRet := Val(cValor)
	
Return nRet


/*/{Protheus.doc} HConfirm
@description Mensagem de Confirmacao

@author	Helitom Silva
@since  22/08/2013

@param p_p_cMsg, Caracter, Mensagem
@param p_cTitulo, Caracter, Titulo da Tela
@param p_aOpc, Array, Array com dois itens, para identificar os nomes dos botoes exemplo: {'Sim', 'Não'}
@param p_nFocus, Numerico, Qual opcao terá o foco
	 
@return Se .T. se confirmou e .F. se nao confirmou

/*/
User Function HConfirm(p_cMsg, p_cTitulo, p_aOpc, p_nFocus)
	
	Local lRet 	  := .F. 
	Local lSelect := .F.
	
	Default p_cMsg 	  := 'Confirma esta ação?'
	Default p_cTitulo := 'Confirmação'
	Default p_aOpc    := {'&Sim', '&Não'}
	Default p_nFocus  := 1	
		
	/* Declaração de Variaveis Private dos Objetos */                            
	SetPrvt("oDlgConf","oPanConf","oSayConf","oBtnSim","oBtnNao")
	
	/* Definicao do Dialog e todos os seus componentes. */                       
	oDlgConf := MSDialog():New( 091, 233, 201, 544, p_cTitulo,,,.F.,,,,,,.T.,,,.T. )
	oPanConf := TPanel():New( 000, 000, "", oDlgConf,,.F.,.F.,,,158,053,.F.,.F. )
	oSayConf := TSay():New( 012 ,008, {|| p_cMsg},oPanConf,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,140,020)
	oBtnSim  := TButton():New( 037, 032, p_aOpc[1], oPanConf, {|| lRet:= .T., lSelect := .T.,oDlgConf:End()},045,012,,,,.T.,,"",,,,.F. )
	oBtnNao  := TButton():New( 037, 080, p_aOpc[2], oPanConf, {|| lRet:= .F., lSelect := .T.,oDlgConf:End()},045,012,,,,.T.,,"",,,,.F. )
	
	If p_nFocus == 1
		oBtnSim:SetFocus()
	Else
		oBtnNao:SetFocus()
	EndIf
	
	oDlgConf:Activate(,,,.T., {|| If(!lSelect, (MsgAlert('Selecione uma das duas opções!'), lSelect), lSelect)})

Return (lRet)


/*/{Protheus.doc} HTimeExec
@description Demonstração de Tempo de Execução - Esta funcao poderá ser usada para medir o tempo de execução de determinada Rotina, Consulta SQL, calculo e etc..

@author Helitom Silva
@since  27/08/2013

@param p_nSegIni, Numerico, Informe o tempo inicial por meio da função "Seconds()"
@param p_nSegFim, Numerico, Informe o tempo final por meio da função "Seconds()"

@return cRet, Caracter, String com Hora:Minuto:Segundos

/*/
User Function HTimeExec(p_nSegIni, p_nSegFim) 

	Local nHH, nMM , nSS, nMS := (p_nSegFim - p_nSegIni)
	Local cRet := ''
	
	nHH := int(nMS/3600) 
	nMS -= (nHH*3600) 
	nMM := int(nMS/60) 
	nMS -= (nMM*60) 
	nSS := int(nMS) 
	nMS := (nMs - nSS)*1000 
	
	cRet := (StrZero(nHH,2) + ":" + StrZero(nMM,2) + ":" + StrZero(nSS, 2) + "." + StrZero(nMS, 3))
	
Return (cRet)


/*/{Protheus.doc} IsProcCall
@description Retorna se uma determinada funcao esta na pilha de Execução.

@author Helitom Silva
@since  02/09/2013

@param p_cRotina, Caracter, Informe a funcao que deseja verificar

@return lRet, Logico, Retorna se .T. se a funcao esta na pilha, senao .F.. 

/*/
User Function IsProcCall(p_cRotina)

	Local lRet    := .F.
	Local nX      := 1
	Local _cVazio := AllTrim(ProcName(nX))
	
	p_cRotina := Upper(p_cRotina)
	
	While !Empty(_cVazio)
	   If AllTrim(ProcName(nX)) = p_cRotina
	      _cVazio := ''
	      lRet   := .T.
	      Exit
	   Else
	      nX++
	      _cVazio := alltrim(ProcName(nX))
	   EndIf
	End
	
Return lRet


/*/{Protheus.doc} OpenURLP
@description Abre um URL numa tela de browser de Internet dentro do Protheus

@author Helitom Silva
@since  16/09/2013

@param p_cURL, Caracter, URL

@link http://tdn.totvs.com/display/tec/TIBrowser
/*/
User Function OpenURLP(p_cURL)
 	
 	 Local aTmpSize := MsAdvSize() 
 	 
 	 /*  		---- aTmpSize ----
	 	 1 -> Linha inicial área trabalho.
	     2 -> Coluna inicial área trabalho.
		 3 -> Linha final área trabalho.
		 4 -> Coluna final área trabalho.
		 5 -> Coluna final dialog (janela).
		 6 -> Linha final dialog (janela).
		 7 -> Linha inicial dialog (janela).
	 */	
 
    oDlgURL := MSDialog():New( aTmpSize[7], 0, aTmpSize[6], aTmpSize[5], "Protheus Browser",,,.F.,,,,,,.T.,,,.T. )
     
    oTIBrowser := TIBrowser():New(0, 0, aTmpSize[5] - 640, 262, p_cURL, oDlgURL )
  
    TButton():New( oDlgURL:nHeight - 20, 10, "Imprimir", oDlgURL, {|| oTIBrowser:Print()}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
             
    oDlgURL:Activate(,,,.T.)

Return


/*/{Protheus.doc} OpenURLB
@description Abre um URL no browser de Internet padrao do Windows.

@author Helitom Silva
@since  16/09/2013

@param p_cURL, Caracter, URL

@link http://tdn.totvs.com/display/tec/TIBrowser
/*/
User Function OpenURLB(p_cURL)
 	
 	WinExec('CMD /C START ' + p_cURL)
 	 
Return


/*/{Protheus.doc} HPutMv
@description Verifica se existe um parametro e cria se necessário

@author Helitom Silva
@since  28/03/2012

@param p_cMvPar, Caracter, Parametro
@param p_cValor, Caracter, Valor do Parametro
@param p_cFilial, Caracter, Filial
@param p_cDesc, Caracter, Descrição do paramento

@return lRet, Logico, .T.

/*/
User Function HPutMv(p_cMvPar, p_cValor, p_cFilial, p_cDesc)

	Local lRet			:= .T.
	Local lExist		:= .F.
	
	Local nRecSX6		:= 0
	Local nOrdSX6		:= 0
	
	Default p_cFilial	:= cFilAnt			/* Sempre tento encontrar primeiro pela filial */
	Default p_cDesc		:= "Atualizar este descricao !"
	
	If Select("SX6") = 0
		DbSelectArea("SX6")
	EndIf
	
	nRecSX6		:= SX6->(Recno())
	nOrdSX6		:= SX6->(IndexOrd())
	
	If Empty(p_cMvPar)
		Return( .F. )
	EndIf
	
	SX6->(DbSetOrder(1))
	SX6->(DbGoTop())
	
	/* Verifico se existe o parametro para a Filial passada ou sem filial */
	If !SX6->(MsSeek( p_cFilial + Substr(p_cMvPar,1,10)))
		If SX6->(MsSeek( Space(Len(AllTrim(p_cFilial))) + Substr(p_cMvPar,1,10)))
			lExist := .T.
		EndIf
	Else
		lExist := .T.
	EndIf
	
	If ( ValType(p_cValor) == 'D' )
		p_cValor 	:= DtoC(p_cValor)
	ElseIf ( ValType(p_cValor) == 'N' )
		xValor	:= cValToChar(p_cValor)
	ElseIf ( ValType(p_cValor) == 'L' )
		xValor	:= If(p_cValor,'.T.','.F.')
	EndIf
	
	If ( lExist )
	
		RecLock('SX6', .F. )
		FieldPut( FieldPos('X6_CONTEUD'), p_cValor ) 
		FieldPut( FieldPos('X6_CONTSPA'), p_cValor ) 
		FieldPut( FieldPos('X6_CONTENG'), p_cValor ) 
		SX6->(MsUnlock())
	
		/* Volta o ponteiro para o local original */
		SX6->(DbSetOrder(nOrdSX6))
		SX6->(DbGoTo(nRecSX6))
	
	Else	
	
		/* Volta o ponteiro para o local original */
		SX6->(DbSetOrder(nOrdSX6))
		SX6->(DbGoTo(nRecSX6))
	
		RecLock('SX6', .T. )
	
		FieldPut( FieldPos('X6_FIL'), p_cFilial ) 
		FieldPut( FieldPos('X6_VAR'), p_cMvPar ) 
		FieldPut( FieldPos('X6_TIPO'), ValType(p_cValor) ) 
		FieldPut( FieldPos('X6_DESCRIC'), Substr(p_cDesc,1,50) ) 
		FieldPut( FieldPos('X6_DESC1'), Substr(p_cDesc,51,50) ) 
		FieldPut( FieldPos('X6_DESC2'), Substr(p_cDesc,101,50) ) 
		FieldPut( FieldPos('X6_DSCSPA'), Substr(p_cDesc,1,50) ) 
		FieldPut( FieldPos('X6_DSCSPA1'), Substr(p_cDesc,51,50) ) 
		FieldPut( FieldPos('X6_DSCSPA2'), Substr(p_cDesc,101,50) ) 
		FieldPut( FieldPos('X6_DSCENG'), Substr(p_cDesc,1,50) ) 
		FieldPut( FieldPos('X6_DSCENG1'), Substr(p_cDesc,51,50) ) 
		FieldPut( FieldPos('X6_DSCENG2'), Substr(p_cDesc,101,50) ) 
		FieldPut( FieldPos('X6_CONTEUD'), p_cValor ) 
		FieldPut( FieldPos('X6_CONTSPA'), p_cValor ) 
		FieldPut( FieldPos('X6_CONTENG'), p_cValor ) 
		FieldPut( FieldPos('X6_PROPRI'), "U" ) 
		FieldPut( FieldPos('X6_PYME'), "S" ) 
		FieldPut( FieldPos('X6_VALID'), "" ) 	
		FieldPut( FieldPos('X6_INIT'), "" ) 
	
		SX6->(MsUnlock())
	
	EndIf

Return lRet


/*/{Protheus.doc} HGetMV
@description Pesquisa um parametro, sempre buscando na tabela sx6

@author Helitom Silva
@since  28/03/2012

@param p_cMvPar, Caracter, Parametro
@param p_cDef, Caracter, Valor Default
@param p_cFilial, Caracter, Filial

@return Conteúdo do Parametro ou Valor Default

/*/
User Function HGetMV(p_cMvPar, p_cDef, p_cFilial)

	Local lExist		:= .F.
	
	Local nRecSX6		:= 0
	Local nOrdSX6		:= 0
	
	Local xConteud		:= ""
	Local xTipo			:= ""
	
	Default p_cDef		:= ""
	Default p_cFilial	:= cFilAnt
	
	If Select("SX6") = 0
		DbSelectArea("SX6")
	EndIf
	
	nRecSX6		:= SX6->(Recno())
	nOrdSX6		:= SX6->(IndexOrd())
	
	SX6->(DbSetOrder(1))
	SX6->(DbGoTop())
	
	If !SX6->(MsSeek(p_cFilial + Subs( p_cMvPar, 1, 10)))
		If SX6->(MsSeek( Space(Len(AllTrim(p_cFilial)))+Subs(p_cMvPar,1,10)))
			lExist	:= .T.
		EndIf
	Else
		lExist := .T.
	EndIf
	
	If lExist
	
		xConteud := StrTran(StrTran(SX6->X6_CONTEUD,'"',''),"'","")
		xTipo		:= SX6->X6_TIPO
	
		/* Volta o ponteiro para o local original */
		SX6->(DbSetOrder(nOrdSX6))
		SX6->(DbGoTo(nRecSX6))
	
		Do Case
			Case xTipo = 'C'
				Return( AllTrim(xConteud) )
	
			Case xTipo = 'N'
				If Empty(xConteud)
					Return( 0 )
				Else
					Return( Val(AllTrim(xConteud)) )
				EndIf
	
			Case xTipo = 'L'
				If Upper(AllTrim(xConteud)) $ '.T.|S|VERDADEIRO|TRUE'
					Return( .T. )
				ElseIf Upper(AllTrim(xConteud)) $ '.F.|N|FALSO|FALSE'
					Return( .F. )
				Else
					Return( Nil )
				EndIf
	
			Case xTipo = 'D'
				If Empty(xConteud)
					Return( CtoD("  /  /    ") )
				ElseIf '/' $ xConteud
					Return( CtoD(AllTrim(xConteud)) )
				Else
					Return( StoD(AllTrim(xConteud)) )
				EndIf
	
			OtherWise
			
				Return Nil
	
		EndCase			
	
	Else
	
		/* Volta o ponteiro para o local original */
		SX6->(DbSetOrder(nOrdSX6))
		SX6->(DbGoTo(nRecSX6))
	
		Return p_cDef
	
	EndIf

Return


/*/{Protheus.doc} HRetABox
@description converte CBox (SX3) em Array ponto para o objeto da classe TComBox.

@author Helitom Silva
@since  29/12/2013

@param cBox, Caracter, Dados X3_CBOX (Exemplo: S=Sim;N=Não)

@return aBox, Array, Lista com opcoes do Combobox, ponto para o objeto da classe TComBox

/*/
User Function HRetABox(p_cBox)
	
	Local aBox 		:= {}
	Local cItens 	:= "'"
	Local nX		:= 0
	Local cCaracter	:= 0
	
	If !Empty(AllTrim(p_cBox))
		
		For nX := 1 To Len(p_cBox)
			cItens += Iif((cCaracter := SubStr(p_cBox, nX, 1)) = ";", "','", cCaracter)
		Next
		
		cItens += "'"
		
		aBox := &('{' + cItens + '}')
		
	EndIf
	
Return aBox


/*/{Protheus.doc} RNomeEnt
@description Retorna o nome da Entidade do Arquivo XX8

@author Julio Storino
@since  30/11/2012

@param p_nEnt, Numerico, Informe o tipo de retorno ( 0 - Nome do Grupo, 1 - Nome da Unidade de Negocio, 2 - Nome da Empresa, 3 - Nome da Filial ) 

@return cRet, Caracter, Nome desejado conforme parametro p_nEnt

@obs Valores Default p_cEmp=01 p_cFil=01001001 p_cEnt=3

/*/
User Function RNomeEnt(p_cEmp, p_cFil, p_nEnt)

	Local cRet  	:= ""
	Local nRecXX8	:= XX8->(Recno())
	
	Local nTEmp		:= 0
	Local nTUni		:= 0
	Local nTFil		:= 0
	
	Local cCGrp		:= ""
	Local cCEmp		:= ""
	Local cCUni		:= ""
	Local cCCod		:= ""
	
	Local cNGrp		:=	""
	Local cNUni		:=	""
	Local cNEmp		:=	""
	Local cNFil		:= ""
			
	Default p_cEmp	:= cEmpAnt
	Default p_cFil	:= cFilAnt
	Default p_nEnt	:= 3
	
	XX8->(DbSetOrder(4))
	XX8->(DbGoTop())
	
	/* Localiza primeiro o registro 0 - Grupo de Empresa para pegar a mascara */
	If XX8->(DbSeek(Space(12) + Space(12) + Space(12) + PadR(p_cEmp,12) + '0'))
		_cLay		:= XX8->XX8_LEIAUT
		nTEmp 	:= ContaLet('E',_cLay)
		nTUni 	:= ContaLet('U',_cLay)
		nTFil 	:= ContaLet('F',_cLay)	
	Else
		Return( 'NiHil')
	EndIf
	
	/* Monto as Strings de Procura conforme a entidade. */	
	Do Case
		Case p_nEnt = 0  /* Grupo de Empresa */
			cCGrp	:= Space(12)
			cCEmp 	:= Space(12)
			cCUni	:= Space(12)
			cCCod	:= PadR(p_cEmp, 12)
		Case p_nEnt = 1	/* Unidade de Negocio */
			cCGrp	:= PadR(p_cEmp, 12)
			cCEmp 	:= Space(12)
			cCUni	:= Space(12)
			cCCod	:= PadR(Substr(p_cFil, At('E', cLay), nTEmp), 12)
		Case p_nEnt = 2	/* Empresa */
			cCGrp	:= PadR(p_cEmp, 12)
			cCEmp 	:= PadR(Substr(p_cFil, At('E', cLay), nTEmp), 12)
			cCUni	:= Space(12)
			cCCod	:= PadR(Substr(p_cFil, At('U', cLay), nTUni), 12)
		Case p_nEnt = 3	/* Filial */
			cCGrp	:= PadR(p_cEmp, 12)
			cCEmp 	:= PadR(Substr(p_cFil, At('E', cLay), nTEmp), 12)
			cCUni	:= PadR(Substr(p_cFil, At('U', cLay), nTUni), 12)
			cCCod	:= PadR(Substr(p_cFil, At('F', cLay), nTFil), 12)
		Case p_nEnt > 9
			_cNGrp	:=	U_NOMEENT(p_cEmp, p_cFil, 0)	/* Nome do Grupo */
			_cNUni 	:= If(Empty(PadR(Substr(p_cFil, At('E', cLay), nTEmp), 12)), "", U_NOMEENT(p_cEmp, p_cFil, 1))	/* Nome da Unidade */
			_cNEmp	:= If(Empty(PadR(Substr(p_cFil, At('U', cLay), nTUni), 12)), "", U_NOMEENT(p_cEmp, p_cFil, 2))	/* Nome da Empresa */
			_cNFil	:= If(Empty(PadR(Substr(p_cFil, At('F', cLay), nTFil), 12)), "", U_NOMEENT(p_cEmp, p_cFil, 3))	/* Nome da Filial */
			Do Case
				Case p_nEnt = 10
					cRet   := cNGrp
				Case p_nEnt = 11
					cRet   := cNUni
				Case p_nEnt = 12
					cRet   := cNEmp
				Case p_nEnt = 13
					cRet   := cNFil
			EndCase		
	EndCase
	
	/* Faço a Busca propriamente dita. */
	If p_nEnt < 10
		XX8->(DbGoTop())
		If XX8->(DbSeek(cCGrp + cCEmp + cCUni + cCCod + cValToChar(p_nEnt)))
			cRet   := AllTrim(XX8->XX8_DESCRI)
		Else
			cRet   := 'NiHil'
		EndIf
	EndIf
	
	XX8->(DbGoTo(nRecXX8))

Return cRet


/*/{Protheus.doc} HGravLog
@description Grava Logs

@author  Julio Storino
@since   03/11/2007
@version 1.0

@param p_cMsg, Caracter, Mensagem do Log
@param p_cTipo, Caracter, Tipo do Log
@param p_cName, Caracter, Nome do Log

@author  Helitom Silva
@since   20/01/2015
@version 2.0 - Feito tratamento para gravar no system definido no ambiente em execução

/*/
User Function HGravLog(p_cMsg, p_cTipo, p_cName, p_lHelp)

	Local cFile 	 := ''
	Local cDirSys	 := CurDir()
	Local cDirLog	 := '\' + cDirSys + 'LOG\'
		
	Default p_cMsg   := ''
	Default p_cTipo  := 'FUN'
	Default p_cName  := ''
	Default p_lHelp  := .F.
	
	/* Verifica se o diretório de Logs existe, senão cria. */
	If !FILE(cDirLog)
		MakeDir(cDirLog)
	EndIf
	
	/* Verifica se o diretório de Logs existe, senão cria. */
	If !FILE(cDirLog + p_cTipo)
		MakeDir(cDirLog + p_cTipo)
	EndIf
	
	/* Monta o Nome do arquivo de Log. */
	cFile := p_cTipo
	cFile += '_' + Upper(AllTrim(Funname()))
	cFile += '_' + Upper(SubStr(AllTrim(Iif(Type('cUserName') == 'C', &('cUserName'), '')), 1, 6))
	cFile += '_' + DtoS(Date())
	cFile += '_' + StrTran(Time(), ':', '')
	cFile += '_' + AllTrim(p_cName)
	
	cFile := StrTran(cFile, ':', '')
	
	While FILE(cDirLog + p_cTipo + '\' + cFile + '.LOG')
		cFile := Left(cFile, Len(cFile) - 2) + StrZero(Val(Right(cFile, 2)) + 1, 2)
	End
	
	cFile += '.LOG'
	
	MemoWrite(cDirLog + p_cTipo + '\' + cFile, p_cMsg)

	If p_lHelp
		Help( ,, 'HELP_' + p_cName,, p_cMsg, 1, 0)
	EndIf
	
Return


/*/{Protheus.doc} SaveParam
@description Salva Grupo de Perguntas

@author Ary Medeiros
@since  06/06/2014

@param p_cPergunta, Caracter, Nome do Grupo de Perguntas
@param p_aPergunta, Array, Dados da tabela SX1

/*/
Static Function SaveParam(p_cPergunta, p_aPergunta)

	Local nI
	Local nEl 	   := 1
	Local lProfile := .T.
	Local uVar
	Local cProfile := ""
	Local aArray   := {}
	Local lForEmp  := VerSenha(150)
	
	DbSelectArea("SX1")
	DbSeek(p_cPergunta)
	While !Eof() .and. X1_GRUPO = p_cPergunta .And. nEl <= Len(p_aPergunta)
		If p_aPergunta[nEl, 6] == "C"
			uVar := AllTrim(Str(p_aPergunta[nEl, 5]))
		ElseIf p_aPergunta[nEl, 6] == "R"
			uVar := p_aPergunta[nEl, 20]
		ElseIf p_aPergunta[nEl, 6] == "K"
			aArray := &("MV_PAR"+StrZero(nEl, 2, 0))
			uVar   := ""
			For nI := 1 To Len(aArray)
				If aArray[nI, 1]
					uVar+= LTrim(Str(nI)) + ";"
				EndIf
			Next nI
		Else
			If Upper(p_aPergunta[nEl, 2]) == "D"
				uVar := "'" + DTOC(p_aPergunta[nEl, 8], "DDMMYY") + "'"
			ElseIf Upper(p_aPergunta[nEl, 2]) == "N"
				uVar := Str(p_aPergunta[nEl, 8], p_aPergunta[nEl, 3], p_aPergunta[nEl, 4])
			Else
				uVar := p_aPergunta[nEl, 8]
			EndIf
		EndIf
	
		cProfile += X1_TIPO + "#" + X1_GSC + "#" + uVar + CRLF
	
		RecLock("SX1")
		If p_aPergunta[nEl, 6] == "C"
			Replace X1_PRESEL with p_aPergunta[nEl, 5]
		ElseIf p_aPergunta[nEl, 6] == "R"
			Replace X1_CNT02 With uVar
		Else
			Replace X1_CNT01 With uVar
		EndIf
		MSUnlock()
	
		nEl++
		DbSkip()
	
	End
	
	If FindProfDef(cUserName, p_cPergunta, "PERGUNTE", "MV_PAR")
		WriteProfDef(cUserName, p_cPergunta, "PERGUNTE", "MV_PAR", cUserName, p_cPergunta, "PERGUNTE", "MV_PAR", cProfile)
	Else
		WriteNewProf(cUserName, p_cPergunta, "PERGUNTE", "MV_PAR", cProfile)
	EndIf
	
Return


/*/{Protheus.doc} HSavePar
@description Atualiza SX1 Antes de Carregar valores Salvos

@author Julio Storino
@since  06/12/2011

@param p_cPergunta, Caracter, Nome do Grupo de Perguntas
@param p_aOrdVal, Caracter, Nome do Grupo de Perguntas

/*/
User Function HSavePar(p_cPergunta, p_aOrdVal)

	Local _nI		:= 0
	Local _aPerg	:= {}
	
	DbSelectArea('SX1')
	DbSetOrder(1)
	
	For _nI := 1 To Len(p_aOrdVal)
		
		DbGoTop()
	
		If DbSeek(PadR(p_cPergunta, 10)+p_aOrdVal[_nI][1])
	
			If SX1->X1_TIPO + SX1->X1_GSC = 'NC'
				aAdd( _aPerg, { X1Pergunt(),                                   	; 	//01-
								X1_TIPO,                                       	;	//02-
							  	IIf(X1_TIPO == "R",255,X1_TAMANHO),         	;	//03-
								X1_DECIMAL,                                		;	//04-
								p_aOrdVal[_nI][2],								;	//05-
								X1_GSC,                                        	;	//06-
								X1_VALID,                                     	;	//07-
								X1_CNT01,                                     	;	//08-
								IIf(X1_GSC=="E",X1_DEF01,AllTrim(X1Def01())),	;	//09-
								AllTrim(X1Def02()),                          	;	//10-
								AllTrim(X1Def03()),                           	;	//11-
								AllTrim(X1Def04()),                          	;	//12-
								AllTrim(X1Def05()),                           	;	//13-
								X1_VAR01,                                     	;	//14-
						  		IIf(X1_PRESEL==0,1,X1_PRESEL),                 	;	//15-
								X1_F3,                                        	;	//16-
								X1_PICTURE,                                   	;	//17-
								IIf(__lPymeSX1,X1_PYME,Nil),                   	;	//18-
								{||.T.},                                      	;	//19-
								X1_CNT02} )											//20-
			Else
				aAdd( _aPerg, { X1Pergunt(),                                   	; 	//01-
								X1_TIPO,                                       	;	//02-
								IIf(X1_TIPO == "R",255,X1_TAMANHO),         	;	//03-
								X1_DECIMAL,                                		;	//04-
								If(X1_PRESEL==0,1,X1_PRESEL),					;	//05-VLR PRE-SELECIONADO COMBO
								X1_GSC,                                        	;	//06-
								X1_VALID,                                     	;	//07-
								p_aOrdVal[_nI][2],                              ;	//08-CONTEUDO ARMAZENADO DO CAMPO
								IIf(X1_GSC == "E", X1_DEF01,AllTrim(X1Def01())),;	//09-
								AllTrim(X1Def02()),                          	;	//10-
								AllTrim(X1Def03()),                           	;	//11-
								AllTrim(X1Def04()),                          	;	//12-
								AllTrim(X1Def05()),                           	;	//13-
								X1_VAR01,                                     	;	//14-
								IIf(X1_PRESEL==0,1,X1_PRESEL),                 	;	//15-
								X1_F3,                                        	;	//16-
								X1_PICTURE,                                   	;	//17-
								IIf(__lPymeSX1,X1_PYME,Nil),                   	;	//18-
								{||.T.},                                      	;	//19-
								X1_CNT02} )											//20-
			EndIf
	
		EndIf
	
		DbSkip()
	
	Next _nI	
	
	SaveParam(p_cPergunta, _aPerg)

Return


/*/{Protheus.doc} PCPFCNPJ
@description Retorna o picture de formatação para CPF ou CNPJ
	
@author  Helitom Silva
@since   21/08/2014
@version 1.0
		
@param p_cCPFCNPJ, Caracter, Numero do CPF ou CNPJ

@return cRet, Caracter, Picture do documento informado

/*/
User Function PCPFCNPJ(p_cCPFCNPJ)
	
	Local cRet := ''
	
	Default p_cCPFCNPJ := ''
	
	cRet := Iif(Len(p_cCPFCNPJ) > 11, "99.999.999/9999-99", "@R 999.999.999-99")

Return cRet


/*/{Protheus.doc} TCPFCNPJ
@description Formatação para CPF ou CNPJ
	
@author  Helitom Silva
@since   21/08/2014
@version 1.0
		
@param p_cCPFCNPJ, Caracter, Numero do CPF ou CNPJ

@return cRet, Caracter, CPF/CNPJ formatado

/*/
User Function TCPFCNPJ(p_cCPFCNPJ)
	
	Local cRet := ''
	
	Default p_cCPFCNPJ := ''
	
	
	If len(trim(p_cCPFCNPJ)) > 11
		cRet :=	 SUBSTR(p_cCPFCNPJ, 1, 2) + '.' +  SUBSTR(p_cCPFCNPJ, 3, 3) + '.' + SUBSTR(p_cCPFCNPJ, 6, 3) + '/' + SUBSTR(p_cCPFCNPJ, 9, 4) + '-' + SUBSTR(p_cCPFCNPJ, 13, 2)
	Else
		cRet :=	 SUBSTR(p_cCPFCNPJ, 1, 3) + '.' +  SUBSTR(p_cCPFCNPJ, 4, 3) + '.' + SUBSTR(p_cCPFCNPJ, 7, 3) + '-' + SUBSTR(p_cCPFCNPJ, 10, 2)
	Endif


Return cRet


/*/{Protheus.doc} HRetDado
@description Retorna dado do tipo informado no parametro
	
@author  Helitom Silva
@since   28/08/2014
@version 1.0		

@return p_cTipo, Caracter, Sigla do Tipo de dados (C = caracter, N = Numerico, D = Data, L = Logico, U = Indefinido)

/*/
User Function HRetDado(p_cTipo)
	
	Local uRet := Nil
	
	If p_cTipo == 'C'
		uRet := ''
	ElseIf p_cTipo == 'N'
		uRet := 0
	ElseIf p_cTipo == 'D'
		uRet := CtoD('//')
	ElseIf p_cTipo == 'L'
		uRet := .F.
	EndIf
				
Return uRet


/*/{Protheus.doc} HExistTable
@description Retorna se existe uma tabela no dicionario de dados.
	
@author  Helitom Silva
@since   08/10/2014
@version 1.0		

@return p_cAlias, Caracter, Alias da Tabela a ser verificada

@return lRet, Logico, Se a tabela existir retorna .T.

/*/
User Function HExistTable(p_cAlias)
	
	Local lRet	   := .F.
	Local aAreaOld := GetArea()
	
	lRet := TCCanOpen(RetSqlName(p_cAlias)) 
	
	RestArea(aAreaOld)
				
Return lRet


/*/{Protheus.doc} EstAll
@description Calcula o saldo de estoque de determinado produto em uma data.

@author Julio Kusther
@since 27/10/2014
@version 1.0

@param p_CodPro, Caracter, Código do produto a ser consultado
@param p_dData, Data, Data do saldo a ser consultado

@return nSaldo, Saldo do produto em todos os locais de estoque
/*/
User Function	EstAll(p_CodPro,p_dData)
	
	Local nRet			:= 0
	Local cQualy		:= GetNewPar( "MV_CQ", "98")
	
	If !Empty(p_CodPro) .And. !Empty(p_dData)	
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		SB2->(DbSeek( cSeek :=xFilial("SB2") + (p_CodPro)))
	
		While SB2->(!Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == cSeek 
					
			If SB2->B2_LOCAL = cQualy // Desconsidera o saldo do armazem de qualidade
				SB2->(DbSkip())
				Loop
			EndIf	
									
			nRet	 += CalcEst(p_CodPro,SB2->B2_LOCAL,p_dData)[1]
			SB2->(DbSkip())
		EndDo
		SB2->(DbCloseArea())	
	EndIF						
		
Return(nRet)	


/*/{Protheus.doc} XFJ
@description Retorna mascara de picture campo.

@author Geanderson Silva
@since 15/11/2014
@version 1.0

@param p_cCampo,caracter,Conteudo do campo que será formatado.
@param p_cTipo,caracter, Tipo se pessoa fisica ou Juridica.

@return cMasc, caracter, Marcara do campo CPF ou CNPJ.

/*/
User Function XFJ(p_cCampo,p_cTipo)

	Local cMasc := ""
	
	Default p_cCampo	:= ""
	Default p_cTipo	:= ""
	
	If !Empty(p_cTipo)	
		If p_cTipo == "1" .or. p_cTipo == "F"  //F/1-CPF e J/2-CNPJ		
			cMasc := "@R 999.999.999-99999%C" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
		Else
			cMasc := "@R 99.999.999/9999-99%C"
		EndIf
	Else			
		If !Empty(p_cCampo) .And. Len(AllTrim(p_cCampo))<14
			cMasc := "@R 999.999.999-99999%C" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
		Else
			cMasc := "@R 99.999.999/9999-99%C"
		EndIf	
	EndIf

Return cMasc


/*/{Protheus.doc} BoxSx1
@description Função semelhante a paramBox

@author Julio Kusther
@since 16/12/2014
@version 1.0

@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}

/*/
User Function BoxSx1(aParametros,cTitle,aRet,bOk,aButtons,lCentered,nPosx,nPosy)

	Local nx
	Local oDlg
	Local cPath     := ""
	Local oPanel
	Local oPanelB
	Local cTextSay
	Local lOk			:= .F.
	Local nLinha		:= 8
	Local cArquivos := ""
	Local nBottom
	Local cLoad		:= ProcName(1)+AllTrim(xFilial())
	Local oFntVerdana
	Local oMainWnd		:= GetWndDefault()
	DEFAULT bOk			:= {|| (.T.)}
	DEFAULT aButtons	:= {}
	DEFAULT lCentered	:= .T.
	DEFAULT nPosX		:= 0
	DEFAULT nPosY		:= 0


	DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD

	DEFINE MSDialog oDlg TITLE cTitle FROM nPosX,nPosY TO nPosX+274,nPosY+445 OF oMainWnd Pixel

	oPanel := TScrollBox():New( oDlg, 8,10,104,203)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	//oPanel := TPanel():New(8,10,'',oDlg, oDlg:oFont, .F., .F.,, ,203 ,104 ,.T.,.T. )

	For nx := 1 to Len(aParametros)
		Do Case
		Case aParametros[nx][1]==1 // SAY + GET
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := IIF(Empty(aParametros[nx][3]), "",aParametros[nx][3])
			cTextSay:= "{||'"+STRTRAN(aParametros[nx][2],"'",'"')+" ? "+"'}"
			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][9],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			cWhen	:= Iif(Empty(aParametros[nx][7]),".T.",aParametros[nx][7])
			cValid	:=Iif(Empty(aParametros[nx][5]),".T.",aParametros[nx][5])
			cF3		:=Iif(Empty(aParametros[nx][6]),NIL,aParametros[nx][6])
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf

			&("oGET"+AllTrim(STRZERO(nx,2,0))) := TGet():New( nLinha,95 ,&cBlKGet,oPanel,aParametros[nx][8],,aParametros[nx][4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,,,,,.T.)
		Case aParametros[nx][1]==2 // SAY + COMBO
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cTextSay:= "{||'"+STRTRAN(aParametros[nx][2],"'",'"')+" ? "+"'}"
			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][7],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			cValid	:=Iif(Empty(aParametros[nx][6]),".T.",aParametros[nx][6])
			cBlKVld := "{|| "+cValid+"}"
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlkWhen := "{|| .T. }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TComboBox():New( nLinha,95, &cBlkGet,aParametros[nx][4], aParametros[nx][5], 10, oPanel, ,,       ,,,.T.,,,.F.,&(cBlkWhen),.T.,,)
		Case aParametros[nx][1]==3 // SAY + RADIO
			nLinha += 8
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cTextSay:= "{||'"+aParametros[nx][2]+" ? "+"'}"
			TGroup():New( nLinha-8,15, nLinha+(Len(aParametros[nx][4])*9)+7,205,aParametros[nx][2]+ " ? ",oPanel,If(aParametros[nx][7],CLR_HBLUE,CLR_BLACK),,.T.)
//			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][7],CLR_HBLUE,CLR_BLACK),,,,,,,,)
//			@ nLinha-5,75 TO nLinha+(Len(aParametros[nx][4])*9)+5,80+aParametros[nx][5]+1 LABEl "" of oPanel PIXEL
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlkWhen := "{|| .T. }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			//cBChange := "{| u | "+aParametros[nx][6]+"}"
						
			                                                   
			&("oGET"+AllTrim(STRZERO(nx,2,0))):= TRadMenu():New( nLinha, 30, aParametros[nx][4],&cBlkGet, oPanel,,/*&(cBChange)*/,,,,,&(cBlkWhen),aParametros[nx][5],9, ,,,.T.)
			nLinha += (Len(aParametros[nx][4])*10)-3
		Case aParametros[nx][1]==4 // SAY + CheckBox
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cTextSay:= "{||'"+aParametros[nx][2]+"  "+"'}"
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][7],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			cBlkWhen := "{|| .T. }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TCheckBox():New(nLinha,95,aParametros[nx][4], &cBlkGet,oPanel, aParametros[nx][5],10,,,,,,,,.T.,,,&(cBlkWhen))
		Case aParametros[nx][1]==5 // CheckBox Linha Inteira
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlkWhen := "{|| .T. }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TCheckBox():New(nLinha,15,aParametros[nx][2], &cBlkGet,oPanel, aParametros[nx][4],10,,,,,,,,.T.,,,&(cBlkWhen))
		Case aParametros[nx][1]==6 // File + Procura de Arquivo
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cTextSay:= "{||'"+STRTRAN(aParametros[nx][2],"'",'"')+" ? "+"'}"
			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][8],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			cWhen	    := Iif(Empty(aParametros[nx][6]),".T.",aParametros[nx][6])
			cValid	  := Iif(Empty(aParametros[nx][5]),".T.","("+aParametros[nx][5]+").Or.Vazio("+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+")")
			cBlkGet   := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlKVld   := "{|| " + cValid + "}"
			cBlKWhen  := "{|| " + cWhen + "}"
			cArquivos := aParametros[nx][9]
			
			If Len(aParametros[nx]) == 10
				cPath := aParametros[nx][10]
			EndIf
			
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf

			cGetfile := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := cGetFile(cArquivos,'"+;
				"STR0086"+"',0,cPath,"+Iif(Len(aParametros[nX]) < 15 .Or. aParametros[nX][15], ".T.",".F.")+;
				","+IIF(Len(aParametros[nX]) >= 14, AllTrim(Str(GETF_LOCALHARD+GETF_LOCALFLOPPY+aParametros[nX][14])), "0")+;
				")+SPACE(40), If(Empty(MV_PAR"+AllTrim(STRZERO(nx,2,0))+;
				"), MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := '"+;
				aParametros[nx][3]+"',)  }"
	
			
			TGet():New( nLinha,95 ,&cBlKGet,oPanel,aParametros[nx][7],,aParametros[nx][4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,)
			TButton():New( nLinha,95 + aParametros[nx][7], "STR0085", oPanel,&(cGetFile), 29, 12, , oDlg:oFont, ,.T.,.F.,,.T., &(cBlkWhen),, .F.)
		
		Case aParametros[nx][1]==7 // Filtro de Arquivos
			nLinha += 2
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			SetPrvt("MV_FIL"+AllTrim(STRZERO(nx,2,0)))

			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][4])
			&("MV_FIL"+AllTrim(STRZERO(nx,2,0))) := MontDescr(aParametros[nx][3],ParamLoad(cLoad,aParametros,nx,aParametros[nx][4]))
			TGroup():New( nLinha-8,15, nLinha+40,170,aParametros[nx][2]+ " ? ",oPanel,,,.T.)
			cWhen	:= ".T."
			cValid	:=".T."
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_FIL"+AllTrim(STRZERO(nx,2,0))+","+"MV_FIL"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			cGetFilter := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := BuildExpr('"+aParametros[nx,3]+"',,MV_PAR"+AllTrim(STRZERO(nx,2,0))+"),MV_FIL"+AllTrim(STRZERO(nx,2,0))+":=MontDescr('"+aParametros[nx,3]+"',MV_PAR"+AllTrim(STRZERO(nx,2,0))+") }"
			TButton():New( nLinha-2,18, "Editar", oPanel,MontaBlock(cGetFilter), 35, 14, , oDlg:oFont, ,.T.,.F.,,.T., ,, .F.)
			TMultiGet():New( nLinha, 55, &cBlKGet,oPanel,109,33,,,,,,.T.,,.T.,&(cBlkWhen),,,.T.,&(cBlkVld),,.T.,.F., )
			nLinha += 31
		Case aParametros[nx][1]==8 // SAY + GET PASSWORD
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx][3])
			cTextSay:= "{||'"+STRTRAN(aParametros[nx][2],"'",'"')+" ? "+"'}"
			TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,If(aParametros[nx][9],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			cWhen	:= Iif(Empty(aParametros[nx][7]),".T.",aParametros[nx][7])
			cValid	:=Iif(Empty(aParametros[nx][5]),".T.",aParametros[nx][5])
			cF3		:=Iif(Empty(aParametros[nx][6]),NIL,aParametros[nx][6])
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TGet():New( nLinha,95 ,&cBlKGet,oPanel,aParametros[nx][8],,aParametros[nx][4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .T. ,cF3,,,,,.T.)
		EndCase
		nLinha += 17
	Next

	oPanelB := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,40,20,.T.,.T. )
	oPanelB:Align := CONTROL_ALIGN_BOTTOM
 
	For nx := 1 to Len(aButtons)
		SButton():New( 4, 157-(nx*33), aButtons[nx][1],aButtons[nx,2],oPanelB,.T.,IIf(Len(aButtons[nx])==3,aButtons[nx,3],Nil),)
	Next

	oMainWnd:CoorsUpdate()

//DEFINE SBUTTON FROM 4, 114   TYPE 4 ENABLE OF oDlg ACTION ParamSave(cLoad,aParametros)
	DEFINE SBUTTON FROM 4, 157   TYPE 1 ENABLE OF oPanelB ACTION (If(ParamOk(aParametros,@aRet).And.Eval(bOk),(oDlg:End(),lOk:=.T.),(lOk:=.F.)))
	DEFINE SBUTTON FROM 4, 190   TYPE 2 ENABLE OF oPanelB ACTION (lOk:=.F.,oDlg:End())

	If (nLinha*2) + 80 > oMAinWnd:nBottom-oMAinWnd:nTop
		nBottom  := oDLg:nTop + oMAinWnd:nBottom-oMAinWnd:nTop - 5
	Else
		nBottom := oDLg:nTop + (nLinha*2) + 80
	EndIf

	nBottom := MAX(310,nBottom)
	oDlg:nBottom := nBottom

	ACTIVATE MSDialog oDlg CENTERED

Return lOk


/*/{Protheus.doc} XDelChar
@description Retira os caracteres especiais de uma palavra.

@author Geanderson Silva
@since 14/10/2016
@version 1.0

@param p_cRet, character, Variavel com caracteres a ser tratados

@type function
/*/
User Function XDelChar(p_cRet)

	Default p_cRet := ""
	
	p_cRet = StrTran(p_cRet, "á", "")
	p_cRet = StrTran(p_cRet, "é", "")
	p_cRet = StrTran(p_cRet, "í", "")
	p_cRet = StrTran(p_cRet, "ó", "")
	p_cRet = StrTran(p_cRet, "ú", "")
	p_cRet = StrTran(p_cRet, "Á", "")
	p_cRet = StrTran(p_cRet, "É", "")
	p_cRet = StrTran(p_cRet, "Í", "")
	p_cRet = StrTran(p_cRet, "Ó", "")
	p_cRet = StrTran(p_cRet, "Ú", "")
	p_cRet = StrTran(p_cRet, "ã", "")
	p_cRet = StrTran(p_cRet, "õ", "")
	p_cRet = StrTran(p_cRet, "Ã", "")
	p_cRet = StrTran(p_cRet, "Õ", "")
	p_cRet = StrTran(p_cRet, "â", "")
	p_cRet = StrTran(p_cRet, "ê", "")
	p_cRet = StrTran(p_cRet, "î", "")
	p_cRet = StrTran(p_cRet, "ô", "")
	p_cRet = StrTran(p_cRet, "û", "")
	p_cRet = StrTran(p_cRet, "Â", "")
	p_cRet = StrTran(p_cRet, "Ê", "")
	p_cRet = StrTran(p_cRet, "Î", "")
	p_cRet = StrTran(p_cRet, "Ô", "")
	p_cRet = StrTran(p_cRet, "Û", "")
	p_cRet = StrTran(p_cRet, "ç", "")
	p_cRet = StrTran(p_cRet, "Ç", "")
	p_cRet = StrTran(p_cRet, "à", "")
	p_cRet = StrTran(p_cRet, "À", "")
	p_cRet = StrTran(p_cRet, "º", "")
	p_cRet = StrTran(p_cRet, "ª", "")
	p_cRet = StrTran(p_cRet, ".", "")
	p_cRet = StrTran(p_cRet, "/", "")
	p_cRet = StrTran(p_cRet, "\", "")
	p_cRet = StrTran(p_cRet, ":", "")
	p_cRet = StrTran(p_cRet, "?", "")
	p_cRet = StrTran(p_cRet, "!", "")
	p_cRet = StrTran(p_cRet, "@", "")
	p_cRet = StrTran(p_cRet, "|", "")
	p_cRet = StrTran(p_cRet, ">", "")
	p_cRet = StrTran(p_cRet, "<", "")
	p_cRet = StrTran(p_cRet, "*", "")
	p_cRet = StrTran(p_cRet, "#", "")
	p_cRet = StrTran(p_cRet, "&", "")
	p_cRet = StrTran(p_cRet, chr(9), "") // TAB
	p_cRet = StrTran(p_cRet, "  ", "")
	p_cRet = StrTran(p_cRet, "-", " ")
	p_cRet = StrTran(p_cRet, " ",'_')

Return p_cRet