class ZCL_INT_ACT_HR_HELPER definition
  public
  final
  create public .

public section.

  class-methods GET_PERSON_FROM_UNAME
    importing
      !IV_UNAME type UNAME
    returning
      value(RS_PA0001) type PA0001 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT_ACT_HR_HELPER IMPLEMENTATION.


  METHOD GET_PERSON_FROM_UNAME.

    SELECT SINGLE p~* INTO CORRESPONDING FIELDS OF @rs_pa0001
                      FROM pa0001 AS p
    JOIN pa0105 AS a ON a~pernr = p~pernr
                     WHERE a~usrid = @iv_uname
                       AND a~usrty = '0001'
                       AND p~begda LE @sy-datum AND
                           p~endda GE @sy-datum AND
                           a~begda LE @sy-datum AND
                           a~endda GE @sy-datum .



  ENDMETHOD.
ENDCLASS.
