#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF68.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMSExp    := SuperGetMv("MV_TMSEXP",.F.,.F.)	//-- Indica TMSExpress ativo
Static lRotaInt   := SuperGetMV("MV_ROTAINT",,.F.)		//-- Integração Rota Inteligente
Static cTipDocMot := SuperGetMv("MV_DMOTEST",.F.," ")	//-- Tipos de documentos que pede motivo
Static cTMSOpDg   := SuperGetMv("MV_TMSOPDG", .F., .F.)	//-- Indica se a integração com Operadoras de Frota está ativa.
Static cAtvChgCli := SuperGetMv("MV_ATVCHGC",,"")		//-- Atividade de Chegada em Cliente
Static lTmf68Mnu  := ExistBlock("TMF68MNU")				//-- Verifica se existe ponto de entrada para inclusão de itens no menu da viagem modelo 3

/*{Protheus.doc} TMSAF68
Adiciona itens no menu da viagem modelo 3
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
Function TMSAF68(aRotina)
Local aEncerrame := {}
Local aFechament := {}
Local aComprovan := {}
Local aManifesto := {}
Local aCarregame := {}
Local aImpressao := {}
Local aManutenca := {}
Local aImpManife := {}
Local aRentabili := {}
Local aRoteiriza := {}
Local aRotUsu    := {}
Local nCntFor1   := 0

//-- Monta menu do carregamento da viagem
ADD OPTION aCarregame TITLE STR0014 ACTION "TMSAF68Sub( 1, 1)" OPERATION  2 ACCESS 0	//-- "Visualizar"
ADD OPTION aCarregame TITLE STR0015 ACTION "TMSAF68Sub( 1, 2)" OPERATION  2 ACCESS 0	//-- "Carregar"
ADD OPTION aCarregame TITLE STR0002 ACTION "TMSAF68Sub( 1, 3)" OPERATION  2 ACCESS 0	//-- "Estornar"

//-- Monta menu dos manifestos da viagem
ADD OPTION aManifesto TITLE STR0006 ACTION "TMSAF68Sub( 2, 1)" OPERATION  2 ACCESS 0	//-- "Visual/Excluir"
ADD OPTION aManifesto TITLE STR0007 ACTION "TMSAF68Sub( 2, 2)" OPERATION  2 ACCESS 0	//-- "Manifestar"
ADD OPTION aManifesto TITLE STR0008 ACTION "TMSAF68Sub( 2, 3)" OPERATION  2 ACCESS 0	//-- "MDF-e"
ADD OPTION aManifesto TITLE STR0009 ACTION "TMSAF68Sub( 2, 4)" OPERATION  2 ACCESS 0	//-- "Tracking eventos MDFe"
If ExistFunc("TMSA73BX1") .And. TMSA73BX1()
	ADD OPTION aManifesto TITLE STR0010 ACTION "TMSAF68Sub( 2, 5)" OPERATION  2 ACCESS 0	//-- "Consulta"
EndIf
ADD OPTION aManifesto TITLE STR0011 ACTION "TMSAF68Sub( 2, 6)" OPERATION  2 ACCESS 0	//-- "Histórico MDF-e"
ADD OPTION aManifesto TITLE STR0012 ACTION "TMSAF68Sub( 2, 7)" OPERATION  2 ACCESS 0	//-- "Vis. Percurso"
ADD OPTION aManifesto TITLE STR0013 ACTION "TMSAF68Sub( 2, 8)" OPERATION  2 ACCESS 0	//-- "Editar Percurso"
ADD OPTION aManifesto TITLE STR0019 ACTION "TMSAF68Sub( 2, 9)" OPERATION  2 ACCESS 0	//-- "Inclusão Condutor"

//-- Monta menu do fechamento da viagem
ADD OPTION aFechament TITLE STR0003 ACTION "TMSAF68Sub( 3, 1)" OPERATION  2 ACCESS 0	//-- "Fechar"
ADD OPTION aFechament TITLE STR0002 ACTION "TMSAF68Sub( 3, 2)" OPERATION  2 ACCESS 0	//-- "Estornar"

//-- Monta menu do encerramento da viagem
ADD OPTION aEncerrame TITLE STR0001 ACTION "TMSAF68Sub( 4, 1)" OPERATION  2 ACCESS 0	//-- "Encerrar"
ADD OPTION aEncerrame TITLE STR0002 ACTION "TMSAF68Sub( 4, 2)" OPERATION  2 ACCESS 0	//-- "Estornar"

//-- Monta menu do comprovante de entrega eletrônico
ADD OPTION aComprovan TITLE STR0004 ACTION "TMSAF68Sub( 5, 1)" OPERATION  2 ACCESS 0	//-- "Monitora"
ADD OPTION aComprovan TITLE STR0005 ACTION "TMSAF68Sub( 5, 2)" OPERATION  2 ACCESS 0	//-- "Altera"

//-- Monta menu da rentabilidade prévia da viagem
ADD OPTION aRentabili TITLE STR0037 ACTION "TMSAF68Sub( 6, 1)" OPERATION  2 ACCESS 0	//-- "Simular Rentabilidade"
ADD OPTION aRentabili TITLE STR0038 ACTION "TMSAF68Sub( 6, 2)" OPERATION  2 ACCESS 0	//-- "Excluir Rentabilidade"

//-- Monta menu da integração com reteirizador
If lRotaInt
	ADD OPTION aRoteiriza TITLE STR0040 ACTION "TMSAF68Sub( 7, 1)" OPERATION  2 ACCESS 0	//-- "Integra Roteirizador"
	ADD OPTION aRoteiriza TITLE STR0041 ACTION "TMSAF68Sub( 7, 2)" OPERATION  2 ACCESS 0	//-- "Consulta Roteirizador"
	ADD OPTION aRoteiriza TITLE STR0042 ACTION "TMSAF68Sub( 7, 3)" OPERATION  2 ACCESS 0	//-- "Legenda Roteirizador"
EndIf
	
//-- Monta menu de manutenção da viagem
ADD OPTION aManutenca TITLE STR0016 ACTION "TMSAF68Sub( 8, 1)" OPERATION  2 ACCESS 0	//-- "Confirmação"
ADD OPTION aManutenca TITLE STR0017 ACTION Aclone(aCarregame)  OPERATION  2 ACCESS 0	//-- "Carregamento"
ADD OPTION aManutenca TITLE STR0018 ACTION Aclone(aManifesto)  OPERATION  2 ACCESS 0	//-- "Manifesto"
ADD OPTION aManutenca TITLE STR0020 ACTION "TMSAF68Sub( 8, 2)" OPERATION  2 ACCESS 0	//-- "Geração AWB"
ADD OPTION aManutenca TITLE STR0021 ACTION "TMSAF68Sub( 8, 3)" OPERATION  2 ACCESS 0	//-- "Operações"
ADD OPTION aManutenca TITLE STR0022 ACTION Aclone(aFechament)  OPERATION  2 ACCESS 0	//-- "Fechamento"
ADD OPTION aManutenca TITLE STR0023 ACTION "TMSAF68Sub( 8, 4)" OPERATION  2 ACCESS 0	//-- "Reg.Ocorrência"
ADD OPTION aManutenca TITLE STR0024 ACTION Aclone(aEncerrame)  OPERATION  2 ACCESS 0	//-- "Encerramento"
ADD OPTION aManutenca TITLE STR0025 ACTION Aclone(aComprovan)  OPERATION  2 ACCESS 0	//-- "Compr Entrega"
ADD OPTION aManutenca TITLE STR0026 ACTION "TMSAF68Sub( 8, 5)" OPERATION  2 ACCESS 0	//-- "Movto.Caixinha"
If lTMSExp
	ADD OPTION aManutenca TITLE STR0027 ACTION "TMSAF68Sub( 8, 6)" OPERATION  2 ACCESS 0	//-- "Estorno Express"
EndIf
ADD OPTION aManutenca TITLE STR0028 ACTION "TMSAF68Sub( 8, 7)" OPERATION  2 ACCESS 0	//-- "Retorno de Unitizadores"
ADD OPTION aManutenca TITLE STR0029 ACTION "TMSAF68Sub( 8, 8)" OPERATION  2 ACCESS 0	//-- "Fornecedores Adicionais"
If cTMSOpDg $ "1:2"	//-- Vale Pedágio e Frota
	ADD OPTION aManutenca TITLE STR0036 ACTION "TMSAF68Sub( 8, 9)" OPERATION  2 ACCESS 0	//-- "Troca de Cartão"
EndIf

//-- Inclui sub-menu de manutenção da viagem na rotina principal		
If lTMSExp
	ADD OPTION aImpManife TITLE STR0018 ACTION "TMSAF68Sub( 9, 1)" OPERATION  2 ACCESS 0	//-- "Manifesto"
	ADD OPTION aImpManife TITLE STR0030 ACTION "TMSAF68Sub( 9, 2)" OPERATION  2 ACCESS 0	//-- "DAMDFE"

	ADD OPTION aImpressao TITLE STR0031 ACTION "TMSAF68Sub(10, 1)" OPERATION  2 ACCESS 0	//-- "Contrato"
	ADD OPTION aImpressao TITLE STR0032 ACTION "TMSAF68Sub(10, 2)" OPERATION  2 ACCESS 0	//-- "Cheque"
	ADD OPTION aImpressao TITLE STR0018 ACTION Aclone(aImpManife)  OPERATION  2 ACCESS 0	//-- "Manifesto"

	ADD OPTION aRotina    TITLE STR0033 ACTION Aclone(aImpressao)  OPERATION  8 ACCESS 0	//-- "Imprimir"
EndIf	
ADD OPTION aRotina    TITLE STR0034 ACTION Aclone(aManutenca)  OPERATION  9 ACCESS 0	//-- "Manutencao"
ADD OPTION aRotina    TITLE STR0039 ACTION Aclone(aRentabili)  OPERATION 10 ACCESS 0	//-- "Rentabilidade Prévia"
If lRotaInt
	ADD OPTION aRotina    TITLE STR0043 ACTION Aclone(aRoteiriza)  OPERATION 11 ACCESS 0	//-- "Roteirizador"
EndIf

//-- Executa ponto de entrada para inclusão de itens no menu da viagem modelo 3
If lTmf68Mnu
	aRotUsu := ExecBlock("TMF68MNU",.F.,.F.,{})
	If ValType(aRotUsu) == "A"
		For nCntFor1 := 1 To Len(aRotUsu)
			ADD OPTION aRotina TITLE aRotUsu[nCntFor1,1] ACTION aRotUsu[nCntFor1,2] OPERATION (nCntFor1 + 11) ACCESS 0	//-- Opçoes do usuário
		Next nCntFor1
	EndIf
EndIf

FwFreeArray(aEncerrame)
FwFreeArray(aFechament)
FwFreeArray(aComprovan)
FwFreeArray(aManifesto)
FwFreeArray(aCarregame)
FwFreeArray(aImpressao)
FwFreeArray(aManutenca)
FwFreeArray(aImpManife)
FwFreeArray(aRentabili)
FwFreeArray(aRoteiriza)

Return aRotina

/*{Protheus.doc} TMSAF68Sub
Controla as chamadas das funções do menu da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 12/08/2020
@version version
@param nRotina (indica a rotina do menu) / nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68Sub(nRotina,nAcao)

Private cCadastro := STR0059	//-- "Viagem Modelo 3"

Default nRotina := 0
Default nAcao   := 0

If nRotina > 0 .And. nAcao > 0
	If nRotina == 1			//-- Carregamento da viagem
		ExecCarreg(nAcao)
	ElseIf nRotina == 2		//-- Manifestos da viagem
		ExecManife(nAcao)
	ElseIf nRotina == 3		//-- Fechamento da viagem
		ExecFecham(nAcao)
	ElseIf nRotina == 4		//-- Encerramento da viagem
		ExecEncerr(nAcao)
	ElseIf nRotina == 5		//-- Comprovante de entrega eletrônico
		ExecCompro(nAcao)
	ElseIf nRotina == 6		//-- Rentabilidade prévia da viagem
		ExecRentab(nAcao)
	ElseIf nRotina == 7		//-- Integração com roteirizador
		ExecRoteir(nAcao)
	ElseIf nRotina == 8		//-- Manutenções da viagem
		ExecManute(nAcao)
	ElseIf nRotina == 9		//-- Impressão dos manifestos (viagem express)
		ExecImpMan(nAcao)
	ElseIf nRotina == 10	//-- Impressões de contrato e cheque (viagem express)
		ExecImpres(nAcao)
	EndIf
EndIf

Return

/*{Protheus.doc} ExecCarreg
Executa as funções do carregamento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecCarreg(nAcao)
Local aAreas := {DM6->(GetArea()),GetArea()}

Default nAcao := 0

//-- Verifica se já existe carregamento
DM6->(DbSetOrder(1))
If DM6->(DbSeek(xFilial("DM6") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	If nAcao == 1			//-- Visualizar
		If TmsAcesso(,"TMSAF90",,2)
			FWExecView(,"TMSAF90",MODEL_OPERATION_VIEW)
		EndIf
	ElseIf nAcao == 2		//-- Carregar alterando
		If TmsAcesso(,"TMSAF90",,4)
			FWExecView(,"TMSAF90",MODEL_OPERATION_UPDATE)
		EndIf
	Else					//-- Estornar
		If TmsAcesso(,"TMSAF90",,5)
			FWExecView(,"TMSAF90",MODEL_OPERATION_DELETE)
		EndIf
	EndIf
Else
	If nAcao == 2	//-- Carregar do início
		If TmsAcesso(,"TMSAF90",,3)
			FWExecView(,"TMSAF90",MODEL_OPERATION_INSERT)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} ExecManife
Executa as funções dos manifestos da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecManife(nAcao)
Local aAreas     := {DTR->(GetArea()),DTX->(GetArea()),GetArea()}
Local aIndexSub  := {}
Local aCores     := {}
Local cFiltraSub := ""
Local lColig     := .T.
Local bFiltraSub

Private aRotina := {}

Default nAcao := 0

DTR->(DbSetOrder(1))
If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))) .And. !Empty(DTR->DTR_NUMVGE) .And. !Empty(DTR->DTR_FILVGE)
	lColig := .T.
EndIf

If nAcao == 1			//-- Visual/Excluir
	SetFunName("TMSA190")

	DTX->(DbSetOrder(1))

	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "Pesquisar"
			
	If TmsAcesso(,"TMSA190",,2,.F.)
		Aadd(aRotina,{STR0014,"TmsA190Mnt",0,2})	//-- "Visualizar"
	EndIf
	If TmsAcesso(,"TMSA190",,5,.F.)
		Aadd(aRotina,{STR0051,"TmsA190Mnt",0,5})	//-- "Excluir"
	EndIf

	Aadd(aRotina,{STR0047,"TmsA190Leg",0,6})	//-- "Legenda"
			
	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DTX_FILIAL == '" + xFilial("DTX") + "' .And. DTX_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTX_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"

		bFiltraSub := {|| FilBrowse("DTX",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)

		Aadd(aCores,{"Empty(DTX->DTX_NUMCTC)" ,"BR_VERDE"   })	//-- Em Aberto
		Aadd(aCores,{"!Empty(DTX->DTX_NUMCTC)","BR_VERMELHO"})	//-- Contrato Gerado

		MaWndBrowse(0,0,300,600,STR0007,"DTX",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Manisfestar"

		EndFilBrw("DTX",aIndexSub)
	EndIf
ElseIf nAcao == 2		//-- Manifestar
	SetFunName("TMSA190")

	DTX->(DbSetOrder(3))
	If lColig .And. DTX->(DbSeek(xFilial("DTX") + DTR->(DTR_FILVGE + DTR->DTR_NUMVGE)))
		Help("",1,"TMSAF6802",,STR0049 + AllTrim(DTX->DTX_MANIFE) + " / " + STR0050 + AllTrim(DTR->DTR_FILVGE) + '-' + AllTrim(DTR->DTR_NUMVGE),03,00)	//-- "Viagem já manifestada." ### "Manifesto: " ### "Viagem Principal: "
	Else
		If TmsAcesso(,"TMSA190",,3)
			aRotina := {{"","",0,1},;
						{"","",0,2},;
						{"","",0,3},;
						{"","",0,5}}
			TmsA190Mnt("DTX",0,3,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
		EndIf
	EndIf
ElseIf nAcao == 3		//-- MDF-e
	If TmsAcesso(,"TMSAE73",,2,.F.)
		TMSAE73()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 4		//-- Tracking eventos MDFe
	If TmsAcesso(,"TMSAE74",,4,.F.)
		TMSAE74()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 5		//-- Consulta
	If TmsAcesso(,"TMSAE73B",,2,.F.)
		TMSAE73B()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 6		//-- Histórico MDF-e
	If TmsAcesso(,"TMSA190A",,2,.F.)
		TMSA190A(2)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 7		//-- Vis. Percurso
	If TmsAcesso(,"TMSAF68PER",,2,.F.)
		TMSAF68PER(.F.)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 8		//-- Editar Percurso
	If TmsAcesso(,"TMSAF68PER",,2,.F.)
		TMSAF68PER(.T.)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
Else					//-- Inclusão condutor
	If TmsAcesso(,"TMSAF68TRM",,2,.F.)
		TMSAF68TRM()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)

Return

/*{Protheus.doc} ExecFecham
Executa as funções do fechamento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecFecham(nAcao)

Private aRotina := {{"","",0,1},;
					{"","",0,2},;
					{"","",0,3},;
					{"","",0,5}}

Default nAcao := 0

SetFunName("TMSA310")

If nAcao == 1			//-- Fechar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		If TmsAcesso(,"TMSA310B",,3)
			TMSA310Mnt("DTQ",DTQ->(Recno()),3,,.T.)
		EndIf
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If TmsAcesso(,"TMSA310D",,3)
			TMSA310Mnt("DTQ",DTQ->(Recno()),3,,.T.)
		EndIf
	EndIf		
Else					//-- Estornar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		If TmsAcesso(,"TMSA310B",,4)
			TMSA310Mnt("DTQ",DTQ->(Recno()),4,,.T.)
		EndIf
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If TmsAcesso(,"TMSA310D",,4)
			TMSA310Mnt("DTQ",DTQ->(Recno()),4,,.T.)
		EndIf
	EndIf		
EndIf

Return

/*{Protheus.doc} ExecEncerr
Executa as funções do encerramento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecEncerr(nAcao)

Private Rotina := {{"","",0,1},;
				   {"","",0,2},;
				   {"","",0,3},;
				   {"","",0,5}}

Default nAcao := 0

SetFunName("TMSA340")

If nAcao == 1			//-- Encerrar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		If TmsAcesso(,"TMSA340B",,3)
			TMSA340Mnt("DTQ",0,3)
		EndIf
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If TmsAcesso(,"TMSA340D",,3)
			TMSA340Mnt("DTQ",0,3)
		EndIf
	EndIf
Else					//-- Estornar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		If TmsAcesso(,"TMSA340B",,4)
			TMSA340Mnt("DTQ",DTQ->(Recno()),4)
		EndIf
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If TmsAcesso(,"TMSA340D",,4)
			TMSA340Mnt("DTQ",DTQ->(Recno()),4)
		EndIf
	EndIf
EndIf

Return

/*{Protheus.doc} ExecCompro
Executa as funções do comprovante de entrega
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecCompro(nAcao)

Default nAcao := 0

If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
	If nAcao == 1			//-- Monitora
		TMSAE71A()
	Else					//-- Altera
		TMSAE71B()
	EndIf
Else
	Help("",1,"TMSAF6807",,,03,00)	//-- "O comprovante de entrega só pode ser utilizado em viagens de entrega."
EndIf

Return

/*{Protheus.doc} ExecRentab
Executa as funções da rentabilidade da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param / nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecRentab(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Simular Rentabilidade
	TMSAF68Rnt(1)
Else					//-- Excluir Rentabilidade
	TMSAF68Rnt(2)
EndIf

Return

/*{Protheus.doc} ExecRoteir
Executa as funções da integração com roteirizador
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecRoteir(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Integra Roteirizador
	TF68RotInt(1)
ElseIf nAcao == 2		//-- Consulta Roteirizador
	TF68RotInt(2)
Else					//-- Legenda Roteirizador
	TMSA046Leg()
EndIf

Return

/*{Protheus.doc} ExecManute
Executa as funções das manutenções da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecManute(nAcao)
Local lCont      := .T.
Local aAreas     := {}
Local aIndexSub  := {}
Local aCores     := {}
Local aCampos    := {}
Local cFiltraSub := ""
Local nOpcDJM    := 0
Local oModelDJM
Local bFiltraSub

Private aRotina := {}

Default nAcao := 0

If nAcao == 1			//-- Confirmação
	SetFunName("TMSA142")

	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		lCont := TmsAcesso(,"TMSA142E",,3)
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		lCont := TmsAcesso(,"TMSA142C",,3)
	EndIf

	If lCont
		TmsA142(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.T.)
	EndIf
ElseIf nAcao == 2		//-- Geração AWB
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))
		aAreas := {DTV->(GetArea()),GetArea()}
	
		SetFunName("TMSA320")
	
		Aadd(aRotina,{STR0044,"AxPesqui",0,1})	//-- "Pesquisar"
	
		If TmsAcesso(,"TMSA320",,2,.F.)
			Aadd(aRotina,{STR0014,"TMSA144AWB",0,2})	//-- "Visualizar"
		EndIf
		If TmsAcesso(,"TMSA320",,3,.F.)
			Aadd(aRotina,{STR0052,"TMSA144AWB",0,3})	//-- "Incluir"
		EndIf
		If TmsAcesso(,"TMSA320",,4,.F.)
			Aadd(aRotina,{STR0002,"TMSA144AWB",0,5})	//-- "Estornar"
		EndIf
		If TmsAcesso(,"TMSA320",,5,.F.)
			Aadd(aRotina,{STR0033,"TMSAF68IAW",0,4})	//-- "Imprimir"
		EndIf
	
		If Len(aRotina) == 1
			Help("",1,"SEMPERM",,,03,00)
		Else
			aIndexSub  := {}
			cFiltraSub := "DTV_FILIAL == '" + xFilial("DTV") + "' .And. DTV_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTV_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
		
			bFiltraSub := {|| FilBrowse("DTV",@aIndexSub,@cFiltraSub)}
			Eval(bFiltraSub)
		
			MaWndBrowse(0,0,300,660,STR0020,"DTV",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Geracao AWB"
		
			EndFilBrw("DTV",aIndexSub)
		EndIf
		
		AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
		FwFreeArray(aRotina)
		FwFreeArray(aIndexSub)
		FwFreeArray(aCores)
		FwFreeArray(aCampos)
	Else
		Help("",1,"TMSAF6808",,,03,00)	//-- "A geração de AWB só pode ser utilizada em viagens de transferência."
	EndIf
ElseIf nAcao == 3		//-- Operações
	aAreas := {DTW->(GetArea()),GetArea()}

	SetFunName("TMSA350")

	DTW->(DbSetOrder(1))
	
	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "Pesquisar"
	
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		If TmsAcesso(,"TMSA350B",,2,.F.)
			Aadd(aRotina,{STR0014,"TmsA350Mnt",0,2})	//-- "Visualizar"
		EndIf
		If TmsAcesso(,"TMSA350B",,3,.F.)
			Aadd(aRotina,{STR0045,"TmsA350Mnt",0,3})	//-- "Apontar"
		EndIf
		If TmsAcesso(,"TMSA350B",,5,.F.)
			Aadd(aRotina,{STR0002,"TmsA350Est",0,5})	//-- "Estornar" 
		EndIf
	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If TmsAcesso(,"TMSA350D",,2,.F.)
			Aadd(aRotina,{STR0014,"TmsA350Mnt",0,2})	//-- "Visualizar"
		EndIf
		If TmsAcesso(,"TMSA350D",,3,.F.)
			Aadd(aRotina,{STR0045,"TmsA350Mnt",0,3})	//-- "Apontar"
		EndIf
		If TmsAcesso(,"TMSA350D",,5,.F.)
			Aadd(aRotina,{STR0002,"TmsA350Est",0,5})	//-- "Estornar" 
		EndIf
		If ExistFunc('TMSA351Vis') .And. !Empty(cAtvChgCli)
			Aadd(aRotina,{STR0046,"TMSA351Vis",0,7})	//-- "Documentos"
		EndIf
	EndIf 

	Aadd(aRotina,{STR0047,"TmsA350Leg",0,6})	//-- "Legenda"

	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DTW_FILIAL == '" + xFilial("DTW") + "' .And. DTW_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTW_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
	
		bFiltraSub := {|| FilBrowse("DTW",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		Aadd(aCores,{"DTW->DTW_STATUS == '1'","BR_VERDE"   })	//-- Em Aberto
		Aadd(aCores,{"DTW->DTW_STATUS == '2'","BR_VERMELHO"})	//-- Encerrado
		Aadd(aCores,{"DTW->DTW_STATUS == '9'","BR_PRETO"   })	//-- Cancelado
	
		MaWndBrowse(0,0,300,600,STR0021,"DTW",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Operações"
	
		EndFilBrw("DTW",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 4		//-- Reg.Ocorrência
	aAreas := {DTW->(GetArea()),GetArea()}

	SetFunName("TMSA360")

	TMA360Ini()	//-- Inicializa F12

	DUA->(DbSetOrder(1))
			
	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "Pesquisar"
			
	If TmsAcesso(,"TMSA360",,2,.F.)
		Aadd(aRotina,{STR0014,"TMSAF68OCO",0,2})	//-- "Visualizar"
	EndIf
	
	If TmsAcesso(,"TMSA360",,3,.F.)
		Aadd(aRotina,{STR0045,"TMSAF68OCO",0,3})	//-- "Apontar"	
	EndIf
	
	If TmsAcesso(,"TMSA360",,4,.F.)
		Aadd(aRotina,{STR0002,"TMSAF68OCO",0,6})	//-- "Estornar"
	EndIf
	
	If TmsAcesso(,"TMSA360",,7,.F.)
		Aadd(aRotina,{STR0048,"TMSAF68OCO",0,6})	//-- "Ajustar"
	EndIf
		
	If Len(aRotina) == 1
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DUA_FILIAL == '" + xFilial("DUA") + "'.And.DUA_FILORI == '" + DTQ->DTQ_FILORI + "'.And.DUA_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
	
		bFiltraSub := {|| FilBrowse("DUA",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		MaWndBrowse(0,0,300,600,STR0023,"DUA",aCampos,aRotina,,,,.T.,,,,,,,,.F.)	//-- "Reg.Ocorrência"
	
		EndFilBrw("DUA",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 5		//-- Movto.Caixinha
	aAreas := {SEU->(GetArea()),GetArea()}

	SetFunName("FINA560")

	Aadd(aRotina,{STR0044,"AxPesqui",0,1})	//-- "Pesquisar" 

	If TmsAcesso(,"FINA560",,2,.F.)
		Aadd(aRotina,{STR0014,"AxVisual",0,2})	//-- "Visualizar"
	EndIf
	If TmsAcesso(,"FINA560",,3,.F.)
		Aadd(aRotina,{STR0052,"TMSA144Mcx",0,3})	//-- "Incluir"
	EndIf
	If TmsAcesso(,"FINA560",,4,.F.)
		Aadd(aRotina,{STR0053,"TMSA144Mcx",0,5})	//-- "Cancelar"
	EndIf
	If TmsAcesso(,"FINA560",,5,.F.)
		Aadd(aRotina,{STR0054,"TMSA144Mcx",0,4})	//-- "Prest. de Contas"
	EndIf

	Aadd(aRotina,{STR0047,"FA560Legend",0,2})	//-- "Legenda"

	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aCores := {}
		Aadd(aCores,{"SEU->EU_TIPO = '00' .And. Empty(SEU->EU_BAIXA) .And. Empty(SEU->EU_NROADIA)","ENABLE"})	//-- Despesas nao baixadas
		Aadd(aCores,{"SEU->EU_TIPO = '00' .And. Empty(SEU->EU_BAIXA)"                             ,"BR_AZUL"})	//-- Despesas de adiantamento nao baixadas
		Aadd(aCores,{"SEU->EU_TIPO = '01' .And. SEU->EU_SLDADIA > 0"                              ,"BR_AMARELO"})	//-- Adiantamento com saldo (em aberto)
		Aadd(aCores,{"!Empty(SEU->EU_BAIXA)"                                                      ,"DISABLE"})	//-- Despesas baixadas e outros movimentos
	
		aIndexSub  := {}
		cFiltraSub := "EU_FILIAL == '" + xFilial("SEU") + "' .And. EU_FILORI == '" + DTQ->DTQ_FILORI + "' .And. EU_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"

		bFiltraSub := {|| FilBrowse("SEU",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		MaWndBrowse(0,0,300,660,STR0026,"SEU",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Movto.Caixinha"
	
		EndFilBrw("SEU",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 6		//-- Estorno Express
	Tf68EstExp(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA)
ElseIf nAcao == 7		//-- Retorno de Unitizadores
	If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
		If TmsAcesso(,"TmsA141RU",,2,.F.)
			TmsA141RU()
		Else
			Help("",1,"SEMPERM",,,03,00)
		EndIf
	Else
		Help("",1,"TMSAF6809",,,03,00)	//-- "O retorno de unitizadores só pode ser utilizado em viagens de entrega."
	EndIf
ElseIf nAcao == 8		//-- Fornecedores Adicionais
	aAreas := {DJM->(GetArea()),GetArea()}

	DJM->(DbSetOrder(1))
	If DbSeek(xFilial("DJM") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))
		If TmsAcesso(,"TMSA151",,4,.F.)
			nOpcDJM := MODEL_OPERATION_UPDATE
		EndIf
	Else
		If TmsAcesso(,"TMSA151",,3,.F.)
			nOpcDJM := MODEL_OPERATION_INSERT
		EndIf
	EndIf

	If nOpcDJM != 0	
		oModelDJM := FWLoadModel("TMSA151")
		oModelDJM:SetOperation(nOpcDJM)
		oModelDJM:Activate()
		
		If nOpcDJM == MODEL_OPERATION_INSERT
			oModelDJM:GetModel("TMSA151_CAB"):SetValue("DJM_FILORI",DTQ->DTQ_FILORI)
			oModelDJm:GetModel("TMSA151_CAB"):SetValue("DJM_VIAGEM",DTQ->DTQ_VIAGEM)
		EndIf
	
		FWExecView("TMSA151",nOpcDJM,,{|| .T.},,,,,,,oModelDJM)
		oModelDJM:DeActivate()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Else					//-- Troca de Cartão
	TMSA161()
EndIf

Return

/*{Protheus.doc} ExecImpMan
Executa as funções das impressões dos manifestos da viagem (express)
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecImpMan(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Manifesto
	TMSAF68IMn("NORMAL")
Else					//-- DAMDFE
	TMSAF68IMn("DAMDFE")
EndIf

Return

/*{Protheus.doc} ExecImpres
Executa as funções das impressões da viagem (express)
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecImpres(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Contrato
	TMSAF68ICt()
Else					//-- Cheque
	TMSAF68ICh()
EndIf

Return

/*{Protheus.doc} Tmsaf68Per
Função para chamar a visualização/edição do percurso com a viagem posicionada
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param lEdita Indica se edit percurso
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68Per(lEdit)

Default lEdit := .F.

If lEdit .And. !DTQ->DTQ_STATUS $ "1:2:5"	//-- 1-Em Aberto; 2-Em Transito; 5-Fechada
	Help("",1,"TMSAF6801")	//-- Não é possível editar o Percurso com status da viagem diferente de Em Aberto, Em Transito ou Fechada.
Else
	F16ExbPerc(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,lEdit)
EndIf

Return

/*{Protheus.doc} Tmsaf68TrM
Chamada da função para inclusão de condutor
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68TrM()
Local aAreas := {GetArea()}

If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))	//-- Viagem em trânsito
	//-- Indica para o modelo da viagem que é inclusão de condutor
	TMFSetStat("lIncMot",.T.)
	//-- Executa a alteração da viagem
	FWExecView(,"TMSAF60",MODEL_OPERATION_UPDATE)
	//-- Indica para o modelo da viagem que não é inclusão de condutor
	TMFSetStat("lIncMot",.F.)
Else
  Help("",1,"TMSXFUNA25")
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)
   
Return 

/*{Protheus.doc} Tmsaf68Oco
Chamada para o registro de ocorrências
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68Oco(cAlias,nTMSReg,nOpcx)

Default cAlias  := ""
Default nTMSReg := 0
Default nOpcx   := 0

If nOpcx == 3
	Tmsa360Mnt(cAlias,0,nOpcx,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
Else
	Tmsa360Mnt(cAlias,DUA->(Recno()),nOpcx)
EndIf

Return

/*{Protheus.doc} Tf68EstExp
Estorno da Viagem Express, Total ou Parcial
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function Tf68EstExp(cSerTms,cTipTra)
Local aAreas     := {DTC->(GetArea()),DT6->(GetArea()),DUD->(GetArea()),DTA->(GetArea()),DTX->(GetArea()),DTQ->(GetArea()),DTY->(GetArea()),;
                     DTP->(GetArea()),GetArea()}
Local aDocExcMot := {}
Local aDelDUD    := {}
Local aCabDTP    := {}
Local aCabDTC    := {}
Local aItemDTC   := {}
Local aItem      := {}
Local lCont      := .T.
Local lCTeUnico  := .F.
Local lEstTot    := .T.
Local lDocto     := .F.
Local cAliasDUD  := ""
Local cAliasDTC  := ""
Local nCntFor1   := 0
Local oModelVia
Local oModelCar
						
Private aRotina     := {}
Private aDelDocto   := {}
Private cMark       := GetMark()
Private lMsErroAuto := .F.

Default cSerTMS := ""
Default cTipTra := ""

DTP->(DbSetOrder(3))
If !DTP->(DbSeek(xFilial("DTP") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	lCont := .F.
	Help("",1,"TMSAF6803",,,03,00)	//-- "Viagem não é Express."
Else
	If cSerTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
		lCont := TmsAcesso(,"TMSA310B",,4,.F.)	//-- Fechamento
		If lCont
			lCont := TmsAcesso(,"TMSAF90",,4,.F.)	//-- Carregamento
		EndIf
	ElseIf cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
		If DTP->DTP_TIPLOT == "4"    
			lCTeUnico := .T.		
		EndIf
		lCont := TmsAcesso(,"TMSA310D",,4,.F.)	//-- Fechamento
		If lCont
			lCont := TmsAcesso(,"TMSAF90",,4,.F.)	//-- Carregamento
		EndIf
	EndIf

	If lCont
		lCont := TmsAcesso(,"TMSA250",,5,.F.)	//-- Contrato Carreteiro
	EndIf
	If lCont
		lCont := TmsAcesso(,"TMSA190",,4,.F.)	//-- Manifesto
	EndIf

	If !lCont
		Help("",1,"SEMPERM",,,03,00)
	Else
		If Pergunte("TMC144",.T.)

			lEstTot := (MV_PAR01 == 1)	//-- Estorno total
	
			If lEstTot
				lCont := TmsAcesso(,"TMSA200",,3,.F.)	.And. TmsAcesso(,"TMSA050",,4,.F.) .And. TmsAcesso(,"TMSA170",,5,.F.)	//-- Calculo do Frete / NF / Lote
	
				If lCont
					If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
						lCont := TmsAcesso(,"TMSA144B",,5,.F.)
					ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
						lCont := TmsAcesso(,"TMSA144D",,5,.F.)
					EndIf
				EndIf
	
				If !lCont
					Help("",1,"SEMPERM",,,03,00)
				EndIf
			EndIf
		Else
			lCont := .F.
		EndIf

		If lCont
			Begin Transaction

				//-- Fechamento de Viagem
				SetFunName("TMSA310")
				aRotina := {{"","",0,1},;
							{"","",0,2},;
							{"","",0,3},;
							{"","",0,5}}
				lCont := TMSA310Mnt("DTQ",DTQ->(Recno()),4,,.F.)

				//-- Contrato de Carreteiro
				If lCont
					DTY->(DbSetOrder(2))
					If DTY->(DbSeek(xFilial("DTY") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
						lCont := TMSA250Mnt("DTY",DTY->(Recno()),5,,.F.)
					EndIf
				EndIf

				//--  Manifesto de Carga
				If lCont
					DTX->(DbSetOrder(3))
					If DTX->(DbSeek(xFilial("DTX") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
						SetFunName("TMSA190")
						aRotina := {{"","",0,1},;
									{"","",0,2},;
									{"","",0,3},;
									{"","",0,5}}
						lCont := TmsA190Mnt("DTX",DTX->(Recno()),4,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
					EndIf
				EndIf

				//-- Carregamento
				If lCont
					//-- Carrega o Model do Carregamento
					oModelCar := FWLoadModel("TMSAF90")
					oModelCar:SetOperation(5)	//-- Exclusão
				
					//-- Ativa o Model da Viagem
					oModelCar:Activate()

					//-- Valida a Exclusão do Carregamento
					If (lCont := oModelCar:VldData())
						oModelCar:CommitData()
					EndIf

					//-- Se Ocorreu Algum Erro Exibe Mensagem
					If !lCont
						//-- Monta mensagem de erro
						TF67MntErr(oModelCar)
					
						MostraErro()
					EndIf
				
					//-- Desativa o Model do Carregamnto
					oModelCar:DeActivate()
				EndIf

				//-- Cálculo do Frete
				If lCont
					cAliasDUD := GetNextAlias()
					cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, R_E_C_N_O_ "
					cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
					cQuery += "  WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
					cQuery += "    AND DUD.DUD_FILORI = '" + DTQ->DTQ_FILORI + "'"
					cQuery += "    AND DUD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
					cQuery += "    AND DUD.DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
					cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery( cQuery )
					DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasDUD,.F.,.T.)
					//-- Limpa a Viagem do DUD
					While (cAliasDUD)->(!Eof())
						Aadd(aDelDUD,{(cAliasDUD)->DUD_FILDOC,(cAliasDUD)->DUD_DOC,(cAliasDUD)->DUD_SERIE})
						DUD->(DbGoTo((cAliasDUD)->R_E_C_N_O_))
						RecLock("DUD",.F.)
						DUD->DUD_VIAGEM := Space(TamSx3("DUD_VIAGEM")[1])
						DUD->(MsUnlock())
						(cAliasDUD)->(DbSkip())
					EndDo
					(cAliasDUD)->(DbCloseArea())

					If !Empty(cTipDocMot)
						If TM200TipDo(aDelDUD,cTipDocMot)
							If !(TMSA200C(aDelDUD,@aDocExcMot,cTipDocMot))	//-- Chama tela de motivo de cancelamento de documentos
								lCont := .F.
							Endif
						EndIf
					Endif
					
					For nCntFor1 := 1 To Len(aDelDUD)
						DT6->(DbSetOrder(1))
						If DT6->(DbSeek(xFilial("DT6") + aDelDUD[nCntFor1,1] + aDelDUD[nCntFor1,2] + aDelDUD[nCntFor1,3]))
							//-- Executa o cancelamento dos documentos de transporte
							TmsA200Cmp(,aDelDocto,.T.,.F.)
							//-- lDocto igual a .F. indica que todos os documentos do lote foram estornados, entao o status do lote passa para digitado.
							//-- lDocto igual a .T. indica que alguns documentos do lote nao foram estornados, entao o status do lote permanece como calculado.
							Processa({|lEnd| lCont := TMSA200Exc(aDelDocto,DT6->DT6_LOTNFC,@lEnd,@lDocto,,.T.,,aDocExcMot)},STR0027,STR0055,.F.)	//-- "Estorno Express" ### "Estornando conhecimento de frete..."
							If lCont .And. !lDocto
								//-- Atualiza o status do lote para (2-Digitado)
								Processa( {|lEnd| lCont := TMSA200Sta(@lEnd,DTP->DTP_LOTNFC,StrZero(2,Len(DTP->DTP_STATUS)))},STR0027,STR0056,.F.)	//-- "Atualizando Status do Lote..."
							EndIf
						EndIf
						If !lCont
							Exit
						EndIf
					Next nCntFor1
				EndIf

				//-- Quando o CTe for único o ExcAuto do TMS050 tem tratamento diferente
				If lCont .And. lEstTot .And. lCTeUnico
					//-- Nota Fiscal
					aCabDTC   := {}
					aItem     := {}
					aItemDTC  := {}

					cAliasDTC := GetNextAlias()
					cQuery := " SELECT * "
					cQuery += "   FROM " + RetSQLName("DTC") + " DTC "
					cQuery += "  WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "'"
					cQuery += "    AND DTC.DTC_FILORI = '" + DTP->DTP_FILORI + "'"
					cQuery += "    AND DTC.DTC_LOTNFC = '" + DTP->DTP_LOTNFC + "'"
					cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasDTC,.F.,.T.)
					While (cAliasDTC)->(!Eof())
						aCabDTC := {{"DTC_FILIAL",(cAliasDTC)->(DTC_FILIAL),Nil},;
									{"DTC_FILORI",(cAliasDTC)->(DTC_FILORI),Nil},;
									{"DTC_LOTNFC",(cAliasDTC)->(DTC_LOTNFC),Nil},;
									{"DTC_CLIREM",(cAliasDTC)->(DTC_CLIREM),Nil},;
									{"DTC_LOJREM",(cAliasDTC)->(DTC_LOJREM),Nil},;
									{"DTC_DATENT",(cAliasDTC)->(DTC_DATENT),Nil},;
									{"DTC_CLIDES",(cAliasDTC)->(DTC_CLIDES),Nil},;
									{"DTC_LOJDES",(cAliasDTC)->(DTC_LOJDES),Nil},;
									{"DTC_CLIDEV",(cAliasDTC)->(DTC_CLIDEV),Nil},;
									{"DTC_LOJDEV",(cAliasDTC)->(DTC_LOJDEV),Nil},;
									{"DTC_CLICAL",(cAliasDTC)->(DTC_CLICAL),Nil},;
									{"DTC_LOJCAL",(cAliasDTC)->(DTC_LOJCAL),Nil},;
									{"DTC_DEVFRE",(cAliasDTC)->(DTC_DEVFRE),Nil},;
									{"DTC_SERTMS",(cAliasDTC)->(DTC_SERTMS),Nil},;
									{"DTC_TIPTRA",(cAliasDTC)->(DTC_TIPTRA),Nil},;
									{"DTC_SERVIC",(cAliasDTC)->(DTC_SERVIC),Nil},;
									{"DTC_TIPNFC",(cAliasDTC)->(DTC_TIPNFC),Nil},;
									{"DTC_TIPFRE",(cAliasDTC)->(DTC_TIPFRE),Nil},;
									{"DTC_SELORI",(cAliasDTC)->(DTC_SELORI),Nil},;
									{"DTC_CDRORI",(cAliasDTC)->(DTC_CDRORI),Nil},;
									{"DTC_CDRDES",(cAliasDTC)->(DTC_CDRDES),Nil},;
									{"DTC_DISTIV",(cAliasDTC)->(DTC_DISTIV),Nil},;
									{"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
									{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
									{"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil}}

						aItem := {{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
								  {"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil},;
								  {"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
								  {"DTC_CODEMB",(cAliasDTC)->(DTC_CODEMB),Nil},;
								  {"DTC_EMINFC",(cAliasDTC)->(DTC_EMINFC),Nil},;
								  {"DTC_QTDVOL",(cAliasDTC)->(DTC_QTDVOL),Nil},;
								  {"DTC_PESO"  ,(cAliasDTC)->(DTC_PESO)  ,Nil},;
								  {"DTC_PESOM3",(cAliasDTC)->(DTC_PESOM3),Nil},;
								  {"DTC_VALOR" ,(cAliasDTC)->(DTC_VALOR) ,Nil},;
								  {"DTC_BASSEG",(cAliasDTC)->(DTC_BASSEG),Nil},;
								  {"DTC_QTDUNI",(cAliasDTC)->(DTC_QTDUNI),Nil},;
								  {"DTC_EDI"   ,(cAliasDTC)->(DTC_EDI)   ,Nil},;
								  {"DTC_ESTORN","1"                      ,Nil}}
						Aadd(aItemDTC,aClone(aItem))

						If !Empty(aCabDTC) .And. !Empty(aItemDTC)
							lMsErroAuto := .F.
							MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)
							If lMsErroAuto
								MostraErro()
								lCont := .F.
							EndIf
						EndIf
						
						(cAliasDTC)->(DbSkip())
					EndDo
					(cAliasDTC)->(DbCloseArea())
					
					//-- Lote de Notas Fiscais
					If lCont
						aCabDTP := {{"DTP_FILORI",DTP->DTP_FILORI,Nil},;
									{"DTP_LOTNFC",DTP->DTP_LOTNFC,Nil}}

						lMsErroAuto := .F.
						MSExecAuto({|u,v| TMSA170(u,v)},aCabDTP,5)
						If lMsErroAuto
							MostraErro()
							lCont := .F.
						EndIf
					EndIf

					//-- Viagem
					If lCont
						//-- Carrega o Model da Viagem
						oModelVia := FWLoadModel("TMSAF60")
						oModelVia:SetOperation(5)	//-- Exclusão
					
						//-- Ativa o Model da Viagem
						oModelVia:Activate()

						//-- Valida a Exclusão da Viagem
						If (lCont := oModelVia:VldData())
							oModelVia:CommitData()
						EndIf

						//-- Se Ocorreu Algum Erro Exibe Mensagem
						If !lCont
							//-- Monta mensagem de erro
							TF67MntErr(oModelVia)
						
							MostraErro()
						EndIf
					
						//-- Desativa o Model do Carregamnto
						oModelVia:DeActivate()
					EndIf

				ElseIf lCont .And. lEstTot .And. !lCTeUnico
					//-- Nota Fiscal
					aCabDTC   := {}
					aItem     := {}
					aItemDTC  := {}

					cAliasDTC := GetNextAlias()
					cQuery := " SELECT * "
					cQuery += "   FROM " + RetSQLName("DTC") + " DTC "
					cQuery += "   WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "'"
					cQuery += "    AND DTC.DTC_FILORI = '" + DTP->DTP_FILORI + "'"
					cQuery += "    AND DTC.DTC_LOTNFC = '" + DTP->DTP_LOTNFC + "'"
					cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC,.F.,.T.)
					
					If (cAliasDTC)->(!Eof())
						aCabDTC := {{"DTC_FILIAL",(cAliasDTC)->(DTC_FILIAL),Nil},;
									{"DTC_FILORI",(cAliasDTC)->(DTC_FILORI),Nil},;
									{"DTC_LOTNFC",(cAliasDTC)->(DTC_LOTNFC),Nil},;
									{"DTC_CLIREM",(cAliasDTC)->(DTC_CLIREM),Nil},;
									{"DTC_LOJREM",(cAliasDTC)->(DTC_LOJREM),Nil},;
									{"DTC_DATENT",(cAliasDTC)->(DTC_DATENT),Nil},;
									{"DTC_CLIDES",(cAliasDTC)->(DTC_CLIDES),Nil},;
									{"DTC_LOJDES",(cAliasDTC)->(DTC_LOJDES),Nil},;
									{"DTC_CLIDEV",(cAliasDTC)->(DTC_CLIDEV),Nil},;
									{"DTC_LOJDEV",(cAliasDTC)->(DTC_LOJDEV),Nil},;
									{"DTC_CLICAL",(cAliasDTC)->(DTC_CLICAL),Nil},;
									{"DTC_LOJCAL",(cAliasDTC)->(DTC_LOJCAL),Nil},;
									{"DTC_DEVFRE",(cAliasDTC)->(DTC_DEVFRE),Nil},;
									{"DTC_SERTMS",(cAliasDTC)->(DTC_SERTMS),Nil},;
									{"DTC_TIPTRA",(cAliasDTC)->(DTC_TIPTRA),Nil},;
									{"DTC_SERVIC",(cAliasDTC)->(DTC_SERVIC),Nil},;
									{"DTC_TIPNFC",(cAliasDTC)->(DTC_TIPNFC),Nil},;
									{"DTC_TIPFRE",(cAliasDTC)->(DTC_TIPFRE),Nil},;
									{"DTC_SELORI",(cAliasDTC)->(DTC_SELORI),Nil},;
									{"DTC_CDRORI",(cAliasDTC)->(DTC_CDRORI),Nil},;
									{"DTC_CDRDES",(cAliasDTC)->(DTC_CDRDES),Nil},;
									{"DTC_DISTIV",(cAliasDTC)->(DTC_DISTIV),Nil},;
									{"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
									{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
									{"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil}}
						While (cAliasDTC)->(!Eof())
							aItem := {{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
									  {"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil},;
									  {"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
									  {"DTC_CODEMB",(cAliasDTC)->(DTC_CODEMB),Nil},;
									  {"DTC_EMINFC",(cAliasDTC)->(DTC_EMINFC),Nil},;
									  {"DTC_QTDVOL",(cAliasDTC)->(DTC_QTDVOL),Nil},;
									  {"DTC_PESO"  ,(cAliasDTC)->(DTC_PESO)  ,Nil},;
									  {"DTC_PESOM3",(cAliasDTC)->(DTC_PESOM3),Nil},;
									  {"DTC_VALOR" ,(cAliasDTC)->(DTC_VALOR) ,Nil},;
									  {"DTC_BASSEG",(cAliasDTC)->(DTC_BASSEG),Nil},;
									  {"DTC_QTDUNI",(cAliasDTC)->(DTC_QTDUNI),Nil},;
									  {"DTC_EDI"   ,(cAliasDTC)->(DTC_EDI)   ,Nil},;
									  {"DTC_ESTORN","1"                      ,Nil}}
							AAdd(aItemDTC,aClone(aItem))

							(cAliasDTC)->(DbSkip())
						EndDo
					EndIf
					(cAliasDTC)->(DbCloseArea())
					
					If !Empty(aCabDTC) .And. !Empty(aItemDTC)
						lMsErroAuto := .F.
						MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)
						If lMsErroAuto
							MostraErro()
							lCont := .F.
						EndIf
					EndIf

					//-- Lote
					If lCont
						aCabDTP := {{"DTP_FILORI",DTP->DTP_FILORI,Nil},;
									{"DTP_LOTNFC",DTP->DTP_LOTNFC,Nil}}

						lMsErroAuto := .F.
						MSExecAuto({|u,v| TMSA170(u,v)},aCabDTP,5)
						If lMsErroAuto
							MostraErro()
							lCont := .F.
						EndIf
					EndIf

					//-- Viagem
					If lCont
						//-- Carrega o Model da Viagem
						oModelVia := FWLoadModel("TMSAF60")
						oModelVia:SetOperation(5)	//-- Exclusão
					
						//-- Ativa o Model da Viagem
						oModelVia:Activate()

						//-- Valida a Exclusão da Viagem
						If (lCont := oModelVia:VldData())
							oModelVia:CommitData()
						EndIf

						//-- Se Ocorreu Algum Erro Exibe Mensagem
						If !lCont
							//-- Monta mensagem de erro
							TF67MntErr(oModelVia)
						
							MostraErro()
						EndIf
					
						//-- Desativa o Model do Carregamnto
						oModelVia:DeActivate()
					EndIf
				EndIF

				If !lCont
					DisarmTransaction()
				EndIf

			End TransAction
		EndIf
	EndIf
EndIf

If lCont
	Help("",1,"TMSAF6804",Iif(lEstTot,STR0057,STR0058),,03,00)	//-- Estorno da viagem realizado com sucesso. ### Total ### Parcial
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)
FwFreeArray(aDocExcMot)
FwFreeArray(aDelDUD)
FwFreeArray(aCabDTP)
FwFreeArray(aCabDTC)
FwFreeArray(aItemDTC)
FwFreeArray(aItem)

Return( Nil )

/*{Protheus.doc} TMSAF68IMn
Imprime Manifesto
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68IMn(cTipMan)
Local aAreas := {DTX->(GetArea()),GetArea()}

Default cTipMan := ""

DTX->(DbSetOrder(3))
If DTX->(MsSeek(xFilial("DTX") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	TmsA190Imp("DTX",DTX->(Recno()),7,cTipMan)
Else
	Help("",1,"TMSAF6805")	//-- Manifesto não encontrado.
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF68ICt
Imprime Contrato de Carreteiro
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68ICt()
Local aAreas   := {DTY->(GetArea()),GetArea()}
Local lRTMSR06 := ExistBlock("RTMSR06")

DTY->(DbSetOrder(2))
If DTY->(!DbSeek(xFilial("DTY") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	Help("",1,"TMSAF6806")	//-- "Contrato não encontrado"
	Return( Nil )
ElseIf lRTMSR06
	// -- Se a rotina de impressão do contrato do carreteiro estiver sendo executada por outro usuário o sistema não imprime o contrato
	If LockByName("IMPCTC",.T.,.F.)
		Pergunte("RTMSR06",.F.)

		MV_PAR01 := DTQ->DTQ_FILORI
		MV_PAR02 := DTQ->DTQ_FILORI
		MV_PAR03 := DTQ->DTQ_VIAGEM
		MV_PAR04 := DTQ->DTQ_VIAGEM
	
		ExecBlock("RTMSR06",.F.,.F.)

		UnLockByName("IMPCTC",.T.,.F.)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF68ICh
Imprime cheques vinculados ao Contrato
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68ICh()
Local aAreas   := {GetArea()}
Local lRTMSR13 := ExistBlock("RTMSR13")

If lRTMSR13
	ExecBlock("RTMSR13",.F.,.F.)
Endif

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TF68RotInt
Executa a integraçao rota inteligente
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF68RotInt(nAcao)

Default nAcao := 1

RotaIntPrc(nAcao)
	
Return

/*{Protheus.doc} TMSAF68Rnt
Calcula a rentabilidade da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68Rnt(nMenu)
Local nOpc := 0	

Default nMenu := 1 

nOpc := Iif(nMenu == 1,3,5)

TMSRentab(nOpc,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	
Return

/*{Protheus.doc} TMSAF68IAW
Imprime cheques vinculados ao Contrato
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68IAW()
Local aAreas   := {GetArea()}
Local lRTMSR08 := ExistBlock("RTMSR08")

If lRTMSR08
	ExecBlock("RTMSR08",.F.,.F.)
Endif

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return
