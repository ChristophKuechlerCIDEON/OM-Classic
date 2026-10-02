*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_SERVICE_DLGO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&----------------------------------------------------------------------
*& Beschreibung: Initialisierung des ALV Grid Controls.
*&
*& Autor:        HAENSEL
*& Angelegt am:  07.09.2006 07:59:15
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
MODULE init_objlist OUTPUT.
  IF go_objlist_container IS INITIAL.
    CREATE OBJECT go_objlist_container
      EXPORTING
        container_name = 'OBJLIST_CONTAINER'.
    CREATE OBJECT go_objlist_control
      EXPORTING
        i_parent = go_objlist_container.

*   Feldkatalog aus DDIC Struktur aufbauen und anpassen
    PERFORM prepare_field_catalog.
    PERFORM prepare_toolbar.

    gs_objlist_layout-CWIDTH_OPT = abap_true.
    gs_objlist_layout-edit  = abap_true.
    CALL METHOD go_objlist_control->set_table_for_first_display
      EXPORTING
        is_layout       = gs_objlist_layout
        it_toolbar_excluding = gt_toolbar_excluding
      CHANGING
        it_fieldcatalog = gt_objlist_fcat
        it_outtab       = gt_objtype_settings
        .

  ENDIF.
ENDMODULE.                 " init_objlist  OUTPUT
