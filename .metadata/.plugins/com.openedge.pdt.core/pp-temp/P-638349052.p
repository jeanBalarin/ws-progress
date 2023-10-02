
/*------------------------------------------------------------------------
    File        : dsCustomer.i

    Description : dataset para operações de Cliente.

    Author(s)   : jeanBalarin
    Created     : Sun Oct 01 12:08:40 BRT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

{customer/customer.i}
{response.i}

DEFINE DATASET dsCustomer SERIALIZE-HIDDEN FOR ttCustomer, ttResultsCust, ttErro, ttPage.

