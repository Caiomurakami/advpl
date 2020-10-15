#Include 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


Static Function ModelDef()
Local oModel	 := Nil		// Objeto do Model
Local oStruSDG	 := Nil		// Recebe a Estrutura da tabela SDG - Field
Local oStrGSDG	 := Nil		// Recebe a Estrutura da tabela SDG - Grid
Local cYesFields := ""      // Recebe os campos que devem aparecer no cabecalho
Local oCab        := FWFormModelStruct():New()
Local oStruFJ0:= FWFormStruct(1,'FJ0')

//Criado falso field, para alimentar a FJ0 de uma unica vez pelo Detail
oCab:AddTable('SDG',,'SDG')
oCab:AddField("Id","","DG_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

oModel := MpFormModel():New( "TMSA071" ,  /*bPreValid*/ ,,,/*bCancel*/ )

oStruSDG := FWFormStruct( 1, "SDG" )

oModel:AddFields( 'MdFieldSDG',, oCab,,,/*Carga*/ )

oModel:SetPrimaryKey({})

oModel:AddGrid( 'MdGridSDG', 'MdFieldSDG', oStruSDG,,, /*bPreVal*/, /*bPosVal*/,/*BLoad*/  )


Return oModel