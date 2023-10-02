@openapi.openedge.export FILE(type="REST", executionMode="single-run", useReturnValue="false", writeDataSetBeforeImage="false").

/*------------------------------------------------------------------------
    File        : customerController.p
    Purpose     : expor um crud personalisado da tabela cliente para servi�o Rest  

    Syntax      :

    Description : opera��es com a tabela customer

    Author(s)   : jeanBalarin
    Created     : Tue Sep 26 20:14:27 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

{customer/dsCustomer.i}

/* ************************** Procedures ************************************ */
@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pFindAll:
    DEFINE INPUT PARAMETER inpPageSize AS INTEGER.
    DEFINE INPUT PARAMETER inpCodePage AS INTEGER.
    DEFINE INPUT PARAMETER inpFilter   AS CHARACTER.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.

    RUN service/customerService.p PERSISTENT SET hService. 
    IF VALID-HANDLE(hService) THEN DO:
        RUN findAllCustomer IN hService (INPUT inpPageSize, INPUT inpCodePage, INPUT inpFilter, OUTPUT  DATASET dsCustomer BY-REFERENCE, OUTPUT iCodeStatus).
    END.
    ELSE DO: 
        CREATE ttErro.
        ASSIGN
            ttErro.msg = 'Erro ao executar chamada a rotina de consulta' 
            ttErro.success = FALSE.
    END.
    FINALLY:
        IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
    END FINALLY.
END.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE findByID:
    DEFINE INPUT PARAMETER Codigo AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.

    RUN service/customerService.p PERSISTENT SET hService.
    IF VALID-HANDLE(hService) THEN 
    DO:
        RUN findByIdCustomer IN hService (INPUT Codigo,
                                          OUTPUT DATASET dsCustomer BY-REFERENCE, OUTPUT iCodeStatus).
    END.
    ELSE 
    DO:
        CREATE ttErro.
        ASSIGN
            ttErro.msg     = 'Erro ao executar chamada a rotina de consulta'
            ttErro.success = FALSE.
    END.
    FINALLY:
        IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
    END FINALLY.

END PROCEDURE.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pCreate:
    DEFINE INPUT  PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    RUN service/customerService.p PERSISTENT SET hService.
    IF VALID-HANDLE(hService) THEN 
    DO:
        FOR FIRST ttNewCustomer NO-LOCK:
            MESSAGE "RECID CONTROLLER: "  RECID (ttNewCustomer).
        END.
        RUN pCreateCustomer IN hService (   INPUT TABLE ttNewCustomer BY-REFERENCE,
                                            OUTPUT DATASET dsCustomer BY-REFERENCE , 
                                            OUTPUT iCodeStatus).
    END.
    ELSE 
    DO:
        CREATE ttErro.
        ASSIGN
            ttErro.msg     = 'Erro ao executar chamada a rotina de Cria��o'
            ttErro.success = FALSE.
    END.
    FINALLY:
        IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
    END FINALLY.

END PROCEDURE.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pUpdate:
    DEFINE INPUT PARAMETER iCode AS INTEGER NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    RUN service/customerService.p PERSISTENT SET hService.
    IF VALID-HANDLE(hService) THEN 
    DO:
        RUN pUpdateCustomer IN hService (   INPUT  iCode,
                                            INPUT  TABLE ttNewCustomer BY-REFERENCE,
                                            OUTPUT DATASET dsCustomer BY-REFERENCE, 
                                            OUTPUT iCodeStatus).
    END.
    ELSE 
    DO:
        CREATE ttErro.
        ASSIGN
            ttErro.msg     = 'Erro ao executar chamada a rotina de Altera��o'
            ttErro.success = FALSE.
    END.
    FINALLY:
        IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
    END FINALLY.
    
END PROCEDURE.


@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pDelete:
    DEFINE INPUT PARAMETER iCodigo AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.

    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
        RUN service/customerService.p PERSISTENT SET hService.
        IF VALID-HANDLE(hService) THEN DO:
            RUN pDeleteCustomer IN hService (
                    INPUT iCodigo,
                    OUTPUT DATASET dsCustomer BY-REFERENCE, 
                    OUTPUT iCodeStatus
                ).     
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN
                ttErro.msg     = 'Erro ao executar chamada a rotina de exclus�o'
                ttErro.success = FALSE.
        END.
        FINALLY:
            IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.  
            FOR EACH ttErro:
                MESSAGE ttErro.msg.
            END.
            FOR EACH ttResultsCust:
                MESSAGE "RECID CONTROLER: " RECID(ttResultsCust).
                MESSAGE ttResultsCust.msg.
            END.
            RETURN.
        END FINALLY.
END PROCEDURE.


@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pFindCustomerPag:
    DEFINE INPUT PARAMETER inpPageSize AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER inpCodePage AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    
    
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    RUN service/customerService.p PERSISTENT SET hService.
    
    IF VALID-HANDLE(hService) THEN DO:
        RUN findCustomerPage IN hService (INPUT inpPageSize, INPUT inpCodePage, OUTPUT DATASET dsCustomer, OUTPUT iCodeStatus).  
        
    END.
    MESSAGE(RETURN-VALUE).
    IF RETURN-VALUE <> "OK" THEN DO:
        iCodeStatus = 500.
        CREATE ttErro.
        ASSIGN ttErro.msg = "Erro desconhecido!".    
    END.   
    RETURN.
    FINALLY: 
        
        IF VALID-HANDLE(hService) THEN
            DELETE PROCEDURE hService.
            
    END FINALLY.   
END PROCEDURE.