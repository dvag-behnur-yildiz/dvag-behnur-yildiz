SET SCHEMA = 'T13AE'                                              
;                                                                 
SET CURRENT PATH = 'T13AE'                                        
;                                                                 
  SELECT                                                          
--*---------------ANFANG ---------------------------------------* 
  SUBSTR(COALESCE(FNDB0001('Vvs'),''), 1, 40)                     
  FROM SYSIBM.SYSDUMMY1                                           
;                                                                
  SELECT                                                          
--*---------------ANFANG ---------------------------------------* 
  SUBSTR(COALESCE(FNDB0001('Kl'),''), 1, 40)                     
  FROM SYSIBM.SYSDUMMY1                                           
;
 
  SELECT                                         
--*---------------ANFANG ------------------------
  SUBSTR(COALESCE(FNDB0001('Klaus'),''), 1, 40)  
  FROM SYSIBM.SYSDUMMY1                          
;      