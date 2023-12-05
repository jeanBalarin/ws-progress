 				  				 
 				 
/*------------------------------------------------------------------------
    File        : tg_user_bas.p
    Project     : sports
    Author(s)   : franc
    Created     : Mon Dec 04 23:07:02 BRT 2023
    Notes       :
    Description : increment id user.
  ----------------------------------------------------------------------*/ 				 

	
	TRIGGER PROCEDURE FOR CREATE OF user_bas.
	
	user_bas.id = NEXT-VALUE (user_bas_id).	 