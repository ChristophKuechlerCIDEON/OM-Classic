FUNCTION /CIDEON/_GET_AENR_4_OBJ_2_DATE.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IC_AETYP) TYPE  AETYP
*"     REFERENCE(I_DATA) TYPE REF TO DATA
*"     REFERENCE(IC_DATUV) TYPE  DATUV DEFAULT SY-DATUM
*"  EXPORTING
*"     REFERENCE(ES_VALID_CHANGENO) TYPE  AENR
*"  EXCEPTIONS
*"      TYPE_NOT_FOUND
*"      MISSING_OBJECT
*"      NO_OBJECT_FOUND
*"      NO_VALID_CHANGE_NUMBERS
*"--------------------------------------------------------------------
*
* Recherche der Änderungsnummer
*
*----------------------------------------------------------------------
* Author :  Matthias Bartsch
*
* Anpassungen:
*    Christoph Küchler
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*
*----------------------------------------------------------------------
* Journal
* 2015/01/06 - Kopie des ursprünglichen FB von M. Bartsch
*
*

**********************************************************************

  DATA: lo_data               TYPE REF TO cl_abap_typedescr.

  DATA: lc_usobj              TYPE aeusobj,
        lc_type               TYPE string.

  DATA: lt_aeoi               TYPE TABLE OF aeoi,
        lt_aenr               TYPE TABLE OF aenr.

  DATA: ls_aenr               TYPE aenr,
        ls_aeoi               TYPE aeoi.

  FIELD-SYMBOLS: <fs_struc>   TYPE ANY,
                 <fs_value>   TYPE ANY.


**********************************************************************
*** Determine kind of submitted data
  lo_data ?= cl_abap_refdescr=>describe_by_data_ref( i_data ).
  lc_type = lo_data->absolute_name.
  SHIFT lc_type LEFT BY 6 PLACES.

  ASSIGN i_data->* TO <fs_struc>.
  CHECK <fs_struc> IS ASSIGNED.

  CASE lo_data->kind.
*** Structure
    WHEN cl_abap_refdescr=>kind_struct.
      CASE lc_type.
          "Material BOM
        WHEN 'MAST'.
          ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj(18) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj+18(4) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'STLAN' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj+22(1) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          "Document BOM or document key
        WHEN 'DOST' OR 'DMS_DOC_KEY'.
          ASSIGN COMPONENT 'DOKAR' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj(3) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'DOKNR' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj+3(25) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'DOKTL' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj+28(3) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'DOKVR' OF STRUCTURE <fs_struc> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            lc_usobj+31(2) = <fs_value>.
            UNASSIGN <fs_value>.
          ENDIF.
      ENDCASE.

*** Data element
    WHEN cl_abap_refdescr=>kind_elem.
      "Material number
      CASE lc_type.
        WHEN 'MATNR'.
          lc_usobj = <fs_struc>.

      ENDCASE.

  ENDCASE.

**********************************************************************
*** Find all entries in change objects
  SELECT *
    INTO TABLE lt_aeoi
    FROM aeoi
    WHERE aetyp = ic_aetyp AND
          usobj = lc_usobj.

  IF lt_aeoi IS INITIAL.
    RAISE no_object_found.
  ENDIF.

**********************************************************************
*** Find all change master records for determined objects
  SELECT *
    INTO TABLE lt_aenr
    FROM aenr
    FOR ALL ENTRIES IN lt_aeoi
    WHERE aennr = lt_aeoi-aennr.

*** Sort descending after date
  SORT lt_aenr BY datuv DESCENDING.

**********************************************************************
*** Determine valid change number for submitted data.
  LOOP AT lt_aenr INTO ls_aenr.
    IF ls_aenr-datuv GT ic_datuv.
      DELETE lt_aenr.
    ENDIF.
  ENDLOOP.

  IF NOT lt_aenr IS INITIAL.
    READ TABLE lt_aenr INTO es_valid_changeno INDEX 1.
  ELSE.
    CLEAR: es_valid_changeno.
    RAISE no_valid_change_numbers.
  ENDIF.

ENDFUNCTION.
