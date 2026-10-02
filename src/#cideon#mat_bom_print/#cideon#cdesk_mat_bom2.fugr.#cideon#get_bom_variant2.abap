FUNCTION /cideon/get_bom_variant2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(BOM_PRINT) TYPE  /CIDEON/BOM_PRINT
*"  EXPORTING
*"     REFERENCE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      MAT_BOM_I STRUCTURE  STPOX
*"      MAT_BOM_CS03_A STRUCTURE  /CIDEON/STPOS_CS03_A OPTIONAL
*"      MAT_BOM_CS03_D STRUCTURE  /CIDEON/STPOS_CS03_D OPTIONAL
*"      MAT_BOM_CS03_M STRUCTURE  /CIDEON/STPOS_CS03_M OPTIONAL
*"      MAT_BOM_CS11 STRUCTURE  /CIDEON/STPOS_CS11 OPTIONAL
*"      MAT_BOM_CS12 STRUCTURE  /CIDEON/STPOS_CS12 OPTIONAL
*"      MAT_BOM_CS13 STRUCTURE  /CIDEON/STPOS_CS13 OPTIONAL
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*       Selektion und Druck Materialstückliste
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           17.01.2005
*-----------------------------------------------------------------------
* Journal   17.01.2005 Auseinandersteuern der Druckvarianten
*                      entsprechend der User-Parameter
*-----------------------------------------------------------------------


  DATA: ls_stpox TYPE stpox,
        ls_stpox_temp TYPE stpox,
        lt_stpox TYPE TABLE OF stpox,
        ls_mat_bom_cs03_a TYPE /cideon/stpos_cs03_a,
        ls_mat_bom_cs03_d TYPE /cideon/stpos_cs03_d,
        ls_mat_bom_cs03_m TYPE /cideon/stpos_cs03_m,
        ls_mat_bom_cs11 TYPE /cideon/stpos_cs11,
        ls_mat_bom_cs12 TYPE /cideon/stpos_cs12,
        ls_mat_bom_cs13 TYPE /cideon/stpos_cs13,
        lp_doknr TYPE doknr,
        anz_stufe(11)  TYPE c,
        lp_stufe TYPE i.

  IF bom_print-explv = 0.
    lp_stufe = 99.
  ELSE.
    lp_stufe = bom_print-explv.
  ENDIF.

  CASE bom_print-bomtype.
    WHEN 'CS03'.
* CS03 ist unabhängig von den Benutzereinstellungen immer nur Stufe 1
      CASE bom_print-bomausp.
        WHEN 'A'.
          CLEAR: ls_stpox, ls_mat_bom_cs03_a.
          LOOP AT mat_bom_i INTO ls_stpox.
            CHECK ls_stpox-stufe = 1.
            MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs03_a.
            SELECT SINGLE obtsp FROM tcs21 INTO ls_mat_bom_cs03_a-obtsp
            WHERE spras = bom_print-spras
            AND   objty = ls_stpox-objty.

            IF ls_stpox-objty = '2'.
              ls_mat_bom_cs03_a-ktext = ls_stpox-potx1.
            ELSE.
              CALL FUNCTION 'ITM_BOMOB_PROVIDE'
                   EXPORTING
                        i_objty = ls_stpox-objty
                        i_idnrk = ls_stpox-idnrk
                        i_dokar = ls_stpox-dokar
                        i_doknr = ls_stpox-doknr
                        i_doktl = ls_stpox-doktl
                        i_dokvr = ls_stpox-dokvr
                        i_klart = ls_stpox-klart
                        i_class = ls_stpox-class
                   IMPORTING
                        e_bomob = ls_mat_bom_cs03_a-bomob.

              CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
                   EXPORTING
                        i_postp = ls_stpox-postp
                        i_objty = ls_stpox-objty
                        i_idnrk = ls_stpox-idnrk
                        i_dokar = ls_stpox-dokar
                        i_doknr = ls_stpox-doknr
                        i_doktl = ls_stpox-doktl
                        i_dokvr = ls_stpox-dokvr
                        i_klart = ls_stpox-klart
                        i_class = ls_stpox-class
                        i_spras = bom_print-spras
                   IMPORTING
                        e_ktext = ls_mat_bom_cs03_a-ktext.
            ENDIF.

            IF NOT ls_stpox-itmid IS INITIAL.
              ls_mat_bom_cs03_a-ident = ls_stpox-itmid.
            ELSE.
              ls_mat_bom_cs03_a-ident = ls_stpox-stvkn.
            ENDIF.
            IF NOT ls_stpox-xtlnr IS INITIAL.
              ls_mat_bom_cs03_a-stlkz = b_flag.
            ENDIF.

            APPEND ls_mat_bom_cs03_a TO mat_bom_cs03_a.
            CLEAR ls_mat_bom_cs03_a.
          ENDLOOP.


        WHEN 'M'.
          CLEAR: ls_stpox, ls_mat_bom_cs03_m.
          LOOP AT mat_bom_i INTO ls_stpox.
            CHECK ls_stpox-stufe = 1.
            MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs03_m.
            CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
                 EXPORTING
                      i_postp = ls_stpox-postp
                      i_objty = ls_stpox-objty
                      i_idnrk = ls_stpox-idnrk
                      i_dokar = ls_stpox-dokar
                      i_doknr = ls_stpox-doknr
                      i_doktl = ls_stpox-doktl
                      i_dokvr = ls_stpox-dokvr
                      i_klart = ls_stpox-klart
                      i_class = ls_stpox-class
                      i_spras = bom_print-spras
                 IMPORTING
                      e_ktext = ls_mat_bom_cs03_m-ktext.

            IF NOT ls_stpox-itmid IS INITIAL.
              ls_mat_bom_cs03_m-ident = ls_stpox-itmid.
            ELSE.
              ls_mat_bom_cs03_m-ident = ls_stpox-stvkn.
            ENDIF.
            IF NOT ls_stpox-xtlnr IS INITIAL.
              ls_mat_bom_cs03_m-stlkz = b_flag.
            ENDIF.
            APPEND ls_mat_bom_cs03_m TO mat_bom_cs03_m.
            CLEAR ls_mat_bom_cs03_m.
          ENDLOOP.

        WHEN 'D'.
          CLEAR: ls_stpox, ls_mat_bom_cs03_d.
          LOOP AT mat_bom_i INTO ls_stpox.
            CHECK ls_stpox-stufe = 1.
            MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs03_d.
            CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
                 EXPORTING
                      i_postp = ls_stpox-postp
                      i_objty = ls_stpox-objty
                      i_idnrk = ls_stpox-idnrk
                      i_dokar = ls_stpox-dokar
                      i_doknr = ls_stpox-doknr
                      i_doktl = ls_stpox-doktl
                      i_dokvr = ls_stpox-dokvr
                      i_klart = ls_stpox-klart
                      i_class = ls_stpox-class
                      i_spras = bom_print-spras
                 IMPORTING
                      e_ktext = ls_mat_bom_cs03_d-ktext.
            IF NOT ls_stpox-itmid IS INITIAL.
              ls_mat_bom_cs03_d-ident = ls_stpox-itmid.
            ELSE.
              ls_mat_bom_cs03_d-ident = ls_stpox-stvkn.
            ENDIF.
            IF NOT ls_stpox-xtlnr IS INITIAL.
              ls_mat_bom_cs03_d-stlkz = b_flag.
            ENDIF.
            APPEND ls_mat_bom_cs03_d TO mat_bom_cs03_d.
            CLEAR ls_mat_bom_cs03_d.
          ENDLOOP.
      ENDCASE.
    WHEN 'CS11'.
*    erst Struktur zusammenstellen!!
      CLEAR: ls_stpox.
      CLEAR: hd_tab.
      REFRESH hd_tab.

      CLEAR ls_stpox.
      LOOP AT mat_bom_i INTO ls_stpox.
        APPEND ls_stpox TO lt_stpox.
      ENDLOOP.
      CLEAR ls_stpox.
      LOOP AT lt_stpox INTO ls_stpox.

        IF NOT ls_stpox-hdnfo IS INITIAL.
          EXIT.
        ELSE.
        ENDIF.
        READ TABLE hd_tab
        WITH KEY stufe = ls_stpox-stufe
                 vwegx = ls_stpox-vwegx
        BINARY SEARCH
        TRANSPORTING NO FIELDS.

*     ?gibt es diesen Satz schon
*     nein
        IF sy-subrc <> 0.
          hd_tab-stufe = ls_stpox-stufe.
          hd_tab-vwegx = ls_stpox-vwegx.
          INSERT hd_tab
            INTO hd_tab
            INDEX sy-tabix.

*        PosNr initialisieren
          CLEAR: ls_stpox-posnr.
*        SFP-InfosatzKz setzen
          ls_stpox-hdnfo = 'X'.
          ls_stpox-objty = '1'.
*        als SFP-Infosatz in die STB aufnehmen
          APPEND ls_stpox TO lt_stpox.
        ENDIF.
      ENDLOOP.
*  STB sortieren (Baukasten)
      SORT lt_stpox ASCENDING BY stufe
               index ASCENDING
               posnr ASCENDING
               hdnfo DESCENDING.

*     dann alle Daten zusammensammeln
      CLEAR: ls_stpox, ls_mat_bom_cs11.
      LOOP AT lt_stpox INTO ls_stpox.
        CHECK ls_stpox-stufe <= lp_stufe.
        MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs11.

        IF NOT ls_stpox-hdnfo IS INITIAL.
          CHECK ls_stpox-stufe > 1.
          ls_stpox-stufe = ls_stpox-stufe - 1.
          ls_stpox-ojtxp = ls_stpox-ojtxb.
          CLEAR ls_mat_bom_cs11-meins.
          CLEAR ls_mat_bom_cs11-mngko.
          READ TABLE lt_stpox INTO ls_stpox_temp
          WITH KEY stufe = ls_stpox-stufe
                   ojtxp = ls_stpox-ojtxb
                   xtlnr = ls_stpox-stlnr.
          ls_stpox-idnrk = ls_stpox_temp-idnrk.
        ELSE.
          IF ls_stpox-mngko >= max_num.
            ls_mat_bom_cs11-ovfls = ueberl_kz.
          ELSE.
            IF ls_stpox-mngko <= min_num.
              ls_mat_bom_cs11-ovfls = ueberl_kz.
            ELSE.
              CLEAR: ls_mat_bom_cs11-ovfls.
            ENDIF.
          ENDIF.

          IF NOT ls_stpox-xtlnr IS INITIAL.
            ls_mat_bom_cs11-bomfl = b_flag.
          ENDIF.
        ENDIF.
        CLEAR: ls_mat_bom_cs11-dobjt,
               ls_mat_bom_cs11-objic.

        CASE ls_stpox-objty.
          WHEN '1'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs11-dobjt.
            ls_mat_bom_cs11-objic = 'M'.                    "@A6@'.

          WHEN 'M'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs11-dobjt.
            ls_mat_bom_cs11-objic = 'M'.                    "@A6@'.

          WHEN '2'.
            WRITE: ls_stpox-potx1 TO ls_mat_bom_cs11-dobjt.
            ls_mat_bom_cs11-objic = 'T'.                    "@0Q@'.

          WHEN '3'.
*            WRITE ls_stpox-doknr TO ls_mat_bom_cs11-dobjt.
*            sy-fdpos = sy-fdpos + 1.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                 EXPORTING
                      input  = ls_stpox-doknr
                 IMPORTING
                      output = lp_doknr.

            CONCATENATE
              lp_doknr
              ls_stpox-dokar
              ls_stpox-doktl
              ls_stpox-dokvr
              INTO ls_mat_bom_cs11-dobjt      "+sy-fdpos
                 SEPARATED BY space.
            ls_mat_bom_cs11-objic = 'D'. "@AR@'.

          WHEN '4'.
            CONCATENATE
              ls_stpox-class
              ls_stpox-klart
              INTO ls_mat_bom_cs11-dobjt
              SEPARATED BY space.
            ls_mat_bom_cs11-objic = 'C'.                    "@7C@'.

          WHEN '5'.
            WRITE: ls_stpox-intrm TO ls_mat_bom_cs11-dobjt.

          WHEN OTHERS.
        ENDCASE.
        WRITE ls_stpox-stufe TO ls_mat_bom_cs11-dstuf NO-SIGN.
        CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
          EXPORTING
            i_postp = ls_stpox-postp
            i_objty = ls_stpox-objty
            i_idnrk = ls_stpox-idnrk
            i_dokar = ls_stpox-dokar
            i_doknr = ls_stpox-doknr
            i_doktl = ls_stpox-doktl
            i_dokvr = ls_stpox-dokvr
            i_klart = ls_stpox-klart
            i_class = ls_stpox-class
            i_spras = bom_print-spras
*           I_POTPR       =
*           I_POTX1       =
*           I_ROMS1       =
*           I_ROMS2       =
*           I_ROMS3       =
*           I_ROMEI       =
*           I_RFORM       =
        IMPORTING
            e_ktext = ls_mat_bom_cs11-ojtxp.
*           E_OBKTX       =


        APPEND ls_mat_bom_cs11 TO gt_mat_bom_cs11.
        CLEAR: ls_stpox, ls_mat_bom_cs11.
      ENDLOOP.

    WHEN 'CS12'.
      CLEAR: ls_stpox, ls_mat_bom_cs12.
      LOOP AT mat_bom_i INTO ls_stpox.
        CHECK ls_stpox-stufe <= lp_stufe.
        MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs12.
        IF ls_stpox-mngko >= max_num.
          ls_mat_bom_cs12-ovfls = ueberl_kz.
        ELSE.
          IF ls_stpox-mngko <= min_num.
            ls_mat_bom_cs12-ovfls = ueberl_kz.
          ELSE.
            CLEAR: ls_mat_bom_cs12-ovfls.
          ENDIF.
        ENDIF.

        IF NOT ls_stpox-xtlnr IS INITIAL.
          ls_mat_bom_cs12-bomfl = b_flag.
        ENDIF.
        CLEAR: ls_mat_bom_cs12-dobjt,
               ls_mat_bom_cs12-objic.

        CASE ls_stpox-objty.
          WHEN '1'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs12-dobjt.
            ls_mat_bom_cs12-objic = 'M'.                    "@A6@'.

          WHEN 'M'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs12-dobjt.
            ls_mat_bom_cs12-objic = 'M'.                    "@A6@'.

          WHEN '2'.
            WRITE: ls_stpox-potx1 TO ls_mat_bom_cs12-dobjt.
            ls_mat_bom_cs12-objic = 'T'.                    "@0Q@'.

          WHEN '3'.
*            WRITE ls_stpox-doknr TO ls_mat_bom_cs12-dobjt.
*            sy-fdpos = sy-fdpos + 1.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                 EXPORTING
                      input  = ls_stpox-doknr
                 IMPORTING
                      output = lp_doknr.

            CONCATENATE
              lp_doknr
              ls_stpox-dokar
              ls_stpox-doktl
              ls_stpox-dokvr
              INTO ls_mat_bom_cs12-dobjt     "+sy-fdpos
                 SEPARATED BY space.
            ls_mat_bom_cs12-objic = 'D'. "@AR@'.

          WHEN '4'.
            CONCATENATE
              ls_stpox-class
              ls_stpox-klart
              INTO ls_mat_bom_cs12-dobjt
              SEPARATED BY space.
            ls_mat_bom_cs12-objic = 'C'.                    "@7C@'.

          WHEN '5'.
            WRITE: ls_stpox-intrm TO ls_mat_bom_cs12-dobjt.

          WHEN OTHERS.
        ENDCASE.

        anz_stufe = ls_stpox-stufe.
        TRANSLATE anz_stufe USING ' .'.
        anz_stufe+10(1) = ' '.

        IF ls_stpox-stufe < 9.
          ls_stpox-stufe = 9 - ls_stpox-stufe.
          SHIFT anz_stufe BY ls_stpox-stufe PLACES.
          ls_stpox-stufe = 9 - ls_stpox-stufe.
        ENDIF.
        WRITE anz_stufe TO ls_mat_bom_cs12-dglvl NO-SIGN.
        CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
          EXPORTING
            i_postp = ls_stpox-postp
            i_objty = ls_stpox-objty
            i_idnrk = ls_stpox-idnrk
            i_dokar = ls_stpox-dokar
            i_doknr = ls_stpox-doknr
            i_doktl = ls_stpox-doktl
            i_dokvr = ls_stpox-dokvr
            i_klart = ls_stpox-klart
            i_class = ls_stpox-class
            i_spras = bom_print-spras
*           I_POTPR       =
*           I_POTX1       =
*           I_ROMS1       =
*           I_ROMS2       =
*           I_ROMS3       =
*           I_ROMEI       =
*           I_RFORM       =
        IMPORTING
            e_ktext = ls_mat_bom_cs12-ojtxp.
*           E_OBKTX       =

        APPEND ls_mat_bom_cs12 TO mat_bom_cs12.
        CLEAR ls_mat_bom_cs12.
      ENDLOOP.

    WHEN 'CS13'.

      DATA: mat_bom_cs13_coll TYPE HASHED TABLE OF /cideon/stpos_cs13
            WITH UNIQUE KEY objic dobjt ojtxp ovfls sumkz meins.
      DATA: mat_bom_cs13_sum TYPE TABLE OF /cideon/stpos_cs13,
            lines_bevor TYPE i,
            lines_after TYPE i.

      CLEAR: ls_stpox, ls_mat_bom_cs13.
      SORT mat_bom_i ASCENDING BY objty
              idnrk ASCENDING
              dokar ASCENDING
              doknr ASCENDING
              dokvr ASCENDING
              doktl ASCENDING
              ojtxp ASCENDING
              potx1 ASCENDING
              potx2 ASCENDING
              sortf ASCENDING
              sumkz ASCENDING.

      LOOP AT mat_bom_i INTO ls_stpox.
        CHECK ls_stpox-stufe <= lp_stufe.
        CHECK ls_stpox-xtlnr IS INITIAL.
        MOVE-CORRESPONDING ls_stpox TO ls_mat_bom_cs13.

        CALL FUNCTION '/CIDEON/ITM_KTEXT_PROVIDE'
          EXPORTING
            i_postp = ls_stpox-postp
            i_objty = ls_stpox-objty
            i_idnrk = ls_stpox-idnrk
            i_dokar = ls_stpox-dokar
            i_doknr = ls_stpox-doknr
            i_doktl = ls_stpox-doktl
            i_dokvr = ls_stpox-dokvr
            i_klart = ls_stpox-klart
            i_class = ls_stpox-class
            i_spras = bom_print-spras
*           I_POTPR       =
*           I_POTX1       =
*           I_ROMS1       =
*           I_ROMS2       =
*           I_ROMS3       =
*           I_ROMEI       =
*           I_RFORM       =
        IMPORTING
            e_ktext = ls_mat_bom_cs13-ojtxp.
*           E_OBKTX       =

        CLEAR: ls_mat_bom_cs13-dobjt,
               ls_mat_bom_cs13-objic.

        CASE ls_stpox-objty.
          WHEN '1'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs13-dobjt.
            ls_mat_bom_cs13-objic = 'M'.                    "@A6@'.

          WHEN 'M'.
            WRITE: ls_stpox-idnrk TO ls_mat_bom_cs13-dobjt.
            ls_mat_bom_cs13-objic = 'M'.                    "@A6@'.

          WHEN '2'.
            WRITE: ls_stpox-potx1 TO ls_mat_bom_cs13-dobjt.
            ls_mat_bom_cs13-objic = 'T'.                    "@0Q@'.

          WHEN '3'.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                 EXPORTING
                      input  = ls_stpox-doknr
                 IMPORTING
                      output = lp_doknr.

            CONCATENATE
              lp_doknr
              ls_stpox-dokar
              ls_stpox-doktl
              ls_stpox-dokvr
              INTO ls_mat_bom_cs13-dobjt  "+sy-fdpos
                 SEPARATED BY space.
            ls_mat_bom_cs13-objic = 'D'. "@AR@'.

          WHEN '4'.
            CONCATENATE
              ls_stpox-class
              ls_stpox-klart
              INTO ls_mat_bom_cs13-dobjt
              SEPARATED BY space.
            ls_mat_bom_cs13-objic = 'C'.                    "@7C@'.

          WHEN '5'.
            WRITE: ls_stpox-intrm TO ls_mat_bom_cs13-dobjt.

          WHEN OTHERS.
        ENDCASE.
        CLEAR: lines_bevor, lines_after.
        DESCRIBE TABLE mat_bom_cs13_coll LINES lines_bevor.
        COLLECT ls_mat_bom_cs13 INTO mat_bom_cs13_coll.
        DESCRIBE TABLE mat_bom_cs13_coll LINES lines_after.
        IF lines_bevor = lines_after.
          APPEND ls_mat_bom_cs13 TO mat_bom_cs13_sum.
        ENDIF.
        CLEAR ls_mat_bom_cs13.
      ENDLOOP.

      CLEAR ls_mat_bom_cs13.
      LOOP AT mat_bom_cs13_coll INTO ls_mat_bom_cs13.
        IF ls_stpox-mngko >= max_num.
          ls_mat_bom_cs13-ovfls = ueberl_kz.
        ELSE.
          IF ls_stpox-mngko <= min_num.
            ls_mat_bom_cs13-ovfls = ueberl_kz.
          ELSE.
            CLEAR: ls_mat_bom_cs13-ovfls.
          ENDIF.
        ENDIF.
        READ TABLE mat_bom_cs13_sum
        WITH KEY objic = ls_mat_bom_cs13-objic
                 dobjt = ls_mat_bom_cs13-dobjt
                 ojtxp = ls_mat_bom_cs13-ojtxp
                 TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          ls_mat_bom_cs13-sumkz = '*'.
        ENDIF.

        APPEND ls_mat_bom_cs13 TO mat_bom_cs13.
        CLEAR ls_mat_bom_cs13.
      ENDLOOP.
  ENDCASE.

ENDFUNCTION.
