
/*------------------------------------------------------------------------
    File        : customer.p
    Purpose     : customer related services

    Syntax      :

    Description : 

    Author(s)   : franc
    Created     : Mon Jul 10 19:41:34 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.
{include/customer.i}

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

PROCEDURE findAllCustomer:
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    
    FOR EACH Customer NO-LOCK:
        CREATE ttCustomer.
        BUFFER-COPY Customer TO ttCustomer.
    END.
    
    iCodeStatus = 200.
    RETURN.
    
END PROCEDURE.

PROCEDURE findByIdCustomer:
    DEFINE INPUT PARAMETER ipCodigo AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    
    IF ipCodigo >= 0 THEN DO:
        FIND FIRST Customer NO-LOCK WHERE 
            Customer.CustNum = ipCodigo NO-ERROR.    
        
        IF AVAILABLE Customer THEN DO:
            BUFFER-COPY Customer TO ttCustomer.
            iCodeStatus = 200.
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN 
                ttErro.msg     = 'Cliente n�o encontrado para codigo informado!'
                ttErro.success = FALSE
                iCodeStatus    = 404. // not found
        END.    
    END.
    ELSE DO:
        CREATE ttErro.
        ASSIGN 
            ttErro.msg     = 'Codigo informado � inv�lido!'
            ttErro.success = FALSE
            iCodeStatus    = 400. // bad request
    END.
END PROCEDURE.

PROCEDURE pCreateCustomer:
    DEFINE INPUT PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        IF CAN-FIND (FIRST ttNewCustomer) THEN DO:
            FOR FIRST ttNewCustomer:
                CREATE Customer.
                BUFFER-COPY ttNewCustomer TO Customer.
                Customer.CustNum = NEXT-VALUE (NextCustNum).
                
                CREATE ttResults.
                ASSIGN 
                    ttResults.CustNum = Customer.CustNum
                    ttResults.Name    = Customer.Name
                    ttResults.SalesRep = Customer.SalesRep
                    ttResults.success  = TRUE 
                    ttResults.msg      = "Cliente criado com sucesso!"
                    iCodeStatus = 201.
            END.
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN 
                ttErro.success = FALSE
                ttErro.msg     = 'Requisi��o imcompleta!'
                iCodeStatus    = 400.
        END.
        CATCH sysError AS Progress.Lang.SysError :
            CREATE ttErro.
            ASSIGN
                ttErro.success = FALSE 
                ttErro.msg     = sysError:GetMessage(1)
                iCodeStatus    = 500.      
        END CATCH. 
    END.
END.

PROCEDURE pUpdateCustomer:
    DEFINE INPUT PARAMETER ipCode AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER TABLE FOR ttNewCustomer.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER icodeStatus AS INTEGER NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        FIND FIRST Customer EXCLUSIVE-LOCK WHERE
            Customer.CustNum = ipCode NO-ERROR.
        IF AVAILABLE Customer THEN DO:
            FOR FIRST ttNewCustomer NO-LOCK:
                BUFFER-COPY ttNewCustomer TO Customer.
            END.
            
            CREATE ttResults.
            BUFFER-COPY Customer TO ttResults.
            ASSIGN 
                ttResults.success = TRUE
                ttResults.msg     =  "Cliente Alterado com sucesso!"
                icodeStatus = 200.           
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN
            ttErro.msg       = "Cliente n�o localizado"
            ttErro.success   = FALSE
            icodeStatus      = 400.
         END.
         CATCH sysErro AS Progress.Lang.Error :
             CREATE ttErro.
             ASSIGN
                 ttErro.msg     = sysErro:GetMessage(1)
                 ttErro.success = FALSE
                 icodeStatus    = 500.
         END CATCH.       
    END.
END PROCEDURE.

PROCEDURE pDeleteCustomer:
    DEFINE INPUT PARAMETER ipCode AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER icodeStatus AS INTEGER NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        FIND FIRST Customer EXCLUSIVE-LOCK WHERE
            Customer.CustNum = ipCode NO-ERROR.
        IF AVAILABLE Customer THEN DO:
            MESSAGE 'AVL CUSTOMER'
            VIEW-AS ALERT-BOX.
            CREATE ttResults.
            BUFFER-COPY Customer TO ttResults.
            ASSIGN 
                ttResults.success = TRUE
                ttResults.msg     = "Cliente Deletado com sucesso!"
                icodeStatus       = 200. 
                
            DELETE Customer.  
            RELEASE Customer. 
            RELEASE ttResults.           
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN
                ttErro.msg     = "Cliente n�o localizado"
                ttErro.success = FALSE
                icodeStatus    = 400.
                RELEASE ttErro.
        END.
        CATCH sysErro AS Progress.Lang.Error :
            EMPTY TEMP-TABLE ttResults.
            CREATE ttErro.
            ASSIGN
                ttErro.msg     = sysErro:GetMessage(1)
                ttErro.success = FALSE
                icodeStatus    = 500.
        END CATCH.       
    END.
END PROCEDURE.


