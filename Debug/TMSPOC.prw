#Include 'Protheus.ch'


User Function Repom()
Local oRepom        := Nil 
Local cToken        := ""

oRepom  := TMSBCARepomFrete():New()
oRepom:Auth()
oRepom:PaymentCreate( "M SP 01 ","000215"  )
oRepom:PaymentCancel( "M SP 01 ","000215"  )
oRepom:PaymLostDoc( "M SP 01 ","000215" , "M SP 01 " , "900000135" , "1")
oRepom:PaymReshipDoc( "M SP 01 ","000215"  , "M SP 01 " , "900000135" , "1")
oRepom:PaymDeliverDoc( "M SP 01 ","000215"  , "M SP 01 " , "900000135" , "1")
oRepom:PaymDismisDoc( "M SP 01 ","000215"  , "M SP 01 " , "900000135" , "1")
oRepom:Destroy()
/*
//oRepom:DriverCreate("000002")
//oRepom:DriverUpdate("000002")
//oRepom:DriverLock("000002",.T.,"OBSERVACAO DE LOCK")
//oRepom:HiredCreate("000001","01")
//oRepom:HiredUpdate("000001","01")
//oRepom:HiredLock("000001","01",.T.,"Lock de proprietário")
//oRepom:VehicleCreate("TSA0001",.T.,"Lock de veículo")
//oRepom:VehicleUpdate("TSA0001",.T.,"Lock de veículo")
//oRepom:VehicleLock("TSA0001",.T.,"Lock de veículo")
//oRepom:GetVeicByDoc("TSA0001")
//oRepom:RouteCreate("ENTGEN","SP","04503",.t. , {"Rodovia Castelo Branco","Rodovia Raposo Tavares"} )
/*If oRepom:ShippingCreate( "M SP 01 " , "000215" )
    oRepom:ShippingDocAdd( "M SP 01 ", "000215" ,  , "M SP 01 ", "800000120" , "1" )
    oRepom:GetShipByShip("M SP 01 ","000216")
    oRepom:ShippingMovAdd(cFilOri, cViagem, cCodveic, "06" , 300.00 )
    If oRepom:PaymentCreate(  "M SP 01 " , "000215" )
        MsgAlert("Key: " + oRepom:GetIdShipping())
    EndIf 
EndIF*/  

FwFreeObj(oRepom)
Return 

User Function IncViagem()
Local aCab      := {} 
Local aItens    := {} 
Local nOpc      := ""
Local lRet      := .T. 
Local cFilDoc   := "M SP 01 "
Local cDoc      := "800001885"
Local cSerie    := "1"
Local aMaster   := {} 
Local aGrid     := {} 
Local aVeiculos := {} 
Local aMot      := {} 
Local aDespesa  := {} 

Aadd( aCab , {"DTQ_SERTMS"  , "3"       , Nil } )
Aadd( aCab , {"DTQ_ROTA"    ,  "ENTGEN" , Nil } )

Aadd( aItens                , {} )
Aadd( aItens[Len(aItens)]   , { "DM3_SEQUEN"    , "001"    ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_FILDOC"    , cFilDoc    ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_DOC"       , cDoc   ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_SERIE"     , cSerie         ,   Nil } )

Aadd( aItens                , {} )
Aadd( aItens[Len(aItens)]   , { "DM3_SEQUEN"    , "002"    ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_FILDOC"    , cFilDoc    ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_DOC"       , "800001882"   ,   Nil } )
Aadd( aItens[Len(aItens)]   , { "DM3_SERIE"     , cSerie         ,   Nil } )

Aadd( aVeiculos , {} )
AAdd( aVeiculos[Len(aVeiculos)] , { "DTR_ITEM"      , "01"      , Nil } )
AAdd( aVeiculos[Len(aVeiculos)] , { "DTR_CODVEI"    , "OMS001"  , Nil } )

Aadd( aMot , {} )
AAdd( aMot[Len(aMot)] , { "DUP_CODMOT"    , "C00000"      , Nil } )

Aadd( aDespesa , {} )
Aadd( aDespesa[Len(aDespesa)] , { "DG_CODDES"   , "TMSCTC"  , Nil } )
Aadd( aDespesa[Len(aDespesa)] , { "DG_TOTAL"    , 200       , Nil } )
Aadd( aDespesa[Len(aDespesa)] , { "DG_BANCO"    , "001"     , Nil } )
Aadd( aDespesa[Len(aDespesa)] , { "DG_AGENCIA"  , "1279"    , Nil } )
Aadd( aDespesa[Len(aDespesa)] , { "DG_NUMCON"   , "1003057" , Nil } )

Aadd( aMaster     , {} )
Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
Aadd( aMaster[Len(aMaster)] ,  "DTQ" )

Aadd( aGrid  , {} )
Aadd( aGrid[Len(aGrid)]  , aClone(aItens) )
Aadd( aGrid[Len(aGrid)]  , "MdGridDM3")
Aadd( aGrid[Len(aGrid)]  , "DM3" )

Aadd( aGrid  , {} )
Aadd( aGrid[Len(aGrid)]  , aClone(aVeiculos) )
Aadd( aGrid[Len(aGrid)]  , "MdGridDTR")
Aadd( aGrid[Len(aGrid)]  , "DTR" )

Aadd( aGrid  , {} )
Aadd( aGrid[Len(aGrid)]  , aClone(aMot) )
Aadd( aGrid[Len(aGrid)]  , "MdGridDUP")
Aadd( aGrid[Len(aGrid)]  , "DUP" )

Aadd( aGrid  , {} )
Aadd( aGrid[Len(aGrid)]  , aClone(aDespesa) )
Aadd( aGrid[Len(aGrid)]  , "MdGridSDG")
Aadd( aGrid[Len(aGrid)]  , "SDG" )
Aadd( aGrid[Len(aGrid)]  , { nOpc , Chave }  )


lRet    := TMSExecAuto( "TMSAF60" ,  aMaster   , aGrid,  3  , .T.  )

If lRet
    MsgInfo("Incluido com sucesso","cTitulo")
EndIf

Return lRet

User Function AltViagem()
Local aCab      := {} 
Local aItens    := {} 
Local nOpc      := ""
Local lRet      := .T. 
Local cFilDoc   := "M SP 01 "
Local cDoc      := "000000167"
Local cSerie    := "534"
Local cViagem   := "003025"
Local aGrid     := {} 
Local aMaster   := {}

DTQ->( dbSetOrder(2))
If DTQ->( MsSeek( xFilial("DTQ") + "M SP 01 " + cViagem ) )

    Aadd( aCab , {"DTQ_FILORI"  , "M SP 01 "   , Nil })
    Aadd( aCab , {"DTQ_VIAGEM"  , cViagem    , Nil })
    Aadd( aCab , {"DTQ_ROTA"    , "ENTGEN"     , Nil } )
    Aadd( aCab , {"DTQ_SERTMS"  , "3"       , Nil } )
    Aadd( aCab , {"DTQ_TIPTRA"  , "1"       , Nil } )

    Aadd( aMaster     , {} )
    Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
    Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
    Aadd( aMaster[Len(aMaster)] ,  "DTQ" )


    Aadd( aCab , {"DM4_XPTO"  , "M SP 01 "   , Nil })
    Aadd( aCab , {"DM4_XPTO"  , cViagem    , Nil })
    Aadd( aCab , {"DM4_XPTO"    , "ENTGEN"     , Nil } )
  
    Aadd( aMaster     , {} )
    Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
    Aadd( aMaster[Len(aMaster)] , "MdFieldDM4" )
    Aadd( aMaster[Len(aMaster)] ,  "DM4" )

    Aadd( aItens                , {} )
    Aadd( aItens[Len(aItens)]   , { "DM3_SEQUEN"     , "001"    ,   Nil } )
    Aadd( aItens[Len(aItens)]   , { "DM3_FILDOC"     , cFilDoc    ,   Nil } )
    Aadd( aItens[Len(aItens)]   , { "DM3_DOC"       , cDoc   ,   Nil } )
    Aadd( aItens[Len(aItens)]   , { "DM3_SERIE"     , cSerie         ,   Nil } )   

    Aadd( aGrid  , {} )
    Aadd( aGrid[Len(aGrid)]  , aClone(aItens) )
    Aadd( aGrid[Len(aGrid)]  , "MdGridDM3")
    Aadd( aGrid[Len(aGrid)]  , "DM3" )

    lRet    := TMSExecAuto( "TMSAF60" ,  aMaster   , aGrid,  4  , .T.  )

    If lRet
        MsgInfo("Alterado com sucesso","cTitulo")
    EndIf

EndIf


Return lRet


User Function ExcViagem()
Local aCab      := {} 
Local aItens    := {} 
Local nOpc      := ""
Local lRet      := .T. 
Local cFilDoc   := "M SP 01 "
Local cDoc      := "000000167"
Local cSerie    := "534"
Local cViagem   := "002944"
Local aMaster   := {} 
Local aGrid     := {} 

DTQ->( dbSetOrder(2))
If DTQ->( MsSeek( xFilial("DTQ") + "M SP 01 " + cViagem) )

    Aadd( aCab , {"DTQ_FILORI"  , "M SP 01 "   , Nil })
    Aadd( aCab , {"DTQ_VIAGEM"  , cViagem     , Nil })
    Aadd( aCab , {"DTQ_ROTA"    , "ENTGEN"     , Nil } )
    Aadd( aCab , {"DTQ_SERTMS"  , "3"       , Nil } )
    Aadd( aCab , {"DTQ_TIPTRA"  , "1"       , Nil } )

    Aadd( aMaster     , {} )
    Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
    Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
    Aadd( aMaster[Len(aMaster)] ,  "DTQ" )

    lRet    := TMSExecAuto( "TMSAF60" ,  aMaster   , aGrid,  5  , .T.  )

    If lRet
        MsgInfo("Excluido com sucesso","cTitulo")
    EndIf
EndIf

Return lRet