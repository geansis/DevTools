#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE	CR	Chr(13) + Chr(10)

/*/{Protheus.doc} DEVFUN03
@description Manipula um arquivo ini - le e grava informacoes.

@author  Julio Storino
@since   23/01/2012
@version 1.0 - (JIniFile)

@author  Helitom Silva
@since   30/09/2014
@version 2.0 - Revisado e reorganizado para o projeto.

/*/
User Function DEVFUN03(p_cAcao, p_aCriters, p_cFile, p_aPop)

	Local _aIni		:= {}
	Local _nI		:= 0
	Local _nZ 		:= 0
	Local _nSess	:= 0
	Local _nChav	:= 0
	Local _lRet		:= .F.

	Default p_aPop	:= {}

	If (Upper(p_cAcao) = "LE" .And. !File(p_cFile))

		/* Zera array de retorno (posicao 3) */
		For _nI := 1 To Len(p_aCriters)
			p_aCriters[_nI][3] := ""
		Next _nI
		
		Return( _lRet )

	EndIf

	If Upper(p_cAcao) $ "LE"

		If !Empty(p_aPop)
	
			/* Normaliza aPop - Somente posicao 1 e 2 para pesquisa */
			For _nI := 1 To Len(p_aPop)
				p_aPop[_nI][1] := Upper(AllTrim(p_aPop[_nI][1]))
				p_aPop[_nI][2] := Upper(AllTrim(p_aPop[_nI][2]))
			Next _nI
	
			/* Carrego o _aIni com os dados do p_aCriters */
			PopulaIni( @_aIni , p_aPop )
	
		ElseIf !CarregaIni( @_aIni , .F. , p_cFile , .F. )

			/* Zera array de retorno (posicao 3) */
			For _nI := 1 To Len(p_aCriters)
				p_aCriters[_nI][3] := ""
			Next _nI
			Return( _lRet )

		Else
			/* Normaliza aCriters */
			For _nI := 1 To Len(p_aCriters)
				p_aCriters[_nI][1] := Upper(AllTrim(p_aCriters[_nI][1]))
				p_aCriters[_nI][2] := Upper(AllTrim(p_aCriters[_nI][2]))
				p_aCriters[_nI][3] := ""
			Next _nI
		EndIf

		/* Veja se em algum momento solicitou todas as chaves do arquivo. */
		If !Empty( aScan( p_aCriters , {|x| x[1] == '*'} ) )
			p_aCriters := {}		//Vou retornar o aCriters com todo o conteudo do arquivo INI */
			For _nI := 1 To Len( _aIni )
				For _nZ := 1 To Len( _aIni[_nI][2] )
					aAdd( p_aCriters , { _aIni[_nI][1] , _aIni[_nI][2][_nZ][1] , _aIni[_nI][2][_nZ][2] } )
				Next _nZ
			Next _nI
		Else
			/* Realiza as Buscas */
			For _nI := 1 To Len(p_aCriters)
				/* Acha a Sessao */
				If !Empty( _nSess := aScan( _aIni , {|x| x[1] == p_aCriters[_nI][1]  }) )
	
					/* Verifica se esta pedindo todos as chaves da sessao */
					If p_aCriters[_nI][2] == '*'

						p_aCriters[_nI][3] := {}
						For _nZ := 1 To Len( _aIni[_nSess][2] ) //To 1 Step -1
						//If Empty( _nChav := aScan( p_aCriters , {|x| x[1]+x[2] == _aIni[_nSess][1]+_aIni[_nSess][2][_nZ][1]} ))
						//	aSize( p_aCriters , Len(p_aCriters)+1 )
						//	aIns( p_aCriters , _nI+1 )
							aAdd( p_aCriters[_nI][3] , { _aIni[_nSess][1] , _aIni[_nSess][2][_nZ][1]  , _aIni[_nSess][2][_nZ][2] } )
						//	p_aCriters[_nI+1] := { _aIni[_nSess][1] , _aIni[_nSess][2][_nZ][1]  , _aIni[_nSess][2][_nZ][2] } 						
						//Else
						//	p_aCriters[_nChav][3] := _aIni[_nSess][2][_nZ][2]						
						//EndIf
						Next _nZ
						_lRet := .T.	/* Se encontrar pelo menos 1 ja retorno .T. */

					Else

						/* Acha a Chave (Somente se ainda nao tiver valor definido) */
						If Empty(p_aCriters[_nI][3])
							If !Empty( _nChav := aScan( _aIni[_nSess][2] , {|x| x[1] == p_aCriters[_nI][2] }) )
								_lRet := .T.	//Se encontrar pelo menos 1 ja retorno .T.
								p_aCriters[_nI][3] := _aIni[_nSess][2][_nChav][2]
							EndIf
						Else
							Loop
						EndIf

					EndIf
	
				EndIf
	
			Next _nI

		EndIf
		
	Else
	
		If !Empty(p_aPop)
	
			/* Normaliza aIni - Somente posicao 1 e 2 para pesquisa */
			For _nI := 1 To Len(p_aPop)
				p_aPop[_nI][1] := Upper(AllTrim(p_aPop[_nI][1]))
				p_aPop[_nI][2] := Upper(AllTrim(p_aPop[_nI][2]))
			Next _nI
	
			/* Carrego o _aIni com os dados do p_aCriters */
			PopulaIni( @_aIni, p_aPop )

		ElseIf !CarregaIni( @_aIni , .T. , p_cFile , .T. )

			/* Zera array de retorno (posicao 3) */
			For _nI := 1 To Len(p_aCriters)
				p_aCriters[_nI][3] := ""
			Next _nI
			Return( _lRet )

		Else

			/* Normaliza aCriters */
			For _nI := 1 To Len(p_aCriters)
				p_aCriters[_nI][1] := Upper(AllTrim(p_aCriters[_nI][1]))
				p_aCriters[_nI][2] := Upper(AllTrim(p_aCriters[_nI][2]))
				p_aCriters[_nI][3] := AllTrim(p_aCriters[_nI][3])
			Next _nI

		EndIf
	
		/* Realiza as Buscas e atualizacoes */
		For _nI := 1 To Len(p_aCriters)
			/* Acha a Sessao */
			If !Empty( _nSess := aScan( _aIni , {|x| x[1] == p_aCriters[_nI][1]  }) )
				/* Acha a Chave */
				If !Empty( _nChav := aScan( _aIni[_nSess][2] , {|x| x[1] == p_aCriters[_nI][2] }) )
					_aIni[_nSess][2][_nChav][2] := p_aCriters[_nI][3]
				Else
					/* Adiciona a Chave e o Valor */
					aAdd( _aIni[_nSess][2] , { p_aCriters[_nI][2] , p_aCriters[_nI][3] } )
				EndIf
			Else
				/* Adiciona Nova Sessao e Chave */
				aAdd( _aIni , { p_aCriters[_nI][1] , {{ p_aCriters[_nI][2] , p_aCriters[_nI][3] }} } )
			EndIf
		Next _nI


		/* Re-Criar o arquivo INI */
		_lRet := CriaINI( _aIni , p_cFile )

	EndIf

Return( _lRet )


/*/{Protheus.doc} CarregaIni
@description Carrega um arquivo ini para um array.

@author Julio Storino
@since  16/07/2012

/*/
Static Function CarregaIni( p_aIni , p_lNew , p_cFile , p_lCom )

	Local _cLine	:= ""
	Local _aLine	:= {}
	Local _nI		:= 0
	Local _nZ 		:= 0
	Local _nNod		:= 0
	Local nHdl    	:= Nil          /* Handle para abertura do arquivo */

	Default p_lNew	:= .F.
	Default p_lCom	:= .F.

	nHdl := FT_FUSE(p_cFile) 		/* Abre o arquivo */

	If nHdl == -1
		p_aIni := {}
		Return( p_lNew )
	Endif

	FT_FGOTOP()					/* Posiciona no comeco do arquivo */
	_cLine := FT_FREADLN()

	/* Carrega o array com os arquivo ini e fecha o arquivo. */
	While !FT_FEOF()
		aAdd( _aLine , FT_FREADLN() )
		FT_FSKIP()
	EndDo
	FT_FUSE()		/* Fecha o arquivo. */

	For _nI := 1 To Len(_aLine)

		If Left(AllTrim(_aLine[_nI]),1) = '['		/* Sessao */
		
			/* Adiciono uma Sessao ao ini */
			aAdd( p_aIni , { Upper(AllTrim(StrTran(StrTran(_aLine[_nI],'[',''),']',''))) , {} } )
			_nNod := Len( p_aIni )
		
			_nI++

			For _nZ := _nI To Len(_aLine)
			
				If (At('[',_aLine[_nZ])==0) .And. (At(']',_aLine[_nZ])==0)

					/* Linhas com comentarios - adiciona */
					If (Left(AllTrim(_aLine[_nZ]),1)) $ ';'
						If p_lCom
							aAdd( p_aIni[_nNod][2] , {_aLine[_nZ],';'} )
							Loop
						Else
							Loop
						EndIf
					EndIf

					/* linhas em branco ou sem o padrao xxxx=yyyyy  Desconsidera totalmente */
					If Empty(_aLine[_nZ]) .Or. !('=' $ _aLine[_nZ])
						Loop
					EndIf

					If '=' $ _aLine[_nZ]
						aAdd( p_aIni[_nNod][2] , { Upper(AllTrim(Substr(_aLine[_nZ],1,At('=',_aLine[_nZ])-1))) , AllTrim(Substr(_aLine[_nZ],At('=',_aLine[_nZ])+1,999)) } )
						Loop
					EndIf

				Else

					_nI := _nZ-1
					Exit

				EndIf

			Next _nZ
		
		EndIf
	
	Next _nI

Return( ( Len(p_aIni) > 0 .Or. p_lNew ) )


/*/{Protheus.doc} CriaINI
@description Cria um novo arquivo ini atualizado. 

@author Julio Storino
@since  16/07/2012

/*/
Static Function CriaINI( p_aIni , p_cFile )

	Local _lRet		:= .F.
	Local _nI		:= 0
	Local _nZ		:= 0
	Local _cIni		:= ""

	/* Crio o Texto com o Arquivo INI */
	For _nI := 1 To Len( p_aIni )
		_cIni += '[' + p_aIni[_nI][1] + ']' + CR
		For _nZ := 1 To Len( p_aIni[_nI][2] )
			_cIni += p_aIni[_nI][2][_nZ][1] + If(p_aIni[_nI][2][_nZ][2]=";",'','=') + If(p_aIni[_nI][2][_nZ][2]=";","",p_aIni[_nI][2][_nZ][2]) + CR
		Next _nZ
		If _nI < Len( p_aIni )
			_cIni += CR
		EndIf
	Next _nI

	/* Apaga o arquivo original - Tento 10 vezes com intervalos de 1/3 segundo para garantir. */
	For _nI := 1 To 10
		_lRet := .F.
		FErase( p_cFile )
		Sleep( 666 )
		If !File( p_cFile )
			_lRet := .T.
			Exit
		EndIf
	Next _nI

	/* Recria o arquivo - Tento 10 vezes com intervalos de 2 segundo para garantir. */
	For _nI := 1 To 10
		_lRet := .F.
		MemoWrite( p_cFile , _cIni )
		Sleep( 2000 )
		If File(p_cFile)
			_lRet := .T.
			Exit
		EndIf
	Next _nI

Return( _lRet )


/*/{Protheus.doc} PopulaIni
@description Carrega os dados do acriters no aini para consulta

@author Julio Storino
@since  19/10/2012

/*/
Static Function PopulaIni( p_aIni , p_aCriters )

	Local _nI 	:= 0
	Local _nZ	:= 0
	Local _nP	:= 0

	p_aIni := {}

	For _nI := 1 To Len(p_aCriters)
		If !Empty(_nP := aScan(p_aIni,{|x| x[1]==p_aCriters[_nI][1]}))
			aAdd( p_aIni[_nP][2] , {p_aCriters[_nI][2],p_aCriters[_nI][3]} )
		Else
			aAdd(p_aIni,{p_aCriters[_nI][1],{{p_aCriters[_nI][2],p_aCriters[_nI][3]}}})
		EndIf
	Next _nI

Return( Len(p_aIni) > 0 )