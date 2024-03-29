#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DEVHEL03  � Autor � HELITOM SILVA      � Data �  23/04/2012 ���
�������������������������������������������������������������������������͹��
���Descricao � Construtor de Tela                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Particular                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DEVHEL03

//----------------------------------------------------------------------------------------------------------------//
// Declara��o de cVariable dos componentes
//----------------------------------------------------------------------------------------------------------------//

	Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE

	Private aCoGCabCam := {}
	Private aCoGCabRel := {}
	Private aCoGCabTab := {}
	Private aCoGDetCam := {}
	Private aCoGDetRel := {}
	Private aCoGDetTab := {}
	Private aHoGCabCam := {}
	Private aHoGCabRel := {}
	Private aHoGCabTab := {}
	Private aHoGDetCam := {}
	Private aHoGDetRel := {}
	Private aHoGDetTab := {}
	Private cGFilCabCa    := Space(100)
	Private cGFilCabRe    := Space(100)
	Private cGFilCabTa    := Space(100)
	Private cGFilDetCa    := Space(100)
	Private cGFilDetRe    := Space(100)
	Private cGFilDetTa    := Space(100)
	Private noGCabCam  := 0
	Private noGCabRel  := 0
	Private noGCabTab  := 0
	Private noGDetCam  := 0
	Private noGDetRel  := 0
	Private noGDetTab  := 0

//----------------------------------------------------------------------------------------------------------------//
// Declara��o de Variaveis Bloco de Codigos para os eventos
//----------------------------------------------------------------------------------------------------------------//
   Private bFilCRel := {|| FilCabRel()}
   Private bFilCCam := {|| FilCabCam()}
   Private bFilDRel := {|| FilDetRel()}
   Private bFilDCam := {|| FilDetCam()}

//----------------------------------------------------------------------------------------------------------------//
// Declara��o de Variaveis Private dos Objetos
//----------------------------------------------------------------------------------------------------------------//
	SetPrvt("oDlgCamp","oPanel1","oBtn1","oGrp1","oSay4","oSay5","oSay6","oGDetCam","oGDetRel","oGDetTab")
	SetPrvt("oGFilDetRel","oGFilDetCam","oGrp2","oSay2","oSay3","oSay7","oGCabCam","oGCabRel","oGCabTab")
	SetPrvt("oGFilCabRel","oGFilCabCam")

//----------------------------------------------------------------------------------------------------------------//
// Definicao do Dialog e todos os seus componentes.
//----------------------------------------------------------------------------------------------------------------//
	oDlgCamp   := MSDialog():New( 091,230,505,1123,"Selecione os Campos do Cabe�alho e Detalhe do Formul�rio",,,.F.,,,,,,.T.,,,.T. )
	oPanel1    := TPanel():New( 000,000,"",oDlgCamp,,.F.,.F.,,,441,200,.T.,.F. )

	oGrp2      := TGroup():New( 001,002,090,438," Campos do Cabe�alho ",oPanel1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay2      := TSay():New( 009,294,{||"Selecione os Campos"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oSay3      := TSay():New( 009,150,{||"Relacionamento entre tabelas"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay7      := TSay():New( 009,005,{||"Selecione as Tabelas"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,054,008)

	MHoGCabTab()
	MCoGCabTab()
	oGCabTa := DbGrid():Create(017,005,077,145,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHoGCabTab,aCoGCabTab, 1 )
    //oGCabTa:bchange := {|| MCoGCabRel()}
    oGCabTa:DEPMARC({|| MCoGCabRel()})

	MHoGCabRel()
	//MCoGCabRel()
	oGCabRe := DbGrid():Create(017,148,077,291,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHoGCabRel,aCoGCabRel, 1 )

	MHoGCabCam()
	MCoGCabCam()
	oGCabCa := DbGrid():Create(017,294,077,434,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHoGCabCam,aCoGCabCam, 1 )

	oGFilCabTa := TGet():New( 078,005,{|u| If(PCount()>0,cGFilCabTab:=u,cGFilCabTab)},oGrp2,141,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilCabTab",,)
	oGFilCabRe := TGet():New( 078,148,{|u| If(PCount()>0,cGFilCabRel:=u,cGFilCabRel)},oGrp2,144,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilCabRel",,)
	oGFilCabCa := TGet():New( 078,294,{|u| If(PCount()>0,cGFilCabCam:=u,cGFilCabCam)},oGrp2,141,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilCabCam",,)

	oBtn1      := TButton():New( 184,002,"Salvar",oPanel1,,037,012,,,,.T.,,"",,,,.F. )

	oGrp1      := TGroup():New( 093,002,183,438," Campos do Detalhe ",oPanel1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay4      := TSay():New( 101,294,{||"Selecione os Campos"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oSay5      := TSay():New( 101,150,{||"Relacionamento entre tabelas"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay6      := TSay():New( 101,005,{||"Selecione as Tabelas"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,054,008)

	MHoGDetTab()
	MCoGDetTab()
	oGDetTa := DbGrid():Create(109,005,169,145,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp1,aHoGDetTab,aCoGDetTab, 1 )

	MHoGDetRel()
	MCoGDetRel()
	oGDetRe := DbGrid():Create(109,148,169,291,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp1,aHoGDetRel,aCoGDetRel, 1 )

	MHoGDetCam()
	MCoGDetCam()
	oGDetCa := DbGrid():Create(109,294,169,434,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp1,aHoGDetCam,aCoGDetCam, 1 )

	oGFilDetTa := TGet():New( 170,005,{|u| If(PCount()>0,cGFilDetTab:=u,cGFilDetTab)},oGrp1,141,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilDetTab",,)
	oGFilDetRe := TGet():New( 170,148,{|u| If(PCount()>0,cGFilDetRel:=u,cGFilDetRel)},oGrp1,144,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilDetRel",,)
	oGFilDetCa := TGet():New( 170,294,{|u| If(PCount()>0,cGFilDetCam:=u,cGFilDetCam)},oGrp1,141,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGFilDetCam",,)


	oDlgCamp:Activate(,,,.T.)

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MHoGCabTab() - Monta aHeader da Grid de Tabelas do Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGCabTab()

	Aadd(aHoGCabTab,{"TABELA","X2_ARQUIVO","@!", 10, 0,"","","C","","" } )

	noGCabTab := 1

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGCabTab() - Monta aCols da Grid de Tabelas do Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MCoGCabTab()

	Local aAux  := {}
   Local nCols := 0
   Local nI		:= 0

	DbSelectArea("SX2")
	DbSetOrder(1)
	DbGoTop()
	While !Eof()

	    nCols++

	    Aadd(aCoGCabTab,Array(noGCabTab+1))

		For nI := 1 To noGCabTab
			aCoGCabTab[nCols][nI] := SX2->&(aHoGCabTab[nI][2])
		Next

		aCoGCabTab[nCols][noGCabTab+1] := .F.

	    DbSkip()
    End

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MHoGCabRel() - Monta aHeader da Grid de Relacionamento Entre Tabelas do Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGCabRel()

	Aadd(aHoGCabRel,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

	Aadd(aHoGCabRel,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabRel,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

	noGCabRel := 8

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGCabRel() - Monta aCols da Grid de Relacionamento Entre Tabelas do Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MCoGCabRel()

	Local aAux 	:= {}
   Local nCols := 0
   Local nI		:= 0

   aSize(oGCabRe:aCols,0)

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	While !Eof()

        If oGCabTa:MARCADO(aScan(oGCabTa:aCols,{|pGrid| pGrid[2] = SX3->X3_ARQUIVO}))
	        nCols++

		    Aadd(oGCabRe:aCols, Array(len(oGCabRe:aHeader) + 1))

			For nI := 2 To len(oGCabRe:aHeader)
				oGCabRe:aCols[nCols][nI] := SX3->&(oGCabRe:aHeader[nI][2])
			Next

			oGCabRe:aCols[nCols][len(oGCabRe:aHeader) + 1] := .F.

			If nCols = 100
			   Exit
			Endif
		EndIf

	    DbSkip()
    End

    oGCabRe:Refresh()
Return

//----------------------------------------------------------------------------------------------------------------//
//Function  � MHoGCabCam() - Monta aHeader da Grid de Campos de Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGCabCam()

	Aadd(aHoGCabCam,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabCam,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabCam,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGCabCam,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

	noGCabCam := 4

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGCabCam() - Monta aCols da Grid de Campos de Cabecalho
//----------------------------------------------------------------------------------------------------------------//
Static Function MCoGCabCam()

	Local aAux  := {}
   Local nCols := 0
   Local nI		:= 0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	While !Eof()

        nCols++

	    Aadd(aCoGCabCam,Array(noGCabCam+1))

		For nI := 1 To noGCabCam
			aCoGCabCam[nCols][nI] := SX3->&(aHoGCabCam[nI][2])
		Next

		aCoGCabCam[nCols][noGCabCam+1] := .F.
		DbSkip()
	End

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MHoGDetTab() - Monta aHeader da Grid de Tabelas do Detalhe
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGDetTab()

	Aadd(aHoGDetTab,{"TABELA","X2_ARQUIVO","@!", 10, 0,"","","C","","" } )

	noGDetTab := 1

Return


//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGDetTab() - Monta aCols da Grid de Tabelas do Detalhe
//----------------------------------------------------------------------------------------------------------------//

Static Function MCoGDetTab()

   Local nCols := 0
	Local nI		:= 0

	DbSelectArea("SX2")
	DbSetOrder(1)
	DbGoTop()
	While !Eof()

        nCols++

	    Aadd(aCoGDetTab,Array(noGDetTab+1))

		For nI := 1 To noGDetTab
			aCoGDetTab[nCols][nI] := SX2->X2_ARQUIVO
		Next

	    aCoGDetTab[nCols][noGDetTab+1] := .F.
		DbSkip()
	End

Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MHoGDetRel() - Monta aHeader da Grid de Relacionamento entre Tabelas do Detalhe
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGDetRel()

	Aadd(aHoGDetRel,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

	Aadd(aHoGDetRel,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetRel,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

    noGDetRel := 8

Return


//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGDetRel() - Monta aCols da Grid de Relacionamento entre Tabelas do Detalhe
//----------------------------------------------------------------------------------------------------------------//
Static Function MCoGDetRel()

	Local aAux  := {}
   Local nCols := 0
   Local nI		:= 0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	While !Eof()

		nCols++

	    Aadd(aCoGDetRel,Array(noGDetRel+1))

		For nI := 1 To noGDetRel
			aCoGDetRel[nCols][nI] := SX3->&(aHoGDetRel[nI][2])
		Next

		aCoGDetRel[nCols][noGDetRel+1] := .F.
		DbSkip()
    End
Return

//----------------------------------------------------------------------------------------------------------------//
// Function  � MHoGDetCam() - Monta aHeader da Grid de Campos do Detalhe
//----------------------------------------------------------------------------------------------------------------//
Static Function MHoGDetCam()

	Aadd(aHoGDetCam,{'CAMPO', 'X3_CAMPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetCam,{'TIPO', 'X3_TIPO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetCam,{'TAMANHO', 'X3_TAMANHO', '@!', 10, 0, "", 'C', "", "" } )
	Aadd(aHoGDetCam,{'DECIMAL', 'X3_DECIMAL', '@!', 10, 0, "", 'C', "", "" } )

	noGDetCam := 4
Return


//----------------------------------------------------------------------------------------------------------------//
// Function  � MCoGDetCam() - Monta aCols da Grid de Campos do Detalhe
//----------------------------------------------------------------------------------------------------------------//
Static Function MCoGDetCam()

	Local aAux  := {}
   Local nCols := 0
	Local nI		:= 0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	While !Eof()

        nCols++

	    Aadd(aCoGDetCam,Array(noGDetCam+1))

		For nI := 1 To noGDetCam
			aCoGDetCam[nCols][nI] := SX3->&(aHoGDetCam[nI][2])
		Next

		aCoGDetCam[nCols][noGDetCam+1] := .F.
		DbSkip()
    End
Return
