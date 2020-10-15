#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF64.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} TMSAF64NFC
Valida a chamada da Rotina P/Entrada da NFiscal do Cliente
@type Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TMSAF64NFC()
Local lRet      := .T.
Local aArea     := GetArea()
Local nOpcx     := 4
Local cLote     := ""
Local cFiltro	:= ""

//-- Valida alteração da viagem
lRet:= TF64VldAlt(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

If lRet
	lRet:= VldTipVia(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPVIA)
EndIf

If lRet 
	lRet:= VldRota(DTQ->DTQ_ROTA)
EndIf

If lRet
	lRet := NfCliBut( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , nOpcx , DTQ->DTQ_STATUS )	
EndIf

If lRet
	lRet:= VldPtoApo(nOpcx)
EndIf

If lRet
	lRet:= VldRecurso(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM )
EndIf

//---- Seleciona os Lotes da Viagem para Filtrar no Browse do TMSA050
If lRet
	TF64ELote(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@cLote)
EndIf

//---- Digitacação da Nota
If lRet
	cFiltro	:= FiltroDTC( DTQ->DTQ_FILORI,  DTQ->DTQ_VIAGEM )
	SaveInter()
	//-- Inclusao documentos clientes p/ transporte
	M->DTQ_FILORI:= DTQ->DTQ_FILORI
	M->DTQ_VIAGEM:= DTQ->DTQ_VIAGEM
	M->DTQ_SERTMS:= DTQ->DTQ_SERTMS
	dbSelectArea("DTC")	
	lRet   := TMSA050(, , , , , , cFiltro)
	RestInter()
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldTipVia
Valida o Tipo de Viagem 
@type Static Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function  VldTipVia(cSerTmsVge,cTipVia)
Local lRet        := .T.
Default cSerTmsVge:= ""
Default cTipVia   := ""

If Empty(cSerTmsVge) .Or. Empty(cTipVia)
	lRet:= .F.
Else
	If cTipVia == '2'  //Vazia
		lRet:= .F.
	Else
		If cSerTmsVge == StrZero(3,Len(DC5->DC5_SERTMS))
			If cTipVia == '3' .Or. cTipVia == '4'  // Se Viagem de Entrega e Vazia / Socorro nao pode digitar notas
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		Help(' ', 1, 'TMSA14420')	//-- Viagem do tipo vazia, nao pode digitar notas fiscais.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldTipVia
Valida o Tipo de Viagem 
@type Static Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRota(cRota)
Local lRet   := .T.
Default cRota:= ""
Default nOpcx:= 3

If Empty(cRota) 
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
	lRet:= .F.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} NfCliBut()
Valida a opção  do botao do NF Cliente
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
//Funçao do TMSA144 
-----------------------------------------------------------/*/
Static Function NfCliBut(cFilOri , cViagem , nOpcx , cStatus )
Local lRet			:= .F. 
Local aOperDTW		:= {} 
Local cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')
Local nCount		:= 1 
Local nPos			:= 0 

Default cFilOri	:= ""
Default cViagem	:= ""
Default nOpcx	:= 3
Default cStatus	:= ""

	If nOpcx == 4 
		If ( cStatus == '2' .Or. cStatus == '4' ) //-- 2=Em trânsito;4=Chegada em Filial/Cliente
			aOperDTW	:= aClone( A350RetDTW( cFilOri, cViagem , "2" , "2" ) ) 

			If Len(aOperDTW) > 0 
				For nCount := 1 To Len(aOperDTW)
					nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_ATIVID" })
					If nPos > 0 
				
						If aOperDTW[nCount, nPos][2] == cAtvChgCli
							lRet	:= .T. 
						Else
							lRet	:= .F. 
							Help("", 1, "TMSA144L0") //-- Para habilitar a opção Nf.Cliente para viagens em trânsito, é necessário que exista alguma operação de chegada de cliente apontada e a saída desse mesmo cliente não deve estar apontada
						EndIf
					EndIf
				Next nCount
			EndIf
		ElseIf  cStatus == "1" //-- Em aberto
			lRet	:= .T. 
		EndIf
	EndIf	


Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} VldPtoApo
Valida o Ponto de Apoio
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
*/
//-------------------------------------------------------------------
//Existindo o Ponto de Apoio a inclusão de documentos na viagem, somente será permitida qdo a operação da chegada no ponto estiver apontada
Static Function VldPtoApo(nOpcx)
Local lRet    := .T.
Local aAreaAnt:= GetArea()

Default nOpcx:= 0

If nOpcx == 4 .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //Em Transito
	If ExistFunc('TM350Apoio')  
		aAreaAnt:= GetArea()
		lRet:= Tm350Apoio(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
		RestArea(aAreaAnt)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldRecurso
Valida o Recurso da Viagem (Veiculo e Motorista)
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRecurso(cFilOri,cViagem)
Local lRet     := .T.
Local aArea    := GetArea()

Default cFilOri:= ""
Default cViagem:= ""

//---- Veiculo
DTR->(dbSetOrder(1))
If !DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
	Help( ' ', 1, 'TMSA24002') //-- Complemento de viagem nao informado (DTR)
	lRet := .F.
EndIf

//----- Motorista
If lRet	
	DUP->(dbSetOrder(1))
	If !DUP->(MsSeek(xFilial("DUP")+cFilOri+cViagem))
		Help('',1,'TMSA24041') //"Informe um Motorista para esta viagem ..."
		lRet:= .F.
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VldLot
Valida os Lotes da Viagem para efetuar o Calculo
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VldLot(cFilOri,cViagem,cStatus)
Local aAreaDTP := DTP->(GetArea())
Local cQuery   := ""
Local cAliasDTP := GetNextAlias()
Local lRet      := .T.

Default cFilOri := ""
Default cViagem := ""
Default cStatus := ""

cQuery := "SELECT COUNT(*) NLOTE FROM " + RetSqlName("DTP") + " DTP " 
cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_FILORI = '" + cFilOri + "' " 
cQuery += " AND DTP_VIAGEM = '" + cViagem + "' " 
cQuery += " AND DTP_STATUS NOT IN (" + cStatus + ") " 
cQuery += " AND D_E_L_E_T_ = ' ' " 					
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
dbSelectArea((cAliasDTP))
If (cAliasDTP)->(!Eof())
	If (cAliasDTP)->NLOTE > 0
		lRet:= .F.
	EndIf
EndIf
(cAliasDTP)->(DbCloseArea())

RestArea(aAreaDTP)
FwFreeArray(aAreaDTP)
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} TF64ELote
Seleciona os Lotes da Viagem
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64ELote(cFilOri,cViagem,cLote)
Local aArea    := GetArea()
Local aAreaDTP := DTP->(GetArea())
Local cQuery   := ""
Local cAliasDTP := GetNextAlias()
Local lRet      := .F.

Default cFilOri := ""
Default cViagem := ""

cQuery := "SELECT DTP_FILORI, DTP_LOTNFC, DTP_STATUS, DTP.R_E_C_N_O_ RECNO FROM " + RetSqlName("DTP") + " DTP " 
cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_FILORI = '" + cFilOri + "' " 
cQuery += " AND DTP_VIAGEM = '" + cViagem + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' " 					
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
dbSelectArea((cAliasDTP))
While (cAliasDTP)->(!Eof())
	lRet:= .T.

	If Empty(cLote)
		cLote:= '(' + (cAliasDTP)->DTP_LOTNFC
	Else
		cLote+= ', ' + (cAliasDTP)->DTP_LOTNFC
	EndIf		

	(cAliasDTP)->(dbSkip())
	If !Empty(cLote)
		cLote+= ')' 
	EndIf
EndDo
(cAliasDTP)->(DbCloseArea())

RestArea(aAreaDTP)
RestArea(aArea)
FwFreeArray(aAreaDTP)
FwFreeArray(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VgMod3
Seleciona os Lotes da Viagem
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VgMod3(cFilOri,cLotNfc,cViagem)
Local lRet    := .T.
Local lVgeMod3:= .T.

Default cFilOri:= ""
Default cLotNfc:= ""
Default cViagem:= ""

//-- Verifica se a Viagem é Modelo 3
lVgeMod3:= TF64Modelo3(cFilOri,cViagem)

If lVgeMod3
	//-- Busca o Nro da Viagem a partir do Lote
	If Empty(cViagem)
		cViagem:= RetVgeLote(cFilOri,cLotNfc)
	EndIf

	If !Empty(cViagem)
		//Executa a Viagem Modelo 3
		lRet:= IncVgeMod3(cFilOri,cViagem,cLotNfc)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetVgeLote
Retorna o Nro da Viagem do Lote
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function RetVgeLote(cFilOri,cLotNfc)
Local cRet    := ""
Local aAreaDTP:= DTP->(GetArea())

Default cFilOri:= ""
Default cLotNfc:= ""

DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
If	DTP->(MsSeek( xFilial('DTP') + cFilOri + cLotNfc ))
	cRet:= DTP->DTP_VIAGEM
EndIf

RestArea(aAreaDTP)
Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} VgeModelo3
Verifica se é uma viagem modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function VgeModelo3(cFilOri,cViagem)
Local lRet:= .F.
Local aArea:= GetArea()

Default cFilOri:= ""
Default cViagem:= ""

DM4->(dbSetOrder(1))
If DM4->(MsSeek(xFilial("DM4")+cFilOri+cViagem))
	lRet:= .T.
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} IncVgeMod3
Inclui documentos na Viagem Modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function IncVgeMod3(cFilOri,cViagem,cLotNfc)
Local nOpc      := 0
Local lRet      := .T. 
Local aArea     := GetArea()

/*Local aCab      := {} 
Local aGrid     := {} 
Local aMaster   := {}
Local aItensDM3 := {}*/

SaveInter()

DBSelectArea('DTQ')
DTQ->( dbSetOrder(2))
If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) )
	lRet:= .T.
	nOpc:= 4
EndIf

If lRet
    /*Aadd( aCab , {"DTQ_FILORI"  , DTQ->DTQ_FILORI  , Nil } )
    Aadd( aCab , {"DTQ_VIAGEM"  , DTQ->DTQ_VIAGEM  , Nil } )
    Aadd( aCab , {"DTQ_ROTA"    , DTQ->DTQ_ROTA    , Nil } )
    Aadd( aCab , {"DTQ_SERTMS"  , DTQ->DTQ_SERTMS  , Nil } )
    Aadd( aCab , {"DTQ_TIPTRA"  , DTQ->DTQ_TIPTRA  , Nil } )

    aItensDM3:= TF64DocDM3(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,cLotNfc)

    Aadd( aMaster     , {} )
    Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
    Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
    Aadd( aMaster[Len(aMaster)] ,  "DTQ" )

    Aadd( aGrid  , {} )
    Aadd( aGrid[Len(aGrid)]  , aClone(aItensDM3) )
    Aadd( aGrid[Len(aGrid)]  , "MdGridDM3")
    Aadd( aGrid[Len(aGrid)]  , "DM3" )

	FwMsgRun( ,{|| lRet:= TMSExecAuto( "TMSAF60",aMaster,aGrid,nOpc, .T.)} , STR0008 , STR0010)  //Processando
   	If lRet
        MsgInfo("Documentos incluídos na viagem com sucesso")
    EndIf
    */
	
	FwMsgRun( ,{|| TmsCmpMdl3( nOpc )} , STR0008 , STR0010 )  //Aguarde... Gerando a viagem modelo 3
    
EndIf

RestInter()
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64DocDM3
Monta os Documentos para inclusão na DM3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function TF64DocDM3(cFilOri,cViagem,cLotNfc)
Local aItens   := {}
Local aArea    := GetArea()
Local cQuery   := ""
Local cAliasTmp:= GetNextAlias()
Local nSeq     := 0
Local cFilDoc  := ""
Local cDoc     := ""
Local cSerie   := ""

Default cFilOri := ""
Default cViagem := ""
Default cLotNfc := ""
	
cQuery := "SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE FROM " + RetSqlName("DUD") + " DUD " 
cQuery += "   JOIN  " + RetSqlName("DT6") + " DT6 "
cQuery += "     ON  DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
cQuery += "     AND DT6.DT6_DOC = DUD.DUD_DOC "
cQuery += "     AND DT6.DT6_SERIE = DUD.DUD_SERIE "
cQuery += "     AND DT6.DT6_LOTNFC = '" + cLotNfc + "' "
cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD_FILORI = '" + cFilOri + "' " 
cQuery += " AND DUD_VIAGEM = '" + cViagem + "' " 
cQuery += " AND DUD_STATUS = '1'" //Em Aberto
cQuery += " AND DUD.D_E_L_E_T_ = ' ' " 					
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .F., .T. )
dbSelectArea((cAliasTmp))
While (cAliasTmp)->(!Eof())
	cFilDoc:= (cAliasTmp)->DUD_FILDOC
	cDoc   := (cAliasTmp)->DUD_DOC
	cSerie := (cAliasTmp)->DUD_SERIE

	DM3->(dbSetOrder(1))
	If !DM3->(DbSeek(xFilial("DM3")+cFilDoc+cDoc+cSerie+cFilOri+cViagem))

		nSeq := nSeq + 1			
		Aadd( aItens                , {} )
		Aadd( aItens[Len(aItens)]   , { "DM3_SEQUEN" , StrZero(nSeq,Len(DUD->DUD_SEQUEN))  ,   Nil } )
		Aadd( aItens[Len(aItens)]   , { "DM3_FILDOC" , cFilDoc       ,   Nil } )
		Aadd( aItens[Len(aItens)]   , { "DM3_DOC"    , cDoc          ,   Nil } )
		Aadd( aItens[Len(aItens)]   , { "DM3_SERIE"  , cSerie        ,   Nil } )
	
	EndIf

	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(DbCloseArea())

RestArea(aArea)
FwFreeArray(aArea)
Return aItens


//-----------------------------------------
/*/{Protheus.doc} TMVldLotM3()
Valida se o Lote é da Viagem Modelo 3
@type 		: Function
@autor		: Katia
@since		: 04/09/2020
@version 	: 12.1.30
Executado pelo TMSA200
/*/
//-------------------------------
Function TMVldLotM3(cFilOri,cViagem)
Local lRet     := .T.
Local cStatus  := "'2','3'"   //2- Digitado, 3-Calculado
Local lVgeMod3 := .T.

Default cFilOri:= ""
Default cViagem:= ""

//--- Valida se é viagem Modelo 3
lVgeMod3:= TF64Modelo3(cFilOri,cViagem)

If lVgeMod3
	//--- Verificar se existe Lote diferente de Digitado para a Viagem Modelo 3
	lRet:= TF64VldLot(cFilOri,cViagem,cStatus) 
	If !lRet
		Help(' ', 1, 'TMSAF6413')	//-- Calculo do Frete não pode ser executado, pois existem Lotes pendentes para essa Viagem.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} FiltroDTC
Filtra DTC
@type Static Function
@author Caio
@since 04/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function FiltroDTC(cFilOri,cViagem)
Local aArea			:= GetArea()
Local cFiltro		:= ""


Default cFilOri		:= ""
Default cViagem		:= ""

If !Empty(cViagem)

	cFiltro:= " EXISTS (SELECT 1 FROM " + RetSqlName( "DTP" ) + " DTP "
	cFiltro+= " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'" 
	cFiltro+= " AND DTP_FILORI= '" + cFilOri + "' AND DTP_VIAGEM = '" + cViagem + "' 
	cFiltro+= " AND DTP.D_E_L_E_T_= ' ' "
	cFiltro+= " AND DTP_FILORI = DTC_FILORI AND DTP_LOTNFC = DTC_LOTNFC ) "	

EndIf

RestArea(aArea)
Return cFiltro


//-------------------------------------------------------------------
/*{Protheus.doc} TF64Modelo3
Verifica se a Viagem é modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64Modelo3(cFilOri,cViagem)
Local lRet       := .T.
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

Default cFilOri:= ""
Default cViagem:= ""

If lVgeAntiga 
	lRet:= .F.
Else
	lRet:= TmsVgeMod3()  //Chamada pela Viagem Modelo 3
	If !lRet	
		lRet:= VgeModelo3(cFilOri,cViagem)  //Viagem gerada pela Modelo 3
	EndIf
EndIf
Return lRet