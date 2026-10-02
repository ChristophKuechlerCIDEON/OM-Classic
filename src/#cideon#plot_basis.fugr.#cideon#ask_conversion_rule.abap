FUNCTION /cideon/ask_conversion_rule.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_CONV_RULE) TYPE  CONVERTER_SPEC_NAME
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.08.2006 - Erstellung
*-----------------------------------------------------------------------
* to do
*            -
*-----------------------------------------------------------------------
*ITAB
*WA
*NORMAL

   call screen 730 starting at 10 10 ending at 75 17.


  o_conv_rule = g_converter_spec_name.

ENDFUNCTION.
