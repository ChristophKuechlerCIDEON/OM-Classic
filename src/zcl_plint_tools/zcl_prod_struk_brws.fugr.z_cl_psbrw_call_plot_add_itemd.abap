FUNCTION z_cl_psbrw_call_plot_add_itemd.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_CALL_PLOT_ADD_ITEMZ
*            bitte gleichlautend anpassen !
***********************************************************************
* Journal
* 03.09.2002 - Umarbeitung
* 06.04.2004 - Heiko Hänsel
*            - Unterstützung für die Transaktionen der
*              Bestellanforderung ME5*
* 15.02.2004 - Meldung bei Erfolg
* 06.05.2004 - Heiko Hänsel    Unterstützung für Instandhaltungsauftag,
*                              Equipment, Technischer Platz
* 10.05.2004 - Heiko Hänsel    Unterstützung für Lieferplan, Anfrage,
*                              Angebot
* 11.05.2004 - Heiko Hänsel    Unterstützung für Verkaufs-anfrage,
*                              -angebot, -auftrag
* 28.09.2004 - Anpassung
*              Erweiterung für direkt verknüpfte Dokumente zu
*              technischen Plätzen / Equipments
*              Änderungsnummer
* 02.02.2005 - Heiko Hänsel   Unterstützung des Projektbuilders
* 16.10.2006 - Kopie
*              Auflösungsdatum setzen
*-----------------------------------------------------------------------

  DATA: it_return TYPE TABLE OF ddshretval.

  DATA: wa_return TYPE ddshretval.

* Datum abfragen lassen

  DATA: datum TYPE sy-datum.
  CLEAR datum.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'SYST'
      fieldname                 = 'DATUM'
*     SEARCHHELP                = ' '
*     SHLPPARAM                 = ' '
*     DYNPPROG                  = ' '
*     DYNPNR                    = ' '
*     DYNPROFIELD               = ' '
*     STEPL                     = 0
*     VALUE                     = ' '
*     MULTIPLE_CHOICE           = ' '
*     DISPLAY                   = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM          = ' '
*     CALLBACK_FORM             = ' '
    TABLES
      return_tab                = it_return
    EXCEPTIONS
      field_not_found           = 1
      no_help_for_field         = 2
      inconsistent_help         = 3
      no_values_found           = 4
      OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
  ENDIF.

  IF it_return[] IS INITIAL.
    datum = sy-datum.
  ELSE.
    CLEAR wa_return.
    READ TABLE it_return INTO wa_return INDEX 1.
  ENDIF.


  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
       EXPORTING
            date_external            = wa_return-fieldval
       IMPORTING
            date_internal            = wa_return-fieldval
       EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.

  IF sy-subrc NE 0.
    datum = sy-datum.
  ELSE.
    datum = wa_return-fieldval.
  ENDIF.

* Memory setzen
  SET PARAMETER ID '/CIDEON/PSB_DATE' FIELD datum.

  CALL FUNCTION 'Z_CL_PSBRW_OBJ_RELEASE'
       EXPORTING
            function         = function
            fm_name          = 'Z_CL_PSBRW_WRITE_PSB_TMP'
       TABLES
            selected_objects = selected_objects
       EXCEPTIONS
            error            = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Memory löschen
  SET PARAMETER ID '/CIDEON/PSB_DATE' FIELD '00000000'.


ENDFUNCTION.
