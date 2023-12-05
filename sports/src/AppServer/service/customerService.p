
/*------------------------------------------------------------------------
    File        : customerService.p
    Purpose     : camada de acesso ao banco CRUD

    Syntax      :

    Description : serviços associados a clientes operações e consultas no banco    

    Author(s)   : jeanBalarin
    Created     : Tue Sep 26 20:22:19 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

{customer/dscustomer.i}

DEFINE VARIABLE rowCont AS INTEGER NO-UNDO.
DEFINE TEMP-TABLE ttNewCustomer-ref_only NO-UNDO REFERENCE-ONLY LIKE ttNewCustomer.

/* ***************************  Main Block  *************************** */

PROCEDURE findAllCustomer:
/*****************************************************************************************************
Autor......: JMF
Objetivo...: procedimento de Consulta de clientes
Parametros.:
    inpPageSize/INTEGER  /v1..: tamanho do lote de registros    
    inpCodPage /INTEGER  /v1..: numero da pagina a ser retornada 
    c-where    /CHARACTER/v1..: filtro a ser passado na query
    dsCustomer /DATASET  /V1..: definição de dados a serem retornados na rotina {customer/dscustomer.i}
    iCodeStatus/INTEGER  /V1..: codigo de status da requisição
versão.....: 
    /v1....: 26/09/23 - versão inicial   
******************************************************************************************************/
    DEFINE INPUT PARAMETER inpPageSize AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER inpCodPage  AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER c-where     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer. // temporary table for data output 
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER  NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        // desativa o preenchimento das tabelas que nao tem relação com as tabelas do banco.
        BUFFER  ttErro:FILL-MODE        = "NO-FILL".
        BUFFER  ttResultsCust:FILL-MODE = 'NO-FILL'.
        BUFFER  ttPage:FILL-MODE        = "NO-FILL". 
        
        // tabela fontes de dados
        DEFINE DATA-SOURCE srcCustomer FOR Customer. 
        // attach do buffer da tt no data-source para carregar as informações.
        BUFFER ttCustomer:ATTACH-DATA-SOURCE (DATA-SOURCE srcCustomer:HANDLE).
        
        // ajustado para que o cliente envie a consulta desejada.
        IF c-where <> '' AND c-where <> ? THEN DO:
            DATA-SOURCE srcCustomer:FILL-WHERE-STRING = " WHERE " + c-where.
        END.
        
        IF inpPageSize = 0 OR inpPageSize = ? THEN DO:
            inpPageSize = 10.   // padrão caso nao informado na chamada se houver um tamanho de pagina.
        END.
        
        IF inpCodPage = ? OR inpCodPage = 0 OR inpCodPage <= 1 THEN DO:
            inpCodPage = 1.
        END.
        ELSE DO:
            inpCodPage = ((inpCodPage - 1 ) * inpPageSize) + 1.
        END.
        
     
        BUFFER ttCustomer:BATCH-SIZE  = inpPageSize.
        
        DATA-SOURCE srcCustomer:RESTART-ROW = inpCodPage.
        rowCont = 0.
        BUFFER ttCustomer:SET-CALLBACK-PROCEDURE ("BEFORE-ROW-FILL", "pRowCont", THIS-PROCEDURE).
        
        DATASET dsCustomer:FILL (). 
        
        
        CATCH e AS Progress.Lang.Error :
            DEFINE VARIABLE contE AS INTEGER NO-UNDO.
            REPEAT contE = 1 TO e:NumMessages:
                CREATE ttErro.
                ASSIGN 
                    ttErro.codStatus = contE
                    ttErro.success   = FALSE
                    ttErro.msg       = e:GetMessage(contE)
                    iCodeStatus      = 500.
            END.        
        END CATCH.
        FINALLY:
            IF NOT CAN-FIND ( FIRST  ttErro ) THEN DO:
                CREATE ttPage.
                ASSIGN
                    ttPage.sizePage = inpPageSize
                    ttPage.hasNext  = IF DATA-SOURCE srcCustomer:NEXT-ROWID <> ? THEN TRUE ELSE NO 
                    ttPage.rowCont  = rowCont
                    iCodeStatus     = 200.
                IF inpCodPage > 1 THEN DO:
                    ttPage.iPage    = (inpCodPage / inpPageSize ).
                END.
                ELSE DO:
                    ttPage.iPage    = inpCodPage.
                END.
            END.
                
            BUFFER ttCustomer:DETACH-DATA-SOURCE().
            RETURN.
                
        END FINALLY.
    END. // bloco de erros
END PROCEDURE.

PROCEDURE pCreateCustomer:
    DEFINE INPUT PARAMETER TABLE FOR ttNewCustomer-ref_only .
    DEFINE OUTPUT PARAMETER DATASET FOR dsCustomer.
    DEFINE OUTPUT PARAMETER iCodeStatus AS INTEGER NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:
        IF CAN-FIND (FIRST ttNewCustomer-ref_only) THEN DO:
            FOR FIRST ttNewCustomer-ref_only:
                CREATE Customer.
                BUFFER-COPY ttNewCustomer-ref_only TO Customer.
                Customer.CustNum = NEXT-VALUE (NextCustNum).
                  
                CREATE ttResultsCust.
                ASSIGN 
                    ttResultsCust.CustNum  = Customer.CustNum
                    ttResultsCust.Name     = Customer.Name
                    ttResultsCust.SalesRep = Customer.SalesRep
                    ttResultsCust.success  = TRUE 
                    ttResultsCust.msg      = "Cliente criado com sucesso!"
                    iCodeStatus = 201.
            END.
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN 
                ttErro.success = FALSE
                ttErro.msg     = 'Requisição imcompleta!'
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
            
            CREATE ttResultsCust.
            BUFFER-COPY Customer TO ttResultsCust.
            ASSIGN 
                ttResultsCust.success = TRUE
                ttResultsCust.msg     =  "Cliente Alterado com sucesso!"
                icodeStatus = 200.           
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN
            ttErro.msg       = "Cliente não localizado"
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
            CREATE ttResultsCust. 
            BUFFER-COPY Customer TO ttResultsCust.
            ASSIGN 
                ttResultsCust.success = TRUE
                ttResultsCust.msg     = "Cliente Deletado com sucesso!"
                icodeStatus           = 200. 
                
            DELETE Customer.  
            RELEASE Customer. 
            RELEASE ttResultsCust.           
        END.
        ELSE DO:
            CREATE ttErro.
            ASSIGN
                ttErro.msg     = "Cliente não localizado"
                ttErro.success = FALSE
                icodeStatus    = 400.
                RELEASE ttErro.
        END.
        CATCH sysErro AS Progress.Lang.Error :
            EMPTY TEMP-TABLE ttResultsCust.
            CREATE ttErro.
            ASSIGN
                ttErro.msg     = sysErro:GetMessage(1)
                ttErro.success = FALSE
                icodeStatus    = 500.
        END CATCH. 
        FINALLY:         
        END FINALLY.   
    END.
END PROCEDURE.

// Procedures rotinas Customer.
PROCEDURE pRowCont PRIVATE:
    DEFINE INPUT PARAMETER DATASET FOR dsCustomer.
    
    rowCont = rowCont + 1.
    
END PROCEDURE.
