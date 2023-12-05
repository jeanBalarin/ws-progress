
/*------------------------------------------------------------------------
    File        : response.i
    Purpose     : definições de dados dos serviços rest

    Syntax      :

    Description : operações relacionadas a tabela customer, 

    Author(s)   : jeanBalarin
    Created     : Tue Sep 26 20:18:15 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Main Block  *************************** */
    
DEFINE TEMP-TABLE ttErro NO-UNDO SERIALIZE-NAME "Errors"
    FIELD msg     AS CHARACTER  SERIALIZE-NAME "message"
    FIELD success AS LOGICAL    SERIALIZE-NAME "success"
    FIELD codStatus  AS INTEGER SERIALIZE-NAME "cod". 
    
DEFINE TEMP-TABLE ttPage NO-UNDO SERIALIZE-NAME "pages"
    FIELD sizePage AS INTEGER 
    FIELD iPage    AS INTEGER SERIALIZE-NAME "page"
    FIELD hasNext  AS LOG 
    FIELD rowCont  AS INTEGER.

    