#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF90.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMS3GFE := TmsIntGFE('02')
Static lMDFeAut := SuperGetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")
Static lPosVia  := .T.

/*{Protheus.doc} TMSAF90
Viagem Modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 24/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF90()
(examples)
@see (links_or_references)
*/
Function TMSAF90()
Local cCadastro := STR0001	//-- "Carregamento da Viagem Modelo 3"
Local cPerg     := "TMSAF90"
Local aSetKey   := {}

Private aRotina := MenuDef()

Aadd(aSetKey,{VK_F12,{|| Pergunte(cPerg,.T.)}})

TmsKeyOn(aSetKey)
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DM6")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

TmsKeyOff(aSetKey)

Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@type Static Function
@author Valdemar Roberto Mognon
@since 24/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example MenuDef()
(examples)
@see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {{STR0002,"AxPesqui"       ,0,1,0,.F.} ,;	//-- Pesquisar
				  {STR0003,"VIEWDEF.TMSAF90",0,2,0,.T.} ,;	//-- Visualizar
				  {STR0004,"VIEWDEF.TMSAF90",0,3,0,.T.} ,;	//-- Incluir
				  {STR0009,"VIEWDEF.TMSAF90",0,4,0,.T.} ,;	//-- Alterar
				  {STR0005,"VIEWDEF.TMSAF90",0,5,0,.T.}}	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruCDM6  := FwFormStruct(1,"DM6")
Local oStruIDM7  := FwFormStruct(1,"DM7")
Local oStruIDTA  := FwFormStruct(1,"DTA")
Local bLinPreDTA := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF90Lin(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)}
Local bCommit    := {|oModel| TMSAF90Grv(oModel)}

//-- Remove campos das Model
RemoveFld(oStruIDM7,{"DM7_FILORI","DM7_VIAGEM"})
RemoveFld(oStruIDTA,{"DTA_FILORI","DTA_VIAGEM","DTA_ESTCAR","DTA_LOCAL" ,"DTA_LOCALI","DTA_PESO"  ,"DTA_SERTMS","DTA_TIPTRA","DTA_FILDPC",;
					 "DTA_CODVEI","DTA_MODVEI","DTA_CODRB1","DTA_MODRB1","DTA_CODRB2","DTA_MODRB2","DTA_CODRB3","DTA_MODRB3",;
					 "DTA_PESOM3","DTA_METRO3","DTA_VALMER","DTA_VALFRE","DTA_PESLIQ","DTA_UNITIZ","DTA_CODANA","DTA_SDOC"  })

//-- Fixa os Whens dos campos
FixWhen(oStruIDTA,"TMSAF90Whe('DTA')","DTA")

//-- Fixa os Valids dos campos
FixValid(oStruIDTA,"TMSAF90Vld('DTA')","DTA")

//-- Altera estrutura dos campos
AltStruc(oStruIDTA,{{"DTA_VEICAR",{{3,"0"}}}})

//-- Monta gatilhos
MntTrigger(oStruIDTA,{{{"DTA_FILDOC","DTA_DOC","DTA_SERIE"},{"DTA_QTDVOL","DTA_FILDCA","DTA_TIPAGD","DTA_DATAGD",;
						"DTA_PRDAGD","DTA_INIAGD","DTA_FIMAGD"}}})

oModel := MpFormModel():New("TMSAF90",/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)

oModel:SetDescription(STR0006)	//-- "Carregamento"

//-- Cabeçalho do Carregamento
oModel:AddFields("MdFieldDM6",,oStruCDM6,,,)
oModel:SetPrimaryKey({"DM6_FILORI","DM6_VIAGEM"})
oModel:GetModel("MdFieldDM6"):SetDescription(STR0006)	//-- "Carregamento"

//-- Grid dos Veículos
oModel:AddGrid("MdGridDM7","MdFieldDM6",oStruIDM7,/*bLinPre*/,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDM7",{{"DM7_FILIAL","xFilial('DM7')"},;
								 {"DM7_FILORI","DM6_FILORI"},;
								 {"DM7_VIAGEM","DM6_VIAGEM"}},;
								 DM7->(IndexKey(1)))
oModel:GetModel("MdGridDM7"):SetOnlyView(.T.)
oModel:GetModel("MdGridDM7"):SetDescription(STR0008)	//-- "Veículos"

//-- Grid dos Documentos
oModel:AddGrid("MdGridDTA","MdGridDM7",oStruIDTA,bLinPreDTA,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDTA",{{"DTA_FILIAL","xFilial('DTA')"},;
								 {"DTA_FILORI","DM6_FILORI"},;
								 {"DTA_VIAGEM","DM6_VIAGEM"},;
								 {"DTA_CODVEI","DM7_CODVEI"}},;
								 DTA->(IndexKey(5)))
oModel:GetModel("MdGridDTA"):SetOptional(.T.)
oModel:GetModel("MdGridDTA"):SetUniqueLine({"DTA_FILDOC","DTA_DOC","DTA_SERIE"})
oModel:GetModel("MdGridDTA"):SetDescription(STR0007)	//-- "Documentos"

oModel:SetVldActivate({|oModel| TMF90PrVld(oModel)})

oModel:SetActivate({|oModel| TMSAF90ACT(oModel)})

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
Local oModel    := FwLoadModel("TMSAF90")
Local oView
Local oStruCDM6 := FwFormStruct(2,"DM6")
Local oStruIDM7 := FwFormStruct(2,"DM7")
Local oStruIDTA := FwFormStruct(2,"DTA")

//-- Remove campos das Views
RemoveFld(oStruIDM7,{"DM7_FILORI","DM7_VIAGEM"})
RemoveFld(oStruIDTA,{"DTA_FILORI","DTA_VIAGEM","DTA_ESTCAR","DTA_LOCAL" ,"DTA_LOCALI","DTA_PESO"  ,"DTA_SERTMS","DTA_TIPTRA","DTA_FILDPC",;
					 "DTA_CODVEI","DTA_MODVEI","DTA_CODRB1","DTA_MODRB1","DTA_CODRB2","DTA_MODRB2","DTA_CODRB3","DTA_MODRB3",;
					 "DTA_PESOM3","DTA_METRO3","DTA_VALMER","DTA_VALFRE","DTA_PESLIQ","DTA_UNITIZ","DTA_CODANA","DTA_SDOC"  })

oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("Viagem",010)
oView:CreateHorizontalBox("Veiculos",025)
oView:CreateHorizontalBox("Documentos",065)

oView:AddField("VwFieldDM6",oStruCDM6,"MdFieldDM6")
oView:SetOwnerView("VwFieldDM6","Viagem")

oView:AddGrid("VwGridDM7",oStruIDM7,"MdGridDM7")
oView:SetOwnerView("VwGridDM7","Veiculos")
oView:EnableTitleView("VwGridDM7",STR0008)	//-- "Veículos"

oView:AddGrid("VwGridDTA",oStruIDTA,"MdGridDTA")
oView:SetOwnerView("VwGridDTA","Documentos")
oView:EnableTitleView("VwGridDTA",STR0007)	//-- "Documentos"

Return oView

/*{Protheus.doc} RemoveFld
Remove fieldes de uma View
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example RemoveFld(oStruct,aFields)
(examples)
@see (links_or_references)
*/
Static Function RemoveFld(oStruct,aCampos)
Local nCntFor1 := 0

Default oStruct := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	&("oStruct:RemoveField('" + aCampos[nCntFor1] + "')")
Next nCntFor1

Return

/*{Protheus.doc} AltStruc
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 01/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example AltStruc(oStruct,aCampos (cCampo,(1=Valid / 2=When / 3=IniPad / 4=PictVar / 5=Obrigat),cExpressao))
(examples)
@see (links_or_references)
*/
Static Function AltStruc(oStruct,aCampos)
Local bCodigo  := Nil
Local nCntFor1 := 0
Local nCntFor2 := 0

Default oStruc  := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	For nCntFor2 := 1 To Len(aCampos[nCntFor1,2])
		If aCampos[nCntFor1,2,nCntFor2,1] == 5
			bCodigo := aCampos[nCntFor1,2,nCntFor2,2]
		Else
			bCodigo := FWBuildFeature(Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,STRUCT_FEATURE_VALID,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,STRUCT_FEATURE_WHEN,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,STRUCT_FEATURE_INIPAD,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,STRUCT_FEATURE_PICTVAR,Nil)))),aCampos[nCntFor1,2,nCntFor2,2])
		EndIf
				
		oStruct:SetProperty(aCampos[nCntFor1,1],Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,MODEL_FIELD_VALID,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,MODEL_FIELD_WHEN,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,MODEL_FIELD_INIT,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,MODEL_FIELD_PICTVAR,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 5,MODEL_FIELD_OBRIGAT,Nil))))),bCodigo)
	Next nCntFor2
Next nCntFor1

Return

/*{Protheus.doc} FixWhen
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example FixWhen(oStruct,cFuncao)
(examples)
@see (links_or_references)
*/
Static Function FixWhen(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_WHEN,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,bCodigo)
Next nCntFor1

Return

/*{Protheus.doc} FixValid
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example FixValid(oStruct,cFuncao)
(examples)
@see (links_or_references)
*/
Static Function FixValid(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo
Local lFixValid:= .T.

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_VALID,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	lFixValid := "TMSA210" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
	If lFixValid
		oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_VALID,bCodigo)
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMSAF90Whe
Valida when dos campos do carregamento da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Whe(cOrigem)
Local lRet := .T.

Default cOrigem := ""

If cOrigem == "DTA"
	lRet := WhenDTA()
EndIf

Return lRet

/*{Protheus.doc} WhenDTA
Executa o when dos campos da DTA
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WhenDTA()
Local lRet       := .T.
Local cCampo     := ReadVar()

If AllTrim(cCampo) $ "M->DTA_SEQDTW"
	lRet := WheSeqDTW()
ElseIf AllTrim(cCampo) $ "M->DTA_FILDPC"
	lRet := WheFilDPC()
ElseIf AllTrim(cCampo) $ "M->DTA_QTDVOL"
	lRet := WheQtdVol()
ElseIf AllTrim(cCampo) $ "M->DTA_VEICAR"
	lRet := WheVeiCar()
ElseIf AllTrim(cCampo) $ "M->DTA_ORIGEM"
	lRet := WheOrigem()
EndIf

Return lRet

/*{Protheus.doc} WheSeqDTW
Executa o when do campo DTA_SEQDTW
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheSeqDTW()
Local lRet := .T.

Return lRet

/*{Protheus.doc} WheFilDPC
Executa o when do campo DTA_FILDPC
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheFilDPC()
Local lRet := .F.

Return lRet

/*{Protheus.doc} WheQtdVol
Executa o when do campo DTA_QTDVOL
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheQtdVol()
Local lRet    := .T.
Local aAreas  := {DT6->(GetArea()),GetArea()}

DT6->(dbSetOrder(1))
If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE")))
	If DT6->DT6_TIPTRA != StrZero(4,Len(DC5->DC5_TIPTRA))	//-- Transporte Internacional
		Help("",1,"TMSAF9001")	//-- "Nao é permitido efetuar carregamento parcial no transporte nacional."
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} WheVeiCar
Executa o when do campo DTA_VEICAR
@type Static Function
@author Valdemar Roberto Mognon
@since 29/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheVeiCar()
Local lRet    := .T.

Return lRet

/*{Protheus.doc} WheOrigem
Executa o when do campo DTA_ORIGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 29/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheOrigem()
Local lRet      := .T.
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDUD := GetNextAlias()

cQuery := " SELECT DUD.DUD_MANIFE,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,DTX.DTX_VIAGEM,DTX.DTX_IDIMDF "

cQuery += "   FROM " + RetSQLName("DUD") + " DUD "

cQuery += "  INNER JOIN " + RetSQLName("DTX") + " DTX "
cQuery += " 	ON DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery += "    AND DTX.DTX_FILMAN = '" + cFilAnt  + "' "
cQuery += "    AND DTX.DTX_FILORI = DUD.DUD_FILORI "
cQuery += "    AND DTX.DTX_VIAGEM = DUD.DUD_VIAGEM "
cQuery += "    AND DTX.DTX_TIPMAN = '2' "
cQuery += "    AND DTX.DTX_IDIMDF = '100' "
cQuery += "    AND DTX.D_E_L_E_T_ = ' ' "

cQuery += "	 WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "    AND DUD.DUD_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
cQuery += "    AND DUD.DUD_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
cQuery += "    AND DUD.DUD_FILDOC = '" + FwFldGet("DTA_FILDOC") + "' "
cQuery += "    AND DUD.DUD_DOC    = '" + FwFldGet("DTA_DOC") + "' "
cQuery += "    AND DUD.DUD_SERIE  = '" + FwFldGet("DTA_SERIE") + "' "
cQuery += "    AND DUD.DUD_MANIFE <> ' ' "
cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasDUD,.F.,.T.)
				
If (cAliasDUD)->(!Eof())
	lRet := .F.
EndIf

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Vld
Valida campos do carregamento da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Vld(cOrigem,cCampo)
Local lRet := .T.

Default cOrigem := ""
Default cCampo  := ReadVar()

If cOrigem == "DM6"
	lRet := ValidDM6(cCampo)
ElseIf cOrigem == "DTA"
	lRet := ValidDTA(cCampo)
EndIf

Return lRet

/*{Protheus.doc} ValidDM6
Valida campos da DM6
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ValidDM6(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DM6_FILORI|M->DM6_VIAGEM"
	lRet := VldViagem()
EndIf

Return lRet

/*{Protheus.doc} ValidDTA
Valida campos da DTA
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ValidDTA(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DTA_FILDOC|M->DTA_DOC|M->DTA_SERIE"
	lRet := VldDocto()
ElseIf AllTrim(cCampo) $ "M->DTA_VEICAR"
	lRet := VldVeiCar()
EndIf

Return lRet

/*{Protheus.doc} VldViagem
Valida os campos DM6_FILORI e DM6_VIAGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldViagem()
Local lRet      := .T.
Local aAreas    := {DTQ->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDUD := ""

If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))
	DTQ->(DbSetOrder(2))
	If !DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
		Help("",1,"TMSAF9003")	//-- Viagem não existe.
		lRet := .F.
	Else
		If !DTQ->DTQ_STATUS $ "1,4" .And. DTQ->DTQ_TIPVIA != StrZero(4,Len(DTQ->DTQ_TIPVIA))
			Help("",1,"TMSAF9004")	//-- Viagem não esta aberta ou com chegada em filial.
			lRet := .F.
		EndIf
	EndIf
	//-- Verifica se existem documentos para serem carregados
	If lRet
		cAliasDUD := GetNextAlias()
		cQuery := " SELECT 1 QTDDOC "
		
		cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
		
		cQuery += "  WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "    AND DUD.DUD_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "    AND DUD.DUD_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "

		cQuery += "    AND NOT EXISTS (SELECT 1 
		cQuery += "                      FROM " + RetSQLName("DTA") + " DTA "
		cQuery += "                     WHERE DTA.DTA_FILIAL = '" + xFilial("DTA") + "' "
		cQuery += "                       AND DTA.DTA_FILDOC = DUD_FILDOC "
		cQuery += "                       AND DTA.DTA_DOC    = DUD_DOC "
		cQuery += "                       AND DTA_SERIE      = DUD_SERIE "
		cQuery += "                       AND DTA_FILORI     = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "                       AND DTA_VIAGEM     = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "                       AND DTA.D_E_L_E_T_ = ' ')"
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.F.,.T.)
						
		If (cAliasDUD)->(Eof()) .Or. Empty((cAliasDUD)->QTDDOC)
			Help("",1,"TMSAF9005")	//-- Viagem não possui documentos para carregar.
			lRet := .F.	
		EndIf		
		(cAliasDUD)->(DbCloseArea())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} VldDocto
Valida os campos DTA_FILDOC, DTA_DOC e DTA_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldDocto()
Local lRet   := .T.
Local aAreas := {DUD->(GetArea()),GetArea()}

If !Empty(FwFldGet("DTA_FILDOC")) .And. !Empty(FwFldGet("DTA_DOC")) .And. !Empty(FwFldGet("DTA_SERIE"))
	DUD->(DbSetOrder(1))
	If !DUD->(DbSeek(xFilial("DUD") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
		Help("",1,"TMSAF9002")	//-- "Documento não está indicado para carregamento nesta vigem."
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} VldVeiCar
Valida os campos DTA_VEICAR
@type Static Function
@author Valdemar Roberto Mognon
@since 31/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldVeiCar()
Local lRet   := .T.
Local cValid := "0"

If !Empty(FwFldGet("DM7_CODRB1"))
	cValid := cValid + "1"
	If !Empty(FwFldGet("DM7_CODRB2"))
		cValid := cValid + "2"
		If !Empty(FwFldGet("DM7_CODRB3"))
			cValid := cValid + "3"
		EndIf
	EndIf
EndIf

lRet := FwFldGet("DTA_VEICAR") $ cValid

Return lRet

/*{Protheus.doc} MntTrigger
Monta gatilhos do carregamento da viagem modelo 3
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function MntTrigger(oStruct,aTrigger)
Local cDominio  := ""
Local cContra   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local aAux      := {}

Default oStruct  := Nil
Default aTrigger := {}

For nCntFor1 := 1 To Len(aTrigger)
	For nCntFor2 := 1 To Len(aTrigger[nCntFor1,1])
		cDominio := aTrigger[nCntFor1,1,nCntFor2]
		For nCntFor3 := 1 To Len(aTrigger[nCntFor1,2])
			cContra := aTrigger[nCntFor1,2,nCntFor3]

			aAux :=(FwStruTrigger(cDominio	,; // Campo de Dominio
								  cContra	,; // Campo de ContraDominio
								  "TMSAF90GAT('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
								  ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
								  ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
								  )) // Condição para execução do gatilho (Opcional)

			oStruct:AddTrigger(aAux[1],;	//-- [01] Id do campo de origem
							   aAux[2],;	//-- [02] Id do campo de destino
							   aAux[3],;	//-- [03] Bloco de codigo de validação da execução do gatilho
							   aAux[4])		//-- [04] Bloco de codigo de execução do gatilho
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

FwFreeArray(aAux)

Return

/*{Protheus.doc} TMSAF90GAT
Monta gatilhos dos campos da DTA
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90GAT(cCampo,cDest)
Local xRet := Nil

Default cCampo := ReadVar()
Default cDest  := ""

If cCampo $ "DM6_FILORI|DM6_VIAGEM"
	xRet:= GatViagem(cCampo,cDest)
ElseIf cCampo $ "DTA_FILDOC|DTA_DOC|DTA_SERIE"
	xRet:= GatDocto(cCampo,cDest)
EndIf

Return xRet 

/*{Protheus.doc} GatViagem
Gatilhos dos campos DTA_FILORI e DTA_VIAGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GatViagem(cCampo,cDest)
Local xRet      := Nil
Local aAreas    := {DM7->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDTR := ""
Local oModel    := FwModelActive()
Local oMdGrdDM7 := oModel:GetModel("MdGridDM7")
Local oStrucDM7 := oMdGrdDM7:GetStruct()
Local aCampos   := Aclone(oStrucDM7:GetFields())
Local nCntFor1  := 0
Local nQtdLin   := 0

If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))

	//-- Verifica se o veiculo da viagem já consta na DM7
	DM7->(DbSetOrder(1))
	If !DM7->(DbSeek(xFilial("DM7") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))

		//-- Le veiculos da viagem
		cAliasDTR := GetNextAlias()
		cQuery := " SELECT DTR.DTR_ITEM DM7_ITEDTR,DTR.DTR_CODVEI DM7_CODVEI,DA3VEI.DA3_DESC DM7_MODVEI,DTR.DTR_CODRB1 DM7_CODRB1,DA3RB1.DA3_DESC DM7_MODRB1,"
		cQuery += "                                DTR.DTR_CODRB2 DM7_CODRB2,DA3RB2.DA3_DESC DM7_MODRB2,DTR.DTR_CODRB3 DM7_CODRB3,DA3RB3.DA3_DESC DM7_MODRB3 "
		
		cQuery += "   FROM " + RetSQLName("DTR") + " DTR "
	
		cQuery += "   JOIN " + RetSQLName("DA3") + " DA3VEI "
		cQuery += "     ON DA3VEI.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3VEI.DA3_COD    = DTR.DTR_CODVEI "
		cQuery += "    AND DA3VEI.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB1 "
		cQuery += "     ON DA3RB1.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB1.DA3_COD    = DTR.DTR_CODRB1 "
		cQuery += "    AND DA3RB1.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB2 "
		cQuery += "     ON DA3RB2.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB2.DA3_COD    = DTR.DTR_CODRB2 "
		cQuery += "    AND DA3RB2.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB3 "
		cQuery += "     ON DA3RB3.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB3.DA3_COD    = DTR.DTR_CODRB3 "
		cQuery += "    AND DA3RB3.D_E_L_E_T_ = ' ' "
		
		cQuery += "  WHERE DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
		cQuery += "    AND DTR.DTR_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "    AND DTR.DTR_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "  ORDER BY DM7_ITEDTR "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTR,.F.,.T.)
						
		If (cAliasDTR)->(!Eof())
			oMdGrdDM7:SetOnlyView(.F.)
			oMdGrdDM7:SetNoInsertLine(.F.)
			While (cAliasDTR)->(!Eof())
				If nQtdLin == 0
					nQtdLin := 1
				Else
					nQtdLin ++
					oMdGrdDM7:Addline()
				EndIf
				oMdGrdDM7:Goline(nQtdLin)
				For nCntFor1 := 1 To Len(aCampos)
					If aCampos[nCntFor1,MODEL_FIELD_IDFIELD] != "DM7_FILIAL"
						oMdGrdDM7:LoadValue(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],(cAliasDTR)->&(aCampos[nCntFor1,MODEL_FIELD_IDFIELD]))
					EndIf
				Next nCntFor1
				(cAliasDTR)->(DbSkip())
			EndDo
			oMdGrdDM7:SetOnlyView(.T.)
		EndIf		
		(cAliasDTR)->(DbCloseArea())
	
		//-- Remonta tela de veiculos carregados
		oMdGrdDM7:GoLine(1)
		
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aCampos)

Return xRet

/*{Protheus.doc} GatDocto
Gatilhos dos campos DTA_FILDOC, DTA_DOC e DTA_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GatDocto(cCampo,cDest)
Local xRet     := Nil
Local aAreas   := {DYD->(GetArea()),DTQ->(GetArea()),DT6->(GetArea()),GetArea()}
Local aFilDca  := {}
Local lAgdEntr := TMSA018Agd()

If !Empty(FwFldGet("DTA_FILDOC")) .And. !Empty(FwFldGet("DTA_DOC")) .And. !Empty(FwFldGet("DTA_SERIE"))
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE")))
		If "DTA_QTDVOL" $ cDest
			xRet := DT6->DT6_QTDVOL
		ElseIf "DTA_FILDCA" $ cDest
			DTQ->(DbSetOrder(2))
			If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
				If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
					aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.T.)
				Else            
					aFilDca := TMSRegDca(DTQ->DTQ_ROTA,DT6->DT6_CDRCAL,.F.)
		            If Empty(aFilDca) 
						aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.F.)
					EndIf
				EndIf
				xRet := Iif(Len(aFilDca) == 1,aFilDca[1,3],Space(Len(DTA->DTA_FILDCA)))
			EndIf
		ElseIf cDest $ "DTA_TIPAGD|DTA_DATAGD|DTA_PRDAGD|DTA_INIAGD|DTA_FIMAGD"
			If lAgdEntr .And. !Empty(DT6->DT6_NUMAGD)
				DYD->(DbSetOrder(1))
				If DYD->(DbSeek(xFilial("DYD") + DT6->(DT6_NUMAGD + DT6_ITEAGD)))
					If "DTA_TIPAGD" $ cDest
						xRet := DYD->DYD_TIPAGD
					ElseIf "DTA_DATAGD" $ cDest
						xRet := DYD->DYD_DATAGD
					ElseIf "DTA_PRDAGD" $ cDest
						xRet := DYD->DYD_PRDAGD
					ElseIf "DTA_INIAGD" $ cDest
						xRet := DYD->DYD_INIAGD
					ElseIf "DTA_FIMAGD" $ cDest
						xRet := DYD->DYD_FIMAGD
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet

/*{Protheus.doc} TMSAF90Grv
Tratamento da gravação, alteração e exclusão
@type Function
@author Valdemar Roberto Mognon
@since 03/08/2020
@version version
@param modelo, fechamento automático (1=Sim / 2=Não)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Grv(oModel)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local lFechou    := .T.
Local cQuery     := ""
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA143" .Or. ;
					 Left(FunName(),7) == "TMSA144" .Or. Left(FunName(),7) == "TMSA360")

Default oModel  := FWModelActive()

Begin Transaction

	lRet := FwFormCommit(oModel)

	If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
	
			cQuery := " UPDATE " + RetSqlName("DTA")
			cQuery += "    SET DTA_SERTMS = '" + DTQ->DTQ_SERTMS + "', "
			cQuery += "        DTA_TIPTRA = '" + DTQ->DTQ_TIPTRA + "' "
			cQuery += "  WHERE DTA_FILIAL = '" + xFilial("DTA") + "'"
			cQuery += "    AND DTA_FILORI = '" + DTQ->DTQ_FILORI + "' "
			cQuery += "    AND DTA_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
	
			If TCSqlExec(cQuery) != 0
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	If lRet
		lRet := GravaDUD(oModel,nOperation)
		lRet := GravaDT6(oModel,nOperation)
	EndIf

	If !lRet
		DisarmTransaction()
		Break
	EndIf

	//-- Fechamento automático
	If !lVgeAntiga .And. DTQ->DTQ_TIPVIA != StrZero(3,Len(DTQ->DTQ_TIPVIA))
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
			lFechou := TMSAF69(2,"TMSAF90",nOperation,)
		EndIf
	EndIf
		
End Transaction

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} GravaDUD
Grava os campos da DUD na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 03/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GravaDUD(oModel,nOperation)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local aAreas     := {DUD->(GetArea()),GetArea()}
Local cStatus    := ""
Local oMdlGrdDM7
Local oMdlGrdDTA
Local cFilDca    := Space(Len(DUD->DUD_FILDCA))
Local lAtuGFE    := .F.

Default oModel     := FWModelActive()
Default nOperation := 0

oMdlGrdDM7 := oModel:GetModel("MdGridDM7")
oMdlGrdDTA := oModel:GetModel("MdGridDTA")

DUD->(DbSetOrder(1))

For nCntFor1 := 1 To oMdlGrdDM7:Length()
	oMdlGrdDM7:GoLine(nCntFor1)
	
	For nCntFor2 := 1 To oMdlGrdDTA:Length()
		oMdlGrdDTA:GoLine(nCntFor2)
		cStatus := ""
		lAtuGFE := .F.
	
		If nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrdDTA:IsDeleted())
			cStatus := StrZero(1,Len(DUD->DUD_STATUS))
			
		ElseIf (nOperation == MODEL_OPERATION_INSERT .And. !oMdlGrdDTA:IsDeleted()) .Or. (nOperation == MODEL_OPERATION_UPDATE .And. !oMdlGrdDTA:IsDeleted())
			cStatus := StrZero(3,Len(DUD->DUD_STATUS))
			cFilDca := oMdlGrdDTA:GetValue('DTA_FILDCA')
		EndIf
	
		If !Empty(cStatus)
			If DUD->(DbSeek(xFilial("DUD") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC")  + FwFldGet("DTA_SERIE") + FwFldGet("DM6_FILORI") + ;
											 FwFldGet("DM6_VIAGEM")))
				
				If lTMS3GFE 
					If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS) ) .And. Empty(DUD->DUD_NUMRED) 
						lAtuGFE:= .T.
					EndIf
				EndIf

				RecLock("DUD",.F.)
				DUD->DUD_STATUS := cStatus
				DUD->DUD_FILDCA := cFilDca
				
				If lAtuGFE
					GrvDUDGFE(cStatus,cFilDca)					
				EndIf

				DUD->(MsUnlock())
			
				//---- Atualiza campos da DM8
				If lAtuGFE
					TF67AtuDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM)
				EndIf

			EndIf
		EndIf
	Next nCntFor2

Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} GrvDUDGFE
Grava os campos da DUD referente a Integração TMS x GFE
@type Static Function
@author Katia
@since 13/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function GrvDUDGFE(cStatus,cFilDca)
Local aAreaSM0:= SM0->(GetArea())

Default cStatus:= ""
Default cFilDca:= ""

If cStatus == StrZero(3,Len(DUD->DUD_STATUS))  //Carregado
	DUD->DUD_UFDES  := NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_ESTENT"))
	DUD->DUD_CDMUND := Substr(NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_CODMUN")),3)
	DUD->DUD_CEPDES := NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_CEPENT"))
Else
	DUD->DUD_UFDES  := Space(Len(DUD->DUD_UFDES))
	DUD->DUD_CDMUND := Space(Len(DUD->DUD_CDMUND))
	DUD->DUD_CEPDES := Space(Len(DUD->DUD_CEPDES))
EndIf

RestArea(aAreaSM0)
FwFreeArray(aAreaSM0)
Return Nil

/*{Protheus.doc} TmsCarMod3
Indica se é carregamento modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 12/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsCarMod3()
Local lRet		:= .F. 
Local oModel	:= Nil

If Left(FunName(),7) == 'TMSAF90' .Or. IsInCallStack("TMSAF90")
	lRet	:= .T. 
Else
	oModel	:= FwModelActive()
	If oModel <> Nil .And. AllTrim(Upper(oModel:cID)) == 'TMSAF90'  //--- Carregamento Modelo 3
		lRet	:= .T. 
	EndIf
EndIf

Return lRet 

/*{Protheus.doc} Tmsaf90Act
Executa a pr-e-validação do modelo principal
@type Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf90Act(oModel)
Local oMdlFldDM6

Default oModel := FwModelActive()

//-- Inicia os campos de filial de origem e viagem quando a rotina for chamada do carregamento e for inclusão de um carregamento novo
If TmsVgeMod3()
	oMdlFldDM6 := oModel:GetModel("MdFieldDM6")
	If oMdlFldDM6:GetOperation() == 3
		oMdlFldDM6:SetValue("DM6_FILORI",DTQ->DTQ_FILORI)
		oMdlFldDM6:SetValue("DM6_VIAGEM",DTQ->DTQ_VIAGEM)
	EndIf
EndIf

Return

/*{Protheus.doc} GravaDT6
Grava os campos da DT6 na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 18/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GravaDT6(oModel,nOperation)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local aAreas     := {DT6->(GetArea()),GetArea()}
Local oMdlGrdDM7
Local oMdlGrdDTA
Local cStatus    := ""
Local cFilOri    := ""
Local cViagem    := ""

Default oModel     := FWModelActive()
Default nOperation := 0

oMdlGrdDM7 := oModel:GetModel("MdGridDM7")
oMdlGrdDTA := oModel:GetModel("MdGridDTA")

DT6->(DbSetOrder(1))

For nCntFor1 := 1 To oMdlGrdDM7:Length()
	oMdlGrdDM7:GoLine(nCntFor1)
	
	For nCntFor2 := 1 To oMdlGrdDTA:Length()
		oMdlGrdDTA:GoLine(nCntFor2)
	
		If nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrdDTA:IsDeleted())
			cStatus := StrZero(1,Len(DT6->DT6_STATUS))
			cFilOri := Space(Len(DT6->DT6_FILVGA))
			cViagem := Space(Len(DT6->DT6_NUMVGA))
		ElseIf (nOperation == MODEL_OPERATION_INSERT .And. !oMdlGrdDTA:IsDeleted()) .Or. (nOperation == MODEL_OPERATION_UPDATE .And. !oMdlGrdDTA:IsDeleted())
			If FwFldGet("DTQ_SERTMS") == StrZero(2,Len(DTQ->DTQ_SERTMS))	//-- Viagem Transporte
				cStatus := StrZero(2,Len(DT6->DT6_STATUS))	//-- Carregado
			ElseIf FwFldGet("DTQ_SERTMS") == StrZero(3,Len(DTQ->DTQ_SERTMS))	//-- Viagem Entrega
				cStatus := StrZero(6,Len(DT6->DT6_STATUS))	//-- Indicado para Entrega
			EndIf
			cFilOri := FwFldGet("DTQ_FILORI")
			cViagem := FwFldGet("DTQ_VIAGEM")
		EndIf
	
		If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC")  + FwFldGet("DTA_SERIE")))
			RecLock("DT6",.F.)
			DT6->DT6_STATUS := cStatus
			DT6->DT6_FILVGA := cFilOri
			DT6->DT6_NUMVGA := cViagem
			DT6->(MsUnlock())
		EndIf
	Next nCntFor2

Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90PrVld
Grava os campos da DT6 na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90PrVld(oModel)
Local lRet       := .T.
Local lCont      := .T.
Local aManifes   := {}
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local nOperation := 0

Default oModel  := FwModelActive()

nOperation := oModel:GetOperation()

If nOperation != MODEL_OPERATION_VIEW .And. nOperation != MODEL_OPERATION_INSERT
	//-- Posiciona na viagem
	If lPosVia
		DTQ->(DbSetOrder(2))
		lCont := (DTQ->(DbSeek(xFilial("DTQ") + DM6->(DM6_FILORI + DM6_VIAGEM))))
	EndIf
    
	If lCont
		//-- Verifica o status da viagem
		If DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) .And. DTQ->DTQ_STATUS != StrZero(4,Len(DTQ->DTQ_STATUS))	//-- Aberto ou Chegada em Filial
			Help("",1,"TMSAF9008")	//-- "Viagem não está em aberto, ou com chegada em filial."
			lRet := .F.
		EndIf
		
		//-- Verifica se permite o estorno do carregamento
		If lRet
			lRet := TMSChkViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,.T.,.F.,.F.,,.F.,.F.,,.T.,,,.F.,.T.)
		EndIf
		
		//-- Verifica se possui manifestos com cancelamento não transmitidos
		If lRet
			lRet := !TMF90CnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.T.)
		EndIf
		
		//-- Verifica se possui manifestos com encerramento não transmitidos
		If lRet
			lRet := !TMF90EnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.F.)
		EndIf

		//-- Verifica se todos os Lotes da Viagem estao calculados 
		If lRet 
			lRet:= TF64VldLot(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,"'3'")  //3-Calculado
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90CnMan
Busca se a viagem possui manifestos com cancelamento não transmitido
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90CnMan(cFilOri,cViagem,aManifes,lMstrErro,nLoop,cFilMan)
Local aAreas     := {GetArea()}
Local aAreaSM0   := {}
Local aMDFeCan   := {}
Local lContinua  := .F.
Local lRet       := .F.
Local cQuery     := ""
Local cAliasDYN  := ""
Local cErro      := ""
Local cTitFilMan := ""
Local cTitManife := ""
Local cTitSerMan := ""
Local cTitRTCMDF := ""
Local cFilBak    := cFilAnt

Default cFilOri  := ""
Default cViagem  := ""
Default aManifes := {}
Default lMsgErr  := .T.
Default nLoop    := 1
Default cFilMan  := ""

//-- Busca os titulos dos campos 
cTitFilMan  := FWX3Titulo("DTX_FILMAN")
cTitManife  := FWX3Titulo("DTX_MANIFE")
cTitSerMan  := FWX3Titulo("DTX_SERMAN")
cTitRTCMDF  := FWX3Titulo("DYN_RTCMDF") 

cAliasDYN := GetNextAlias()
cQuery += "SELECT DYN_FILMAN,DYN_MANIFE,DYN_SERMAN,DYN_VIAGEM,DYN_RTCMDF  "
cQuery += "  FROM " + RetSQLName("DYN") + " DYN "
cQuery += " WHERE DYN_FILIAL = '" + xFilial("DYN") + "' "
cQuery += "       AND DYN_FILORI = '" + cFilOri + "' "
cQuery += "       AND DYN_VIAGEM = '" + cViagem + "' "
cQuery += "       AND DYN_STCMDF <> '2' "	//2-Autorizado
If !Empty(cFilMan)
	cQuery += "       AND DYN_FILMAN = '" + cFilMan + "' " 
EndIf
cQuery += "       AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDYN,.F.,.T.)

While (cAliasDYN)->(!Eof())
    lRet := .T.

	If lMDFeAut .And. nLoop == 1
		Aadd(aMDFeCan,{(cAliasDYN)->DYN_FILMAN,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_SERMAN,(cAliasDYN)->DYN_VIAGEM,""})
	Else
		Aadd(aManifes,{(cAliasDYN)->DYN_FILMAN,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_SERMAN,(cAliasDYN)->DYN_RTCMDF})

		If lMsgErr
			cErro += cTitFilMan +  " : " + (cAliasDYN)->DYN_FILMAN + " | "
			cErro += cTitManife +  " : " + (cAliasDYN)->DYN_MANIFE + " | "
			cErro += cTitSerMan +  " : " + (cAliasDYN)->DYN_SERMAN + " | "
			cErro += cTitRTCMDF +  " : " + (cAliasDYN)->DYN_RTCMDF + CRLF + CRLF
		EndIf
	EndIf
	(cAliasDYN)->(DbSkip())
EndDo

(cAliasDYN)->(DbCloseArea())

If Len(aMDFeCan) > 0
	//-- Alterar o conteudo da variavel cFilAnt
	aAreaSM0  := SM0->(GetArea())
	cFilAnt   := Posicione("SM0",1,cEmpAnt + aMDFeCan[Len(aMDFeCan),1],"FWCODFIL()")
	lContinua := TmsMDFeAut(aMDFeCan,3) //-- Transmite o cancelamento do MDF-e
	If lContinua
		TmsLimpDUD(cFilOri,cViagem,aMDFeCan)	//-- Limpar a DUD
	EndIf
	cFilAnt := Posicione("SM0",1,cEmpAnt + cFilBak,"FWCODFIL()")
	RestArea(aAreaSM0)
EndIf

If !lMDFeAut .Or. nLoop > 1
	// Exibe a mensagem de erro.
	If lRet .AND. lMsgErr
		AutoGrLog(STR0012 + CRLF)	//-- "Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem cancelamento não transmitido:"
		AutoGrLog( cErro )
    	MostraErro()
	EndIf
Else
	lRet := TMF90CnMan(cFilOri,cViagem,aManifes,lMsgErr,++nLoop)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90EnMan
Busca se a viagem possui manifestos com encerramento não transmitido
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90EnMan(cFilOri,cViagem,aManifes,lMstrErro,nLoop,cFilMan)
Local aAreas     := {GetArea()}
Local aAreaSM0   := {}
Local aMDFeEnc   := {}
Local lContinua  := .F.
Local lRet       := .F.
Local cQuery     := ""
Local cAliasDTX  := ""
Local cErro      := ""
Local cTitFilMan := ""
Local cTitManife := ""
Local cTitSerMan := ""
Local cTitSTFMDF := ""
Local cFilBak    := cFilAnt
Local lUFAtiv    := DTX->(ColumnPos("DTX_UFATIV")) > 0
	
Default cFilOri   := ""
Default cViagem   := ""
Default aManifes  := {}
Default lMstrErro := .T.
Default nLoop     := 1
Default cFilMan   := ""

//--  Busca os titulos dos campos 
cTitFilMan  := FWX3Titulo("DTX_FILMAN")
cTitManife  := FWX3Titulo("DTX_MANIFE")
cTitSerMan  := FWX3Titulo("DTX_SERMAN")
cTitSTFMDF  := FWX3Titulo("DTX_STFMDF")

cAliasDTX := GetNextAlias()
cQuery += "SELECT DTX_FILMAN,DTX_MANIFE,DTX_SERMAN,DTX_VIAGEM,DTX_STFMDF "
If lUfAtiv 							
	cQuery += ",DTX_UFATIV "
EndIf
cQuery += "  FROM " + RetSQLName("DTX") + " DTX "
cQuery += " WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery += "       AND DTX_FILORI = '" + cFilOri + "' "
cQuery += "       AND DTX_VIAGEM = '" + cViagem + "' "
cQuery += "       AND DTX_STFMDF <> '2' "	//-- Encerramento não Autorizado
cQuery += "       AND DTX_STIMDF = '2' "	//-- Envio Autorizado
If !Empty(cFilMan)
	cQuery += "       AND DTX_FILMAN = '" + cFilMan + "' "
EndIf
cQuery += "       AND D_E_L_E_T_ = ' ' "
cQuery += "       AND NOT EXISTS (SELECT 1 "
cQuery += "                         FROM " + RetSqlName("DYN") + " DYN "
cQuery += "                        WHERE DYN.DYN_FILIAL = '" + xFilial("DYN") + "' "
cQuery += "                          AND DYN.DYN_FILORI = '" + cFilOri + "' "
cQuery += "                          AND DYN.DYN_VIAGEM = '" + cViagem + "' "
cQuery += "                          AND DYN.DYN_STCMDF <> '2' "	//-- Cancelamento não Autorizado
If !Empty(cFilMan)
	cQuery += "                          AND DYN.DYN_FILMAN = '" + cFilMan + "' "
EndIf
cQuery += "                          AND DYN.D_E_L_E_T_ = ' ' )"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDTX,.F.,.T.)

While (cAliasDTX)->(!Eof())
    lRet := .T.
	
	If lMDFeAut .And. nLoop == 1
		Aadd(aMDFeEnc,{(cAliasDTX)->DTX_FILMAN,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_SERMAN,(cAliasDTX)->DTX_VIAGEM,Iif(lUFAtiv,(cAliasDTX)->DTX_UFATIV,"")})
	Else
		Aadd(aManifes,{(cAliasDTX)->DTX_FILMAN,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_SERMAN,(cAliasDTX)->DTX_STFMDF})
						
		If lMstrErro
			cErro += cTitFilMan +  " : " + (cAliasDTX)->DTX_FILMAN + " | "
			cErro += cTitManife +  " : " + (cAliasDTX)->DTX_MANIFE + " | "
			cErro += cTitSerMan +  " : " + (cAliasDTX)->DTX_SERMAN + " | "
			cErro += cTitSTFMDF +  " : " + (cAliasDTX)->DTX_STFMDF + CRLF + CRLF
		EndIf
	EndIf
	(cAliasDTX)->(DbSkip())
EndDo

(cAliasDTX)->(DbCloseArea())
	
If Len(aMDFeEnc) > 0
	//-- Alterar o conteudo da variavel cFilAnt
	aAreaSM0  := SM0->(GetArea())
	cFilAnt   := Posicione("SM0",1,cEmpAnt + aMDFeEnc[Len(aMDFeEnc),1],"FWCODFIL()")
	lContinua := TmsMDFeAut(aMDFeEnc, 2)	//-- Transmite o Encerramento do MDF-e
	If lContinua
		TmsLimpDUD(cFilOri,cViagem,aMDFeEnc)	//-- Limpar a DUD
	EndIf
	cFilAnt := Posicione("SM0",1,cEmpAnt+cFilBak,"FWCODFIL()")
	RestArea(aAreaSM0)
EndIf 
	
If !lMDFeAut .Or. nLoop > 1
	// Exibe a mensagem de erro.
	If lRet .AND. lMstrErro
		AutoGrLog(STR0013 + CRLF)	//-- "Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem encerramento não transmitido:"
		AutoGrLog(cErro)
    	MostraErro()
	EndIf
Else
	lRet := TMF90EnMan(cFilOri,cViagem,aManifes,lMstrErro,++nLoop)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Lin
Chama Pre Validação da Linha dos Documentos
@type Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Lin(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet := .T.

lRet:= LinePreDTA(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)

Return lRet

/*{Protheus.doc} LinePreDTA
Pre Valida Linha dos Documentos
@type Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function LinePreDTA(oMdlGridDTA,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet   := .T.
Local aAreas := {GetArea()}

If cAction == "DELETE"
	If FwFldGet("DTA_FILATU") != cFilAnt
		Help("", 1,"TMSAF9007")	//-- "Somente é permitido o estorno do carregamento de documentos da filial atual."
		lRet:= .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Set
Seta valor em variável estatica
@type Function
@author Valdemar Roberto Mognon
@since 08/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Set(cVar,xCont)

&(cVar) := xCont

Return
