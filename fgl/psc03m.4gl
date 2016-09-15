-----------------------------------------------------------------------------
--  程式名稱: psc03m.4gl
--  作    者: merlin
--  日    期:
--  處理概要: 還本註記作業
--  重要函式:
------------------------------------------------------------------------------
--  修改者:kobe
--  091/04/11:新增給付變更的選擇
--            若原電匯者選擇給付變更,將刪除benf電匯帳號
------------------------------------------------------------------------------
--  修改者:kobe
--  093/04/07:因應給付方式(主動電匯)的新增, 修改控制
------------------------------------------------------------------------------
--  101/10/01 cmwang 新增「是否取消未回領取註記」功能
--  101/10/15 cmwang 新增「退匯照會」及「匯款銀行合併/裁撤照匯」欄位及列印功能
--  101/10/17 cmwang 新增「取消未回領取註記」功能
--  103/09/29 cmwang SR140800458 將psck.nonresp_sw = "N"之資料提供可更改為Y的提示
--  104/03/05 cmwang SR150300312 註記新增刪除由user控制
-------------------------------------------------------------------------------
GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/ia.4gl"
#GLOBALS "../def/pscgcpn.4gl"

DATABASE life 
  DEFINE p_bell             CHAR                    --> 鈴聲字元
  DEFINE p_space            CHAR(20)                --> 空白
  DEFINE p_keys             CHAR(400)               --> 查詢條件暫存區
  DEFINE p_total_record     INTEGER                 --> 資料數
  DEFINE p_err              INTEGER                 --> 錯誤訊息
  DEFINE p_new_flag         INTEGER
  DEFINE p_modu_sw          CHAR
  DEFINE p_answer           CHAR(1)
  DEFINE p_table            CHAR(8)
  DEFINE p_psck             RECORD LIKE psck.*
  DEFINE p_pscb             RECORD LIKE pscb.*
  DEFINE p_pay_change       CHAR(1)                 --> 給付變更(Y/N)
--101/10/15 cmwang
  DEFINE p_remit_notice     CHAR(1)        --> 退匯照會(Y/N)
  DEFINE p_Arr              INT            --> 資料陣列位置
  DEFINE p_Scr              INT            --> 螢幕陣列位置
--end 101/10/15 
  DEFINE p_relation	  CHAR(1)
  DEFINE p_pt_sw             CHAR(1) ----pt指示
  DEFINE f_rtn               CHAR(1)
  DEFINE f_exist      INTEGER  -- 保單檢核 --
         ,f_pscb_exist      INTEGER  -- 還本檔檢核 --
         ,f_ptsn_exist      INTEGER  
  DEFINE p_ins_psca01       INTEGER 
MAIN 
  OPTIONS
      INSERT  KEY  F35
    , DELETE  KEY  F36
    , ERROR   LINE LAST
    , PROMPT  LINE LAST - 2
    , MESSAGE LINE LAST - 1
    , COMMENT LINE LAST

    DEFER INTERRUPT
    SET LOCK MODE TO WAIT
    WHENEVER ERROR STOP
 
  LET g_program_id ="psc03m"
  LET p_space      =" "
  LET p_bell       =ASCII 7

  OPEN FORM psc03m01 FROM "psc03m01"
  DISPLAY FORM psc03m01 ATTRIBUTE (GREEN)
-- 101/10/17 cmwang 新增
  CLOSE FORM psc03m01 
-- end 101/10/17  
  CALL ShowLogo()
--  JOB  CONTROL beg --
  CALL JobControl()

  MENU "請選擇"
    BEFORE MENU 
    
      IF  NOT CheckAuthority("1", FALSE)  THEN
        HIDE OPTION "1)新增或修改註記"
      END IF
      IF  NOT CheckAuthority("2", FALSE)  THEN
        HIDE OPTION "2)取消註記"
      END IF
      IF  NOT CheckAuthority("3", FALSE)  THEN
        HIDE OPTION "3)特殊保單控管"
      END IF

      COMMAND "1)新增或修改註記"
        LET INT_FLAG = FALSE
        CALL input()
        CLOSE FORM psc03m01
--  101/10/17 cmwang 新增
      COMMAND "2)取消註記"
        LET INT_FLAG = FALSE 
        CALL input_all()
        CLOSE FORM psc03m05
      COMMAND "3)特殊保單控管"
        RUN "psc24m.4ge"
-- end 101/10/17
      COMMAND "0)結束"
        EXIT MENU
  END MENU    
-- JOB  CONTROL end --
  CALL JobControl()
END MAIN
------------------------------------------------------------------------------
--  函式名稱: init
--  處理概要: 畫面初值
--  重要函式:
------------------------------------------------------------------------------
FUNCTION init()
  MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)
  INITIALIZE p_psck.*       TO NULL
  LET p_pay_change=""
  LET p_relation=""
  LET p_pt_sw      ='0'
  LET p_ins_psca01 = 0
END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: input
--  處理概要: 輸入註記內容
--  重要函式:
------------------------------------------------------------------------------
FUNCTION input()
    DEFINE  l_correct               INTEGER   -- 日期檢查 t or f --
    DEFINE  l_formated_date         CHAR(9)   -- 日期格式化 999/99/99 --
    DEFINE  l_psck_cnt              INTEGER
    DEFINE  f_pay_change_type       CHAR(1)
           ,f_pay_change_name       CHAR(70)
    DEFINE  f_expired_date	        LIKE polf.expired_date
    -- 101/10/15 cmwang 新增退匯照會內容
    DEFINE f_else_ind               INT 
    DEFINE f_notice_print           CHAR(1)      
    DEFINE f_remit_notice_desc      CHAR(70)
    DEFINE f_remit_notice_resolve   CHAR(70)
    DEFINE f_rcode                  INT
    DEFINE f_rcode_desc             CHAR(200) 
    -- end 101/10/15

    CALL init()
    LET f_pay_change_type=""
    LET f_pay_change_name=""
    LET p_modu_sw=""
   
  -- 101/10/15 cmwang 新增 remit_notice欄位及open form 敘述
    OPEN FORM psc03m01 FROM "psc03m01"
    DISPLAY FORM psc03m01 ATTRIBUTE (GREEN)
    CALL ShowLogo()    
    INPUT   p_psck.policy_no        ,
            p_psck.cp_anniv_date    ,
            p_pay_change            ,
            p_remit_notice          ,
            p_psck.cp_remark_desc_1 ,
            p_psck.cp_remark_desc_2 ,
            p_psck.cp_remark_desc_3 ,
            p_psck.cp_remark_desc_4 ,
            p_psck.cp_remark_desc_5
        WITHOUT DEFAULTS
        FROM    policy_no               , 
                cp_anniv_date           ,
                pay_change              ,
                remit_notice            ,
                cp_remark_desc_1        ,
                cp_remark_desc_2        ,
                cp_remark_desc_3        ,
                cp_remark_desc_4        ,
                cp_remark_desc_5
        ATTRIBUTE(BLUE,REVERSE,UNDERLINE)
        -- end 101/10/15
        AFTER FIELD policy_no
            IF NOT FIELD_TOUCHED(psck.policy_no) THEN
                ERROR "保單號碼必須輸入!!"  ATTRIBUTE (RED)
                NEXT FIELD policy_no
            END IF
    
            SELECT      *
            INTO        g_polf.*
            FROM        polf
            WHERE       policy_no=p_psck.policy_no
    
        IF SQLCA.SQLERRD[3]=0 THEN
            CALL get_ia(p_psck.policy_no) RETURNING f_rtn ----0-正常; 1-有誤
            IF f_rtn = 1 THEN
                ERROR "無此張保單!!"  ATTRIBUTE (RED)
                NEXT FIELD policy_no
            ELSE
                LET p_pt_sw = '1'
            END IF
        ELSE
            --- 098/10 新增SN滿期回覆 yirong---
            IF p_psck.policy_no[1,1] = '6' THEN
                IF g_polf.insurance_type = 'N' THEN  ---103/07新增
                    ERROR "FVA保單不適用!!"  ATTRIBUTE (RED)
                    NEXT FIELD policy_no
                ELSE   
                    LET p_pt_sw = '2'
                END IF
            END IF
        END IF
    
        AFTER FIELD cp_anniv_date
            CALL  CheckDate(p_psck.cp_anniv_date) RETURNING l_correct,l_formated_date
            IF NOT FIELD_TOUCHED(psck.cp_anniv_date) THEN      
                ERROR "週年日必須輸入!!"  ATTRIBUTE (RED)
                NEXT FIELD cp_anniv_date
            ELSE
              IF l_correct = false THEN
                    ERROR "週年日輸入錯誤!!" ATTRIBUTE (RED)
                    NEXT FIELD cp_anniv_date
              END IF
            END IF 
            -- DISPLAY "*pt_sw",p_pt_sw
            IF p_pt_sw = '1' THEN ----給付保單 
                SELECT  count(*) INTO f_pscb_exist
                FROM    ptpd
                WHERE   policy_no = p_psck.policy_no
                AND     payout_due = p_psck.cp_anniv_date
                AND     opt_notice_sw  in ( '1','2')----回覆狀態 1.等待回覆 2.已經回覆
                AND     process_sw     = '0'        ----初始值   1.已經給付
                IF f_pscb_exist = 0 THEN
                    ERROR "給付檔中無此筆資料 !!"
                    NEXT  FIELD policy_no
                END IF
                SELECT  count(*) INTO f_exist
                FROM    psck
                WHERE   policy_no=p_psck.policy_no
                AND     cp_anniv_date=p_psck.cp_anniv_date
                IF f_exist = 0 THEN
                    LET p_modu_sw ='I'
                ELSE
                    LET p_modu_sw ='U'
                    CALL disp()
                END IF
            ELSE
                --- 098/10 新增SN滿期回覆 yirong--- 
                IF p_pt_sw = '2' THEN
                    SELECT  count(*)
                    INTO    f_ptsn_exist
                    FROM    ptsn
                    WHERE   policy_no = p_psck.policy_no
                    AND     iv_terminate_date = p_psck.cp_anniv_date
                    IF f_ptsn_exist = 0 THEN
                        ERROR "此張保單無還本資料!!"  ATTRIBUTE (RED)
                        NEXT FIELD policy_no
                    END IF
                    SELECT  cp_remark_sw 
                    INTO    p_pscb.cp_remark_sw
                    FROM    ptsn
                    WHERE   policy_no = p_psck.policy_no
                    
                    IF p_pscb.cp_remark_sw="Y" THEN
                        LET p_modu_sw="U"
                        CALL disp()
                    END IF
                ELSE
                    SELECT  * INTO p_pscb.*
                    FROM    pscb
                    WHERE   policy_no=p_psck.policy_no
                    AND     cp_anniv_date=p_psck.cp_anniv_date
                    IF SQLCA.SQLERRD[3]=0 THEN
                        ERROR "此張保單無還本資料!!"  ATTRIBUTE (RED)
                        NEXT FIELD policy_no
                    END IF
                    IF  p_pscb.cp_remark_sw="Y" THEN
                        LET p_modu_sw="U"
                        CALL disp()
                    END IF 
                END IF  -- p_pt_sw = '2'
            END IF -- p_pt_sw = '1'
            -- 101/11/09 將p_pay_change ,remit_notice預設定為 "N" 並在螢幕欄位上顯示
        BEFORE FIELD pay_change
            LET p_pay_change = 'N'
            DISPLAY "N" TO pay_change
            LET p_remit_notice = 'N'
            DISPLAY "N" TO remit_notice
            IF p_pt_sw = '1' THEN
                NEXT FIELD cp_remark_desc_1
            END IF
        
        AFTER FIELD pay_change
            IF p_pt_sw = '1' OR p_pt_sw = '2' THEN
                LET p_pay_change = 'N'
                LET f_pay_change_type=""
                LET f_pay_change_name=""
            ELSE
                IF p_pay_change = "N" THEN
                    LET f_pay_change_type=""
                    LET f_pay_change_name=""
                ELSE
                    IF p_pay_change = "Y" THEN  
                        IF p_pscb.cp_disb_type="0"
                            OR p_pscb.cp_disb_type="3"
                            OR p_pscb.cp_disb_type="4"
                            OR p_pscb.cp_disb_type="5" THEN
                            CALL chg_pay_type() RETURNING f_pay_change_type,f_pay_change_name
                        ELSE
                            ERROR "此張保單無法選擇給付變更!!"  ATTRIBUTE(RED)
                        END IF
                    END IF                
                END IF
                IF f_pay_change_type !=""
                   OR f_pay_change_type IS NOT NULL THEN
                    LET f_pay_change_name[69]="1"
                    LET p_psck.cp_remark_desc_5=f_pay_change_name
                    DISPLAY BY NAME p_psck.cp_remark_desc_5 ATTRIBUTE(CYAN)
                ELSE
                    LET p_pay_change="N"
                    DISPLAY p_pay_change TO pay_change ATTRIBUTE(CYAN)
                END IF
                SELECT  expired_date 
                INTO    f_expired_date
                FROM    polf
                WHERE   policy_no=p_psck.policy_no
                
                IF p_psck.cp_anniv_date >= f_expired_date THEN
                    LET p_relation="M"
                ELSE
                    LET p_relation="L"
                END IF
            END IF
            ----101/10/01 cmwang新增「是否取消未回領取註記」功能
            CALL nonresp_sw_chg(p_psck.policy_no,p_psck.cp_anniv_date)
            -- 101/10/01 END
    -- 101/10/15 cmwang 退匯照會選擇"Y"，show選項填入註記內容空白的欄位，並提供列印方式選項
        AFTER FIELD remit_notice
            IF p_remit_notice = 'Y' THEN
      	        LET  f_remit_notice_desc = ""
    	        CALL remit_notify() RETURNING f_remit_notice_desc 
                IF LENGTH(f_remit_notice_desc CLIPPED ) = 0 THEN 
                    LET p_remit_notice = "N" 
                    DISPLAY "N" TO remit_notice
                    NEXT FIELD remit_notice
                END IF      
    	        CASE p_Arr
    	            WHEN 1
    	                LET f_remit_notice_resolve ="□已聯絡保戶，辦理姓名變更後再重新付款。"
    	            WHEN 2
    	                LET f_remit_notice_resolve =""
    	            WHEN 3 
    	                LET f_remit_notice_resolve =""
                    WHEN 4 
    	                LET f_remit_notice_resolve =""
    	            WHEN 5 
    	                LET f_remit_notice_resolve =""
    	            WHEN 6
                        LET f_remit_notice_resolve ="□已聯絡保戶，原帳號無異動，新分行別________________，請依上述資料匯款。"
                END CASE   	 
   	            LET f_else_ind = 0
                IF (p_psck.cp_remark_desc_1 IS NULL 
                   OR p_psck.cp_remark_desc_1 = " " 
                   OR LENGTH(p_psck.cp_remark_desc_1 CLIPPED) = 0) THEN 
   	                LET p_psck.cp_remark_desc_1 = f_remit_notice_desc
   	                DISPLAY p_psck.cp_remark_desc_1 TO cp_remark_desc_1 
   	            ELSE 
   	                LET f_else_ind = 1
   	            END IF
   	            IF f_else_ind = 1 THEN 
   	                IF (p_psck.cp_remark_desc_2 IS NULL 
   	                   OR p_psck.cp_remark_desc_2 = " "
   	                   OR LENGTH(p_psck.cp_remark_desc_2 CLIPPED) = 0) THEN 
                        LET p_psck.cp_remark_desc_2 = f_remit_notice_desc
                        DISPLAY p_psck.cp_remark_desc_2 TO cp_remark_desc_2
   	                ELSE 
   	                    LET f_else_ind = 2
   	                END IF
   	            END IF 
   	            IF f_else_ind = 2 THEN 
   	                IF (p_psck.cp_remark_desc_3 IS NULL 
   	                   OR p_psck.cp_remark_desc_3 = " "
   	                   OR LENGTH(p_psck.cp_remark_desc_3) = 0) THEN 
   	                    LET p_psck.cp_remark_desc_3 = f_remit_notice_desc
   	                    DISPLAY p_psck.cp_remark_desc_3 TO cp_remark_desc_3
   	                ELSE 
   	                    LET f_else_ind = 3
   	                END IF
   	            END IF  
   	            IF f_else_ind = 3 THEN 
   	                IF (p_psck.cp_remark_desc_4 IS NULL 
   	                   OR p_psck.cp_remark_desc_4 = " "
   	                   OR LENGTH(p_psck.cp_remark_desc_4) = 0) THEN
   	                    LET p_psck.cp_remark_desc_4 = f_remit_notice_desc
   	                    DISPLAY p_psck.cp_remark_desc_4 TO cp_remark_desc_4
   	                ELSE 
   	                    LET f_else_ind = 4
   	                END IF   
   	            END IF
                IF f_else_ind = 4 THEN
   	                IF (p_psck.cp_remark_desc_5 IS NULL 
   	                   OR p_psck.cp_remark_desc_5 = " "
   	                   OR LENGTH(p_psck.cp_remark_desc_5) = 0) THEN 
   	                    LET p_psck.cp_remark_desc_5 = f_remit_notice_desc
   	                    DISPLAY p_psck.cp_remark_desc_5 TO cp_remark_desc_5
   	                ELSE
   	                    LET p_psck.cp_remark_desc_1 = f_remit_notice_desc
   	                    DISPLAY p_psck.cp_remark_desc_1 TO cp_remark_desc_1
   	                END IF 
   	            END IF    
            END IF
            -- end 101/10/15  
        ON KEY (F7)
            LET INT_FLAG=TRUE
            EXIT INPUT

        -- 中斷作業 --
        AFTER  INPUT
            LET p_psck.process_user=g_user
            LET p_psck.process_date=GetDate(TODAY)
            LET p_psck.process_time=TIME        
            MESSAGE " "
            IF INT_FLAG THEN
                LET INT_FLAG = FALSE
                LET p_new_flag = FALSE
                ERROR '放棄此項作業!!' ATTRIBUTE(RED,UNDERLINE)
                EXIT INPUT
            END IF
            WHILE 1=1
                PROMPT '是否存檔[y/n]' ATTRIBUTE(RED,UNDERLINE) FOR CHAR p_answer
                IF UPSHIFT(p_answer) = 'Y' THEN
                    IF p_modu_sw="U" THEN
                        IF upd()   THEN
                            ERROR '修改成功!!' ATTRIBUTE(RED,UNDERLINE)
                        END IF
                    ELSE
                      IF save() THEN
                            ERROR '存檔成功!!'  ATTRIBUTE(RED,UNDERLINE)
                      END IF
                    END IF
                    LET f_rcode = 0
                    LET f_rcode_desc = ""
                    ----101/10/31 cmwang 退匯照會選擇"Y"時列印照會單                
                    IF p_remit_notice = 'Y' THEN
                        CALL notice_print(p_psck.policy_no,p_psck.cp_anniv_date,f_remit_notice_desc) RETURNING f_rcode , f_rcode_desc
                    END IF
                    ---- end 101/10/31 
                    IF f_rcode THEN 
                        ERROR "照會資料有誤，請聯絡資訊部!!"
                        SLEEP 1 
                        DISPLAY "*",f_rcode_desc CLIPPED
                        RETURN 
                    END IF 
                    EXIT WHILE
                END IF
                IF UPSHIFT(p_answer) = 'N' THEN
                    EXIT WHILE
                END IF
            END WHILE
    END INPUT
  RETURN
END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: save
--  處理概要: 儲存資料(psck)
--  重要函式:
------------------------------------------------------------------------------
FUNCTION save()
  DEFINE l_back		INTEGER
  WHENEVER ERROR CONTINUE
  LET l_back=0
  BEGIN WORK
    INSERT INTO psck  VALUES(p_psck.*)
    IF NOT SQLCA.SQLERRD[3] THEN
      LET p_err = STATUS
      LET p_table = 'psck'
      LET l_back=1
      ROLLBACK WORK
      CALL ShowMessage( p_table, 1, p_err )
      RETURN FALSE
    ELSE
      IF p_pt_sw = '1' THEN
        COMMIT WORK
        RETURN TRUE
      ELSE
        IF p_pt_sw = '2' THEN
          LET l_back=0
          UPDATE  ptsn
            SET   cp_remark_sw ="Y"
            WHERE policy_no=p_psck.policy_no
          IF NOT SQLCA.SQLERRD[3] THEN
            LET p_err = STATUS
            LET p_table = 'ptsn'
            LET l_back = 2
            ROLLBACK WORK
            CALL ShowMessage( p_table, 2, p_err )
            RETURN FALSE
          ELSE
            COMMIT WORK
            RETURN TRUE
          END IF
        ELSE
          LET l_back=0
          UPDATE   pscb
            SET    cp_remark_sw ="Y"
            WHERE  policy_no=p_psck.policy_no
              AND  cp_anniv_date=p_psck.cp_anniv_date

          IF NOT SQLCA.SQLERRD[3] THEN
            LET p_err = STATUS
            LET p_table = 'pscb'
            LET l_back = 2
            ROLLBACK WORK
            CALL ShowMessage( p_table, 2, p_err )
            RETURN FALSE
          ELSE
        ----- 正常電匯給付變更需刪除該電匯帳號 --
            IF p_pay_change="Y"  
               AND (p_pscb.cp_disb_type="3" OR p_pscb.cp_disb_type="5")
	       AND p_pscb.disb_special_ind="0" THEN
              LET l_back=0
              UPDATE   benf
                SET    (remit_bank, remit_branch, remit_account) = ("","","")
                WHERE  policy_no=p_psck.policy_no
                  AND  relation =p_relation

              IF NOT SQLCA.SQLERRD[3] THEN
                LET p_err = STATUS
                LET p_table = 'benf'
                LET l_back = 2
                ROLLBACK WORK
                CALL ShowMessage( p_table, 2, p_err )
                RETURN FALSE
              ELSE
                COMMIT WORK
                RETURN TRUE
              END IF
            END IF
            COMMIT WORK
            RETURN TRUE
          END IF
        END IF ----p_pt_sw='2'
      END IF ----p_pt_sw='1'
    END IF  
END FUNCTION
------------------------------------------------------------------------------
--  函式名稱: upd
--  處理概要: 更新資料(psck)
--  重要函式:
------------------------------------------------------------------------------
FUNCTION upd()
  DEFINE l_back  INTEGER
  DEFINE f_psca01 RECORD LIKE psca01.*
  WHENEVER ERROR CONTINUE
  LET l_back=0
  BEGIN WORK
    IF p_ins_psca01 THEN
       LET f_psca01.policy_no = p_psck.policy_no 
       LET f_psca01.cp_anniv_date = p_psck.cp_anniv_date
       LET f_psca01.program_id = "psc03m"
       LET f_psca01.process_user = g_user
       LET f_psca01.process_date = GetDate(TODAY)
       LET f_psca01.process_time = CURRENT HOUR TO SECOND
       INSERT INTO psca01 VALUES ( f_psca01.* )
       IF NOT SQLCA.SQLERRD[3] THEN
          LET p_err = STATUS
          LET p_table = 'psca01'
          LET l_back = 2
          ROLLBACK WORK
          CALL ShowMessage( p_table, 2, p_err )
          RETURN FALSE
       END IF 
    END IF        
    UPDATE   psck
      SET    psck.* = p_psck.*
      WHERE  policy_no=p_psck.policy_no
        AND  cp_anniv_date=p_psck.cp_anniv_date

    IF  NOT SQLCA.SQLERRD[3] THEN
      LET p_err = STATUS
      LET p_table = 'psck'
      LET l_back = 2
      ROLLBACK WORK
      CALL ShowMessage( p_table, 2, p_err )
      RETURN FALSE
    ELSE
      -- 正常電匯給付變更需刪除該電匯帳號 --
      IF p_pay_change="Y"
         AND (p_pscb.cp_disb_type="3" OR p_pscb.cp_disb_type="5")
	 AND p_pscb.disb_special_ind="0" THEN
	LET l_back=0
	UPDATE  benf
	  SET   (remit_bank, remit_branch, remit_account) = ("","","")
	  WHERE policy_no=p_psck.policy_no    
            AND relation =p_relation

        IF NOT SQLCA.SQLERRD[3] THEN
	  LET p_err = STATUS
	  LET p_table = 'benf'
	  LET l_back = 2
	  ROLLBACK WORK
	  CALL ShowMessage( p_table, 2, p_err )
	  RETURN FALSE
	ELSE
	  COMMIT WORK
	  RETURN TRUE
	END IF
      END IF  
      COMMIT WORK
      RETURN TRUE
    END IF
END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: upd_data()
--  處理概要: 更新資料(pscb)
--  重要函式:
------------------------------------------------------------------------------
FUNCTION upd_data()
  DEFINE l_back  INTEGER
  WHENEVER ERROR CONTINUE
  LET l_back=0
  BEGIN WORK
    UPDATE   pscb
      SET    cp_remark_sw ="Y"
      WHERE  policy_no=p_psck.policy_no
        AND  cp_anniv_date=p_psck.cp_anniv_date

    IF NOT SQLCA.SQLERRD[3] THEN
      LET p_err = STATUS
      LET p_table = 'pscb'
      LET l_back = 2
      ROLLBACK WORK
      CALL ShowMessage( p_table, 2, p_err )
      RETURN FALSE
    ELSE
      COMMIT WORK
      RETURN TRUE
    END IF
END FUNCTION
------------------------------------------------------------------------------
--  函式名稱: disp
--  處理概要: 查詢顯現視窗
--  重要函式:
------------------------------------------------------------------------------
FUNCTION disp()
-- end 101/10/17 
  SELECT * INTO p_psck.*
    FROM   psck
    WHERE  policy_no=p_psck.policy_no
      AND  cp_anniv_date=p_psck.cp_anniv_date

--       IF p_psck.cp_remark_desc_5[69]="1" THEN
--          LET p_pay_change="Y"
--       END IF
  
  DISPLAY p_psck.policy_no,p_psck.cp_anniv_date,p_pay_change,
          p_psck.cp_remark_desc_1,p_psck.cp_remark_desc_2,
          p_psck.cp_remark_desc_3,p_psck.cp_remark_desc_4,
          p_psck.cp_remark_desc_5,p_psck.process_date,
          p_psck.process_time,p_psck.process_user
    TO  policy_no,cp_anniv_date,pay_change,cp_remark_desc_1
        ,cp_remark_desc_2,cp_remark_desc_3,cp_remark_desc_4
        ,cp_remark_desc_5,process_date,process_time,process_user       
    ATTRIBUTE(CYAN)
         
  IF INT_FLAG THEN
    LET INT_FLAG=FALSE
  END IF
  RETURN
END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: chg_pay_type
--  處理概要: 給付變更控制
--  重要函式:
------------------------------------------------------------------------------
FUNCTION chg_pay_type()

  DEFINE f_pay_change_type            CHAR(1)
        ,f_pay_change_name            CHAR(70)

  OPEN WINDOW w_psc03m03 AT 8,24 WITH FORM "psc03m03"
    ATTRIBUTE(BLUE, REVERSE, UNDERLINE,FORM LINE FIRST, PROMPT LINE LAST)

    LET f_pay_change_type=""
    LET f_pay_change_name=""

    IF INT_FLAG = TRUE THEN
      CLOSE WINDOW w_psc03m03
      LET INT_FLAG=FALSE
      RETURN f_pay_change_type,f_pay_change_name
    END IF
    DISPLAY f_pay_change_type TO pay_change_type
    INPUT   f_pay_change_type WITHOUT DEFAULTS
      FROM  pay_change_type ATTRIBUTE(BLUE, REVERSE, UNDERLINE)

      AFTER FIELD pay_change_type
        IF f_pay_change_type="" OR f_pay_change_type IS NULL THEN
          LET f_pay_change_type=""
        ELSE
          IF p_pscb.cp_disb_type="0" THEN
            CASE f_pay_change_type
              WHEN "0"
                LET f_pay_change_name="支票回銷"
                EXIT CASE
              WHEN "1"
                LET f_pay_change_name="支票改抵繳"
                EXIT CASE
              WHEN "2"
                ERROR "選擇錯誤...!!" ATTRIBUTE(RED)
                LET f_pay_change_type = NULL
                DISPLAY f_pay_change_type TO pay_change_type
                NEXT FIELD pay_change_type
                EXIT CASE
              OTHERWISE
                LET f_pay_change_type=""
                LET f_pay_change_name=""
                EXIT CASE
            END CASE
          ELSE
            IF p_pscb.cp_disb_type="3" THEN
              CASE f_pay_change_type
                WHEN "0"
                  LET f_pay_change_name="電匯回銷"
                  EXIT CASE
                WHEN "1"
                  LET f_pay_change_name="電匯改抵繳"
                  EXIT CASE
                WHEN "2"
                  LET f_pay_change_name="電匯改開票"
                  EXIT CASE
                OTHERWISE
                  LET f_pay_change_type=""
                  LET f_pay_change_name=""
                  EXIT CASE
              END CASE
            ELSE
              IF p_pscb.cp_disb_type="4" THEN
                CASE f_pay_change_type
                  WHEN "0"
		    LET f_pay_change_name="未回回銷"
		    EXIT CASE
		  WHEN "1"
		    LET f_pay_change_name="未回改抵繳"
		    EXIT CASE
		  WHEN "2"
                    ERROR "選擇錯誤...!!" ATTRIBUTE(RED)
                    LET f_pay_change_type = NULL
            	    DISPLAY f_pay_change_type TO pay_change_type
                    NEXT FIELD pay_change_type
                    EXIT CASE
		  OTHERWISE
                    LET f_pay_change_type=""
                    LET f_pay_change_name=""
                    EXIT CASE
                END CASE
	      ELSE
		IF p_pscb.cp_disb_type="5" THEN
		  CASE f_pay_change_type
		    WHEN "0"
		      LET f_pay_change_name="主動電匯回銷"
		      EXIT CASE
		    WHEN "1"
		      LET f_pay_change_name="主動電匯改抵繳"
		      EXIT CASE
		    WHEN "2"
		      LET f_pay_change_name="主動電匯改開票"
		      EXIT CASE
		    OTHERWISE
		      LET f_pay_change_type=""
		      LET f_pay_change_name=""
		      EXIT CASE
		  END CASE
		ELSE
		  LET f_pay_change_type=""
                  LET f_pay_change_name=""
                  ERROR "無法使用此功能..!!" ATTRIBUTE(RED)
		END IF
              END IF
            END IF
          END IF
        END IF
      AFTER INPUT
        IF INT_FLAG=TRUE THEN
          LET f_pay_change_type=""
          LET f_pay_change_name=""
          EXIT INPUT
        END IF
 
    END INPUT
    -- 101/10/15 cmwang 變更close window 位置
    CLOSE WINDOW w_psc03m03
    IF INT_FLAG=TRUE THEN
      LET INT_FLAG=FALSE
      CLOSE WINDOW w_psc03m03 RETURN f_pay_change_type,f_pay_change_name
    END IF

    --    CLOSE WINDOW w_psc03m03
    RETURN f_pay_change_type,f_pay_change_name

END FUNCTION
------------------------------------------------------------------------------
--  函式名稱: nonresp_sw_chg
--  處理概要: 新增未回領取註記
--  輸    入: p_psck.policy_no,p_psck.cp_anniv_date
--  處 理 者: cmwang
--  重要函式:
------------------------------------------------------------------------------
FUNCTION nonresp_sw_chg(f_policy_no ,f_cp_anniv_date)
    DEFINE f_policy_no LIKE pscb.policy_no 
    DEFINE f_cp_anniv_date LIKE pscb.cp_anniv_date
    DEFINE f_prompt_ans  CHAR(1) 
    DEFINE f_cp_remark_sw LIKE pscb.cp_remark_sw
    DEFINE f_nonresp_sw_cnt     INT
    DEFINE f_do_sw              INTEGER    
  
    LET f_do_sw = 0
    INITIALIZE f_nonresp_sw_cnt TO NULL 
    SELECT  COUNT(*)
    INTO    f_nonresp_sw_cnt
    FROM    psck
    WHERE   policy_no =  f_policy_no
    AND     cp_anniv_date = f_cp_anniv_date
    AND     ( nonresp_sw != "Y"         --SR140800458 Y-->N
              OR nonresp_sw IS NULL )
    IF f_nonresp_sw_cnt THEN
        DISPLAY " " TO cp_nonresp_sw ATTRIBUTE(CYAN,UNDERLINE)
        WHILE TRUE
            LET INT_FLAG =FALSE
            PROMPT "請確認是否新增本筆未回領取註記[y/n]?" FOR f_prompt_ans     
            IF (UPSHIFT(f_prompt_ans) = "Y" OR UPSHIFT(f_prompt_ans) = "N")
               AND INT_FLAG = FALSE THEN 
                EXIT WHILE 
            ELSE 
                LET INT_FLAG = FALSE
        	    RETURN
            END IF 
        END WHILE   
        CASE UPSHIFT(f_prompt_ans) 
            WHEN "N" 
                --	ERROR "還本註記存檔完成!!" ATTRIBUTE(RED,UNDERLINE)
    	        RETURN 
            WHEN "Y"
                LET p_psck.nonresp_sw ="Y"
                LET p_ins_psca01 = 1
                ERROR "新增未回領取註記!!" ATTRIBUTE(RED,UNDERLINE)
                
    	        UPDATE    psck
    	        SET       nonresp_sw = "Y"
    	        WHERE     policy_no = f_policy_no
    	        AND       cp_anniv_date = f_cp_anniv_date
                ERROR "已新增未回領註記!"
                LET f_do_sw = 1
    	        DISPLAY "*" TO cp_nonresp_sw
            OTHERWISE 
                DISPLAY "f_prompt_ans 有其他可能性"
        END CASE
    END IF
    IF f_do_sw = 1 THEN
        RETURN 
    END IF 
    INITIALIZE f_nonresp_sw_cnt TO NULL 
    SELECT  COUNT(*)
    INTO    f_nonresp_sw_cnt
    FROM    psck
    WHERE   policy_no =  f_policy_no
    AND     cp_anniv_date = f_cp_anniv_date
    AND     nonresp_sw = "Y"
    IF f_nonresp_sw_cnt THEN
        DISPLAY "*" TO cp_nonresp_sw ATTRIBUTE(CYAN,UNDERLINE)
        WHILE TRUE
            LET INT_FLAG =FALSE
            PROMPT "請確認是否取消本筆未回領取註記[y/n]?" FOR f_prompt_ans     
            IF (UPSHIFT(f_prompt_ans) = "Y" OR UPSHIFT(f_prompt_ans) = "N")
               AND INT_FLAG = FALSE THEN 
                EXIT WHILE 
            ELSE 
                LET INT_FLAG = FALSE
        	    RETURN
            END IF 
        END WHILE   
        CASE UPSHIFT(f_prompt_ans) 
            WHEN "N" 
                --	ERROR "還本註記存檔完成!!" ATTRIBUTE(RED,UNDERLINE)
    	        RETURN 
            WHEN "Y"
                LET p_psck.nonresp_sw ="Y"
                LET p_ins_psca01 = 1
                ERROR "取消未回領取註記!!" ATTRIBUTE(RED,UNDERLINE)
                
    	        UPDATE    psck
    	        SET       nonresp_sw = " "
    	        WHERE     policy_no = f_policy_no
    	        AND       cp_anniv_date = f_cp_anniv_date
                ERROR "已取消未回領註記!"
                LET f_do_sw = 1
                
    	        DISPLAY " " TO cp_nonresp_sw
            OTHERWISE 
                DISPLAY "f_prompt_ans 有其他可能性"
        END CASE
    END IF  
END FUNCTION
------------------------------------------------------------------------------
--  函式名稱: remit_notify
--  處理概要: 顯示退匯照會內容並提供user選擇後，將選擇內容填入註記內容空白欄位
--  輸    出: f_remit_notice_desc(選擇之內容) 
--  處 理 者: 101/10/15 cmwang
--  重要函式:
------------------------------------------------------------------------------
FUNCTION remit_notify()
  DEFINE f_remit_notice_desc CHAR(70)
  DEFINE f_remit_notice_array ARRAY[6] OF RECORD
  	 desc_code CHAR(1)
  	,remit_desc CHAR(70)
  END RECORD 
  DEFINE f_process_date CHAR(9)
  DEFINE f_i INT
  DEFINE f_remit_notice_array_size INT
  DEFINE f_exitdisp_ind INT 
  LET f_remit_notice_array_size = 6  --改
  LET f_process_date = GetDate(TODAY)
  FOR f_i = 1 TO f_remit_notice_array_size
    LET f_remit_notice_array[f_i].desc_code = " "
    IF f_i = 1 THEN 
      LET f_remit_notice_array[f_i].desc_code = "V"
    END IF
  END FOR 
  LET f_remit_notice_array[1].remit_desc = "匯款帳戶戶名有誤造成退匯"
  LET f_remit_notice_array[2].remit_desc = "匯款帳號有誤造成退匯"
  LET f_remit_notice_array[3].remit_desc = "匯款因滯納因素造成退匯"
  LET f_remit_notice_array[4].remit_desc = "匯款帳戶已結清造成退匯"
  LET f_remit_notice_array[5].remit_desc = "受益人ID有誤造成退匯"
  LET f_remit_notice_array[6].remit_desc = "原匯款銀行/分行已裁撤或合併，已照會業務員。",f_process_date
  OPEN WINDOW remit_window AT 7,1 WITH FORM "psc03m04"
    ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST )
  LET INT_FLAG = FALSE
  LET f_exitdisp_ind = 0 
  WHILE TRUE
    IF f_exitdisp_ind THEN 
      IF int_flag THEN
        LET int_flag = FALSE
      END IF  
      EXIT WHILE 
    END IF
    IF FGL_LASTKEY() = FGL_KEYVAL("ESC") THEN
      CALL CursorReset()
      LET f_exitdisp_ind = 1
      LET f_remit_notice_desc = f_remit_notice_array[p_Arr].remit_desc
      EXIT WHILE   
    END IF 
    LET f_remit_notice_array[p_Arr].desc_code = " "
    LET f_remit_notice_array[1].desc_code = "V"
    CALL SET_COUNT(f_remit_notice_array_size)
    DISPLAY ARRAY f_remit_notice_array TO p_psc03m04_arr.* ATTRIBUTE(WHITE)
      ON KEY (UP)
      	CALL CursorReset()
      	IF p_Arr > 1 THEN 
      	  LET f_remit_notice_array[p_Arr].desc_code = " "
      	  LET p_Arr = p_Arr - 1
      	  LET p_Scr = p_Scr - 1	
      	  LET f_remit_notice_array[p_Arr].desc_code = "V"
      	  CALL FGL_SETCURRLINE(p_Scr,p_Arr)
      	ELSE 
      	  ERROR "已達到第一筆資料!" ATTRIBUTE(RED,UNDERLINE)
      	END IF 
      ON KEY (DOWN,RETURN)
      	CALL CursorReset()
      	IF p_Arr < f_remit_notice_array_size THEN 
      	  LET f_remit_notice_array[p_Arr].desc_code = " "
      	  LET p_Arr = p_Arr + 1 
      	  LET p_Scr = p_Scr + 1
      	  LET f_remit_notice_array[p_Arr].desc_code = "V"
      	  CALL FGL_SETCURRLINE(p_Scr ,p_Arr)
      	ELSE 
      	  ERROR "已達到最後一筆資料!" ATTRIBUTE(RED,UNDERLINE)
      	END IF
      ON KEY (INTERRUPT)
        CALL CursorReset()
        LET f_exitdisp_ind = 1
        LET f_remit_notice_desc = ""
        EXIT DISPLAY       
{ Display Array ON KEY 無法套在Esc鍵上
      ON KEY (ACCEPT)
        DISPLAY "AAA"
      	CALL CursorReset()
      	LET f_exitdisp_ind = 1 
      	LET f_remit_notice_desc = f_remit_notice_array[p_Arr].remit_desc
      	EXIT DISPLAY
} 
    END DISPLAY
  END WHILE
  CLOSE WINDOW remit_window
  RETURN f_remit_notice_desc

END FUNCTION 
------------------------------------------------------------------------------
--  函式名稱: CursorReset
--  處理概要: 更新 p_Scr , p_Data
--  輸    出: 
--  處 理 者: 101/10/15 cmwang
--  重要函式:
------------------------------------------------------------------------------
FUNCTION CursorReset()
  LET p_Scr = SCR_LINE()
  LET p_Arr = ARR_CURR()
END FUNCTION 
------------------------------------------------------------------------------
--  函式名稱: input_all
--  處理概要: 新增取消未回領取註記
--  輸    出: 
--  處 理 者: 101/10/17 cmwang
--  重要函式:
------------------------------------------------------------------------------
FUNCTION input_all()
  DEFINE f_pscb RECORD LIKE pscb.*
  DEFINE f_pscp RECORD LIKE pscp.*
  DEFINE f_expired_date LIKE polf.expired_date
  DEFINE f_cancel_arr RECORD 
  	 nonresp_sw_cancel CHAR(1)
  END RECORD 
  DEFINE f_nonresp_sw_ind CHAR(1)
  DEFINE f_pscp_exit INT 
  
  OPEN FORM psc03m05 FROM 'psc03m05'
  DISPLAY FORM psc03m05 ATTRIBUTE (GREEN)
  CALL ShowLogo() 
  INPUT f_pscb.policy_no FROM policy_no ATTRIBUTE(BLUE,REVERSE,UNDERLINE)
    AFTER FIELD policy_no
      LET f_pscp_exit = 0  
      SELECT  COUNT(*)
        INTO  f_pscp_exit
  	FROM  pscp 
  	WHERE policy_no = f_pscb.policy_no
      IF f_pscp_exit = 0 THEN 
  	ERROR "該保單號碼不在還本保單主檔中!!"
  	NEXT FIELD policy_no
      END IF 
      SELECT  expired_date
        INTO  f_expired_date
        FROM  polf 
        WHERE policy_no = f_pscb.policy_no
  
      IF STATUS = NOTFOUND THEN 
  	ERROR "該保單號碼",f_pscb.policy_no,"在polf中找不到expired_date!!"
  	NEXT FIELD policy_no 
      END IF      
  END INPUT 
  CALL input_arr(f_pscb.policy_no,f_expired_date) RETURNING f_nonresp_sw_ind
  IF f_nonresp_sw_ind = "0" THEN 
    ERROR "該保單號碼無未回領取註記!" ATTRIBUTE(RED)
    SLEEP 1 
  END IF 
  RETURN 
END FUNCTION 
------------------------------------------------------------------------------
--  函式名稱: input_arr
--  處理概要: 顯示保單資訊
--  輸    入:  
--  處 理 者: 101/10/17 cmwang
--  重要函式:
------------------------------------------------------------------------------
FUNCTION input_arr(f_policy_no,f_expired_date1)
  DEFINE f_policy_no LIKE pscb.policy_no
  DEFINE f_expired_date1 LIKE polf.expired_date --用以判斷滿期或生存
  DEFINE f_nonresp_sw_ind CHAR(1) --是否有未回領取註記指示
  DEFINE f_dis_arr array[100] OF RECORD 
     cp_anniv_date  LIKE pscp.cp_anniv_date
    ,plan_code     LIKE pscp.plan_code
    ,rate_scale   LIKE pscp.rate_scale 
    ,nonresp_sw   LIKE psck.nonresp_sw
    ,cp_pay_amt   LIKE pscp.cp_pay_amt
    ,pay_type     CHAR(4)
    ,nonresp_sw_cancel CHAR(1)
  END RECORD
  DEFINE f_pscp_cnt INT 
  DEFINE f_expired_date LIKE polf.expired_date
  DEFINE f_i INT     ---資料總數 
  DEFINE f_trigger_ind INT 
  
  LET f_pscp_cnt = 0 
  SELECT  COUNT(*) 
    INTO  f_pscp_cnt
    FROM  psck 
    WHERE policy_no = f_policy_no
      AND nonresp_sw = "Y"
  
  IF f_pscp_cnt = 0 THEN
    LET f_nonresp_sw_ind = "0"
    RETURN f_nonresp_sw_ind
  ELSE 
    LET f_nonresp_sw_ind = "1"
  END IF 
 
  DECLARE pscp_cur CURSOR FOR 
    SELECT  cp_anniv_date
      FROM  psck
      WHERE policy_no = f_policy_no
        AND nonresp_sw = "Y"
  	    
  FOR f_i = 1 TO 100
    INITIALIZE f_dis_arr[f_i].* TO NULL 
  END FOR 
  LET f_i = 1 
  
  FOREACH pscp_cur INTO  f_dis_arr[f_i].cp_anniv_date
    SELECT  plan_code,rate_scale,cp_pay_amt,cp_anniv_date
      INTO  f_dis_arr[f_i].plan_code,
  	    f_dis_arr[f_i].rate_scale,
  	    f_dis_arr[f_i].cp_pay_amt
      FROM  pscp
      WHERE policy_no = f_policy_no
        AND cp_anniv_date = f_dis_arr[f_i].cp_anniv_date 
  	                     
    SELECT  nonresp_sw
      INTO  f_dis_arr[f_i].nonresp_sw
      FROM  psck 
      WHERE policy_no = f_policy_no 
        AND cp_anniv_date = f_dis_arr[f_i].cp_anniv_date
    --判斷是否註記
    IF  f_dis_arr[f_i].nonresp_sw = "Y" THEN 
      LET f_dis_arr[f_i].nonresp_sw = "*"
    ELSE 
      DISPLAY "有抓到未回領註記資料"
    END IF 
    --找出expired_date	
    SELECT  expired_date 
      INTO  f_expired_date
      FROM  polf 
      WHERE policy_no =  f_policy_no
      --判斷生存/滿期
    IF f_dis_arr[f_i].cp_anniv_date >= f_expired_date THEN 
      LET f_dis_arr[f_i].pay_type = "滿期"
    ELSE 
      LET f_dis_arr[f_i].pay_type = "生存"
    END IF
    --預設nonresp_sw_cancel = "N"
    LET f_dis_arr[f_i].nonresp_sw_cancel = "N"     
    LET f_i = f_i + 1
  END FOREACH 
  LET f_i = f_i - 1 
  
  MESSAGE "請輸入Esc確定,End離開!"
  LET INT_FLAG = FALSE
  LET f_trigger_ind = FALSE
  WHILE  TRUE  
    CALL SET_COUNT(f_i)
    INPUT ARRAY f_dis_arr  WITHOUT DEFAULTS FROM  p_psc03m05_inp_arr.* ATTRIBUTE(WHITE)
      BEFORE INPUT
      	IF f_trigger_ind = TRUE THEN 
      	  LET f_trigger_ind = FALSE 
      	  CALL FGL_SETCURRLINE(p_Scr,p_Arr)
        END IF 
      BEFORE ROW 
      	CALL CursorReset()
    	AFTER FIELD nonresp_sw_cancel
    	IF f_dis_arr[p_Arr].nonresp_sw_cancel <> "Y" AND  
    	  f_dis_arr[p_Arr].nonresp_sw_cancel <> "N" THEN
    	  ERROR "請輸入(Y/N)!!" ATTRIBUTE(RED)
    	  NEXT FIELD nonresp_sw_cancel
    	ELSE 
    	  IF f_dis_arr[p_Arr].nonresp_sw_cancel = "Y" THEN 
    	    LET f_dis_arr[p_Arr].nonresp_sw = " "
    	    DISPLAY " " TO p_psc03m05_inp_arr[p_Scr].nonresp_sw
            BEGIN WORK 
    	      UPDATE  psck 
    	        SET   nonresp_sw =" " 
    		WHERE policy_no = f_policy_no
    		  AND cp_anniv_date = f_dis_arr[p_Arr].cp_anniv_date
          ELSE
    	    DISPLAY "*" TO p_psc03m05_inp_arr[p_Scr].nonresp_sw
    	    LET f_dis_arr[p_Arr].nonresp_sw = "*"
    	    UPDATE  psck 
              SET   nonresp_sw ="Y" 
    	      WHERE policy_no = f_policy_no
    		AND cp_anniv_date = f_dis_arr[p_Arr].cp_anniv_date
    	  END IF 
        END IF
      
      AFTER ROW 
      	CALL CursorReset()
      	IF p_Arr = f_i AND FGL_LASTKEY() = FGL_KEYVAL("Down")  THEN 
      	  LET f_trigger_ind = TRUE
      	  ERROR "此筆為可修正之最後一筆!!" ATTRIBUTE(RED)
      	  SLEEP 1  
      	  EXIT INPUT
      	END IF
        
      AFTER INPUT
        IF INT_FLAG THEN 
    	  LET INT_FLAG = FALSE
    	  ROLLBACK WORK
    	  EXIT WHILE 
    	ELSE 
    	  COMMIT WORK
          ERROR "作業已完成!!" ATTRIBUTE(RED,UNDERLINE)
    	  EXIT WHILE   
        END IF
    END INPUT
  END WHILE 
  RETURN f_nonresp_sw_ind    
END FUNCTION 
------------------------------------------------------------------------------
--  函式名稱: notice_print
--  處理概要: 列印照會單(psck)
--  輸    入:  
--  重要函式:
------------------------------------------------------------------------------
FUNCTION notice_print(f_policy_no , f_cp_anniv_date,f_remit_notice_desc)
  DEFINE f_policy_no LIKE psck.policy_no 
  DEFINE f_cp_anniv_date LIKE psck.cp_anniv_date
  DEFINE f_remit_notice_desc CHAR(70)
  DEFINE f_agent_code LIKE poag.agent_code
  DEFINE f_agent_name CHAR(20)
  DEFINE f_dept_code LIKE agnt.dept_code  --dept.dept_code 
  DEFINE f_dept_name LIKE dept.dept_name
  DEFINE f_applicant_id LIKE clnt.client_id 
  DEFINE f_applicant_name CHAR(20)
  DEFINE f_expired_date LIKE polf.expired_date
  DEFINE f_benf_relation CHAR(1)
  DEFINE f_pay_type CHAR(10)
  DEFINE f_benf RECORD LIKE benf.*
  DEFINE f_benf_name CHAR(200) 
  DEFINE f_benf_name_tmp LIKE benf.names 
  DEFINE f_currency LIKE polf.currency
  DEFINE f_currency_meaning CHAR(10)
  -- "*11/12新增"
  DEFINE f_user_code           LIKE edp_base:usrdat.user_code
  DEFINE f_user_name           LIKE edp_base:usrdat.user_name
  DEFINE f_access_dept         LIKE dept.dept_code
  DEFINE f_access_dept_name    LIKE dept.dept_name
  DEFINE f_user_phone          LIKE edp_base:usrprf.phone
  DEFINE f_user_ext            LIKE edp_base:usrprf.ext
  DEFINE f_user_fax            LIKE edp_base:usrprf.fax   
  -- "*結束新增"
  DEFINE f_cur_cnt  INT 
  DEFINE f_rpt_code_1 CHAR(8) -- psc03m01 原匯款銀行或分行已裁撤或合併
  DEFINE f_rpt_code_2 CHAR(8) -- psc03m02 其他退匯原因且幣別為新台幣
  DEFINE f_rpt_code_3 CHAR(8) -- psc03m03 其他退匯原因且幣別為外幣(目前美元)
  DEFINE f_rpt_name_1 CHAR(40)
  DEFINE f_rpt_name_2 CHAR(40)
  DEFINE f_rpt_name_3 CHAR(40)
  DEFINE f_cp_pay_amt LIKE pscp.cp_pay_amt
  DEFINE f_rpt_cmd		CHAR(1024) --執行照會單列印指令
  DEFINE f_copies		INTEGER    -- locprn的列印份數
  DEFINE f_rcode		INTEGER    --指示照會單是否列印錯誤
  DEFINE f_rcode_desc CHAR(200) --指示照會列印錯誤說明
  DEFINE f_ans CHAR(1) --列印選項 0.IDMS列印 1.線上列印
  DEFINE f_remit_notice_resolve CHAR(70) --照會單回覆聯回覆選項(解決方式)
  DEFINE f_cp_notice_formtype  LIKE    pscr.cp_notice_formtype
  DEFINE f_common_flag         INT

   -- 101/10/23 cmwang 列印照會單功能
  INITIALIZE f_cp_pay_amt TO NULL
  --LET f_cp_pay_amt = 0 
  INITIALIZE f_agent_code TO NULL 
  INITIALIZE f_agent_name TO NULL
  INITIALIZE f_dept_code TO NULL
  INITIALIZE f_dept_name TO NULL
  INITIALIZE f_applicant_id TO NULL
  INITIALIZE f_applicant_name TO NULL
  INITIALIZE f_cp_anniv_date TO NULL
  INITIALIZE f_expired_date TO NULL 
  INITIALIZE f_benf_relation TO NULL 
  INITIALIZE f_pay_type TO NULL
  INITIALIZE f_benf_name TO NULL
  INITIALIZE f_benf_name_tmp TO NULL
  INITIALIZE f_currency TO NULL
  LET f_currency_meaning = " "
  LET f_rcode = 0 
  LET f_rcode_desc = "保單號碼",f_policy_no CLIPPED 
    
  CALL getNames(p_psck.policy_no,"S") RETURNING f_agent_code,f_agent_name
  IF f_agent_code IS NULL OR f_agent_code = " "THEN 
    LET f_rcode = 1
    LET f_rcode_desc = f_rcode_desc CLIPPED,",agent_code 未帶出!"
  ELSE 
    IF  f_agent_name IS NULL OR f_agent_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",agent_name 未帶出!"
    END IF 
  END IF 
  SELECT  dept_code
    INTO  f_dept_code
    FROM  agnt 
    WHERE agent_code = f_agent_code
    IF f_dept_code IS NULL OR f_dept_code = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",dept_code 未帶出!"
    END IF 
    SELECT  dept_name
      INTO  f_dept_name
      FROM  dept
      WHERE dept_code = f_dept_code
    IF f_dept_name IS NULL OR f_dept_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",dept_name 未帶出!"
    END IF 
    CALL getNames(p_psck.policy_no,"O1") RETURNING f_applicant_id , f_applicant_name
    IF f_applicant_name IS NULL OR f_applicant_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",applicant_name 未帶出!"
    END IF 
    LET f_cp_anniv_date = p_psck.cp_anniv_date
    IF f_cp_anniv_date IS NULL OR f_cp_anniv_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",cp_anniv_date 未帶出!"
    END IF
    LET f_expired_date = g_polf.expired_date
    IF f_expired_date IS NULL OR f_expired_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",expired_date 未帶出!"
    END IF
-- 判斷 f_benf_relation 後面找benf_cur 條件會用到
    IF f_expired_date <= f_cp_anniv_date THEN
      LET f_benf_relation = "M"
    ELSE
      LET f_benf_relation = "L"
    END IF
    IF f_expired_date IS NULL OR f_expired_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",expired_date 未帶出!"
    END IF
----判斷給付保險金種類
    LET f_cp_notice_formtype = " "
　　SELECT cp_notice_formtype INTO f_cp_notice_formtype
          FROM   pscr
          WHERE  policy_no    = f_policy_no
          AND    cp_anniv_date = f_cp_anniv_date
    IF f_cp_notice_formtype IS NULL OR f_cp_notice_formtype = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED ,",f_cp_notice_formtype 未帶出!"
    END IF 
    -- 判斷生存/滿期 --
    CASE
      WHEN f_cp_notice_formtype  ="1"
        LET f_pay_type   ="生存保險金"
      WHEN f_cp_notice_formtype  ="1.1"
        LET f_pay_type   ="生存保險金"
      WHEN f_cp_notice_formtype  ="2"
        LET f_pay_type   ="滿期保險金"
      WHEN f_cp_notice_formtype  ="2.1"
        LET f_pay_type   ="滿期保險金"
      WHEN f_cp_notice_formtype  ="3"
        LET f_pay_type   ="生存保險金"
      WHEN f_cp_notice_formtype  ="3.1"
        LET f_pay_type   ="生存保險金"
      WHEN f_cp_notice_formtype  ="4"
        LET f_pay_type   ="滿期保險金"
      WHEN f_cp_notice_formtype  ="4.1"
        LET f_pay_type   ="滿期保險金"
      WHEN f_cp_notice_formtype  ="5"
        IF f_cp_anniv_date >= f_expired_date THEN
          LET f_pay_type ="滿期保險金"
        ELSE
          LET f_pay_type ="生存保險金"
        END IF
      OTHERWISE
        LET f_pay_type   = "  "
    END CASE
  
    LET f_currency = g_polf.currency
    --將幣別改成中文
    CASE f_currency 
      WHEN "TWD" 
        LET f_currency_meaning = "新台幣"
      WHEN "USD"
        LET f_currency_meaning = "美元"
      OTHERWISE 
        LET f_currency_meaning = " "
    END CASE 
    IF f_currency_meaning = " " OR LENGTH(f_currency_meaning CLIPPED) = 0 THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_currency_meaning 未帶出!"
    END IF
     
    DECLARE benf_cur CURSOR FOR 
      SELECT  * 
        FROM  benf
        WHERE policy_no = p_psck.policy_no
          AND relation = f_benf_relation
          AND coverage_no = 0
    LET f_cur_cnt = 0
    LET f_benf_name = ""
    FOREACH benf_cur INTO f_benf.*
      LET f_cur_cnt = f_cur_cnt + 1 
      LET f_benf_name_tmp = ""
      IF LENGTH(f_benf.client_id CLIPPED) != 0 THEN
        SELECT  names INTO f_benf_name_tmp
          FROM  clnt 
          WHERE client_id = f_benf.client_id
     	IF LENGTH(f_benf_name_tmp CLIPPED) != 0 THEN
          LET f_benf_name = f_benf_name CLIPPED ," |",f_benf_name_tmp 
     	END IF
      END IF
      IF f_cur_cnt = 0 THEN 
      	LET f_rcode = 1 
      	LET f_rcode_desc = f_rcode_desc CLIPPED,",benf_name 未帶出!"
      END IF 
      IF f_cur_cnt = 4 THEN 
       	EXIT FOREACH 
      END IF                     		
    END FOREACH
    LET f_benf_name = f_benf_name[3,200]  
    LET f_cp_pay_amt = 0 
    SELECT  cp_pay_amt
      INTO  f_cp_pay_amt
      FROM  pscp 
      WHERE policy_no = f_policy_no
        AND cp_anniv_date = f_cp_anniv_date
    IF f_cp_pay_amt = 0 and p_Arr != 6 THEN 
      LET f_rcode = 1 
      LET f_rcode_desc = f_rcode_desc CLIPPED,",cp_pay_amt 未帶出!"
    END IF
    -- 獲取承辦人相關欄位資訊
    LET f_user_code = g_user
    SELECT  dept_code
      INTO  f_access_dept
      FROM  edp_base:usrdat
      WHERE user_code = f_user_code
    IF f_access_dept IS NULL THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept 未帶出!"
    END IF
    LET f_access_dept_name = " "
    SELECT  dept_name INTO f_access_dept_name
      FROM  dept
      WHERE dept_code = f_access_dept
    IF f_access_dept_name = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept_name 未帶出!"
    END IF
    LET f_user_phone = " "
    LET f_user_ext = " "
    LET f_user_fax = " "
    SELECT  phone,ext,fax INTO f_user_phone,f_user_ext,f_user_fax
      FROM  edp_base:usrprf
      WHERE user_code = f_user_code
    IF f_user_phone = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_phone 未帶出!"
    END IF
    IF f_user_ext = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_ext 未帶出!"
    END IF
    IF f_user_fax = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_fax 未帶出!"
    END IF
    LET f_user_name = " "
    SELECT  user_name
      INTO  f_user_name
      FROM  edp_base:usrdat
      WHERE user_code = f_user_code
    IF f_user_name = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_name 未帶出!"
    END IF    
{ "*
    DECLARE user_cur CURSOR FOR 
      SELECT     access_dept , access_user 
        FROM     apdt 
        WHERE    policy_no = f_policy_no
        ORDER BY po_chg_rece_date DESC
    INITIALIZE f_access_dept TO NULL
    INITIALIZE f_user_code TO NULL
    FOREACH user_cur INTO f_access_dept , f_user_code
      IF f_access_dept IS NULL THEN 
        LET f_rcode = 1 
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept 未帶出!"
      END IF 
      IF f_user_code IS NULL THEN 
        LET f_rcode = 1 
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_code 未帶出!"
      END IF
      LET f_access_dept_name = " "
      SELECT  dept_name INTO f_access_dept_name
        FROM  dept 
        WHERE dept_code = f_access_dept 
      IF f_access_dept_name = " " THEN 
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept_name 未帶出!"
      END IF
      LET f_user_phone = " "
      LET f_user_ext = " "
      LET f_user_fax = " " 
      SELECT  phone,ext,fax INTO f_user_phone,f_user_ext,f_user_fax
        FROM  edp_base:usrprf 
        WHERE user_code = f_user_code
      IF f_user_phone = " " THEN 
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_phone 未帶出!"
      END IF
      IF f_user_ext = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_ext 未帶出!"
      END IF
      IF f_user_fax = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_fax 未帶出!"
      END IF
      LET f_user_name = " "
      SELECT  user_name
        INTO  f_user_name
        FROM  edp_base:usrdat
        WHERE user_code = f_user_code
      IF f_user_name = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_name 未帶出!"
      END IF
      EXIT FOREACH
    END FOREACH
}       
    --選擇列印方式
    PROMPT " 請選擇列印方式 : 0.IDMS 列印  1:線上列印  " ATTRIBUTE (YELLOW) FOR CHAR f_ans
    IF f_ans NOT MATCHES "[0]" THEN
      LET f_ans = '1'
    END IF
    IF f_ans IS NULL OR f_ans = ' ' THEN
      LET f_ans = '1'
    END IF
    -- 取得 f_rpt_name_1,f_rpt_name_2,f_rpt_name_3
    LET f_rpt_code_1 = "psc03m01"
    LET f_rpt_code_2 = "psc03m02"
    LET f_rpt_code_3 = "psc03m03"
    IF f_ans = '0' THEN   -- 送至 PSM 平台
      LET f_rpt_name_1 = ""
      LET f_rpt_name_2 = ""
      LET f_rpt_name_3 = ""
      CALL PSManagerName(f_rpt_code_1) RETURNING f_rpt_name_1
      CALL PSManagerName(f_rpt_code_2) RETURNING f_rpt_name_2
      CALL PSManagerName(f_rpt_code_3) RETURNING f_rpt_name_3
    ELSE                     -- Local
      LET f_rpt_name_1 = ""
      LET f_rpt_name_2 = ""
      LET f_rpt_name_3 = ""
      CALL ReportName(f_rpt_code_1) RETURNING f_rpt_name_1
      CALL ReportName(f_rpt_code_2) RETURNING f_rpt_name_2
      CALL ReportName(f_rpt_code_3) RETURNING f_rpt_name_3
    END IF 
    --判斷資料是否齊全，判斷送出哪張報表
    IF f_rcode =0 THEN
      IF p_Arr = 6 THEN
      	START REPORT rpt_psc03m01 TO f_rpt_name_1
      	OUTPUT TO REPORT rpt_psc03m01(f_dept_name,f_agent_name,f_policy_no,f_cp_anniv_date
      	,f_applicant_name,f_pay_type,f_benf_name,f_remit_notice_resolve,f_access_dept_name
        ,f_user_name,f_user_phone,f_user_ext,f_user_fax,f_dept_code,f_ans)
      	FINISH REPORT rpt_psc03m01
      	--判斷PSM或LOCAL列印
      	IF f_ans = '0'  THEN
      	  LET f_rpt_cmd = "psmanager ",f_rpt_name_1
          RUN f_rpt_cmd
          ERROR "照會單列印完成 !!"
          SLEEP 1
        ELSE
          LET f_copies = SelectPrinter (f_rpt_name_1)
          IF (f_copies ) THEN
            LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                          ,f_rpt_name_1 CLIPPED
            RUN f_rpt_cmd
            ERROR "照會單列印完成 !!"
            SLEEP 1
          END IF
        END IF 
      ELSE
      	IF f_currency = "TWD" THEN
       	  START REPORT rpt_psc03m02 TO f_rpt_name_2
       	  OUTPUT TO REPORT rpt_psc03m02(f_dept_name,f_agent_name,f_policy_no,f_cp_anniv_date
      	  ,f_applicant_name,f_pay_type,f_benf_name,f_currency_meaning,f_cp_pay_amt,f_remit_notice_desc
      	  ,f_remit_notice_resolve,f_access_dept_name,f_user_name,f_user_phone
          ,f_user_ext,f_user_fax,f_dept_code,f_ans)
      	  FINISH REPORT rpt_psc03m02
      	  --判斷PSM或LOCAL列印
      	  IF f_ans = '0'  THEN
      	    LET f_rpt_cmd = "psmanager ",f_rpt_name_2
            RUN f_rpt_cmd
            ERROR "照會單列印完成 !!"
            SLEEP 1
          ELSE
            LET f_copies = SelectPrinter (f_rpt_name_2)
            IF (f_copies ) THEN
              LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                            ,f_rpt_name_2 CLIPPED
              RUN f_rpt_cmd
              ERROR "照會單列印完成 !!"
              SLEEP 1
            END IF
          END IF
      	ELSE
      	  START REPORT rpt_psc03m03 TO f_rpt_name_3
      	  OUTPUT TO REPORT rpt_psc03m03(f_dept_name,f_agent_name,f_policy_no,f_cp_anniv_date
      	   ,f_applicant_name,f_pay_type,f_benf_name,f_currency_meaning,f_cp_pay_amt,f_remit_notice_desc
      	   ,f_remit_notice_resolve,f_access_dept_name,f_user_name,f_user_phone
          ,f_user_ext,f_user_fax,f_dept_code,f_ans)
      	  FINISH REPORT rpt_psc03m03
      	  --判斷PSM或LOCAL列印
      	  IF f_ans = '0'  THEN
      	    LET f_rpt_cmd = "psmanager ",f_rpt_name_3
            RUN f_rpt_cmd
            ERROR "照會單列印完成 !!"
            SLEEP 1
          ELSE
            LET f_copies = SelectPrinter (f_rpt_name_3)
            IF (f_copies ) THEN
              LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                            ,f_rpt_name_3 CLIPPED
              RUN f_rpt_cmd
              ERROR "照會單列印完成 !!"
              SLEEP 1
            END IF
          END IF	  
        END IF 
      END IF 
    END IF 
  RETURN f_rcode,f_rcode_desc
END FUNCTION 
------------------------------------------------------------------------------
--  函式名稱: rpt_psc03m01
--  處理概要: 列印psc03m01
--  輸    入:  
--  重要函式:
------------------------------------------------------------------------------
REPORT rpt_psc03m01(r)
  DEFINE r RECORD 
  	 dept_name LIKE   dept.dept_name
  	,agent_name CHAR(20)
  	,policy_no LIKE psck.policy_no 
  	,cp_anniv_date LIKE psck.cp_anniv_date
  	,applicant_name CHAR(20) 
  	,pay_type CHAR(10)
  	,benf_name CHAR(200)
  	,remit_notice_resolve CHAR(70)
        ,access_dept_name    LIKE dept.dept_name
        ,user_name    LIKE   edp_base:usrdat.user_name
        ,user_phone   LIKE   edp_base:usrprf.phone
        ,user_ext     LIKE   edp_base:usrprf.ext
        ,user_fax     LIKE   edp_base:usrprf.fax
        ,dept_code    LIKE dept.dept_code     
        ,ans         CHAR(1)
  END RECORD 
  DEFINE f_date CHAR(9)
  
  OUTPUT
     TOP    OF PAGE "^L"
     PAGE   LENGTH  66
     LEFT   MARGIN   0
     TOP    MARGIN   0
     BOTTOM MARGIN   0
     
  FORMAT 
    PAGE HEADER
      IF r.ans = "0" THEN 
        PRINT COLUMN 1 ,r.dept_code
        SKIP 5 LINES
      ELSE
        SKIP 6 LINES
      END IF 
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","三商美邦人壽保險股份有限公司"
      SKIP 1 LINES
      PRINT COLUMN 30 ,"~IT26G2;","生存／滿期金照會單"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","致：",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"君"
      SKIP 1 LINES
      PRINT COLUMN 10,"貴保戶於本次應領之還本金，因下列原因致使本單位無法繼續處理相關作業，"
      SKIP 1 LINES 
      PRINT COLUMN 10,"請台端儘速與受益人取得聯絡，以免耽誤保戶領取生存／滿期金的時效。"
      SKIP 1 LINES 
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 55,"給付週年日：",r.cp_anniv_date
      SKIP 2 LINES 
      PRINT COLUMN 7,"要保人：",r.applicant_name CLIPPED,COLUMN 55,"給付種類：",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"受益人：",r.benf_name
      SKIP 7 LINES 
      PRINT COLUMN 7,"照會內容：原匯款銀行或分行已裁撤或合併，無法進行匯款作業，請協助通知"
      SKIP 1 LINES
      PRINT COLUMN 17,"受益人重新填寫生存金回函，並檢附新存摺面頁影本.受益人身分證"
      SKIP 1 LINES 
      PRINT COLUMN 17,"正反面影本。"
      SKIP 5 LINES
      PRINT COLUMN 33,"承辦人：",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED
      PRINT COLUMN 33,"連絡電話：",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"傳真號碼：",r.user_fax CLIPPED
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"列印日：",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","照會單回覆聯"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 54,"還本週年日：",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"服務業務員：",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"□","已連絡保戶，重新回覆生存金回函及檢附相關文件。"
      SKIP 2 LINES
      PRINT COLUMN 7,"□","已聯絡保戶，原帳號無異動，新分行別________________，請依上述資料匯款。"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"業務同仁：______________","手機號碼：_____________","日期：___________"
END REPORT 
------------------------------------------------------------------------------
--  函式名稱: rpt_psc03m02
--  處理概要: 列印psc03m02
--  輸    入:  
--  重要函式:
------------------------------------------------------------------------------
REPORT rpt_psc03m02(r)
  DEFINE r RECORD 
  	dept_name LIKE   dept.dept_name
  	,agent_name CHAR(20)
  	,policy_no LIKE psck.policy_no 
  	,cp_anniv_date LIKE psck.cp_anniv_date
  	,applicant_name CHAR(20) 
  	,pay_type CHAR(10)
  	,benf_name CHAR(200)
  	,currency_meaning CHAR(10)
  	,cp_pay_amt LIKE pscp.cp_pay_amt
  	,remit_notice_desc CHAR(70)
  	,remit_notice_resolve CHAR(70)
        ,access_dept_name    LIKE dept.dept_name
        ,user_name           LIKE edp_base:usrdat.user_name
        ,user_phone          LIKE edp_base:usrprf.phone
        ,user_ext            LIKE edp_base:usrprf.ext
        ,user_fax            LIKE edp_base:usrprf.fax
        ,dept_code           LIKE dept.dept_code
        ,ans         CHAR(1)
  END RECORD  
  DEFINE f_date CHAR(9)
  
  OUTPUT
    TOP    OF PAGE "^L"
    PAGE   LENGTH  66
    LEFT   MARGIN   0
    TOP    MARGIN   0
    BOTTOM MARGIN   0
     
  FORMAT 
    PAGE HEADER
      IF r.ans = "0" THEN
        PRINT COLUMN 1 ,r.dept_code
        SKIP 5 LINES
      ELSE
        SKIP 6 LINES
      END IF
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","三商美邦人壽保險股份有限公司"
      SKIP 1 LINES
      PRINT COLUMN 25 ,"~IT26G2;","生存／滿期金匯款退匯照會單"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","致：",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"君"
      SKIP 1 LINES
      PRINT COLUMN 10,"貴保戶於本次應領之還本金，因下列原因致使本單位無法繼續處理相關作業，"
      SKIP 1 LINES 
      PRINT COLUMN 10,"請台端儘速與受益人取得聯絡，以免耽誤保戶領取生存／滿期金的時效。"
      SKIP 1 LINES 
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 55,"給付週年日：",r.cp_anniv_date
      SKIP 1 LINES 
      PRINT COLUMN 7,"要保人：",r.applicant_name CLIPPED,COLUMN 55,"給付種類：",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"受益人：",r.benf_name
      SKIP 1 LINES
      PRINT COLUMN 7,"幣  別：",r.currency_meaning CLIPPED ,COLUMN 55,"給付金額：","$",r.cp_pay_amt USING  "<<<,<<<,<<&.&&"
      SKIP 7 LINES 
      PRINT COLUMN 7,"照會內容：",r.remit_notice_desc CLIPPED,"，請協助保戶處理"
      SKIP 1 LINES
      PRINT COLUMN 17,"請於三日內傳真回覆本照會單"
      SKIP 4 LINES
      PRINT COLUMN 7,"為避免再次退匯，請協助保戶辦理匯款約定帳戶。"
      SKIP 4 LINES 
      PRINT COLUMN 33,"承辦人：",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED 
      PRINT COLUMN 33,"連絡電話：",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"傳真號碼：",r.user_fax CLIPPED 
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"列印日：",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","退匯照會單回覆聯"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 54,"還本週年日：",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"服務業務員：",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"□","已連絡保戶，請郵寄生存金支票至收費地址。"
      SKIP 2 LINES 
      PRINT COLUMN 7,"□","已聯絡保戶，辦理姓名變更後再重新付款。"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"業務同仁：______________","手機號碼：_____________","日期：___________"
END REPORT 
------------------------------------------------------------------------------
--  函式名稱: rpt_psc03m03
--  處理概要: 列印psc03m02
--  輸    入:  
--  重要函式:
------------------------------------------------------------------------------
REPORT rpt_psc03m03(r)
  DEFINE r RECORD 
  	dept_name LIKE   dept.dept_name
  	,agent_name CHAR(20)
  	,policy_no LIKE psck.policy_no 
  	,cp_anniv_date LIKE psck.cp_anniv_date
  	,applicant_name CHAR(20) 
  	,pay_type CHAR(10)
  	,benf_name CHAR(200)
  	,currency_meaning CHAR(10)
  	,cp_pay_amt LIKE pscp.cp_pay_amt
  	,remit_notice_desc CHAR(70)
  	,remit_notice_resolve CHAR(70)
        ,access_dept_name    LIKE dept.dept_name
        ,user_name    LIKE edp_base:usrdat.user_name
        ,user_phone   LIKE edp_base:usrprf.phone
        ,user_ext     LIKE edp_base:usrprf.ext
        ,user_fax     LIKE edp_base:usrprf.fax
        ,dept_code    LIKE dept.dept_code
        ,ans         CHAR(1)
  END RECORD 
  DEFINE f_date CHAR(9)
  
  OUTPUT
     TOP    OF PAGE "^L"
     PAGE   LENGTH  66
     LEFT   MARGIN   0
     TOP    MARGIN   0
     BOTTOM MARGIN   0
     
  FORMAT 
    PAGE HEADER
      IF r.ans = "0" THEN
        PRINT COLUMN 1 ,r.dept_code
        SKIP 5 LINES
      ELSE
        SKIP 6 LINES
      END IF
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","三商美邦人壽保險股份有限公司"
      SKIP 1 LINES
      PRINT COLUMN 25 ,"~IT26G2;","生存／滿期金匯款退匯照會單"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","致：",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"君"
      SKIP 1 LINES
      PRINT COLUMN 10,"貴保戶於本次應領之還本金，因下列原因致使本單位無法繼續處理相關作業，"
      SKIP 1 LINES 
      PRINT COLUMN 10,"請台端儘速與受益人取得聯絡，以免耽誤保戶領取生存／滿期金的時效。"
      SKIP 1 LINES 
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 55,"給付週年日：",r.cp_anniv_date
      SKIP 1 LINES 
      PRINT COLUMN 7,"要保人：",r.applicant_name CLIPPED,COLUMN 55,"給付種類：",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"受益人：",r.benf_name
      SKIP 1 LINES
      PRINT COLUMN 7,"幣  別：",r.currency_meaning CLIPPED,COLUMN 55,"給付金額：","$",r.cp_pay_amt USING  "<<<,<<<,<<&.&&"
      SKIP 7 LINES 
      PRINT COLUMN 7,"照會內容：",r.remit_notice_desc CLIPPED ,"，請協助保戶處理"
      SKIP 1 LINES
      PRINT COLUMN 17,"請於三日內傳真回覆本照會單"
      SKIP 4 LINES
      PRINT COLUMN 7,"*原約定帳戶已匯款失敗，為避免再次退匯，請協助保戶重新約定外幣指定帳號。"
      SKIP 4 LINES
      PRINT COLUMN 33,"承辦人：",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED
      PRINT COLUMN 33,"連絡電話：",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"傳真號碼：",r.user_fax CLIPPED 
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"列印日：",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","退匯照會單回覆聯"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"保單號碼：",r.policy_no,COLUMN 54,"還本週年日：",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"服務業務員：",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"□","已連絡保戶，重新回覆生存金回函，並請重新匯入指定帳號。"
      SKIP 2 LINES
{      PRINT COLUMN 7,"□","已連絡保戶，因受益人=扣款轉帳授權人，故請直接匯入扣款轉帳帳號。"
      SKIP 1 LINES }
      PRINT COLUMN 7,"□","已聯絡保戶，辦理姓名變更後再重新付款。"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"業務同仁：______________","手機號碼：_____________","日期：___________"
END REPORT 
