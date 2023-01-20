//--------------------------------------------------------------------------------------------
// 								SELECT .. FROM
//--------------------------------------------------------------------------------------------
// Devido a limita��es na utiliza��o do xTranslate, a princ�pio a sintaxe para JOINS �:
// FROM (tabela1 WHERE Condicao1, tabela2 WHERE Condicao2,...)
// O join entre as tabelas deve ser feito via par�metros. Por exemplo:
// TAB SB2, TAB SB1 WHERE B1_CODPROD = ?SB2->B2_CODPROD?
//--------------------------------------------------------------------------------------------
#XTRANSLATE PREPARE SELECT <xlist,...> FROM (<aTables,...>) ;
				[GROUP BY <bGroup>] ;
				[TOP <nTop>] ;
					=> ISAMQry():New({ <aTables> }, { <xList> }, <{bGroup}>, <nTop>)

#XTRANSLATE SELECT <xlist,...> FROM (<aTables,...>) ;
				[GROUP BY <bGroup>] ;
				[TOP <nTop>] ;
					=> ISAMQry():New({ <aTables> }, { <xList> }, <{bGroup}>, <nTop>)

#XTRANSLATE EXECUTE SELECT <xlist,...> FROM (<aTables,...>) ;
				[GROUP BY <bGroup>] ;
				[TOP <nTop>] ;
				[INTO TABLE (<aCampos,...>)] [COUNT TO <nCount>] ;
				[PROC (<bProcedure,...>) ] ;
				[PARAMS <aParams>] ;
					=> ISAMExec(ISAMQry():New({<aTables>},{<xList>},<{bGroup}>,<nTop>),[{ <aCampos> }][{|aLine| <bProcedure> }],[@<nCount>], <aParams>)

#XTRANSLATE XSELECT <xlist,...> FROM (<aTables,...>) ;
				[GROUP BY <bGroup>] ;
				[TOP <nTop>] ;
				[INTO TABLE (<aCampos,...>)] [COUNT TO <nCount>] ;
				[PROC (<bProcedure,...>) ] ;
				[PARAMS <aParams>] ;
					=> ISAMExec(ISAMQry():New({<aTables>},{<xList>},<{bGroup}>,<nTop>),[{ <aCampos> }][{|aLine| <bProcedure> }],[@<nCount>], <aParams>)
//--------------------------------------------------------------------------------------------
// 								UPDATE ... SET
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como c�digo/macro)
//--------------------------------------------------------------------------------------------

#XCOMMAND UPDATE &<cTable> SET (<xlist,...>) ;
				VALUES (<xValues,...>) ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[COUNT TO <nCount>] ;
					=> dbUpdate( { <"xList"> }, { <xValues> }, { <cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder> }, [@<nCount>])

//--------------------------------------------------------------------------------------------
// 								UPDATE ... SET
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como string)
//--------------------------------------------------------------------------------------------

#XCOMMAND UPDATE <cTable> SET (<xlist,...>) ;
				VALUES (<xValues,...>) ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[COUNT TO <nCount>] ;
					=> dbUpdate( { <"xList"> }, { <xValues> }, { <"cTable">, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder> }, [@<nCount>])

//--------------------------------------------------------------------------------------------
// 								INSERT ... INTO
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como c�digo/macro)
//--------------------------------------------------------------------------------------------

#XCOMMAND INSERT INTO &<cTable> (<xlist,...>) ;
				VALUES (<xValues,...>) ;
					=> dbInsert({ <"xList"> }, { <xValues> }, <cTable>)

//--------------------------------------------------------------------------------------------
// 								INSERT ... INTO
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como String)
//--------------------------------------------------------------------------------------------

#XCOMMAND INSERT INTO <cTable> (<xlist,...>) ;
				VALUES (<xValues,...>) ;
					=> dbInsert({ <"xList"> }, { <xValues> }, <"cTable">)

//--------------------------------------------------------------------------------------------
// 								DELETE FROM
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como c�digo/macro)
//--------------------------------------------------------------------------------------------

#XCOMMAND DELETE FROM &<cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[COUNT TO <nCount>] ;
					=> dbDelFrom({ <cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder> }, [@<nCount>])

//--------------------------------------------------------------------------------------------
// 								DELETE FROM
//--------------------------------------------------------------------------------------------
// Efetuado sobre a tabela padr�o (ctable tratado como sTRING)
//--------------------------------------------------------------------------------------------

#XCOMMAND DELETE FROM <cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[COUNT TO <nCount>] ;
					=> dbDelFrom({ <"cTable">, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder> }, [@<nCount>])

//--------------------------------------------------------------------------------------------
// 								TRANSLATES DE SOURCES
//--------------------------------------------------------------------------------------------
// Os xTranslates abaixo definem fontes de dados a serem utilizadas na cl�usula JOIN FROM.
//--------------------------------------------------------------------------------------------

//TABELA PADR�O, ONDE CTABLE SER� TRATADA COMO STRING
#XTRANSLATE QRY <cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<"cTable">, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//TABELA PADR�O, ONDE CTABLE SER� TRATADA COMO C�DIGO/MACRO
#XTRANSLATE QRY &<cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//TABELA LOCAL, ONDE CTABLE SER� TRATADA COMO STRING
#XTRANSLATE TAB <cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<"cTable">, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//TABELA LOCAL, ONDE CTABLE SER� TRATADA COMO C�DIGO/MACRO
#XTRANSLATE TAB &<cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//ARRAY
#XTRANSLATE ARR <cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//OBJ
#XTRANSLATE OBJ <cTable> ;
				[WHERE &<cWhere2>] [WHERE (<cWhere2>)] [WHERE <cWhere>] ;
				[FOR <bFor>] ;
				[ORDER <nOrder>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> {<cTable>, <"cWhere"> <cWhere2>, <{bFor}>, <nOrder>, <cAlias> <"cAlias2">}

//TABELA VIA DBACCESS, ONDE CTABLE � TRATADA COMO UMA STRING
#XTRANSLATE TOP <cTable> ;
				[WHERE &<cWhere>] [WHERE <cWhere2>] ;
				[FOR <bFor>] ;
				[ORDER &<cOrder>] [ORDER <cOrder2>] ;
				[SELECT &<Select>] [SELECT <Select2>] ;
				[GROUP BY &<cGroup>] [GROUP BY <cGroup2>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> { DbObjSql({ <"Select"><Select2> },<"cTable">,<cWhere><"cWhere2">,<cGroup><"cGroup2">,<"cOrder"><cOrder2>),,<bFor>,<cAlias><"cAlias2">}

//TABELA VIA DBACCESS, ONDE CTABLE � TRATADA COMO C�DIGO/MACRO
#XTRANSLATE TOP &<cTable> ;
				[WHERE &<cWhere>] [WHERE <cWhere2>] ;
				[FOR <bFor>] ;
				[ORDER &<cOrder>] [ORDER <cOrder2>] ;
				[SELECT &<Select,...>] [SELECT <Select2,...>] ;
				[GROUP BY &<cGroup>] [GROUP BY <cGroup2>] ;
				[ALIAS &<cAlias>] [ALIAS <cAlias2>] ;
					=> { DbObjSql( { <"Select"><Select2> },<cTable>,<cWhere><"cWhere2">,<cGroup><"cGroup2">,<"cOrder"><cOrder2>),,<bFor>,<cAlias><"cAlias2">}

//--------------------------------------------------------------------------------------------
// 								TERMOS PARA CL�USULA SELECT
//--------------------------------------------------------------------------------------------
// Os termos abaixo s�o utilizados para aplica��o na cl�usula select, com fun��es de agrega��o
// ou acesso normal a campos
//--------------------------------------------------------------------------------------------
#XTRANSLATE #SUM(<Expression>)  => { "SUM", {|| <Expression> } }
#XTRANSLATE #CONC(<Expression>)  => { "STRSUM", {|| <Expression> } }
#XTRANSLATE #STRSUM(<Expression>)  => { "STRSUM", {|| <Expression> } }
#XTRANSLATE #AVG(<Expression>)  => { "AVG", {|| <Expression> } }
#XTRANSLATE #VALUE(<Expression>) => { "VALUE", {|| <Expression> } }
#XTRANSLATE #MAX(<Expression>)  => { "MAX", {|| <Expression> } }
#XTRANSLATE #MIN(<Expression>)  => { "MIN", {|| <Expression> } }
#XTRANSLATE #COUNT(<Expression>) => { "COUNT", {|| <Expression> } }
#XTRANSLATE #FIRST(<Expression>) => { "FIRST", {|| <Expression> } }
#XTRANSLATE #LAST(<Expression>) => { "LAST", {|| <Expression> } }
#XTRANSLATE #PONDAVG(<Expression1>,<Expression2>) => { "PONDAVG", {|| { <Expression1>, <Expression2> } } }
#XTRANSLATE #PONDAVG(<Expression>) => { "PONDAVG", {|| <Expression> } }
#XTRANSLATE #(<Expression>) => { "VALUE", {|| <Expression> } }

//--------------------------------------------------------------------------------------------
// 								Vetor associativo
//--------------------------------------------------------------------------------------------
// xTransalte para arrays associativos, baseados na classe HashMap
//--------------------------------------------------------------------------------------------

#XTRANSLATE Array\(\#\) => HashMap():New()
#XTRANSLATE \[\#<xExpression>,<xExpression2> => :Get(<xExpression>)\[\#<xExpression2>
#XTRANSLATE \[\#<xExpression>\] := <xValue> => :Put(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] += <xValue> => :Sum(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] -= <xValue> => :Minus(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] *= <xValue> => :Multiply(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] /= <xValue> => :Divide(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] ^= <xValue> => :Power(<xExpression>, <xValue>)
#XTRANSLATE \[\#<xExpression>\] ++ <xValue> => :Sum(<xExpression>, 1)
#XTRANSLATE \[\#<xExpression>\] -- <xValue> => :Minus(<xExpression>, 1)
#XTRANSLATE \[\#<xExpression>\] => :Get(<xExpression>)
