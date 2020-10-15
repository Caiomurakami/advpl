#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'TMSAC13.ch'

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC13()
Configurador TMS X FreteBras

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC13()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DM1")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAC13")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription( STR0001 + " " + STR0002 )		//"Configurador Fretbras"
oBrowse:Activate()

Return

/*/-----------------------------------------------------------
{Protheus.doc} menudef()
Menu da rotina

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008  ACTION "AxPesqui"        	OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAC13" 	OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAC13" 	OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAC13" 	OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSAC13" 	OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0009  ACTION "TMSAC13Con()" 	OPERATION 6 ACCESS 0 // "Testar Conexão"

Return(aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
Local oModel	:= Nil		// Objeto do Model
Local oStruDM1	:= Nil		// Recebe a Estrutura da tabela DLU
Local bCommit 	:= { |oModel| CommitMdl(oModel) }
Local bPosValid := { |oModel| PosVldMdl(oModel) }

oStruDM1:= FWFormStruct( 1, "DM1" )

oModel := MPFormModel():New( "TMSAC13",,bPosValid, bCommit , /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDM1',, oStruDM1,,,/*Carga*/ ) 
oModel:GetModel( 'MdFieldDM1' ):SetDescription( STR0001 + " " + STR0002  ) 	//"Configurador Fretebras"
oModel:SetPrimaryKey({"DM1_FILIAL" , "DM1_ID"})       
oModel:SetActivate( )
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Criação da View

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDM1	:= Nil		// Recebe a Estrutura da tabela DM1
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC13")
oStruDM1 := FWFormStruct( 2, "DM1" )

oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDM1', oStruDM1 , 'MdFieldDM1')   

oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDM1','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pós-validação do modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet			:= .T. 
Local aAreaDM1      := DM1->(GetArea())

DM1->(dbSetorder(2))
If FwFldGet("DM1_MSBLQL") == "2" .And. DM1->(MsSeek(xFilial("DM1") + "2" ))

    While DM1->DM1_FILIAL + DM1->DM1_MSBLQL == xFilial("DM1") + "2" 
        
        If DM1->DM1_ID <> FwFldGet("DM1_ID")      
            lRet    := .F. 
            Help("",1,"TMSAC130000001") //-- Não é permitido mais de um ID ativos. 
            Exit
        EndIf

        DM1->(dbSkip())
    EndDo

EndIf

RestArea(aAreaDM1)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)
Local lRet	:= .T. 

lRet	:= FwFormCommit(oModel)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAFretBr()
Indica se a integração com fretebras está habilitada

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAFretBr( lTrial , nQtdFrete )
Local lRet  := .F. 

Default lTrial      := .F. 
Default nQtdFrete   := 0 

If TableInDic("DM1")

    DM1->(dbSetorder(2))
    If DM1->( dbSeek(xFilial("DM1") + "2" ) ) 
        If DM1->(ColumnPos("DM1_IDTOTV")) > 0 
            If !Empty(DM1->DM1_IDTOTV)
                lRet    := .T. 
            Else 
                lTrial  := .T. 
            EndIf 
        Else
            lTrial  := .T.     
            lRet    := .T.
        EndIf 
    EndIf
EndIf

If lTrial
    nQtdFrete   := QtdFrete()
    If nQtdFrete >= 50 
        lRet    := .F. 
    Else
        lRet    := .T. 
    EndIf 
EndIf 

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC13Con()
Verifica se a conexão está ativa

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC13Con()
Local oFrete    := Nil 
Local lRet      := .F. 

If DM1->DM1_MSBLQL == "2" .And. TMSAFretBr()

    oFrete  := TMSBCAFreteBras():New()
    cToken  := oFrete:GetAccessToken() //objeto:nomedométodo() 

    If !Empty(cToken)
        lRet    := .T. 
    EndIf

    FwFreeObj( oFrete )
EndIf

If lRet
    MsgInfo("Token: " + SubStr(cToken,1,30) )
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} QtdFrete()
Verifica se a conexão está ativa

@author Caio Murakami   
@since 17/09/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function QtdFrete()
Local aArea     := GetArea()
Local nQtde     := 0 
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

cQuery  := " SELECT COUNT(*) QTDFRETE "
cQuery  += " FROM " + RetSQLName("DM2") + " DM2 "
cQuery  += " WHERE DM2_FILIAL   = '" + xFilial("DM2") + "' "
cQuery  += " AND DM2_IDFRT      <> '' "
 
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->( !Eof() )
    nQtde   := (cAliasQry)->QTDFRETE
    (cAliasQry)->(dbSkip())
EndDo 

(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return nQtde
