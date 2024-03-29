#Include 'Protheus.ch'

#DEFINE	CR	Chr(13) + Chr(10)

/*{Protheus.doc} RUNUPDPE
	
@author Helitom Silva
@since 24/12/2013
@version 1.0		

@return ${Nil}, ${Nil}

@description Ponto de Entrada do programa U_RUNUPD e � usado para carregar o Combobox de 
             sele��o dos Grupos dos compatibilizadores que deseja executar,
             retornando um Array unidimensional com o Grupo e Descri��o.
             
             Caso e se PE nao existe ser� exibido um campo para informar o nome do Grupo de 
             compatibilizadores.

*/
User Function TSTRUNUPDPE()
	
	Local aGrupos := {}
	
	//A cada item do Array deve ser informado: {Grupo=Descri��o do Grupo}
	//Grupo � a fun��o que chama os compatibilizadores.
	//Exemplo: aGrupos := {'UPD001=Compatibilizadores do UPD001','UPD002=Compatibilizadores do UPD001','UPD002=Compatibilizadores do UPD001'}
	
	aGrupos := {'TSTUPD=Compatibilizadores Teste'}
	
Return aGrupos 