#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF63.CH"

Static cTmsErp := SuperGetMV("MV_TMSERP",,'0') 

//-------------------------------------------------------------------
/* TMSAF63
Rotina da Valida��o da Linha da Viagem Modelo 3 
@author  Katia
@since   17/06/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Function TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,cValid)

Local lRet		:= .T.
Local cModel    := ""

Default oModel	:= FWModelActive()

cModel:= Upper(oModel:cId)

If cModel == Upper("MdGridDM3")
	If cValid == "POS"
		lRet:= LinePosDM3(oModel)
	ElseIf cValid == "PRE"
		lRet:= LinePreDM3(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
	EndIf
ElseIf cModel == Upper("MdGridDTR")
	If cValid == "POS"
		lRet:= LinePosDTR(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= LinePreDTR(oModel,nLine,cAction,cIDField)
	EndIf
ElseIf cModel == Upper("MdGridDUP")
	If cValid == "POS"
		lRet:= LinePosDUP(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= LinePreDUP(oModel,nLine,cAction,cIDField)
	EndIf
ElseIf cModel == Upper("MdGridDUQ")
	If cValid == "POS"
		lRet:= LinePosDUQ(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= .T.
	EndIf
ElseIf cModel == Upper("MdGridDVW")
	If cValid == "POS"
		lRet:= LinePosDVW(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= LinePreDVW(oModel,nLine,cAction,cIDField)
	EndIf
ElseIf cModel == Upper("MdGridDLD")
	If cValid == "POS"
		lRet:= LinePosDLD(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= LinePreDLD(oModel,nLine,cAction,cIDField)
	EndIf	
ElseIf cModel == Upper("MdGridSDG")
	If cValid == "POS"
		lRet	:= TMSA070Vld( oModel,nLine )
		If lRet 
			lRet:= LinePosSDG(oModel,nLine)
		EndIf 
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePosDM3
Fun��o do Linha Ok da Grid dos Documentos (DM3) da Viagem Modelo 3 
@author  Katia
@since   17/06/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function LinePosDM3(oMdlGridDM3,nLine)
Local lRet       	:= .T.
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""

cFilDoc	:= FwFldGet("DM3_FILDOC")
cDoc	:= FwFldGet("DM3_DOC")
cSerie	:= FwFldGet("DM3_SERIE")

lRet	:= TF67BlqDoc( cFilDoc , cDoc , cSerie , .T. , .T. )

Return lRet

//-------------------------------------------------------------------
/* LinePreDM3
Fun��o do Pre Valida��o (bLinePre) da Linha da Grid dos Documentos (DM3)
@author  Katia
@since   29/06/2020
@version 1.0      
Fun��o TMSA144Del()
*/
//-------------------------------------------------------------------
Static Function LinePreDM3(oMdlGridDM3,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet       := .T.
Local aDocsDUA   := {}
Local aAreaDA8   := DA8->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oMdlFldDTQ := Nil
Local nLineDest  := 0

If cAction == "DELETE" .Or. cAction == "UNDELETE" 
	If cAction == "DELETE"  
		If !oMdlGridDM3:IsDeleted() //-- Est� deletando a linha
			aAdd(aDocsDUA, {oMdlGridDM3:GetValue("DM3_FILDOC"), oMdlGridDM3:GetValue("DM3_DOC"), oMdlGridDM3:GetValue("DM3_SERIE") })
			//-- Verifica se existe uma ocorr�ncia apontada para o documento.
			If !TMSDocOcor(aDocsDUA, M->DTQ_FILORI, M->DTQ_VIAGEM)
				lRet:= .F.
			EndIf
			
		EndIf
	EndIf

	If lRet .And.  oMdlGridDM3:GetValue('DM3_STATUS',nLine) != StrZero(1,Len(DUD->DUD_STATUS)) //-- Em Aberto
		Help(' ', 1, 'TMSA14402') //"Documento nao esta em aberto"
		lRet:= .F.
	EndIf

	If lRet .And. cAction == "UNDELETE"
		//--- Quando tem altera��o de Rota e o documento foi deletado por nao atender a rota, ao desmarcar a linha 
		//--- valida novamente se o documento  pertence a nova rota informada
		If !Empty(oMdlGridDM3:GetValue("DM3_DOC")) 
			oMdlFldDTQ:= oModel:GetModel("MdFieldDTQ")
			If oMdlFldDTQ:IsFieldUpdate('DTQ_ROTA')	 .And. !Empty(oMdlFldDTQ:GetValue('DTQ_ROTA'))
				lRet:= TMSAF62("DM3","M->DM3_SERIE")
			EndIf	
		EndIf
		If lRet
			//-- Nao permite tirar a marca de dele��o em viagens de transporte vazia
			If FwFldGet("DTQ_SERTMS") $ " 23" .And. (FwFldGet("DTQ_TIPVIA") == StrZero(2,Len(DTQ->DTQ_TIPVIA)) .Or. FwFldGet("DTQ_TIPVIA") == StrZero(4,Len(DTQ->DTQ_TIPVIA)))
				Help("",1,"TMSAF6304")	//-- "Viagem dos tipos vazia e socorro n�o podem possuir documentos."
				lRet := .F.
			Endif
		EndIf
	EndIf

ElseIf cAction == "CANSETVALUE" 
	//-- Nao permite alteracao do documento na viagem
	If !oMdlGridDM3:IsInserted() .And. cIDField $ "DM3_FILDOC|DM3_DOC|DM3_SERIE" 
		lRet:= .F.	
	EndIf

ElseIf cAction == "SETVALUE" 	
	If cIDField == 'DM3_SEQUEN'
		If !Empty(xValue) .And. !Empty(xCurrentValue)
			If xValue <> xCurrentValue
				If oMdlGridDM3:SeekLine({{"DM3_SEQUEN", xValue}}) 						
					If FwFldGet('DM3_STATUS') <> StrZero(3,Len(DUD->DUD_STATUS))   //Carregado
						nLineDest:= oMdlGridDM3:GetLine()			
										
						TF65SetaSt(xValue,nLine,xCurrentValue,nLineDest) //Seta Variavel Static
					Else
						TF62SetaSt(.F.,.T.)	//Seta Variavel Static			
					EndIf
				Else
					TF62SetaSt(.F.,.F.)	//Seta Variavel Static			
				EndIf	
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDA8)
RestArea(aAreaDT6)
RestArea(aArea)

FwFreeArray(aAreaDA8)
FwFreeArray(aAreaDT6)
FwFreeArray(aArea)
FwFreeArray(aDocsDUA)
Return lRet

//-------------------------------------------------------------------
/* LinePosDTR
Fun��o do Linha Ok da Grid dos Veiculos (DTR) da Viagem Modelo 3 
@author  Katia
@since   07/07/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function LinePosDTR(oMdlGridDTR,nLine)
Local lRet      := .T.
Local aArea     := GetArea() 
Local aAreaDA3  := DA3->( GetArea() )
Local cCodVei	:= ""
Local cCodRB1	:= ""
Local cCodRB2	:= ""
Local cCodRB3	:= ""
Local cCatVei   := ""

If lRet
	cCodVei		:= FwFldGet("DTR_CODVEI")
	cCodRB1		:= FwFldGet("DTR_CODRB1")
	cCodRB2		:= FwFldGet("DTR_CODRB2")
	cCodRB3		:= FwFldGet("DTR_CODRB3")

	lRet	:= TF64VldVei(cCodVei) .And. TF64VldVei(cCodRB1) .And. TF64VldVei(cCodRB2) .And. TF64VldVei(cCodRB3)

	If lRet
		lRet	:= TF67BlqVei( cCodVei , cCodRB1 , cCodRB2, cCodRB3 , .T. , .T. )
	EndIf
EndIf

If lRet .And. nLine > 1
	If !Empty(FwFldGet("DM5_CODOPE"))
		Help('',1,'TMSA24086') //--N�o � poss�vel utilizar comboio quando a viagem for integrada com Operadora de Frete!
		lRet := .F.
	ElseIf cTmsErp == '1' 
		Help('',1,'TMSA24087') //--N�o � poss�vel utilizar comboio quando o SIGATMS estiver integrado com ERP Datasul!
		lRet := .F.
	EndIf
EndIf

If lRet
	cCatVei:= TF62CatVei(cCodVei)
	If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI))
		If 	M->DTQ_TIPVIA <> '4' .And. M->DTQ_TIPVIA <> '2' //-- Socorro (4) e Vazia (2)
			If Empty(cCodRB1)
				Help('',1,'TMSA24027') // A escolha do primeiro reboque e obrigatorio para um veiculo do tipo cavalo.
				lRet := .F.
			EndIf					
			If Empty(cCodRB2) .And. !Empty(cCodRB3)
				Help('',1,'TMSA24080') // Informe o 2� Reboque
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDA3)
RestArea(aArea)
FwFreeArray(aAreaDA3)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/* LinePreDTR
Fun��o do Pre Valida��o (bLinePre) da Linha da Grid dos Veiculos (DTR)
@author  Katia
@since   29/06/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function LinePreDTR(oMdlGridDTR,nLine,cAction,cIDField)
Local lRet    := .T.

If cAction == "CANSETVALUE" 
	//-- Nao permite alteracao do veiculo
	If !Empty(M->DM4_FILVGE) .And. !Empty(M->DM4_NUMVGE)
		If !(cIDField $ "DTR_VALFRE|DTR_VALRB1|DTR_VALRB2|DTR_VALRB3") 
			lRet:= .F.	
		EndIf
	EndIf

	If !oMdlGridDTR:IsInserted() 
		If cIDField $ "DTR_CODVEI|DTR_CODRB1|DTR_CODRB2|DTR_CODRB3" 
			lRet:= .F.	
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePosDUP
Pos Valida Linha da DUP
@type Static Function
@author Valdemar Roberto Mognon
@since 06/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
//-------------------------------------------------------------------
Static Function LinePosDUP(oModel,nLine)
Local lRet := .T.


Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePreDUP
Pre Valida Linha da DUP (Trata o delete e o undelete da linha)
@type Static Function
@author Valdemar Roberto Mognon
@since 06/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
//-------------------------------------------------------------------
Static Function LinePreDUP(oModel,nLine,cAction,cIDField)
Local lRet := .T.

Default oModel   := Nil
Default nLine    := 0
Default cAction  := ""
Default cIDField := ""

If cAction == "UNDELETE" 
	//-- Executa as valida��es dos campos na retirada do delete da linha
	lRet := TMSAF62("DUP","DUP_CODMOT")
ElseIf cAction == "DELETE" 
	If TMFGetStat("lIncMot") .And. !oModel:IsInserted()
		Help("",1,"TMSAF6303")	//-- Na inclus�o de condutor, n�o � permitido a exclus�o do motorista j� existente.
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePosDUQ
Fun��o do Linha Ok da Grid dos Ajudantes (DUQ) da Viagem Modelo 3 
@author  Caio Murakami
@since   15/07/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function LinePosDUQ(oMdlGridDUQ,nLine)
Local lRet		:= .T. 
Local cCodAju	:= ""

cCodAju	:= FwFldGet("DUQ_CODAJU")

lRet	:= TF67BlqAju( cCodAju , .T. , .T. ) 

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} LinePreDVW
Pre Valida Linha da DVW
@type Static Function
@author Valdemar Roberto Mognon
@since 23/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
//-------------------------------------------------------------------
Static Function LinePreDVW(oModel,nLine,cAction,cIDField)
Local lRet := .T.

Default oModel   := Nil
Default nLine    := 0
Default cAction  := ""
Default cIDField := ""

If cAction == "DELETE"
	If !Empty(FwFldGet("DVW_ORIGEM")) .And. FwFldGet("DVW_ORIGEM") != "TMSA240"
		Help("",1,"TMSAF6302")	//-- "O valor informado n�o foi gerado pelo TMS."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePosDVW
Pos Valida Linha da DVW
@type Static Function
@author Valdemar Roberto Mognon
@since 23/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
//-------------------------------------------------------------------
Static Function LinePosDVW(oModel,nLine)
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePosDLD
Pos Valida Linha da DLD
@type Static Function
@author Katia
@since 27/07/2020
@version 12.130
@param oModel, nLinha
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePosDLD(oModel,nLine)
Local lRet       := .T.

If M->DM5_CODOPE == '02'  //Pamcard
	lRet:= PamDLDLok()
EndIf


Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePreDLD
Pos Valida Linha da DLD
@type Static Function
@author Katia
@since 27/07/2020
@version 12.130
@param oModel, nLinha
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePreDLD(oModel,nLine,cAction,cIDField)
Local lRet:= .T.

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LinePosSDG
Pos Valida Linha da SDG
@type Static Function
@author Caio Murakami
@since 20/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
//-------------------------------------------------------------------
Static Function LinePosSDG(oModel, nLine)
Local lRet		:= .T. 
Local cBco 		:= FwFldGet('DG_BANCO')
Local cAge 		:= FwFldGet('DG_AGENCIA')
Local cCta 		:= FwFldGet('DG_NUMCON')
Local lGerTit 	:= GetMV('MV_GERTIT' ,,.T.)
Local cCodFor	:= ""
Local cLojFor	:= ""
Local cCodVenc	:= ""

If !Empty( FwFldGet("DG_CODDES") ) 
	DT7->(dbSetOrder(1))
	If DT7->(MsSeek(xFilial('DT7')+ FwFldGet("DG_CODDES")  ) )
		//-- Se no cadastro da despesa o campo 'Movimento bancario' tiver conteudo igual a 'Sim'
		If DT7->DT7_MOVBCO == '1' 
			If	Empty(cBco) .Or. Empty(cAge) .Or. Empty(cCta)
				lRet	:= .F. 
				Help('',1,'TMSA24035')	//-- Informe o Banco / Agencia / No. da Conta ...
			EndIf
			If	!Empty(cBco) .And. 	!Empty(cAge) .And. 	!Empty(cCta)
				//-- Verifica se Banco/Agencia/Conta encontra-se bloqueado.
				If !CarregaSA6(cBco,cAge,cCta,.T.,,.T.)
					lRet	:= .F. 
				EndIf
			EndIf
		EndIf
	EndIf
EndIf 

If lRet
	If	Empty(FwFldGet('DG_TOTAL')) .Or. Empty(FwFldGet('DG_VALCOB')) 
		lRet	:= .F. 
		Help('',1,'TMSA24007', , STR0010 + AllTrim(Str(nLine)), 3, 1 ) //"Existem campos com valores zerados" ### "Linha :"	
	EndIf
EndIf 

If lRet
	If lGerTit	
		If !Empty(cBco)		
			IF !Empty( FwFldGet("DM5_CODOPE") )
				cCodFor := Posicione("DA3",1,xFilial("DA3")+FwFldGet("DTR_CODVEI"),"DA3_CODFOR")
				cLojFor := Posicione("DA3",1,xFilial("DA3")+FwFldGet("DTR_CODVEI"),"DA3_LOJFOR")		
				cCodVenc:= Posicione('SA2',1,FwxFilial('SA2')+cCodFor+cLojFor,'A2_COND')		
				IF Empty(cCodVenc)
			   		lRet	:= .F. 
					Help('',1,'HELP',,STR0011,1,0) //-- "� necess�rio informar a condi��o de pagamento para o propriet�rio do ve�culo" 
				EndIF
			EndIF
		EndIF
	EndIF
EndIf 

Return lRet 

