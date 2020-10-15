#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_TMS.CH"

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TMS
@autor		: Eduardo Alberti
@descricao	: Atualização De Dicionários Para UpdDistr
@since		: Sep./2015
@using		: UpdDistr Para TMS
@review	:
@param		: 	cVersion 	: Versão do Protheus, Ex. ‘12’
				cMode 		: Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
				cRelStart	: Release de partida. Ex: ‘002’ ( Este seria o Release no qual o cliente está)
				cRelFinish	: Release de chegada. Ex: ‘005’ ( Este seria o Release ao final da atualização)
				cLocaliz	: Localização (país). Ex: ‘BRA’
/*/
//---------------------------------------------------------------------------------------------------
Function RUP_TMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Local aArea 			:= GetArea()
Local aArSXB			:= SXB->( GetArea() )
Local aArSX1			:= {}
Local aArSX3			:= SX3->( GetArea() )
Local aArSX7			:= SX7->( GetArea() )
Local aArSX6			:= SX6->( GetArea() )
Local aDicSXB			:= {}
Local aDicSX3       	:= {}
Local aDicSX7       	:= {}
Local aDicSX6			:= {}	
Local aDicSX9			:= {} 
Local nL				:= 0
Local nAtu				:= 0
Local lAtu				:= .F.	
Local cAliasQry  		:= nil
Local cQryDocTms 		:= ' '
Local cAliasDA3			:= GetNextAlias()
Local cQryAtvDmd		:= ' '
Local aPerg				:= {}
Local xTamPadR			:= ''

Default cVersion		:= ''
Default cMode			:= '1'
Default cRelStart		:= ''
Default cRelFinish		:= ''
Default cLocaliz		:= ''
	
	//-- Executa Uma Vez Por Empresa
#IFDEF TOP
	If cMode == "1"

		//-- Release Maior Ou Igual a '007'
		If cRelStart >= "007"
		
			//-- Colocado Os Comandos TmsLogMsg dentro Dos 'If's Acima Pois Repetia Muito No Console.Log
			TmsLogMsg(,STR0001 + 'RUP_TMS: ' + DtoC(dDataBase) + STR0002 + Time()) //-- ' Inicio RUP_TMS: '  ' Hora: '
			TmsLogMsg(,STR0003 + ' cMode = ' + cMode + Iif( cMode == '1', STR0004 , STR0005)) //-- 'Executando' 'Por Grupo De Empresas' 'Por Empresa + Filial'
			TmsLogMsg(,STR0006 + ' >= 007') //-- 'Release Inicial'

			//--------------------------------------------------------------------------------------------------------------//
			//--  Montagem Dos Vetores Dos Dicionarios Que Serão Ajustados Para Releases Maiores Que '007'                  //
			//--------------------------------------------------------------------------------------------------------------//
			
			//-- Ajustes Do Dicionário SX3
			aAdd(aDicSX3,{'DYL','DYL_DETPIC','X3_RELACAO','IF(INCLUI,"",TABELA("ET",DYL->DYL_CODPIC,.F.))'})
			//-- Ajustes Do Dicionário SX3 Para Divergencia De Produtos
			aAdd(aDicSX3,{'DDT','DDT_GREMBP','X3_VALID'  ,'Vazio() .Or. (ExistCpo("SX5","LX"+M->DDT_GREMBP) .And. DDTPosVl())'	})
			aAdd(aDicSX3,{'DDT','DDT_GREMBP','X3_F3'     ,'XLX'																			})
			aAdd(aDicSX3,{'DDT','DDT_DCEMBP','X3_RELACAO','IIF(!INCLUI,POSICIONE("SX5",1,XFILIAL("SX5")+"LX"+DDT->DDT_GREMBP,"X5_DESCRI")," ")'})
			aAdd(aDicSX3,{'DDT','DDT_DCEMBP','X3_INIBRW' ,'Posicione("SX5",1,xFilial("SX5")+"LX"+DDT->DDT_GREMBP,"X5_DESCRI")'	})
			aAdd(aDicSX3,{'DDT','DDT_GREMBI','X3_VALID'  ,'Vazio() .Or. ExistCpo("SX5","LX"+M->DDT_GREMBI)'						})
			aAdd(aDicSX3,{'DDT','DDT_GREMBI','X3_F3'     ,'XLX'																			})
			aAdd(aDicSX3,{'DDT','DDT_DCEMBI','X3_RELACAO','IIF(!INCLUI,POSICIONE("SX5",1,XFILIAL("SX5")+"LX"+DDT->DDT_GREMBI,"X5_DESCRI")," ")'})
			aAdd(aDicSX3,{'DDT','DDT_DCEMBI','X3_INIBRW' ,'Posicione("SX5",1,xFilial("SX5")+"LX"+DDT->DDT_GREMBI,"X5_DESCRI")'	})
			aAdd(aDicSX3,{'DY3','DY3_GRPEMB','X3_VALID'  ,'Vazio() .Or. ExistCpo("SX5","LX"+M->DY3_GRPEMB)'						})
			aAdd(aDicSX3,{'DY3','DY3_GRPEMB','X3_F3'     ,'XLX'																			})
			
			// Ajuste Issue DLOGTMS02-12571
			aAdd(aDicSX3,{'DLS','DLS_TPSPDG','X3_F3'     ,'MR'	})

			// TVRTHK - Retirado a obrigatoriedade (X3_OBRIGAT) e valor inicial (X3_RELACAO) dos campos abaixo.
			aAdd(aDicSX3,{'DEF','DEF_REGORI','X3_RELACAO','POSICIONE("DUY",1,XFILIAL("DUY")+M->DEF_CDRORI,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DEF','DEF_REGORI','X3_OBRIGAT'  , " " })
			aAdd(aDicSX3,{'DEF','DEF_DESTIP','X3_RELACAO','TMSVALFIELD("M->DEF_TIPTRA",.F.,"DEF_DESTIP")'})
			aAdd(aDicSX3,{'DEF','DEF_DESTIP','X3_OBRIGAT'  , " " })
			
			// Remoção da Obrigatoriedade do campo DF1_SRVCOL
			SX3->(DbSetOrder(2))
			If SX3->( MsSeek( "DF1_NCONTR" ) )
				aAdd(aDicSX3,{'DF1','DF1_SRVCOL','X3_USADO', SX3->X3_USADO })
				aAdd(aDicSX3,{'DF1','DF1_SRVCOL','X3_RESERV', SX3->X3_RESERV })						
				aAdd(aDicSX3,{'DF1','DF1_SRVCOL','X3_OBRIGAT', SX3->X3_OBRIGAT })
				aAdd(aDicSX3,{'DF1','DF1_SRVCOL','X3_BROWSE', SX3->X3_BROWSE })
			EndIF
			
			// Ajuste para Alterar e Real - Issue MLOG-137
			aAdd(aDicSX3,{'DTA','DTA_TIPAGD','X3_VISUAL' , 'A'})
			aAdd(aDicSX3,{'DTA','DTA_TIPAGD','X3_CONTEXT', 'R'})
			aAdd(aDicSX3,{'DTA','DTA_PRDAGD','X3_VISUAL' , 'A'})
			aAdd(aDicSX3,{'DTA','DTA_PRDAGD','X3_CONTEXT', 'R'})
			aAdd(aDicSX3,{'DTA','DTA_INIAGD','X3_VISUAL' , 'A'})
			aAdd(aDicSX3,{'DTA','DTA_INIAGD','X3_CONTEXT', 'R'})
			aAdd(aDicSX3,{'DTA','DTA_FIMAGD','X3_VISUAL' , 'A'})
			aAdd(aDicSX3,{'DTA','DTA_FIMAGD','X3_CONTEXT', 'R'})
			aAdd(aDicSX3,{'DTA','DTA_DATAGD','X3_VISUAL' , 'A'})
			aAdd(aDicSX3,{'DTA','DTA_DATAGD','X3_CONTEXT', 'R'})
			
			// Correção do inicializador - Issue MLOG-137
			aAdd(aDicSX3,{'DTA','DTA_DATAGD','X3_RELACAO','Iif(Inclui,CTOD("  /  /    "),TmsA210Agd("DYD_DATAGD"))'})
			
			// Correcao do inicializador - ISSUE: MLOG-2904
			aAdd(aDicSX3,{'DTQ','DTQ_DESROT','X3_RELACAO','IF(INCLUI,"",POSICIONE("DA8",1,XFILIAL("DA8")+DTQ->DTQ_ROTA,"DA8_DESC"))'})

			//-- Ajuste issue: DLOGTMS03-5154 - Consulta F3 Campo DTP_VIAGEM
			SXB->(dbSetOrder(1))
			If SXB->( MsSeek( "DTQTMS"))
				aAdd(aDicSX3,{'DTP','DTP_VIAGEM','X3_F3','DTQTMS'})
			EndIf

			// Retirada do campo DTP_SITCTE do Browse, e alteração da propriedade X3_RELACAO do campo DT6_SITCTE  - Issue MLOG-1209
			aAdd(aDicSX3,{'DTP','DTP_SITCTE','X3_BROWSE','N'})
			aAdd(aDicSX3,{'DT6','DT6_SITCTE','X3_RELACAO','"0"'})

			aAdd(aDicSX3,{'DV1','DV1_TIPNFC','X3_CBOX'  , " " })

			//Ajustes Ref. ao Doc. Exigidos x Fornecedor	
			aAdd(aDicSX3,{'DD1','DD1_CODFOR','X3_VALID'  ,'ExistCpo("SA2",M->DD1_CODFOR) .And. ExistChav("DD1",M->DD1_CODFOR+M->DD1_LOJFOR,,"EXISTFOR")'						})
			
			//Gatilho Campo DTC_DPCEMI
			aAdd(aDicSX3,{'DTC','DTC_DPCEMI','X3_VALID'  ,'TMSA050Vld()'})
			//When dos Campos DTC_CLIEXP DTC_LOJEXP
			aAdd(aDicSX3,{'DTC','DTC_CLIEXP','X3_WHEN'  ,'TMSA050Whe("DTC_CLIEXP")'})
			aAdd(aDicSX3,{'DTC','DTC_LOJEXP','X3_WHEN'  ,'TMSA050Whe("DTC_LOJEXP")'})
			
			// Retirada dos campos do Browse - Issue MLOG-27 
			aAdd(aDicSX3,{'DUL','DUL_DDD','X3_BROWSE','N'})
			aAdd(aDicSX3,{'DUL','DUL_TEL','X3_BROWSE','N'})

			// Retirada do campo DTP_SITCTE do Browse, e alteração da propriedade X3_RELACAO do campo DT6_SITCTE  - Issue MLOG-1209
			aAdd(aDicSX3,{'DTP','DTP_SITCTE','X3_BROWSE','N'})
			aAdd(aDicSX3,{'DT6','DT6_SITCTE','X3_RELACAO','"0"'})
			
			aAdd(aDicSX3,{'DF8','DF8_ROTA','X3_VISUAL' , 'A'})
			
			//Ajuste Issue MLOG-3236 - Erro na consulta genérica na tabela DTC
			aAdd(aDicSX3,{'DTC','DTC_REGDES','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRDES,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_REGCAL','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRCAL,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_REGPER','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRPER,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_RORRAT','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_ORIRAT,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_UORRAT','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_ORIRAT,"DUY_EST")'})
			aAdd(aDicSX3,{'DTC','DTC_RCARAT','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CALRAT,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_UCARAT','X3_RELACAO','Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CALRAT,"DUY_EST")'})
			aAdd(aDicSX3,{'DTC','DTC_REGDES','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRDES,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_REGCAL','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRCAL,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_REGPER','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRPER,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_RORRAT','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_ORIRAT,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_UORRAT','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_ORIRAT,"DUY_EST")'})
			aAdd(aDicSX3,{'DTC','DTC_RCARAT','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CALRAT,"DUY_DESCRI")'})
			aAdd(aDicSX3,{'DTC','DTC_UCARAT','X3_BROWSE' ,'Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CALRAT,"DUY_EST")'})
			
			//Ajuste Issue: MLOG-3427 - Erro na liberacao da viagem
			aAdd(aDicSX3,{'DUC','DUC_CODOBS','X3_RELACAO','IF(!INCLUI, MSMM(DUC->DUC_CODOBS,80), "")'})
			
			//DLOGTMS02-4105
			aAdd(aDicSX3,{'DTC','DTC_CTEANT','X3_VALID','TMSA050Vld()'})
			
			//DLOGTMS02-596 
			aAdd(aDicSX3,{'DT6','DT6_LOJDEV','X3_VISUAL' , 'A'})			
			aAdd(aDicSX3,{'DT6','DT6_CLIDEV','X3_VISUAL' , 'A'})			
			
			// Alterando USADO para que o campo DUL_BAIRRO que é obrigatório, possa ser acessado por outros modulos. 
			aAdd(aDicSX3,{'DUL','DUL_BAIRRO','X3_VISUAL' , 'A'})					
			aAdd(aDicSX3,{'DUL','DUL_BAIRRO','X3_CONTEXT', 'R'})
			
			//Ajuste Issue: DLOGTMS01-756 - Inicializador padrao da IE
			aAdd(aDicSX3,{'DTC','DTC_INSREM','X3_RELACAO','TMA050INI("DTC_INSREM")'})
			aAdd(aDicSX3,{'DTC','DTC_INSDES','X3_RELACAO','TMA050INI("DTC_INSDES")'})
			aAdd(aDicSX3,{'DTC','DTC_INSCON','X3_RELACAO','TMA050INI("DTC_INSCON")'})
			aAdd(aDicSX3,{'DTC','DTC_INSDPC','X3_RELACAO','TMA050INI("DTC_INSDPC")'})			

			//-- Ajuste ISSUE DLOGTMS02-12010 - Tornar obsleto carregamento gráfico
			aAdd(aDicSX3,{'DDL','DDL_UNITIZ','X3_VALID',''})
			aAdd(aDicSX3,{'DDL','DDL_CODANA','X3_VALID',''})
			aAdd(aDicSX3,{'DDL','DDL_FILDCA','X3_VALID',''})
			aAdd(aDicSX3,{'DDL','DDL_UNITIZ','X3_WHEN',''})
			aAdd(aDicSX3,{'DDL','DDL_CODANA','X3_WHEN',''})
			aAdd(aDicSX3,{'DDL','DDL_OCUPAC','X3_WHEN',''})
			aAdd(aDicSX3,{'DDL','DDL_FILDCA','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_FILORI','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_VIAGEM','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_CODVEI','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_VEICAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_UNITIZ','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_DATCAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_HORCAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_DTFCAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_HRFCAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_RESCAR','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_DATDSC','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_HORDSC','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_HRFDSC','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_DTFDSC','X3_VALID',''})
			aAdd(aDicSX3,{'DDK','DDK_FILORI','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_VIAGEM','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_CODVEI','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_VEICAR','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_UNITIZ','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_FILCAR','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_CARREG','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_VERSAO','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_DATCAR','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_HORCAR','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_DTFCAR','X3_WHEN',''})
			aAdd(aDicSX3,{'DDK','DDK_HRFCAR','X3_WHEN',''})			
			aAdd(aDicSX3,{'DDK','DDK_FILORI','X3_RELACAO',''})
			aAdd(aDicSX3,{'DDK','DDK_VIAGEM','X3_RELACAO',''})
			aAdd(aDicSX3,{'DDK','DDK_CODVEI','X3_RELACAO',''})
			aAdd(aDicSX3,{'DDK','DDK_CARREG','X3_RELACAO',''})
			aAdd(aDicSX3,{'DDK','DDK_VERSAO','X3_RELACAO',''})

			// Ajuste do Campo DTR_CIOT de Visual para Alterar 
			If cRelStart >= "017"
				aAdd(aDicSX3,{'DTR','DTR_CIOT','X3_VISUAL' , 'A'})
			EndIf	

			//-- Ajuste Issue: DLOGTMS02-11028 - Campo LoteEDI De Visual para Alterar
			aAdd(aDicSX3,{'DE5','DE5_LOTEDI','X3_VISUAL' , 'A'})

			//-- Ajuste Issue> DLOGTMS02-12009
			aAdd(aDicSX3,{'DIZ','DIZ_LOJCLI','X3_VALID' , ''})
			aAdd(aDicSX3,{'DIZ','DIZ_LOJFOR','X3_VALID' , ''})
			aAdd(aDicSX3,{'DIZ','DIZ_LOJCLI','X3_WHEN' , ''})
			aAdd(aDicSX3,{'DIZ','DIZ_LOJFOR','X3_WHEN' , ''})
			aAdd(aDicSX3,{'DIZ','DIZ_CODCLI','X3_WHEN' , ''})
			aAdd(aDicSX3,{'DIZ','DIZ_CODFOR','X3_WHEN' , ''})

			//-- Ajuste Issue> DLOGTMS02-12320
			aAdd( aDicSX3, { 'DYA', 'DYA_ITEM', 'X3_TAMANHO', 5 } )
			aAdd( aDicSX3, { 'DYF', 'DYF_ITEM', 'X3_TAMANHO', 5 } )
			aAdd( aDicSX3, { 'DYG', 'DYG_ITEM', 'X3_TAMANHO', 5 } )
			
			//--------------------------------------------------------------------------------------------------------------//			
			//-- Viagem Mod. 3
			//--------------------------------------------------------------------------------------------------------------//			
			aAdd( aDicSX3, { 'DTQ', 'DTQ_DATGER', 'X3_ORDEM', '05' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_HORGER', 'X3_ORDEM', '06' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_SERTMS', 'X3_ORDEM', '07' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_DESSVT', 'X3_ORDEM', '08' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_TIPTRA', 'X3_ORDEM', '09' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_DESTPT', 'X3_ORDEM', '10' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_ROTA'	, 'X3_ORDEM', '11' } )
			aAdd( aDicSX3, { 'DTQ', 'DTQ_DESROT', 'X3_ORDEM', '12' } )
			aAdd( aDicSX3, { 'DTA', 'DTA_VEICAR', 'X3_ORDEM', '10' } )
			aAdd( aDicSX3, { 'DTA', 'DTA_QTDVOL', 'X3_ORDEM', '11' } )

			//--------------------------------------------------------------------------------------------------------------//			
			//-- Ajustes Do Dicionário SX6
			//--------------------------------------------------------------------------------------------------------------//		
			Aadd(aDicSX6,{'MV_NATTXBA','X6_TIPO','C'})
			Aadd(aDicSX6,{'MV_NATTXBA','X6_VALID','TmsX6Valid(X6_FIL, X6_VAR, X6_TIPO, X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'} )                                                     

			//--------------------------------------------------------------------------------------------------------------//			
			//-- Ajustes Do Dicionário SX7
			//--------------------------------------------------------------------------------------------------------------//		
			aAdd(aDicSX7,{'DYL_CODPIC','001','X7_CHAVE','xFilial("SX5")+"ET"+M->DYL_CODPIC'})
			
			//-- Ajustes Do Dicionário SX7 Para Divergencia De Produtos
			aAdd(aDicSX7,{'DDT_GREMBI','001','X7_CHAVE','xFilial("SX5") + "LX" + M->DDT_GREMBI'})
			aAdd(aDicSX7,{'DDT_GREMBP','001','X7_CHAVE','xFilial("SX5") + "LX" + M->DDT_GREMBP'})
			
			//-- Exclusão de gatilhos da tabela DAU, relacionados ao campo DAU_CODFOR (somente o 1º gatilho será mantido).
			aAdd(aDicSX7,{'DAU_CODFOR','002','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','003','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','004','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','005','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','006','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','007','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','008','',''})
			aAdd(aDicSX7,{'DAU_CODFOR','009','',''})

			//-- Exclusão de gatilhos da tabela DAU, relacionados ao campo DAU_LOJFOR (somente o 1º gatilho será mantido).
			aAdd(aDicSX7,{'DAU_LOJFOR','002','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','003','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','004','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','005','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','006','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','007','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','008','',''})
			aAdd(aDicSX7,{'DAU_LOJFOR','009','',''})
			
			//-- Exclusão de gatilho antigo pois não é necessário na release 17
			aAdd(aDicSX7,{'DT2_TIPPND','001','',''})
			
			TmsLogMsg(," Atualização de Gatilhos DT5")
			//-- Exclusão de gatilho antigo na DT5, pois não é mais necessário
			aAdd(aDicSX7,{'DT5_DDD','001','',''})						
			aAdd(aDicSX7,{'DT5_DDD','002','',''})
			aAdd(aDicSX7,{'DT5_DDD','003','',''})
			aAdd(aDicSX7,{'DT5_DDD','004','',''})
			aAdd(aDicSX7,{'DT5_DDD','005','',''})
			aAdd(aDicSX7,{'DT5_DDD','006','',''})
			aAdd(aDicSX7,{'DT5_DDD','007','',''})
			aAdd(aDicSX7,{'DT5_DDD','008','',''})
			aAdd(aDicSX7,{'DT5_DDD','009','',''})
			aAdd(aDicSX7,{'DT5_DDD','010','',''})
			aAdd(aDicSX7,{'DT5_DDD','011','',''})
			aAdd(aDicSX7,{'DT5_TEL','001','',''})
			aAdd(aDicSX7,{'DT5_TEL','002','',''})
			aAdd(aDicSX7,{'DT5_TEL','003','',''})
			aAdd(aDicSX7,{'DT5_TEL','004','',''})
			aAdd(aDicSX7,{'DT5_TEL','005','',''})
			aAdd(aDicSX7,{'DT5_TEL','006','',''})
			aAdd(aDicSX7,{'DT5_TEL','007','',''})
			aAdd(aDicSX7,{'DT5_TEL','008','',''})
			aAdd(aDicSX7,{'DT5_TEL','009','',''})
			aAdd(aDicSX7,{'DT5_TEL','010','',''})
			aAdd(aDicSX7,{'DT5_TEL','011','',''})
			
			//--Exclusão do gatilho DIZ_STADCO
			aAdd(aDicSX7,{'DIZ_STADCO','001','',''})
			
			//-- Exclusão relacionamento SDG
			AAdd(aDicSX9,{ "SDG","001","DYX","DG_CODDES","DYX_NUMDES" } )

			//--Exclusão da Consulta Padrão MR
			aAdd(aDicSXB,{"MR ", "1", "Tipo Pagamento"})
			aAdd(aDicSXB,{"MR ", "2", "Tipo Pagamento"})
			aAdd(aDicSXB,{"MR ", "3", "Tipo Pagamento"})
			aAdd(aDicSXB,{"MR ", "4", "Tipo Pagamento"})
			aAdd(aDicSXB,{"MR ", "5", "Tipo Pagamento"})
			aAdd(aDicSXB,{"MR ", "6", "Tipo Pagamento"})

			//-------------------------------------------//
			//  Atualização Do Dicionário De Dados (SXB) //
			//-------------------------------------------//
			TmsLogMsg(,STR0018)
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSXB)
				
				DbSelectArea("SXB")
				SXB->( DbSetOrder(1) )
				If SXB->( MsSeek( PadR( aDicSXB[nL,1], Len(SXB->XB_ALIAS) ) + PadR( aDicSXB[nL,2], Len(SXB->XB_TIPO) ) ) )
					nAtu ++
					lAtu := .T.

					RecLock("SXB", .F.)
					SXB->( DbDelete() )
					SXB->( MsUnlock() )
				EndIf
				TmsLogMsg(,STR0016 + aDicSXB[nL,1] + ' - ' + aDicSXB[nL,2] + STR0017 + Iif(lAtu, STR0009 , STR0010 )) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
				lAtu := .f.
						
			Next nL
			
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) // 'Atualizado(s) ' ' Registros.'

			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Dados (SX3).                                                                 //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX3 - Campos")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX3)
			
				DbSelectArea("SX3")
				DbSetOrder(2)
				If MsSeek( PadR( aDicSX3[nL,2], Len(SX3->X3_CAMPO)) )

					If ValType(&(aDicSX3[nL,3])) == 'C'
						xTamPadR:= PadR(aDicSX3[nL,4], Len( &( aDicSX3[nL,3] ) ) )
					Else
						xTamPadR:= aDicSX3[nL,4]
					EndIf

					//-- Efetua Macro Substituição Do Dicionário
					If &(aDicSX3[nL,3]) <> xTamPadR
						
						nAtu ++
						lAtu := .t.
						
						RecLock("SX3",.F.)
						&("SX3->" + aDicSX3[nL,3]) := aDicSX3[nL,4]
						SX3->(MsUnlock())
						
					EndIf
				EndIf
				
				TmsLogMsg(,'   SX3 - ' + STR0007 + aDicSX3[nL,2] + STR0008 + aDicSX3[nL,3] + ' ' + Iif(lAtu, STR0009 , STR0010 )) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
				lAtu := .f.
						
			Next nL
			
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) // 'Atualizado(s) ' ' Registros.'
			
			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Parâmetros (SX6)                                                             //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX6 - Parâmetros")
			FsAtuSX6(aDicSX6 , cRelStart , cMode )
			
			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Gatilhos (SX7).                                                              //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX7 - Gatilhos")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX7)
			
				DbSelectArea("SX7")
				SX7->(DbSetOrder(1))
				
				If MsSeek(PadR(aDicSX7[nL,1],Len(SX7->X7_CAMPO)) + PadR(aDicSX7[nL,2],Len(SX7->X7_SEQUENC)) )
						
					//-- Exclusão dos gatilhos relacionados aos campos DAU_CODFOR e DAU_LOJFOR (somente o 1º gatilho será mantido).
					If aDicSX7[nL,1] = 'DAU_CODFOR' .Or. aDicSX7[nL,1] = 'DAU_LOJFOR'
						RecLock("SX7", .F.)
						dbDelete()
						MsUnlock()
					
					//-- Exclusão de gatilho antigo pois não é necessário na release 17
					ElseIf aDicSX7[nL,1] == 'DT2_TIPPND' .And. PadR(aDicSX7[nL,2],Len(SX7->X7_SEQUENC)) == '001' .And. SX7->X7_PROPRI == 'S'
						RecLock("SX7", .F.)
						dbDelete()
						MsUnlock()
					
					//-- Exclusão dos gatilhos relacionados aos campos DT5_DDD, DT5_TEL e DIZ_STADCO
					ElseIf aDicSX7[nL,1] == 'DT5_DDD' .OR. aDicSX7[nL,1] == 'DT5_TEL' .Or. aDicSX7[nL,1] == 'DIZ_STADCO'
						RecLock("SX7", .F.)
						dbDelete()
						MsUnlock()
					
					//-- Efetua Macro Substituição Do Dicionário
					ElseIf	&(aDicSX7[nL,3]) <> PadR(aDicSX7[nL,4],Len(&(aDicSX7[nL,3])))
					
						nAtu ++
						lAtu := .t.

						RecLock("SX7",.F.)
						&("SX7->" + aDicSX7[nL,3]) := aDicSX7[nL,4]
						SX7->(MsUnlock())
						
					EndIf
				EndIf
				
				TmsLogMsg(,'    SX7 - ' + STR0013 + aDicSX7[nL,1] + STR0014 + aDicSX7[nL,2] + STR0007 + aDicSX7[nL,3] + ' ' + Iif(lAtu, STR0009 , STR0010 )) //-- ' Gatilho: ' ' Sequencia: ' ' Campo: ' ' Atualizado ' " Atualizado Anteriormente " 
				lAtu := .f.
				
			Next nL
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) //-- ' Atualizado(s) ' ' Registros '
			
			//-------------------------------------------//
			//  Atualização Do Dicionário De Dados (SX9) //
			//-------------------------------------------//
			TmsLogMsg(,"Atualização campos SX9")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX9)
				dbSelectArea("SX9")
				SX9->( DBSetOrder(1))
				If SX9->( MsSeek( aDicSX9[nL][1] ) )
					While SX9->(!Eof()) .And. SX9->X9_DOM == aDicSX9[nL][1]

						If SX9->X9_DOM == aDicSX9[nL][1] ;
							.And. SX9->X9_CDOM == aDicSX9[nL][3];
							.And. RTrim(SX9->X9_EXPDOM) == RTrim(aDicSX9[nL][4]) ;
							.And. RTrim(SX9->X9_EXPCDOM ) == RTrim(aDicSX9[nL][5] )

							nAtu ++
							lAtu := .T.

							RecLock("SX9", .F.)
							SX9->( DbDelete() )
							SX9->( MsUnlock() )
							
							TmsLogMsg(, "SX9 - Dominio: " + aDicSX9[nL][1] + ' - Contra Dominio: ' + aDicSX9[nL][3] + STR0017 ) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
							lAtu := .F.

						EndIf
						SX9->(dbSkip())
					EndDo
				EndIf 
			Next nL 

			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) // 'Atualizado(s) ' ' Registros.'

			//-- Migrador de Contratos de Clientes TMS
			#IFDEF TOP
				TmsLogMsg(,"Inicio Migrador de Contratos...")
				If FindFunction("TmsMigCtrc")
					TmsMigCtrc(.F.)
				EndIf
				TmsLogMsg(,"Fim Migrador de Contratos...")
			#ENDIF	

			//-- Popula Tabela DLH - Historico do MDF-e sincronizando com a tabela DUD - Movimentos da Viagem
			#IFDEF TOP
				TmsLogMsg(,"Inicio do processamento da Tabela DLH - Histórico do MDF-e")
				If ExistFunc("TMSDUD2DLH")
					TMSDUD2DLH()
				Endif
				TmsLogMsg(,"Fim do processamento da tabela DLH")
			#ENDIF

			TmsLogMsg(,STR0015 + 'RUP_TMS: ' + DtoC(dDataBase) + STR0002 + Time()) //-- ' Fim ' ' Hora: '

		EndIf
		//Executa alteração de dicionário para Release superior ou igual a 12.1.16
		If cRelStart >= "016" 
		
			TmsLogMsg(,"Inicio Atualização DL5_DOCTMS...")
			SX3->(DbSetOrder(2))
			
			//Executa preenchimento do tipo de documento na tabela DL5
			If SX3->( MsSeek( "DL5_DOCTMS" ) )   

				cQuery := " SELECT Count(*) DL5_DOCTMS "
				cQuery += " FROM " + RetSqlName("DL5") 
				cQuery += " WHERE DL5_FILIAL = '" + xFilial("DL5") + "' "
				cQuery += " AND DL5_DOCTMS = ' ' "
				cQuery := ChangeQuery(cQuery)

				If TcSqlExec(cQuery) != 0
					TmsLogMsg(,"Erro ao verificar DL5_DOCTMS em branco, campo não atualizado.")
				Else 
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
	
					If (cAliasQry)->DL5_DOCTMS > 0
						cQryDocTms := " UPDATE " + RetSqlName("DL5") + " SET DL5_DOCTMS = DT6_DOCTMS "
						cQryDocTms += " FROM " + RetSqlName("DT6") + "," + RetSqlName("DL5")
						cQryDocTms += " WHERE DT6_FILDOC = DL5_FILDOC "
						cQryDocTms += " AND DT6_DOC = DL5_DOC "
						cQryDocTms += " AND DT6_SERIE  = DL5_SERIE "
						cQryDocTms += " AND DL5_DOCTMS = ' ' "
						cQryDocTms += " AND DL5_DOCTMS <> DT6_DOCTMS "

						If TcSqlExec(cQryDocTms) != 0
							TmsLogMsg(,"Erro ao atualizar campo DL5_DOCTMS, campo não atualizado.")
						EndIf
						TmsLogMsg(,"Fim Atualização DL5_DOCTMS...")
					Else 
						TmsLogMsg(,"Não possui o campo DL5_DOCTMS em branco. Campo já encontra-se atualizado!")
					EndIf
				EndIf
			EndIf
		Endif

		// DLOGTMS02-10293 - Retirada do parâmetro 02 do TMSA850 
		aArSX1 := SX1->(GetArea())
		SX1->(DbSetOrder(1)) //X1_GRUPO+X1_ORDEM
		cPerg := Padr("TMA850", Len(SX1->X1_GRUPO))

		If SX1->(MsSeek(cPerg+"02"))
						RecLock("SX1", .F.)
						dbDelete()
						MsUnlock()
						TmsLogMsg(,"Excluído item 02 do Pergunte TMA850.")
		EndIf
		RestArea(aArSX1)

		//DLOGTMS01-1936 - Criação campo DA3_GSTDMD
		If cRelStart >= "017" 
		
			TmsLogMsg(,"Inicio Atualização DA3_GSTDMD...")
			SX3->(DbSetOrder(2))
			
			//Executa preenchimento do campo Ativo em Gestão de Demandas na tabela DA3
			If SX3->( MsSeek( "DA3_GSTDMD" ) )   

				cQuery := " SELECT Count(*) DA3_GSTDMD "  
				cQuery += " FROM " + RetSqlName('DA3') + CRLF
				cQuery += " WHERE DA3_FILIAL = '" + xFilial("DA3") + "' " + CRLF
				cQuery += " AND DA3_GSTDMD = ' ' " + CRLF
				cQuery += " AND D_E_L_E_T_ = ' ' " + CRLF
				cQuery := ChangeQuery(cQuery)

				If TcSqlExec(cQuery) != 0
					TmsLogMsg(,"Erro ao verificar DA3_GSTDMD em branco, campo não atualizado.")
				Else 
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDA3, .T., .T.)
	
					If (cAliasDA3)->DA3_GSTDMD > 0
						cQryAtvDmd := " UPDATE " + RetSqlName("DA3") + CRLF
						cQryAtvDmd += " SET DA3_GSTDMD = '1' " + CRLF
						cQryAtvDmd += " WHERE DA3_FILIAL = '"  + xFilial("DA3") + "' " + CRLF
						cQryAtvDmd += " AND DA3_GSTDMD = ' ' " + CRLF
						cQryAtvDmd += " AND D_E_L_E_T_ = ' ' " + CRLF

						If TcSqlExec(cQryAtvDmd) != 0
							TmsLogMsg(,"Erro ao atualizar campo DA3_GSTDMD, campo não atualizado.")
						EndIf
						TmsLogMsg(,"Fim Atualização DA3_GSTDMD...")
					Else 
						TmsLogMsg(,"Não possui o campo DA3_GSTDMD em branco. Campo já enconta-se atualizado!")
					EndIf
				EndIf
			EndIf
		EndIf

		//-- Release Maior ou Igual que '023'
		If cRelFinish >= "023"

			TmsLogMsg(,"Inicio Atualização Pergunte TMB144...")

			aAdd(aPerg, "Exibir Monitor de CT-e ?")
			aAdd(aPerg, "Calcula Romaneio SIGAGFE ?")
			aAdd(aPerg, "Calcula Romaneio SIGAGFE ?")
			nL := 1
			lAtu := .T.

			aArSX1 := SX1->(GetArea())
			SX1->(DbSetOrder(1)) //X1_GRUPO+X1_ORDEM
			cPerg := Padr("TMB144", Len(SX1->X1_GRUPO))

			If SX1->(MsSeek(cPerg+"07"))
				While SX1->(!Eof()) .AND. SX1->X1_GRUPO == cPerg .AND. nL <= Len(aPerg)
					If AllTrim(SX1->X1_PERGUNT) != aPerg[nL]
						lAtu := .F.
						Exit
					EndIf

					If lAtu .AND. SX1->X1_ORDEM == "09" .AND. AllTrim(SX1->X1_PERGUNT) == "Calcula Romaneio SIGAGFE ?"
						RecLock("SX1", .F.)
						dbDelete()
						MsUnlock()
						TmsLogMsg(,"Excluido item 09 do Pergunte TMB144.")
					EndIf

					nL++
					SX1->(dbSkip())
				EndDo
			EndIf

			RestArea(aArSX1)
			TmsLogMsg(,"Fim Atualização Pergunte TMB144...")
		EndIf

		//-- Release Maior ou Igual a '025'
		If cRelFinish >= "025"
			aAdd(aDicSX3,{'DL8','DL8_DESGRD','X3_RELACAO','IIF(INCLUI,"",TMS153ABrw("DL8_DESGRD"))'})
		EndIf

		//-- Release Maior ou Igual a '027'
		If cRelFinish >= "025" //cRelFinish >= "027"
			TmsLogMsg(,"Inicio Atualização DL5_CLIDEV e DL5_LOJDEV...")
			SX3->(DbSetOrder(2))
			
			//Executa preenchimento do código e da loja do devedor na tabela DL5
			If SX3->( dbSeek( "DL5_CLIDEV" ) )   

				cQuery := " SELECT Count(1) DL5_CLIDEV "
				cQuery += " FROM " + RetSqlName("DL5") 
				cQuery += " WHERE DL5_FILIAL = '" + xFilial("DL5") + "' "
				cQuery += " AND DL5_CLIDEV = ' ' "
				cQuery := ChangeQuery(cQuery)

				If TcSqlExec(cQuery) != 0
					TmsLogMsg(,"Erro ao verificar DL5_CLIDEV em branco, campo não atualizado.")
				Else 
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
	
					If (cAliasQry)->DL5_CLIDEV > 0
						cQryDocTms := " UPDATE " + RetSqlName("DL5") + " SET DL5_CLIDEV = DT6_CLIDEV, "
						cQryDocTms += " DL5_LOJDEV = DT6_LOJDEV "
						cQryDocTms += " FROM " + RetSqlName("DT6") + "," + RetSqlName("DL5")
						cQryDocTms += " WHERE DT6_FILIAL = DL5_FILIAL " 
						cQryDocTms += " AND DT6_FILDOC = DL5_FILDOC "
						cQryDocTms += " AND DT6_DOC = DL5_DOC "
						cQryDocTms += " AND DT6_SERIE  = DL5_SERIE "
						cQryDocTms += " AND DL5_CLIDEV = ' ' "

						If TcSqlExec(cQryDocTms) != 0
							TmsLogMsg(,"Erro ao atualizar campo DL5_CLIDEV, campo não atualizado.")
						EndIf
						TmsLogMsg(,"Fim Atualização DL5_CLIDEV...")
					Else 
						TmsLogMsg(,"Não possui o campo DL5_CLIDEV em branco. Campo já encontra-se atualizado!")
					EndIf
				EndIf
			EndIf
		EndIF

	ElseIf cMode == "2"
		
		//--------------------------------------------------------------------------------------------------------------//			
		//-- Ajustes Do Dicionário SX6
		//--------------------------------------------------------------------------------------------------------------//		
		Aadd(aDicSX6,{'MV_NATTXBA','X6_TIPO','C'})
		Aadd(aDicSX6,{'MV_NATTXBA','X6_VALID','TmsX6Valid(X6_FIL, X6_VAR, X6_TIPO, X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'} )                                                     

		//--------------------------------------------------------------------------------------------------------------//
		//--  Atualização Do Dicionário De Parâmetros (SX6)                                                             //
		//--------------------------------------------------------------------------------------------------------------//
		TmsLogMsg(," Atualização de SX6 - Parâmetros")
		FsAtuSX6(aDicSX6 , cRelStart , cMode )
	
	EndIf
#ENDIF
	RestArea( aArSX7 )
	RestArea( aArSXB )
	RestArea( aArSX3 )
	RestArea( aArSX6 )
	RestArea( aArea )

Return NIL

//-------------------------------
//-- Atualiza SX6
//-------------------------------
Static Function FsAtuSX6(aDicSX6, cRelStart, cMode )
Local nCount	:= 1 
Local cUpd 		:= ""
Local lDicInDB 	:= MPDicInDB()
Local cCampo	:= ""
Local cTipo		:= ""
Local cNewVar	:= ""
Local lAlt		:= .F. 

Default aDicSX6		:= {}
Default cRelStart	:= ""
Default cMode		:= "" //-- Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)

//-- Executa alteração de dicionário para Release superior ou igual a 12.1.17
If cRelStart >= "017" 
	dbSelectArea("SX6")
	SX6->( dbSetOrder(1) )

	For nCount := 1 To Len(aDicSX6)
		lAlt	:= .F. 
		cCampo 	:= aDicSX6[nCount,1]
		cTipo	:= aDicsX6[nCount,2]
		cNewVar	:= aDicSX6[nCount,3] 
		
		If lDicInDB .And. cMode == "1"

			cUpd := " UPDATE " + MPSysSqlName("SX6")
			cUpd += " SET " + cTipo + " = '" + cNewVar + "' "	
			cUpd += " WHERE X6_VAR 		= '" + cCampo  +"' "
			cUpd += " 	AND " + cTipo 	+ " != " + "'" + cNewVar + "'" 
			cUpd += " 	AND D_E_L_E_T_ 	= '' "

			lAlt	:= .T.

			If TCSqlExec(cUpd) < 0 
				lAlt := .F. 
			EndIf

		Else

			//-- Tratamento filial em branco
			If SX6->(MsSeek(Replicate(" ", FwSizeFilial())+ cCampo) )
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

			//-- Tratamento Referente Empresa
			If SX6->(MsSeek(PadR(FwCompany(),FwSizeFilial())+cCampo))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf
			
			//-- Tratamento Referente Empresa + Filial
			If SX6->(MsSeek(PadR(FwCompany()+FwUnitBusiness(),FwSizeFilial())+cCampo))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

			//-- Código Completo da Filial Atual
			If SX6->(MsSeek(FwCodFil()+ cCampo ))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

		EndIf
		
		If lAlt
			TmsLogMsg(,'    SX6 - ' + cCampo + ' atualizado. - '  +  cNewVar ) 
		EndIf

	Next nCount
EndIf

Return
