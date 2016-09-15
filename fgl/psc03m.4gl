-----------------------------------------------------------------------------
--  �{���W��: psc03m.4gl
--  �@    ��: merlin
--  ��    ��:
--  �B�z���n: �٥����O�@�~
--  ���n�禡:
------------------------------------------------------------------------------
--  �ק��:kobe
--  091/04/11:�s�W���I�ܧ󪺿��
--            �Y��q�ת̿�ܵ��I�ܧ�,�N�R��benf�q�ױb��
------------------------------------------------------------------------------
--  �ק��:kobe
--  093/04/07:�]�����I�覡(�D�ʹq��)���s�W, �קﱱ��
------------------------------------------------------------------------------
--  101/10/01 cmwang �s�W�u�O�_�������^������O�v�\��
--  101/10/15 cmwang �s�W�u�h�׷ӷ|�v�Ρu�״ڻȦ�X��/���M�Ӷסv���ΦC�L�\��
--  101/10/17 cmwang �s�W�u�������^������O�v�\��
--  103/09/29 cmwang SR140800458 �Npsck.nonresp_sw = "N"����ƴ��ѥi��אּY������
--  104/03/05 cmwang SR150300312 ���O�s�W�R����user����
-------------------------------------------------------------------------------
GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/ia.4gl"
#GLOBALS "../def/pscgcpn.4gl"

DATABASE life 
  DEFINE p_bell             CHAR                    --> �a�n�r��
  DEFINE p_space            CHAR(20)                --> �ť�
  DEFINE p_keys             CHAR(400)               --> �d�߱���Ȧs��
  DEFINE p_total_record     INTEGER                 --> ��Ƽ�
  DEFINE p_err              INTEGER                 --> ���~�T��
  DEFINE p_new_flag         INTEGER
  DEFINE p_modu_sw          CHAR
  DEFINE p_answer           CHAR(1)
  DEFINE p_table            CHAR(8)
  DEFINE p_psck             RECORD LIKE psck.*
  DEFINE p_pscb             RECORD LIKE pscb.*
  DEFINE p_pay_change       CHAR(1)                 --> ���I�ܧ�(Y/N)
--101/10/15 cmwang
  DEFINE p_remit_notice     CHAR(1)        --> �h�׷ӷ|(Y/N)
  DEFINE p_Arr              INT            --> ��ư}�C��m
  DEFINE p_Scr              INT            --> �ù��}�C��m
--end 101/10/15 
  DEFINE p_relation	  CHAR(1)
  DEFINE p_pt_sw             CHAR(1) ----pt����
  DEFINE f_rtn               CHAR(1)
  DEFINE f_exist      INTEGER  -- �O���ˮ� --
         ,f_pscb_exist      INTEGER  -- �٥����ˮ� --
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
-- 101/10/17 cmwang �s�W
  CLOSE FORM psc03m01 
-- end 101/10/17  
  CALL ShowLogo()
--  JOB  CONTROL beg --
  CALL JobControl()

  MENU "�п��"
    BEFORE MENU 
    
      IF  NOT CheckAuthority("1", FALSE)  THEN
        HIDE OPTION "1)�s�W�έק���O"
      END IF
      IF  NOT CheckAuthority("2", FALSE)  THEN
        HIDE OPTION "2)�������O"
      END IF
      IF  NOT CheckAuthority("3", FALSE)  THEN
        HIDE OPTION "3)�S��O�汱��"
      END IF

      COMMAND "1)�s�W�έק���O"
        LET INT_FLAG = FALSE
        CALL input()
        CLOSE FORM psc03m01
--  101/10/17 cmwang �s�W
      COMMAND "2)�������O"
        LET INT_FLAG = FALSE 
        CALL input_all()
        CLOSE FORM psc03m05
      COMMAND "3)�S��O�汱��"
        RUN "psc24m.4ge"
-- end 101/10/17
      COMMAND "0)����"
        EXIT MENU
  END MENU    
-- JOB  CONTROL end --
  CALL JobControl()
END MAIN
------------------------------------------------------------------------------
--  �禡�W��: init
--  �B�z���n: �e�����
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION init()
  MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)
  INITIALIZE p_psck.*       TO NULL
  LET p_pay_change=""
  LET p_relation=""
  LET p_pt_sw      ='0'
  LET p_ins_psca01 = 0
END FUNCTION

------------------------------------------------------------------------------
--  �禡�W��: input
--  �B�z���n: ��J���O���e
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION input()
    DEFINE  l_correct               INTEGER   -- ����ˬd t or f --
    DEFINE  l_formated_date         CHAR(9)   -- ����榡�� 999/99/99 --
    DEFINE  l_psck_cnt              INTEGER
    DEFINE  f_pay_change_type       CHAR(1)
           ,f_pay_change_name       CHAR(70)
    DEFINE  f_expired_date	        LIKE polf.expired_date
    -- 101/10/15 cmwang �s�W�h�׷ӷ|���e
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
   
  -- 101/10/15 cmwang �s�W remit_notice����open form �ԭz
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
                ERROR "�O�渹�X������J!!"  ATTRIBUTE (RED)
                NEXT FIELD policy_no
            END IF
    
            SELECT      *
            INTO        g_polf.*
            FROM        polf
            WHERE       policy_no=p_psck.policy_no
    
        IF SQLCA.SQLERRD[3]=0 THEN
            CALL get_ia(p_psck.policy_no) RETURNING f_rtn ----0-���`; 1-���~
            IF f_rtn = 1 THEN
                ERROR "�L���i�O��!!"  ATTRIBUTE (RED)
                NEXT FIELD policy_no
            ELSE
                LET p_pt_sw = '1'
            END IF
        ELSE
            --- 098/10 �s�WSN�����^�� yirong---
            IF p_psck.policy_no[1,1] = '6' THEN
                IF g_polf.insurance_type = 'N' THEN  ---103/07�s�W
                    ERROR "FVA�O�椣�A��!!"  ATTRIBUTE (RED)
                    NEXT FIELD policy_no
                ELSE   
                    LET p_pt_sw = '2'
                END IF
            END IF
        END IF
    
        AFTER FIELD cp_anniv_date
            CALL  CheckDate(p_psck.cp_anniv_date) RETURNING l_correct,l_formated_date
            IF NOT FIELD_TOUCHED(psck.cp_anniv_date) THEN      
                ERROR "�g�~�饲����J!!"  ATTRIBUTE (RED)
                NEXT FIELD cp_anniv_date
            ELSE
              IF l_correct = false THEN
                    ERROR "�g�~���J���~!!" ATTRIBUTE (RED)
                    NEXT FIELD cp_anniv_date
              END IF
            END IF 
            -- DISPLAY "*pt_sw",p_pt_sw
            IF p_pt_sw = '1' THEN ----���I�O�� 
                SELECT  count(*) INTO f_pscb_exist
                FROM    ptpd
                WHERE   policy_no = p_psck.policy_no
                AND     payout_due = p_psck.cp_anniv_date
                AND     opt_notice_sw  in ( '1','2')----�^�Ъ��A 1.���ݦ^�� 2.�w�g�^��
                AND     process_sw     = '0'        ----��l��   1.�w�g���I
                IF f_pscb_exist = 0 THEN
                    ERROR "���I�ɤ��L������� !!"
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
                --- 098/10 �s�WSN�����^�� yirong--- 
                IF p_pt_sw = '2' THEN
                    SELECT  count(*)
                    INTO    f_ptsn_exist
                    FROM    ptsn
                    WHERE   policy_no = p_psck.policy_no
                    AND     iv_terminate_date = p_psck.cp_anniv_date
                    IF f_ptsn_exist = 0 THEN
                        ERROR "���i�O��L�٥����!!"  ATTRIBUTE (RED)
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
                        ERROR "���i�O��L�٥����!!"  ATTRIBUTE (RED)
                        NEXT FIELD policy_no
                    END IF
                    IF  p_pscb.cp_remark_sw="Y" THEN
                        LET p_modu_sw="U"
                        CALL disp()
                    END IF 
                END IF  -- p_pt_sw = '2'
            END IF -- p_pt_sw = '1'
            -- 101/11/09 �Np_pay_change ,remit_notice�w�]�w�� "N" �æb�ù����W���
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
                            ERROR "���i�O��L�k��ܵ��I�ܧ�!!"  ATTRIBUTE(RED)
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
            ----101/10/01 cmwang�s�W�u�O�_�������^������O�v�\��
            CALL nonresp_sw_chg(p_psck.policy_no,p_psck.cp_anniv_date)
            -- 101/10/01 END
    -- 101/10/15 cmwang �h�׷ӷ|���"Y"�Ashow�ﶵ��J���O���e�ťժ����A�ô��ѦC�L�覡�ﶵ
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
    	                LET f_remit_notice_resolve ="���w�p���O��A��z�m�W�ܧ��A���s�I�ڡC"
    	            WHEN 2
    	                LET f_remit_notice_resolve =""
    	            WHEN 3 
    	                LET f_remit_notice_resolve =""
                    WHEN 4 
    	                LET f_remit_notice_resolve =""
    	            WHEN 5 
    	                LET f_remit_notice_resolve =""
    	            WHEN 6
                        LET f_remit_notice_resolve ="���w�p���O��A��b���L���ʡA�s����O________________�A�Ш̤W�z��ƶ״ڡC"
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

        -- ���_�@�~ --
        AFTER  INPUT
            LET p_psck.process_user=g_user
            LET p_psck.process_date=GetDate(TODAY)
            LET p_psck.process_time=TIME        
            MESSAGE " "
            IF INT_FLAG THEN
                LET INT_FLAG = FALSE
                LET p_new_flag = FALSE
                ERROR '��󦹶��@�~!!' ATTRIBUTE(RED,UNDERLINE)
                EXIT INPUT
            END IF
            WHILE 1=1
                PROMPT '�O�_�s��[y/n]' ATTRIBUTE(RED,UNDERLINE) FOR CHAR p_answer
                IF UPSHIFT(p_answer) = 'Y' THEN
                    IF p_modu_sw="U" THEN
                        IF upd()   THEN
                            ERROR '�ק令�\!!' ATTRIBUTE(RED,UNDERLINE)
                        END IF
                    ELSE
                      IF save() THEN
                            ERROR '�s�ɦ��\!!'  ATTRIBUTE(RED,UNDERLINE)
                      END IF
                    END IF
                    LET f_rcode = 0
                    LET f_rcode_desc = ""
                    ----101/10/31 cmwang �h�׷ӷ|���"Y"�ɦC�L�ӷ|��                
                    IF p_remit_notice = 'Y' THEN
                        CALL notice_print(p_psck.policy_no,p_psck.cp_anniv_date,f_remit_notice_desc) RETURNING f_rcode , f_rcode_desc
                    END IF
                    ---- end 101/10/31 
                    IF f_rcode THEN 
                        ERROR "�ӷ|��Ʀ��~�A���p����T��!!"
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
--  �禡�W��: save
--  �B�z���n: �x�s���(psck)
--  ���n�禡:
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
        ----- ���`�q�׵��I�ܧ�ݧR���ӹq�ױb�� --
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
--  �禡�W��: upd
--  �B�z���n: ��s���(psck)
--  ���n�禡:
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
      -- ���`�q�׵��I�ܧ�ݧR���ӹq�ױb�� --
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
--  �禡�W��: upd_data()
--  �B�z���n: ��s���(pscb)
--  ���n�禡:
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
--  �禡�W��: disp
--  �B�z���n: �d����{����
--  ���n�禡:
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
--  �禡�W��: chg_pay_type
--  �B�z���n: ���I�ܧ󱱨�
--  ���n�禡:
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
                LET f_pay_change_name="�䲼�^�P"
                EXIT CASE
              WHEN "1"
                LET f_pay_change_name="�䲼���ú"
                EXIT CASE
              WHEN "2"
                ERROR "��ܿ��~...!!" ATTRIBUTE(RED)
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
                  LET f_pay_change_name="�q�צ^�P"
                  EXIT CASE
                WHEN "1"
                  LET f_pay_change_name="�q�ק��ú"
                  EXIT CASE
                WHEN "2"
                  LET f_pay_change_name="�q�ק�}��"
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
		    LET f_pay_change_name="���^�^�P"
		    EXIT CASE
		  WHEN "1"
		    LET f_pay_change_name="���^���ú"
		    EXIT CASE
		  WHEN "2"
                    ERROR "��ܿ��~...!!" ATTRIBUTE(RED)
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
		      LET f_pay_change_name="�D�ʹq�צ^�P"
		      EXIT CASE
		    WHEN "1"
		      LET f_pay_change_name="�D�ʹq�ק��ú"
		      EXIT CASE
		    WHEN "2"
		      LET f_pay_change_name="�D�ʹq�ק�}��"
		      EXIT CASE
		    OTHERWISE
		      LET f_pay_change_type=""
		      LET f_pay_change_name=""
		      EXIT CASE
		  END CASE
		ELSE
		  LET f_pay_change_type=""
                  LET f_pay_change_name=""
                  ERROR "�L�k�ϥΦ��\��..!!" ATTRIBUTE(RED)
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
    -- 101/10/15 cmwang �ܧ�close window ��m
    CLOSE WINDOW w_psc03m03
    IF INT_FLAG=TRUE THEN
      LET INT_FLAG=FALSE
      CLOSE WINDOW w_psc03m03 RETURN f_pay_change_type,f_pay_change_name
    END IF

    --    CLOSE WINDOW w_psc03m03
    RETURN f_pay_change_type,f_pay_change_name

END FUNCTION
------------------------------------------------------------------------------
--  �禡�W��: nonresp_sw_chg
--  �B�z���n: �s�W���^������O
--  ��    �J: p_psck.policy_no,p_psck.cp_anniv_date
--  �B �z ��: cmwang
--  ���n�禡:
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
            PROMPT "�нT�{�O�_�s�W�������^������O[y/n]?" FOR f_prompt_ans     
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
                --	ERROR "�٥����O�s�ɧ���!!" ATTRIBUTE(RED,UNDERLINE)
    	        RETURN 
            WHEN "Y"
                LET p_psck.nonresp_sw ="Y"
                LET p_ins_psca01 = 1
                ERROR "�s�W���^������O!!" ATTRIBUTE(RED,UNDERLINE)
                
    	        UPDATE    psck
    	        SET       nonresp_sw = "Y"
    	        WHERE     policy_no = f_policy_no
    	        AND       cp_anniv_date = f_cp_anniv_date
                ERROR "�w�s�W���^����O!"
                LET f_do_sw = 1
    	        DISPLAY "*" TO cp_nonresp_sw
            OTHERWISE 
                DISPLAY "f_prompt_ans ����L�i���"
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
            PROMPT "�нT�{�O�_�����������^������O[y/n]?" FOR f_prompt_ans     
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
                --	ERROR "�٥����O�s�ɧ���!!" ATTRIBUTE(RED,UNDERLINE)
    	        RETURN 
            WHEN "Y"
                LET p_psck.nonresp_sw ="Y"
                LET p_ins_psca01 = 1
                ERROR "�������^������O!!" ATTRIBUTE(RED,UNDERLINE)
                
    	        UPDATE    psck
    	        SET       nonresp_sw = " "
    	        WHERE     policy_no = f_policy_no
    	        AND       cp_anniv_date = f_cp_anniv_date
                ERROR "�w�������^����O!"
                LET f_do_sw = 1
                
    	        DISPLAY " " TO cp_nonresp_sw
            OTHERWISE 
                DISPLAY "f_prompt_ans ����L�i���"
        END CASE
    END IF  
END FUNCTION
------------------------------------------------------------------------------
--  �禡�W��: remit_notify
--  �B�z���n: ��ܰh�׷ӷ|���e�ô���user��ܫ�A�N��ܤ��e��J���O���e�ť����
--  ��    �X: f_remit_notice_desc(��ܤ����e) 
--  �B �z ��: 101/10/15 cmwang
--  ���n�禡:
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
  LET f_remit_notice_array_size = 6  --��
  LET f_process_date = GetDate(TODAY)
  FOR f_i = 1 TO f_remit_notice_array_size
    LET f_remit_notice_array[f_i].desc_code = " "
    IF f_i = 1 THEN 
      LET f_remit_notice_array[f_i].desc_code = "V"
    END IF
  END FOR 
  LET f_remit_notice_array[1].remit_desc = "�״ڱb���W���~�y���h��"
  LET f_remit_notice_array[2].remit_desc = "�״ڱb�����~�y���h��"
  LET f_remit_notice_array[3].remit_desc = "�״ڦ]���Ǧ]���y���h��"
  LET f_remit_notice_array[4].remit_desc = "�״ڱb��w���M�y���h��"
  LET f_remit_notice_array[5].remit_desc = "���q�HID���~�y���h��"
  LET f_remit_notice_array[6].remit_desc = "��״ڻȦ�/����w���M�ΦX�֡A�w�ӷ|�~�ȭ��C",f_process_date
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
      	  ERROR "�w�F��Ĥ@�����!" ATTRIBUTE(RED,UNDERLINE)
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
      	  ERROR "�w�F��̫�@�����!" ATTRIBUTE(RED,UNDERLINE)
      	END IF
      ON KEY (INTERRUPT)
        CALL CursorReset()
        LET f_exitdisp_ind = 1
        LET f_remit_notice_desc = ""
        EXIT DISPLAY       
{ Display Array ON KEY �L�k�M�bEsc��W
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
--  �禡�W��: CursorReset
--  �B�z���n: ��s p_Scr , p_Data
--  ��    �X: 
--  �B �z ��: 101/10/15 cmwang
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION CursorReset()
  LET p_Scr = SCR_LINE()
  LET p_Arr = ARR_CURR()
END FUNCTION 
------------------------------------------------------------------------------
--  �禡�W��: input_all
--  �B�z���n: �s�W�������^������O
--  ��    �X: 
--  �B �z ��: 101/10/17 cmwang
--  ���n�禡:
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
  	ERROR "�ӫO�渹�X���b�٥��O��D�ɤ�!!"
  	NEXT FIELD policy_no
      END IF 
      SELECT  expired_date
        INTO  f_expired_date
        FROM  polf 
        WHERE policy_no = f_pscb.policy_no
  
      IF STATUS = NOTFOUND THEN 
  	ERROR "�ӫO�渹�X",f_pscb.policy_no,"�bpolf���䤣��expired_date!!"
  	NEXT FIELD policy_no 
      END IF      
  END INPUT 
  CALL input_arr(f_pscb.policy_no,f_expired_date) RETURNING f_nonresp_sw_ind
  IF f_nonresp_sw_ind = "0" THEN 
    ERROR "�ӫO�渹�X�L���^������O!" ATTRIBUTE(RED)
    SLEEP 1 
  END IF 
  RETURN 
END FUNCTION 
------------------------------------------------------------------------------
--  �禡�W��: input_arr
--  �B�z���n: ��ܫO���T
--  ��    �J:  
--  �B �z ��: 101/10/17 cmwang
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION input_arr(f_policy_no,f_expired_date1)
  DEFINE f_policy_no LIKE pscb.policy_no
  DEFINE f_expired_date1 LIKE polf.expired_date --�ΥH�P�_�����Υͦs
  DEFINE f_nonresp_sw_ind CHAR(1) --�O�_�����^������O����
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
  DEFINE f_i INT     ---����`�� 
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
    --�P�_�O�_���O
    IF  f_dis_arr[f_i].nonresp_sw = "Y" THEN 
      LET f_dis_arr[f_i].nonresp_sw = "*"
    ELSE 
      DISPLAY "����쥼�^����O���"
    END IF 
    --��Xexpired_date	
    SELECT  expired_date 
      INTO  f_expired_date
      FROM  polf 
      WHERE policy_no =  f_policy_no
      --�P�_�ͦs/����
    IF f_dis_arr[f_i].cp_anniv_date >= f_expired_date THEN 
      LET f_dis_arr[f_i].pay_type = "����"
    ELSE 
      LET f_dis_arr[f_i].pay_type = "�ͦs"
    END IF
    --�w�]nonresp_sw_cancel = "N"
    LET f_dis_arr[f_i].nonresp_sw_cancel = "N"     
    LET f_i = f_i + 1
  END FOREACH 
  LET f_i = f_i - 1 
  
  MESSAGE "�п�JEsc�T�w,End���}!"
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
    	  ERROR "�п�J(Y/N)!!" ATTRIBUTE(RED)
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
      	  ERROR "�������i�ץ����̫�@��!!" ATTRIBUTE(RED)
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
          ERROR "�@�~�w����!!" ATTRIBUTE(RED,UNDERLINE)
    	  EXIT WHILE   
        END IF
    END INPUT
  END WHILE 
  RETURN f_nonresp_sw_ind    
END FUNCTION 
------------------------------------------------------------------------------
--  �禡�W��: notice_print
--  �B�z���n: �C�L�ӷ|��(psck)
--  ��    �J:  
--  ���n�禡:
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
  -- "*11/12�s�W"
  DEFINE f_user_code           LIKE edp_base:usrdat.user_code
  DEFINE f_user_name           LIKE edp_base:usrdat.user_name
  DEFINE f_access_dept         LIKE dept.dept_code
  DEFINE f_access_dept_name    LIKE dept.dept_name
  DEFINE f_user_phone          LIKE edp_base:usrprf.phone
  DEFINE f_user_ext            LIKE edp_base:usrprf.ext
  DEFINE f_user_fax            LIKE edp_base:usrprf.fax   
  -- "*�����s�W"
  DEFINE f_cur_cnt  INT 
  DEFINE f_rpt_code_1 CHAR(8) -- psc03m01 ��״ڻȦ�Τ���w���M�ΦX��
  DEFINE f_rpt_code_2 CHAR(8) -- psc03m02 ��L�h�׭�]�B���O���s�x��
  DEFINE f_rpt_code_3 CHAR(8) -- psc03m03 ��L�h�׭�]�B���O���~��(�ثe����)
  DEFINE f_rpt_name_1 CHAR(40)
  DEFINE f_rpt_name_2 CHAR(40)
  DEFINE f_rpt_name_3 CHAR(40)
  DEFINE f_cp_pay_amt LIKE pscp.cp_pay_amt
  DEFINE f_rpt_cmd		CHAR(1024) --����ӷ|��C�L���O
  DEFINE f_copies		INTEGER    -- locprn���C�L����
  DEFINE f_rcode		INTEGER    --���ܷӷ|��O�_�C�L���~
  DEFINE f_rcode_desc CHAR(200) --���ܷӷ|�C�L���~����
  DEFINE f_ans CHAR(1) --�C�L�ﶵ 0.IDMS�C�L 1.�u�W�C�L
  DEFINE f_remit_notice_resolve CHAR(70) --�ӷ|��^���p�^�пﶵ(�ѨM�覡)
  DEFINE f_cp_notice_formtype  LIKE    pscr.cp_notice_formtype
  DEFINE f_common_flag         INT

   -- 101/10/23 cmwang �C�L�ӷ|��\��
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
  LET f_rcode_desc = "�O�渹�X",f_policy_no CLIPPED 
    
  CALL getNames(p_psck.policy_no,"S") RETURNING f_agent_code,f_agent_name
  IF f_agent_code IS NULL OR f_agent_code = " "THEN 
    LET f_rcode = 1
    LET f_rcode_desc = f_rcode_desc CLIPPED,",agent_code ���a�X!"
  ELSE 
    IF  f_agent_name IS NULL OR f_agent_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",agent_name ���a�X!"
    END IF 
  END IF 
  SELECT  dept_code
    INTO  f_dept_code
    FROM  agnt 
    WHERE agent_code = f_agent_code
    IF f_dept_code IS NULL OR f_dept_code = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",dept_code ���a�X!"
    END IF 
    SELECT  dept_name
      INTO  f_dept_name
      FROM  dept
      WHERE dept_code = f_dept_code
    IF f_dept_name IS NULL OR f_dept_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",dept_name ���a�X!"
    END IF 
    CALL getNames(p_psck.policy_no,"O1") RETURNING f_applicant_id , f_applicant_name
    IF f_applicant_name IS NULL OR f_applicant_name = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",applicant_name ���a�X!"
    END IF 
    LET f_cp_anniv_date = p_psck.cp_anniv_date
    IF f_cp_anniv_date IS NULL OR f_cp_anniv_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",cp_anniv_date ���a�X!"
    END IF
    LET f_expired_date = g_polf.expired_date
    IF f_expired_date IS NULL OR f_expired_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",expired_date ���a�X!"
    END IF
-- �P�_ f_benf_relation �᭱��benf_cur ����|�Ψ�
    IF f_expired_date <= f_cp_anniv_date THEN
      LET f_benf_relation = "M"
    ELSE
      LET f_benf_relation = "L"
    END IF
    IF f_expired_date IS NULL OR f_expired_date = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",expired_date ���a�X!"
    END IF
----�P�_���I�O�I������
    LET f_cp_notice_formtype = " "
�@�@SELECT cp_notice_formtype INTO f_cp_notice_formtype
          FROM   pscr
          WHERE  policy_no    = f_policy_no
          AND    cp_anniv_date = f_cp_anniv_date
    IF f_cp_notice_formtype IS NULL OR f_cp_notice_formtype = " " THEN 
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED ,",f_cp_notice_formtype ���a�X!"
    END IF 
    -- �P�_�ͦs/���� --
    CASE
      WHEN f_cp_notice_formtype  ="1"
        LET f_pay_type   ="�ͦs�O�I��"
      WHEN f_cp_notice_formtype  ="1.1"
        LET f_pay_type   ="�ͦs�O�I��"
      WHEN f_cp_notice_formtype  ="2"
        LET f_pay_type   ="�����O�I��"
      WHEN f_cp_notice_formtype  ="2.1"
        LET f_pay_type   ="�����O�I��"
      WHEN f_cp_notice_formtype  ="3"
        LET f_pay_type   ="�ͦs�O�I��"
      WHEN f_cp_notice_formtype  ="3.1"
        LET f_pay_type   ="�ͦs�O�I��"
      WHEN f_cp_notice_formtype  ="4"
        LET f_pay_type   ="�����O�I��"
      WHEN f_cp_notice_formtype  ="4.1"
        LET f_pay_type   ="�����O�I��"
      WHEN f_cp_notice_formtype  ="5"
        IF f_cp_anniv_date >= f_expired_date THEN
          LET f_pay_type ="�����O�I��"
        ELSE
          LET f_pay_type ="�ͦs�O�I��"
        END IF
      OTHERWISE
        LET f_pay_type   = "  "
    END CASE
  
    LET f_currency = g_polf.currency
    --�N���O�令����
    CASE f_currency 
      WHEN "TWD" 
        LET f_currency_meaning = "�s�x��"
      WHEN "USD"
        LET f_currency_meaning = "����"
      OTHERWISE 
        LET f_currency_meaning = " "
    END CASE 
    IF f_currency_meaning = " " OR LENGTH(f_currency_meaning CLIPPED) = 0 THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_currency_meaning ���a�X!"
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
      	LET f_rcode_desc = f_rcode_desc CLIPPED,",benf_name ���a�X!"
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
      LET f_rcode_desc = f_rcode_desc CLIPPED,",cp_pay_amt ���a�X!"
    END IF
    -- ����ӿ�H��������T
    LET f_user_code = g_user
    SELECT  dept_code
      INTO  f_access_dept
      FROM  edp_base:usrdat
      WHERE user_code = f_user_code
    IF f_access_dept IS NULL THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept ���a�X!"
    END IF
    LET f_access_dept_name = " "
    SELECT  dept_name INTO f_access_dept_name
      FROM  dept
      WHERE dept_code = f_access_dept
    IF f_access_dept_name = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept_name ���a�X!"
    END IF
    LET f_user_phone = " "
    LET f_user_ext = " "
    LET f_user_fax = " "
    SELECT  phone,ext,fax INTO f_user_phone,f_user_ext,f_user_fax
      FROM  edp_base:usrprf
      WHERE user_code = f_user_code
    IF f_user_phone = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_phone ���a�X!"
    END IF
    IF f_user_ext = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_ext ���a�X!"
    END IF
    IF f_user_fax = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_fax ���a�X!"
    END IF
    LET f_user_name = " "
    SELECT  user_name
      INTO  f_user_name
      FROM  edp_base:usrdat
      WHERE user_code = f_user_code
    IF f_user_name = " " THEN
      LET f_rcode = 1
      LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_name ���a�X!"
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
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept ���a�X!"
      END IF 
      IF f_user_code IS NULL THEN 
        LET f_rcode = 1 
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_code ���a�X!"
      END IF
      LET f_access_dept_name = " "
      SELECT  dept_name INTO f_access_dept_name
        FROM  dept 
        WHERE dept_code = f_access_dept 
      IF f_access_dept_name = " " THEN 
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_access_dept_name ���a�X!"
      END IF
      LET f_user_phone = " "
      LET f_user_ext = " "
      LET f_user_fax = " " 
      SELECT  phone,ext,fax INTO f_user_phone,f_user_ext,f_user_fax
        FROM  edp_base:usrprf 
        WHERE user_code = f_user_code
      IF f_user_phone = " " THEN 
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_phone ���a�X!"
      END IF
      IF f_user_ext = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_ext ���a�X!"
      END IF
      IF f_user_fax = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_fax ���a�X!"
      END IF
      LET f_user_name = " "
      SELECT  user_name
        INTO  f_user_name
        FROM  edp_base:usrdat
        WHERE user_code = f_user_code
      IF f_user_name = " " THEN
        LET f_rcode = 1
        LET f_rcode_desc = f_rcode_desc CLIPPED,",f_user_name ���a�X!"
      END IF
      EXIT FOREACH
    END FOREACH
}       
    --��ܦC�L�覡
    PROMPT " �п�ܦC�L�覡 : 0.IDMS �C�L  1:�u�W�C�L  " ATTRIBUTE (YELLOW) FOR CHAR f_ans
    IF f_ans NOT MATCHES "[0]" THEN
      LET f_ans = '1'
    END IF
    IF f_ans IS NULL OR f_ans = ' ' THEN
      LET f_ans = '1'
    END IF
    -- ���o f_rpt_name_1,f_rpt_name_2,f_rpt_name_3
    LET f_rpt_code_1 = "psc03m01"
    LET f_rpt_code_2 = "psc03m02"
    LET f_rpt_code_3 = "psc03m03"
    IF f_ans = '0' THEN   -- �e�� PSM ���x
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
    --�P�_��ƬO�_�����A�P�_�e�X���i����
    IF f_rcode =0 THEN
      IF p_Arr = 6 THEN
      	START REPORT rpt_psc03m01 TO f_rpt_name_1
      	OUTPUT TO REPORT rpt_psc03m01(f_dept_name,f_agent_name,f_policy_no,f_cp_anniv_date
      	,f_applicant_name,f_pay_type,f_benf_name,f_remit_notice_resolve,f_access_dept_name
        ,f_user_name,f_user_phone,f_user_ext,f_user_fax,f_dept_code,f_ans)
      	FINISH REPORT rpt_psc03m01
      	--�P�_PSM��LOCAL�C�L
      	IF f_ans = '0'  THEN
      	  LET f_rpt_cmd = "psmanager ",f_rpt_name_1
          RUN f_rpt_cmd
          ERROR "�ӷ|��C�L���� !!"
          SLEEP 1
        ELSE
          LET f_copies = SelectPrinter (f_rpt_name_1)
          IF (f_copies ) THEN
            LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                          ,f_rpt_name_1 CLIPPED
            RUN f_rpt_cmd
            ERROR "�ӷ|��C�L���� !!"
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
      	  --�P�_PSM��LOCAL�C�L
      	  IF f_ans = '0'  THEN
      	    LET f_rpt_cmd = "psmanager ",f_rpt_name_2
            RUN f_rpt_cmd
            ERROR "�ӷ|��C�L���� !!"
            SLEEP 1
          ELSE
            LET f_copies = SelectPrinter (f_rpt_name_2)
            IF (f_copies ) THEN
              LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                            ,f_rpt_name_2 CLIPPED
              RUN f_rpt_cmd
              ERROR "�ӷ|��C�L���� !!"
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
      	  --�P�_PSM��LOCAL�C�L
      	  IF f_ans = '0'  THEN
      	    LET f_rpt_cmd = "psmanager ",f_rpt_name_3
            RUN f_rpt_cmd
            ERROR "�ӷ|��C�L���� !!"
            SLEEP 1
          ELSE
            LET f_copies = SelectPrinter (f_rpt_name_3)
            IF (f_copies ) THEN
              LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                            ,f_rpt_name_3 CLIPPED
              RUN f_rpt_cmd
              ERROR "�ӷ|��C�L���� !!"
              SLEEP 1
            END IF
          END IF	  
        END IF 
      END IF 
    END IF 
  RETURN f_rcode,f_rcode_desc
END FUNCTION 
------------------------------------------------------------------------------
--  �禡�W��: rpt_psc03m01
--  �B�z���n: �C�Lpsc03m01
--  ��    �J:  
--  ���n�禡:
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
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","�T�Ӭ����H�ثO�I�ѥ��������q"
      SKIP 1 LINES
      PRINT COLUMN 30 ,"~IT26G2;","�ͦs���������ӷ|��"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","�P�G",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"�g"
      SKIP 1 LINES
      PRINT COLUMN 10,"�Q�O��󥻦����⤧�٥����A�]�U�C��]�P�ϥ����L�k�~��B�z�����@�~�A"
      SKIP 1 LINES 
      PRINT COLUMN 10,"�Хx�ݾ��t�P���q�H���o�p���A�H�K�Ի~�O�����ͦs�����������ɮġC"
      SKIP 1 LINES 
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 55,"���I�g�~��G",r.cp_anniv_date
      SKIP 2 LINES 
      PRINT COLUMN 7,"�n�O�H�G",r.applicant_name CLIPPED,COLUMN 55,"���I�����G",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"���q�H�G",r.benf_name
      SKIP 7 LINES 
      PRINT COLUMN 7,"�ӷ|���e�G��״ڻȦ�Τ���w���M�ΦX�֡A�L�k�i��״ڧ@�~�A�Ш�U�q��"
      SKIP 1 LINES
      PRINT COLUMN 17,"���q�H���s��g�ͦs���^��A���˪��s�s�P�����v��.���q�H������"
      SKIP 1 LINES 
      PRINT COLUMN 17,"���ϭ��v���C"
      SKIP 5 LINES
      PRINT COLUMN 33,"�ӿ�H�G",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED
      PRINT COLUMN 33,"�s���q�ܡG",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"�ǯu���X�G",r.user_fax CLIPPED
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"�C�L��G",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","�ӷ|��^���p"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 54,"�٥��g�~��G",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"�A�ȷ~�ȭ��G",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"��","�w�s���O��A���s�^�Хͦs���^����˪��������C"
      SKIP 2 LINES
      PRINT COLUMN 7,"��","�w�p���O��A��b���L���ʡA�s����O________________�A�Ш̤W�z��ƶ״ڡC"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"�~�ȦP���G______________","������X�G_____________","����G___________"
END REPORT 
------------------------------------------------------------------------------
--  �禡�W��: rpt_psc03m02
--  �B�z���n: �C�Lpsc03m02
--  ��    �J:  
--  ���n�禡:
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
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","�T�Ӭ����H�ثO�I�ѥ��������q"
      SKIP 1 LINES
      PRINT COLUMN 25 ,"~IT26G2;","�ͦs���������״ڰh�׷ӷ|��"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","�P�G",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"�g"
      SKIP 1 LINES
      PRINT COLUMN 10,"�Q�O��󥻦����⤧�٥����A�]�U�C��]�P�ϥ����L�k�~��B�z�����@�~�A"
      SKIP 1 LINES 
      PRINT COLUMN 10,"�Хx�ݾ��t�P���q�H���o�p���A�H�K�Ի~�O�����ͦs�����������ɮġC"
      SKIP 1 LINES 
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 55,"���I�g�~��G",r.cp_anniv_date
      SKIP 1 LINES 
      PRINT COLUMN 7,"�n�O�H�G",r.applicant_name CLIPPED,COLUMN 55,"���I�����G",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"���q�H�G",r.benf_name
      SKIP 1 LINES
      PRINT COLUMN 7,"��  �O�G",r.currency_meaning CLIPPED ,COLUMN 55,"���I���B�G","$",r.cp_pay_amt USING  "<<<,<<<,<<&.&&"
      SKIP 7 LINES 
      PRINT COLUMN 7,"�ӷ|���e�G",r.remit_notice_desc CLIPPED,"�A�Ш�U�O��B�z"
      SKIP 1 LINES
      PRINT COLUMN 17,"�Щ�T�餺�ǯu�^�Х��ӷ|��"
      SKIP 4 LINES
      PRINT COLUMN 7,"���קK�A���h�סA�Ш�U�O���z�״ڬ��w�b��C"
      SKIP 4 LINES 
      PRINT COLUMN 33,"�ӿ�H�G",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED 
      PRINT COLUMN 33,"�s���q�ܡG",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"�ǯu���X�G",r.user_fax CLIPPED 
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"�C�L��G",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","�h�׷ӷ|��^���p"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 54,"�٥��g�~��G",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"�A�ȷ~�ȭ��G",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"��","�w�s���O��A�жl�H�ͦs���䲼�ܦ��O�a�}�C"
      SKIP 2 LINES 
      PRINT COLUMN 7,"��","�w�p���O��A��z�m�W�ܧ��A���s�I�ڡC"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"�~�ȦP���G______________","������X�G_____________","����G___________"
END REPORT 
------------------------------------------------------------------------------
--  �禡�W��: rpt_psc03m03
--  �B�z���n: �C�Lpsc03m02
--  ��    �J:  
--  ���n�禡:
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
      PRINT COLUMN 25 ,ASCII 126,"IT26G2;","�T�Ӭ����H�ثO�I�ѥ��������q"
      SKIP 1 LINES
      PRINT COLUMN 25 ,"~IT26G2;","�ͦs���������״ڰh�׷ӷ|��"
      SKIP 1 LINES 
      
    ON EVERY ROW
      PRINT COLUMN 7,ASCII 126,"IT22G2;","�P�G",r.dept_name CLIPPED," ",r.agent_name CLIPPED ,COLUMN 46,"�g"
      SKIP 1 LINES
      PRINT COLUMN 10,"�Q�O��󥻦����⤧�٥����A�]�U�C��]�P�ϥ����L�k�~��B�z�����@�~�A"
      SKIP 1 LINES 
      PRINT COLUMN 10,"�Хx�ݾ��t�P���q�H���o�p���A�H�K�Ի~�O�����ͦs�����������ɮġC"
      SKIP 1 LINES 
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 55,"���I�g�~��G",r.cp_anniv_date
      SKIP 1 LINES 
      PRINT COLUMN 7,"�n�O�H�G",r.applicant_name CLIPPED,COLUMN 55,"���I�����G",r.pay_type
      SKIP 1 LINES 
      PRINT COLUMN 7,"���q�H�G",r.benf_name
      SKIP 1 LINES
      PRINT COLUMN 7,"��  �O�G",r.currency_meaning CLIPPED,COLUMN 55,"���I���B�G","$",r.cp_pay_amt USING  "<<<,<<<,<<&.&&"
      SKIP 7 LINES 
      PRINT COLUMN 7,"�ӷ|���e�G",r.remit_notice_desc CLIPPED ,"�A�Ш�U�O��B�z"
      SKIP 1 LINES
      PRINT COLUMN 17,"�Щ�T�餺�ǯu�^�Х��ӷ|��"
      SKIP 4 LINES
      PRINT COLUMN 7,"*����w�b��w�״ڥ��ѡA���קK�A���h�סA�Ш�U�O�᭫�s���w�~�����w�b���C"
      SKIP 4 LINES
      PRINT COLUMN 33,"�ӿ�H�G",r.access_dept_name CLIPPED ,"   ",r.user_name CLIPPED
      PRINT COLUMN 33,"�s���q�ܡG",r.user_phone CLIPPED ,"*",r.user_ext CLIPPED
      PRINT COLUMN 33,"�ǯu���X�G",r.user_fax CLIPPED 
      LET f_date = getDate(TODAY)
      PRINT COLUMN 33,"�C�L��G",f_date 
      PRINT "------------------------------------------------------------------------------"
      SKIP 1 LINES
      PRINT COLUMN 40,ASCII 126,"~IT26G2;","�h�׷ӷ|��^���p"
      SKIP 1 LINES
      PRINT ASCII 126,"~IT22G2;"
      PRINT COLUMN 7,"�O�渹�X�G",r.policy_no,COLUMN 54,"�٥��g�~��G",r.cp_anniv_date
      SKIP 1 LINES
      PRINT COLUMN 7,"�A�ȷ~�ȭ��G",r.agent_name
      SKIP 1 LINES 
      PRINT COLUMN 7,"��","�w�s���O��A���s�^�Хͦs���^��A�ýЭ��s�פJ���w�b���C"
      SKIP 2 LINES
{      PRINT COLUMN 7,"��","�w�s���O��A�]���q�H=������b���v�H�A�G�Ъ����פJ������b�b���C"
      SKIP 1 LINES }
      PRINT COLUMN 7,"��","�w�p���O��A��z�m�W�ܧ��A���s�I�ڡC"--r.remit_notice_resolve
      SKIP 3 LINES 
      PRINT COLUMN 5,"�~�ȦP���G______________","������X�G_____________","����G___________"
END REPORT 
