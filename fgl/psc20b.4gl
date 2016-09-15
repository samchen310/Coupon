------------------------------------------------------------------------------
--  程式名稱: psc20b.4gl
--  作    者: Kobe
--  日    期: 092/12/12
--  處理概要: 月處理前, 針對可能還本保單且受益人檔未留存匯款帳號者, 將符合
--            條件的帳號寫入受益人檔, 以利還本主動電匯作業
------------------------------------------------------------------------------
--  修改目的: 處理範圍排除保單號碼開頭為 "6", "8", "9"
--  修改日期: 093/04/23
--  修 改 者: Kobe
------------------------------------------------------------------------------
--  修改目的: 依據需求單號PS99419S,調整主動電匯帳號抓取規則
--            順位1:有效約定帳號
--            順位2:前一次生存還本金成功帳號
--            順位3:自動轉帳或彙繳的郵局帳號
--  修改日期: 099/03/26
--  修改者  : 汪逸雲
------------------------------------------------------------------------------
--  修改目的: 調整主動電匯帳號抓取規則,並改由呼叫函式psc20s02_get_account()
--  修改日期: 104/11/26
--  修 改 者: JUCHUN 
------------------------------------------------------------------------------
--  修改目的: 定義g_program_id
--  修改日期: 105/01/29
--  修 改 者: JUCHUN 
------------------------------------------------------------------------------
GLOBALS "../def/common.4gl"
DATABASE life

   DEFINE p_benf			RECORD LIKE benf.*
   DEFINE p_benp                        RECORD LIKE benp.*
   DEFINE p_rowid			INTEGER
   DEFINE p_method                      CHAR(1)
   DEFINE p_auto_pay_ind                CHAR(1)
   DEFINE p_issue_date                  LIKE polf.po_issue_date
   DEFINE p_annd                        LIKE pscb.cp_anniv_date
   DEFINE p_expired_date                LIKE polf.expired_date
   DEFINE p_currency                    CHAR(3)
   DEFINE p_benp_cnt                    SMALLINT
   DEFINE p_last_po                     CHAR(12)
   DEFINE p_last_relation               CHAR(1)
   DEFINE p_last_client_id              CHAR(10)
   DEFINE p_del_sw                      CHAR(1)
   DEFINE p_psc4_cnt                    INT
MAIN

   DEFINE f_coupon_date			CHAR(9)
         ,f_coupon_mm       CHAR(2)
   DEFINE f_exist_sw			CHAR(1)
         ,f_source_ind      CHAR(1)   
   DEFINE ctl_code        CHAR(1)  -- 099/04/07新增 by 逸雲
   DEFINE f_polf			RECORD LIKE polf.*
   DEFINE f_pocl			RECORD LIKE pocl.*

   DEFINE f_result            INTEGER
         ,f_remit_bank        LIKE dbdd.remit_bank        
         ,f_remit_branch      LIKE dbdd.remit_branch     
         ,f_remit_account     LIKE dbdd.remit_account    
         ,f_bank_code         LIKE pcdl.bank_branch       
         ,f_swift_code        LIKE dbdd.remit_swift_code       
         ,f_bank_account_e    LIKE dbdd.remit_account  
         ,f_bank_name_e       LIKE dbdd.remit_bank_name      
         ,f_payee_e           LIKE dbdd.payee         
         ,f_bank_address_e    LIKE dbdd.remit_bank_address 
          
   	
   WHENEVER ERROR CONTINUE

   SET LOCK MODE TO WAIT

   SELECT desc[1,9]
   INTO   f_coupon_date
   FROM   etab
   WHERE  code   = "PS"
   AND    e_type = "coupon0"

   LET f_coupon_date = AddMonth(f_coupon_date,1) --上線後開啟 for sd0
   LET f_coupon_mm   = f_coupon_date[5,6] -- 還本目標月份
   
   LET p_last_po = ""
   LET p_last_relation = ""
   INITIALIZE f_polf.* TO NULL
   INITIALIZE f_pocl.* TO NULL
   INITIALIZE p_benf.* TO NULL
   LET f_result          = 0
   LET f_remit_bank      = ''
   LET f_remit_branch    = ''
   LET f_remit_account   = ''
   LET f_bank_code       = ''
   LET f_swift_code      = ''
   LET f_bank_account_e  = ''
   LET f_bank_name_e     = ''
   LET f_payee_e         = ''
   LET f_bank_address_e  = ''
   LET g_program_id = "psc20b"
   

———yirong test SR12
   
   -- 104/11/26 加上週年日與還本險種條件,移除ROWID    
#  DECLARE benf_ptr CURSOR WITH HOLD FOR
#     SELECT *, ROWID
#     FROM   benf
#     WHERE relation IN ('L','M') 
#     AND policy_no[1] NOT IN ("6","8","9") -- 上線後開啟 for sd0
#     ORDER BY policy_no,relation,client_id
#  FOREACH benf_ptr INTO p_benf.*, p_rowid
   	
   DECLARE benf_ptr CURSOR WITH HOLD FOR
      SELECT a.*, b.*  
      FROM   benf a, polf b, pldf c
      WHERE  a.relation IN ('L','M') 
      AND    a.policy_no[1] NOT IN ("6","8","9") 
      AND    a.policy_no          = b.policy_no
      AND    b.po_issue_date[5,6] = f_coupon_mm       -- 只要週年日為月處理執行月份保單   
      AND    b.basic_plan_code    = c.plan_code
      AND    b.basic_rate_scale   = c.rate_scale
      AND    c.coupon_ind NOT IN('0','3')             -- 只要還本險種
      ORDER BY a.policy_no,a.relation,a.client_id
   FOREACH benf_ptr INTO p_benf.*, f_polf.* 
      DISPLAY '------ ',p_benf.policy_no,'|',p_benf.relation,'|',p_benf.client_id,'|',f_polf.po_issue_date,'|',f_polf.currency

      LET p_issue_date		= ""
      LET p_method		= ""
      LET p_auto_pay_ind	= ""
      LET p_annd =  ""
      LET p_expired_date=""
      
      LET f_exist_sw		= "N"
      INITIALIZE p_benp.* TO NULL
      
      -- 104/11/26 合併到上方SQL指令判斷 
#     SELECT *
#     INTO   f_polf.* 
#     FROM   polf
#     WHERE  policy_no = p_benf.policy_no

      IF p_benf.client_id IS NULL THEN
         LET p_benf.client_id = ' '
      END IF
 
--display p_last_po,'------',p_last_relation
      IF p_benf.policy_no = p_last_po  AND
         p_benf.relation = p_last_relation THEN
         LET p_del_sw = 'N'
         IF p_benf.client_id = p_last_client_id AND 
            f_polf.currency != 'TWD' THEN
            DISPLAY	"不符:相同保戶"
            CONTINUE FOREACH
         END IF
      ELSE
         LET p_del_sw ='Y'        
      END IF

      LET p_last_po = p_benf.policy_no
      LET p_last_relation = p_benf.relation
      LET p_last_client_id = p_benf.client_id



      IF LENGTH(f_polf.po_issue_date CLIPPED) = 0 THEN 
         DISPLAY "不符:po_issue_date空白"
         CONTINUE FOREACH 
      END IF
      IF LENGTH(p_benf.client_id CLIPPED) = 0 AND f_polf.currency = 'TWD' THEN 
      	 DISPLAY "不符:受益人ID空白"
         CONTINUE FOREACH 
      END IF

      ------------------------------------------------
      --針對滿期受益人，尚未滿期者不抓帳號，直接略過-- by 逸雲 099/05/28
      ------------------------------------------------

      IF p_benf.relation='M' THEN
         CALL PolicyAnniversary(f_polf.po_issue_date,f_coupon_date,1) RETURNING p_annd
         IF p_annd < f_polf.expired_date THEN 
           DISPLAY "不符:未滿期者不抓帳號"
           CONTINUE FOREACH 
         END IF
      END IF 

      -- 104/11/26 合併到上方SQL指令判斷 
#      ------------------------------
#      -- 保單是否為月處理執行月份 --
#      ------------------------------
#      IF f_polf.po_issue_date[5,6] != f_coupon_date[5,6] THEN
#	 CONTINUE FOREACH
#      END IF

      ------------------ 
      --特殊保單不處理--
      ------------------
      LET p_psc4_cnt = 0
      SELECT count(*)
        INTO p_psc4_cnt
        FROM psc4
       WHERE policy_no = p_benf.policy_no
         AND psc_type = '1'
      IF p_psc4_cnt > 0 THEN
         DISPLAY "不符:特殊保單" 
         CONTINUE FOREACH
      END IF

      -- 104/11/26 改寫
      -- 要保人 
      SELECT *
      INTO   f_pocl.*
      FROM   pocl 
      WHERE  policy_no    = p_benf.policy_no
      AND    client_ident = 'O1'

      CALL psc20s02_get_account(p_benf.policy_no
                               ,f_polf.currency
                               ,p_benf.client_id
                               ,f_pocl.client_id
                               ,f_polf.method
                               ,f_polf.auto_pay_ind )
          RETURNING f_result   
                   ,f_remit_bank     
                   ,f_remit_branch   
                   ,f_remit_account  
                   ,f_bank_code      
                   ,f_swift_code     
                   ,f_bank_account_e 
                   ,f_bank_name_e    
                   ,f_payee_e        
                   ,f_bank_address_e
                   ,f_source_ind 

      DISPLAY "KURT test :",p_benf.policy_no,'--ID=',p_benf.client_id,'--rel=',p_benf.relation," 帳號來源: ",f_source_ind," 帳號有效檢查:",f_result

      CASE f_result
          WHEN 1
          	  DISPLAY "有找到有效帳號"
          WHEN 0
          	  DISPLAY "沒找到帳號"
          WHEN -1
          	  DISPLAY "找到但帳號無效"
          WHEN -2
          	  DISPLAY "參數有誤"	
      END CASE
      
      -- 更新檔案(沒找到帳號則清空)
      WHENEVER ERROR CONTINUE 
      BEGIN WORK
      CALL psc20s04_upd_benf_account (p_benf.policy_no
                                     ,p_benf.relation
                                     ,f_polf.currency
                                     ,p_benf.client_id
                                     ,p_benf.names
                                     ,f_remit_bank      
                                     ,f_remit_branch    
                                     ,f_remit_account   
                                     ,f_bank_code       
                                     ,f_swift_code      
                                     ,f_bank_account_e  
                                     ,f_bank_name_e     
                                     ,f_payee_e         
                                     ,f_bank_address_e
                                     ,p_del_sw) RETURNING f_result 
      INITIALIZE p_benf.* TO NULL
      INITIALIZE f_polf.* TO NULL
      INITIALIZE f_pocl.* TO NULL
      LET f_result          = 0
      LET f_remit_bank      = ''
      LET f_remit_branch    = ''
      LET f_remit_account   = ''
      LET f_bank_code       = ''
      LET f_swift_code      = ''
      LET f_bank_account_e  = ''
      LET f_bank_name_e     = ''
      LET f_payee_e         = ''
      LET f_bank_address_e  = ''
   


#IF p_currency = 'TWD' THEN       
#      ---------------------------
#      -- 搜尋帳號約定系統帳號 --
#      -------------------------------------
#      CALL get_account_0() RETURNING f_exist_sw
#      IF f_exist_sw = "N" THEN
#         IF p_benf.remit_bank is null THEN
#            let p_benf.remit_bank = ' '
#         END IF
#         IF p_benf.remit_bank <> ' ' THEN
#            CONTINUE FOREACH
#         END IF
#      END IF
#      
#-- 094/08 取消此條件
#-- 099/03 依需求單號PS99419S重新使用 by 逸雲 ------
#
#      ----------------------
#      -- 搜尋付款成功帳號 --
#      ----------------------
#      IF f_exist_sw = "N" THEN
#	 CALL get_account_2() RETURNING f_exist_sw
#      END IF
#--------------------------------------------------- END by 逸雲
#----- 101/10/15 因應個資法取消此兩條件 yirong 
#{    
#      ----------------------
#      -- 搜尋自動轉帳帳號 --
#      ----------------------
#      IF f_exist_sw = "N" THEN
#         IF p_method = "1" THEN
#	    CALL get_account_1() RETURNING f_exist_sw
#         END IF
#      END IF
#
#      ----------------------
#      -- 搜尋匯繳帳號 --
#      ----------------------
#      IF f_exist_sw = "N" THEN
#         IF p_method = "5" THEN
#	    CALL get_account_9() RETURNING f_exist_sw
#         END IF
#      END IF
#}
#---------------------------------------------------101/10/15 END
#      IF f_exist_sw = "Y" THEN
#
#	 BEGIN WORK
#
#	 UPDATE benf
#	 SET   (remit_bank, remit_branch, remit_account)
#	     = (p_benf.remit_bank, p_benf.remit_branch, p_benf.remit_account)
#         WHERE  rowid = p_rowid
#
#--	 DISPLAY p_rowid," ",p_benf.policy_no
#   
#         IF SQLCA.SQLCODE != 0 THEN
#	    DISPLAY "Error at update benf: ",p_benf.policy_no
#	    ROLLBACK WORK
#	 ELSE
#	    DISPLAY p_benf.policy_no,'-',p_benf.client_id,"-", p_benf.remit_bank
#				    , "-", p_benf.remit_branch
#				    , "-", p_benf.remit_account
#	    COMMIT WORK
#	 END IF
#display 'UPD succ=',p_benf.policy_no,'-',p_benf.client_id,"-", p_benf.remit_bank
#                              , "-", p_benf.remit_branch
#                             , "-", p_benf.remit_account
#
#      ELSE
#--   101/11先清空受益人帳號在抓取yirong----
#
#         BEGIN WORK
#  
#         UPDATE benf
#         SET   (remit_bank, remit_branch, remit_account)
#             = ('', '', '')
#         WHERE  rowid = p_rowid
#
#
#         IF SQLCA.SQLCODE != 0 THEN
#            DISPLAY "Error at update benf: ",p_benf.policy_no
#            ROLLBACK WORK
#         ELSE
#            COMMIT WORK
#         END IF
#display 'UPD NULL'
#
#      END IF
#ELSE  --外幣
#      ---------------------------
#      -- 搜尋外幣保單匯繳帳號 --
#      ---------------------------
#
#      CALL get_account_5() RETURNING f_exist_sw
#{
#      IF f_exist_sw = "N" THEN
#         IF p_benp.bank_code is null THEN
#            LET p_benp.bank_code = ' '
#         END IF
#         IF p_benp.bank_code <> ' ' THEN
#            CONTINUE FOREACH
#         END IF
#      END IF
#}
#      --------------------------
#      -- 搜尋帳號約定系統帳號 --
#      --------------------------
#
#      IF f_exist_sw = "N" THEN
#         CALL get_account_6() RETURNING f_exist_sw
#display '6',f_exist_sw
#      END IF
#      
#      ----------------------
#      -- 搜尋付款成功帳號 --
#      ----------------------
#      IF f_exist_sw = "N" THEN
#         CALL get_account_7() RETURNING f_exist_sw
#display '7',f_exist_sw
#      END IF
#
#
#      IF f_exist_sw = "N" THEN
#         IF p_benp.bank_code is null THEN
#            LET p_benp.bank_code = ' '
#            LET p_benp.swift_code = ' '
#            LET p_benp.bank_name_e = ' '
#            LET p_benp.bank_account_e = ' '
#            LET p_benp.payee_e = ' '
#            LET p_benp.bank_address_e = ' '
#
#          END IF
#      END IF
#
#      LET p_benp_cnt = 0
#      SELECT count(*)
#        INTO p_benp_cnt
#        FROM benp
#       WHERE policy_no = p_benf.policy_no
#         AND relation = p_benf.relation
#--         AND client_id = p_benf.client_id
#
#display 'cnt=',p_benp_cnt           ,p_del_sw
#      IF p_benp_cnt > 0  AND p_del_sw = "Y" THEN
#         BEGIN WORK
#display  p_benf.policy_no,'   ',p_benf.relation
#         DELETE FROM benp
#         WHERE policy_no = p_benf.policy_no
#         AND relation = p_benf.relation
#--         AND client_id = p_benf.client_id
#
#         IF SQLCA.SQLCODE != 0 THEN
#            ROLLBACK WORK
#            ERROR "benp 刪除失敗 !!",p_benf.policy_no, p_benf.relation
#         END IF
#display 'delete',p_benf.policy_no, p_benf.relation
#         COMMIT WORK
#      END IF 
#
#      BEGIN WORK
#      INSERT INTO benp VALUES (
#                                  p_benf.policy_no,
#                                  p_benf.coverage_no,
#                                  p_benf.relation,
#                                  p_benf.client_id,
#                                  p_benf.names,
#                                  p_benp.bank_code,
#                                  p_benp.swift_code,
#                                  p_benp.bank_name_e,
#                                  p_benp.bank_account_e,
#                                  p_benp.payee_e,
#                                  p_benp.bank_address_e)
#
#      IF SQLCA.SQLCODE != 0 THEN
#         DISPLAY "Error at insert benp: ",p_benf.policy_no
#         ROLLBACK WORK
#      ELSE
#         DISPLAY p_currency,'  ',p_benp.policy_no,'-',p_benp.client_id,"-", p_benp.bank_code
#                         , "-", p_benp.swift_code, "-", p_benp.bank_account_e
#         COMMIT WORK
#      END IF
# 
#END IF 
    END FOREACH

END MAIN
#--104/11/26 COMMENT OUT
#------------------------------------------------------------------------------
#--  程式名稱: get_account_0
#--  日    期: 092/12/12
#--  處理概要: 依條件取得自動轉帳帳號 
#--	      AND 3.受益人=要保人=委託人
#------------------------------------------------------------------------------
#FUNCTION get_account_0()
#
#   DEFINE f_applicant_id		CHAR(10)
#   DEFINE f_applicant_name		CHAR(40)
#   DEFINE f_client_id			CHAR(10)
#
#   DEFINE f_bank_no			LIKE bldt.bank_account  
#   DEFINE f_bank_branch			LIKE bkrf.bank_branch   
#
#   DEFINE f_pctl_cnt			SMALLINT
#   DEFINE f_cnt	         		SMALLINT
#   DEFINE f_psra   RECORD LIKE psra.*
#   DEFINE f_exist_sw			CHAR(1)
#
#   LET f_applicant_id		= ""
#   LET f_client_id		= ""
#   LET f_bank_no		= ""
#   LET f_bank_branch		= ""
#   LET f_exist_sw		= "N"
#
#      LET f_cnt = 0
#      SELECT count(*) INTO f_cnt
#        FROM psra
#       WHERE client_id = p_benf.client_id
#         AND psra_sts_code = '0'
#      
#      IF f_cnt  > 0     THEN
#      SELECT * INTO f_psra.*
#        FROM psra
#       WHERE client_id = p_benf.client_id
#         AND psra_sts_code = '0'
#
#	  IF LENGTH(f_psra.remit_bank CLIPPED) = 0
#	  OR LENGTH(f_psra.remit_branch CLIPPED) = 0 
#	  OR LENGTH(f_psra.remit_account CLIPPED) = 0 THEN
#	     RETURN f_exist_sw
#	  END IF
#
#         LET p_benf.remit_bank		= f_psra.remit_bank
#         LET p_benf.remit_branch	= f_psra.remit_branch
#         LET p_benf.remit_account	= f_psra.remit_account
#
#display 'p_no = ',p_benf.policy_no ,' ',p_benf.client_id ,' ',f_psra.remit_bank,
#' ',f_psra.remit_branch,' ',f_psra.remit_account
#         LET f_exist_sw			= "Y"
#     END IF
#   RETURN f_exist_sw
#
#END FUNCTION
#
#
#------------------------------------------------------------------------------
#--  程式名稱: get_account_1
#--  作    者: Kobe
#--  日    期: 092/12/12
#--  處理概要: 依條件取得自動轉帳帳號 
#--	          1.收費方式為自動轉帳  
#--            AND 2.轉帳機構為郵局(998)  
#--	      AND 3.受益人=要保人=委託人
#------------------------------------------------------------------------------
#FUNCTION get_account_1()
#
#   DEFINE f_applicant_id		CHAR(10)
#   DEFINE f_applicant_name		CHAR(40)
#   DEFINE f_client_id			CHAR(10)
#
#   DEFINE f_bank_no			LIKE bldt.bank_account  
#   DEFINE f_bank_branch			LIKE bkrf.bank_branch   
#
#   DEFINE f_pctl_cnt			SMALLINT
#   DEFINE f_exist_sw			CHAR(1)
#
#   LET f_applicant_id		= ""
#   LET f_client_id		= ""
#   LET f_bank_no		= ""
#   LET f_bank_branch		= ""
#   LET f_exist_sw		= "N"
#
#   IF LENGTH(p_method CLIPPED) = 0
#   OR LENGTH(p_auto_pay_ind CLIPPED) = 0 THEN
#      RETURN f_exist_sw
#   END IF
#
#   DECLARE pcdl_ptr CURSOR FOR
#      SELECT client_id
#      FROM   pcdl
#      WHERE  policy_no   = p_benf.policy_no
#      AND    bank_op_ind = "1"
#      ORDER BY process_date DESC, process_time DESC
#
#   ----------------------------
#   -- 保單自動轉帳是否有資料 --
#   ----------------------------   
#   SELECT COUNT(*)
#   INTO   f_pctl_cnt
#   FROM   pctl
#   WHERE  policy_no   = p_benf.policy_no
#   AND    bank_op_ind = "1"
#
#   IF f_pctl_cnt > 0 THEN
#
#      --------------
#      -- 委託人ID --
#      --------------
#      IF p_auto_pay_ind = "1"
#      OR p_auto_pay_ind = "2" THEN
#	 SELECT client_id
#	 INTO   f_client_id
#	 FROM   pccd
#	 WHERE  policy_no   = p_benf.policy_no
#	 AND    bank_op_ind = "1"
#
#	 IF STATUS = NOTFOUND THEN
#	    OPEN pcdl_ptr
#	    FETCH pcdl_ptr INTO f_client_id
#	    CLOSE pcdl_ptr
#	    FREE pcdl_ptr
#	 END IF
#      ELSE
#	 SELECT client_id
#	 INTO   f_client_id
#	 FROM   bkrf
#	 WHERE  policy_no   = p_benf.policy_no
#	 AND    bank_op_ind = "1"
#      END IF
#
#      --------------
#      -- 要保人ID --
#      --------------
#      CALL GetNames(p_benf.policy_no, "O1") RETURNING f_applicant_id, f_applicant_name
#
#      --------------------------
#      -- 受益人=要保人=委託人 --
#      --------------------------
#      IF LENGTH(f_client_id CLIPPED) = 0
#      OR LENGTH(f_applicant_id CLIPPED) = 0 THEN
#	 RETURN f_exist_sw
#      END IF
#
#      IF  p_benf.client_id = f_applicant_id
#      AND p_benf.client_id = f_client_id    THEN
#	  CALL GetBankAccount(p_benf.policy_no, p_auto_pay_ind, p_method)
#	       RETURNING f_bank_no, f_bank_branch
#
#	  IF LENGTH(f_bank_no CLIPPED) = 0
#	  OR LENGTH(f_bank_branch CLIPPED) = 0 THEN
#	     RETURN f_exist_sw
#	  END IF
#	  
#	  IF f_bank_no[1,3] != "998" THEN
#	     RETURN f_exist_sw
#	  ELSE
#	     LET p_benf.remit_bank	= "700"
#	     LET p_benf.remit_branch	= "0021"
#	     LET p_benf.remit_account	= f_bank_no[4,19]
#	     LET f_exist_sw		= "Y"
#	  END IF
#      END IF
#
#   END IF
#
#   RETURN f_exist_sw
#
#END FUNCTION
#
#------------------------------------------------------------------------------
#--  程式名稱: get_account_2
#--  作    者: Kobe
#--  日    期: 092/12/12
#--  處理概要: 依條件取得付款成功帳號
#--                1.取得最近一次電匯付款成功帳號
#--            AND 2.受益人=受款人
#--            AND 3.銀行代碼非 "801", "802", "827"
#------------------------------------------------------------------------------
#-- 修 改 者:汪逸雲
#-- 修改目的:因測試環境人名會改為黃XX、李XX，會與dbdd中的payee名稱對不上
#--          故修改以該保單在benf檔中的銀行帳號來對上dbdd
#--          ，另POS要求抓帳號要是最近一次正常電匯的帳號，不可為指定電匯的帳號
#------------------------------------------------------------------------------
#FUNCTION get_account_2()
#
#   DEFINE f_disb_no         LIKE dbdd.disb_no
#   DEFINE f_remit_bank			LIKE dbdd.remit_bank
#   DEFINE f_remit_branch		LIKE dbdd.remit_branch
#   DEFINE f_remit_account		LIKE dbdd.remit_account
#   DEFINE f_process_date		LIKE dbdd.process_date
#   DEFINE f_process_time		LIKE dbdd.process_time
#   DEFINE f_reference_code  LIKE dbdd.reference_code
#   DEFINE f_disb_sts_code   LIKE dbdd.disb_sts_code
#   DEFINE chk_cnt           SMALLINT
#   DEFINE f_names           LIKE clnt.names
#   DEFINE f_payee           LIKE dbdd.payee
#
#   DEFINE f_tran_date			CHAR(9)
#   DEFINE f_exist_sw			CHAR(1)
#
#   LET f_disb_no		= ""
#   LET f_remit_bank		= ""
#   LET f_remit_branch		= ""
#   LET f_remit_account		= ""
#   LET f_exist_sw		= "N"
#   LET f_disb_sts_code =''
#   LET f_tran_date		= getDate(TODAY)
#   LET f_tran_date		= SubtractYear(f_tran_date, 2)
#   LET chk_cnt = 0
#   LET f_names=''
#   LET f_payee=''
#      
#   DECLARE dbdd_ptr CURSOR FOR
#      SELECT payee,disb_no, remit_bank, remit_branch, remit_account,disb_sts_code, process_date, process_time
#      FROM   dbdd
#      WHERE  reference_code = p_benf.policy_no
#--    AND    disb_sts_code = "R" --099/05 修改
#      AND    function_code LIKE 'R%' --099/05 新增此條件 by 逸雲 
#--    AND    process_date > f_tran_date
#      ORDER BY process_date DESC, process_time DESC
#
#   OPEN dbdd_ptr
#   FOREACH dbdd_ptr INTO f_payee,f_disb_no,f_remit_bank,f_remit_branch
#                        ,f_remit_account,f_disb_sts_code,f_process_date
#                        ,f_process_time
#
#      IF LENGTH(f_remit_bank CLIPPED) = 0
#      OR LENGTH(f_remit_branch CLIPPED) = 0
#      OR LENGTH(f_remit_account CLIPPED) = 0 THEN
#         CONTINUE FOREACH
#      END IF
#      IF f_remit_bank = "801"
#      OR f_remit_bank = "802"
#      OR f_remit_bank = "827"
#      OR f_remit_bank = "055"
#      OR f_remit_bank = "145"
#      OR f_remit_bank = "154"
#      OR f_remit_bank = "172"
#      OR f_remit_bank = "811"
#      OR f_remit_bank = "219"
#      OR f_remit_bank = "133"
#      OR f_remit_bank = "176"
#      OR f_remit_bank = "813" THEN
#         CONTINUE FOREACH
#      END IF
#      SELECT COUNT(*) INTO chk_cnt
#      FROM pscb
#      WHERE policy_no=p_benf.policy_no 
#      AND cp_sw='2'
#      AND disb_special_ind = '0'
#      AND cp_disb_type IN ('3','5')
#
#      IF chk_cnt ==0 THEN EXIT FOREACH END IF
#
#      LET chk_cnt =0
#
#      SELECT COUNT(*) INTO chk_cnt
#      FROM pscs
#      WHERE policy_no=p_benf.policy_no
#      AND remit_bank = f_remit_bank
#      AND remit_branch = f_remit_branch
#      AND remit_account = f_remit_account
#
#      IF chk_cnt >0 THEN CONTINUE FOREACH END IF
#      IF p_benf.relation =='L' 
#         AND 
#         (
#          LENGTH(p_benf.remit_bank CLIPPED)==0
#          OR
#          LENGTH(p_benf.remit_branch CLIPPED)==0
#          OR
#          LENGTH(p_benf.remit_account CLIPPED)==0
#         )
#      THEN
#
#        SELECT names INTO f_names
#        FROM clnt
#        WHERE client_id=p_benf.client_id
#        
#        IF f_names CLIPPED !=f_payee CLIPPED THEN CONTINUE FOREACH END IF 
#             
#      ELSE
#        LET chk_cnt=0
#
#        SELECT COUNT(*) INTO chk_cnt
#        FROM benf
#        WHERE policy_no=p_benf.policy_no
#        AND client_id=p_benf.client_id
#        AND remit_bank=f_remit_bank
#        AND remit_branch=f_remit_branch
#        AND remit_account=f_remit_account
#      
#        IF chk_cnt==0 THEN CONTINUE FOREACH END IF
#      END IF
#      IF f_disb_sts_code != 'R' 
#--        AND f_disb_sts_code !='A' --測試用
#        THEN EXIT FOREACH END IF 
#    
#      LET p_benf.remit_bank		= f_remit_bank
#      LET p_benf.remit_branch	= f_remit_branch
#      LET p_benf.remit_account	= f_remit_account
#      LET f_exist_sw			= "Y"
#      EXIT FOREACH
#      
#   END FOREACH
#   CLOSE dbdd_ptr
#   
#   RETURN f_exist_sw
#
#END FUNCTION
#
#------------------------------------------------------------------------------
#--  程式名稱: get_account_9
#--  作    者: Kobe
#--  日    期: 092/12/12
#--  處理概要: 依條件取得彙繳帳號 
#--	          1.收費方式為彙繳  
#--            AND 2.轉帳機構為郵局(998)  
#--	      AND 3.受益人=要保人=委託人
#------------------------------------------------------------------------------
#FUNCTION get_account_9()
#
#   DEFINE f_applicant_id		CHAR(10)
#   DEFINE f_applicant_name		CHAR(40)
#   DEFINE f_client_id			CHAR(10)
#   define f_bank_id		        LIKE bkrf.bank_id
#   define f_branch_account		LIKE bkrf.branch_account
#   DEFINE f_bank_branch			LIKE bkrf.bank_branch   
#
#   DEFINE f_pctl_cnt			SMALLINT
#   DEFINE f_exist_sw			CHAR(1)
#
#   LET f_applicant_id		= ""
#   LET f_client_id		= ""
#   LET f_bank_id		= ""
#   LET f_bank_branch		= ""
#   LET f_branch_account		= ""
#   LET f_exist_sw		= "N"
#
#   IF LENGTH(p_method CLIPPED) = 0
#   OR LENGTH(p_auto_pay_ind CLIPPED) = 0 THEN
#      RETURN f_exist_sw
#   END IF
#
#   DECLARE pcdl_ptr1 CURSOR FOR
#      SELECT client_id
#      FROM   pcdl
#      WHERE  policy_no   = p_benf.policy_no
#      AND    bank_op_ind = "1"
#      ORDER BY process_date DESC, process_time DESC
#
#   ----------------------------
#   -- 保單彙繳是否有資料 --
#   ----------------------------   
#   SELECT COUNT(*)
#   INTO   f_pctl_cnt
#   FROM   pctl
#   WHERE  policy_no   = p_benf.policy_no
#   AND    bank_op_ind = "1"
#
#   IF f_pctl_cnt > 0 THEN
#
#      --------------
#      -- 委託人ID --
#      --------------
#      IF p_auto_pay_ind = "1"
#      OR p_auto_pay_ind = "2" THEN
#	 SELECT client_id
#	 INTO   f_client_id
#	 FROM   pccd
#	 WHERE  policy_no   = p_benf.policy_no
#	 AND    bank_op_ind = "1"
#
#	 IF STATUS = NOTFOUND THEN
#	    OPEN pcdl_ptr1
#	    FETCH pcdl_ptr1 INTO f_client_id
#	    CLOSE pcdl_ptr1
#	    FREE pcdl_ptr1
#	 END IF
#      ELSE
#	 SELECT client_id
#	 INTO   f_client_id
#	 FROM   bkrf
#	 WHERE  policy_no   = p_benf.policy_no
#	 AND    bank_op_ind = "1"
#      END IF
#
#      --------------
#      -- 要保人ID --
#      --------------
#      CALL GetNames(p_benf.policy_no, "O1") RETURNING f_applicant_id, f_applicant_name
#
#      --------------------------
#      -- 受益人=要保人=委託人 --
#      --------------------------
#      IF LENGTH(f_client_id CLIPPED) = 0
#      OR LENGTH(f_applicant_id CLIPPED) = 0 THEN
#	 RETURN f_exist_sw
#      END IF
#
#      IF  p_benf.client_id = f_applicant_id
#      AND p_benf.client_id = f_client_id    THEN
#{
#	  CALL GetBankAccount(p_benf.policy_no, p_auto_pay_ind, p_method)
#	       RETURNING f_bank_no, f_bank_branch
#}
#         SELECT bank_id    
#               ,bank_branch     
#               ,branch_account
#         INTO f_bank_id,f_bank_branch,f_branch_account
#         FROM bkrf
#         WHERE policy_no = p_benf.policy_no 
#           AND client_id = p_benf.client_id
#	   AND bank_op_ind = "1"
#
#	  IF LENGTH(f_bank_id CLIPPED) = 0
#	  OR LENGTH(f_bank_branch CLIPPED) = 0 THEN
#	     RETURN f_exist_sw
#	  END IF
#	  
#	  IF f_bank_id != "998" THEN
#	     RETURN f_exist_sw
#	  ELSE
#	     LET p_benf.remit_bank	= "700"
#	     LET p_benf.remit_branch	= "0021"
#	     LET p_benf.remit_account	= f_branch_account
#	     LET f_exist_sw		= "Y"
#--display 'p_no9= ',p_benf.policy_no ,' ',p_benf.client_id ,' ',p_benf.remit_bank,
#--' ',p_benf.remit_branch,' ',p_benf.remit_account
#	  END IF
#      END IF
#
#   END IF
#
#   RETURN f_exist_sw
#
#END FUNCTION
#------------------------------------------------------------------------------
#--  程式名稱: get_account_5
#--  日    期: 100/03/11
#--  處理概要: 
#------------------------------------------------------------------------------
#FUNCTION get_account_5()
#
#   DEFINE f_cnt                         SMALLINT
#   DEFINE f_pofb   RECORD LIKE pofb.*
#   DEFINE f_exist_sw                    CHAR(1)
#   DEFINE   f_err   CHAR(01)
#   DEFINE   f_mes   CHAR(40)
#   DEFINE   f_payee_en_ind CHAR
#
#
#   LET f_exist_sw               = "N"
#
#   LET f_cnt = 0
#   SELECT count(*) INTO f_cnt
#     FROM pofb
#    WHERE client_id = p_benf.client_id
#      AND policy_no = p_benf.policy_no
#
#      IF f_cnt  > 0     THEN
#         SELECT * INTO f_pofb.*
#         FROM pofb
#         WHERE client_id = p_benf.client_id
#         AND   policy_no = p_benf.policy_no
#  
#         IF LENGTH ( f_pofb.swift_code CLIPPED ) != 0 THEN
#            CALL chk_foreignacct( "0" , f_pofb.swift_code ,f_pofb.bank_account_e)
#               Returning f_err, f_payee_en_ind, f_mes
#            IF f_err  THEN
#display p_benf.policy_no ,f_mes
#               RETURN f_exist_sw
#            ELSE
#               IF f_payee_en_ind = "Y"
#               AND LENGTH ( f_pofb.payee_e ) = 0
#               THEN
#display p_benf.policy_no ,"pofb=該SW英文名字為必要輸入。"
#                  RETURN f_exist_sw
#               END IF
#            END  IF
#
#         ELSE  -- 無remit_swift_code,則需有remit_bank_name及remit_address
#            IF LENGTH( f_pofb.bank_name_e CLIPPED )=0
#            OR LENGTH( f_pofb.bank_address_e   CLIPPED )=0
#            THEN
#display p_benf.policy_no ,"銀行名稱,地址不可為空白:"
#               RETURN f_exist_sw
#            END IF
#
#            IF LENGTH ( f_pofb.payee_e ) = 0
#            THEN
#display p_benf.policy_no , "受款人不可為空白"
#               RETURN f_exist_sw
#            END IF
#
#         END IF
#         IF LENGTH ( f_pofb.bank_account_e CLIPPED ) = 0
#         THEN
#display p_benf.policy_no , "帳號不可為空白"
#            RETURN f_exist_sw
#         END IF
#
# 
#{
#          IF LENGTH(f_pofb.bank_code CLIPPED) = 0
#          OR LENGTH(f_pofb.swift_code CLIPPED) = 0
#          OR LENGTH(f_pofb.bank_account_e CLIPPED) = 0 
#          OR LENGTH(f_pofb.bank_name_e CLIPPED) = 0 
#          OR LENGTH(f_pofb.payee_e CLIPPED) = 0 THEN
#             RETURN f_exist_sw
#          END IF
#}
#         LET p_benp.bank_code          =  f_pofb.bank_code
#         LET p_benp.swift_code         =  f_pofb.swift_code
#         LET p_benp.bank_account_e     =  f_pofb.bank_account_e
#         LET p_benp.bank_name_e        =  f_pofb.bank_name_e
#         LET p_benp.payee_e            =  f_pofb.payee_e  
#         LET p_benp.bank_address_e     =  f_pofb.bank_address_e
#
#display 'p_no = ',p_benf.policy_no ,' ',p_benf.client_id 
#         LET f_exist_sw                 = "Y"
#     END IF
#   RETURN f_exist_sw
#
#END FUNCTION
#------------------------------------------------------------------------------
#--  程式名稱: get_account_6
#--  日    期: 100/03/11
#--  處理概要:
#------------------------------------------------------------------------------
#
#FUNCTION get_account_6()
#
#   DEFINE f_cnt                         SMALLINT
#   DEFINE f_psrf   RECORD LIKE psrf.*
#   DEFINE f_exist_sw                    CHAR(1)
#   DEFINE   f_err   CHAR(01)
#   DEFINE   f_mes   CHAR(40)
#   DEFINE   f_payee_en_ind CHAR
#
#   LET f_exist_sw               = "N"
#
#   LET f_cnt = 0
#   SELECT count(*) INTO f_cnt
#     FROM psrf
#    WHERE client_id = p_benf.client_id
#      AND psrf_sts_code = '0'
#  
#display 'psrf cnt=',f_cnt
#      IF f_cnt  > 0     THEN
#         SELECT * 
#         INTO   f_psrf.*
#         FROM   psrf
#         WHERE  client_id = p_benf.client_id
#         AND    psrf_sts_code = '0'
#
#         IF LENGTH ( f_psrf.swift_code CLIPPED ) != 0 THEN
#            CALL chk_foreignacct( "0" , f_psrf.swift_code ,f_psrf.bank_account_e)
#               Returning f_err, f_payee_en_ind, f_mes           
#            IF f_err  THEN
#display p_benf.client_id ,f_mes
#               RETURN f_exist_sw
#            ELSE
#               IF f_payee_en_ind = "Y"
#               AND LENGTH ( f_psrf.payee_e ) = 0
#               THEN
#display p_benf.client_id ,"=該SW英文名字為必要輸入。"
#                  RETURN f_exist_sw
#               END IF
#            END  IF
#
#         ELSE  -- 無remit_swift_code,則需有remit_bank_name及remit_address
#            IF LENGTH( f_psrf.bank_name_e CLIPPED )=0
#            OR LENGTH( f_psrf.bank_address_e   CLIPPED )=0
#            THEN
#display p_benf.client_id ,"銀行名稱,地址不可為空白:"
#               RETURN f_exist_sw
#            END IF
#
#            IF LENGTH ( f_psrf.payee_e ) = 0
#            THEN
#display p_benf.client_id , "受款人不可為空白"
#               RETURN f_exist_sw
#            END IF
#
#         END IF
#         IF LENGTH ( f_psrf.bank_account_e CLIPPED ) = 0
#         THEN
#display p_benf.client_id , "帳號不可為空白"
#            RETURN f_exist_sw
#         END IF
#  
#{
#          IF LENGTH(f_psrf.bank_code CLIPPED) = 0
#          OR LENGTH(f_psrf.swift_code CLIPPED) = 0
#          OR LENGTH(f_psrf.bank_account_e CLIPPED) = 0
#          OR LENGTH(f_psrf.bank_name_e CLIPPED) = 0
#--          OR LENGTH(f_psrf.payee_e CLIPPED) = 0 
#          THEN
#             RETURN f_exist_sw
#          END IF
#}
#         LET p_benp.bank_code          =  f_psrf.bank_code
#         LET p_benp.swift_code         =  f_psrf.swift_code
#         LET p_benp.bank_account_e     =  f_psrf.bank_account_e
#         LET p_benp.bank_name_e        =  f_psrf.bank_name_e
#         LET p_benp.payee_e            =  f_psrf.payee_e
#         LET p_benp.bank_address_e     =  f_psrf.bank_address_e
#
#display 'psrf  p_no = ',p_benf.policy_no ,' ',p_benf.client_id
#         LET f_exist_sw                 = "Y"
#     END IF
#   RETURN f_exist_sw
#
#END FUNCTION
#
#------------------------------------------------------------------------------
#--  程式名稱: get_account_7
#--  日    期: 100/03/11
#--  處理概要:
#------------------------------------------------------------------------------
#
#FUNCTION get_account_7()
#   DEFINE f_dbdd    RECORD LIKE dbdd.*
#   DEFINE f_exist_sw                    CHAR(1)
#   DEFINE   f_err   CHAR(01)
#   DEFINE   f_mes   CHAR(40)
#   DEFINE   f_payee_en_ind CHAR
#
#   LET f_exist_sw                 = "N"   
#
#
#   DECLARE dbdd_cur_ptr CURSOR FOR
#      SELECT * 
#      FROM   dbdd
#      WHERE  reference_code = p_benf.policy_no
#      AND    disb_sts_code = "R" --測試用A
#      AND    function_code LIKE 'R%' 
#      AND    payee_id = p_benf.client_id
#      ORDER BY process_date DESC, process_time DESC
#
#   OPEN dbdd_cur_ptr
#   FOREACH dbdd_cur_ptr INTO f_dbdd.*
#         IF LENGTH ( f_dbdd.remit_swift_code CLIPPED ) != 0 THEN
#            CALL chk_foreignacct( "0" , f_dbdd.remit_swift_code ,f_dbdd.remit_account)
#               Returning f_err, f_payee_en_ind, f_mes
#            IF f_err  THEN
#display p_benf.policy_no ,f_mes
#               RETURN f_exist_sw
#            ELSE
#               IF f_payee_en_ind = "Y"
#               AND LENGTH ( f_dbdd.payee ) = 0
#               THEN
#display p_benf.policy_no ,"dbdd=該SW英文名字為必要輸入。"
#                  RETURN f_exist_sw
#               END IF
#            END  IF
#
#         ELSE  -- 無remit_swift_code,則需有remit_bank_name及remit_address
#            IF LENGTH( f_dbdd.remit_bank_name CLIPPED )=0
#            OR LENGTH( f_dbdd.remit_bank_address   CLIPPED )=0
#            THEN
#display p_benf.policy_no ,"銀行名稱,地址不可為空白:"
#               RETURN f_exist_sw
#            END IF
#
#            IF LENGTH ( f_dbdd.payee ) = 0
#            THEN
#display p_benf.policy_no , "受款人不可為空白"
#               RETURN f_exist_sw
#            END IF
#
#         END IF
#         IF LENGTH ( f_dbdd.remit_account CLIPPED ) = 0
#         THEN
#display p_benf.policy_no , "帳號不可為空白"
#            RETURN f_exist_sw
#         END IF
#
#         LET p_benp.bank_code          =  f_dbdd.remit_bank clipped,f_dbdd.remit_branch clipped
#         LET p_benp.swift_code         =  f_dbdd.remit_swift_code
#         LET p_benp.bank_account_e     =  f_dbdd.remit_account
#         LET p_benp.bank_name_e        =  f_dbdd.remit_bank_name
#         LET p_benp.payee_e            =  f_dbdd.payee
#         LET p_benp.bank_address_e     =  f_dbdd.remit_bank_address
#
#         LET f_exist_sw                 = "Y"
#         EXIT FOREACH
#     END FOREACH 
#     RETURN f_exist_sw
#END FUNCTION
