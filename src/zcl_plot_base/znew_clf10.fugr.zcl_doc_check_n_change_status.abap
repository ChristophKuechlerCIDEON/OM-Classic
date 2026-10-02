FUNCTION zcl_doc_check_n_change_status .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKST) LIKE  DRAW-DOKST DEFAULT 'FR'
*"  EXPORTING
*"     VALUE(E_FLAGDB) TYPE  C
*"  TABLES
*"      ITAB_DRAW STRUCTURE  DRAW OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : wa_draw TYPE draw.

  DATA : itab_doc_files2 TYPE TABLE OF bapi_doc_files2,
         wa_doc_files2   TYPE          bapi_doc_files2.

  DATA : itab_doc_tdws TYPE TABLE OF bapi_doc_tdws,
         wa_doc_tdws   TYPE          bapi_doc_tdws.

  DATA : lv_docfile(59)  TYPE c,
         lv_statusextern LIKE draw-dokst,
         lv_statusintern LIKE draw-dokst.

  DATA : str1_bapiret2    TYPE bapiret2,
         str2_bapiret2    TYPE bapiret2,
         str3_bapiret2    TYPE bapiret2,
         str4_bapiret2    TYPE bapiret2.

  DATA : last_cooled_tab TYPE TABLE OF bapi_doc_files2.

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
        getactivefiles             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
      IMPORTING
*       DOCUMENTDATA               =
        return                     = str1_bapiret2
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

      IF ( wa_doc_files2-storagecategory IS INITIAL OR
           wa_doc_files2-checkedin       IS INITIAL ).

*       This means this file is not checkedin to the server.
*       There by Stop Further processing and come out of the program.
        MOVE 'X' TO e_flagdb.

        CLEAR lv_docfile.

        CONCATENATE wa_draw-dokar '/'
                    wa_draw-doknr '/'
                    wa_draw-doktl '/'
                    wa_draw-dokvr '/'
                    wa_doc_files2-originaltype    '/'
                    wa_doc_files2-storagecategory '/'
                    wa_doc_files2-wsapplication   '/'
                    wa_doc_files2-checkedin INTO  lv_docfile.

        MESSAGE e058(zcvn) WITH lv_docfile '' '' ''.

      ELSE.
        APPEND wa_doc_files2 TO last_cooled_tab.
      ENDIF.

    ENDLOOP.

    IF e_flagdb IS INITIAL.

      CALL FUNCTION 'BAPI_DOCUMENT_GETSTATUS'
        EXPORTING
          documenttype       = wa_draw-dokar
          documentnumber     = wa_draw-doknr
          documentpart       = wa_draw-doktl
          documentversion    = wa_draw-dokvr
        IMPORTING
          statusextern        = lv_statusintern
          statusintern        = lv_statusextern
*         STATUSDESCRIPTION  =
*         RETURN             =
                .

      IF ( lv_statusintern NE 'AR' AND lv_statusextern NE 'AR' ).

        CALL FUNCTION 'BAPI_DOCUMENT_GETSTATUSLIST'
          EXPORTING
            documenttype           = wa_draw-dokar
*           STATUSINTERN           = ' '
*           STATUSEXTERN           = ' '
*           GETSTATUSNETWORK       = ' '
          IMPORTING
            return                 = str2_bapiret2
          TABLES
            statuslist             = itab_doc_tdws
                  .

       LOOP AT itab_doc_tdws INTO wa_doc_tdws WHERE statusintern = 'AR'.

          CALL FUNCTION 'BAPI_DOCUMENT_SETSTATUS'
            EXPORTING
              documenttype       = wa_draw-dokar
              documentnumber     = wa_draw-doknr
              documentpart       = wa_draw-doktl
              documentversion    = wa_draw-dokvr
*             STATUSEXTERN       =
              statusintern       = wa_doc_tdws-statusintern
*             STATUSLOG          = ' '
            IMPORTING
              return             = str3_bapiret2
                    .

          COMMIT WORK.
          WAIT UP TO 3 SECONDS.

*          IF str3_bapiret2-id IS INITIAL.
*            COMMIT WORK.
*            WAIT UP TO 1 SECONDS.
*          ELSE.
*            MESSAGE e058(zcvn) WITH 'STR3_BAPIRET2'
*                                    str3_bapiret2-type
*                                    str3_bapiret2-id
*                                    str3_bapiret2-message.
*          ENDIF.


          CLEAR lv_statusextern.
          CLEAR lv_statusintern.

          CALL FUNCTION 'BAPI_DOCUMENT_GETSTATUS'
               EXPORTING
                    documenttype      = wa_draw-dokar
                    documentnumber    = wa_draw-doknr
                    documentpart      = wa_draw-doktl
                    documentversion   = wa_draw-dokvr
               IMPORTING
                    statusextern      = lv_statusextern
                    statusintern      = lv_statusintern
*                   STATUSDESCRIPTION =
*                   RETURN            =
                        .

        ENDLOOP.

      ENDIF.

      IF (  lv_statusintern EQ 'AR' AND lv_statusextern EQ 'AR' ).

        CALL FUNCTION 'BAPI_DOCUMENT_SETSTATUS'
          EXPORTING
            documenttype       = wa_draw-dokar
            documentnumber     = wa_draw-doknr
            documentpart       = wa_draw-doktl
            documentversion    = wa_draw-dokvr
            statusintern       = 'FR'
*           STATUSLOG          = ' '
          IMPORTING
            return             = str4_bapiret2
                .

        COMMIT WORK.
        WAIT UP TO 3 SECONDS.

*        IF str4_bapiret2-id IS INITIAL.
*          WAIT UP TO 3 SECONDS.
*          COMMIT WORK.
*        ELSE.
*          MESSAGE e058(zcvn) WITH 'IT4_BAPIRET2'
*                                  it4_bapiret2-type
*                                  it4_bapiret2-id
*                                  it4_bapiret2-message.
*        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.
