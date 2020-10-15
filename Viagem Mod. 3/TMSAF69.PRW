#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF69.CH"

//-----------------------------------------------
/* {Protheus.doc} TMSAF69
Rotina que administra as execuções automáticas
@type Function
@author Valdemar Roberto Mognon
@since 02/09/2020
@version P12 R12.1.29
@param nAção 1=Carregamento / 2=Fechamento
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

	If (MV_PAR01 == 2 .And. lLoteOk) .And. !TMFGetStat("lIncMot")	//-- Carregamento automático ### Não é inclusão de condutor		

		If lRet
			If !IsBlind()	//-- Processo não sendo executado de forma automática
				FWMsgRun(,{|| lRet := TF67AtuCar(oModel,nOpcx)},STR0001,STR0002)	//-- "Processando" ### "Executando Carregamento Automático ..."
			Else
				lRet := TF67AtuCar(oModel,nOpcx)
			EndIf
			
			If !lRet			
				Help("",1,"TMSAF6701",,,3,1)	//-- "Carregamento automático não efetuado. Execute o carregamento manualmente."
			EndIf			
		EndIf				
	EndIf
ElseIf nAcao == 2	//-- Fechamento
	Pergunte(cPerg,.F.)

	If MV_PAR01 == 1	//--Fechamento Automático
		If !IsBlind()	//-- Processo não sendo executado de forma automática
			FWMsgRun(,{|| lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)},STR0001,STR0003)	//-- "Processando" ### "Executando Fechamento Automático ..."
		Else
			lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)
		EndIf

		If !lRet
			Help("",1,"TMSAF9006",,,3,1)	//-- "Fechamento automático não efetuado. Execute o fechamento manualmente."
		EndIf
	EndIf
EndIf

Return lRet
