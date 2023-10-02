DEFINE TEMP-TABLE ttNewCustomer NO-UNDO SERIALIZE-NAME "Customer"
    FIELD Country      AS CHARACTER SERIALIZE-NAME "pais" 
    FIELD Name         AS CHARACTER SERIALIZE-NAME "nome" 
    FIELD Address      AS CHARACTER SERIALIZE-NAME "endereco"
    FIELD Address2     AS CHARACTER SERIALIZE-NAME "endereco-2" 
    FIELD City         AS CHARACTER SERIALIZE-NAME "cidade" 
    FIELD State        AS CHARACTER SERIALIZE-NAME "estado" 
    FIELD PostalCode   AS CHARACTER SERIALIZE-NAME "cep" 
    FIELD Contact      AS CHARACTER SERIALIZE-NAME "contato" 
    FIELD Phone        AS CHARACTER SERIALIZE-NAME "telefone" 
    FIELD SalesRep     AS CHARACTER SERIALIZE-NAME "representante"
    FIELD CreditLimit  AS DECIMAL   SERIALIZE-NAME "limiteCredito" 
    FIELD Balance      AS DECIMAL   SERIALIZE-NAME "balance" 
    FIELD Terms        AS CHARACTER SERIALIZE-NAME "termos" 
    FIELD Discount     AS INTEGER   SERIALIZE-NAME "desconto" 
    FIELD Comments     AS CHARACTER SERIALIZE-NAME "comentarios" 
    FIELD Fax          AS CHARACTER SERIALIZE-NAME "fax" 
    FIELD EmailAddress AS CHARACTER SERIALIZE-NAME "email".

DEFINE TEMP-TABLE ttCustomer NO-UNDO SERIALIZE-NAME "Customers" LIKE ttNewCustomer
    FIELD CustNum AS INTEGER SERIALIZE-NAME "codigo" .

    
DEFINE TEMP-TABLE ttResultsCust NO-UNDO SERIALIZE-NAME "results"
    FIELD CustNum  AS INTEGER   SERIALIZE-NAME "codigo"  
    FIELD Name     AS CHARACTER SERIALIZE-NAME "nome" 
    FIELD SalesRep AS CHARACTER SERIALIZE-NAME "representante"
    FIELD msg      AS CHARACTER SERIALIZE-NAME "message"
    FIELD success  AS LOGICAL   SERIALIZE-NAME "success".   