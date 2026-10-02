FUNCTION /cideon/select_mat_dir.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(BOM_PRINT) TYPE  /CIDEON/BOM_PRINT
*"  TABLES
*"      MAT_BOM TYPE  TABLE
*"      POSI_MAT_DIR STRUCTURE  /CIDEON/MAT_DIR
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*       Selektion der verknüpften Dokumente zu den Positionen
*----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           24.10.2006
*-----------------------------------------------------------------------
* Journal   24.10.2006 Entwicklung
*   CKR     26.10.2006 - Probleme mit CONV_UTIL_MATNR_EXT_TO_INT
*                      CONV_UTIL_MATNR_INT_TO_EXT
*                      in einem DIMP System
*                      BUG: 1817
*   PRE     02.11.2006 - Typkonflikt bei INT_TO_EXT
*                        definition geändert
*-----------------------------------------------------------------------
* CKR
  DATA: matnr_ext TYPE csap_mbom-matnr.
  DATA: matnr_int TYPE mbm_class_data-matnr.
* /CKR

  DATA:  lc_dokar TYPE dokar,
         lc_doknr TYPE doknr,
         lc_doktl TYPE doktl_d,
         lc_dokvr TYPE dokvr,
      ls_bom_print TYPE /cideon/bom_print,
      ls_mat_dir TYPE /cideon/mat_dir,
      ls_draw TYPE draw,
      ls_return TYPE bapiret2,
      lc_objecttype TYPE bapi_doc_drad-objecttype,
      lc_objectkey TYPE bapi_doc_drad-objectkey,
      lc_objky TYPE objky,
      ls_documentlist TYPE bapi_doc_keys,
      lt_documentlist TYPE TABLE OF bapi_doc_keys,
      lc_matnr TYPE matnr,
      lc_matnr_e TYPE matnr,
      lc_index TYPE syindex,
      bapi_message LIKE messages.

  FIELD-SYMBOLS:  <doc_key> TYPE bapi_doc_keys,
                  <bom_pos> TYPE ANY, "stpox
                  <postp> TYPE ANY,
                  <dokar> TYPE ANY,
                  <doknr> TYPE ANY,
                  <dokvr> TYPE ANY,
                  <doktl> TYPE ANY,
                  <idnrk> TYPE ANY,
                  <bomob> TYPE ANY,
                  <dobjt> TYPE ANY,
                  <posnr> TYPE ANY.

  LOOP AT mat_bom ASSIGNING <bom_pos>.
    CHECK <bom_pos> IS ASSIGNED.
    CLEAR: lc_matnr_e, lc_objecttype, lc_objectkey,
           ls_mat_dir, lc_matnr.
    CLEAR: lc_dokar, lc_doknr, lc_doktl,
           lc_dokvr, ls_draw.
    lc_index = 1.
    CASE bom_print-bomtype.
      WHEN 'CS03'.
        CASE bom_print-bomausp.
          WHEN 'A'.

            ASSIGN COMPONENT 'POSTP' OF STRUCTURE <bom_pos> TO <postp>.
            CHECK <postp> IS ASSIGNED.
            ASSIGN COMPONENT 'BOMOB' OF STRUCTURE <bom_pos> TO <bomob>.
            CHECK <bomob> IS ASSIGNED.
            CASE <postp>.
              WHEN 'T'.
*      Textposition ohne Verknüpfung
              WHEN 'D'.
*      Dokumentenposition -> Verknüpfung
                MOVE  'DRAW' TO lc_objecttype.
                MOVE <bomob>+0(3) TO ls_draw-dokar.
                MOVE <bomob>+4(25) TO ls_draw-doknr.
                MOVE <bomob>+30(3) TO ls_draw-doktl.
                MOVE <bomob>+34(2) TO ls_draw-dokvr.

                CALL FUNCTION 'CONV_UTIL_DOCNR_EXT_TO_INT'
                     EXPORTING
                          i_documentnumber = ls_draw-doknr
                     IMPORTING
                          e_documentnumber = ls_draw-doknr.

                CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
                     EXPORTING
                          draw      = ls_draw
                     IMPORTING
                          objectkey = lc_objky.
                lc_objectkey = lc_objky.

              WHEN OTHERS.
                MOVE  'MARA' TO lc_objecttype.
                MOVE <bomob> TO lc_matnr_e.

* CKR
*                CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
*                     EXPORTING
*                          i_material = lc_matnr_e
*                     IMPORTING
*                          e_material = lc_matnr.
*                MOVE lc_matnr TO lc_objectkey.

                CLEAR matnr_ext.
                CLEAR matnr_int.
                matnr_ext = lc_matnr_e.
                CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
                     EXPORTING
                          i_material = matnr_ext
                     IMPORTING
                          e_material = matnr_int.
*                lc_matnr = matnr_int.
                MOVE matnr_int TO lc_objectkey.
* /CKR

            ENDCASE.
          WHEN 'D' OR 'M'.

*  Ermitteln der verknüpften Dokumente zu den Positionen
*  Unterscheidung der Positionsarten:
*    -  Material
*    -  Dokument
*    -  Sonstige:
            ASSIGN COMPONENT 'POSTP' OF STRUCTURE <bom_pos> TO <postp>.
            CHECK <postp> IS ASSIGNED.
            CASE <postp>.
              WHEN 'T'.
*      Textposition ohne Verknüpfung
              WHEN 'D'.
*      Dokumentenposition -> Verknüpfung womit ?
                MOVE:  'DRAW' TO lc_objecttype.
             ASSIGN COMPONENT 'DOKAR' OF STRUCTURE <bom_pos> TO <dokar>.
             ASSIGN COMPONENT 'DOKNR' OF STRUCTURE <bom_pos> TO <doknr>.
             ASSIGN COMPONENT 'DOKVR' OF STRUCTURE <bom_pos> TO <dokvr>.
             ASSIGN COMPONENT 'DOKTL' OF STRUCTURE <bom_pos> TO <doktl>.
                CHECK <dokar> IS ASSIGNED.
                CHECK <doknr> IS ASSIGNED.
                CHECK <dokvr> IS ASSIGNED.
                CHECK <doktl> IS ASSIGNED.

                MOVE: <dokar> TO ls_draw-dokar,
                      <doknr> TO ls_draw-doknr,
                      <dokvr> TO ls_draw-dokvr,
                      <doktl> TO ls_draw-doktl.

                CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
                     EXPORTING
                          draw      = ls_draw
                     IMPORTING
                          objectkey = lc_objky.
                MOVE lc_objky TO lc_objectkey.
              WHEN OTHERS.
                MOVE:  'MARA' TO lc_objecttype.
             ASSIGN COMPONENT 'IDNRK' OF STRUCTURE <bom_pos> TO <idnrk>.
                CHECK <idnrk> IS ASSIGNED.
* CKR
*                CALL FUNCTION 'CONV_UTIL_MATNR_INT_TO_EXT'
*                     EXPORTING
*                          i_material = lc_matnr
*                     IMPORTING
*                          e_material = lc_matnr_e.
                CLEAR matnr_int.
                CLEAR matnr_ext.
                MOVE <idnrk> TO lc_objectkey.
                MOVE <idnrk> TO matnr_int.
                CALL FUNCTION 'CONV_UTIL_MATNR_INT_TO_EXT'
                     EXPORTING
                          i_material = matnr_int
                     IMPORTING
                          e_material = matnr_ext.
                lc_matnr_e = matnr_ext.
* /CKR
            ENDCASE.

        ENDCASE.

      WHEN 'CS11' OR 'CS12'.
        ASSIGN COMPONENT 'OBJIC' OF STRUCTURE <bom_pos> TO <postp>.
        CHECK <postp> IS ASSIGNED.
        ASSIGN COMPONENT 'DOBJT' OF STRUCTURE <bom_pos> TO <dobjt>.
        CHECK <dobjt> IS ASSIGNED.
        ASSIGN COMPONENT 'POSNR' OF STRUCTURE <bom_pos> TO <posnr>.
        CHECK <posnr> IS ASSIGNED.
        CHECK NOT <posnr> IS INITIAL.
        CASE <postp>.
          WHEN 'T'.
*      Textposition ohne Verknüpfung
          WHEN 'D'.
            MOVE:  'DRAW' TO lc_objecttype.
            SPLIT <dobjt> AT space INTO lc_doknr lc_dokar
                                        lc_doktl lc_dokvr.
            MOVE: lc_dokar TO ls_draw-dokar,
                  lc_doktl TO ls_draw-doktl,
                  lc_dokvr TO ls_draw-dokvr.
            CALL FUNCTION 'CONV_UTIL_DOCNR_EXT_TO_INT'
                 EXPORTING
                      i_documentnumber = lc_doknr
                 IMPORTING
                      e_documentnumber = ls_draw-doknr.

            CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
                 EXPORTING
                      draw      = ls_draw
                 IMPORTING
                      objectkey = lc_objky.
            lc_objectkey = lc_objky.

          WHEN OTHERS.
            MOVE  'MARA' TO lc_objecttype.
* CKR
*            CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
*                 EXPORTING
*                      i_material = lc_matnr_e
*                 IMPORTING
*                      e_material = lc_matnr.
*            MOVE lc_matnr TO lc_objectkey.
            CLEAR matnr_int.
            CLEAR matnr_ext.
            MOVE: <dobjt> TO matnr_ext,
                  <dobjt> to lc_matnr_e.
            CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
                 EXPORTING
                      i_material = matnr_ext
                 IMPORTING
                      e_material = matnr_int.
            MOVE matnr_int TO lc_objectkey.
* /CKR
        ENDCASE.

      WHEN 'CS13'.
        ASSIGN COMPONENT 'OBJIC' OF STRUCTURE <bom_pos> TO <postp>.
        CHECK <postp> IS ASSIGNED.
        ASSIGN COMPONENT 'DOBJT' OF STRUCTURE <bom_pos> TO <dobjt>.
        CHECK <dobjt> IS ASSIGNED.
        CASE <postp>.
          WHEN 'T'.
*      Textposition ohne Verknüpfung
          WHEN 'D'.
            MOVE:  'DRAW' TO lc_objecttype.
            SPLIT <dobjt> AT space INTO lc_doknr lc_dokar
                                        lc_doktl lc_dokvr.
            MOVE: lc_dokar TO ls_draw-dokar,
                  lc_doktl TO ls_draw-doktl,
                  lc_dokvr TO ls_draw-dokvr.
            CALL FUNCTION 'CONV_UTIL_DOCNR_EXT_TO_INT'
                 EXPORTING
                      i_documentnumber = lc_doknr
                 IMPORTING
                      e_documentnumber = ls_draw-doknr.

            CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
                 EXPORTING
                      draw      = ls_draw
                 IMPORTING
                      objectkey = lc_objky.
            lc_objectkey = lc_objky.

          WHEN OTHERS.
            MOVE  'MARA' TO lc_objecttype.

* CKR
*            CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
*                 EXPORTING
*                      i_material = lc_matnr_e
*                 IMPORTING
*                      e_material = lc_matnr.
*            MOVE lc_matnr TO lc_objectkey.
            CLEAR matnr_int.
            CLEAR matnr_ext.
            MOVE: <dobjt> TO matnr_ext,
                  <dobjt> to lc_matnr_e.
            CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
                 EXPORTING
                      i_material = matnr_ext
                 IMPORTING
                      e_material = matnr_int.
            MOVE matnr_int TO lc_objectkey.
*/CKR
        ENDCASE.

    ENDCASE.
    CHECK NOT lc_objectkey IS INITIAL.

*  Lesen der bereits vorm Speichern vorhandenen Objektverknüpfungen:

    CLEAR: ls_return, lt_documentlist.
    CALL FUNCTION 'BAPI_DOCUMENT_GETOBJECTDOCS'
      EXPORTING
        objecttype                = lc_objecttype
        objectkey                 = lc_objectkey
*   CURRENTVERSIONSONLY       =
*   DATE                      = SY-DATUM
       IMPORTING
         return                    = ls_return
      TABLES
        documentlist              = lt_documentlist.

    IF lt_documentlist[] IS INITIAL.
    ELSE.

      LOOP AT lt_documentlist ASSIGNING <doc_key>.
        CHECK <doc_key> IS ASSIGNED.
        MOVE-CORRESPONDING <doc_key> TO ls_mat_dir.
        MOVE: <postp> TO ls_mat_dir-postp.
        MOVE: lc_index   TO ls_mat_dir-nrindex.
        CASE <postp>.
          WHEN 'T'.
          WHEN 'D'.
            MOVE lc_objectkey TO ls_mat_dir-objky.
          WHEN OTHERS.
            MOVE lc_matnr_e TO ls_mat_dir-objky.
        ENDCASE.
        READ TABLE posi_mat_dir FROM ls_mat_dir.
        IF sy-subrc <> 0.
          APPEND ls_mat_dir TO posi_mat_dir.
        ENDIF.
        lc_index = lc_index + 1.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
