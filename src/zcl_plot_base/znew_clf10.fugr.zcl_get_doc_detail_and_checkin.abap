FUNCTION ZCL_GET_DOC_DETAIL_AND_CHECKIN .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKST) LIKE  DRAW-DOKST DEFAULT 'FR'
*"  TABLES
*"      ITAB_DRAW STRUCTURE  DRAW OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : wa_draw TYPE draw,
         flag_sapdb TYPE c.

  DATA : itab_doc_files2 TYPE TABLE OF bapi_doc_files2,
         wa_doc_files2   TYPE          bapi_doc_files2.

  DATA : itab_checkin_doc_files2 TYPE TABLE OF bapi_doc_files2,
         wa_checkin_doc_files2   TYPE          bapi_doc_files2.

  DATA : lv_sapdb LIKE bapi_doc_files2-storagecategory.

  DATA : it1_bapiret2 TYPE bapiret2.

  LOOP AT itab_draw INTO wa_draw WHERE dokst NE i_dokst.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_draw-dokar
        documentnumber             = wa_draw-doknr
        documentpart               = wa_draw-doktl
        documentversion            = wa_draw-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
*     IMPORTING
*       DOCUMENTDATA               =
*       RETURN                     =
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
        documentfiles              = itab_doc_files2
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .


    LOOP AT itab_doc_files2 INTO wa_doc_files2.

      IF flag_sapdb IS INITIAL
          AND NOT ( wa_doc_files2-storagecategory IS INITIAL ).

        MOVE wa_doc_files2-storagecategory TO lv_sapdb.
        flag_sapdb = 'X'.

      ELSE.

        MOVE 'Z_CID_CS' TO lv_sapdb.
        flag_sapdb = 'X'.

      ENDIF.

      IF ( wa_doc_files2-storagecategory EQ space OR
           wa_doc_files2-checkedin EQ space ).

        MOVE lv_sapdb TO wa_doc_files2-storagecategory.

        REFRESH itab_checkin_doc_files2.

        APPEND wa_doc_files2 TO itab_checkin_doc_files2.

        CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN2'
          EXPORTING
            documenttype            = wa_draw-dokar
            documentnumber          = wa_draw-doknr
            documentpart            = wa_draw-doktl
            documentversion         = wa_draw-dokvr
*           HOSTNAME                = ' '
*           STATUSINTERN            = ' '
*           statusextern            = lv_statusintern
*           STATUSLOG               = ' '
*           REVLEVEL                = ' '
*           AENNR                   = ' '
          IMPORTING
            return                  = it1_bapiret2
          TABLES
            documentfiles           = itab_checkin_doc_files2
*           COMPONENTS              =
*           DOCUMENTSTRUCTURE       =
                  .


        WAIT UP TO 3 SECONDS.

        COMMIT WORK.

        IF it1_bapiret2-id IS INITIAL.
          COMMIT WORK.
        ELSE.
          MESSAGE e058(zcvn) WITH 'IT1_BAPIRET2'
                                  it1_bapiret2-type
                                  it1_bapiret2-id
                                  it1_bapiret2-message.
        ENDIF.

      ENDIF.

    ENDLOOP.

    CLEAR it1_bapiret2.

  ENDLOOP. "If the status of the Document is 'FR'.


ENDFUNCTION.
