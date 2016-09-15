----------------------------------------------------------------------------
-- 程式代碼: psca02m.4gl 
-- 處理概要: 還本未回領取作業
-- lib     : psca01s ,psca02s 
-- 修    改: 103/12/29 修改報表列印資料產出的排序
--           105/01/08 SR151200331 未回領取提示訊息修改(pyliu)
----------------------------------------------------------------------------

DATABASE life 

   GLOBALS "../def/common.4gl"
   GLOBALS "../def/lf.4gl"
   GLOBALS "../def/report.4gl"
   GLOBALS "../def/omsg.4gl"
   GLOBALS "../def/disburst.4gl"
   GLOBALS "../def/pscgcpn.4gl"
   GLOBALS "../def/pscgchk.4gl"

   --**** 不重要 ****--
   DEFINE p_today             CHAR(9)      --就是今天
   DEFINE p_user_code         CHAR(8)
   DEFINE p_user_id           CHAR(10)
   DEFINE p_user_name         VARCHAR(40)
   DEFINE p_dept_code         CHAR(6)

   --**** 新增修改 保單號碼輸入 ****--
   DEFINE p_po_inp RECORD
          policy_no           LIKE pscah.policy_no     ,
          po_chg_rece_no      LIKE apdt.po_chg_rece_no
   END RECORD

   --**** 新增修改 保單資訊顯示 ****--
   DEFINE p_po_dis RECORD 
          names          LIKE clnt.names          ,
          currency       LIKE polf.currency       ,
          po_issue_date  LIKE polf.po_issue_date  ,
          paid_to_date   LIKE polf.paid_to_date   ,
          po_sts_code    LIKE polf.po_sts_code    ,
          agent_name     LIKE pscah.agent_name   
   END RECORD
   DEFINE p_agent_code   LIKE poag.agent_code  

   --**** 新增修改 畫面二 週年日顯示 ***--
   DEFINE p_anniv_2             ARRAY[200] OF RECORD
               cp_anniv_date       LIKE pscah.cp_anniv_date      ,
               plan_code           LIKE pldf.plan_code           ,
               rate_scale          LIKE pldf.rate_scale          ,
               status              CHAR(2)                       ,
               nonresp_sw          LIKE psck.nonresp_sw          ,
               payee               LIKE pscad.payee              ,
               cp_amt              LIKE pscr.cp_amt              ,
               check_no            LIKE pscad.check_no           ,
               relation_desc       CHAR(2)                                         
   END RECORD
   DEFINE p_anniv             ARRAY[200] OF RECORD                                      
          F1_inp              RECORD
              ca_disb_type       LIKE pscah.ca_disb_type         ,
              mail_addr          LIKE pscah.mail_addr       
          END RECORD                                                          ,
          --****抵繳保費****--
          prem_po             ARRAY[10] OF LIKE pscae.policy_no               ,
          prem_po_arr         INTEGER                                         ,
          prem_po_scr         INTEGER                                         ,
          prem_po_cnt         INTEGER                                         ,
          --****匯款帳號****--
          remit               ARRAY[10] OF RECORD
              check_no           LIKE dbdd.check_no              ,
              ori_id             LIKE pscd.client_id             ,
              ori_name           LIKE pscd.names                 ,
              new_id             LIKE pscad.payee_id             ,
              new_name           LIKE pscad.payee                ,
              remit_bank         LIKE pscad.remit_bank           ,
              remit_branch       LIKE pscad.remit_branch         ,
              remit_account      LIKE pscad.remit_account        ,
              payee_code         LIKE pscad.payee_code           ,
              bank_name          LIKE bank.bank_name 
          END RECORD                                                          ,
          benf_ratio          ARRAY[10] OF LIKE benf.benf_ratio               ,
          disb_no             ARRAY[10] OF LIKE dbdd.disb_no                  ,
          remit_arr           INTEGER                                         ,
          remit_scr           INTEGER                                         ,
          remit_cnt           INTEGER                                                   
   END RECORD 
   DEFINE p_anniv_cnt         INTEGER 
   DEFINE p_anniv_arr         INTEGER 
   DEFINE p_anniv_scr         INTEGER 
   DEFINE p_anniv_choose      ARRAY[200] OF CHAR(1)

   --**** 還本未回照會視窗 ****--
   DEFINE p_psca02m04_inp   RECORD 
          policy_no       LIKE pscah.policy_no
   END RECORD

MAIN 
   
   DEFER INTERRUPT
   SET LOCK MODE TO WAIT
   
   CALL psca02m_before_menu()
   
   MENU "請選擇" 
      BEFORE MENU
         CALL ShowLogo()
         IF NOT CheckAuthority( "1" ,FALSE ) THEN
            HIDE OPTION "1)新增修改"
         END IF
         IF NOT CheckAuthority( "2" ,FALSE ) THEN
            HIDE OPTION "2)還本未回照會"
         END IF
         IF NOT CheckAuthority( "3" ,FALSE ) THEN
            HIDE OPTION "3)還本未回上傳"
         END IF
         IF NOT CheckAuthority( "4" ,FALSE ) THEN
            HIDE OPTION "4)報表列印"
         END IF
      COMMAND "1)新增修改"
                 CALL int_flag_init()
                 IF NOT psca02m_edit() THEN 
                    CONTINUE MENU
                 END IF 
      COMMAND "2)還本未回照會"
                 CALL int_flag_init()    
                 IF NOT psca02m_notice() THEN 
                    CONTINUE MENU
                 END IF 
      COMMAND "3)還本未回上傳"
                 CALL int_flag_init()
                 IF not psca02m_cad_sts_Update() THEN
                    CONTINUE MENU
                 END IF 
      COMMAND "4)報表列印"
                 CALL int_flag_init()
                 IF not psca02m_print() THEN
                    CONTINUE MENU
                 END IF
      COMMAND "0)結束"
                 EXIT MENU

   END MENU

END MAIN 

FUNCTION psca02m_before_menu()

   OPTIONS
      ERROR   LINE LAST
    , PROMPT  LINE LAST - 1
    , MESSAGE LINE LAST
    , COMMENT LINE LAST

   LET g_program_id ="psca02m"
   LET p_today = GetDate(TODAY)
   CALL JobControl()
   CALL GetUserData(g_user) RETURNING p_user_code   ,
                                      p_user_id     ,
                                      p_user_name   ,
                                      p_dept_code   
   CALL ShowLogo()
   OPEN FORM s_psca02m01 FROM "psca02m01"
   DISPLAY FORM s_psca02m01 ATTRIBUTE (GREEN)

END FUNCTION --psca02m_before_menu END 

FUNCTION int_flag_init()
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
   END IF 
END FUNCTION --int_flag_init END

FUNCTION psca02m_edit()  
   DEFINE f_ix             INTEGER
   DEFINE f_cnt            INTEGER
   DEFINE f_tran_ok        INTEGER 

   DISPLAY FORM s_psca02m01 ATTRIBUTE (GREEN)
   CALL ShowLogo()

   --**** 新增修改畫面 輸入保單號碼跟選取受理號碼 ****--
   INITIALIZE p_po_inp TO NULL
   IF NOT po_inp() THEN
      RETURN 0
   END IF

   --**** 新增修改畫面 顯示要保人~業務員資訊 ****--
   --**** 初始化 ****--
   INITIALIZE p_po_dis TO NULL
   LET p_agent_code = " "
   INITIALIZE g_polf TO NULL
   CALL po_dis()
   DISPLAY BY NAME p_po_dis.*
   SELECT  a.names        ,
           a.client_id    ,
           a.remit_bank   ,
           a.remit_branch ,
           a.remit_account,
           b.names as new_name 
   FROM    benf a ,clnt b
   WHERE   1 = 2 
   INTO TEMP benf_tmp WITH NO LOG ;
   --**** 初始化 ****--
   FOR f_ix = 1 TO 200 
       INITIALIZE p_anniv[f_ix] TO NULL
       LET p_anniv[f_ix].prem_po_cnt = 0
       LET p_anniv[f_ix].remit_cnt   = 0
       LET p_anniv_choose[f_ix] = " "
   END FOR 
   LET p_anniv_cnt = 0
   CALL anniv_data()
   IF p_anniv_cnt = 0 THEN 
      CALL err_touch("查無資料")
      DROP TABLE benf_tmp ;
      RETURN 0
   END IF            
   IF NOT psca02m_display_anniv_date() THEN
      DROP TABLE benf_tmp;
      RETURN 0
   END IF
   --**** 逐週年日做交易 ****--
   LET f_tran_ok = 1
   BEGIN WORK
   FOR f_ix = 1 TO p_anniv_cnt
       IF NOT validChar( p_anniv_2[f_ix].cp_anniv_date ) THEN
          CONTINUE FOR
       END IF
       IF p_anniv_choose[f_ix] != "1" THEN
          CONTINUE FOR
       END IF
       LET f_tran_ok = psca02m_psca_tran( f_ix )
       IF NOT f_tran_ok THEN --pscah ,pscad ,pscae
          CALL err_touch( "交易失敗，洽資訊部" )
          EXIT FOR 
       END IF
   END FOR
   IF NOT f_tran_ok THEN
      ROLLBACK WORK
      DROP TABLE benf_tmp ;
      RETURN 0
   END IF
   COMMIT WORK 
   
   DROP TABLE benf_tmp;
   RETURN 1
END FUNCTION --psca02m_edit END 

FUNCTION po_inp()
   DEFINE f_psck_cnt        INTEGER 
   
   INPUT BY NAME p_po_inp.*  WITHOUT DEFAULTS ATTRIBUTE(BLUE ,REVERSE)
         BEFORE FIELD po_chg_rece_no
            LET p_po_inp.po_chg_rece_no = psca01s_rece_no_show( p_po_inp.policy_no ) 
            DISPLAY BY NAME p_po_inp.po_chg_rece_no 
         ON KEY (F6)
            CALL psca01s_rece_no_show( p_po_inp.policy_no ) 
                 RETURNING p_po_inp.po_chg_rece_no
            DISPLAY BY NAME p_po_inp.po_chg_rece_no
         AFTER FIELD po_chg_rece_no
            IF NOT validChar( p_po_inp.po_chg_rece_no ) THEN
               CALL err_touch( "請輸入受理號碼" )
               NEXT FIELD po_chg_rece_no
            END IF
         AFTER INPUT
            IF INT_FLAG THEN 
               CALL err_touch( "已選擇放棄輸入" )
               EXIT INPUT 
            END IF 
            SELECT   COUNT(*)
            INTO     f_psck_cnt
            FROM     psck a ,polf b 
            WHERE    a.policy_no = p_po_inp.policy_no 
            AND      a.policy_no = b.policy_no
            AND      a.nonresp_sw = "Y"
            AND      b.currency = "TWD"
            IF f_psck_cnt = 0 THEN 
               CALL err_touch( "本保單無尚未領取之生存／滿期保險金" )
               EXIT INPUT
            END IF 
   END INPUT
   IF f_psck_cnt = 0 OR 
      INT_FLAG       THEN 
      RETURN 0
   END IF 
   RETURN 1 
END FUNCTION --po_inp END 

FUNCTION po_dis()   

   SELECT      currency        ,
               po_issue_date   ,
               paid_to_date    ,
               po_sts_code     ,
               *     
   INTO        p_po_dis.currency        ,
               p_po_dis.po_issue_date   ,
               p_po_dis.paid_to_date    ,
               p_po_dis.po_sts_code     ,
               g_polf.*
   FROM        polf
   WHERE       policy_no = p_po_inp.policy_no
   
   SELECT      b.names
   INTO        p_po_dis.names
   FROM        pocl a ,clnt b
   WHERE       a.policy_no = p_po_inp.policy_no
   AND         a.client_ident = "O1"
   AND         a.client_id = b.client_id
  
   SQL
             SELECT      FIRST 1 b.names ,
                                 a.agent_code  
             INTO        $p_po_dis.agent_name ,
                          $p_agent_code
             FROM        poag a , clnt b
             WHERE       a.policy_no = $p_po_inp.policy_no 
             AND         a.relation = "S"
             AND         a.agent_code = b.client_id
   END SQL
    
END FUNCTION --po_dis END

FUNCTION anniv_data()
   DEFINE f_psck          RECORD LIKE psck.*
   DEFINE f_pscd          RECORD LIKE pscd.*
   DEFINE f_pscb          RECORD LIKE pscb.*
   DEFINE f_ix            INTEGER
   DEFINE f_cp_anniv_date_old CHAR(9)
   DEFINE f_pscad_cnt     INTEGER
   
   LET f_ix = p_anniv_cnt
   LET f_cp_anniv_date_old = " "
   DECLARE anniv_cur CURSOR WITH HOLD FOR 
      SELECT   *
      FROM     psck a ,outer pscd b ,outer pscb d
      WHERE    a.policy_no     = p_po_inp.policy_no 
      AND      a.nonresp_sw    = "Y"
      AND      a.policy_no     = b.policy_no 
      AND      a.cp_anniv_date = b.cp_anniv_date 
      AND      a.policy_no     = d.policy_no 
      AND      a.cp_anniv_date = d.cp_anniv_date 
      ORDER BY a.policy_no ,a.cp_anniv_date ,b.cp_pay_seq 
   FOREACH anniv_cur INTO f_psck.* ,f_pscd.* ,f_pscb.*
      LET f_ix = f_ix + 1
      LET p_anniv_2[f_ix].cp_anniv_date = " "
      LET p_anniv_2[f_ix].plan_code     = " "
      LET p_anniv_2[f_ix].rate_scale    = " "
      LET p_anniv_2[f_ix].status        = " "
      LET p_anniv_2[f_ix].nonresp_sw    = " "
      IF f_cp_anniv_date_old != f_psck.cp_anniv_date THEN
         LET p_anniv_2[f_ix].cp_anniv_date  = f_psck.cp_anniv_date
         LET p_anniv_2[f_ix].plan_code      = g_polf.basic_plan_code
         LET p_anniv_2[f_ix].rate_scale     = g_polf.basic_rate_scale
         LET p_anniv_2[f_ix].status = psca01s_status( f_pscb.cp_sw ,f_pscb.cp_notice_sw )
         LET p_anniv_2[f_ix].nonresp_sw     = " "
         IF f_psck.nonresp_sw = "Y" THEN 
            LET p_anniv_2[f_ix].nonresp_sw = "*"
         END IF 
      END IF
      LET p_anniv_2[f_ix].payee = f_pscd.names 
      LET p_anniv_2[f_ix].cp_amt = f_pscd.cp_real_payamt
      SELECT    check_no  
      INTO      p_anniv_2[f_ix].check_no 
      FROM      dbdd
      WHERE     disb_no = f_pscd.disb_no
      LET p_anniv_2[f_ix].relation_desc = "生"
      IF f_psck.cp_anniv_date >= g_polf.expired_date THEN 
         LET p_anniv_2[f_ix].relation_desc = "滿"
      END IF             
      LET f_cp_anniv_date_old = f_psck.cp_anniv_date      
   END FOREACH --anniv_cur
   LET p_anniv_cnt = f_ix
END FUNCTION --anniv_data END 

FUNCTION psca02m_display_anniv_date()
   DEFINE f_prompt         VARCHAR(250)
   DEFINE f_prompt_ans     INTEGER
   DEFINE f_check_msg      VARCHAR(250)
   DEFINE f_err            INTEGER 
   DEFINE f_press_key      VARCHAR(20)
   DEFINE f_anniv_date     CHAR(9)
   DEFINE f_data_ok        INTEGER 
   DEFINE f_ix             INTEGER
   DEFINE f_B1_B3_sw       INTEGER
   DEFINE f_exit_display   INTEGER
   DEFINE f_save_data      INTEGER
   DEFINE f_err_cnt        INTEGER
     
   CALL SET_COUNT( p_anniv_cnt )
   DISPLAY ARRAY p_anniv_2 TO psca02m01_s2.* ATTRIBUTE ( YELLOW ) 
      ON KEY ( F1 )
         LET f_err = 0
         CALL psca01s_Cursor() RETURNING p_anniv_scr ,p_anniv_arr
         LET p_anniv_choose[p_anniv_arr] = " "
         CALL psca02m_F1_edit()
         CALL psca02m_check_err() RETURNING f_err ,f_check_msg
         --**** 檢查支票有系統例外狀況 ****--
         IF f_err = 1 THEN 
            LET f_check_msg = "不在系統規則內，洽資訊部:",f_check_msg CLIPPED 
            CALL err_touch( f_check_msg CLIPPED )
            EXIT DISPLAY 
         END IF
      ON KEY ( DOWN ,UP ,RETURN )
         CALL psca01s_Cursor() RETURNING p_anniv_scr ,p_anniv_arr
         CALL psca02m_DownUp_press() RETURNING f_press_key
         --**** 跑到新的週年日的設定 ****--
         --**** 設定新的游標位置 ****--
         CALL psca02m01_s2_next_position( f_press_key )
              RETURNING p_anniv_scr ,p_anniv_arr
         --**** 游標跑到新的位置 ****--
         CALL FGL_SETCURRLINE( p_anniv_scr ,p_anniv_arr )
      ON KEY(ACCEPT ,ESC)
         LET f_save_data = 0
         LET f_B1_B3_sw  = 0       
         CALL psca02m02_s2_data_ok() RETURNING f_data_ok ,f_err_cnt
         LET f_exit_display = 0
         IF f_data_ok THEN 
            IF NOT psca01s_promptSave("請確認存檔") THEN 
               LET f_err = 1 
               EXIT DISPLAY
            ELSE
               LET f_exit_display = 1
            END IF
         END IF
         IF NOT f_data_ok THEN         
            LET f_prompt = "尚有",f_err_cnt USING "#&" ,"個週年日未正確回覆，確認要存檔"
            LET f_prompt_ans = psca01s_promptSave( f_prompt )
            IF f_prompt_ans = 0 THEN
               LET f_exit_display = 0
               CALL FGL_SETCURRLINE(1 ,1)
            ELSE
               LET f_exit_display = 1
            END IF
         END IF
         WHILE ( f_data_ok = 0 AND f_prompt_ans = 1 ) OR 
                 f_data_ok = 1
            --**** 判斷是要出受理結案訊息或是確認請存檔訊息 ****--
            LET f_B1_B3_sw = psca02m_B1_B3_status( p_po_inp.policy_no )
            IF NOT f_B1_B3_sw THEN
               CALL ap905_update_sts(p_po_inp.po_chg_rece_no,'5')
               EXIT WHILE
            END IF
            -- SR151200331
			IF psca01s_promptSave("建檔完成,尚有還本金未領取,受理流程是否結案?") THEN
               CALL ap905_update_sts(p_po_inp.po_chg_rece_no,'5')
               EXIT WHILE
            END IF   
            EXIT WHILE
         END WHILE
         IF f_exit_display THEN 
            EXIT DISPLAY
         END IF
   END DISPLAY 
   IF f_err    OR 
      INT_FLAG THEN 
      RETURN 0
   END IF
   RETURN 1
END FUNCTION --psca02m_display_anniv_date END 

FUNCTION psca02m01_s2_next_position( f_press_key )
   DEFINE f_press_key  VARCHAR(200)

   WHILE TRUE   
      IF f_press_key = "DOWN" OR f_press_key = "RETURN" THEN
         LET p_anniv_arr = p_anniv_arr + 1
         LET p_anniv_scr = p_anniv_scr + 1
      END IF 
      IF f_press_key = "UP" THEN
         LET p_anniv_arr = p_anniv_arr - 1
         LET p_anniv_scr = p_anniv_scr - 1
      END IF
      --**** 不能超出邊界 ****--
      IF p_anniv_arr < 1 THEN 
         LET p_anniv_arr = p_anniv_arr + 1
      END IF 
      IF p_anniv_arr > ARR_COUNT() THEN
         LET p_anniv_arr = p_anniv_arr - 1
      END IF
      IF p_anniv_scr < 1 THEN 
         LET p_anniv_scr = p_anniv_scr + 1
      END IF 
      IF p_anniv_scr > FGL_SCR_SIZE( "psca02m01_s2" ) THEN 
         LET p_anniv_scr = p_anniv_scr - 1
      END IF
      --****最後一筆有空列 ****-- 
      IF validChar( p_anniv_2[p_anniv_arr].cp_anniv_date ) = 0 THEN
         IF p_anniv_arr = ARR_COUNT() THEN
            LET f_press_key = "UP"  
         END IF
         CONTINUE WHILE 
      END IF
      EXIT WHILE
   END WHILE    
   RETURN p_anniv_scr ,p_anniv_arr
END FUNCTION --psca02m01_s2_next_position END 

FUNCTION psca02m_F1_edit()
   DEFINE f_ix             INTEGER

   ------過保證期再次確認------
   IF psc_after_gee_chk( p_po_inp.policy_no                    ,
                         p_anniv_2[p_anniv_arr].cp_anniv_date ) THEN
      IF NOT psca01s_promptSave( "本次生存金為非保證給付期，請做被保險人之生存認證" ) THEN
         RETURN 
      END IF 
   END IF     
   
   OPEN WINDOW s_psca02m02 AT 9,1 WITH FORM "psca02m02" ATTRIBUTE(GREEN, FORM LINE FIRST)
   DISPLAY BY NAME p_anniv_2[p_anniv_arr].cp_anniv_date ATTRIBUTE(YELLOW)
   --**** 讀資料 ****--
   IF NOT validChar( p_anniv[p_anniv_arr].F1_inp.ca_disb_type ) THEN
      SELECT  ca_disb_type ,mail_addr
      INTO    p_anniv[p_anniv_arr].F1_inp.*
      FROM    pscah
      WHERE   policy_no     = p_po_inp.policy_no 
      AND     cp_anniv_date = p_anniv_2[p_anniv_arr].cp_anniv_date
   END IF
   --**** user輸入付款方式 ****--
   IF NOT psca02m_input_payway() THEN
      CLOSE WINDOW s_psca02m02 
      RETURN
   END IF
   --**** 輸入匯款行 匯款分行 匯款帳號 ****--
   IF p_anniv[p_anniv_arr].remit_cnt = 0 THEN
      CALL psca02m_load_remit()
   END IF
   IF NOT psca02m_input_remit_arr() THEN
      CLOSE WINDOW s_psca02m02
      RETURN
   END IF
   LET p_anniv_choose[p_anniv_arr] = "1"
   CLOSE WINDOW s_psca02m02
END FUNCTION -- psca02m_F1_edit END 

FUNCTION psca02m_DownUp_press()
   
   IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
      RETURN "DOWN" 
   END IF 
   IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
      RETURN "UP" 
   END IF
   IF FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
      RETURN "RETURN"
   END IF
   RETURN "OTHER"
END FUNCTION --psca02m_DownUp_press END 

FUNCTION psca02m_load_remit()
   DEFINE f_pscd         RECORD LIKE pscd.*
   DEFINE f_pscad        RECORD LIKE pscad.*
   DEFINE f_ix           INTEGER
   DEFINE f_relation     CHAR(1)

   LET f_ix = p_anniv[p_anniv_arr].remit_cnt
   DECLARE remit_cur CURSOR WITH HOLD FOR
      SELECT    * 
      FROM      pscd b ,outer pscad c
      WHERE     b.policy_no     = p_po_inp.policy_no
      AND       b.cp_anniv_date = p_anniv_2[p_anniv_arr].cp_anniv_date
      AND       b.policy_no     = c.policy_no 
      AND       b.cp_anniv_date = c.cp_anniv_date 
      AND       b.disb_no       = c.disb_no
      ORDER BY  b.disb_no
   FOREACH remit_cur INTO f_pscd.* ,f_pscad.*
      LET f_ix = f_ix + 1
      SELECT  check_no 
      INTO    p_anniv[p_anniv_arr].remit[f_ix].check_no
      FROM    dbdd 
      WHERE   disb_no = f_pscd.disb_no
      LET p_anniv[p_anniv_arr].remit[f_ix].ori_id   = f_pscd.client_id
      LET p_anniv[p_anniv_arr].remit[f_ix].ori_name = f_pscd.names 
      LET p_anniv[p_anniv_arr].remit[f_ix].new_id   = f_pscad.payee_id
      LET p_anniv[p_anniv_arr].remit[f_ix].new_name = f_pscad.payee
      LET p_anniv[p_anniv_arr].remit[f_ix].remit_bank    = f_pscad.remit_bank
      LET p_anniv[p_anniv_arr].remit[f_ix].remit_branch  = f_pscad.remit_branch
      LET p_anniv[p_anniv_arr].remit[f_ix].remit_account = f_pscad.remit_account
      LET p_anniv[p_anniv_arr].remit[f_ix].payee_code    = f_pscad.payee_code
      SELECT    bank_name 
      INTO      p_anniv[p_anniv_arr].remit[f_ix].bank_name
      FROM      bank
      WHERE     bank_code[1,3] = p_anniv[p_anniv_arr].remit[f_ix].remit_bank
      AND       bank_code[4,7] = p_anniv[p_anniv_arr].remit[f_ix].remit_branch
      LET p_anniv[p_anniv_arr].benf_ratio[f_ix] = f_pscd.benf_ratio
      LET p_anniv[p_anniv_arr].disb_no[f_ix]    = f_pscd.disb_no 
   END FOREACH 
   LET p_anniv[p_anniv_arr].remit_cnt = f_ix
   RETURN 
END FUNCTION --psca02m_load_remit END

FUNCTION psca02m02_remit_chk( f_anniv_arr )
   DEFINE f_ix        INTEGER
   DEFINE f_err       INTEGER
   DEFINE f_anniv_arr INTEGER 

   LET f_err = 0
   FOR f_ix = 1 TO p_anniv[f_anniv_arr].remit_cnt
       IF p_anniv[f_anniv_arr].F1_inp.ca_disb_type != "2" THEN
          CONTINUE FOR
       END IF 
       IF validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_bank    ) = 0 OR 
          validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_branch  ) = 0 OR 
          validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_account ) = 0 THEN
          LET f_err = 1
          EXIT FOR
       END IF
       IF NOT psca02m02_remit_bank( p_anniv[f_anniv_arr].remit[f_ix].remit_bank ) THEN
          LET f_err = 1
          EXIT FOR
       END IF
       IF NOT psca02m02_remit_acct( p_anniv[f_anniv_arr].remit[f_ix].remit_bank   ,
                                    p_anniv[f_anniv_arr].remit[f_ix].remit_branch ,
                                    p_anniv[f_anniv_arr].remit[f_ix].remit_account) THEN
          LET f_err = 1
          EXIT FOR
       END IF
   END FOR
   IF f_err THEN 
      RETURN 0
   END IF
   FOR f_ix = 1 TO p_anniv[f_anniv_arr].remit_cnt
       IF p_anniv[f_anniv_arr].F1_inp.ca_disb_type = "2" THEN
          CONTINUE FOR
       END IF 
       IF validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_bank    ) = 1 OR 
          validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_branch  ) = 1 OR 
          validChar( p_anniv[f_anniv_arr].remit[f_ix].remit_account ) = 1 THEN
          LET f_err = 1
          EXIT FOR
       END IF
   END FOR
   IF f_err THEN 
      RETURN 0
   END IF
   RETURN 1
END FUNCTION --psca02m02_remit_chk END 

FUNCTION psca02m_check_err()
   DEFINE f_ix           INTEGER 
   DEFINE f_err          INTEGER 
   DEFINE f_err_msg      VARCHAR(250)
   DEFINE f_nonresp_sw   CHAR(1)
  
   LET f_ix = p_anniv_arr 
   CALL psca02s01_load_pscd( g_polf.policy_no                   ,
                             p_anniv_2[f_ix].cp_anniv_date )
   CALL psca02s00( p_anniv_2[f_ix].cp_anniv_date ) RETURNING f_err     ,
                                                             f_err_msg ,
                                                             f_nonresp_sw
   RETURN f_err ,f_err_msg
END FUNCTION --psca02m_check_err END

FUNCTION psca02m02_s2_data_ok()
    DEFINE f_ix          INTEGER
    DEFINE f_err_cnt     INTEGER 

    LET f_err_cnt = 0
    --**** 有週年日放棄 ****--
    FOR f_ix = 1 TO p_anniv_cnt       
        IF p_anniv_choose[f_ix] = "0" OR 
            p_anniv_choose[f_ix] = " " THEN 
            LET f_err_cnt = f_err_cnt + 1
        END IF 
    END FOR    

    --**** 正確回覆的寫入p_anniv_choose ****--
    FOR f_ix = 1 TO p_anniv_cnt       
        IF NOT validChar( p_anniv_2[f_ix].cp_anniv_date ) THEN
            CONTINUE FOR
        END IF
        IF p_anniv_choose[f_ix] = "0" OR 
            p_anniv_choose[f_ix] = " " THEN 
            CONTINUE FOR 
        END IF   
        IF NOT psca01s_fieldChk( "ca_disb_type" ,p_anniv[f_ix].F1_inp.ca_disb_type ) THEN
            LET f_err_cnt = f_err_cnt + 1
            CONTINUE FOR
        END IF
        IF NOT psca02m02_remit_chk( f_ix ) THEN
            LET f_err_cnt = f_err_cnt + 1
            CONTINUE FOR
        END IF
    END FOR    
    IF f_err_cnt > 0 THEN
        RETURN 0 ,f_err_cnt
    ELSE 
        RETURN 1 ,0
    END IF 
END FUNCTION --psca02m02_s2_data_ok END 

FUNCTION psca02m_psca_tran( f_anniv_ix )
   DEFINE f_pscah        RECORD LIKE pscah.*
   DEFINE f_pscad        RECORD LIKE pscad.*
   DEFINE f_pscah_cnt    INTEGER 
   DEFINE f_ix           INTEGER
   DEFINE f_err          INTEGER
   DEFINE f_err_msg      VARCHAR(250)
   DEFINE f_anniv_ix     INTEGER 
   DEFINE f_status       INTEGER

   LET f_err = 0
   LET f_err_msg = " "
   LET f_status = STATUS
 
   SELECT COUNT(*)
   INTO   f_pscah_cnt 
   FROM   pscah
   WHERE  policy_no            = p_po_inp.policy_no
   AND    cp_anniv_date        = p_anniv_2[f_anniv_ix].cp_anniv_date
   LET f_pscah.policy_no       = p_po_inp.policy_no 
   LET f_pscah.cp_anniv_date   = p_anniv_2[f_anniv_ix].cp_anniv_date
   LET f_pscah.po_chg_rece_no  = p_po_inp.po_chg_rece_no 
   LET f_pscah.agent_code      = p_agent_code
   LET f_pscah.agent_name      = p_po_dis.agent_name
   LET f_pscah.ca_disb_type    = p_anniv[f_anniv_ix].F1_inp.ca_disb_type 
   LET f_pscah.mail_addr       = p_anniv[f_anniv_ix].F1_inp.mail_addr
   LET f_pscah.glkk_dept       = p_dept_code 
   LET f_pscah.crt_user        = p_user_code 
   LET f_pscah.crt_date        = p_today
   LET f_pscah.crt_time        = CURRENT hour TO second
   WHENEVER ERROR CONTINUE
   --**** 交易 pscah ****--
   IF f_pscah_cnt = 0 THEN 
      INSERT INTO pscah VALUES( f_pscah.* )
      LET f_status = STATUS
   END IF
   IF f_pscah_cnt > 0 THEN 
      UPDATE pscah
      SET    agent_code   = f_pscah.agent_code     ,
             agent_name   = f_pscah.agent_name     , 
             ca_disb_type = f_pscah.ca_disb_type   ,
             mail_addr    = f_pscah.mail_addr      ,
             glkk_dept    = f_pscah.glkk_dept      ,
             crt_user     = f_pscah.crt_user       ,
             crt_date     = f_pscah.crt_date       ,
             crt_time     = f_pscah.crt_time 
      WHERE  policy_no     = f_pscah.policy_no 
      AND    cp_anniv_date = f_pscah.cp_anniv_date 
      LET f_status = STATUS
   END IF 
   IF SQLCA.SQLCODE != 0 THEN
      LET f_err_msg = p_po_inp.policy_no,"*",p_anniv_2[f_anniv_ix].cp_anniv_date ,
                      "交易有誤:pscah" ,ERR_GET( f_status ) CLIPPED
      CALL err_touch( f_err_msg )
      WHENEVER ERROR STOP
      RETURN 0
   END IF

   --***** 交易 pscad ****--
   FOR f_ix = 1 TO p_anniv[f_anniv_ix].remit_cnt
       LET f_pscad.policy_no     = f_pscah.policy_no 
       LET f_pscad.cp_anniv_date = f_pscah.cp_anniv_date
       INITIALIZE g_dbdd TO NULL
       SELECT  *
       INTO    g_dbdd.*
       FROM    dbdd
       WHERE   disb_no = p_anniv[f_anniv_ix].disb_no[f_ix]
       LET f_pscad.check_no      = g_dbdd.check_no 
       LET f_pscad.cad_sts_code  = "0"
       LET f_pscad.msg_content   = " "
       LET f_pscad.cad_sts_date  = p_today
       
       LET f_pscad.benf_ratio    = p_anniv[f_anniv_ix].benf_ratio[f_ix]
       LET f_pscad.remit_bank    = p_anniv[f_anniv_ix].remit[f_ix].remit_bank
       LET f_pscad.payee_code    = p_anniv[f_anniv_ix].remit[f_ix].payee_code
       LET f_pscad.remit_branch  = p_anniv[f_anniv_ix].remit[f_ix].remit_branch
       LET f_pscad.remit_account = p_anniv[f_anniv_ix].remit[f_ix].remit_account
       LET f_pscad.disb_no       = p_anniv[f_anniv_ix].disb_no[f_ix]
       LET f_pscad.glkk_ind      = psca02m_glkk_ind( p_anniv[f_anniv_ix].F1_inp.ca_disb_type ) 
       IF f_pscad.glkk_ind = "X" THEN
          LET f_err = 1 
          LET f_err_msg =  p_po_inp.policy_no,"*",p_anniv_2[f_anniv_ix].cp_anniv_date ,
                           "支票狀態有誤:",g_dbdd.disb_sts_code
          CALL err_touch( f_err_msg )
          EXIT FOR
       END IF
       LET f_pscad.payee_id      = p_anniv[f_anniv_ix].remit[f_ix].new_id
       LET f_pscad.payee         = p_anniv[f_anniv_ix].remit[f_ix].new_name
       LET f_pscad.disb_sts_code = g_dbdd.disb_sts_code 
       LET f_pscad.crt_user      = f_pscah.crt_user
       LET f_pscad.crt_date      = p_today
       LET f_pscad.crt_time      = CURRENT hour TO second
       IF f_pscah_cnt = 0 THEN 
          INSERT INTO pscad VALUES( f_pscad.* )
          LET f_status = STATUS
       END IF
       IF f_pscah_cnt > 0 THEN
          UPDATE pscad
          SET    * = ( f_pscad.* )
          WHERE  policy_no     = f_pscad.policy_no 
          AND    cp_anniv_date = f_pscad.cp_anniv_date 
          AND    check_no      = f_pscad.check_no
          LET f_status = STATUS
       END IF 
       IF SQLCA.SQLCODE != 0 THEN 
          LET f_err_msg = p_po_inp.policy_no,"*",p_anniv_2[f_anniv_ix].cp_anniv_date ,
                          "交易有誤: pscad",ERR_GET( f_status ) CLIPPED
          LET f_err = 1
          CALL err_touch( f_err_msg )
          EXIT FOR
       END IF
   END FOR
   IF f_err THEN
      WHENEVER ERROR STOP
      RETURN 0
   END IF   
   --**** 交易 pscae ****--
   DELETE 
   FROM    pscae
   WHERE   join_policy_no = f_pscah.policy_no 
   AND     cp_anniv_date  = f_pscah.cp_anniv_date 
   IF SQLCA.SQLCODE != 0 THEN
      LET f_err_msg = p_po_inp.policy_no,"*",p_anniv_2[f_anniv_ix].cp_anniv_date ,
                      "交易有誤: pscad delete ",ERR_GET( STATUS )  CLIPPED
      LET f_err = 1
      CALL err_touch( f_err_msg )
      WHENEVER ERROR STOP
      RETURN 0
   END IF
   IF f_pscah.ca_disb_type = "3" THEN
      FOR f_ix = 1 TO p_anniv[f_anniv_ix].prem_po_cnt 
          IF p_anniv[f_anniv_ix].prem_po[f_ix] is NULL or p_anniv[f_anniv_ix].prem_po[f_ix] = ''
             OR p_anniv[f_anniv_ix].prem_po[f_ix] = '' OR LENGTH( p_anniv[f_anniv_ix].prem_po[f_ix] ) = 0 THEN
               CONTINUE FOR
          END IF
          INSERT INTO pscae VALUES ( p_anniv[f_anniv_ix].prem_po[f_ix]         ,
                                     f_pscah.cp_anniv_date   ,
                                     f_pscah.policy_no       ,
                                     p_user_code             ,
                                     p_today                 ,
                                     CURRENT hour TO second  )
          IF SQLCA.SQLCODE != 0 THEN
             LET f_err_msg = p_po_inp.policy_no,"*",p_anniv_2[f_anniv_ix].cp_anniv_date ,
                             "交易有誤: pscad delete ",ERR_GET( STATUS )  CLIPPED
             LET f_err = 1
             CALL err_touch( f_err_msg )
             EXIT FOR 
          END IF
      END FOR
      IF f_err THEN
         WHENEVER ERROR STOP
         RETURN 0
      END IF 
   END IF
   WHENEVER ERROR STOP 
   RETURN 1 
END FUNCTION --psca02m_psca_tran END

FUNCTION psca02m_glkk_ind( f_ca_disb_type )
   DEFINE f_ca_disb_type   LIKE pscah.ca_disb_type 

   IF f_ca_disb_type = "1" THEN
      IF g_dbdd.disb_sts_code = "P" OR 
         g_dbdd.disb_sts_code = "S" OR
         g_dbdd.disb_sts_code = "T" THEN
         RETURN "1"
      END IF
   END IF
   IF f_ca_disb_type = "2" THEN
      IF g_dbdd.disb_sts_code = "P" OR 
         g_dbdd.disb_sts_code = "S" OR
         g_dbdd.disb_sts_code = "T" THEN
         RETURN "2"
      END IF
   END IF
   IF f_ca_disb_type = "3" THEN
      IF g_dbdd.disb_sts_code = "P" THEN 
         RETURN "4"
      END IF
      IF g_dbdd.disb_sts_code = "S" OR 
         g_dbdd.disb_sts_code = "T" THEN
         RETURN "3"
      END IF 
   END IF
   IF f_ca_disb_type = "4" THEN 
      IF g_dbdd.disb_sts_code = "P" THEN 
         RETURN "4"
      END IF
      IF g_dbdd.disb_sts_code = "S" OR 
         g_dbdd.disb_sts_code = "T" THEN
         RETURN "3"
      END IF 
   END IF
   RETURN "X"
END FUNCTION --psca02m_glkk_ind END 

FUNCTION psca02m_input_prem_po()
   DEFINE f_prem_po ARRAY[10] OF LIKE polf.policy_no
   DEFINE f_prem_po_cnt            INTEGER
   DEFINE f_ix                INTEGER
   DEFINE f_sts_cnt           INTEGER
   DEFINE f_prompt_ans        INTEGER 
   DEFINE f_prem_po_ix        INTEGER 

   --**** 先備份 ****--
   FOR f_ix = 1 TO 10 
       LET f_prem_po[f_ix] = p_anniv[p_anniv_arr].prem_po[f_ix]
   END FOR
   LET f_prem_po_cnt = p_anniv[p_anniv_arr].prem_po_cnt
   OPEN WINDOW s_psca02m03 AT 11,1 WITH FORM "psca02m03" 
        ATTRIBUTE(GREEN, FORM LINE FIRST)
   CALL SET_COUNT( f_prem_po_cnt )
   INPUT ARRAY p_anniv[p_anniv_arr].prem_po WITHOUT DEFAULTS FROM psca02m03_s1.*
         ATTRIBUTE( BLUE ,REVERSE )
         BEFORE ROW 
            CALL psca01s_Cursor() RETURNING p_anniv[p_anniv_arr].prem_po_scr ,
                                            p_anniv[p_anniv_arr].prem_po_arr
         BEFORE INSERT 
            CALL psca01s_ArrCount() RETURNING p_anniv[p_anniv_arr].prem_po_cnt
         AFTER FIELD policy_no
            IF FIELD_TOUCHED( policy_no ) THEN
               LET f_prem_po_ix = p_anniv[p_anniv_arr].prem_po_arr
               SELECT  COUNT(*)
               INTO    f_sts_cnt 
               FROM    polf 
               WHERE   policy_no = p_anniv[p_anniv_arr].prem_po[f_prem_po_ix]
               AND     po_sts_code >= "42" 
               AND     po_sts_code <= "59"
               IF f_sts_cnt = 0 THEN
                  CALL err_touch( "  非有效保單" )
                  NEXT FIELD policy_no
               END IF
            END IF
         AFTER DELETE 
            CALL psca01s_ArrCount() RETURNING p_anniv[p_anniv_arr].prem_po_cnt
         AFTER INPUT 
            CALL psca01s_ArrCount() RETURNING p_anniv[p_anniv_arr].prem_po_cnt
   END INPUT 
   IF INT_FLAG THEN 
      FOR f_ix = 1 TO 10 
          LET p_anniv[p_anniv_arr].prem_po[f_ix] = f_prem_po[f_ix]
      END FOR
      LET p_anniv[p_anniv_arr].prem_po_cnt = f_prem_po_cnt
      CLOSE WINDOW s_psca02m03
      LET p_anniv_choose[p_anniv_arr] = "0"
      RETURN 
   END IF 
   CLOSE WINDOW s_psca02m03
   RETURN
END FUNCTION --psca02m_input_prem_po END

FUNCTION psca02m_load_prem_po( f_policy_no ,f_cp_anniv_date )
   DEFINE f_policy_no                  LIKE pscae.join_policy_no 
   DEFINE f_cp_anniv_date              LIKE pscae.cp_anniv_date
   DEFINE f_pscae                      RECORD LIKE pscae.*
   DEFINE f_ix1 ,f_ix2                 INTEGER
   
   LET f_ix1 = p_anniv_arr
   LET f_ix2 = p_anniv[p_anniv_arr].prem_po_cnt
   DECLARE pscae_cur CURSOR WITH HOLD FOR 
       SELECT       *
       FROM         pscae
       WHERE        join_policy_no = f_policy_no 
       AND          cp_anniv_date  = f_cp_anniv_date 
   FOREACH pscae_cur INTO f_pscae.*
       LET f_ix2 = f_ix2 + 1
       LET p_anniv[f_ix1].prem_po[f_ix2] = f_pscae.policy_no 
   END FOREACH
   LET p_anniv[p_anniv_arr].prem_po_cnt = f_ix2
END FUNCTION --psca02m_load_prem_po END 

FUNCTION psca02m02_remit_bank( f_remit_bank )
   DEFINE f_remit_bank     LIKE pscad.remit_bank
   DEFINE f_bank_cnt       INTEGER

   SELECT COUNT(*)
   INTO   f_bank_cnt
   FROM   bank
   WHERE  bank_code[1,3]= f_remit_bank

   IF f_bank_cnt = 0 THEN
      RETURN 0
   END IF
   RETURN 1
END FUNCTION -- psca02m02_remit_bank END

FUNCTION psca02m02_remit_acct( f_remit_bank ,f_remit_branch ,f_remit_account )
   DEFINE f_remit_bank    LIKE pscad.remit_bank
   DEFINE f_remit_branch  LIKE pscad.remit_branch
   DEFINE f_remit_account LIKE pscad.remit_account
   DEFINE f_chk_remit_err      INTEGER
         ,f_chk_remit_msg      CHAR(255)
   
    CALL chkRemitAcct ( f_remit_bank     ,
                        f_remit_branch   ,
                        f_remit_account  )
         RETURNING f_chk_remit_err,f_chk_remit_msg
    IF f_chk_remit_err !="0" THEN
       RETURN 0
    END IF
    RETURN 1
END FUNCTION --psca02m02_remit_acct END

FUNCTION psca02m_input_payway()
   DEFINE f_prompt_ans         INTEGER
   DEFINE f_psca02m02_inp_bak  RECORD
          ca_disb_type        LIKE pscah.ca_disb_type    ,
          mail_addr           LIKE pscah.mail_addr
   END RECORD
   DEFINE f_ix                INTEGER 

   --**** 先備份 INT_FLAG 要還原 ****--
   LET f_psca02m02_inp_bak.* = p_anniv[p_anniv_arr].F1_inp.* 
   --**** 輸入付款方式 郵寄地址 ****--
   INPUT BY NAME p_anniv[p_anniv_arr].F1_inp.* WITHOUT DEFAULTS ATTRIBUTE(BLUE ,REVERSE)
      AFTER FIELD ca_disb_type 
         IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type = "3" THEN
            IF p_anniv[p_anniv_arr].prem_po_cnt = 0 THEN 
               CALL psca02m_load_prem_po( p_po_inp.policy_no ,
                                          p_anniv_2[p_anniv_arr].cp_anniv_date)
            END IF 
            CALL psca02m_input_prem_po()
         END IF
         IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type != "3"     AND 
            f_psca02m02_inp_bak.ca_disb_type = "3"              THEN
            LET f_prompt_ans = psca01s_promptSave( "將刪除抵繳保費資料，請確認" )
            IF f_prompt_ans = 1 THEN
               --**** 抵繳保單視窗變數初始化 ****--
               FOR f_ix = 1 TO 10
                   INITIALIZE p_anniv[p_anniv_arr].prem_po TO NULL
               END FOR 
               LET p_anniv[p_anniv_arr].prem_po_cnt = 0
            END IF
            IF f_prompt_ans = 0 THEN
               NEXT FIELD ca_disb_type
            END IF 
         END IF
         IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type = "1" THEN
            --**** 郵寄支票預設帶入舊保單收費地址 ****--
            SELECT c.address 
            INTO   p_anniv[p_anniv_arr].F1_inp.mail_addr
            FROM   polf a, pocl b, addr c, OUTER addr d
            WHERE  a.policy_no = p_po_inp.policy_no
            AND    a.policy_no = b.policy_no
            AND    b.client_ident = "O1"
            AND    c.client_id = b.client_id
            AND    c.addr_ind = a.mail_addr_ind
            AND    d.client_id = b.client_id
            AND    d.addr_ind = "E"
            DISPLAY BY NAME p_anniv[p_anniv_arr].F1_inp.mail_addr 
            NEXT FIELD mail_addr
         ELSE
            LET p_anniv[p_anniv_arr].F1_inp.mail_addr = " "
            DISPLAY BY NAME p_anniv[p_anniv_arr].F1_inp.mail_addr
         END IF
         IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type != "1" THEN
            EXIT INPUT
         END IF
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF NOT psca01s_fieldChk( "ca_disb_type" ,p_anniv[p_anniv_arr].F1_inp.ca_disb_type ) THEN
               CALL err_touch( "付款方式輸入錯誤" )
               NEXT FIELD ca_disb_type
            END IF
            IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type = "1" AND 
               p_anniv[p_anniv_arr].F1_inp.mail_addr = " "    THEN
               CALL err_touch( "選擇郵寄支票須輸入郵寄地址" )
               NEXT FIELD mail_addr
            END IF
         END IF 
   END INPUT
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      LET p_anniv[p_anniv_arr].F1_inp.* = f_psca02m02_inp_bak.*
      LET p_anniv_choose[p_anniv_arr] = "0"
      RETURN 0
   END IF   
   RETURN 1
END FUNCTION --psca02m_input_payway END 

FUNCTION psca02m_input_remit_arr()
   DEFINE f_ix             INTEGER 
   DEFINE f_max_cnt        INTEGER
   DEFINE f_scr ,f_arr     INTEGER
   DEFINE f_benf_tmp_cnt   INTEGER
   DEFINE f_psca02m02_s1_bak   ARRAY[10] OF RECORD
          check_no           LIKE dbdd.check_no              ,
          ori_id             LIKE pscd.client_id             ,
          ori_name           LIKE pscd.names                 ,
          new_id             LIKE pscad.payee_id             ,
          new_name           LIKE pscad.payee                ,
          remit_bank         LIKE pscad.remit_bank           ,
          remit_branch       LIKE pscad.remit_branch         ,
          remit_account      LIKE pscad.remit_account        ,
          payee_code         LIKE pscad.payee_code           ,
          bank_name          LIKE bank.bank_name
   END RECORD
   DEFINE f_F1_disb_no_bak  ARRAY[10] OF LIKE dbdd.disb_no
   DEFINE f_F1_benf_ratio_bak ARRAY[10] OF LIKE pscd.benf_ratio
   DEFINE f_02_s1_cnt  INTEGER
   
   --*** 備份 ****--
   FOR f_ix = 1 TO 10
       LET f_psca02m02_s1_bak[f_ix].* = p_anniv[p_anniv_arr].remit[f_ix].*
       LET f_F1_disb_no_bak[f_ix].* = p_anniv[p_anniv_arr].disb_no[f_ix].*
       LET f_F1_benf_ratio_bak[f_ix].* = p_anniv[p_anniv_arr].benf_ratio[f_ix].*
   END FOR
   LET f_02_s1_cnt = p_anniv[p_anniv_arr].remit_cnt
   --*** 最大筆數 ****--
   LET f_max_cnt = p_anniv[p_anniv_arr].remit_cnt
   CALL SET_COUNT( f_max_cnt )
   INPUT ARRAY p_anniv[p_anniv_arr].remit  WITHOUT DEFAULTS FROM psca02m02_s1.* 
         ATTRIBUTE(INSERT ROW = FALSE ,DELETE ROW = FALSE 
                  ,MAXCOUNT = f_max_cnt,BLUE ,REVERSE )
      BEFORE ROW 
         CALL psca01s_Cursor() RETURNING p_anniv[p_anniv_arr].remit_scr ,p_anniv[p_anniv_arr].remit_arr
         LET f_scr = p_anniv[p_anniv_arr].remit_scr
         LET f_arr = p_anniv[p_anniv_arr].remit_arr
         IF f_max_cnt < p_anniv[p_anniv_arr].remit_arr THEN 
            LET f_scr = f_scr - 1
            LET f_arr = f_arr - 1
            LET p_anniv[p_anniv_arr].remit_arr = p_anniv[p_anniv_arr].remit_arr -1 
            LET p_anniv[p_anniv_arr].remit_scr = p_anniv[p_anniv_arr].remit_scr -1
            CALL FGL_SETCURRLINE( p_anniv[p_anniv_arr].remit_scr ,p_anniv[p_anniv_arr].remit_arr )
            NEXT FIELD new_id
         END IF
         IF NOT validChar( p_anniv[p_anniv_arr].remit[f_arr].new_id ) THEN
            SELECT  client_id ,remit_bank ,remit_branch ,remit_account ,new_name
            INTO    p_anniv[p_anniv_arr].remit[f_arr].new_id        ,
                    p_anniv[p_anniv_arr].remit[f_arr].remit_bank    ,
                    p_anniv[p_anniv_arr].remit[f_arr].remit_branch  ,
                    p_anniv[p_anniv_arr].remit[f_arr].remit_account ,
                    p_anniv[p_anniv_arr].remit[f_arr].new_name
            FROM    benf_tmp 
            WHERE   names = p_anniv[p_anniv_arr].remit[f_arr].ori_name

            SELECT    bank_name 
            INTO      p_anniv[p_anniv_arr].remit[f_arr].bank_name
            FROM      bank
            WHERE     bank_code[1,3] = p_anniv[p_anniv_arr].remit[f_arr].remit_bank
            AND       bank_code[4,7] = p_anniv[p_anniv_arr].remit[f_arr].remit_branch

            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].new_id TO psca02m02_s1[f_scr].new_id
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].remit_bank TO psca02m02_s1[f_scr].remit_bank
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].remit_branch TO psca02m02_s1[f_scr].remit_branch
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].remit_account TO psca02m02_s1[f_scr].remit_account
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].new_name TO psca02m02_s1[f_scr].new_name
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].bank_name TO psca02m02_s1[f_scr].bank_name
         END IF
         NEXT FIELD new_id

      BEFORE FIELD ori_id 
         NEXT FIELD new_id 

      BEFORE FIELD ori_name 
         NEXT FIELD new_id

      BEFORE FIELD payee_code 
         DISPLAY " 1.更名 2.ID變更 3.指定 4.法定代理人 5.法定繼承人 6.其他"
                  AT 12 ,1 ATTRIBUTE( RED ,UNDERLINE )      

      AFTER FIELD payee_code
         DISPLAY "                                                        " 
                  AT 12 ,1 ATTRIBUTE( RED ,UNDERLINE )

      AFTER FIELD new_id
         IF NOT INT_FLAG THEN 
            SELECT   names 
            INTO     p_anniv[p_anniv_arr].remit[f_arr].new_name
            FROM     clnt 
            WHERE    client_id = p_anniv[p_anniv_arr].remit[f_arr].new_id
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].new_name TO psca02m02_s1[f_scr].new_name
            IF NOT validChar( p_anniv[p_anniv_arr].remit[f_arr].new_name ) THEN
               CALL err_touch("請通知總公司保全給付科建立客戶資料")
               NEXT FIELD new_id
            END IF
         END IF
         
      AFTER FIELD remit_branch
         IF NOT INT_FLAG THEN 
            SELECT    bank_name 
            INTO      p_anniv[p_anniv_arr].remit[f_arr].bank_name
            FROM      bank
            WHERE     bank_code[1,3] = p_anniv[p_anniv_arr].remit[f_arr].remit_bank
            AND       bank_code[4,7] = p_anniv[p_anniv_arr].remit[f_arr].remit_branch
            DISPLAY p_anniv[p_anniv_arr].remit[f_arr].bank_name TO psca02m02_s1[f_scr].bank_name
         END IF
      AFTER ROW
         IF NOT INT_FLAG THEN 
            IF p_anniv[p_anniv_arr].F1_inp.ca_disb_type = "2" THEN
               IF NOT psca02m02_remit_bank( p_anniv[p_anniv_arr].remit[f_arr].remit_bank ) THEN 
                  CALL err_touch( "匯款銀行輸入錯誤" )
                  NEXT FIELD remit_bank
               END IF 
               IF NOT psca02m02_remit_acct( p_anniv[p_anniv_arr].remit[f_arr].remit_bank   ,
                                            p_anniv[p_anniv_arr].remit[f_arr].remit_branch ,
                                            p_anniv[p_anniv_arr].remit[f_arr].remit_account) THEN 
                  CALL err_touch( "匯款帳號輸入錯誤" )
                  NEXT FIELD remit_account
               END IF
            END IF
            SELECT COUNT(*)
            INTO   f_benf_tmp_cnt
            FROM   benf_tmp
            WHERE  names = p_anniv[p_anniv_arr].remit[f_arr].ori_name
            IF f_benf_tmp_cnt = 0 THEN
               INSERT INTO benf_tmp VALUES ( p_anniv[p_anniv_arr].remit[f_arr].ori_name      ,
                                             p_anniv[p_anniv_arr].remit[f_arr].new_id        ,
                                             p_anniv[p_anniv_arr].remit[f_arr].remit_bank    ,
                                             p_anniv[p_anniv_arr].remit[f_arr].remit_branch  ,
                                             p_anniv[p_anniv_arr].remit[f_arr].remit_account ,
                                             p_anniv[p_anniv_arr].remit[f_arr].new_name      )
            END IF 
         END IF 
      AFTER INPUT 
         CALL psca01s_ArrCount() RETURNING p_anniv[p_anniv_arr].remit_cnt
         IF NOT INT_FLAG THEN 
            IF NOT psca02m02_remit_chk( p_anniv_arr ) THEN
               CALL err_touch( "匯款資訊錯誤" )
               CALL FGL_SETCURRLINE( 1, 1)
               NEXT FIELD remit_bank
            END IF
         END IF    
   END INPUT
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      --**** 還原 ****--
      FOR f_ix = 1 TO 10
          LET p_anniv[p_anniv_arr].remit[f_ix].* = f_psca02m02_s1_bak[f_ix].*
          LET p_anniv[p_anniv_arr].disb_no[f_ix].* = f_F1_disb_no_bak[f_ix].*
          LET p_anniv[p_anniv_arr].benf_ratio[f_ix].* = f_F1_benf_ratio_bak[f_ix].*
      END FOR
      LET p_anniv[p_anniv_arr].remit_cnt = f_02_s1_cnt
      LET p_anniv_choose[p_anniv_arr] = "0"
      RETURN 0 
   END IF
   RETURN 1
END FUNCTION -- psca02m_input_remit_arr END

FUNCTION psca02m_notice()
   DEFINE f_notice_rpt_sw     CHAR(1)  -- 0.IDMS列印 1.線上列印
   DEFINE f_notice_rpt        CHAR(30)  
   DEFINE f_output_cmd        CHAR(200) --輸出指令
   

   DISPLAY FORM s_psca02m01 ATTRIBUTE (GREEN)
   CALL ShowLogo()
 
   OPEN WINDOW s_psca02m04 AT 6,1 WITH FORM "psca02m04" ATTRIBUTE(GREEN, FORM LINE FIRST)

   IF NOT psca02m04_Input() THEN
      CLOSE WINDOW s_psca02m04
      RETURN 0
   END IF
   --**** 列印詢問 ****--
   WHILE TRUE 
        PROMPT " 請選擇列印方式 :"-- 0.IDMS 列印  1:線上列印  " 
               FOR f_notice_rpt_sw ATTRIBUTE( YELLOW ,UNDERLINE )
        IF f_notice_rpt_sw != "1"  AND
           f_notice_rpt_sw != "0"  THEN 
           CONTINUE WHILE
        END IF 
        EXIT WHILE
   END WHILE
   MESSAGE "資料處理中..."  ATTRIBUTE (RED ,REVERSE)
   --**** 檔案名稱 ****--
   IF f_notice_rpt_sw = "0" THEN
      LET f_notice_rpt = PSManagerName( "psca02m21" )
   END IF 
   IF f_notice_rpt_sw = "1" THEN
      LET f_notice_rpt = "psca02m21.rpt" 
   END IF 
   --**** 產生報表 ****--
   IF NOT psca02m_notice_Output( f_notice_rpt ,f_notice_rpt_sw ) THEN
      CALL err_touch( "產生報表失敗，請洽資訊部" )
      CLOSE WINDOW s_psca02m04
      RETURN 0
   END IF
   --**** 檔案輸出 ****--
   IF f_notice_rpt_sw = "0" THEN
      LET f_output_cmd = "psmanager ",f_notice_rpt
      RUN f_output_cmd
   END IF 
   IF f_notice_rpt_sw = "1" THEN
      LET f_output_cmd = "locprn ",f_notice_rpt
      RUN f_output_cmd
   END IF 
   
   CLOSE WINDOW s_psca02m04
   RETURN 1
END FUNCTION --psca02m_notice END

FUNCTION psca02m04_Input()
   DEFINE f_psck_cnt         INTEGER  -- 保單週年日在未回領取主檔筆數
   DEFINE f_rcode            INT                        -- yirong by  SR16020029
   DEFINE f_err                        CHAR(100)
   DEFINE f_cnt              SMALLINT

   INITIALIZE p_psca02m04_inp TO NULL
   LET f_psck_cnt = 0
   INPUT BY NAME p_psca02m04_inp.* WITHOUT DEFAULTS ATTRIBUTE(BLUE ,REVERSE)
      AFTER INPUT
         IF NOT INT_FLAG THEN 
            CALL check_pscb_message(p_psca02m04_inp.policy_no,'')
                  RETURNING f_rcode,f_cnt,f_err
--display f_rcode,'---',f_cnt,'---',f_err
{
            SELECT    COUNT(*) 
            INTO      f_psck_cnt
            FROM      psck
            WHERE     policy_no = p_psca02m04_inp.policy_no
            AND       nonresp_sw = "Y"
}
            IF f_rcode <> 1 THEN
               CALL err_touch( "查無資料" )
            END IF 
         END IF 
   END INPUT
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      RETURN 0
   END IF 
   IF f_cnt = 0 THEN 
      RETURN 0 
   END IF 
   RETURN 1
END FUNCTION --psca02m04_Input END 

FUNCTION psca02m_notice_Output( f_notice_rpt ,f_notice_rpt_sw )
   DEFINE f_notice_rpt       CHAR(30) 
   DEFINE f_notice_rpt_sw    CHAR(1)
   DEFINE f_psck             RECORD LIKE psck.*
   DEFINE f_pocl             RECORD LIKE pocl.*
   DEFINE f_clnt             RECORD LIKE clnt.*
   DEFINE f_pscd             RECORD LIKE pscd.*
   DEFINE f_dept             RECORD LIKE dept.*
   DEFINE f_rpt              RECORD 
          agent_name         LIKE pscah.agent_name    , 
          agent_dept         LIKE dept.dept_name      ,
          agent_dept_code    LIKE dept.dept_code      ,
          policy_no          LIKE pscah.policy_no     ,
          O1_name            LIKE clnt.names          ,
          cp_anniv_date      LIKE pscah.cp_anniv_date ,
          benf_name          VARCHAR(250)             ,
          user_name          LIKE edp_base:usrdat.user_name ,
          dept_code          LIKE dept.dept_code      ,
          dept_name          LIKE dept.dept_name      ,
          user_phone         LIKE edp_base:usrprf.phone        ,
          user_ext           LIKE edp_base:usrprf.ext          ,
          notify_seq         LIKE nofy.notify_seq     , --先做好以後萬一web照會可以用
          notice_rpt_sw      CHAR(1)
   END RECORD
   DEFINE f_agent_code       LIKE agnt.agent_code
   DEFINE f_notify_ok        INTEGER
   DEFINE f_cnt              INTEGER
   
   INITIALIZE f_rpt      TO NULL 
   INITIALIZE f_pscd    TO NULL
   INITIALIZE f_dept     TO NULL
   LET f_notify_ok = 1
   LET p_today = GetDate(TODAY)
   
   BEGIN WORK
   START REPORT psca02m_notice_rpt TO f_notice_rpt

   DECLARE notice_cur CURSOR WITH HOLD FOR 
      SELECT    c.* ,d.*
      FROM      pocl c ,clnt d 
      WHERE     c.policy_no     = p_psca02m04_inp.policy_no
      AND       c.client_ident  = "O1"
      AND       c.client_id     = d.client_id 
      ORDER BY  c.policy_no 
   FOREACH notice_cur INTO f_pocl.* ,f_clnt.*
      INITIALIZE f_rpt     TO NULL 
--      INITIALIZE f_pscd   TO NULL
      INITIALIZE f_dept    TO NULL
--      LET f_rpt.benf_name = ""
      LET f_agent_code    = ""
      --**** f_rpt *****--
      DECLARE poag_cur CURSOR WITH HOLD FOR 
         SELECT  b.names ,a.agent_code
         FROM    poag a ,clnt b
         WHERE   a.policy_no = p_psca02m04_inp.policy_no
         AND     relation = "S"
         AND     a.agent_code = b.client_id 
         ORDER BY comm_share DESC 
      FOREACH poag_cur INTO f_rpt.agent_name ,f_agent_code
         EXIT FOREACH  
      END FOREACH
      SELECT     a.dept_code           ,b.dept_name  
      INTO       f_rpt.agent_dept_code ,f_rpt.agent_dept
      FROM       agnt a , dept b
      WHERE      a.agent_code = f_agent_code 
      AND        a.dept_code  = b.dept_code
      LET f_rpt.policy_no  = p_psca02m04_inp.policy_no
      LET f_rpt.O1_name    = f_clnt.names 
{
      LET f_rpt.cp_anniv_date = f_psck.cp_anniv_date
      DECLARE pscd_cur2 CURSOR WITH HOLD FOR
         SELECT   * 
         FROM     pscd 
         WHERE    policy_no     = f_psck.policy_no 
         AND      cp_anniv_date = f_psck.cp_anniv_date 
      FOREACH pscd_cur2 INTO f_pscd.*
         IF f_rpt.benf_name = ""  OR 
            f_rpt.benf_name = " " OR 
            LENGTH( f_rpt.benf_name ) = 0 THEN
            LET f_rpt.benf_name = f_pscd.names CLIPPED
         ELSE
            LET f_rpt.benf_name = f_rpt.benf_name CLIPPED ,"、",
                                  f_pscd.names CLIPPED 
         END IF 
      END FOREACH
}
      LET f_rpt.user_name = p_user_name
      LET f_rpt.dept_code = p_dept_code
      SELECT   dept_name 
      INTO     f_rpt.dept_name 
      FROM     dept
      WHERE    dept_code = p_dept_code
      SELECT   phone               ,
               ext
      INTO     f_rpt.user_phone    ,
               f_rpt.user_ext 
      FROM     edp_base:usrprf
      WHERE    user_code = g_user
      LET f_rpt.notice_rpt_sw = f_notice_rpt_sw

      LET f_cnt = 0

      SELECT max(cp_anniv_date),count(*)
        INTO f_psck.cp_anniv_date,f_cnt
        FROM psck
       WHERE policy_no     = p_psca02m04_inp.policy_no 
         AND nonresp_sw    = "Y"

      IF f_cnt = 0 THEN 
      
         SELECT max(cp_anniv_date)
           INTO f_psck.cp_anniv_date
           FROM pscb
          WHERE policy_no = p_psca02m04_inp.policy_no
      END IF 
       

      OUTPUT TO REPORT psca02m_notice_rpt( f_rpt.* )
      IF NOT upd_ins_psck( p_psca02m04_inp.policy_no       ,
                           f_psck.cp_anniv_date   ,
                           "4"                    ,
                           " "                    ,
                           " "                    ,
                           p_today                ) THEN
         LET f_notify_ok = 0
         CALL err_touch( "寫入照會檔失敗" )
         EXIT FOREACH 
      END IF 
   END FOREACH 
   FINISH REPORT psca02m_notice_rpt
   IF f_notify_ok THEN
      COMMIT WORK
   ELSE 
      ROLLBACK WORK 
   END IF 
   RETURN f_notify_ok
END FUNCTION --psca02m_notice_Output END

REPORT psca02m_notice_rpt(r)
   DEFINE r              RECORD
          agent_name         LIKE pscah.agent_name    ,
          agent_dept         LIKE dept.dept_name      ,
          agent_dept_code    LIKE dept.dept_code      ,
          policy_no          LIKE pscah.policy_no     ,
          O1_name            LIKE clnt.names          ,
          cp_anniv_date      LIKE pscah.cp_anniv_date ,
          benf_name          VARCHAR(250)             ,
          user_name          LIKE edp_base:usrdat.user_name ,
          dept_code          LIKE dept.dept_code      ,
          dept_name          LIKE dept.dept_name      ,
          user_phone         LIKE edp_base:usrprf.phone        ,
          user_ext           LIKE edp_base:usrprf.ext          ,
          notify_seq         LIKE nofy.notify_seq     ,
          notice_rpt_sw      CHAR(1)
   END RECORD
   DEFINE r_first_group_date       CHAR(1)
   DEFINE r_today            CHAR(9)

   OUTPUT
      LEFT   MARGIN    0
      TOP    MARGIN    0
      BOTTOM MARGIN    0
      PAGE   LENGTH   66
      TOP    OF PAGE  "^L"

   ORDER BY r.policy_no ,r.cp_anniv_date

   FORMAT
      PAGE HEADER
         IF r.notice_rpt_sw = "0" THEN
            PRINT COLUMN 1 ,r.agent_dept_code
            SKIP 2 LINES
         ELSE
            SKIP 3 LINES
         END IF
         PRINT COLUMN 1  ,"~IX10W2;"
         PRINT COLUMN 11 ,"三商美邦人壽保險股份有限公司"
         PRINT COLUMN 1  ,"~IX10W2;"
         PRINT COLUMN 11 ,"生存／滿期金未申領通知單"
         SKIP 2 LINE
         PRINT COLUMN 1  ,"~IX10W1;"
         SKIP 1 LINE    
      
     BEFORE GROUP OF r.policy_no
         PRINT COLUMN 6  ,"致:",r.agent_dept CLIPPED ," ",r.agent_name , 
               COLUMN 47 ,"君"
         SKIP 2 LINES 
         PRINT COLUMN 10 ,"貴保戶尚有生存/滿期保險金未申請，敬請  台端儘速協助受益人填具"
         SKIP 1 LINE
         PRINT COLUMN 10 ,"「保險金領取方式回函」並檢附相關證明文件申辦。若有任何問題，請洽"
         SKIP 1 LINE 
         PRINT COLUMN 10 ,"詢承辦人員或各地保戶服務科，以維護保戶權益。"
         SKIP 3 LINES
         PRINT COLUMN 6  ,"保 單 號 碼：",r.policy_no , 
               COLUMN 45 ,"給付種類：生存／滿期保險金"
         SKIP 2 LINES
         PRINT COLUMN 6  ,"要保人：",r.O1_name
         SKIP 1 LINES 
         LET r_first_group_date = 0 
{
     BEFORE GROUP OF r.cp_anniv_date
         SKIP 1 LINE
         LET r_first_group_date = r_first_group_date + 1
         IF r_first_group_date = 1 THEN
            PRINT COLUMN 6  ,"給付週年日：",r.cp_anniv_date ,
                  COLUMN 45 ,"受益人：" ,r.benf_name CLIPPED
         END IF
         IF r_first_group_date != 1 THEN
            PRINT COLUMN 18  ,r.cp_anniv_date ,
                  COLUMN 53  ,r.benf_name CLIPPED
         END IF 

     AFTER GROUP OF r.cp_anniv_date
         SKIP 1 LINES
}
     AFTER GROUP OF r.policy_no 
         SKIP 2 LINES
         LET r_today = p_today
{
         LET r_today = p_today
         PRINT COLUMN 6  ,"照會內容："
         SKIP 1 LINE
         PRINT COLUMN 6  ,"本照會單免回覆，請協助受益人填具「保險金領取方式回函」及檢附相關證"
         SKIP 1 LINE
         PRINT COLUMN 6  ,"明文件，並送件辦理。若有任何問題，請洽詢承辦人員或各地保戶服務科。"
         SKIP 9 LINES 
}
         PRINT COLUMN 46 ,"承辦人：",r.dept_name CLIPPED, " ",r.user_name CLIPPED
         SKIP 1 LINE
         PRINT COLUMN 46 ,"連絡電話：",r.user_phone CLIPPED ,
               COLUMN 69 ,"分機 ",r.user_ext
         SKIP 1 LINE
         PRINT COLUMN 46 ,"列印日：",r_today
　　　　 SKIP TO TOP OF PAGE

END REPORT --psca02m_notice_rpt END 

FUNCTION psca02m_cad_sts_Update()
   DEFINE f_pscad           RECORD LIKE pscad.*
   DEFINE f_gl360p0_err     INTEGER 
   DEFINE f_gl360p0_msg     VARCHAR(250)
   DEFINE f_glkk            RECORD LIKE glkk.*
   DEFINE f_err_msg         VARCHAR(250)
   DEFINE f_err             INTEGER
   DEFINE f_pscah           RECORD LIKE pscah.*
   DEFINE f_dbdd            RECORD LIKE dbdd.*
   DEFINE f_another_fail    VARCHAR(250)
  
   IF NOT psca01s_promptSave( "是否執行" ) THEN 
      RETURN 0
   END IF 
   WHENEVER ERROR CONTINUE   
   DECLARE cah_cur CURSOR WITH HOLD FOR 
      SELECT  DISTINCT a.*
      FROM    pscah a, pscad b
      WHERE   a.policy_no     = b.policy_no 
      AND     a.cp_anniv_date = b.cp_anniv_date
      AND     b.cad_sts_code = "0"
   FOREACH cah_cur INTO f_pscah.*
      --****同一個policy_no ,cp_anniv_date 有一張票有問題 就取消交易 ****--
      LET f_gl360p0_err = 0
      LET f_gl360p0_msg = " "
      LET f_another_fail = " "
      BEGIN WORK 
      DECLARE cad_sts_cur CURSOR WITH HOLD FOR 
         SELECT  * 
         FROM    pscad
         WHERE   policy_no     = f_pscah.policy_no 
         AND     cp_anniv_date = f_pscah.cp_anniv_date
      FOREACH cad_sts_cur INTO f_pscad.*      
         INITIALIZE f_glkk.* TO NULL
         INITIALIZE f_dbdd.* TO NULL
         SELECT   * 
         INTO     f_dbdd.*
         FROM     dbdd
         WHERE    disb_no = f_pscad.disb_no
         LET f_glkk.check_no      = f_pscad.check_no 
         LET f_glkk.glkk_ind      = f_pscad.glkk_ind 
         LET f_glkk.payee_id      = f_pscad.payee_id 
         IF f_glkk.glkk_ind != "1" AND 
            f_glkk.glkk_ind != "2" THEN
            LET f_glkk.payee_id = " "
         END IF
         LET f_glkk.payee         = f_pscad.payee
         IF f_glkk.glkk_ind != "1" AND 
            f_glkk.glkk_ind != "2" THEN
            LET f_glkk.payee = " "
         END IF
         LET f_glkk.remit_bank    = f_pscad.remit_bank
         LET f_glkk.remit_branch  = f_pscad.remit_branch
         LET f_glkk.remit_account = f_pscad.remit_account
         LET f_glkk.glkk_note     = "還本金逾期未回覆"
         LET f_glkk.input_user    = p_user_code
         SELECT   dept_code 
         INTO     f_glkk.glkk_dept 
         FROM     edp_base:usrdat
         WHERE    user_code = p_user_code
         LET f_glkk.process_user  = g_user
         LET f_glkk.process_date  = p_today
         LET f_glkk.process_time  = CURRENT HOUR TO SECOND
         -------------------------------------------------------
         IF AddMonth( f_dbdd.check_date ,10 ) <= p_today OR 
            f_pscah.ca_disb_type != 1                    THEN
            CALL gl360p0_deal_glkk( f_glkk.* ) RETURNING f_gl360p0_err ,
                                                         f_gl360p0_msg
            IF f_gl360p0_err = 1 THEN 
               EXIT FOREACH 
            END IF         
         END IF          
      END FOREACH
      --**** 若同一個週年日任一張失敗全部都不寫入glkk *****-
      IF f_gl360p0_err = 1 THEN
         ROLLBACK WORK
      ELSE
         COMMIT WORK
      END IF 
      --**** 回寫未回領取系統 ****--
      BEGIN WORK
      IF f_gl360p0_err = 1 THEN
         LET f_another_fail = "支票號碼:",f_pscad.check_no,"付款資料有誤"
         UPDATE  pscad
         SET     cad_sts_code = "2"                ,
                 msg_content  = f_another_fail     ,
                 cad_sts_date = p_today
         WHERE   policy_no     = f_pscah.policy_no
         AND     cp_anniv_date = f_pscah.cp_anniv_date
         AND     check_no     != f_pscad.check_no
         IF SQLCA.SQLCODE != 0 THEN
            LET f_err_msg = f_pscah.policy_no     ,"-",
                            f_pscah.cp_anniv_date ,  
                            "err_1",ERR_GET( STATUS )
            CALL err_touch( f_err_msg )
            ROLLBACK WORK
            CONTINUE FOREACH
         END IF
         UPDATE  pscad
         SET     cad_sts_code = "2"                ,
                 msg_content  = f_gl360p0_msg      ,
                 cad_sts_date = p_today
         WHERE   check_no     = f_pscad.check_no
         IF SQLCA.SQLCODE != 0 THEN
            LET f_err_msg = f_pscah.policy_no     ,"-",
                            f_pscah.cp_anniv_date ,
                            "err_2",ERR_GET( STATUS )
            CALL err_touch( f_err )
            ROLLBACK WORK 
            CONTINUE FOREACH
         END IF
         COMMIT WORK 
         CONTINUE FOREACH 
      END IF
      IF f_gl360p0_err = 0 THEN
         UPDATE  pscad
         SET     cad_sts_code = "1"                ,
                 msg_content  = " "                ,
                 cad_sts_date = p_today
         WHERE   policy_no     = f_pscah.policy_no
         AND     cp_anniv_date = f_pscah.cp_anniv_date
         IF SQLCA.SQLCODE != 0 THEN
            LET f_err_msg = f_pscah.policy_no     ,"-",
                            f_pscah.cp_anniv_date ,  
                            "err_3",ERR_GET( STATUS )
            CALL err_touch( f_err_msg )
            ROLLBACK WORK 
            CONTINUE FOREACH
         END IF
         COMMIT WORK
      END IF 
      --**** 更新註記檔 更新失敗在寫一次進pscad ****-- 
      BEGIN WORK
      UPDATE psck 
      SET    nonresp_sw = "N"
      WHERE  policy_no      = f_pscah.policy_no 
      AND    cp_anniv_date  = f_pscah.cp_anniv_date 
      IF SQLCA.SQLCODE != 0 THEN
         LET f_err_msg = f_pscah.policy_no     ,"-",
                         f_pscah.cp_anniv_date ,
                         "err_4",ERR_GET( STATUS )
         CALL err_touch( f_err )         
         ROLLBACK WORK
         CONTINUE FOREACH 
      END IF
      IF NOT upd_ins_psck( f_pscah.policy_no       ,
                           f_pscah.cp_anniv_date   ,
                           "5"                    ,
                           " "                    ,
                           " "                    ,
                           p_today                ) THEN
         LET f_err_msg = f_pscah.policy_no     ,"-",
                         f_pscah.cp_anniv_date ,
                         "err_4",ERR_GET( STATUS )
         CALL err_touch( f_err )         
         ROLLBACK WORK 
         CONTINUE FOREACH 
      END IF 
      COMMIT WORK
   END FOREACH 
   WHENEVER ERROR STOP 
   CALL err_touch("執行完成")
   RETURN 1 
END FUNCTION --psca02m_cad_sts_Update END

FUNCTION psca02m_print()   
   DEFINE f_psca02m05_inp   RECORD 
          dept_code         LIKE dept.dept_code ,
          dept_name         LIKE dept.dept_name ,
          process_date      CHAR(9)
   END RECORD 
   DEFINE f_psca02m05_s1    ARRAY[4] OF RECORD
          choose            CHAR(1)
   END RECORD 
   DEFINE f_ix              INTEGER 
   DEFINE f_rpt_name_1 ,
          f_rpt_name_2 ,
          f_rpt_name_3 ,
          f_rpt_name_4      CHAR(30)
   DEFINE f_pscad           RECORD LIKE pscad.*
   DEFINE f_pscah           RECORD LIKE pscah.*
   DEFINE f_prompt_ans      INTEGER
   DEFINE f_cmd             CHAR(500)
   DEFINE f_pscd            RECORD LIKE pscd.*
   DEFINE f_pay_desc        VARCHAR(250)
   DEFINE f_dbdd            RECORD LIKE dbdd.*
   DEFINE f_glkk_users      VARCHAR(40)
   DEFINE f_input_user      LIKE glkk.input_user
   DEFINE f_payee_desc      VARCHAR(20)
   DEFINE f_pay_seq         INTEGER
   DEFINE f_user_name       VARCHAR(250)
   DEFINE f_user_names      VARCHAR(250)

   OPEN WINDOW s_psca02m05 AT 1,1 WITH FORM "psca02m05" --ATTRIBUTE(GREEN, FORM LINE FIRST)

   --***** 初始化 ****--
   LET f_psca02m05_inp.dept_code = "90433"
   SELECT   dept_name 
   INTO     f_psca02m05_inp.dept_name 
   FROM     dept 
   WHERE    dept_code = f_psca02m05_inp.dept_code
   IF STATUS = NOTFOUND THEN
      LET f_psca02m05_inp.dept_name = ""
   END IF
   LET f_psca02m05_inp.process_date = p_today
   
   INPUT BY NAME f_psca02m05_inp.dept_code     ,
                 f_psca02m05_inp.process_date  
                 WITHOUT DEFAULTS ATTRIBUTE(BLUE ,REVERSE)
         AFTER FIELD dept_code
               IF INT_FLAG THEN 
                  EXIT INPUT 
               END IF 
               IF NOT validChar( f_psca02m05_inp.dept_code ) THEN
                  CALL err_touch( "作業單位錯誤" )
                  NEXT FIELD dept_code
               END IF 
               SELECT  * 
               INTO    f_psca02m05_inp.dept_name 
               FROM    dept
               WHERE   dept_code = f_psca02m05_inp.dept_code 
               DISPLAY BY NAME f_psca02m05_inp.dept_name
        AFTER FIELD process_date
               IF INT_FLAG THEN 
                  EXIT INPUT
               END IF 
               IF NOT validChar( f_psca02m05_inp.process_date ) THEN
                  CALL err_touch( "作業日期錯誤" )
                  NEXT FIELD process_date
               END IF 
               IF f_psca02m05_inp.process_date > p_today THEN
                  CALL err_touch( "不可大於系統日" )
                  NEXT FIELD process_date
               END IF
               EXIT INPUT 
   END INPUT 
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      CALL err_touch( "你已放棄作業" )
      RETURN 0 
   END IF 
   
   FOR f_ix = 1 TO 4 
       LET f_psca02m05_s1[f_ix].choose = "Y"
   END FOR
   CALL SET_COUNT(4)
   INPUT ARRAY f_psca02m05_s1 WITHOUT DEFAULTS FROM psca02m05_s1.*
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      CALL err_touch( "你已放棄作業" )
      RETURN 0
   END IF 
   MESSAGE "資料處理中..." ATTRIBUTE (RED ,REVERSE)
   
   LET f_rpt_name_1 = "psca02m05_1.lst"  --還本未回回覆-上傳成功報表
   LET f_rpt_name_2 = "psca02m05_2.lst"  --還本未回回覆-上傳失敗報表
   LET f_rpt_name_3 = "psca02m05_3.lst"  --還本未回支票控管明細表(抽票用印)
   LET f_rpt_name_4 = "psca02m05_4.lst"  --還本未回支票控管明細表(抽票作廢)
   
   --**** 為了撈成功報表的上傳人員(rpt_1用到) ****--
   LET f_glkk_users = ""
   LET f_input_user = ""
   LET f_user_names = ""
   LET f_user_name  = ""
   DECLARE glkk_users CURSOR WITH HOLD FOR 
      SELECT    DISTINCT input_user
      FROM      pscad a , pscah b ,glkk c
      WHERE     a.cad_sts_code IN ("1","2")
      AND       a.cad_sts_date  = f_psca02m05_inp.process_date
      AND       a.policy_no     = b.policy_no
      AND       a.cp_anniv_date = b.cp_anniv_date
      AND       a.disb_no = c.disb_no
      AND       a.glkk_ind = c.glkk_ind
   FOREACH glkk_users INTO f_input_user
      IF f_glkk_users = " "   OR 
         f_glkk_users IS NULL THEN
         LET f_glkk_users = f_input_user 
      ELSE 
         LET f_glkk_users = f_glkk_users CLIPPED ,"、" ,f_input_user CLIPPED
      END IF 
      SELECT   user_name
      INTO     f_user_name
      FROM     edp_base:usrdat
      WHERE    user_code = f_input_user
      IF f_user_names = " "   OR 
         f_user_names IS NULL THEN
         LET f_user_names = f_user_name
      ELSE 
         LET f_user_names = f_user_names CLIPPED ,"、" ,f_user_name CLIPPED 
      END IF 
   END FOREACH --glkk_users
      
   START REPORT psca02m05_rpt_1 TO f_rpt_name_1
   START REPORT psca02m05_rpt_2 TO f_rpt_name_2
   START REPORT psca02m05_rpt_3 TO f_rpt_name_3
   START REPORT psca02m05_rpt_4 TO f_rpt_name_4
   DECLARE pscad_rpt_cur CURSOR WITH HOLD FOR 
      SELECT    * 
      FROM      pscad a , pscah b
      WHERE     a.cad_sts_code IN ("1","2")
      AND       a.cad_sts_date  = f_psca02m05_inp.process_date 
      AND       a.policy_no     = b.policy_no
      AND       a.cp_anniv_date = b.cp_anniv_date
   FOREACH pscad_rpt_cur INTO f_pscad.* ,f_pscah.*
      INITIALIZE f_pscd TO NULL
      LET f_pay_desc = " "
      LET f_payee_desc = " "
      LET f_pay_seq = 0
      INITIALIZE f_dbdd TO NULL

      SQL
          EXECUTE PROCEDURE getDesc( "payee_code" ,$f_pscad.payee_code ) 
                  INTO $f_payee_desc
      END SQL

      SELECT     * 
      INTO       f_pscd.*
      FROM       pscd
      WHERE      policy_no = f_pscad.policy_no 
      AND        cp_anniv_date = f_pscad.cp_anniv_date 
      AND        disb_no       = f_pscad.disb_no
      SELECT    * 
      INTO      f_dbdd.*
      FROM      dbdd
      WHERE     disb_no = f_pscad.disb_no 
      SQL 
           EXECUTE PROCEDURE getDesc("ca_disb_type" ,$f_pscah.ca_disb_type) 
                   INTO $f_pay_desc
      END SQL
      
      --**** 根據pay_desc 定義pay_seq報表排序順續 ****--
      IF f_pay_desc = "電匯" THEN 
         LET f_pay_seq = 1 
      END IF 
      IF f_pay_desc = "郵寄支票" THEN
         LET f_pay_seq = 2
      END IF
      IF f_pay_desc = "抵繳保費" THEN
         LET f_pay_seq = 3
      END IF
      IF f_pay_desc = "還款" THEN
         LET f_pay_seq = 4
      END IF

      --*** rpt_1 判斷 ***--
      WHILE ( f_psca02m05_s1[1].choose = "Y" )
         IF AddMonth( f_dbdd.check_date ,10 ) <= f_pscad.cad_sts_date AND 
            f_pscad.cad_sts_code = "1"                           THEN 
            OUTPUT TO REPORT psca02m05_rpt_1( f_pscad.*           ,
                                              f_pscd.currency     ,
                                              f_dbdd.disb_amt     ,
                                              f_pay_desc          ,
                                              f_glkk_users        ,
                                              f_pay_seq           ,
                                              f_payee_desc        ,
                                              f_user_names        ,
                                              f_dbdd.check_date   )
            EXIT WHILE 
         END IF
         IF AddMonth( f_dbdd.check_date ,10 ) > f_pscad.cad_sts_date  AND 
            f_pscah.ca_disb_type <> "1"                              AND
            f_pscad.cad_sts_code = "1"                               THEN
            OUTPUT TO REPORT psca02m05_rpt_1( f_pscad.*          ,
                                              f_pscd.currency    ,
                                              f_dbdd.disb_amt    , 
                                              f_pay_desc         ,
                                              f_glkk_users       ,
                                              f_pay_seq          ,
                                              f_payee_desc       ,
                                              f_user_names       ,
                                              f_dbdd.check_date  )
            EXIT WHILE
         END IF
         EXIT WHILE
      END WHILE
      --*** rpt_2 判斷 ***--
      WHILE ( f_psca02m05_s1[2].choose = "Y" )
         IF AddMonth( f_dbdd.check_date ,10 ) <= f_pscad.cad_sts_date AND 
            f_pscad.cad_sts_code = "2"                               THEN 
            OUTPUT TO REPORT psca02m05_rpt_2( f_pscad.* ,f_pay_seq)
            EXIT WHILE
         END IF
         IF AddMonth( f_dbdd.check_date ,10 ) > f_pscad.cad_sts_date AND 
            f_pscah.ca_disb_type <> "1"                             AND
            f_pscad.cad_sts_code = "2"                              THEN
            OUTPUT TO REPORT psca02m05_rpt_2( f_pscad.* ,f_pay_seq)
            EXIT WHILE
         END IF
         EXIT WHILE 
      END WHILE
      --*** rpt_3 判斷 ***--      
      WHILE ( f_psca02m05_s1[3].choose = "Y" )         
         IF AddMonth( f_dbdd.check_date ,10 ) > f_pscad.cad_sts_date  AND 
            f_pscah.ca_disb_type = "1"                               THEN
            OUTPUT TO REPORT psca02m05_rpt_3( f_pscad.*          ,
                                              f_dbdd.disb_amt    ,
                                              f_pay_seq          ,
                                              f_dbdd.check_date  )
            EXIT WHILE
         END IF
         EXIT WHILE
      END WHILE      
      --*** rpt_4 判斷 ***--
      WHILE ( f_psca02m05_s1[4].choose = "Y" )
         IF AddMonth( f_dbdd.check_date ,10 ) > f_pscad.cad_sts_date AND 
            f_pscah.ca_disb_type != "1"                             AND 
            f_pscad.cad_sts_code = "1"                              THEN
            OUTPUT TO REPORT psca02m05_rpt_4( f_pscad.*          ,
                                              f_dbdd.disb_amt    ,
                                              f_pay_seq          ,
                                              f_dbdd.check_date  )
            EXIT WHILE
         END IF
         EXIT WHILE
      END WHILE 
   END FOREACH  -- pscd_rpt_cur END 
   FINISH REPORT psca02m05_rpt_1
   FINISH REPORT psca02m05_rpt_2
   FINISH REPORT psca02m05_rpt_3
   FINISH REPORT psca02m05_rpt_4
   OPTIONS 
     PROMPT LINE LAST -1
   WHILE ( f_psca02m05_s1[1].choose = "Y" )
      LET f_prompt_ans = psca01s_promptSave( "報表已產生完成，是否本地列印" )
      IF f_prompt_ans = 0 THEN
         EXIT WHILE
      END IF
      LET f_cmd = "locprn ",f_rpt_name_1 CLIPPED 
      RUN f_cmd 
      EXIT WHILE 
   END WHILE
   OPTIONS 
     PROMPT LINE LAST -1
   WHILE ( f_psca02m05_s1[2].choose = "Y" )
      LET f_prompt_ans = psca01s_promptSave( "報表已產生完成，是否本地列印" )
      IF f_prompt_ans = 0 THEN
         EXIT WHILE
      END IF
      LET f_cmd = "locprn ",f_rpt_name_2 CLIPPED 
      RUN f_cmd 
      EXIT WHILE
   END WHILE  
   OPTIONS 
     PROMPT LINE LAST -1
   WHILE ( f_psca02m05_s1[3].choose = "Y" ) 
      LET f_prompt_ans = psca01s_promptSave( "報表已產生完成，是否本地列印" )
      IF f_prompt_ans = 0 THEN
         EXIT WHILE
      END IF
      LET f_cmd = "locprn ",f_rpt_name_3 CLIPPED 
      RUN f_cmd
      EXIT WHILE 
   END WHILE 
   OPTIONS 
     PROMPT LINE LAST -1
   WHILE ( f_psca02m05_s1[4].choose = "Y" )
      LET f_prompt_ans = psca01s_promptSave( "報表已產生完成，是否本地列印" )
      IF f_prompt_ans = 0 THEN
         EXIT WHILE
      END IF      
      LET f_cmd = "locprn ",f_rpt_name_4 CLIPPED 
      RUN f_cmd
      EXIT WHILE
   END WHILE 
   CLOSE WINDOW s_psca02m05
   RETURN 1
END FUNCTION --psca02m_print END

REPORT psca02m05_rpt_1( r            ,
                        r_currency   ,
                        r_cp_pay_amt ,
                        r_pay_desc   ,
                        r_glkk_users ,
                        r_pay_seq    ,
                        r_payee_desc ,
                        r_user_names ,
                        r_check_date )  
   DEFINE r                  RECORD LIKE pscad.*
   DEFINE r_currency         LIKE pscd.currency
   DEFINE r_cp_pay_amt       LIKE pscd.cp_pay_amt
   DEFINE r_pay_desc         VARCHAR(250)
   DEFINE r_glkk_users       VARCHAR(40)
   DEFINE r_pay_seq          INTEGER
   DEFINE r_payee_desc       VARCHAR(20)
   DEFINE r_payee_remit_cnt  INTEGER  -- 電匯
   DEFINE r_payee_chk_cnt    INTEGER  -- 郵寄支票
   DEFINE r_payee_prem_cnt   INTEGER  -- 抵繳保費
   DEFINE r_payee_loan_cnt   INTEGER  -- 還款
   DEFINE r_user_names       VARCHAR(250)
   DEFINE r_check_date       LIKE dbdd.check_date 

   OUTPUT
      LEFT   MARGIN    0
      TOP    MARGIN    0
      BOTTOM MARGIN    0
      PAGE   LENGTH   66
      TOP    OF PAGE  "^L"

   ORDER BY r_pay_seq ,r.cp_anniv_date ,r.check_no

   FORMAT
      PAGE HEADER
           PRINT COLUMN 20 ,"三 商 美 邦 人 壽 保 險 股 份 有 限 公 司" ,
                 COLUMN 81 ,"【機密資料】"
           PRINT COLUMN 23 ,"批次未回領取 成功 報表 - 保戶服務部 "
           PRINT COLUMN 23 ,"作業單位:保戶服務部保全給付科"
           PRINT COLUMN 1  ,"列印日期：" , p_today ,
                 COLUMN 82 ,"報表代碼：","GC200-1"
           PRINT COLUMN 1  ,"作業日期：",r.cad_sts_date ,
                 COLUMN 82 ,"頁數：" ,PAGENO USING "###"
           PRINT SetLine( "=", 102) CLIPPED
           PRINT COLUMN 1  ,"保單號碼" ,
            　　 COLUMN 15 ,"受益人"   ,
  　　           COLUMN 26 ,"週年日"   ,
                 COLUMN 38 ,"支票號碼" ,
                 COLUMN 51 ,"支票日期" ,
                 COLUMN 63 ,"幣別"     ,
                 COLUMN 72 ,"金額"　　 ,
                 COLUMN 81 ,"付款方式" ,
                 COLUMN 94 ,"說明"
           PRINT SetLine( "=", 102) CLIPPED
      ON EVERY ROW
           IF r_payee_remit_cnt = " " OR 
              r_payee_remit_cnt IS NULL THEN 
              LET r_payee_remit_cnt = 0
           END IF 
           IF r_payee_chk_cnt = " " OR 
              r_payee_chk_cnt IS NULL THEN 
              LET r_payee_chk_cnt = 0
           END IF 
           IF r_payee_prem_cnt = " " OR 
              r_payee_prem_cnt IS NULL THEN 
              LET r_payee_prem_cnt = 0
           END IF 
           IF r_payee_loan_cnt = " " OR 
              r_payee_loan_cnt IS NULL THEN 
              LET r_payee_loan_cnt = 0
           END IF 
           IF r_pay_seq = 1 THEN 
              LET r_payee_remit_cnt = r_payee_remit_cnt + 1 
           END IF 
           IF r_pay_seq = 2 THEN 
              LET r_payee_chk_cnt = r_payee_chk_cnt + 1 
           END IF
           IF r_pay_seq = 3 THEN 
              LET r_payee_prem_cnt = r_payee_prem_cnt + 1 
           END IF
           IF r_pay_seq = 4 THEN 
              LET r_payee_loan_cnt = r_payee_loan_cnt + 1 
           END IF
           PRINT COLUMN 1  ,r.policy_no        ,
                 COLUMN 14 ,r.payee CLIPPED    ,
                 COLUMN 25 ,r.cp_anniv_date    ,
                 COLUMN 38 ,r.check_no         ,
                 COLUMN 50 ,r_check_date       ,
                 COLUMN 63 ,r_currency         ,
                 COLUMN 67 ,r_cp_pay_amt USING "##,###,##&" ,
                 COLUMN 81 ,r_pay_desc CLIPPED ,
                 COLUMN 94 ,r_payee_desc 

      ON LAST ROW 
           SKIP 1 LINE 
           PRINT COLUMN 1  ,"上傳人員：",r_user_names CLIPPED
           SKIP 2 LINES
           PRINT COLUMN 1  ,"電匯筆數：",r_payee_remit_cnt USING "###&"
           PRINT COLUMN 1  ,"郵寄筆數：",r_payee_chk_cnt USING "###&"
           PRINT COLUMN 1  ,"抵繳筆數：",r_payee_prem_cnt USING "###&"
           PRINT COLUMN 1  ,"還款筆數：",r_payee_loan_cnt USING "###&" 
           SKIP 1 LINE 
           PRINT COLUMN 1  ,"總筆數："  ,COUNT(*) USING "#####" ,
                 COLUMN 39 ,"總金額："  ,SUM(r_cp_pay_amt) USING "###,###,###,##&.&&"
                 

END REPORT -- psca02m05_rpt_1 END

REPORT psca02m05_rpt_2( r ,r_pay_seq )
   DEFINE r              RECORD LIKE pscad.*
   DEFINE r_pay_seq      INTEGER
   
   OUTPUT
      LEFT   MARGIN    0
      TOP    MARGIN    0
      BOTTOM MARGIN    0
      PAGE   LENGTH   66
      TOP    OF PAGE  "^L"

   ORDER BY r_pay_seq ,r.cp_anniv_date ,r.check_no
     
   FORMAT 
      PAGE HEADER 
           PRINT COLUMN 20 ,"三 商 美 邦 人 壽 保 險 股 份 有 限 公 司" ,
                 COLUMN 81 ,"【機密資料】"
           PRINT COLUMN 23 ,"批次未回領取 失敗 報表 - 保戶服務部 "
           PRINT COLUMN 23 ,"作業單位:保戶服務部保全給付科"
           PRINT COLUMN 1  ,"列印日期：" , p_today ,
                 COLUMN 82 ,"報表代碼：","GC200-2"
           PRINT COLUMN 1  ,"作業日期：",r.cad_sts_date ,
                 COLUMN 82 ,"頁數：" ,PAGENO USING "###"
           PRINT SetLine( "=", 102) CLIPPED
           PRINT COLUMN 1  ,"保單號碼" ,
            　　 COLUMN 15 ,"受益人"   ,
  　　           COLUMN 28 ,"週年日"   ,
                 COLUMN 44 ,"支票號碼" ,
                 COLUMN 54 ,"幣別"     ,
                 COLUMN 64 ,"金額失敗原因"　　 
           PRINT SetLine( "=", 102) CLIPPED      
      ON EVERY ROW 
           PRINT COLUMN 1  ,r.policy_no       ,
                 COLUMN 14 ,r.payee CLIPPED   ,
                 COLUMN 28 ,r.cp_anniv_date   ,
                 COLUMN 44 ,r.check_no        , 
                 COLUMN 55 ,"TWD"             ,
                 COLUMN 63 ,r.msg_content CLIPPED

      ON LAST ROW 
           SKIP 1 LINE
           PRINT COLUMN 1  ,"上傳人員：" ,p_user_name CLIPPED ,
                 COLUMN 30 ,"總筆數：", COUNT(*) USING "####"

END REPORT -- psca02m05_rpt_2 END 

REPORT psca02m05_rpt_3( r ,r_cp_pay_amt ,r_pay_seq ,r_check_date )
   DEFINE r               RECORD LIKE pscad.*
   DEFINE r_cp_pay_amt    LIKE pscd.cp_pay_amt
   DEFINE r_pay_seq       INTEGER
   DEFINE r_check_date    LIKE dbdd.check_date  

   OUTPUT
      LEFT   MARGIN    0
      TOP    MARGIN    0
      BOTTOM MARGIN    0
      PAGE   LENGTH   66
      TOP    OF PAGE  "^L"

   ORDER BY r_pay_seq ,r.cp_anniv_date ,r.check_no 

   FORMAT 
      PAGE HEADER
           PRINT ASCII 126 ,"IW1Z1;"
           PRINT COLUMN 20 ,"三 商 美 邦 人 壽 保 險 股 份 有 限 公 司 "
           PRINT COLUMN 20 ,"還 本 未 回 支 票 控 管 明 細 表(抽票用印) "
           PRINT ASCII 126 ,"IW1Z1;"
           PRINT "報表代碼：GC200-3"  ,
                 COLUMN 61 ,"製表單位：90433"        
           PRINT "處理日期：",r.cad_sts_date   , 
                 COLUMN 61 ,"製表日期：", p_today
           PRINT SetLine( "-", 80) CLIPPED
           PRINT COLUMN 1  , "保單號碼" , 
                 COLUMN 18 ,"支票號碼"  ,
                 COLUMN 29 ,"支票金額"  ,
                 COLUMN 40 ,"支票日期"  ,
                 COLUMN 52 ,"受款人"    ,
                 COLUMN 64 ,"承辦人員" 
           PRINT SetLine( "-", 80) CLIPPED
      
     ON EVERY ROW 
           PRINT COLUMN 1  ,r.policy_no                         , 
                 COLUMN 18 ,r.check_no                          ,
                 COLUMN 29 ,r_cp_pay_amt USING "##,###,##&"     ,
                 COLUMN 40 ,r_check_date                        ,
                 COLUMN 52 ,r.payee  CLIPPED                    ,
                 COLUMN 64 ,p_user_name CLIPPED 

     ON LAST ROW
           SKIP 3 LINES 
           PRINT COLUMN 1  ,"主管：" ,
                 COLUMN 30 ,"承辦人："
           SKIP 2 LINES 
           PRINT COLUMN 1  ,"財務部用印確認："
                 
END REPORT --psca02m05_rpt_3 END 

REPORT psca02m05_rpt_4( r            ,
                        r_cp_pay_amt ,
                        r_pay_seq    ,
                        r_check_date ) 
   DEFINE r             RECORD LIKE pscad.*
   DEFINE r_cp_pay_amt  LIKE pscd.cp_pay_amt 
   DEFINE r_pay_seq     INTEGER
   DEFINE r_check_date  LIKE dbdd.check_date 

   OUTPUT
      LEFT   MARGIN    0
      TOP    MARGIN    0
      BOTTOM MARGIN    0
      PAGE   LENGTH   66
      TOP    OF PAGE  "^L"   

   ORDER BY r_pay_seq ,r.cp_anniv_date ,r.check_no 
   
   FORMAT 
      PAGE HEADER 
           PRINT COLUMN 1  ,"~IW1Z1;"
           PRINT COLUMN 20 ,"三 商 美 邦 人 壽 保 險 股 份 有 限 公 司 "
           PRINT COLUMN 20 ,"還 本 未 回 支 票 控 管 明 細 表(抽票作廢)" 
           PRINT COLUMN 1  ,"~IW1Z1;"
           PRINT COLUMN 1  ,"報表代碼：GC200-4" ,
                 COLUMN 61 ,"製表單位：90433" 
           PRINT COLUMN 1  ,"處理日期：",r.cad_sts_date ,
                 COLUMN 61 ,"製表日期：", p_today
           PRINT SetLine( "-", 80) CLIPPED
           PRINT COLUMN 1  ,"保單號碼"    ,
                 COLUMN 18 ,"支票號碼"    ,
                 COLUMN 29 ,"支票金額"    ,
                 COLUMN 40 ,"支票日期"    ,
                 COLUMN 52 ,"受款人 "     ,
                 COLUMN 64 ,"承辦人員"
           PRINT SetLine( "-", 80) CLIPPED
      ON EVERY ROW 
           PRINT COLUMN 1  ,r.policy_no   ,
                 COLUMN 18 ,r.check_no    ,
                 COLUMN 27 ,r_cp_pay_amt  USING "##,###,##&" ,
                 COLUMN 40 ,r_check_date  ,
                 COLUMN 52 ,r.payee CLIPPED ,
                 COLUMN 64 ,p_user_name CLIPPED
           
END REPORT --psca02m05_rpt_4 END 

FUNCTION psca02m_B1_B3_status( f_policy_no )
   DEFINE f_policy_no             LIKE pscah.policy_no 
   DEFINE f_pscb                  RECORD LIKE pscb.*
   DEFINE f_special_status_ind    INTEGER 
   DEFINE f_status                CHAR(2)

   --**** 受理結案 須判斷有沒有週年日狀態處於B1 B3 ****--
   LET f_special_status_ind = 0
   INITIALIZE f_pscb TO NULL
   LET f_status = " "
   DECLARE pscb_status_cur CURSOR WITH HOLD FOR 
      SELECT  * 
      FROM    pscb
      WHERE   policy_no = f_policy_no
      ORDER BY cp_anniv_date DESC 
   FOREACH pscb_status_cur INTO f_pscb.*
      LET f_status = psca01s_status( f_pscb.cp_sw ,f_pscb.cp_notice_sw ) 
      IF f_status = "B1" OR 
         f_status = "B3" THEN
         LET f_special_status_ind = 1
         EXIT FOREACH
      END IF    
   END FOREACH
   RETURN f_special_status_ind   
END FUNCTION --psca02m_B1_B3_status END 
