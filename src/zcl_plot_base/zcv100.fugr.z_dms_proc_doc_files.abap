FUNCTION z_dms_proc_doc_files.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CALLED_FROM) TYPE  DMS_PROC01-PROC_TYPE OPTIONAL
*"     REFERENCE(TESTMODE) TYPE  C OPTIONAL
*"  TABLES
*"      IT_ZORI_DOC_FILES STRUCTURE  ZORI_DOC_FILES OPTIONAL
*"      IT_BAPI_DOC_FILES2 STRUCTURE  BAPI_DOC_FILES2 OPTIONAL
*"      TDRAW STRUCTURE  DRAW OPTIONAL
*"      ITAB_FILETYPE STRUCTURE  TDWP OPTIONAL
*"      IT_FAIL_DOCUMENT STRUCTURE  ZCL_S_FAIL_DOCUMENT OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      ABORT
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*& Function Group  : ZCV100                                           &*
*& Function Module : Z_DMS_PROC_DOC_FILES                             &*
*& Author          : Srinivas.Mamillapalli@CIDEON.de                  &*
*&--------------------------------------------------------------------&*
*& This Function Module creates the detailed table for the those docs &*
*& that were selected from the DRAW table and selected into internal  &*
*& table TDRAW the and send as IT_ZORI_DOC_FILES & IT_BAPI_DOC_FILES2 &*
*& But these Details will be processed only for those documents that  &*
*& are with the Work Station Application Types that were defines in   &*
*& ITAB_FILETYPE. If selected Documents Does not have the FileTypes   &*
*& they will be send into Internal Table IT_FAIL_DOCUMENT.            &*
*&--------------------------------------------------------------------&*
* Änderungen:  - Christoph Küchler
*                Chris@christoph-kuechler.de
* 15.12.2003 - weitere Felder aus Dokumenten mitgeben
*
*&--------------------------------------------------------------------&*
* Änderungen:  - Dr. Peter Rabe
*                Peter.Rabe@cideon.de
* 25.02.2004 - Auswahl CAD-Applikation über F4-FB mit Multiselect
*
* 7.0.159.1
* 2012/02/15
* BUG 8046
* Nicht alle Originale werden im Control Center von der Such
* in die Plotliste übernommen
* FB Z_DMS_PROC_DOC_FILES
*
*&--------------------------------------------------------------------&*

  DATA: flag TYPE c,
        ind_cont,
        incr TYPE n.

  DATA: zdate(10) TYPE c,
        ztime(8) TYPE c.

  DATA: tdrad           TYPE drad           OCCURS 0 WITH HEADER LINE.

  DATA: bapi_doc_draw2  TYPE bapi_doc_draw2 OCCURS 0 WITH HEADER LINE,
        bapiret2        TYPE bapiret2       OCCURS 0 WITH HEADER LINE,
        bapi_doc_tdwa   TYPE bapi_doc_tdwa  OCCURS 0 WITH HEADER LINE,
        t1_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0
                                                     WITH HEADER LINE,
        t2_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0
                                                     WITH HEADER LINE,
        t1_zori_doc_files TYPE zori_doc_files OCCURS 0
                                                     WITH HEADER LINE.
  DATA : docfile LIKE bapi_doc_files2-docfile.


  IF flag IS INITIAL.

    IF itab_filetype[] IS INITIAL.

* 25.02.2004 Beginn
*      CALL SCREEN 0100 STARTING AT 1 1 ENDING AT 60 25.
      PERFORM multisel_tdwp.
* 25.02.2004 Ende
      flag = 'X'.
      IF g_flag_exit = 'X'.
        REFRESH it_zori_doc_files.
        REFRESH it_bapi_doc_files2.
        RAISE abort.
        EXIT.
      ELSE.
* 11.02.2003 Beginn
        LOOP AT it_tdwp.
          MOVE-CORRESPONDING it_tdwp TO itab_filetype.
          APPEND itab_filetype.
        ENDLOOP.
* 11.02.2003 Ende
      ENDIF.
    ELSE.
      LOOP AT itab_filetype.
        MOVE-CORRESPONDING itab_filetype TO it_tdwp.
        APPEND it_tdwp.
      ENDLOOP.
      flag = 'X'.

    ENDIF.
    CLEAR itab_filetype.
  ENDIF.


  LOOP AT tdraw.

    CLEAR: ind_cont.

    IF ind_cont IS INITIAL.

      REFRESH tdrad.

      SELECT * FROM drad INTO tdrad WHERE
                     dokar = tdraw-dokar
                 AND doknr = tdraw-doknr
                 AND doktl = tdraw-doktl
                 AND dokvr = tdraw-dokvr.

        APPEND tdrad.

      ENDSELECT.

*  Get the complete details of the documents that R selected.
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
        EXPORTING
          documenttype               = tdraw-dokar
          documentnumber             = tdraw-doknr
          documentpart               = tdraw-doktl
          documentversion            = tdraw-dokvr
*         GETOBJECTLINKS             = ' '
*         GETCOMPONENTS              = ' '
*         GETSTATUSLOG               = ' '
*         GETLONGTEXTS               = ' '
*         GETACTIVEFILES             = 'X'
        IMPORTING
          documentdata               = bapi_doc_draw2
          return                     = bapiret2
        TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
          documentfiles              = t1_bapi_doc_files2
*         COMPONENTS                 =
                .

      CLEAR bapiret2.

* Move the values from the internal table t1_bapi_doc_files2 to
* t2_bapi_doc_files2 for the purpose of allowing to fill it again
* with other values and clear the internal table t1_bapi_doc_files2.
      LOOP AT t1_bapi_doc_files2.

        MOVE t1_bapi_doc_files2 TO t2_bapi_doc_files2.

        MOVE tdraw-dokar TO t2_bapi_doc_files2-documenttype.
        MOVE tdraw-doknr TO t2_bapi_doc_files2-documentnumber.
        MOVE tdraw-doktl TO t2_bapi_doc_files2-documentpart.
        MOVE tdraw-dokvr TO t2_bapi_doc_files2-documentversion.

        APPEND t2_bapi_doc_files2.
        DELETE t1_bapi_doc_files2.
        CLEAR t1_bapi_doc_files2.

      ENDLOOP.

      IF sy-subrc NE 0.
        MOVE tdraw-dokar TO it_fail_document-dokar.
        MOVE tdraw-doknr TO it_fail_document-doknr.
        MOVE tdraw-dokvr TO it_fail_document-dokvr.
        MOVE tdraw-doktl TO it_fail_document-doktl.
        MOVE 'X' TO it_fail_document-knz_kein_file.
        MOVE 'X' TO it_fail_document-knz_garkein_file.

        APPEND it_fail_document.
      ENDIF.

    ENDIF.
  ENDLOOP.

* Process from here only when there is some data available
* in the table t2_bapi_doc_files2.
  IF NOT ( t2_bapi_doc_files2[] IS INITIAL ).
    SORT t2_bapi_doc_files2 BY documentnumber.

*   Looping at the detatiled doc values where the WSA is a value
*   from the it_tdwp.
    CLEAR t2_bapi_doc_files2.
    LOOP AT t2_bapi_doc_files2 . "WHERE wsapplication = it_tdwp-dappl.

*     Looping at the selected Work Station Application(WSA) table .
      LOOP AT it_tdwp WHERE dappl = t2_bapi_doc_files2-wsapplication.

        incr = incr + 1.

        MOVE incr TO t1_zori_doc_files-cont.

        MOVE t2_bapi_doc_files2-documenttype
                           TO t1_zori_doc_files-dokar.
        MOVE t2_bapi_doc_files2-documentnumber
                           TO t1_zori_doc_files-doknr.
        MOVE t2_bapi_doc_files2-documentpart
                           TO t1_zori_doc_files-doktl.
        MOVE t2_bapi_doc_files2-documentversion
                           TO t1_zori_doc_files-dokvr.
        MOVE t2_bapi_doc_files2-originaltype
                           TO t1_zori_doc_files-cont.

        CONCATENATE t2_bapi_doc_files2-docpath t2_bapi_doc_files2-docfile
                                                             INTO docfile.

        MOVE docfile TO t2_bapi_doc_files2-docfile.

        MOVE t2_bapi_doc_files2-docfile
                           TO t1_zori_doc_files-filep.

        MOVE t2_bapi_doc_files2-checkedin
                           TO t1_zori_doc_files-checked.

*       weitere Felder mitgeben
*        t1_zori_doc_files-
*        = t2_bapi_doc_files2-.
        t1_zori_doc_files-originaltype
          = t2_bapi_doc_files2-originaltype.
        t1_zori_doc_files-sourcedatacarrie
          = t2_bapi_doc_files2-sourcedatacarrier.
        t1_zori_doc_files-storagecategory
          = t2_bapi_doc_files2-storagecategory.
        t1_zori_doc_files-wsapplication
          = t2_bapi_doc_files2-wsapplication.
        t1_zori_doc_files-application_id
          = t2_bapi_doc_files2-application_id.
        t1_zori_doc_files-file_id
          = t2_bapi_doc_files2-file_id.
        t1_zori_doc_files-description
          = t2_bapi_doc_files2-description.
        t1_zori_doc_files-language
          = t2_bapi_doc_files2-language.
        t1_zori_doc_files-active_version
                = t2_bapi_doc_files2-active_version.
        t1_zori_doc_files-created_at
                = t2_bapi_doc_files2-created_at.
        t1_zori_doc_files-changed_at
                = t2_bapi_doc_files2-changed_at.
* Problem mit SPs, kommt wahrscheinlich erst bei SP43/44/45
*        t1_zori_doc_files-created_by
*                = t2_bapi_doc_files2-created_by.
*        t1_zori_doc_files-changed_by
*                = t2_bapi_doc_files2-changed_by.
*        t1_zori_doc_files-content_descript
*                = t2_bapi_doc_files2-content_description.


*       Split the TIMESTAMP into date and time, as we need only date.
        SPLIT t2_bapi_doc_files2-created_at AT ' ' INTO zdate ztime.

        MOVE zdate TO t1_zori_doc_files-cdate.

        APPEND t1_zori_doc_files.

        MOVE t2_bapi_doc_files2 TO it_bapi_doc_files2.
        APPEND it_bapi_doc_files2.

        MOVE t1_zori_doc_files TO it_zori_doc_files.
        APPEND it_zori_doc_files.

        CLEAR : zdate, ztime.
        CLEAR it_zori_doc_files-cdate.

      ENDLOOP.

      IF sy-subrc NE 0.
        MOVE t2_bapi_doc_files2-documenttype
                                TO it_fail_document-dokar.
        MOVE t2_bapi_doc_files2-documentnumber
                                TO it_fail_document-doknr.
        MOVE t2_bapi_doc_files2-documentversion
                                TO it_fail_document-dokvr.
        MOVE t2_bapi_doc_files2-documentpart
                                TO it_fail_document-doktl.
        MOVE 'X'                TO it_fail_document-knz_kein_file.
        MOVE ' '                TO it_fail_document-knz_garkein_file.

        APPEND it_fail_document.
      ENDIF.

    ENDLOOP.

  ENDIF.

**...§§ Commented on 15.01.2003...begin..
*
* Sort the internal table to eliminate the dupllicate values.
* sort with this values and delete the duplicates.
  SORT it_fail_document[] ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_fail_document[]
                      COMPARING dokar
                                doknr
                                dokvr
                                doktl
                                knz_kein_file
                                knz_garkein_file.

* Sort the internal table to eliminate the dupllicate values.
* As here only Paths of the files (i.e filep) unique value
* sort with this values and delete the duplicates.
  SORT it_zori_doc_files[] BY dokar
                              doknr
                              dokvr
                              doktl
                              filep
                              checked.

*  DELETE ADJACENT DUPLICATES FROM it_zori_doc_files[]
*                      COMPARING dokar
*                                doknr
*                                dokvr
*                                doktl
*                                filep
*                                checked.

  DELETE ADJACENT DUPLICATES FROM it_zori_doc_files[]
                      COMPARING dokar
                                doknr
                                dokvr
                                doktl
                                filep
                                checked
                                wsapplication
                                .

* Sort the internal table to eliminate the dupllicate values.
* As here only Paths of the files (i.e docfile) unique value
* sort with this values and delete the duplicates.
  SORT it_bapi_doc_files2[] BY documenttype
                               documentnumber
                               documentversion
                               documentpart
                               docfile
                               checkedin.

*  DELETE ADJACENT DUPLICATES FROM it_bapi_doc_files2[]
*                    COMPARING documenttype
*                              documentnumber
*                              documentversion
*                              documentpart
*                              docfile
*                              checkedin.

  DELETE ADJACENT DUPLICATES FROM it_bapi_doc_files2[]
                    COMPARING documenttype
                              documentnumber
                              documentversion
                              documentpart
                              docfile
                              checkedin
                              wsapplication.

*...§§ Commented on 15.01.2003...begin..

  DATA: index_fail TYPE sy-tabix.

  LOOP AT it_fail_document.
    index_fail = sy-tabix.
    LOOP AT it_zori_doc_files WHERE dokar = it_fail_document-dokar
                              AND   doknr = it_fail_document-doknr
                              AND   dokvr = it_fail_document-dokvr
                              AND   doktl = it_fail_document-doktl.

      DELETE it_fail_document INDEX index_fail.
    ENDLOOP.
  ENDLOOP.

  CLEAR it_tdwp.
  REFRESH it_tdwp.
  CLEAR it_tdwp[].

ENDFUNCTION.
