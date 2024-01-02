#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} UPDUSERS
Lista os usuarios para realizar a alteração de senha.
@type function
@version 1.0 
@author geanderson.silva
@since 20/01/2023
/*/
User Function UPDUSERS

    local cUserAlias := "USERSTMP"

    BeginSql Alias cUserAlias
        SELECT
            USR_ID,
            USR_CODIGO,
            USR_NOME,
            USR_EMAIL
        FROM
            SYS_USR
        WHERE
            D_E_L_E_T_ = ' ' 
            AND USR_MSBLQL = '2'
            AND USR_ID NOT IN ('000000','001391','001242')
    EndSql

    DBSelectArea(cUserAlias)
    While (cUserAlias)->(!Eof())
        if !u_TESTEPUT((cUserAlias)->USR_ID)
            varinfo("Houve erro no usuario id ->",(cUserAlias)->USR_ID)
        endif
        (cUserAlias)->(DbSkip())
    EndDo

Return


/*/{Protheus.doc} UPDUSRPW
Função que executa o metodo PUT e altera a senha do usuario.
@type function
@version 1.0 
@author geanderson.silva
@since 20/01/2023
@param pUserId, character, código do usuario.
@return logical, Alterado com sucesso.
/*/
User Function UPDUSRPW(pUserId)

    local lRet := .f.
    local oRestClient := nil
    local cUrl := ""
    local cPath := ""
    local aHeadOut := {}

    cUrl := "http://192.168.240.48:1905/REST"
    cPath := "/api/framework/v1/users/"+pUserId+""

    cBody :=    '{'
    cBody +=    '"schemas":['       
    cBody +=    '"urn:scim:schemas:core:2.0:User",'
    cBody +=    '"urn:scim:schemas:extension:enterprise:2.0:User"'
    cBody +=    '],'
    cBody +=    '"emails": ['
    cBody +=    '{'
    cBody +=    '"value": "'+pUserId+'teste@todimo.com.br",'
    cBody +=    '"primary": true'
    cBody +=    '}'
    cBody +=    '],'
    cBody +=    '"password":"TESTE123"'
    cBody +=    '}'
    
    Aadd(aHeadOut, "Authorization: Bearer [gere um token com um usuario admin coloque aqui, sem os cochetes]")
    Aadd(aHeadOut, "Content-Type: application/json")

    oRestClient := FWRest():New(cUrl)
    oRestClient:setPath(cPath)

    if oRestClient:Put(aHeadOut,cBody)
        varinfo("Var oRestClient:GetResult()",oRestClient:GetResult())
        lRet := .t.
    else
        varinfo("Var oRestClient:GetLastError()",oRestClient:GetLastError())
    endif

    // PswOrder(1)
    // lSeek := PswSeek("GEANDERSON.SILVA",.t.)

Return lRet
