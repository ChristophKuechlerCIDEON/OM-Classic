FUNCTION Z_CL_PLINT_TOOLS_ASK_FOR_PRIO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PRIO_VON) LIKE  ZCL_S_PLOTLIST-PRIO OPTIONAL
*"     REFERENCE(I_PRIO_BIS) LIKE  ZCL_S_PLOTLIST-PRIO OPTIONAL
*"  EXPORTING
*"     REFERENCE(O_PRIO) LIKE  ZCL_S_PLOTLIST-PRIO
*"  EXCEPTIONS
*"      ERROR
*"      FORGET
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 23.07.2002 creation
*
*-----------------------------------------------------------------------
* to do:
*      - add some checks
*-----------------------------------------------------------------------
  clear prio.
  clear g_prio.
  clear prio_von.
  clear prio_bis.
  prio_von = i_prio_von.
  prio_bis = i_prio_bis.

  call screen 500 starting at 10 10 ending at 67 25.

  o_prio = g_prio.

ENDFUNCTION.
