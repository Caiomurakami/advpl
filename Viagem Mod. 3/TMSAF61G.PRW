#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMS3GFE := TmsIntGFE('02')

/*{Protheus.doc} TMSAF61G
Valida when dos campos da viagem modelo 3 - Integração TMS x GFE
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return lRet
*/

Function TMSAF61G(cOrigem)
Local lRet := .T.

Default cOrigem := ""

If cOrigem == "DTQ"
	lRet := WhenDTQGFE()
ElseIf cOrigem == "DM8"
	lRet := WhenDM8()
ElseIf cOrigem == "DJN"
	lRet := WhenDJN()
EndIf

Return lRet

/*{Protheus.doc} WhenDTQGFE
Executa o when dos campos da DTQ x GFE
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return lRet
*/

Static Function WhenDTQGFE()
Local lRet       := .T.
Local cCampo     := ReadVar()

If cCampo $ 'M->DTQ_PAGGFE|M->DTQ_TIPVEI|M->DTQ_CDTPOP|M->DTQ_CDCLFR|M->DTQ_UFORI|M->DTQ_CDMUNO|M->DTQ_CEPORI|M->DTQ_UFDES|M->DTQ_CDMUND|M->DTQ_CEPDES'
	If !lTMS3GFE 
		lRet:=.F.
	EndIf
EndIf	

Return lRet

/*{Protheus.doc} WhenDM8
Executa o when dos campos da DM8
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return lRet
*/
Static Function WhenDM8()
Local lRet       := .T.
Local cCampo     := ReadVar()
	
//-- Estes campos serao preenchidos automaticamente na gravação da viagem atraves do conteudo do campo DUD_FILDCA
If cCampo $ 'M->DM8_UFDES|M->DM8_CDMUND|M->DM8_CEPDES'
	If M->DTQ_SERTMS == StrZero(2,Len(DC5->DC5_SERTMS))
		lRet:= .F.
	EndIf 
EndIf

Return lRet

/*{Protheus.doc} WhenDJN
Executa o when dos campos da DJN
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return lRet
*/
Static Function WhenDJN()
Local lRet       := .T.

Return lRet

