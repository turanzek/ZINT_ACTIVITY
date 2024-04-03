*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINT_T_ACT_PROJE................................*
DATA:  BEGIN OF STATUS_ZINT_T_ACT_PROJE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINT_T_ACT_PROJE              .
CONTROLS: TCTRL_ZINT_T_ACT_PROJE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINT_T_ACT_PROJE              .
TABLES: ZINT_T_ACT_PROJE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
