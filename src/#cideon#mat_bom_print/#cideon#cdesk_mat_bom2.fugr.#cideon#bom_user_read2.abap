FUNCTION /CIDEON/BOM_USER_READ2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(UNAME) TYPE  XUBNAME DEFAULT 'DEFAULT'
*"       EXPORTING
*"             VALUE(BOM_USR) TYPE  /CIDEON/BOM_USR
*"       EXCEPTIONS
*"              NO_ENTRY
*"----------------------------------------------------------------------

  IF uname IS INITIAL.
    uname = 'DEFAULT'.
  ENDIF.

  CHECK NOT uname IS INITIAL.

  SELECT SINGLE * FROM /cideon/bom_usr
  INTO bom_usr
  WHERE uname EQ uname.

  IF sy-subrc NE 0.
    CLEAR bom_usr.
    RAISE no_entry.
  ENDIF.

ENDFUNCTION.
