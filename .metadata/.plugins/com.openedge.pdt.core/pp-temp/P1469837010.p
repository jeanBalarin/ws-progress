 
 /*------------------------------------------------------------------------
    File        : UserBas
    Purpose     : implement the base user entity and its validations such as authentication and validating user groups
    Syntax      : 
    Description : 
    Author(s)   : franc
    Created     : Sun Nov 26 17:05:17 BRT 2023
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING entitties.user.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS entitties.user.UserBas: 
    
    DEFINE PUBLIC PROPERTY firstName AS CHARACTER NO-UNDO 
    GET():
        RETURN THIS-OBJECT:firstName.
    END GET.
    PRIVATE SET(INPUT pName AS CHARACTER):
        THIS-OBJECT:firstName = pName.
    END SET. 
    
    DEFINE PUBLIC PROPERTY lastName AS CHARACTER NO-UNDO 
    GET(): 
        RETURN THIS-OBJECT:lastName.
    END GET.
    PRIVATE SET(INPUT pLastName AS CHARACTER):
        THIS-OBJECT:lastName = pLastName. 
    END SET.       
    
    DEFINE PUBLIC PROPERTY id AS INT64 NO-UNDO 
    GET():
        RETURN THIS-OBJECT:id.
    END GET.
    // NOT IMPLEMENTS, SEQUENCE USER_BAS_ID IN THE METHOD SAVE.
    PRIVATE SET.  
    
    DEFINE PUBLIC PROPERTY login AS CHARACTER NO-UNDO 
    GET():
        RETURN THIS-OBJECT:login.
    END GET.
    PRIVATE SET(INPUT pLogin AS CHARACTER):
        // implements method validate-login()
        THIS-OBJECT:login = pLogin.
    END SET.
     
    DEFINE PUBLIC PROPERTY active AS LOGICAL NO-UNDO 
    GET():
        RETURN THIS-OBJECT:ACTIVE.    
    END GET.
    SET(INPUT pActive AS LOGICAL):
        THIS-OBJECT:ACTIVE  = pActive.            
    END SET.
     
    DEFINE PUBLIC PROPERTY blockLogin AS LOGICAL NO-UNDO 
    GET():
        RETURN THIS-OBJECT:blockLogin.    
    END GET.
    PRIVATE SET(INPUT pBlock AS LOGICAL):
        THIS-OBJECT:blockLogin = pBlock.            
    END SET.
    
    DEFINE PUBLIC PROPERTY email AS CHARACTER NO-UNDO 
    GET():
        RETURN THIS-OBJECT:email.
    END GET.
    PRIVATE SET(INPUT pEmail AS CHARACTER):
        // implements method validate-login().
        THIS-OBJECT:email = pEmail.             
    END SET.
     
    DEFINE PRIVATE PROPERTY passWord AS CHARACTER NO-UNDO 
    PRIVATE GET.
    PRIVATE SET(INPUT pPass AS CHARACTER): 
        // implement encryption-pass() method
        THIS-OBJECT:passWord = pPass.
    END SET. 
    
    DEFINE PUBLIC PROPERTY datePass AS DATETIME NO-UNDO 
    GET():
        RETURN THIS-OBJECT:datePass.
    END GET.
    PRIVATE SET(INPUT pDate AS DATETIME):
        THIS-OBJECT:datePass = pDate.             
    END SET.
     
    DEFINE PRIVATE PROPERTY token AS CHARACTER NO-UNDO 
    PRIVATE GET():
        RETURN THIS-OBJECT:token.    
    END GET.
    PRIVATE SET(INPUT pToken AS CHARACTER):
        THIS-OBJECT:token = pToken.                    
    END SET.
    
    DEFINE PUBLIC PROPERTY dateToken AS DATETIME NO-UNDO 
    GET():
        RETURN THIS-OBJECT:dateToken.    
    END GET.
    PRIVATE SET(INPUT pDateToken AS DATETIME):
        THIS-OBJECT:dateToken = pDateToken.            
    END SET.
    
    DEFINE PUBLIC PROPERTY nrFailLogin AS INTEGER NO-UNDO 
    PUBLIC GET(): 
        RETURN THIS-OBJECT:nrFailLogin.
    END GET.
    PRIVATE SET(INPUT pFail AS INTEGER):
        THIS-OBJECT:nrFailLogin = pFail.            
    END SET.
     
    DEFINE PUBLIC PROPERTY lastLogin AS DATETIME NO-UNDO 
    GET():
        RETURN THIS-OBJECT:lastLogin.    
    END GET.
    PRIVATE SET(INPUT pLogin AS DATETIME):
        THIS-OBJECT:lastLogin.                
    END SET.
            
    DEFINE PUBLIC PROPERTY phone AS CHARACTER NO-UNDO 
    PUBLIC GET():
        RETURN THIS-OBJECT:phone.    
    END GET.
    PRIVATE SET(INPUT pPhone AS CHARACTER):
        THIS-OBJECT:phone = pPhone.            
    END SET.
     
    DEFINE PRIVATE PROPERTY uniqueIdentification AS CHARACTER NO-UNDO 
    PRIVATE GET(): 
        RETURN THIS-OBJECT:uniqueIdentification.
    END GET.
    PRIVATE SET(INPUT pIdUnique AS CHARACTER): 
        THIS-OBJECT:uniqueIdentification = pIdUnique.    
    END SET.      
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	CONSTRUCTOR STATIC  UserBas (  ):
		
	END CONSTRUCTOR.

    
    CONSTRUCTOR PUBLIC UserBas (  ):
        SUPER ().
        
    END CONSTRUCTOR.


    METHOD PUBLIC entitties.user.UserBas Create(
        INPUT pFisrtName            AS CHARACTER, 
        INPUT pLastName             AS CHARACTER,
        INPUT pLogin                AS CHARACTER,
        INPUT pEmail                AS CHARACTER,
        INPUT pPhone                AS CHARACTER,
        INPUT pUniqueIdentification AS CHARACTER,
        INPUT pPass                 AS CHARACTER
    ):
        DEFINE VARIABLE newUser AS UserBas NO-UNDO.
        
        
        
            
        RETURN newUser.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Validar o email informado
     Notes: 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LOGICAL valid-email( INPUT pEmail AS CHARACTER):       
        DEFINE VARIABLE valid AS LOGICAL NO-UNDO.
        DEFINE VARIABLE appErr AS Progress.Lang.AppError.
        DO ON ERROR UNDO, THROW:
            // min length
            IF LENGTH(pEmail) < 12 THEN DO:
                appErr = NEW Progress.Lang.AppError(SUBSTITUTE('The email provided is not valid! # &1', pEmail),400).
                valid = FALSE.
                RETURN ERROR appErr.
            END.
            // format email 
            IF NUM-ENTRIES(pEmail, '@') <> 2 THEN DO:
                appErr = NEW Progress.Lang.AppError(SUBSTITUTE('The email format is not valid! # &1', pEmail),400).
                valid = FALSE.
                RETURN ERROR appErr.
            END.
            // avail email outher user
            IF CAN-FIND(FIRST user_bas NO-LOCK WHERE user_bas.email = pEmail) THEN DO:
                appErr = NEW Progress.Lang.AppError(SUBSTITUTE('The email provided is already in use by another user!'),410).
                valid = FALSE. 
                RETURN ERROR appErr.
            END.
            
            valid = TRUE.
            CATCH sysErr AS Progress.Lang.SysError:
                valid = FALSE.
                RETURN ERROR sysErr.       
            END CATCH.
            CATCH err AS Progress.Lang.Error:
                valid = FALSE.
                RETURN ERROR err.        
            END CATCH.
            FINALLY:
                RETURN valid.    
            END FINALLY.
        END.
    END METHOD.

    DESTRUCTOR PUBLIC UserBas ( ):

    END DESTRUCTOR.

END CLASS.