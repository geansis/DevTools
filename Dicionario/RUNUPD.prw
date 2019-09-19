#INCLUDE 'PROTHEUS.CH'

#DEFINE	CR	Chr(13) + Chr(10)


/*/{Protheus.doc} RUNUPD
@description Selecionar os compatibilizadores que deseja executar.
	
@author  Evandro Vendrametto
@since   25/11/2013
@version 1.0		

@author  Helitom Silva
@since   27/11/2013
@version 2.0 - Incluido uso da DbGrid e Conexão com empresa Inicial.

@author  Helitom Silva
@since   25/11/2013
@version 3.0 - Incluido PE e Combobox para seleção de Grupos de Compatibilizadores.

@author  Helitom Silva
@since   09/02/2015
@version 4.0 - Melhoria na Interface usando a Classe FwLayer.

/*/
User Function RUNUPD()
	
	Local cRotina 	:= "Compatibilizador"	
	Local nSuperior	:= 031
	Local nEsquerda	:= 000
	Local nInferior	:= 150
	Local nDireita	:= 350		
	Local nX		:= 300		
	Local oFWLayer  := FWLayer():New()
	
	Private _lConect  := .F.	
	Private cCodEmp   := '99'
	Private cCodFil   := '01'
	
	Private lExistPe  := ExistBlock('RUNUPDPE') 
	Private aItGrupo  := {}
	Private aIdaGPUPD := {}
	Private nItGrupo  := 0
	Private cCompatib := Space(8)
	Private aCols	  := {}	

	SetPrvt("oDlgRun","oSayGrupo","oGetGrupo","oCombGrupo","oDbGrid")	
		
	CarrConfig()
    
    If MsgYesNo('Deseja executar em modo exclusivo?')
    	If !AcessoExcPt()
			MsgStop( "Não foi possível acessar em modo exclusivo!" )
			Return
		EndIf
    EndIf
     		
	/* Conexao com empresa Inicial para ter acesso as demais, pois as vezes alguns clientes não tem a empresa 99 */
	If !MsgSelEmp()
		Return
	EndIf	
	
	Set Date Brit
	Set Century ON

	SetPrvt("oDlgRun","oWinHeaderL","oWinHeaderR","oWinDet","oCombGrupo","oGetGrupo","oDbGrid","oBtnOk","oBtnClose")

	oDlgRun	  := MSDialog():New(000, 000, 450, 700, cRotina,,,.F.,,,,,,.T.,,,.T.)

	oFWLayer:Init( oDlgRun, .F., .T. )

	oFWLayer:AddLine( 'LHEADER', 20, .F. )
	oFWLayer:AddCollumn( 'CHEADERLEFT', 70, .T., 'LHEADER' )
	oFWLayer:AddCollumn( 'CHEADERRIGHT', 30, .T., 'LHEADER' )
	oFWLayer:AddWindow( 'CHEADERLEFT', 'WHEADER', 'Grupo de Updates', 100, .F., .T.,, 'LHEADER'  )
	oFWLayer:AddWindow( 'CHEADERRIGHT', 'WHEADER', 'Opções', 100, .F., .T.,, 'LHEADER'  )

	oWinHeaderL := oFWLayer:GetWinPanel( 'CHEADERLEFT', 'WHEADER', 'LHEADER' ) 
			
	If lExistPe
		
		aItGrupo := ExecBlock('RUNUPDPE', .F., .F.)
		
		If ExistBlock('IDAGPUPD') 
			If Valtype(aIdaGPUPD := ExecBlock('IDAGPUPD', .F., .F.)) == 'A' .and. Len(aIdaGPUPD) > 0
				For nX := 1 to Len(aIdaGPUPD)
					aAdd(aItGrupo, aIdaGPUPD[nX])
				Next
			EndIf
		EndIf
		
		If !Len(aItGrupo) > 0
			MsgAlert('Atenção o PE: RUNUPDPE não retornou Grupo(s) de Compatibilizadores, por favor exclua-o do RPO ou corrija-o para que retorne os Grupos!')
			Return
		EndIf
		
		oCombGrupo := TComboBox():New( 02, 02, {|u| If(PCount()>0,cCompatib:=u,cCompatib)},aItGrupo,150,010,oWinHeader,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCompatib )		
		oCombGrupo:bChange := {|| MontaCols()}
		oCombGrupo:SetFocus()
		
	Else		
	
		oGetGrupo := TGet():New(02, 02, {|u| If(PCount()>0, cCompatib := u, cCompatib )},oWinHeader,030,009,"@!",,CLR_BLACK,CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCompatib")
		oGetGrupo:bChange	:= {|| MontaCols() }
		oGetGrupo:SetFocus()
		
	EndIf

	oWinHeaderR := oFWLayer:GetWinPanel( 'CHEADERRIGHT', 'WHEADER', 'LHEADER' ) 

	oBtnOk    := TButton():New(002, 004, "&Ok",		oWinHeaderR, {|| ExecUPDs()}, 040,015,,,,.T.,,"",,,,.F.)
	oBtnClose := TButton():New(002, 050, "&Fechar",	oWinHeaderR, {|| oDlgRun:End() }, 040,015,,,,.T.,,"",,,,.F.)
	
	oFWLayer:AddLine( 'LDET', 80, .F. )	
	oFWLayer:AddCollumn( 'CDET', 100, .T., 'LDET' )
	oFWLayer:addWindow( 'CDET', 'WDET', 'Compatibilizadores', 100, .F., .T.,, 'LDET' )
	
	oWinDet := oFWLayer:GetWinPanel( 'CDET', 'WDET', 'LDET' )
		
	oDbGrid	:= DbGrid():Create(nSuperior,nEsquerda,nInferior,nDireita,GD_UPDATE/*/GD_INSERT+GD_DELETE+GD_UPDATE/*/,,,,,,,,,, oWinDet, MontaHeader(), aCols, 1, 1)
	oDbGrid:oBrowse:lHScroll  	:= .F.
	oDbGrid:oBrowse:nScrollType := 1
	oDbGrid:oBrowse:Align		:= CONTROL_ALIGN_ALLCLIENT
	
	If lExistPe
		Eval(oCombGrupo:bChange)
	EndIf
			
	oDlgRun:lEscClose := .T.		
	oDlgRun:lCentered := .T.	
	oDlgRun:Activate() 
		
Return


/*/{Protheus.doc} MontaCols
@description Monta colunas da Grid

@author Evandro Vendrametro
@since  27/11/2013

/*/
Static Function MontaHeader()
	
	Local aRet := {}
	
	aAdd(aRet, {"Funcao"   ,	"FUNC" , 	"@!",   10,	0,"" ,,"C" ,,,,,,"V",,,.F.})
	aAdd(aRet, {"Descricao",	"DESC" , 	"@!",	50,	0,"" ,,"C" ,,,,,,"V",,,.F.})
	aAdd(aRet, {"Data"	   ,	"DATA" , 	"@D",	8,	0,"" ,,"D" ,,,,,,"V",,,.F.})
	
Return aRet


/*/{Protheus.doc} MontaCols
@description Monta dados da Grid

@author Evandro Vendrametro
@since  27/11/2013

/*/
Static Function MontaCols()
	
	Local nX		:= 0
	Local nY		:= 0	
	Local aArrayRet	:= {}
	
	If ExistBlock(cCompatib)			
		
		aArrayRet := ExecBlock(cCompatib)
		
		If !Empty(aArrayRet)				
		
			aSize(oDbGrid:aCols, 0)                                                         	
			
			For nX := 1 to Len(aArrayRet) 										
				
				/* Inicializando aCols */
				aAdd(oDbGrid:aCols, Array(Len(oDbGrid:aHeader) + 1))									
			
				/* Preenche o acols */	 
				oDbGrid:aCols[nX, 1] := oDbGrid:hoNo 
				oDbGrid:aCols[nX, 2] := aArrayRet[nX, 1]
				oDbGrid:aCols[nX, 3] := aArrayRet[nX, 2]	
				oDbGrid:aCols[nX, 4] := Iif(Len(aArrayRet[nX]) > 2, CtoD(aArrayRet[nX, 3]), CtoD('//'))	
						
				oDbGrid:aCols[nX, len(oDbGrid:aheader) + 1] := .F.    
											
			Next
			
			oDbGrid:Refresh()			
		
		Else	
							
			MsgAlert("Verifique o grupo do Update!!!")
			
			If lExistPe
				oCombGrupo:SetFocus()
			Else
				oGetGrupo:SetFocus()
			EndIf
					
		EndIf
			
	Else
		
		oDbGrid:Limpar()
		oDbGrid:Refresh()
		  
		MsgAlert("Não foi encontrada a função: " + cCompatib)
					
	EndIf
	 
Return


/*/{Protheus.doc} ExecUPDs
@description Executa compatibilizadores Selecionados

@author Evandro Vendrametro
@since  27/11/2013

/*/
Static Function ExecUPDs()
	
	Local nI		:= 0 	
	Local nX		:= 0
	Local aEmpresas := {}	
	Local aRetDados	:= {}
	
	For nI := 1 To Len(oDbGrid:aCols)
		
		/* Verifica os marcados. */	
		If oDbGrid:Marcado(nI) .and. !Empty(oDbGrid:aCols[nI, 2])
			aAdd(aRetDados, {oDbGrid:aCols[nI, 2]})			 
		EndIf
	
	Next
	
	If !Empty(aRetDados)
	 
		/* Retorna as empresas selecionadas. */
		aEmpresas 	:= U_DEVUPD0()	
		
		If Len(aEmpresas) > 0
		
			For nX := 1 To Len(aRetDados)
	
				/*Executa a Update dos marcados. */			
				U_DEVUPD1(aEmpresas, aRetDados[nX][1])
							
			Next
			
			oDbGrid:MARDESM(2)
			
			MsgAlert("Finalizou!")	
		
		EndIf
		
	Else
		MsgAlert('Nenhum compatibilizador válido marcado!')
	EndIf
	
	oDbGrid:PosLinha(1)
	
Return


/*/{Protheus.doc} MsgSelEmp
@description Formulario para Seleção de Empresa e Filial de Login

@author Helitom Silva
@since  27/11/2013

/*/
Static Function MsgSelEmp()

	Local lSair := .f.

	bOk2 := {|| IIF(cCodEmp <> Space(2) .or. cCodFil <> Space(8), (lSair := .t., SetaEmp()), MsgAlert('Por favor, informe a Empresa e a Filial!'))  }
	bCancel2 := {|| lSair := .f., oDlgTab:End()}

	cCodEmp := PadR(cCodEmp, 2)
	cCodFil := PadR(cCodFil, 8)

	/*Declaração de Variaveis Private dos Objetos*/
	SetPrvt("oDlgTab","oPanelTab","oSayC","oSayR","oBtnOk","oBtnCc","oGtCons","oGtReve")

	/*Definicao do Dialog e todos os seus componentes.*/

	oDlgTab    := MSDialog():New( 091,232,160,540,"Selecione a Empresa e a Filial",,,.F.,,,,,,.T.,,,.T. )
	oPanelTab  := TPanel():New( 000,000,"",oDlgTab,,.F.,.F.,,,148,036,.F.,.F. )
	oSayC      := TSay():New( 009,006,{||"Empresa"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
	oSayR      := TSay():New( 022,011,{||"Filial"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)

	oBtnOk     := TButton():New( 006,107,"Ok",oPanelTab,@bOk2,037,012,,,,.T.,,"",,,,.F. )
	oBtnCc     := TButton():New( 020,107,"Cancelar",oPanelTab,@bCancel2,037,012,,,,.T.,,"",,,,.F. )

	oGtCons    := TGet():New( 008,036,{|u|if(PCount()>0,cCodEmp:=u,cCodEmp)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"EMP",Nil),"cCodEmp",,)
	oGtCons:bValid := {|| IIF(cCodEmp <> Space(2), .T., .F.)}

	oGtReve    := TGet():New( 021,036,{|u|if(PCount()>0,cCodFil:=u,cCodFil)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"DLB",Nil),"cCodFil",,)
	oGtReve:bValid := {|| IIF(cCodFil <> Space(6), .T., .F.)}

	oDlgTab:Activate(,,,.T.)

Return (lSair)


/*/{Protheus.doc} SetaEmp
@description Define Emmpresa e Filial de Login

@author Helitom Silva
@since  27/11/2013

/*/
Static Function SetaEmp()

	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)

	_lConect := .t.

	cDadosEmp := padr('cCodEmp = ' + cCodEmp + ' ', 60) + CR
	cDadosEmp += padr('cCodFil = ' + cCodFil + ' ', 60) + CR
	
	MemoWrite('C:\Temp\Config.txt', cDadosEmp)

	oDlgTab:End()

Return


/*/{Protheus.doc} CarrConfig
@description Carrega configurações

@author Helitom Silva
@since  27/11/2013

/*/
Static Function CarrConfig()

	Local nTamFile, nTamLin, cBuffer, nBtLidos, cTxtLin, cDLinha
	Local lEnc := .f.
	Local nK   := 0

	Private cArqConf := "C:\Temp\Config.txt"
	Private nHdl     := fOpen(cArqConf,68)

	If !File(cArqConf)
	   Return
	EndIf

	If nHdl == -1
	    MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	    Return
	Endif

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 60+Len(CR)
	cBuffer  := Space(nTamLin) /* Variavel para criacao da linha do registro para leitura */
	cTxtLin	 := ""

	nBtLidos := fRead(nHdl,cBuffer,nTamLin) /* Leitura da primeira linha do arquivo texto */

	cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nTamLin))

	ProcRegua(nTamFile) /* Numero de registros a processar */

	cCodEmp	 := ''
	cCodFil  := ''

	While nBtLidos >= nTamLin

		IncProc()
		IEnc := .f.

		If UPPER("cCodEmp") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				 If Substr(cTxtLin, nK, 1) = '='
				 	 IEnc := .t.
				 EndIf
				 If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
				 	 cCodEmp += Substr(cTxtLin, nK, 1)
				 EndIf
				 If !Empty(cCodEmp) .and. (Substr(cTxtLin, nK, 1) = ' ')
				 	  Exit
				 EndIf
			Next
		EndIf

		If UPPER("cCodFil") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				 If Substr(cTxtLin, nK, 1) = '='
				 	 IEnc := .t.
				 EndIf
				 If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
				 	 cCodFil += Substr(cTxtLin, nK, 1)
				 EndIf
				 If !Empty(cCodFil) .and. (Substr(cTxtLin, nK, 1) = ' ')
				 	  Exit
				 EndIf
			Next
		EndIf

	   nBtLidos := fRead(nHdl, @cBuffer, nTamLin) // Leitura da proxima linha do arquivo texto

		cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nBtLidos))

	EndDo

	fClose(nHdl)

Return


/*/{Protheus.doc} AcessoExcPt
@description Verifica se obtem acesso exclusivo

@author Helitom Silva
@since  19/09/2014

/*/
Static Function AcessoExcPt()

	Local lRet := .F.
	Local nX   := 0

	For nX := 1 To 20
	
		DbUseArea( .T., , "SIGAMAT.EMP", "SM0", .F., .F. )

		If !Empty( Select( "SM0" ) )
			lRet := .T.
			DbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf

	Next

Return lRet