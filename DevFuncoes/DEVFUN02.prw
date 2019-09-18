#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "AP5MAIL.CH"

#DEFINE	CR	Chr(13) + Chr(10)

/*/{Protheus.doc} DEVFUN02
@description Rotina para startar os jobs customizados no lugar da rotina padrao que start um agente impossivel de derrubar

@author  Julio Storino
@since   23/02/2012
@version 1.0 - (JobCall)

@author  Helitom Silva
@since   30/09/2014
@version 2.0 - Revisado, ajustado e reorganizado para o projeto.

@obs Funcionamento:      
	                                                   
	    1-CRIAR A PASTA JOBCALL NO ROOTPATH DO SERVIDOR (PROTHEUS_DATA)    
	                                                                        
	    2-CRIAR O ARQUIVO CALLJOB.CFG COM AS CONFIGURACOES DE FUNCIONAMENTO DO JOB, SENDO ELAS:                                        
	                                                                       
	    [PAREXEC]                                                          
	     MAXJOBS=15                       <- Maximo Threads Simultaneas    
	     INDEBUG=ON                       <- Mode Debug (saida Console)    
	     MONTHRUN=ALL                     <- Dias do Mes a executar (1)    
	     DAYWKRUN=SEG-TER-QUA-QUI-SEX-SAB <- Dias da Semana a executar (1) 
	     STARTRUN=00:00                   <- Hora de Inicio do Job         
	     STOPRUN=23:59                    <- Hora de Fim do Job            
	                                                                       
	     (1) Ou All para todos os Didas do Mes/Semanas                     
	                                                                       
	    3-CRIAR UM START JOB NO INI DO SERVER OU SLAVE ONDE O JOB SERA     
	      EXECUTADO, CONFORME ABAIXO:                                      
	                                                                       
	           [ONSTART]                                                   
	           refreshrate=30  <- Tempo que o Job eh verificado            
	           jobs=JOBCALL    <- nome do Job a ser executado              
	                                                                       
	           [JOBCALL]                                                   
	           main=U_JOBCALL  <- nome desta rotina                        
	           environment=??  <- nome do ambiente a ser executado         
	                                                                       
	    4-CRIAR E COMPILAR A ROTINA A SER COLOCA NO JOB                    
	      ATENTAR PARA O USO DE PREPARE ENVIRONMENT                        
	      ATENTAR PARA TRATAMENTO DE MENSAGEM VISUAIS (USAR CONOUT)        
	      ATENTAR PARA TRATAMENTO DOS PARAMETROS RECEBIDOS                 
	      FUNCAO ISBLIND() NAO IRA FUNCIONAR, AO INVEZ DISSO USAR:         
	         Private __IsBlind	:= Type('cFilant') = 'U'                  
	                                                                       
	    5-COLOCAR DENTRO DA PASTA JOBCALL (ITEM 1) OS ARQUIVOS INI DOS     
	      JOBS QUE DESEJA QUE SEJAM EXECUTADOS, CONFORME O MODELO:         
	                                                                       
	      qualquer_coisa.ini                       <- nome do arquivo ini  
	                                                  nao ha regras        
	      [parexec]                                                        
	      jobname=Teste                            <- nome do Job          
	      funname=U_JOBTESTE                       <- nome da funcao       
	      envname=NFKRF0_TI03                      <- ambiente de execucao 
	      indebug=ON / OFF                         <- Saida Console On Off 
	                                                                       
	      [mvparam]                                                        
	      partype=A                                <- tipo passagem (1)    
	      mvpar01=dDataBase-1                      <- parametros da rotina 
	      mvpar02=dDataBase-1                         podem ser criados    
	      mvpar03='010101'                          quantos forem        
	      mvpar04='010101'                          necessarios          
	      mvpar05=10.00                               o conteudo deve ser  
	      mvpar06=5.00                                o exato valor a ser  
	      mvpar07=20.00                               passado para rotina  
	      mvpar08={'helitom.silva@hotmail.com'}                           
	                                                                       
	      [runtime]                                                        
	      monthrun=all                             <- Execucao mensal (2)  
	      daywkrun=seg-ter-qua-sex-sab             <- Execucao Semanal (3) 
	      lastrun=11:00:00                         <- Ultima execucao (4)  
	      elaprun=01:00:00                         <- Intervalo (5)        
	
	 (1) A - passa os parametros como array ex: funcao({par1,par2,par3})  
	     U - passa os parametros com unicos ex: funcao( par1,par2,par3 )  
	                                                                      
	 (2) all - Para ser executado todos os dias do mes                    
	     01-02-05-10-15 Para ser executado em determinados dias do mes    
	                                                                      
	 (3) all - Para ser executado todos os dias da semana                 
	     seg-qua-sex-dom Para ser executado em determinado dias da semana 
	                                                                      
	 (4) Registra a hora da ultima execucao do job somente para os Jobs   
	     de execucao unica, nos jobs recursivos nao usa esta informacao.  
	     Se vazio o Job sera ignorado (nao eh executado)                  
	     se elaprun=**:**:** sera a hora de execucao unica do Job            
	                                                                      
	 (5) Registra o intervalo de execucao do Job em horas:minutos HH:MM   
	     Se estiver vazio assume como valor padrao 02:30                  
	     Se preenchido com **:**:** o Job sera executado uma unica vez no    
	     horario definido na chave lastrun                                 

/*/

User Function DEVFUN02()

	Local _nI			:= 0
	Local _nX			:= 0
	Local _nZ			:= 0

	/* Arrays de Trabalho */
	Local aJobs			:= {}
	Local aJobsBkp		:= {}
	Local aJobRun		:= {}

	Local _lBkp			:= .F.

	Local _cProg		:= ""
	Local _cEnv			:= ""
	Local _cTPar		:= ""

	Local _aPar			:= {}
	Local _aParJ		:= {}

	Local _cPar			:= ""
	Local _cParJ		:= ""
	Local _cParLog		:= ""

	Local _bBloco		:= ""

	/* Variaveis para carregar array de Trabalho */
	Local _cMonthrun	:= ""
	Local _cDayWkrun 	:= ""
	Local _cLastDay		:= ""
	Local _cLastRun		:= ""

	Local aThreTmp		:= {}

	Private _aGRIni		:= {}
	Private _cDebug		:= ""
	Private _nMaxJobs	:= 999
	Private _cMonthJob	:= "all"
	Private _cDayWkJob	:= "all"
	Private _cStartJob	:= "00:00:00"
	Private _cStopJob	:= "23:59:59"

	Private _cPtMsg		:= ""
	Private _lDebug		:= .F.
	Private _cJobName	:= "* CALLJOB *"
	Private _cElapRun	:= ""  /* Privada pois tenho que testar o Tipo de Job na hora de executar e atualizar ultima execucao. */
	Private _aWeek		:= {'dom','seg','ter','qua','qui','sex','sab'}

	/* Protecao - pasta base do Job */
	If !File("\jobcall")
		MakeDir("\jobcall")
	EndIf

	/* Carrega os Parametros de Trabalho */
	ParamJob()

	if File("\jobcall\mod.off") .Or. !TempoJob()
		Return( Nil )
	EndIf

	/* Prepara o Ambiente para todas as funcoes Funcionarem */
	Prepare Environment Empresa "01" Filial "010101"

	PtInternal(1, _cPtMsg := "CallJob - " + ProcName() + " - Funcao Principal do JOB")

	/* LOOP PRINCIPAL */
	While .T.
	
		/* Modo de Liga/Desliga Job */
		if File("\jobcall\mod.off") .Or. !TempoJob()
			Exit
		EndIf
	
		/* Modo restart do Job */
		if File("\jobcall\mod.res")
			FRename("\jobcall\mod.res","\jobcall\mod.on")
			ParamJob()
			aJobs 	:= {}
			aJobRun := {}
		EndIf
	
		/* Para forcar carregamento por alteracoes nos ini, mude o arquivo mod para .res */
		If Empty(aJobs)
		
			aJobs := {}
			aJobs := Directory("\jobcall\*.ini")
		
			/* Proteção para o caso de algum arquivo estar faltando (se houver o arquivo de Bkp) */
			If File("\jobcall\bkpini")

				aJobsBkp := {}
				aJobsBkp :=	Directory("\jobcall\bkpini\*.ini")
			
				For _nI := 1 To Len(aJobsBkp)
					If Empty( aScan( aJobs, {|x| AllTrim(Lower(x[1])) == AllTrim(Lower(aJobsBkp[_nI][1]))}) )
						If __CopyFile("\jobcall\bkpini\" + aJobsBkp[_nI][1], "\jobcall\" + aJobsBkp[_nI][1])
							_lBkp := .T.
						Else
							U_DEVFUN01('helitom.silva@hotmail.com.br','CallJob - Nao pode recuperar arquivo ' + aJobsBkp[_nI][1],' Favor Verificar ! ',,,{})
						EndIf
					EndIf
				Next _nI

				/* Re-obtem os agendamentos apos o backup */
				If _lBkp
					_lBkp := .F.
					aJobs := {}
					aJobs := Directory("\jobcall\*.ini")
				EndIf

			EndIf
		
			/* Crio o array de trabalho (para nao mais ter que ficar atualizando os inis em disco) */
			For _nI := 1 To Len(aJobs)
			
				/* Zera Variaveis de Controle */
				_cJobName	:= ""
				_cProg		:= ""
				_cEnv		:= ""
				_cTPar		:= ""
				_aPar		:= {}
				_aParJ		:= {}
				_cMonthrun 	:= ""
				_cDayWkrun 	:= ""
				_cLastRun 	:= ""
				_cElapRun 	:= ""
			
				/* Carrega todos os registros importantes do INI */
				_aGRIni := {}
				aAdd( _aGRIni , {"parexec","jobname"	,""})		/* 1 */
				aAdd( _aGRIni , {"parexec","funname"	,""})		/* 2 */
				aAdd( _aGRIni , {"parexec","envname"	,""})		/* 3 */
				aAdd( _aGRIni , {"mvparam","*"		 	,""})		/* 4 {1,2,{ {1,2,3}  , {1,2,3} }} */
				aAdd( _aGRIni , {"runtime","monthrun"	,""})		/* 5 */
				aAdd( _aGRIni , {"runtime","daywkrun"	,""})		/* 6 */
				aAdd( _aGRIni , {"runtime","lastrun"	,""})		/* 7 */
				aAdd( _aGRIni , {"runtime","elaprun"	,""})		/* 8 */
			
				U_DEVFUN03("le", _aGRIni, "\jobcall\" + aJobs[_nI][1])

				_cJobName 	:= _aGRIni[1][3]
				_cProg 		:= _aGRIni[2][3]
				_cEnv		:= _aGRIni[3][3]
				If !Empty(_aGRIni[4][3])
					_cTPar 	:= _aGrIni[4][3][aScan(_aGRIni[4][3], {|x| Upper(x[2]) = "PARTYPE"})][3]
					_aPar	:= _aGRIni[4][3]
				EndIf
				_cMonthrun 	:= _aGRIni[5][3]
				_cDayWkrun 	:= _aGRIni[6][3]
				_cLastRun 	:= _aGRIni[7][3]
				_cElapRun 	:= _aGRIni[8][3]

				If Empty(_cLastRun)		/* Ignora o Job - Nao Executa */
					Loop
				EndIf

				/* Protecao contra problemas no arquivo INI. */
				If Empty(_cJobName) 	.Or. Empty(_cProg) 		.Or. ;
				   Empty(_cEnv) 		.Or. Empty(_cMonthrun)	.Or. ;
				   Empty(_cDayWkrun)
				
					/* renomeia o arquivo para outra extensao que nao seja ini */
					__CopyFile("\jobcall\" + aJobs[_nI][1], "\jobcall\" + FileNoExt(aJobs[_nI][1]) + ".err")
					
					/* apaga o arquivo para nao dar mais erro (independente de ter o backup) */
					FErase("\jobcall\" + aJobs[_nI][1])
				
					/* Tenta recuperar o backup */
					If File("\jobcall\bkpini\" + aJobs[_nI][1])
						/* Copio o backup */
						If __CopyFile("\jobcall\bkpini\" + aJobs[_nI][1], "\jobcall\" + aJobs[_nI][1])
							_lBkp := .T.
						Else
							U_DEVFUN01('helitom.silva@hotmail.com','CallJob - Erro ao recuperar arquivo de controle ' + aJobs[_nI][1],' Favor Verificar ! ',,,{})
						EndIf
					Else
						U_DEVFUN01('helitom.silva@hotmail.com','CallJob - Nao ha backup do arquivo de controle ' + aJobs[_nI][1] + '!',,,{})
					EndIf
				
				EndIf
			
				/* Se houve recuperacao de arquivo pelo bkp. */
				If _lBkp
				
					_lBkp := .F.
					Console('Recarregando parametros do controle...')
				
					/* Carrega todos os registros importantes do INI */
					_aGRIni := {}
					aAdd( _aGRIni , {"parexec","jobname"	,""})		/* 1 */
					aAdd( _aGRIni , {"parexec","funname"	,""})		/* 2 */
					aAdd( _aGRIni , {"parexec","envname"	,""})		/* 3 */
					aAdd( _aGRIni , {"mvparam","*"		 	,""})		/* 4 {1,2,{ {1,2,3}  , {1,2,3} }} */
					aAdd( _aGRIni , {"runtime","monthrun"	,""})		/* 5 */
					aAdd( _aGRIni , {"runtime","daywkrun"	,""})		/* 6 */
					aAdd( _aGRIni , {"runtime","lastrun"	,""})		/* 7 */
					aAdd( _aGRIni , {"runtime","elaprun"	,""})		/* 8 */
				
					U_DEVFUN03("le", _aGRIni, "\jobcall\" + aJobs[_nI][1])
	
					_cJobName 	:= _aGRIni[1][3]
					_cProg 		:= _aGRIni[2][3]
					_cEnv		:= _aGRIni[3][3]
					If !Empty(_aGRIni[4][3])
						_cTPar 	:= _aGrIni[4][3][aScan(_aGRIni[4][3], {|x| Upper(x[2]) = "PARTYPE"})][3]
						_aPar	:= _aGRIni[4][3]
					EndIf
					_cMonthrun 	:= _aGRIni[5][3]
					_cDayWkrun 	:= _aGRIni[6][3]
					_cLastRun 	:= _aGRIni[7][3]
					_cElapRun 	:= _aGRIni[8][3]
				
				EndIf

				If Empty(_cLastRun)		/* Ignora o Job - Nao Executa */
					Loop
				EndIf
			
				/* Tratamento do campo _cLastRun (so mantenho o valor se for execucao unica no dia) */
				If !("*" $ _cElapRun)
					_cLastRun := "00:00:00"
				EndIf
			
				/* Looping para pegar os parametros de execucao (MV_PAR01, MV_PAR02, etc...) */
				If !Empty(_cTPar)
					For _nZ := 1 To Len(_aPar)
						If 'MVPAR' $ _aPar[_nZ][2]
							aAdd( _aParJ , StrTran(Lower(_aPar[_nZ][3]),'ddatabase','Date()') )
						EndIf
					Next _nI
				EndIf
			
				/*Adiciona no Array de Trabalho Principal */
				/*                     1             2        3       4      5         6           7           8         9        10 */   
				aAdd( aJobRun , {aJobs[_nI][1], _cJobName, _cProg, _cEnv, _cTPar, _cMonthRun, _cDayWkRun, _cLastRun, _cElapRun, _aParJ} )
			
			Next _nI
		
		EndIf
	
		/* Verifica se ha agendamentos */
		If !Empty(aJobRun)
			Console('[' + cValToChar(Len(aJobs)) + '] Job(s) agendados...')
		EndIf
	
		/* Looping de Trabalho */
		For _nI := 1 To Len(aJobRun)

			/* Variavel de Log */
			_cParLog := ""

			/* Testa se ja nao ha mais Threads do que o configurado */
			While CountJob(_nMaxJobs)
				Sleep(10000)
			EndDo

			If CheckRun(@aJobRun[_nI])
			
				/* Re-define algumas variaveis de controle */
				_cPar		:= ""
				_cParJ		:= ""
				_aPar		:= {}
				_aParJ		:= {}

				If aJobRun[_nI][5] $ 'aA'
				
					For _nX := 1 To Len(aJobRun[_nI][10])
						_cPar 	:= StrTran(aJobRun[_nI][10][_nX], Chr(34), Chr(39))		//Chr(34) = "    Chr(39) = '
						_cPar 	:= If(Empty(_cPar), "''", _cPar)
						_cParLog += _cPar + ","
						aAdd( _aParJ, &(_cPar) )
					Next _nX
				
					/* Adiciona o lDebug sempre como ultimo parametro */
					aAdd( _aParJ , _lDebug )
					
					/* Starta o Job
					   Demonstro e gravo a Hora da execucao. */
					Console('Executando Job - inicio em [' + Time() + ']')
					Console('Linha: ' + aJobRun[_nI][3] + '({' + _cParLog + If(_lDebug, '.T.', '.F.') + '})')
					StartJob(aJobRun[_nI][3], aJobRun[_nI][4], .F., _aParJ)
					If aJobRun[_nI][9]  = "**:**:**"
						aJobRun[_nI][9] := "**!**!**"
						U_DEVFUN03("gr", {{"runtime", "elaprun", "**!**!**"}}, "\jobcall\" + aJobRun[_nI][1])
					Else
						aJobRun[_nI][8] := Time()
						//U_DEVFUN03("gr",{{"runtime","lastrun",Time()}},"\jobcall\"+aJobs[_nI][1])
					EndIf

				ElseIf aJobRun[_nI][5] $ 'uU'
				
					For _nX := 1 To Len(aJobRun[_nI][10])
						_cPar  	 := StrTran(aJobRun[_nI][10][_nX], Chr(34), Chr(39))		//Chr(34) = "    Chr(39) = '
						_cPar  	 := If(Empty(_cPar),"''",_cPar)
						_cParLog += _cPar + ","
						_cParJ 	 += _cPar + ','
					Next _nX
				
					/* Adiciona o lDebug sempre como ultimo parametro */
					_cParJ += If(_lDebug,'.T.','.F.')
					
					// _cParJ 	:= Substr(_cParJ,1,Len(_cParJ)-1) /* Nao precisa mais, encerro com ldebug sem virgula */
					_bBloco  := MontaBlock("{|| StartJob('" + aJobRun[_nI][3] + "','" + aJobRun[_nI][4] + "',.F.," + _cParJ + ")}")
				
					/* Demonstro e gravo a Hora da execucao. */
					Console('Executando Job - inicio em [' + Time() + ']')
					Console('Linha: ' + aJobRun[_nI][3] + '(' + _cParLog + If(_lDebug, '.T.', '.F.') + ')')
					
					/* Starta o Job */
					Eval(_bBloco)
					If aJobRun[_nI][9]  = "**:**:**"
						aJobRun[_nI][9] := "**!**!**"
						U_DEVFUN03("gr",{{"runtime", "elaprun", "**!**!**"}}, "\jobcall\" + aJobRun[_nI][1])
					Else
						aJobRun[_nI][8] := Time()
						//U_DEVFUN03("gr",{{"runtime","lastrun",Time()}},"\jobcall\" + aJobs[_nI][1])
					EndIf

				Else
					/* Demonstro e gravo a Hora da execucao. */
					Console('Executando Job - inicio em [' + Time() + ']')
					Console('Linha: ' + aJobRun[_nI][3] + '()')
					StartJob(aJobRun[_nI][3], aJobRun[_nI][4], .F.)
					If aJobRun[_nI][9]  = "**:**:**"
						aJobRun[_nI][9] := "**!**!**"
						U_DEVFUN03("gr",{{"runtime","elaprun","**!**!**"}},"\jobcall\" + aJobRun[_nI][1])
					Else
						aJobRun[_nI][8] := Time()
						//U_DEVFUN03("gr",{{"runtime","lastrun",Time()}},"\jobcall\" + aJobs[_nI][1])
					EndIf
				EndIf
			EndIf
		
			_cPar		:= ""
			_cParJ		:= ""
			_aPar		:= {}
			_aParJ		:= {}
			_cJobName	:= "* CALLJOB *"
		
		Next _nI
	
		/* ** Debug ** */
		//Reset Environment
		//Return
	
		/* Espera aproximadamente 5 segundos */
		nStandBy := 5
		Console('Job em Stand-By - inicio em [' + cValToChar(nStandBy) + 's]')
		PtInternal(1, _cPtMsg + ' - inicio em [' + cValToChar(nStandBy) + 's]')
		For _nI := 1 To nStandBy
			Sleep(1000)
			If Mod(_nI, 10) = 0
				Console('Job em Stand-By - inicio em [' + cValToChar(nStandBy - _nI) + 's]')
				PtInternal(1, _cPtMsg + ' - inicio em [' + cValToChar(nStandBy - _nI) + 's]')
			EndIf
			if File("\jobcall\mod.off") .Or. File("\jobcall\mod.res") .Or. !TempoJob()
				Exit
			EndIf
		Next _nI
		PtInternal(1, _cPtMsg)
	
	EndDo

	/* Este reset provavelmente nao vai ser executado nunca. */
	Reset Environment

Return


/*/{Protheus.doc} ParamJob
@description Carrega os parametros gerais de execucao do job

@author Julio Storino
@since  23/04/2013

/*/
Static Function ParamJob

	/* Carrega Parametros Gerais do Job */
	If File("\jobcall\calljob.cfg")
		
		/* Carrega os parametros do Job */
		_aGRIni := {}
		aAdd( _aGRIni , {"parexec","maxjobs"	,""})		/* 1 */
		aAdd( _aGRIni , {"parexec","indebug"	,""})		/* 2 */
		aAdd( _aGRIni , {"parexec","monthrun"	,""})		/* 3 */
		aAdd( _aGRIni , {"parexec","daywkrun" 	,""})		/* 4 */
		aAdd( _aGRIni , {"parexec","startrun"	,""})		/* 5 */
		aAdd( _aGRIni , {"parexec","stoprun"	,""})		/* 6 */

		U_DEVFUN03("le",_aGRIni,"\jobcall\calljob.cfg")

		/* MaxJobs */
		If U_HSONUMEROS(AllTrim(_aGRIni[1][3]), .F.)
			_nMaxJobs 	:= Val(_aGRIni[1][3])
		EndIf

		/* lDebug */
		If !Empty(_aGRIni[2][3]) .And. (Upper(AllTrim(_aGRIni[2][3])) $ "ON|OFF")
			_lDebug := Upper(AllTrim(_aGRIni[2][3])) == "ON"
		EndIf

		/* Dia do Mes */
		If !Empty(_aGRIni[3][3])
			_cMonthJob := lower(AllTrim(_aGRIni[3][3]))
		EndIf

		/* Dia da Semana */
		If !Empty(_aGRIni[4][3])
			_cDayWkJob := lower(AllTrim(_aGRIni[4][3]))
		EndIf

		/* Hora de Inicio */
		If !Empty(_aGRIni[4][3])
			_cStartJob := AllTrim(_aGRIni[5][3])
		EndIf
	
		/* Hora de Fim */
		If !Empty(_aGRIni[4][3])
			_cStopJob := AllTrim(_aGRIni[6][3])
		EndIf
		
	Else
	
		cDefCFG := '[PAREXEC]' + CR
		cDefCFG += 'MAXJOBS=15' + CR + CR
		cDefCFG += 'INDEBUG=ON' + CR + CR
		cDefCFG += 'MONTHRUN=ALL' + CR + CR
		cDefCFG += 'DAYWKRUN=SEG-TER-QUA-QUI-SEX-SAB' + CR + CR
		cDefCFG += 'STARTRUN=02:30' + CR + CR
		cDefCFG += 'STOPRUN=20:30' + CR + CR
		
		MemoWrite('\jobCall\calljob.cfg', cDefCFG)
			
	EndIf

Return


/*/{Protheus.doc} TempoJob
@description valida a existencia do job no tempo

@author Julio Storino
@since  22/04/2013

/*/
Static Function TempoJob

	Local _lRet	:= .T.

	_lRet := (_cMonthJob	= "all") .Or. (cValToChar(Day(Date())) $ _cMonthJob)

	If _lRet
		_lRet := (_cDayWkJob	= "all") .Or. (_aWeek[Dow(Date())] $ _cDayWkJob)
	EndIf

	If _lRet
		_lRet := Time() >= _cStartJob
	EndIf

	If _lRet
		_lRet := Time() <= _cStopJob
	EndIf

Return _lRet


/*/{Protheus.doc} CheckRun
@description Funcao auxiliar para iniciar o schedule da integracao Protheus

@author Julio Storino
@since  29/02/2012

/*/
Static Function CheckRun(aJobRun)

	Local _lRet			:= .F.
	Local _nI			:= 0
	Local _cMvPar		:= ""

	Local _lExecHr		:= .F.
	Local _lExecDay		:= .F.
	Local _lExecWek		:= .F.

	Local _cMonthrun	:= ""
	Local _cDayWkrun 	:= ""
	Local _cLastDay		:= ""
	Local _cLastRun		:= ""

	Local _aMonthrun	:= {}
	Local _aDayWkrun	:= {}
	Local _cNextDay		:= ""
	Local _cHrProx		:= ""
	Local _cHrPass		:= ""
	Local _cHrNext		:= ""
	Local _aTimTmp		:= {}
	Local _nBarra		:= 0

	_cJob		:= aJobRun[1]
	_cJobName 	:= aJobRun[2]
	_cMonthrun 	:= aJobRun[6]
	_cDayWkrun 	:= aJobRun[7]
	_cLastRun 	:= aJobRun[8]
	_cElapRun 	:= aJobRun[9]

	If (_nBarra := Len(AllTrim(_cJobName))) > 10
		_nBarra := _nBarra - 10
	Else
		_nBarra := 0
	EndIf

	Console(Replicate('-',55-_nBarra))

	If !Empty(_cLastRun)
	
		Console('Verificando...')
	
		/* VALIDA EXECUCAO DO DIA DO MES */
		Do Case
		Case Empty(_cMonthrun) .Or. (Lower(AllTrim(_cMonthrun))="all")
			Console('No mes [Todos os dias]')
			Console('Ultima [hoje] Proxima [hoje]')
			_lExecDay	:= .T.
		Case StrZero(Day(Date()),2) $ _cMonthrun
			_aMonthrun := StrTokArr(_cMonthrun,' /\_-:;|')
			aEval( _aMonthrun , {|x| IIf(Val(x)<Day(Date()),_cLastDay:=x,Nil)})
			_cLastDay := IIf(Empty(_cLastDay),_aMonthrun[Len(_aMonthrun)],_cLastDay)
			Console('No mes [' + _cMonthrun + ']')
			Console('Ultima [dia ' + _cLastDay  + '] Proxima [hoje]')
			_lExecDay	:= .T.
		OtherWise
			_aMonthrun := StrTokArr(_cMonthrun,' /\_-:;|')
			aEval( _aMonthrun , {|x| IIf(Val(x) < Day(Date()), _cLastDay := x, Nil)})
			_cLastDay := IIf(Empty(_cLastDay),_aMonthrun[Len(_aMonthrun)], _cLastDay)
			aEval( _aMonthrun , {|x| IIf(Val(x)> Day(Date()).And.Empty(_cNextDay), _cNextDay := x, Nil)})
			_cNextDay := IIf(Empty(_cNextDay),_aMonthrun[1],_cNextDay)
			If Day(Date()) > 	Val(_cNextDay)		/* Vai rodar so mes que vem */
				_cHrPass := StrZero(StoD(	IIf(Month(Date())=12,cValToChar(Year(Date()) + 1),cValToChar(Year(Date()))) + ;
					IIf(Month(Date())=12,'01',StrZero(Month(Date()) + 1,2)) + _cNextDay) - Date(),2)
			Else
				_cHrPass := StrZero(Val(_cNextDay) - Day(Date()),2)
			EndIf
			Console('No mes [' + _cMonthrun + ']')
			Console('Ultima [dia ' + _cLastDay + '] Proxima [dia ' + _cNextDay + ' daqui ' + _cHrPass + ' dia(s)]')
			Return( .F. )
		EndCase
	
		/* VALIDA EXECUCAO DO DIA DA SEMANA */
		Do Case
		Case Empty(_cDayWkrun) .Or. (Lower(AllTrim(_cDayWkrun))="all")
			Console('Na semana [todos os dias]')
			Console('Ultima... [hoje] Proxima [hoje]')
			_lExecWek	:= .T.
		Case Upper(Left(_aWeek[Dow(Date())], 3)) $ _cDayWkrun
			_aDayWkrun := StrTokArr(_cDayWkrun,' /\_-:;|')
			For _nI := 1 To Len(_aDayWkrun)
				Do Case
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'dom'
					_aDayWkrun[_nI] := 1
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'seg'
					_aDayWkrun[_nI] := 2
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'ter'
					_aDayWkrun[_nI] := 3
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'qua'
					_aDayWkrun[_nI] := 4
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'qui'
					_aDayWkrun[_nI] := 5
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'sex'
					_aDayWkrun[_nI] := 6
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'sab'
					_aDayWkrun[_nI] := 7
				EndCase
			Next _nI
			aEval( _aDayWkrun , {|x| IIf(x<Dow(Date()),_cLastDay:=x,Nil)})
			_cLastDay := IIf(Empty(_cLastDay),_aDayWkrun[Len(_aDayWkrun)],_cLastDay)
			Console('Na semana [' + _cDayWkrun + ']')
			Console('Ultima... [' + _aWeek[_cLastDay] + '] Proxima [hoje]')
			_lExecWek	:= .T.
		OtherWise
			_aDayWkrun := StrTokArr(_cDayWkrun,' /\_-:;|')
			For _nI := 1 To Len(_aDayWkrun)
				Do Case
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'dom'
					_aDayWkrun[_nI] := 1
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'seg'
					_aDayWkrun[_nI] := 2
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'ter'
					_aDayWkrun[_nI] := 3
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'qua'
					_aDayWkrun[_nI] := 4
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'qui'
					_aDayWkrun[_nI] := 5
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'sex'
					_aDayWkrun[_nI] := 6
				Case Lower(Left(AllTrim(_aDayWkrun[_nI]), 3)) = 'sab'
					_aDayWkrun[_nI] := 7
				EndCase
			Next _nI
			aEval( _aDayWkrun, {|x| IIf(x < Dow(Date()), _cLastDay := x, Nil)})
			_cLastDay := IIf(Empty(_cLastDay), _aDayWkrun[Len(_aDayWkrun)], _cLastDay)
			aEval( _aDayWkrun, {|x| IIf(x>Dow(Date()) .And. Empty(_cNextDay), _cNextDay := x, Nil)})
			_cNextDay := IIf(Empty(_cNextDay),_aDayWkrun[1],_cNextDay)
			
			If Dow(Date()) > 	_cNextDay		/* Vai rodar so na semana que vem */
				_cHrPass := StrZero(7-(Dow(Date()) - _cNextDay), 2)
			Else
				_cHrPass := StrZero(_cNextDay - Dow(Date()), 2)
			EndIf
			Console('Na semana [' + _cDayWkrun + ']')
			Console('Ultima... [' + _aWeek[_cLastDay] + '] Proxima [' + _aWeek[_cNextDay] + ' daqui ' +  _cHrPass + ' dia(s)]')
			
			Return( .F. )
		EndCase
	
		/* VALIDA EXECUCAO DA HORA */
		If Empty(_cElapRun)
			_cElapRun := "02:30:00"
		EndIf
		If AllTrim(_cElapRun) = "**:**:**"				/* Tem que executar no horario ! */
		
			_cHrPass := ElapTime( _cLastRun , Time() )
			_cHrProx := RElapTime( Time() , _cLastRun)
			Console('No dia [Unica as ' + _cLastRun + ']')
		
			If (_lExecHr := (_cHrPass >= "00:00:00" .And. _cHrPass <= "01:00:00"))
				Console('Ultima [as ' + _cLastRun + '] Proxima [as ' + _cLastRun + ' imediatamente]')
			Else
				Console('Ultima [as ' + _cLastRun + '] Proxima [as ' + _cLastRun + ' daqui ' + _cHrProx + ']')
			EndIf
		
		ElseIf AllTrim(_cElapRun) = "**!**!**"			/* Ja Executou no horario ! */
		
			_cHrPass := ElapTime( _cLastRun, Time() )
			_cHrProx := RElapTime( Time() , _cLastRun )
			Console('No dia [Unica as ' + _cLastRun + ']')
			Console('Ultima [as ' + _cLastRun + '] Proxima [as ' + _cLastRun + ' daqui ' + _cHrProx + ']')
		
			If _cHrPass > "01:00:00"
				aJobRun[8] := "**:**:**"
				U_DEVFUN03("gr", {{"runtime", "elaprun", "**:**:**"}}, "\jobcall\" + _cJob)
			EndIf
		
		Else
			_cHrPass := ElapTime( _cLastRun, Time() )
		
			/* Ajusta o retorno da funcao SomaHoras */
			_aTimTmp 	:= StrTokArr(StrTran(cValToChar(SomaHoras( StrTran(_cLastRun, '.', ':'), _cElapRun)), '.', ':') + ":00", ":")
			aScan( {1,2,3} , {|x| IIf(Len(_aTimTmp)<x,aAdd(_aTimTmp, "00"), _aTimTmp[x] := PadL(Val(_aTimTmp[x]), 2, '0'))})
			_aTimTmp[1] := IIf( Val(_aTimTmp[1]) >= 24 , StrZero(Val(_aTimTmp[1])-24,2) , _aTimTmp[1] )
			_cHrNext    := PadL(AllTrim(_aTimTmp[1]),2,"0") + ":" + PadL(AllTrim(_aTimTmp[2]),2,"0") + ":" + PadL(AllTrim(_aTimTmp[3]),2,"0")
		
			If Time() = _cHrNext
				_cHrProx := " imediatamente"
			ElseIf Time() > _cHrNext
				_cHrProx := " imediatamente"
			Else
				_cHrProx := RElapTime( Time() , _cHrNext )
				_cHrProx := ' daqui ' + _cHrProx
			EndIf
		
			Console('No dia [a cada ' + _cElapRun + ']')
			Console('Ultima [as ' + _cLastRun + '] Proxima [as ' + _cHrNext + _cHrProx + ']')
		
			_lExecHr := (_cHrPass >= _cElapRun)
		EndIf
	
		_lRet := ( _lExecDay .And. _lExecWek .And. _lExecHr )
	
	Else
		Console('Impossivel determinar ultima execucao - [Job ignorado]')
		_lRet := .F.
	EndIf

Return _lRet


/*/{Protheus.doc} Console
@description funcao para jogar o conout no console

@author Julio Storino
@since  20/04/2013

/*/
Static Function Console(cMsg)

	If _lDebug
		ConOut(RegDt()+cMsg)
	EndIf

Return


/*/{Protheus.doc} RegDt
@description Funcao auxiliar para registrar data e hora do conout

@author Julio Storino
@since  29/02/2012

/*/
Static Function RegDt

	Local _cDate  := Substr(DtoC(Date()),4,2) + '/' + Substr(DtoC(Date()),1,2) + '/' + Substr(DtoC(Date()),7,2)

	Local _cRegDt := '[' + _cDate + ' ' + Time() + '] CJ [' + _cJobName + '] '

Return _cRegDt


/*/{Protheus.doc} RElapTime
@description Retorna o tempo que falta para timenow chegar a timeago

@author Julio Storino
@since  07/03/2012

/*/
Static Function RElapTime(TimeNow,TimeAgo)

	Local _cRet		:= RTString( IIf(TimeAgo<TimeNow,86400,0) + (Secs(TimeAgo) - Secs(TimeNow)))

Return _cRet


/*/{Protheus.doc} RTString
@description Funcao auxiliar da funcao relaptime

@author Julio Storino
@since  07/03/2012

/*/
Static Function RTString( nSeconds )

	Local cTime := Time()                  /* Time() string in system time format */
	Local cRet 	:= PadL( Int( (nSeconds / 3600) % 24 ), 2, "0" ) + SubStr( cTime, 3, 1 ) + ;
				   PadL( Int( (nSeconds /   60) % 60 ), 2, "0" ) + SubStr( cTime, 6, 1 ) + ;
				   PadL( Int( (nSeconds       ) % 60 ), 2, "0" )

Return cRet


/*/{Protheus.doc} CountJob
@description Funcao auxiliar, conta as jobs em execucao 

@author Julio Storino
@since  22/04/2013

/*/
Static Function CountJob(nMax)

	Local _nY		:= 0
	Local lRet		:= .F.
	Local nCount	:= 0
	Local aThreTmp	:= GetUserInfoArray()

	For _nY := 1 To Len(aThreTmp)
		If ("calljob" $ Lower(AllTrim(aThreTmp[_nY][11]))) .Or. ("jobcall" $ Lower(AllTrim(aThreTmp[_nY][01])))
			nCount++
		EndIf
	Next _nY

Return ( nCount > nMax )