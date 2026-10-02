FUNCTION-POOL zck_konvertierunbg.           "MESSAGE-ID ..

DATA : itab_cid1 TYPE bapi_doc_files2  OCCURS 0 WITH HEADER LINE,
       wa_cid1 TYPE bapi_doc_files2.

DATA : BEGIN OF tab_cid2 ,
           number LIKE bapi_doc_files2-originaltype,
           filename LIKE bapi_doc_files2-docfile,
        END OF tab_cid2.

DATA : itab_tab_cid2 LIKE tab_cid2 OCCURS 0 WITH HEADER LINE,
       wa_tab_cid2 LIKE tab_cid2.
