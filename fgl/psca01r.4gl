----------------------------------------------------------------------------
-- 程 式 名 稱：psca01r
-- 處 理 概 要：SR140800458 針對曾經執行過未回領取（R5 R6)之還本帳務，
--              比對檢查支票作廢作業
----------------------------------------------------------------------------
-- memo 
DATABASE life 

   GLOBALS "../def/common.4gl"
   GLOBALS "../def/lf.4gl"
   GLOBALS "../def/report.4gl"
   GLOBALS "../def/omsg.4gl"
   GLOBALS "../def/disburst.4gl"
   GLOBALS "../def/pscgcpn.4gl"

   DEFINE p_psck        RECORD LIKE psck.*
MAIN 
   
   CALL psca01r_from_psck()
   
END MAIN 

FUNCTION psca01r_from_psck()
   DEFINE f_err         INTEGER 
   DEFINE f_err_msg     CHAR(60)
   DEFINE f_nonresp_sw  CHAR(1)
   DEFINE f_echo        CHAR(250)

   LET f_echo = "rm psca01r.out"
   RUN f_echo
   LET f_echo = "rm psca01r.out2"
   RUN f_echo 

   DECLARE psck_cur CURSOR WITH HOLD FOR 
      SELECT     a.* ,b.*
      FROM       psck a , polf b --,cmwangpsc c 
      WHERE      nonresp_sw = "Y"
      AND        a.policy_no = b.policy_no 
      AND        b.currency = "TWD"
--      AND        a.policy_no = c.policy_no 
--      AND        a.cp_anniv_date = c.cp_anniv_date
--       AND a.policy_no = "143100070748"
   FOREACH psck_cur INTO p_psck.* ,g_polf.*
      --**** g_polf ,( g_pscd|g_pscx ) ****--
      CALL psca02s01_load_pscd( p_psck.policy_no ,p_psck.cp_anniv_date )
      --**** 檢核 ****--
      CALL psca02s00( p_psck.cp_anniv_date ) RETURNING f_err        ,
                                                       f_err_msg    ,
                                                       f_nonresp_sw
LET f_echo = "echo ",p_psck.policy_no,"-",p_psck.cp_anniv_date,"-",g_polf.po_sts_code,"-",f_err_msg CLIPPED ," >> psca01r.out2"
RUN f_echo  
      IF f_err = 1 THEN 
         LET f_err_msg = "call psca02s00: ",f_err_msg CLIPPED
         CALL psca01r_err( f_err_msg )
         CONTINUE FOREACH
      END IF 
      --**** 更新psck ****--
      IF f_nonresp_sw = "N" THEN
         CALL psca01r_update_psck( f_nonresp_sw )
      END IF 

   END FOREACH -- psck_cur END 
END FUNCTION -- psca01r_from_psck END 

FUNCTION psca01r_load_pscd_pscx() 
   DEFINE i        INTEGER 
   
   FOR i = 1 TO 50 
       INITIALIZE g_pscd[i] TO NULL 
       INITIALIZE g_pscx[i] TO NULL
   END FOR 
   LET i = 1  
   IF g_polf.currency = "TWD" THEN 
      DECLARE pscd_cur CURSOR WITH HOLD FOR 
         SELECT    * 
         FROM      pscd 
         WHERE     policy_no     = p_psck.policy_no 
         AND       cp_anniv_date = p_psck.cp_anniv_date
      FOREACH pscd_cur INTO g_pscd[i].*
         LET i = i + 1
      END FOREACH 
      RETURN 
   END IF 
   DECLARE pscx_cur CURSOR WITH HOLD FOR 
      SELECT    *
      FROM      pscx 
      WHERE     policy_no     = p_psck.policy_no 
      AND       cp_anniv_date = p_psck.cp_anniv_date 
   FOREACH pscx_cur INTO g_pscx[i].*
      LET i = i + 1   
   END FOREACH
   RETURN  
END FUNCTION -- psca01r_load_pscd_pscx END 

FUNCTION psca01r_update_psck( f_nonresp_sw )
   DEFINE f_nonresp_sw     CHAR(1)
DEFINE f_echo         CHAR(250)

   IF f_nonresp_sw = "Y" THEN 
      RETURN 
   END IF

LET f_echo = "echo ",p_psck.policy_no,"-",p_psck.cp_anniv_date ," >> psca01r.out"
RUN f_echo

   WHENEVER ERROR CONTINUE 
   BEGIN WORK 
      UPDATE psck
      SET    nonresp_sw = f_nonresp_sw
      WHERE  policy_no = p_psck.policy_no 
      AND    cp_anniv_date = p_psck.cp_anniv_date 
      IF SQLCA.SQLCODE <> 0 THEN
         ROLLBACK WORK 
         CALL psca01r_err( " update psck error " )
      END IF 
   COMMIT WORK 
   WHENEVER ERROR STOP

END FUNCTION --psca01r_update_psck END

FUNCTION psca01r_err( f_msg )
   DEFINE f_msg           CHAR(500)
   
   DISPLAY "ERROR: ","|",
           p_psck.policy_no ,"|",
           p_psck.cp_anniv_date ,"|",
           g_polf.po_sts_code ,"|",
           f_msg CLIPPED           

END FUNCTION --psca01r_err END 
