@openapi.openedge.export FILE(type="REST", executionMode="single-run", useReturnValue="false", writeDataSetBeforeImage="false").

/*------------------------------------------------------------------------
    File        : customerController.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : franc
    Created     : Mon Jul 10 20:52:56 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.
{include/customer.i}
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pFindAll:
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        RUN service/customerService.p PERSISTENT SET hService.
        IF VALID-HANDLE(hService) THEN DO:
            RUN findAllCustomer IN hService (OUTPUT  DATASET dsCustomer BY-REFERENCE, OUTPUT iCodeStatus).
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
END.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE findByID:
    DEFINE INPUT PARAMETER Codigo AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
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
    END.
END PROCEDURE.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pCreate:
    DEFINE INPUT  PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE: 
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
                ttErro.msg     = 'Erro ao executar chamada a rotina de Criação'
                ttErro.success = FALSE.
        END.
        FINALLY:
            IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
        END FINALLY.
    END.
END PROCEDURE.

@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pUpdate:
    DEFINE INPUT PARAMETER iCode AS INTEGER NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
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
                ttErro.msg     = 'Erro ao executar chamada a rotina de Alteração'
                ttErro.success = FALSE.
        END.
        FINALLY:
            IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.    
        END FINALLY.
    END.
END PROCEDURE.


@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
PROCEDURE pDelete:
    DEFINE INPUT PARAMETER iCodigo AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    
    
    DEFINE VARIABLE hService AS HANDLE NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
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
                ttErro.msg     = 'Erro ao executar chamada a rotina de exclusão'
                ttErro.success = FALSE.
        END.
        FINALLY:
            IF VALID-HANDLE(hService) THEN DELETE PROCEDURE hService.  
            FOR EACH ttErro:
                MESSAGE ttErro.msg.
            END.
            FOR EACH ttResults:
                MESSAGE "RECID CONTROLER: " RECID(ttResults).
                MESSAGE ttResults.msg.
            END.
            RETURN.
        END FINALLY.
    END.
END PROCEDURE.

    
