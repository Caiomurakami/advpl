#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAC15A.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverByDoc()
Realiza o tratamento do Json retornado do GetDrvrByDoc e GetDrvrByName

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cGet    retorno do get a ser tratado
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
@Return     aRet    { 
                        { Locked,                       , Logico} ,
                        { LockedReason,                 , "" } ,
                        { driver_country                , "" } ,
                        { driver_national_id            , "" } ,
                        { driver_license_number         , "" } ,
                        
                        { driver_address_street         , "" } ,
                        { driver_address_number         , "" } ,
                        { driver_address_complement     , "" } ,
                        { driver_address_neighborhood   , "" } ,
                        { driver_address_zipcode        , "" } ,

                        { driver_birthdate              , "" } ,
                        { driver_gender                   , "" } ,
                        { driver_name                 , "" } ,
                        
                        {
                            driver_phone_areacode       , ""
                            driver_phone_number         , ""
                            driver_phone_preferential   , Logical
                            driver_phone_typeid         , ""
                        }
                    }
/*/
//--------------------------------------------------------------------

Function TMSGDriver( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGDArr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGDArr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf

            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf
    
    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGDArr( oResult )

    Local nCount    := 0
    Local aResult   := {}
    Local aTel      := {}
    Local aPhones   := {}

    AAdd( aResult, { "Locked",                  oResult:Locked                 } )
    AAdd( aResult, { "LockedReason",            oResult:LockedReason           } )
    AAdd( aResult, { "driver_country",          oResult:Country                } )
    AAdd( aResult, { "driver_national_id",      oResult:NationalId             } )
    AAdd( aResult, { "driver_license_number",   oResult:DriverLicenseNumber    } )

    If AttIsMemberOf( oResult, "ADDRESS" )
        AAdd( aResult, { "driver_address_street",          oResult:Address:Street        } )
        AAdd( aResult, { "driver_address_number",          oResult:Address:Number        } )
        AAdd( aResult, { "driver_address_complement",      oResult:Address:Complement    } )
        AAdd( aResult, { "driver_address_neighborhood",    oResult:Address:Neighborhood  } )
        AAdd( aResult, { "driver_address_zipcode",         oResult:Address:ZipCode       } )
    EndIf

    If AttIsMemberOf( oResult, "DriverPersonalInformation" )
        AAdd( aResult, { "driver_birthdate",  RetForDt(oResult:DriverPersonalInformation:BirthDate)   } )
        AAdd( aResult, { "driver_gender",     oResult:DriverPersonalInformation:Gender      } )
        AAdd( aResult, { "driver_name",       oResult:DriverPersonalInformation:Name        } )
    EndIf

    If AttIsMemberOf( oResult, "PHONES" )
        
        For nCount := 1 To Len( oResult:Phones )
        
            AAdd( aTel, { "driver_phone_areacode",       oResult:Phones[nCount]:AreaCode     } )
            AAdd( aTel, { "driver_phone_number",         oResult:Phones[nCount]:Number       } )
            AAdd( aTel, { "driver_phone_preferential",   oResult:Phones[nCount]:Preferential } )
            AAdd( aTel, { "driver_phone_typeid",         oResult:Phones[nCount]:TypeId       } )

            AAdd( aPhones, aTel )

            aTel := {}
        Next nCount

        AAdd( aResult, aPhones )

        aPhones := {}
    EndIf

    FWFreeArray(aPhones)
    FWFreeArray(aTel)

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGCard
Realiza o tratamento do Json retornado do GetCardHired, 
GetCardDriver e GetCardDvrHrd.

@param      cGet    string a ser tratada
@return     aRet    {
                        {
                            "CardNumber": 0,
                            "CardType": "string",
                            "HiredNationalID": "string",
                            "HiredName": "string",
                            "DriverNationalID": "string",
                            "DriverName": "string",
                            "Status": "Active"
                        }
                    }
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Function TMSGCard( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGCdAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGCdAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGCdAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Card_Number",             oResult:CardNumber          } )
    AAdd( aResult, { "Card_Type",               oResult:CardType            } )
    AAdd( aResult, { "Card_HiredNationalID",    oResult:HiredNationalID     } )
    AAdd( aResult, { "Card_HiredName",          oResult:HiredName           } )
    AAdd( aResult, { "Card_DriverNationalID",   oResult:DriverNationalID    } )
    AAdd( aResult, { "Card_DriverName",         oResult:DriverName          } )

    If oResult:Status == "Active"
        AAdd( aResult, { "Card_Status",         .T.                         } )
    Else
        AAdd( aResult, { "Card_Status",         .F.                         } )
    EndIf

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} RetErrRep()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetErrRep( nResult )

    Local aRet      := {}

    Default nResult := 0

    If nResult == 400
        AAdd( aRet, { 400, "400	Bad Request", STR0001           } ) // STR0001 "O Servidor não pode processar a requisição devido a algum erro do cliente."
    ElseIf nResult == 401
        AAdd( aRet, { 401, "401	Unauthorized", STR0002          } ) // STR0002 "A solicitação não foi aplicada porque não possui credenciais de autenticação válidas."
    ElseIf nResult == 404
        AAdd( aRet, { 404, "404	Not Found", STR0003             } ) // STR0003 "O Servidor não conseguiu encontrar o recurso solicitado."
    ElseIf nResult == 500
        AAdd( aRet, { 500, "500	Internal Server Error", STR0004 } ) // STR0004 "O Servidor encontrou uma condição inesperada que o impediu de atender à solicitação."
    EndIf

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetLoadTypes

@param      cGet    string a ser tratada
@return     aRet    { {"CodeType": 1, "Description": "Granel sólido"} }
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Function TMSGLdTp( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aResult   := {}
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "A"
                    
                    For nCount := 1 To Len( oResult:Result )
                        
                        AAdd( aResult, { "Load_CodeType",       oResult:Result[nCount]:CodeType    } )
                        AAdd( aResult, { "Load_Description",    DecodeUTF8(oResult:Result[nCount]:Description) } )
                        
                        AAdd( aRet, aResult )
                        
                        aResult := {}

                    Next nCount

                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetHiredByName, GetHiredByDoc

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    
{   { "Hired_Country",               oResult:Country                 },
    { "Hired_NationalId",            oResult:NationalId              },
    { "Hired_Type",                  oResult:HiredType               },
    { "Hired_Locked",                oResult:Locked                  },
    { "Hired_LockedReason",          oResult:LockedReason            },
    { "Hired_Email",                 oResult:Email                   },
    { "Hired_Status",                oResult:Status                  },
    { "Hired_FuelVoucherPercentage", oResult:FuelVoucherPercentage   },
    { "Hired_UsesFuelVoucher",       oResult:UsesFuelVoucher         },
    { "Hired_RNTRC",     oResult:BrazilianSettings:RNTRC    },
    { "Hired_INSS",  oResult:BrazilianSettings:HiredPessoaFisica:INSS    },
    { "Hired_RG",    oResult:BrazilianSettings:HiredPessoaFisica:RG      },
    { "Hired_InscricaoEstadual",         oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoEstadual         },
    { "Hired_InscricaoMunicipal",        oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoMunicipal        },
    { "Hired_NomeFantasia",              oResult:BrazilianSettings:HiredPessoaJuridica:NomeFantasia              },
    { "Hired_OptanteSimplesNacional",    oResult:BrazilianSettings:HiredPessoaJuridica:OptanteSimplesNacional    },
    { "Hired_address_street",          oResult:Address:Street        },
    { "Hired_address_number",          oResult:Address:Number        },
    { "Hired_address_complement",      oResult:Address:Complement    },
    { "Hired_address_neighborhood",    oResult:Address:Neighborhood  },
    { "Hired_address_zipcode",         oResult:Address:ZipCode       },
    { "Hired_CompanyName",             oResult:CompanyInformation:CompanyName  },
    { "Hired_birthdate",         oResult:DriverPersonalInformation:BirthDate         },
    { "Hired_gender",            oResult:DriverPersonalInformation:Gender            },
    { "Hired_LegalDependents",   oResult:DriverPersonalInformation:LegalDependents   },
    { "Hired_name",              oResult:DriverPersonalInformation:Name              },
    { "ANTTDataConsulta",        oResult:BrazilianTransportRegulatoryAgency:ANTTDataConsulta     },
    { "ANTTEquiparadoTAC",       oResult:BrazilianTransportRegulatoryAgency:ANTTEquiparadoTAC    },
    { "ANTTNomeRazaoSocial",     oResult:BrazilianTransportRegulatoryAgency:ANTTNomeRazaoSocial  },
    { "ANTTRNTRCAtivo",          oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCAtivo       },
    { "ANTTRNTRCDataValidade",   oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCDataValidade},
    { "ANTTTransportadorTipo",   oResult:BrazilianTransportRegulatoryAgency:ANTTTransportadorTipo},
    {   { "Hired_phone_areacode",       oResult:Phones[nCount]:AreaCode     },
        { "Hired_phone_number",         oResult:Phones[nCount]:Number       },
        { "Hired_phone_preferential",   oResult:Phones[nCount]:Preferential },
        { "Hired_phone_typeid",         oResult:Phones[nCount]:TypeId       } }
/*/
//--------------------------------------------------------------------
Function TMSGHBNm( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGHBNAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGHBNAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGHBNAr( oResult )

    Local nCount    := 0
    Local aResult   := {}
    Local aTel      := {}
    Local aPhones   := {}

    AAdd( aResult, { "Hired_Country",               oResult:Country                 } )
    AAdd( aResult, { "Hired_NationalId",            oResult:NationalId              } )
    AAdd( aResult, { "Hired_Type",                  oResult:HiredType               } )
    AAdd( aResult, { "Hired_Locked",                oResult:Locked                  } )
    AAdd( aResult, { "Hired_LockedReason",          oResult:LockedReason            } )
    AAdd( aResult, { "Hired_Email",                 oResult:Email                   } )
    AAdd( aResult, { "Hired_Status",                oResult:Status                  } )
    
    If AttIsMemberOf( oResult, "FuelVoucherPercentage" )
        AAdd( aResult, { "Hired_FuelVoucherPercentage", oResult:FuelVoucherPercentage   } )
    EndIf
    
    If AttIsMemberOf( oResult, "UsesFuelVoucher" )
        AAdd( aResult, { "Hired_UsesFuelVoucher",       oResult:UsesFuelVoucher         } )
    EndIf

    If AttIsMemberOf( oResult, "BrazilianSettings" )
        AAdd( aResult, { "Hired_RNTRC",     oResult:BrazilianSettings:RNTRC } )

        If ValType( oResult:BrazilianSettings:HiredPessoaFisica ) == "O"
            AAdd( aResult, { "Hired_INSS",  oResult:BrazilianSettings:HiredPessoaFisica:INSS    } )
            AAdd( aResult, { "Hired_RG",    oResult:BrazilianSettings:HiredPessoaFisica:RG      } )
        EndIf
        
        If ValType( oResult:BrazilianSettings:HiredPessoaJuridica ) == "O"
            AAdd( aResult, { "Hired_InscricaoEstadual",         oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoEstadual         } )
            AAdd( aResult, { "Hired_InscricaoMunicipal",        oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoMunicipal        } )
            AAdd( aResult, { "Hired_NomeFantasia",              oResult:BrazilianSettings:HiredPessoaJuridica:NomeFantasia              } )
            AAdd( aResult, { "Hired_OptanteSimplesNacional",    oResult:BrazilianSettings:HiredPessoaJuridica:OptanteSimplesNacional    } )//Logico
        EndIf
    EndIf

    If AttIsMemberOf( oResult, "ADDRESS" )
        AAdd( aResult, { "Hired_address_street",          oResult:Address:Street        } )
        AAdd( aResult, { "Hired_address_number",          oResult:Address:Number        } )
        AAdd( aResult, { "Hired_address_complement",      oResult:Address:Complement    } )
        AAdd( aResult, { "Hired_address_neighborhood",    oResult:Address:Neighborhood  } )
        AAdd( aResult, { "Hired_address_zipcode",         oResult:Address:ZipCode       } )
    EndIf

    If ValType( oResult:CompanyInformation ) == "O"
        AAdd( aResult, { "Hired_CompanyName",             oResult:CompanyInformation:CompanyName  } )
    EndIf

    If AttIsMemberOf( oResult, "HiredPersonalInformation" ) .And. oResult:HiredPersonalInformation <> Nil
        AAdd( aResult, { "Hired_birthdate",         RetForDt(oResult:HiredPersonalInformation:BirthDate)} )
        AAdd( aResult, { "Hired_gender",            oResult:HiredPersonalInformation:Gender             } )
        AAdd( aResult, { "Hired_LegalDependents",   oResult:HiredPersonalInformation:LegalDependents    } )
        AAdd( aResult, { "Hired_name",              oResult:HiredPersonalInformation:Name               } )
    EndIf

    If AttIsMemberOf( oResult, "BrazilianTransportRegulatoryAgency" )
        AAdd( aResult, { "ANTTDataConsulta",        RetForDt(oResult:BrazilianTransportRegulatoryAgency:ANTTDataConsulta)     } )
        AAdd( aResult, { "ANTTEquiparadoTAC",       oResult:BrazilianTransportRegulatoryAgency:ANTTEquiparadoTAC    } )
        AAdd( aResult, { "ANTTNomeRazaoSocial",     oResult:BrazilianTransportRegulatoryAgency:ANTTNomeRazaoSocial  } )
        AAdd( aResult, { "ANTTRNTRCAtivo",          oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCAtivo       } )
        AAdd( aResult, { "ANTTRNTRCDataValidade",   RetForDt(oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCDataValidade)} )
        AAdd( aResult, { "ANTTTransportadorTipo",   oResult:BrazilianTransportRegulatoryAgency:ANTTTransportadorTipo} )
    EndIf

    If AttIsMemberOf( oResult, "PHONES" )
        
        For nCount := 1 To Len( oResult:Phones )
        
            AAdd( aTel, { "Hired_phone_areacode",       oResult:Phones[nCount]:AreaCode     } )
            AAdd( aTel, { "Hired_phone_number",         oResult:Phones[nCount]:Number       } )
            AAdd( aTel, { "Hired_phone_preferential",   oResult:Phones[nCount]:Preferential } )
            AAdd( aTel, { "Hired_phone_typeid",         oResult:Phones[nCount]:TypeId       } )

            AAdd( aPhones, aTel )

            aTel := {}
        Next nCount

        AAdd( aResult, aPhones )

        aPhones := {}
    EndIf

    FWFreeArray(aPhones)
    FWFreeArray(aTel)

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} RetForDt( cData )
Faz tratamento na string enviada para ser transformada em Data

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetForDt( cData )

    Local dRetData  := SToD("19000101")
    
    Default cData   := "19000101"

    dRetData    := SToD( StrTran( SubStr( cData, 1, 10 ), "-", "" ) )

Return dRetData

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtByCEP GetRtByIBGE GetRtByTrcId

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
                    "TraceCode": 0,
                    "RouteCode": 0,
                    "Distance": 0,
                    "RoundTrip": true,
                    "Name": "string",
                    "TotalVPRValue": 0,
                    "TraceIdentifier": "string"
                    }
/*/
//--------------------------------------------------------------------

Function TMSGRota( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGRtAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGRtAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGRtAr
Realiza o tratamento do Json retornado do GetRtByCEP GetRtByIBGE GetRtByTrcId

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
{
  "TraceCode": 0,
  "RouteCode": 0,
  "Distance": 0,
  "RoundTrip": true,
  "Name": "string",
  "TotalVPRValue": 0,
  "TraceIdentifier": "string"
}
/*/
//--------------------------------------------------------------------

Static Function RetGRtAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Route_TraceCode",         oResult:TraceCode       } )
    AAdd( aResult, { "Route_RouteCode",         oResult:RouteCode       } )
    AAdd( aResult, { "Route_Distance",          oResult:Distance        } )
    AAdd( aResult, { "Route_RoundTrip",         oResult:RoundTrip       } )
    AAdd( aResult, { "Route_Name",              oResult:Name            } )
    AAdd( aResult, { "Route_TotalVPRValue",     oResult:TotalVPRValue   } )
    AAdd( aResult, { "Route_TraceIdentifier",   oResult:TraceIdentifier } )

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtRequest

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
                    "Id": 0,
                    "Status": "Pending",
                    "TraceCode": 0,
                    "RouteCode": 0,
                    "DisapprovalReason": "string",
                    "DisapprovalReasonCode": 0,
                    "TraceIdentifier": "string"
                    }
/*/
//--------------------------------------------------------------------

Function TMSGRoReq( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGRRAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGRRAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtRequest

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
{
  "Id": 0,
  "Status": "Pending",
  "TraceCode": 0,
  "RouteCode": 0,
  "DisapprovalReason": "string",
  "DisapprovalReasonCode": 0,
  "TraceIdentifier": "string"
}
/*/
//--------------------------------------------------------------------

Static Function RetGRRAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Route_Id",                    cValToChar(oResult:Id)          } )
    AAdd( aResult, { "Route_Status",                oResult:Status                  } )
    AAdd( aResult, { "Route_TraceCode",             cValToChar(oResult:TraceCode)   } )
    AAdd( aResult, { "Route_RouteCode",             cValToChar(oResult:RouteCode)   } )
    AAdd( aResult, { "Route_DisapprovalReason",     oResult:DisapprovalReason       } )
    AAdd( aResult, { "Route_DisapprovalReasonCode", cValToChar(oResult:DisapprovalReasonCode)   } )
    AAdd( aResult, { "Route_TraceIdentifier",       oResult:TraceIdentifier         } )

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSDriver( cCodMot )

    Local oRepom    := Nil
    Local aDriver   := {}
    Local nI        := 0
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodMot := ""

	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	aDriver := oRepom:GetDrvrByDoc( cCodMot )
    
    For nI := 1 To Len(aDriver)
        If Valtype( aDriver[nI][1] ) == "N"

            If aDriver[nI][1] == 404// Not Found
                lRepInc := .T. // Realiza a inclusão
            Else
                lErro	:= .T.
                Exit
            EndIf

        Else
            lRepInc := .F. // Realiza a alteração
        EndIf
    Next nI

	If !lErro
		If lRepInc
			lRepom := oRepom:DriverCreate( cCodMot )
		Else
			lRepom := oRepom:DriverUpdate( cCodMot )
		EndIf
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSDriLoc( cCodMot, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aDriver   := {}
    Local nI        := 0

    Default cCodMot := ""
    Default lLock   := .F.
    Default cObserv := ""
    
    If !Empty(cCodMot)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetDrvrByDoc( cCodMot )

        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepExc := .F. // Realiza a Exclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepExc := .T. // Realiza a Exclusão
            EndIf
        Next nI
        
        If !lErro .AND. lRepExc
            lRepom := oRepom:DriverLock( cCodMot, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSVCard
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSVCard( cCodMot, cStatus, cCard )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local aCard     := {}
    Local nI        := 0

    Default cCodMot := ""
    Default cStatus := ""
    Default cCard   := ""

    If !Empty( cCodMot )
        TmsRepTrac("TMSBCARepomFrete - Instanciado ")
        
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        TmsRepTrac("GetCardDriver - Instanciado ")
        
        aCard := oRepom:GetCardDriver( cCodMot )
        oRepom:Destroy()
        FwFreeObj(oRepom)

        If Len(aCard) > 0
            For nI := 1 To Len(aCard)
                If Valtype( aCard[nI][1] ) == "N"
                    Aviso( aCard[nI][2], aCard[nI][3], { "Ok" } )
                    lRepom := .F.
                    Exit
                Else
                    lRepom  := .T.
                    cStatus := If( aCard[nI][7][2], "Ativo", "Desativado" )
                    TmsRepTrac( "GetCardDriver - Consumido "+ AllToChar( aCard[nI][7][2] ) )
                    Exit
                EndIf
            Next nI
        Else
            lRepom := .F.
        EndIf
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSVehic( cCodVei )

    Local oRepom    := Nil
    Local aVeicul   := {}
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodVei := ""

	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	aVeicul := oRepom:GetVeicByDoc( cCodVei )
    
    If Len(aVeicul) > 0
        lRepInc := .F. // Realiza a Alteração
    EndIf

	If !lErro
		If lRepInc
			lRepom := oRepom:VehicleCreate( cCodVei )
		Else
			lRepom := oRepom:VehicleUpdate( cCodVei )
		EndIf
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSVeiLoc( cCodVei, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aVeicul   := {}

    Default cCodVei := ""
    Default lLock   := .F.
    Default cObserv := ""
    
    If !Empty(cCodVei)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aVeicul := oRepom:GetVeicByDoc( cCodVei )

        If Len(aVeicul) > 0
            lRepExc := .T.
        EndIf

        If !lErro .AND. lRepExc
            lRepom := oRepom:VehicleLock( cCodVei, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSHired( cCodFor, cLoja )

    Local oRepom    := Nil
    Local aDriver   := {}
    Local nI        := 0
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodFor := ""
    Default cLoja   := ""

    If !Empty(cCodFor) .AND. !Empty(cLoja)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetHrdByDoc( cCodFor, cLoja )
        
        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepInc := .T. // Realiza a inclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepInc := .F. // Realiza a alteração
            EndIf
        Next nI

        If !lErro
            If lRepInc
                lRepom := oRepom:HiredCreate( cCodFor, cLoja )
            Else
                lRepom := oRepom:HiredUpdate( cCodFor, cLoja )
            EndIf
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSHirLoc( cCodFor, cLoja, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aDriver   := {}
    Local nI        := 0

    Default cCodFor := ""
    Default cLoja   := ""
    Default lLock   := .F.
    Default cObserv := "Delete"
    
    If !Empty(cCodFor) .AND. !Empty(cLoja)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetHrdByDoc( cCodFor, cLoja )

        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepExc := .F. // Realiza a Exclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepExc := .T. // Realiza a Exclusão
            EndIf
        Next nI
        
        If !lErro .AND. lRepExc
            lRepom := oRepom:HiredLock( cCodFor, cLoja, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGravDEG
Realiza gravação do token e seu limite de uso

@param      cToken, nExpire
@author     Rodrigo A. Pirolo
@since      09/10/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSGravDEG( cToken, nExpire )

    Local lRet      := .F.
    Local aAreaDEG  := DEG->(GetArea())

    Default cToken  := ""
    Default nExpire := 0
    
    If !Empty( cToken )
        DbSelectArea("DEG")
        DEG->( DbSetOrder( 1 ) )

        If DEG->( DbSeek( xFilial( "DEG" ) + "01" ) )
            RecLock("DEG", .F.)
                DEG->DEG_TOKEN  := cToken
                DEG->DEG_DTTOKE := Date()
                DEG->DEG_HRTOKE := Time()
                DEG->DEG_EXPIRE := nExpire
            DEG->( MsUnlock() )
            lRet := .T.
        EndIf
    EndIf
    
    RestArea(aAreaDEG)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS15TstR
Realiza teste de comunicaç~ão do cadastro da repom.

@param      cToken, nExpire
@author     Rodrigo A. Pirolo
@since      09/10/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMS15TstR()

	Local oRepom        := Nil
	Local cToken        := ""
	
	If DEG->DEG_CODOPE == "01"
	    oRepom  := TMSBCARepomFrete():New()
	
	    oRepom:Auth()
	
	    cToken  := AllTrim(oRepom:Access_Token)
	
	    If !Empty(cToken)
	        Aviso( STR0005, STR0006 + cToken, { "Ok" } )//STR0005"Integração Prtheus TMS x REPOM" STR0006"A comunicação com o Sistema Repom foi realizada com sucesso. O Token de acesso é: "
	    Else
	        Aviso( STR0005, STR0007, { "Ok" } ) //"A comunicação com o Sistema Repom não foi realizada com sucesso. Por favor revise os dados de acesso."
	    EndIf
	
	    FwFreeObj(oRepom)
	Else
	    Help( , , , 'TMS15TstR', STR0008 )//'Apenas a Gerenciadora de Frota REPOM possui esta funcionalidade.'
	EndIf

Return
