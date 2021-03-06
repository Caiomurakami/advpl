#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF69.CH"

//-----------------------------------------------
/* {Protheus.doc} TMSAF69
Rotina que administra as execu��es autom�ticas
@type Function
@author Valdemar Roberto Mognon
@since 02/09/2020
@version P12 R12.1.29
@param nA��o 1=Carregamento / 2=Fechamento
@return lRet
*///---------------------------------------------    

Function TMSAF69(nAcao,cPerg,nOpcx,oModel)
Local lRet      := .T.
Local oMdlFldDTQ:= Nil
Local lLoteVge  := .F.
Local lLoteOk   := .T.

Default nAcao  := 0
Default cPerg  := ""
Default nOpcx  := 0
Default oModel := FWModelActive()

oMdlFldDTQ:= oModel:GetModel ("MdFieldDTQ") 

If nAcao == 1	//-- Carregamento
	Pergunte(cPerg,.F.)

	//-- Verifica se todos os Lotes da Viagem estao calculados para efetuar o carregamento (EXPRESS)
	lLoteVge:= TF64ELote(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'))
	If lLoteVge
		lLoteOk:= TF64VldLot(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'),"'3'")  //3-Calculado
	EndIf

	If (MV_PAR01 == 2 .And. lLoteOk) .And. !TMFGetStat("lIncMot")	//-- Carregamento autom�tico ### N�o � inclus�o de condutor		

		If lRet
			If !IsBlind()	//-- Processo n�o sendo executado de forma autom�tica
				FWMsgRun(,{|| lRet := TF67AtuCar(oModel,nOpcx)},STR0001,STR0002)	//-- "Processando" ### "Executando Carregamento Autom�tico ..."
			Else
				lRet := TF67AtuCar(oModel,nOpcx)
			EndIf
			
			If !lRet			
				Help("",1,"TMSAF6701",,,3,1)	//-- "Carregamento autom�tico n�o efetuado. Execute o carregamento manualmente."
			EndIf			
		EndIf				
	EndIf
ElseIf nAcao == 2	//-- Fechamento
	Pergunte(cPerg,.F.)

	If MV_PAR01 == 1	//--Fechamento Autom�tico
		If !IsBlind()	//-- Processo n�o sendo executado de forma autom�tica
			FWMsgRun(,{|| lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)},STR0001,STR0003)	//-- "Processando" ### "Executando Fechamento Autom�tico ..."
		Else
			lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)
		EndIf

		If !lRet
			Help("",1,"TMSAF9006",,,3,1)	//-- "Fechamento autom�tico n�o efetuado. Execute o fechamento manualmente."
		EndIf
	EndIf
EndIf

Return lRet
