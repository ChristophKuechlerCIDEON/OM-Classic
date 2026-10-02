FUNCTION-POOL /cideon/cfx_base.             "MESSAGE-ID ..


DATA: ok_code               TYPE sy-ucomm.


* global data for dynpro '1200' and the filter administration

* global data for dynpro '1400' and the upload to cfolders
DATA: radio_1(1)  TYPE c,
      radio_2(1)  TYPE c,
      cfol_field01  TYPE text50,
      cfol_field02  TYPE text50,
      cfol_field03  TYPE text50,
      cfol_field04  TYPE text50.
