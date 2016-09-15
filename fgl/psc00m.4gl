------------------------------------------------------------------------------
--  �{���W��: psc00m.4gl
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: �٥��q���^�Ч@�~
--  ���n�禡:
------------------------------------------------------------------------------
--  �s�����٥��^�Ч@�~:���ӷ|�P���I
------------------------------------------------------------------------------
--  089/11/21�s�W�O��(92000)�B���Ʀ�F����(9A000)
------------------------------------------------------------------------------
--  �ק��:JC
--  090/04/25:�ק���q�H�W�r����k,��id ��clnt,�_�h��� benf �� names
------------------------------------------------------------------------------
--  �ק��:merlin
--  090/05/22:�̪F��F����(98000)�W�ߧ@�~�A���k�ݩ󰪶������q(97000)
------------------------------------------------------------------------------
--  ��  ��:JC 090/07/20 SR:PS90655S �t�X�ק�,�e���h�@�ӫO�檬�A
--         ���I�覡�� "��ú�O�O" ,�n����e�ڵ{��,�O���䥦�i�O��
--         �`�N:�Y�q "��ú" �אּ �䥦�覡,��ƥ������B�z
--              po_sts < 50 �~�i�H��ú,���� pc961_process �ǤJ p_pc961_data
--         define p_pc961_data record �{����b pc961p0.4gl ��
--                prss_code:EDIT=�s��,SAVE=�s��,DELE=�R��,PASS=�L�b,QURY=�d��
------------------------------------------------------------------------------
--  �ק��:kobe
--  091/04/11:���^����]�|�s�W��pscn
------------------------------------------------------------------------------
--  �ק��:kobe
--  091/11/16:���^����|�O��log��psck��
------------------------------------------------------------------------------
--  �ק��:kobe
--  092/01/22:(1)�s�W�e�� psc00m00 �ٴ����
--            (2)�^�е{�Ǥ�, ��󤣻���粒��i�����C�L
------------------------------------------------------------------------------
--  �ק��:kurt
--  095/05/26:�s�W���I�^�ж���
------------------------------------------------------------------------------
--  �ק��:yirong
--  095/12/29:�s�W��ú�O�O�^�б���,�ݨDPS95I99S
------------------------------------------------------------------------------
--  �ק��:yirong
--  098/03/24:�s�W�^�Ф覡�����^�y�M��
------------------------------------------------------------------------------
--  �ק��:JUCHUN
--  100/03/31:�t�X�~���٥��i��ץ�
------------------------------------------------------------------------------
--  �ק��:JUCHUN
--  101/02/20:�ץ�bug:�^�Юɤ����~��/�x���O��A�ݥ����s�}��FORM
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--  �ק��:yirong
--  101/09/06:�s�W�d�x����i�H�Y�ɹL�b�I�spsc30s01
------------------------------------------------------------------------------
--  �ק��:cmwang SR130800093
--  102/08/06:���^�����psck�s�W�@����ơA�s�Wnonresp_sw_add()
------------------------------------------------------------------------------
--  �ק��:yirong
--  102/10/04:����6�����^�y�ﶵ
------------------------------------------------------------------------------
--  �ק��:cmwang
--  103/12/23:�s�Wp_upd_psck�A�Nupd_psck�ʧ@��Jpsc01m_save_data
-----------------------------------------------------------------------------
--  �ק��:cmwang 
--  104/01/19:������奼�^����ɯd�Ulog��pscba�A�ߤWpsc96b.4gl���沣�X������
----------------------------------------------------------------------------
--  �ק��: pyliu(�٦�psca02m�S����I��done)�R�ǻ�����r�ε��ק�I
--  105/01/28 SR151200331:���q�H�L��Ʈɥd��
----------------------------------------------------------------------------
--  �ק��: JUCHUN
--  105/04/01 �뵹�I�I�إu��^�� 0:�l�H�䲼,3:�q ��,4:���^���
----------------------------------------------------------------------------
--  �ק��: JUCHUN
--  105/07/06 �s�W9B000���������q
----------------------------------------------------------------------------
--  ��  ��:JUCHUN
--  105/07/20 �קK�뵹�I�I���ܧ��A�I�اP�_���~
--            �Y�w�s�bpscp,�N��pscp�������I�اP�_ 
--            �_�h,�ΫO��ثe�I�بӧP�_ 
-------------------------------------------------------------------------------

GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/pscgcpn.4gl"
GLOBALS "../def/report.4gl"
GLOBALS "../def/ia.4gl"
GLOBALS "../def/ptinface.4gl"
GLOBALS "../def/disburst.4gl"
GLOBALS "../def/pscgchk.4gl"

DATABASE life

    DEFINE p_space           CHAR(20)
          ,p_bell            CHAR
          ,p_tx_date         CHAR(9)   -- �@�b��� --
          ,p_tran_date       CHAR(9)   -- ������ --
          ,p_pass_or_deny    INTEGER   -- �v���ˮ� --

    DEFINE p_pscb           RECORD LIKE pscb.*
    DEFINE p_policy_no           LIKE polf.policy_no
          ,p_cp_anniv_date       LIKE pscb.cp_anniv_date
          ,p_po_sts_code         LIKE polf.po_sts_code
          ,p_benf_relation       CHAR(1)
          ,p_act_return_date     CHAR(9)
          ,p_cp_notice_code      CHAR(1)
          ,p_cp_notice_dif_code  CHAR(1)
          ,p_dif_code_desc       CHAR(30)
          ,p_cp_notice_sub_code  CHAR(1)
          ,p_notice_desc         CHAR(1024) -- �ʤ�󪺤��e --
          ,p_notice_desc_len     INTEGER    -- �ʤ�󤺮e������ --
          ,p_notice_desc_1       CHAR(30)
          ,p_notice_desc_2       CHAR(30)
          ,p_notice_desc_3       CHAR(30)
          ,p_notice_desc_4       CHAR(30)
          ,p_notice_desc_5       CHAR(30)
          ,p_notice_desc_6       CHAR(30)
          ,p_notice_desc_7       CHAR(30)

    DEFINE p_pscg ARRAY[7]  OF RECORD
           input_desc            CHAR(30)
                           END RECORD

    DEFINE p_pscg_notice_desc_1  CHAR(30)
          ,p_pscg_notice_desc_2  CHAR(30)
          ,p_pscg_notice_desc_3  CHAR(30)
          ,p_pscg_notice_desc_4  CHAR(30)
          ,p_pscg_notice_desc_5  CHAR(30)
          ,p_pscg_notice_desc_6  CHAR(30)
          ,p_pscg_notice_desc_7  CHAR(30)

    DEFINE p_dif ARRAY [99]  OF RECORD
           cp_notice_dif_code LIKE pscf.cp_notice_dif_code
          ,dif_code_desc      LIKE pscf.cp_dif_code_desc
                            END RECORD

    DEFINE p_applicant_id     LIKE clnt.client_id
          ,p_applicant_name   LIKE clnt.names
          ,p_tel_1            LIKE addr.tel_1
          ,p_tel_2            LIKE addr.tel_2
          ,p_coverage_no      LIKE colf.coverage_no
          ,p_benf_cnt         INTEGER
          ,p_pce_param        CHAR(1)
          ,p_old_cp_disb_type CHAR(1)
          ,p_cp_sw            CHAR(1)

    DEFINE p_pc961_sw        SMALLINT
          ,p_pc961_msg       CHAR(78)

    DEFINE p_pc961_data       RECORD
           policy_no          LIKE pscb.policy_no
          ,cp_anniv_date      LIKE pscb.cp_anniv_date
          ,prss_code          CHAR(4)
          ,tran_date          CHAR(9)
          ,cp_pay_amt         LIKE pcpm.cp_pay_amt
          ,col_policy_no_1    LIKE pscb.policy_no
          ,col_policy_no_2    LIKE pscb.policy_no
          ,col_policy_no_3    LIKE pscb.policy_no
          ,col_policy_no_4    LIKE pscb.policy_no
          ,col_policy_no_5    LIKE pscb.policy_no
          ,col_policy_no_6    LIKE pscb.policy_no
          ,col_policy_no_7    LIKE pscb.policy_no
          ,col_policy_no_8    LIKE pscb.policy_no
          ,col_policy_no_9    LIKE pscb.policy_no
          ,col_policy_no_10   LIKE pscb.policy_no
                          END RECORD
    -- �٥���ú�O�O�P���O�t�X --
    DEFINE p_pcps    RECORD LIKE pcps.* 
    DEFINE ans       CHAR(1)

    -- �e���@�W�b������� --
    DEFINE p_data_s1 RECORD -- screen s1 -- 
           policy_no         LIKE polf.policy_no
          ,po_sts_code       LIKE polf.po_sts_code
          ,cp_anniv_date     LIKE pscp.cp_anniv_date
          ,po_chg_rece_no    LIKE apdt.po_chg_rece_no
          ,cp_disb_type      LIKE pscb.cp_disb_type
          ,mail_addr_ind     LIKE pscb.mail_addr_ind
          ,disb_special_ind  LIKE pscb.disb_special_ind
	  ,cp_rtn_sw	     LIKE pscb.cp_rtn_sw
          ,cp_pay_name       CHAR(12)
          ,cp_pay_id         CHAR(10)
	  ,dept_name	     CHAR(18)
--          ,dept_code         CHAR(6)
                 END RECORD
    -- �����Ĥ@������줴�һݪ��ܼ� --
    DEFINE p_dept_code	     LIKE dept.dept_code

    -- �e���@�ĤT������� --
    DEFINE p_data_s3 RECORD
           psck_sw           CHAR(1)                 -- �٥����O --
	  ,overloan_desc     CHAR(1)		     -- OVERLOAN ���� --
	  ,notice_resp_desc  CHAR(1)		     -- �^�Ы��� --
          ,app_name          CHAR(12)                -- �n�O�H   --
	  ,app_id	     CHAR(10)		     -- �n�O�Hid --
          ,insured_name      CHAR(12)                -- �Q�O�H   --
          ,insured_id	     CHAR(10)		     -- �Q�O�Hid --
                 END RECORD

    -- �����ĤT������줴�һݪ��ܼ� --
    DEFINE p_agent_code	     LIKE agnt.agent_code    -- �~�ȭ�   --
          ,p_dept_code_1     LIKE dept.dept_code     -- ��~��� --

    -- �e���G detail ��� --
    DEFINE p_data_s2 ARRAY[99] OF RECORD           -- ���q�H���� --
           client_id           LIKE benf.client_id
          ,benf_ratio          LIKE benf.benf_ratio
          ,remit_bank          LIKE benf.remit_bank     -- ���q�H   --
          ,remit_branch        LIKE benf.remit_branch   -- �״ڤ��� --
          ,remit_account       LIKE benf.remit_account  -- ���t�v   --
          ,benf_order          LIKE benf.benf_order     -- �״ڻȦ� --
          ,names               LIKE benf.names          -- ���q�H�m�W --
                 END RECORD

    DEFINE p_data_s2_b ARRAY[99] OF RECORD
           bank_name           LIKE bank.bank_name           --�Ȧ�W��--
           END RECORD

    DEFINE p_data_s21 ARRAY[99] OF RECORD           -- ���q�H����-1 --
           mail_addr_ind       LIKE ptpc.mail_addr_ind
          ,pay_method          LIKE ptpc.pay_method
                 END RECORD
 
    DEFINE p_pscs              RECORD LIKE pscs.*       -- �q�ׯS����� --
    DEFINE p_benf    ARRAY[99] OF RECORD           -- ���q�H���� --
           client_id           LIKE benf.client_id
          ,benf_ratio          LIKE benf.benf_ratio     -- ���t��v --
          ,remit_bank          LIKE benf.remit_bank     -- �״ڻȦ� --
          ,remit_branch        LIKE benf.remit_branch   -- �״ڤ��� --
          ,remit_account       LIKE benp.bank_account_e -- �״ڱb�� --  100/03/31 MODIFY ��benf.remit_account 
          ,benf_order          LIKE benf.benf_order     -- ����     --
          ,names               LIKE benf.names          -- ���q�H   --
          ,bank_name           LIKE bank.bank_name           --�Ȧ�W��--
                 END RECORD
   
   
    
    DEFINE p_addr ARRAY[10]    OF RECORD
           addr_ind            LIKE addr.addr_ind
          ,zip_code            LIKE addr.zip_code
          ,tel_1               LIKE addr.tel_1
          ,tel_2               LIKE addr.tel_2
          ,fax                 LIKE addr.fax
          ,address             LIKE addr.address
                 END RECORD
    DEFINE p_po_chg  ARRAY[20] OF RECORD
           po_chg_rece_no   LIKE apdt.po_chg_rece_no
          ,po_chg_rece_date LIKE apdt.po_chg_rece_date 
          ,po_chg_sts_code  LIKE apdt.po_chg_sts_code   --09
                 END RECORD

    --------------------------------------------------------------------------
    -- p_sel_sw=1:�^��,2:���ƥ��^,3:��奼�^��,4:���I�ק�,5:�ӷ|��C�L
    --------------------------------------------------------------------------
    DEFINE p_sel_sw          CHAR(1)
    DEFINE p_pt_sw             CHAR(1) ----pt����
    DEFINE f_rtn               CHAR(1)
    DEFINE p_po_chg_rece_no   LIKE apdt.po_chg_rece_no
    DEFINE p_apdt_exist CHAR(1)
    DEFINE p_po_chg_cnt                   SMALLINT
    DEFINE p_relation   CHAR(1)
    DEFINE p_benf_cnt1   INT
    DEFINE p_online_prc CHAR(1)  --101/09�u�W�L�b����yirong
    DEFINE p_tel_3      LIKE addr.tel_1
    DEFINE p_psbh_cnt   INT
    
    --100/03/31 ADD                                   
    DEFINE p_benp_ext  ARRAY[99] OF RECORD 
            payee               LIKE dbdd.payee              -- ���ڤH(�^)    
           ,remit_swift_code    LIKE dbdd.remit_swift_code   -- �״ڻȦ�swift code
           ,remit_bank_name     LIKE dbdd.remit_bank_name    -- �״ڻȦ�^��W��
           ,remit_bank_address  LIKE dbdd.remit_bank_address -- �״ڻȦ�a�}  
           END RECORD 
    
    DEFINE p_data_s2_c ARRAY[99] OF RECORD
            payee               LIKE dbdd.payee              -- ���ڤH(�^)    
           ,remit_swift_code    LIKE dbdd.remit_swift_code   -- �״ڻȦ�swift code 
           ,remit_bank_name     LIKE dbdd.remit_bank_name    -- �״ڻȦ�^��W�� 
           ,remit_bank_address  LIKE dbdd.remit_bank_address -- �״ڻȦ�a�}  
           END RECORD       
    -- 100/03/31 END 
    DEFINE p_cmd     CHAR(100)
    DEFINE p_cp_pay_amt  LIKE pscr.cp_pay_amt
    DEFINE p_cp_amt      LIKE pscr.cp_amt   
    DEFINE p_upd_psck    CHAR(1)

-- �D�{�� --
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

    LET g_program_id ="psc00m"
    LET p_space      =" "
    LET p_bell       =ASCII 7
    LET p_tx_date    =GetDate(TODAY)
    LET p_tran_date  =GetDate(TODAY)
    LET p_pt_sw      ='0'

    -- ��ܲĤ@�e�� --
    OPEN FORM psc00m00 FROM "psc00m00"
    DISPLAY FORM psc00m00 ATTRIBUTE (GREEN)

    CALL ShowLogo()
    -- JOB  CONTROL beg --
    CALL JobControl()

    MENU "�п��"

        BEFORE MENU  
            IF  NOT CheckAuthority( "1", FALSE )  THEN
                HIDE OPTION "1)�^��"
            END IF
            {
            IF  NOT CheckAuthority( "2", FALSE )  THEN
                HIDE OPTION "2)���^�л��"
            END IF
            }
            IF  NOT CheckAuthority( "3", FALSE )  THEN
                HIDE OPTION "3)��奼�^�л��"
            END IF
            IF  NOT CheckAuthority( "4", FALSE )  THEN
                HIDE OPTION "4)�קﵹ�I���e"
            END IF
            IF  NOT CheckAuthority( "5", FALSE )  THEN
                HIDE OPTION "5)�ӷ|��C�L"
            END IF
            IF  NOT CheckAuthority( "6", FALSE )  THEN
                HIDE OPTION "6)���^����^�Ч@�~"
            END IF
            IF  NOT CheckAuthority( "7", FALSE )  THEN
                HIDE OPTION "7)�ӷ|�ɥ�"
            END IF
            IF  NOT CheckAuthority( "8", FALSE )  THEN
                HIDE OPTION "8)�h��"
            END IF
            IF  NOT CheckAuthority( "9", FALSE )  THEN
                HIDE OPTION "9)�h��@"
            END IF   
            IF  NOT CheckAuthority( "10", FALSE )  THEN
                HIDE OPTION "10)�h��G��
            END IF 
            IF  NOT CheckAuthority( "11", FALSE )  THEN
                HIDE OPTION "11)�ӷ|�@"
            END IF



        COMMAND "1)�^��"
            LET  p_sel_sw="1"
            CALL psc00m_init()
            CALL psc00m_sel_1()

        {
        COMMAND "2)���^�л��"
            LET  p_sel_sw="2"
            CALL psc00m_init()
            CALL psc00m_sel_2()
        }

        COMMAND "3)��奼�^�л��"
            LET  p_sel_sw="3"
            CALL psc00m_sel_3()

        COMMAND "4)�קﵹ�I���e"
            LET  p_sel_sw="4"
            CALL psc00m_sel_4()

        COMMAND "5)�ӷ|��C�L"
            LET  p_sel_sw="5"
	    CALL psc00m_init()
            CALL psc00m_sel_5()
        COMMAND "6)���^����^�Ч@�~"
            LET p_cmd = "psca02m.4ge "  
            RUN p_cmd

        COMMAND "7)�ӷ|�ɥ�"
            LET p_cmd = "ap003m.4ge "
            RUN p_cmd

        COMMAND "8)�h��"
            LET p_cmd = "ap002p.4ge "
            RUN p_cmd


        COMMAND "0)����"
            EXIT MENU
        END MENU 

    CLOSE FORM psc00m00

    OPTIONS
       INSERT KEY F1
     , DELETE KEY F2

    -- JOB  CONTROL beg --
    CALL JobControl()

END MAIN -- �D�{������ --
------------------------------------------------------------------------------
--   psc00m_init
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: �{���ܼ� initialize
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc00m_init()
    DEFINE f_rcode INTEGER
    DEFINE f_i     INTEGER
    LET f_rcode=0

    LET p_policy_no          =""
    LET p_cp_anniv_date      =""
    LET p_po_sts_code        =""
    LET p_benf_relation      =""
    LET p_act_return_date    =""
    LET p_cp_notice_code     =""
    LET p_cp_notice_dif_code =""
    LET p_dif_code_desc      =""
    LET p_cp_notice_sub_code =""
    LET p_apdt_exist         =""
    LET p_po_chg_rece_no     =""
    LET p_upd_psck           =""
    INITIALIZE p_pc961_data.* TO NULL

    FOR f_i=1 TO 20
        LET p_po_chg[f_i].po_chg_rece_no = ''
        LET p_po_chg[f_i].po_chg_rece_date  = '' 
        LET p_po_chg[f_i].po_chg_sts_code = ''
    END FOR

     
    RETURN

END FUNCTION -- psc00m_init --
------------------------------------------------------------------------------
--  �禡�W��: psc00m_sel_1
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: ��ܳB�z�٥��O��^��
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_1()
    DEFINE f_rcode           INTEGER

    DEFINE f_polf_exist      INTEGER  -- �O���ˮ� --
          ,f_pscb_exist      INTEGER  -- �٥����ˮ� --
          ,f_pscn_exist      INTEGER  -- �O�_�A���i��^�� --
          ,f_chkdate_sw      INTEGER  -- ����ˮ� --
          ,f_format_date     CHAR(9)  -- �榡�ƪ���� --
  -----------------------�ק�}�l-------------------------------------------------------
 --       ,f_cnt             INTEGER
-----------------------�קﵲ��-------------------------------------------------------
    DEFINE f_ins_pscn        CHAR(1)  --  N:���� pscn ���@
          ,f_ins_pscg        CHAR(1)  --  N:���� pscg ���@
          ,f_call_psc00m00   CHAR(1)  --  N:�i�J���
          ,f_upd_pscb        CHAR(1)
          ,f_repeat_sw	     CHAR(1)
          ,f_upd_psck        CHAR(1)  --  Y:nonresp_sw = "Y" N:nonresp_sw = " "

    DEFINE f_pscn	     RECORD LIKE pscn.*
	  ,f_cmd             CHAR(1024)

    DEFINE f_notice_print    CHAR(1)  --  Y:�C�L�ӷ|��, N:���C�L�ӷ|��
    DEFINE f_psck_cnt        SMALLINT
    DEFINE f_sw              CHAR(1)
    DEFINE f_prompt_ans      CHAR(1)  
-----------------------�ק�}�l-------------------------------------------------------
--    DEFINE f_po_chg_sts_code LIKE aplg.po_chg_sts_code
--    DEFINE f_po_chg_rece_date LIKE apdt.po_chg_rece_date 
 --   DEFINE f_po_chg_rece_no   LIKE apdt.po_chg_rece_no   
--    LET f_po_chg_sts_code = ""
-----------------------�קﵲ��-------------------------------------------------------    
    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""
    LET f_psck_cnt = 0

    MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    IF INT_FLAG=TRUE THEN
        CLOSE WINDOW w_psc00m01
        LET INT_FLAG=FALSE
        RETURN
    END IF
    
     IF INT_FLAG=TRUE THEN
        CLOSE WINDOW w_psc00m01
        LET INT_FLAG=FALSE
        RETURN
    END IF

    LET f_rcode     		=0
    LET f_polf_exist		=0
    LET f_pscb_exist		=0
    LET f_pscn_exist		=0
    LET f_chkdate_sw		=TRUE
    LET f_format_date		=""
    LET f_ins_pscg   	        ="N"
    LET f_ins_pscn	        ="N"
    LET f_upd_pscb	        ="N"
    LET f_upd_psck              ="N"
    LET f_call_psc00m00	 	="N"
    LET f_repeat_sw     	=""
    LET f_notice_print		="N"
    LET p_pt_sw                 = '0'
    LET f_prompt_ans            =" "
---------------------------�ק�}�l-----------------------------------------------
--    LET f_cnt                   = 0
    LET f_sw                = '0'
---------------------------�קﵲ��----------------------------------------------

    INITIALIZE f_pscn.*         TO NULL
    LET p_psbh_cnt = 0 

    DISPLAY p_policy_no,p_cp_anniv_date,p_po_chg_rece_no TO psc00m01.*

    INPUT p_policy_no,p_cp_anniv_date,p_po_chg_rece_no without defaults FROM
          psc00m01.* 
          --policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-���`; 1-���~
                   IF f_rtn = 1 THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF
     	  AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-���`; 1-���~
                   IF f_rtn = 1 THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

             IF p_pt_sw = '1' THEN ----���I�O��
                SELECT count(*) INTO f_pscb_exist
                FROM   ptpd
                WHERE  policy_no      = p_policy_no
                AND    payout_due     = p_cp_anniv_date
--                AND    live_certi_ind = 'Y'
                AND    opt_notice_sw  in ( '1','2')----�^�Ъ��A 1.���ݦ^�� 2.�w�g�^��
                AND    process_sw     = '0'        ----��l��   1.�w�g���I
                IF f_pscb_exist = 0 THEN
                   ERROR "���I�ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF
                IF  g_poia.po_sts_code !='53' THEN 
                    ERROR '�~���O�檬�A���šA���ݦ^��'
                   NEXT  FIELD policy_no
                END IF

                IF  p_cp_anniv_date > AddDay(p_tx_date,45) OR g_poia.po_sts_code !='53' THEN 
                   ERROR '���O����D�^�д����A���i�^��'
                   NEXT  FIELD policy_no
                END IF

             ELSE
                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7","8")

                IF f_pscb_exist =0 THEN
                   ERROR "�٥��ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF
             END IF
             IF f_sw = "0" THEN
                LET f_sw ="1"
                ERROR "�Ы�F6��ܨ��z���X!!" ATTRIBUTE(RED ,REVERSE)
                NEXT  FIELD cp_anniv_date
             END IF

             IF p_po_chg_rece_no = "" OR p_po_chg_rece_no = " " OR
                p_po_chg_rece_no IS NULL THEN
                ERROR "�ӫO�渹�X�d�L���A(2,4,A)�U�����z���X�A�Ьd��!" ATTRIBUTE(RED ,REVERSE)
                NEXT  FIELD cp_anniv_date 
             END IF

             SELECT count(*)
             INTO   f_pscn_exist
             FROM   pscn
             WHERE  policy_no	=p_policy_no
             AND    cp_anniv_date	=p_cp_anniv_date
         
             SELECT count(*)
             INTO   p_psbh_cnt
             FROM   psbh
             WHERE  policy_no     = p_policy_no
             AND    cp_anniv_date = p_cp_anniv_date
             AND    cp_rtn_sts in ('0','1')
-------------------------�ק�u�}�l(���z���X)-------------------------------------------------
	     ON KEY (F6) 
		IF INFIELD(cp_anniv_date) THEN 
		   CALL rece_no_show()
	           DISPLAY p_po_chg_rece_no TO po_chg_rece_no ATTRIBUTE( BLUE, REVERSE, UNDERLINE )
 	        END IF
                
                
-------------------------�ק�u����(���z���X)------------------------------------------------- 
    END INPUT

    IF INT_FLAG THEN
       ERROR "�^�Ч@�~��� !!"
       LET INT_FLAG = FALSE
------------------------------------------------------------------------------------------
			 CLOSE WINDOW w_psc00m01
---------------------------------------------------------------------------------------------
       RETURN
    END IF

  IF  p_pt_sw = '1' THEN
    IF  g_poia.po_sts_code = '53' THEN
        LET f_polf_exist = 0
    ELSE
        LET f_polf_exist = 1
    END IF
  ELSE
    SELECT COUNT(*)
    INTO   f_polf_exist
    FROM   polf
    WHERE  policy_no = p_policy_no
    AND    po_sts_code NOT IN ("42", "43", "44", "46", "47", "48", "50")
  END IF
    LET f_repeat_sw = " "
    IF f_polf_exist > 0 THEN
--       PROMPT "�Ъ`�N�A���O��D�����Ī��A�A�T�{�Ы�(Y/y)" FOR CHAR f_repeat_sw
       PROMPT "�O��D���Ī��A�T�{�Ы�(Y/y)" FOR CHAR f_repeat_sw
       IF UPSHIFT(f_repeat_sw) !="Y"
       OR f_repeat_sw IS NULL        THEN
	  CLOSE WINDOW w_psc00m01
	  RETURN
       END IF
    END IF
    SELECT count(*)
      INTO f_psck_cnt
      FROM psck
     WHERE policy_no = p_policy_no
       AND nonresp_sw = 'Y'
    IF f_psck_cnt > 0 THEN
       ERROR "�|�����^������O�������A�нT�{ !!"
    END IF

    LET f_repeat_sw = " "
    IF f_pscn_exist > 0 THEN

       LET f_cmd ="SELECT FIRST 1 * FROM pscn "
                 ," WHERE policy_no= ? "
                 ," AND   cp_anniv_date= ? "
                 ," ORDER BY process_date DESC ,process_time DESC "

       PREPARE pscn_pre FROM f_cmd
       DECLARE pscn_ptr CURSOR FOR pscn_pre
       FOREACH pscn_ptr USING p_policy_no, p_cp_anniv_date
			INTO  f_pscn.*
       END FOREACH

       IF  f_pscn.cp_notice_code = "1" 
       AND f_pscn.cp_notice_sub_code MATCHES "[12]" THEN
       ELSE
           IF p_psbh_cnt = 0 THEN
              PROMPT "  �T�w�A���i��^�нЫ�(Y/y)" FOR CHAR f_repeat_sw
              IF UPSHIFT(f_repeat_sw) !="Y" OR
                 f_repeat_sw IS NULL        THEN
                 CLOSE WINDOW w_psc00m01
                 RETURN
              END IF
           ELSE
              PROMPT "�����O�欰�^�y��,�A���^��(Y/y)" FOR CHAR f_repeat_sw
              IF UPSHIFT(f_repeat_sw) !="Y" OR
                 f_repeat_sw IS NULL        THEN
                 CLOSE WINDOW w_psc00m01
                 RETURN
              END IF
           END IF         
       END IF
    END IF

    CLOSE WINDOW w_psc00m01

    CALL psc00m02_screen() RETURNING f_rcode
    ----------------------------------------------
    -- f_rcode
    -- =1 :INT_FLAG=TRUE ���}                   --
    -- !=1:psc00m02 �s��                        --
    ----------------------------------------------

    -- ��J��Ƥ��s,���} --
    IF f_rcode !=0 THEN
       ERROR "�^�Ф��s�� !!"
       RETURN
    END IF

    -- ������,�i�J��� --
    IF p_cp_notice_code="0" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
       LET f_upd_psck="N"
       LET f_notice_print="N"
    END IF

    -- ���^�Х�,�i�J��� --
    IF p_cp_notice_code="2" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
--       IF f_psck_cnt > 0 THEN
       LET f_upd_psck="Y"
--       END IF 
       LET f_notice_print="N"
    END IF

    -- �ӷ|�^��,�i�J��� --
    IF p_cp_notice_code="3" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
       LET f_upd_psck="N"
       LET f_notice_print="N"
    END IF

    IF p_cp_notice_code="1" THEN
       LET f_ins_pscg="Y"
       LET f_upd_psck="N"
       -- �ĳq�� --
       IF p_cp_notice_sub_code ="0" THEN
          LET f_ins_pscn="Y"
          LET f_call_psc00m00="Y"
          LET f_upd_pscb="N"
	  LET f_notice_print="N"
       ELSE
	  IF p_cp_notice_sub_code ="1" THEN
	     LET f_ins_pscn="Y"
             LET f_call_psc00m00="N"
             LET f_upd_pscb="Y"
	     LET f_notice_print="Y"
	  ELSE
	     LET f_ins_pscn="Y"
	     LET f_call_psc00m00="N"
	     LET f_upd_pscb="Y"
	     LET f_notice_print="Y"
	  END IF
       END IF
    END IF
    LET p_upd_psck = f_upd_psck
    IF f_call_psc00m00="Y" THEN
       CALL psc00m00_input() RETURNING f_rcode
       -- ����^�Ъ���Ƥ��s,���} --
       IF f_rcode =1 THEN
          ERROR "�^�и��,�����Ʃ��@�~ !!"
          LET f_rcode=0
          RETURN
       END IF
    END  IF

    IF f_ins_pscn="Y" THEN
       CALL psc00m_insert_pscn(f_upd_pscb,f_ins_pscg)
            RETURNING f_rcode
       IF f_rcode !=0 THEN
          ERROR "�^�и�Ʒs�W���~,���p����T�� !!"
          RETURN
       END IF
    END IF

    IF f_notice_print="Y" THEN

       -- ��ܷӷ|�~�ȭ��ΫO��~�ݦC�L --
       IF p_cp_notice_sub_code = "1"
       OR p_cp_notice_sub_code = "2" THEN
	  CALL notice_print() RETURNING f_rcode

	  IF f_rcode != 0 THEN
	     ERROR "�C�L�ӷ|����~,���p����T�� !!"
	     RETURN
	  END IF
       END IF
    END IF

    RETURN

END FUNCTION -- psc00m_sel_1 --
-------------------------------------------------------------------
FUNCTION psc00m02_screen()
    DEFINE f_rcode          INTEGER
          ,f_ans_sw         CHAR(1)

    LET  p_act_return_date=p_tran_date
    LET  p_cp_notice_code =""
    LET  f_rcode=0

    OPEN WINDOW w_psc00m02 AT 10,41 WITH FORM "psc00m02"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    WHILE 1=1

        LET f_rcode         =0
        LET INT_FLAG        =FALSE
        LET p_cp_notice_code=""

        DISPLAY p_policy_no,p_cp_anniv_date,p_tran_date
        TO      policy_no  ,cp_anniv_date  ,act_return_date

        INPUT p_cp_notice_code WITHOUT DEFAULTS
              FROM  cp_notice_code
              ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

              AFTER FIELD cp_notice_code
                    IF LENGTH(p_cp_notice_code CLIPPED)=0 THEN
                       ERROR "�^�гB�z�X������J !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    IF p_cp_notice_code NOT MATCHES "[0-3]" THEN
                       ERROR "�^�гB�z�X��J���~ !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    -- ��󤣻���,�i�J�ӷ|�οĳq�B�z --
                    IF p_cp_notice_code="1" THEN
                       CALL psc00m03_screen()
                    END IF

              AFTER INPUT

                    IF INT_FLAG=TRUE THEN
                       EXIT INPUT
                    END IF
                    IF LENGTH(p_cp_notice_code CLIPPED)=0 THEN
                       ERROR "�^�гB�z�X������J !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    IF p_cp_notice_code NOT MATCHES "[0-3]" THEN
                       ERROR "�^�гB�z�X��J���~ !!"
                       NEXT FIELD cp_notice_code
                    END IF

                    IF p_cp_notice_code MATCHES "[2]" AND p_pt_sw= '1' THEN
                       ERROR "�^�гB�z�X��J���~�A���I�^�Ф��i�ϥ� !!"
                       NEXT FIELD cp_notice_code
                    END IF

                    IF p_cp_notice_code="1" THEN
                      IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                         ERROR "�^�гB�z,��󤣻�,�L�B�z�覡 !!"
                         NEXT FIELD cp_notice_code
                      END IF

                      IF p_notice_desc_len=0 THEN
                         ERROR "�^�гB�z,��󤣻�,�L�ʽX !!"
                         NEXT FIELD cp_notice_code
                      END IF
                    END IF

                    LET f_ans_sw=""
                    PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
                    IF UPSHIFT(f_ans_sw) !="Y" OR
                       f_ans_sw IS NULL        THEN
                       NEXT FIELD cp_notice_code
                    END IF

        END INPUT

        IF INT_FLAG=TRUE THEN
           LET INT_FLAG=FALSE
           LET f_rcode=1
        ENd IF

        EXIT WHILE
    END WHILE

    CLOSE WINDOW w_psc00m02
    LET INT_FLAG=FALSE
    RETURN f_rcode

END FUNCTION -- psc00m02_screen --

FUNCTION psc00m03_screen()
    DEFINE f_rcode  CHAR(1)
          ,f_ans_sw CHAR(1)
    DEFINE f_psc00m03_rcode CHAR(1)

    OPEN WINDOW w_psc00m03 AT  10,11 WITH FORM "psc00m03"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )
--    MESSAGE "ESC:�s�� F1:�ӷ|�ɥ� F2:�h��"

    WHILE 1=1

        LET f_rcode             ="0"
        LET INT_FLAG            =FALSE
        LET f_psc00m03_rcode    ="0"
        LET p_cp_notice_sub_code=""

        DISPLAY p_policy_no,p_cp_anniv_date,p_act_return_date
               ,p_cp_notice_code
               ,p_cp_notice_sub_code
        TO      policy_no,cp_anniv_date,act_return_date
               ,cp_notice_code
               ,cp_notice_sub_code

        INPUT p_cp_notice_sub_code
              WITHOUT DEFAULTS FROM cp_notice_sub_code
              ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

              AFTER FIELD cp_notice_sub_code
                    IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                       ERROR "�B�z�覡������J   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    IF p_cp_notice_sub_code NOT MATCHES "[0-2]" THEN
                       ERROR "�B�z�覡��J���~   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    -- ���ʽX�B�z pscg insert --
                    -- f_rcode=0 �T�w�s��       --
                    -- f_rcoed=1 �s�ɿ��~       --
                    -- f_rcode=2 ���s��       --
                    CALL psc00m08_screen() RETURNING
                         f_rcode
               --   CALL psc00m_dsp_dif_code() RETURNING
               --        f_rcode,p_cp_notice_dif_code
               --       ,p_dif_code_desc

                    IF  f_rcode=1 THEN
                        ERROR " �N�X�ɤ�ʸ�� !!"
                        ATTRIBUTE (RED)
                        LET f_rcode=0
                        NEXT FIELD cp_notice_sub_code
                    END IF

                    IF  f_rcode=2  THEN
                        ERROR " ���ʽX�@�~ !!" ATTRIBUTE (RED)
                        LET f_rcode=0
                        NEXT FIELD cp_notice_sub_code
                    END IF

              AFTER INPUT
                    IF INT_FLAG=TRUE THEN
                       EXIT INPUT
                    END IF

                    IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                       ERROR "�B�z�覡������J   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    IF p_cp_notice_sub_code NOT MATCHES "[0-2]" THEN
                       ERROR "�B�z�覡��J���~   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF

                    IF p_notice_desc_len =0 THEN
                       ERROR "���ʵL�@�~,�Э��s��J!!" ATTRIBUTE (RED)
                       LET f_rcode=0
                       NEXT FIELD cp_notice_sub_code
                    END IF

                    LET f_ans_sw=""
--                    MESSAGE "" 
                    PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
                    IF UPSHIFT(f_ans_sw) !="Y" OR
                       f_ans_sw IS NULL        THEN
--                       MESSAGE "F1:�ӷ|�ɥ� F2:�h��" 
                       NEXT FIELD cp_notice_sub_code
                    END IF

        END INPUT

        IF INT_FLAG=TRUE THEN
           LET p_cp_notice_sub_code=""
           EXIT WHILE
        END IF

        EXIT WHILE
    END WHILE

    CLOSE WINDOW w_psc00m03
    LET INT_FLAG=FALSE
    RETURN

END FUNCTION -- psc00m03_screen --

-- ���ʪ����e --
FUNCTION psc00m08_screen()
    DEFINE f_rcode    CHAR(1)
          ,f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
          ,f_arr_cur  INTEGER
          ,f_scr_cur  INTEGER
    DEFINE f_ans_sw   CHAR(1)
          ,f_dif_code_desc CHAR(30)
    DEFINE f_cmd 	CHAR(100)
    OPEN WINDOW w_psc00m08 AT  6,6 WITH FORM "psc00m08"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )
    MESSAGE "  F6:��ܯʽX����"

    FOR f_i=1 TO 7
        LET p_pscg[f_i].input_desc=""
    END FOR

    LET f_rcode=0
    LET f_ans_sw=""
    LET p_notice_desc_len=0
    LET p_notice_desc=""

    CALL SET_COUNT(7)
    INPUT ARRAY p_pscg WITHOUT DEFAULTS
    FROM  psc00m08.*
    BEFORE ROW
           LET f_arr_cur = ARR_CURR()
           LET f_scr_cur = SCR_LINE()

    ON KEY (F6)
       CALL psc00m_dsp_dif_code() RETURNING
            f_rcode,f_dif_code_desc
       LET p_pscg[f_arr_cur].input_desc=f_dif_code_desc
       DISPLAY p_pscg[f_arr_cur].input_desc TO
               psc00m08[f_scr_cur].desc
       LET p_notice_desc =p_notice_desc CLIPPED
                         ,p_pscg[f_arr_cur].input_desc
 

    AFTER INPUT
       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET p_notice_desc_len=LENGTH(p_notice_desc CLIPPED)

       LET f_ans_sw=""
       PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD desc
       END IF
    END INPUT
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       LET p_notice_desc_len=0
       LET p_notice_desc=""
       CLOSE WINDOW w_psc00m08
       RETURN f_rcode
    END IF
    LET p_notice_desc_1=p_pscg[1].input_desc
    LET p_notice_desc_2=p_pscg[2].input_desc
    LET p_notice_desc_3=p_pscg[3].input_desc
    LET p_notice_desc_4=p_pscg[4].input_desc
    LET p_notice_desc_5=p_pscg[5].input_desc
    LET p_notice_desc_6=p_pscg[6].input_desc
    LET p_notice_desc_7=p_pscg[7].input_desc
    LET p_notice_desc_len = length(p_notice_desc_1)
    CLOSE WINDOW w_psc00m08

    RETURN f_rcode
END FUNCTION -- psc00m08_screen --

FUNCTION psc00m_dsp_dif_code()
    DEFINE f_rcode    CHAR(1)
    DEFINE f_pscf  RECORD LIKE pscf.*
    DEFINE f_pscf_cnt INTEGER
          ,f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
    DEFINE f_cp_notice_dif_code LIKE pscf.cp_notice_dif_code
          ,f_dif_code_desc      LIKE pscf.cp_dif_code_desc


    LET f_i=0
    LET f_cp_notice_dif_code=""
    LET f_dif_code_desc     =""

    FOR f_i=1 TO 99
        LET p_dif[f_i].cp_notice_dif_code=""
        LET p_dif[f_i].dif_code_desc     =""
    END FOR

    LET f_i=0
    DECLARE pscf_crs CURSOR FOR
            SELECT *
            FROM   pscf
    FOREACH pscf_crs  INTO f_pscf.*
        LET f_i=f_i+1
        LET p_dif[f_i].cp_notice_dif_code=f_pscf.cp_notice_dif_code
        LET p_dif[f_i].dif_code_desc     =f_pscf.cp_dif_code_desc
    END FOREACH

    IF f_i=0 THEN
       LET f_rcode=1
       LET f_cp_notice_dif_code=""
       LET f_dif_code_desc  =""
       RETURN f_rcode,f_dif_code_desc
    END IF

    LET f_x=8
    LET f_y=31

    OPEN WINDOW w_psc00m04 AT f_x, f_y WITH FORM "psc00m04"
         ATTRIBUTE( BLUE, REVERSE, UNDERLINE )

    CALL SET_COUNT(f_i)
    LET f_cp_notice_dif_code=""
    LET f_dif_code_desc=""
    LET INT_FLAG=FALSE

    DISPLAY ARRAY p_dif TO psc00m04.* ATTRIBUTE (BLUE ,REVERSE)


    IF (INT_FLAG = FALSE) THEN
        LET f_i    = ARR_CURR()
        LET f_cp_notice_dif_code=p_dif[f_i].cp_notice_dif_code
        LET f_dif_code_desc     =p_dif[f_i].dif_code_desc
    ELSE
        LET f_rcode=2
        LET INT_FLAG = FALSE
    END IF

    CLOSE WINDOW w_psc00m04

    RETURN f_rcode,f_dif_code_desc
END FUNCTION -- psc00m_dsp_diff_code --

FUNCTION psc00m_insert_pscn(f_upd_pscb,f_ins_pscg)
    DEFINE f_upd_pscb CHAR(1)     -- �O�_��s pscb --
          ,f_ins_pscg CHAR(1)     -- �O�_ insert pscg --
    DEFINE f_rcode INTEGER
          ,f_process_date CHAR(9)
          ,f_process_time CHAR(8)
          ,f_notice_serial INTEGER
          ,f_pscn_notice_serial INTEGER
          ,f_dummy_flag         CHAR(2)

    LET f_notice_serial=0
    LET f_rcode=0
    LET f_process_date=GetDate(TODAY)
    LET f_process_time=TIME

    WHENEVER ERROR CONTINUE


    BEGIN WORK

    LET f_pscn_notice_serial=null

    SELECT max(cp_notice_serial)
    INTO   f_pscn_notice_serial
    FROM   pscn
    WHERE  policy_no=p_policy_no
    AND    cp_anniv_date=p_cp_anniv_date

    IF f_pscn_notice_serial IS NULL THEN
       LET f_pscn_notice_serial=0
    END IF

    LET  f_notice_serial=f_pscn_notice_serial+1

    IF f_ins_pscg="N" THEN
       LET f_dummy_flag="OK" 
    ELSE
       {
       SELECT max(cp_notice_serial)
       INTO   f_pscg_notice_serial
       FROM   pscg
       WHERE  policy_no=p_policy_no
       AND    cp_anniv_date=p_cp_anniv_date

       IF f_pscg_notice_serial IS NULL THEN
          LET f_pscg_notice_serial=0
       END IF

       LET  f_notice_serial=f_pscg_notice_serial+1
       }

       INSERT INTO pscg
       VALUES (p_policy_no
              ,p_cp_anniv_date
              ,f_notice_serial
              ,p_notice_desc_1
              ,p_notice_desc_2
              ,p_notice_desc_3
              ,p_notice_desc_4
              ,p_notice_desc_5
              ,p_notice_desc_6
              ,p_notice_desc_7
              ,f_process_date
              ,f_process_time
              ,g_user
              )
       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
    END IF


    INSERT INTO pscn
    VALUES (p_policy_no
           ,p_cp_anniv_date
           ,p_act_return_date
           ,p_cp_notice_code
           ,p_cp_notice_sub_code
           ,f_notice_serial
           ,f_process_date
           ,f_process_time
           ,g_user
           )

    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    ELSE
       IF f_upd_pscb="Y" THEN
         IF p_pt_sw = '1' THEN     ----���I�O��
            ----���ݧ�s cp_notice_sw
         ELSE
          UPDATE pscb
          SET    cp_notice_sw="1"
                ,change_date =f_process_date
                ,process_date=f_process_date
                ,process_user=g_user
          WHERE  policy_no=p_policy_no
          AND    cp_anniv_date=p_cp_anniv_date
          IF SQLCA.SQLCODE != 0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END  IF
         END IF

          -- �ӷ|���� --
          INSERT INTO psci
          VALUES (p_policy_no
                 ,p_cp_anniv_date
                 ,"1"
                 ,g_user
                 ,f_process_date
                 )
          IF SQLCA.SQLCODE !=0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END IF

       END IF
    END IF

    COMMIT WORK
    RETURN f_rcode
END FUNCTION -- psc00m_insert_pscn --


FUNCTION psc00m00_input()
    DEFINE f_rcode          INTEGER
    DEFINE f_psc00m00_rcode CHAR(1)

    LET f_rcode=0

    CALL psc01m_init()

    IF  p_pt_sw = '1' THEN
    CALL psc01m_query_pt() RETURNING f_rcode
    ELSE
    CALL psc01m_query() RETURNING f_rcode
    END IF

    RETURN f_rcode
END FUNCTION --psc00m00_input --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_init
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��q���^��,�e�����
--  ���n�禡:
------------------------------------------------------------------------------

FUNCTION psc01m_init()
    DEFINE f_i SMALLINT -- array index ---

    INITIALIZE p_pc961_data.* TO NULL

    LET   p_applicant_id  =" "
    LET   p_applicant_name=" "
    LET   p_tel_1         =" "
    LET   p_tel_2         =" "
    LET   p_old_cp_disb_type=" "
    LET   p_coverage_no  =1

    -- �e���@��� --
    LET   p_data_s1.policy_no              =" "       -- �O�渹�X --
    LET   p_data_s1.po_sts_code            =" "       -- �O�檬�A --
    LET   p_data_s1.cp_anniv_date          =" "       -- �٥��g�~�� --
    LET   p_data_s1.cp_disb_type           =" "       -- �I�ڤ覡 --
    LET   p_data_s1.mail_addr_ind          =" "       -- �l�H���� --
    LET   p_data_s1.disb_special_ind       =" "       -- �q�׫��� --
    LET   p_data_s1.cp_rtn_sw		   =" "	      -- �ٴګ��� --
    LET   p_data_s1.cp_pay_name            =" "       -- ����m�W --
    LET   p_data_s1.cp_pay_id              =" "       -- ����id   --
    LET   p_data_s1.dept_name		   =" "       -- ����a�I --
    LET   p_data_s1.po_chg_rece_no         =" "       -- ���z���X  97.07 yirong
--    LET   p_data_s1.dept_code              =" "       -- ����a�I --
    -- �ɵe���@��������� --
    LET   p_dept_code			   =" "	      -- ����a�I --


    -- �e���T��� --
    LET   p_data_s3.psck_sw                =" "       -- �٥����O --
    LET   p_data_s3.overloan_desc	   =" "	      -- OVERLOAN ���� --
    LET   p_data_s3.notice_resp_desc	   =" "	      -- �^�Ы��� --
    LET   p_data_s3.app_name               =" "       -- �n�O�H   --
    LET   p_data_s3.app_id		   =" "	      -- �n�O�Hid --
    LET   p_data_s3.insured_name           =" "       -- �Q�O�H   --
    LET   p_data_s3.insured_id		   =" "	      -- �Q�O�Hid --

    -- �ɵe���T��������� --
    LET   p_agent_code			   =" "       -- �~�ȭ�   --
    LET   p_dept_code_1			   =" "       -- ��~��� --

    -- �e���G detail ��� --
    FOR f_i=1 TO 99
       LET   p_data_s2[f_i].client_id      =" "      -- ���q�HID  --
       LET   p_data_s2[f_i].benf_ratio     = 0       -- ���q���  --
       LET   p_data_s2[f_i].remit_bank     =" "      -- �״ڻȦ�  --
       LET   p_data_s2[f_i].remit_branch   =" "      -- �״ڻȦ�  --
       LET   p_data_s2[f_i].remit_account  =" "      -- �״ڱb�b  --
       LET   p_data_s2[f_i].benf_order     =" "      -- ���q����  --
       LET   p_data_s2[f_i].names          =" "      -- �m�W/�W�� --
    END FOR
    FOR f_i=1 TO 99
       LET   p_data_s2_b[f_i].bank_name     =" "
    END FOR
    
    -- 100/03/31 ADD
    FOR f_i=1 TO 99
       LET   p_data_s2_c[f_i].payee               =" "                      
       LET   p_data_s2_c[f_i].remit_swift_code    =" " 
       LET   p_data_s2_c[f_i].remit_bank_name     =" "
       LET   p_data_s2_c[f_i].remit_bank_address  =" "  
    END FOR
    -- 100/03/31 END
    
    CLEAR FORM
    RETURN
END FUNCTION   -- psc01m_init --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_query
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��d�ߧ@�~,�d�ߵe��
--  ���n�禡:
------------------------------------------------------------------------------

FUNCTION psc01m_query()
    
    DEFINE f_rcode              INTEGER
          ,f_dummy_flag         CHAR(2)
          ,f_ans_sw             CHAR(1)   -- prompt ���^�� --
          ,f_ans_sw1            CHAR(1)   -- yirong 101/09
          ,f_expired_sw         CHAR(1)
          ,f_psck_sw            CHAR(1)
          ,f_psck_cnt           INTEGER
          ,f_pscninq_sw         INTEGER

    DEFINE f_po                 CHAR(255) -- ���o po ��T�� prepare --
    DEFINE f_addr_cmd           CHAR(255) -- ����a�}���ק�s�W�@�~ --
    DEFINE f_bank_cmd		CHAR(255) -- ����Ȧ��ƺ��@�@�~ --
    DEFINE f_i                  INTEGER   -- array �p�ƾ� --
          ,f_j                  INTEGER   -- array �p�ƾ� -
          ,f_benf_cnt           INTEGER   -- ���q�H�p�ƾ� --
          ,f_arr_cur            INTEGER   -- ���q�H��J���p�� --
          ,f_scr_cur            INTEGER   -- ���q�H�e�����p�� --
          ,f_disb_err           INTEGER   -- ���q�H�Ȧ�b������ --
          ,f_chk_remit_err      INTEGER 
          ,f_chk_remit_msg      CHAR(255)

    DEFINE f_pscb_cnt           INTEGER   -- ���� perpare ���O���O��i���� --
          ,f_polf_cnt           INTEGER   -- polf �O�_�s�b input �O�� --
          ,f_right_or_fault     INTEGER   -- ����ˬd t or f --
          ,f_formated_date      CHAR(9)   -- ����榡�� 999/99/99 --
          ,f_benf_relation      CHAR(1)   -- ����/�ͦs ���q�H --
          ,f_serivce_agt_name   CHAR(40)  -- �A�ȷ~�ȭ�_name --
          ,f_agt_deptbelong     CHAR(6)   -- agent ���ݤ����q --

    DEFINE f_cp_anniv_date      LIKE    pscb.cp_anniv_date
          ,f_cp_sw              LIKE    pscb.cp_sw
          ,f_cp_disb_type       LIKE    pscb.cp_disb_type
          ,f_mail_addr_ind      LIKE    pscb.mail_addr_ind
          ,f_disb_special_ind   LIKE    pscb.disb_special_ind
          ,f_pay_ind            CHAR(1)
          ,f_cp_pay_name        CHAR(12)
          ,f_cp_pay_id          LIKE    pscb.cp_pay_id
          ,f_cp_dept_code       LIKE    pscb.dept_code

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype
          ,f_chk_sw             LIKE pscr.cp_chk_sw
          ,f_chk_date           LIKE pscr.cp_chk_date

    DEFINE f_arr                INTEGER
          ,f_dtl_cp_ann         LIKE    pscb.cp_anniv_date

    DEFINE f_client_ident       LIKE    colf.client_ident
          ,f_applicant_id       LIKE    clnt.client_id
          ,f_insured_id         LIKE    clnt.client_id
          ,f_addr_id            LIKE    clnt.client_id
          ,f_addr_ind           LIKE    addr.addr_ind
          ,f_zip_code           LIKE    addr.zip_code
          ,f_address            LIKE    addr.address
          ,f_app_name           LIKE    clnt.names
          ,f_insured_name       LIKE    clnt.names
--          ,f_disb_ind           CHAR(1)
          ,f_ask_error          CHAR(100)
          , f_po_chg_sts_code   CHAR(1)
    DEFINE f_rece               SMALLINT
    -- 100/03/31 ADD
    DEFINE f_hotkey_msg         CHAR(100)     
    DEFINE f_cmd_1              CHAR(1000)  
    DEFINE f_client_id          LIKE benf.client_id 
    DEFINE f_swift_code         LIKE benp.swift_code     
    DEFINE f_bank_account_e     LIKE benp.bank_account_e 
    DEFINE f_psc4_cnt           SMALLINT
    -- 100/03/31 END      
    MESSAGE " END:����"

    LET INT_FLAG      =FALSE
    LET f_client_ident=" "
    LET f_applicant_id=" "
    LET f_app_name    =" "
    LET f_insured_id  =" "
    LET f_insured_name=" "
    LET f_addr_id     =" "
    LET f_addr_ind    ="0"
    LET f_zip_code    =" "
    LET f_address     =" "
    LET f_chk_date    =" "
    LET f_chk_sw      =" "
    LET f_psck_sw     =" "

    LET f_psck_cnt    =0
    LET f_pscb_cnt    =0
    LET f_polf_cnt    =0
    LET f_benf_cnt    =0
    LET f_psc4_cnt = 0
    LET p_data_s1.policy_no=p_policy_no
    LET p_data_s1.cp_anniv_date=p_cp_anniv_date
    -- ����ˬd --

    -- g_polf.����� --
    SELECT *
    INTO   g_polf.*
    FROM   polf
    WHERE  policy_no=p_data_s1.policy_no
    IF SQLCA.SQLERRD[3]=0 THEN
       ERROR "�L���i�O��!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- 100/03/31 ADD �~���n�������t�~�@��FORM,������ܤ]���P
    IF g_polf.currency = 'TWD' THEN
    	 LET f_hotkey_msg = "END:���,F2:���z�d��,F5:�l�H����,F6:���`�q��,F8:���w�q��,F9:���O,F7:�Ȧ��ƺ��@"
       OPEN FORM psc00m00 FROM "psc00m00"              -- 101/02/20 ADD �^�Юɤ����~��/�x���O��A�ݥ����s�}��FORM 
       DISPLAY FORM psc00m00 ATTRIBUTE (GREEN)
       CALL ShowLogo()
    ELSE
    	 LET f_hotkey_msg = "END:���,F2:���z�d��,F6:���`�q��,F8:���w�q��,F9:���O,F7:�Ȧ�Swift code���@"  
    	 OPEN FORM psc00m11 FROM "psc00m11"
       DISPLAY FORM psc00m11 ATTRIBUTE (GREEN)
       CALL ShowLogo()
    END IF
    -- 100/03/31 ADD
    
    -- ���� or �ͦs --
    IF g_polf.expired_date <= p_data_s1.cp_anniv_date THEN
       LET f_expired_sw="Y"
    ELSE
       LET f_expired_sw="N"
    END IF

    SELECT count(*) INTO f_pscb_cnt
    FROM   pscb
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    AND    cp_sw  in ("1","3","4","7","8")

    IF f_pscb_cnt is null OR
       f_pscb_cnt =0      THEN
       ERROR "���i�O��L�٥����!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- �٥����O --
    SELECT count(*) INTO f_psck_cnt
    FROM   psck
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    IF f_psck_cnt=0 THEN
       LET f_psck_sw="N"
    ELSE
       LET f_psck_sw="Y"
    END IF


    LET f_pscb_cnt=0
    LET f_polf_cnt=0
    LET f_benf_cnt=0
    LET p_benf_cnt=0

    SELECT * INTO p_pscb.*
    FROM   pscb
    WHERE  policy_no    =p_policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    LET f_cp_sw             =p_pscb.cp_sw
    LET f_cp_disb_type      =p_pscb.cp_disb_type
    LET f_mail_addr_ind     =p_pscb.mail_addr_ind
    LET f_disb_special_ind  =p_pscb.disb_special_ind
    LET f_cp_pay_name       =p_pscb.cp_pay_name
    LET f_cp_pay_id         =p_pscb.cp_pay_id
    LET f_cp_dept_code      =p_pscb.dept_code

    -- �e���@���ĤT����� --
        LET  p_data_s3.psck_sw        =f_psck_sw

	IF p_pscb.overloan_sw = "1" THEN
	   LET p_data_s3.overloan_desc = "Y"
	ELSE
	   IF p_pscb.overloan_sw = "0" THEN
	      LET p_data_s3.overloan_desc = "N"
	   END IF
	END IF

	IF p_pscb.notice_resp_sw = "1" THEN
	   LET p_data_s3.notice_resp_desc = "Y"
	ELSE
	   IF p_pscb.notice_resp_sw = "0" THEN
	      LET p_data_s3.notice_resp_desc = "N"
	   END IF
	END IF

        -- �~�ȭ�,�P��~��� --
        SELECT agent_code
        INTO   p_agent_code
        FROM   poag
        WHERE  policy_no=p_data_s1.policy_no
        AND    relation ="S"

        SELECT dept_code
        INTO   p_dept_code_1
        FROM   agnt
        WHERE  agent_code=p_agent_code

        SELECT names INTO f_serivce_agt_name
        FROM   clnt
        WHERE  client_id=p_agent_code

        SELECT dept_belong INTO f_agt_deptbelong
        FROM   dept
        WHERE  dept_code=p_dept_code_1
{
        IF f_agt_deptbelong ="99000" OR 
           f_agt_deptbelong ="98000" THEN
           LET f_agt_deptbelong="97000"
        END IF
}
        IF f_agt_deptbelong ="99000"  THEN
           LET f_agt_deptbelong="97000"
        END IF

        -- �n�O�HID,�m�W --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

        SELECT cp_chk_sw,cp_chk_date,coverage_no,cp_amt
        INTO   f_chk_sw,f_chk_date,p_coverage_no,p_cp_amt
        FROM   pscr
        WHERE  policy_no=p_data_s1.policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date

        -- �Q�O�HID,�m�W --
        SELECT client_ident
        INTO   f_client_ident
        FROM   colf
        WHERE  policy_no=p_data_s1.policy_no
        AND    coverage_no=p_coverage_no

        SELECT client_id
        INTO   f_insured_id
        FROM   pocl
        WHERE  policy_no=p_data_s1.policy_no
        AND    client_ident=f_client_ident

        SELECT names
        INTO   f_insured_name
        FROM   clnt
        WHERE  client_id=f_insured_id

        LET p_data_s3.app_name    =p_applicant_name[1,12] CLIPPED
        LET p_data_s3.app_id	  =p_applicant_id
        LET p_data_s3.insured_name=f_insured_name[1,12]   CLIPPED
        LET p_data_s3.insured_id  =f_insured_id

    -- �e���@���ĤG�����,���q�H��� --
       IF g_polf.expired_date >  p_data_s1.cp_anniv_date THEN
          LET p_benf_relation="L"    --�ͦs���q�H
       ELSE
          LET p_benf_relation="M"    --�������q�H
       END IF
 
       SELECT count(*)
       INTO   f_benf_cnt
       FROM   benf
       WHERE  policy_no=p_data_s1.policy_no
       AND    relation =p_benf_relation

       IF f_benf_cnt !=0 THEN
          -- 100/03/31 MODIFY �ھڹ��O�줣�P���q�H�״ڸ��
{
          DECLARE benf_cur CURSOR FOR
                     SELECT benf.client_id
                           ,benf.benf_ratio
                           ,benf.remit_bank
                           ,benf.remit_branch
                           ,benf.remit_account
                           ,benf.benf_order
                           ,benf.names
                           ,bank.bank_name
                     FROM  benf , outer bank
                     WHERE benf.policy_no  =p_data_s1.policy_no
                     AND   benf.relation   =p_benf_relation
                     AND   bank.bank_code[1,3] = benf.remit_bank
                     AND   bank.bank_code[4,7] = benf.remit_branch
}                    
          LET f_cmd_1= ''
          IF g_polf.currency = 'TWD' THEN 
          	 LET f_cmd_1 = " SELECT benf.client_id                           ",          
                           "       ,benf.benf_ratio                          ",    
                           "       ,benf.remit_bank                          ",    
                           "       ,benf.remit_branch                        ",    
                           "       ,benf.remit_account                       ",    
                           "       ,benf.benf_order                          ",    
                           "       ,benf.names                               ",    
                           "       ,bank.bank_name                           ",
                           "       ,''                                       ",   -- payee_e �~���ϥ�
                           "       ,''                                       ",   -- swift_code �~���ϥ�
                           "       ,''                                       ",   -- bank_name_e �~���ϥ� 
                           "       ,''                                       ",   -- bank_address_e�~���ϥ� 
                           " FROM  benf , outer bank                         ",    
                           " WHERE benf.policy_no  ='",p_data_s1.policy_no,"'",    
                           " AND   benf.relation   ='",p_benf_relation,"'    ",    
                           " AND   bank.bank_code[1,3] = benf.remit_bank     ",    
                           " AND   bank.bank_code[4,7] = benf.remit_branch   "   
          ELSE 
          	  LET f_cmd_1 = " SELECT benf.client_id                          ",                                 
          	               "       ,benf.benf_ratio                          ",                                 
                           "       ,benp.bank_code[1,3]                      ",
                           "       ,benp.bank_code[4,7]                      ",   
                           "       ,benp.bank_account_e                      ",                                 
                           "       ,benf.benf_order                          ",                                 
                           "       ,benf.names                               ",                                 
                           "       ,''                                       ", -- bank_name ����W��
                           "       ,benp.payee_e                             ",
                           "       ,benp.swift_code                          ",
                           "       ,benp.bank_name_e                         ",
                           "       ,benp.bank_address_e                      ",                                
                           " FROM  benf , outer benp                         ",                                 
                           " WHERE benf.policy_no  ='",p_data_s1.policy_no,"'",                                 
                           " AND   benf.relation   ='",p_benf_relation,"'    ",                                 
                           " AND   benf.policy_no  = benp.policy_no          ",                                 
                           " AND   benf.relation   = benp.relation           ",
                           " AND   benf.client_id  = benp.client_id          "                                     
          END IF      
          -- 100/03/31 END
         
          PREPARE cur_f_cmd_1 FROM f_cmd_1
          DECLARE benf_cur CURSOR FOR cur_f_cmd_1   
          LET p_benf_cnt = 1
          FOREACH benf_cur INTO p_data_s2[p_benf_cnt].*,p_data_s2_b[p_benf_cnt].bank_name
          	                   ,p_data_s2_c[p_benf_cnt].*                              -- 100/03/31 ADD
             --  ���q�H��ƭY�O�� id �h�� clnt ���W�r --
             IF LENGTH(p_data_s2[p_benf_cnt].client_id CLIPPED) !=0 THEN
                SELECT names INTO p_data_s2[p_benf_cnt].names
                FROM   clnt
                WHERE  client_id=p_data_s2[p_benf_cnt].client_id
             END IF
             
             -- 100/03/31 ADD �~���W�ߧ�Ȧ椤��W��
             IF g_polf.currency <> 'TWD' THEN 
                SELECT bank_name
                  INTO p_data_s2_b[p_benf_cnt].bank_name
                  FROM bank
                 WHERE bank_code[1,3] = p_data_s2[p_benf_cnt].remit_bank
                   AND bank_code[4,7] = p_data_s2[p_benf_cnt].remit_branch
             END IF
             -- 100/03/31 END
             
             LET p_benf_cnt = p_benf_cnt + 1
          END FOREACH
          FREE benf_cur
          LET p_benf_cnt=p_benf_cnt-1
       END IF
       
       
    -- ��ܨ��o�����(�e���@�ĤT����) --
    DISPLAY BY NAME p_data_s3.*
       ATTRIBUTE (YELLOW)

    -- ��ܨ��o�����(�e���@�ĤG����) --
    IF f_benf_cnt !=0 THEN
       FOR f_i=1 TO 2
           IF f_i > p_benf_cnt THEN
              EXIT FOR
           END IF
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*   ATTRIBUTE (YELLOW)
       END FOR
    ELSE
       FOR f_i=1 TO 2
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*   ATTRIBUTE (YELLOW)
       END FOR 
    END IF
    

    -- 100/03/31 END
    
    -- ��ܨ��o�����(�e���@�Ĥ@����) --
    LET p_old_cp_disb_type        =f_cp_disb_type
    LET p_cp_sw                   =f_cp_sw
    LET p_data_s1.cp_disb_type    =f_cp_disb_type
    LET p_data_s1.mail_addr_ind   =f_mail_addr_ind
    LET p_data_s1.disb_special_ind=f_disb_special_ind
    LET p_data_s1.cp_pay_name     =f_cp_pay_name
    LET p_data_s1.cp_pay_id       =f_cp_pay_id
--    LET p_data_s1.dept_code       =f_cp_dept_code
    LET p_data_s1.po_sts_code     =g_polf.po_sts_code
    LET p_dept_code		  =f_cp_dept_code
    SELECT dept_name
    INTO   p_data_s1.dept_name
    FROM   dept
    WHERE  dept_code=p_dept_code
    LET p_data_s1.dept_name=p_data_s1.dept_name[1,18]
    LET p_data_s1.po_chg_rece_no = p_po_chg[1].po_chg_rece_no
{
    IF p_apdt_exist = '1' THEN
       DISPLAY "���z���X�D��89�Ψ��z�����p�D�ӿ줤�A�Ьd��!!"
                AT 22,1
                ATTRIBUTE (RED)
    END IF
}

    IF p_sel_sw="2" THEN
       LET p_data_s1.cp_disb_type="4"
    END IF

    LET INT_FLAG=FALSE

    MESSAGE f_hotkey_msg CLIPPED
    
    -- 100/03/31 MODIFY �~��������֡A�ҥH���O�y�k�n�@�ӭ���� 
    IF g_polf.currency = 'TWD' THEN  
       DISPLAY BY NAME p_data_s1.*    ATTRIBUTE (YELLOW)
    ELSE
    	 DISPLAY p_data_s1.policy_no         TO psc01_s2.policy_no          ATTRIBUTE (YELLOW)
    	 DISPLAY g_polf.currency             TO psc01_s2.currency           ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.po_sts_code       TO psc01_s2.po_sts_code        ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.cp_anniv_date     TO psc01_s2.cp_anniv_date      ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.po_chg_rece_no    TO psc01_s2.po_chg_rece_no     ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.cp_disb_type      TO psc01_s2.cp_disb_type       ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.disb_special_ind  TO psc01_s2.disb_special_ind   ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.cp_rtn_sw	       TO psc01_s2.cp_rtn_sw	        ATTRIBUTE (YELLOW) 
    END IF
    -- 100/03/31 END
    
    INPUT p_data_s1.cp_disb_type
         ,p_data_s1.mail_addr_ind
         ,p_data_s1.disb_special_ind
	 ,p_data_s1.cp_rtn_sw
    WITHOUT DEFAULTS
    FROM cp_disb_type
         ,mail_addr_ind
         ,disb_special_ind
	 ,cp_rtn_sw
	
	
    AFTER FIELD cp_disb_type
        -- SR151200331
		IF p_benf_cnt = 0 OR chk_benf_data() = FALSE THEN
			PROMPT "���q�H�ťթ�ID�ť�,�Щ���q�H�ɫ��ɫ�A�^��!(Y/N)" FOR CHAR f_ans_sw
			IF UPSHIFT(f_ans_sw) !="Y" OR
				f_ans_sw IS NULL        THEN
				NEXT FIELD cp_disb_type
			END IF
			-- ERROR "���q�H�ťթ�ID�ť�,�Щ���q�H�ɫ��ɫ�A�^��!"
			-- NEXT FIELD cp_disb_type �R�ǻ��i�H��USER�~��KEY
		END IF
		
		IF p_data_s1.cp_disb_type MATCHES "[0-5]" 
           AND p_data_s1.cp_disb_type != '5' THEN
           
           -- 105/04/01 �뵹�I�I�إu��^�� 0:�l�H�䲼,3:�q ��,4:���^��� 	-- 105/07/20
           IF p_data_s1.cp_disb_type MATCHES "[12]" AND                              
              psc99s01_pay_modx_by_anniv (p_data_s1.policy_no, p_data_s1.cp_anniv_date) = 1 THEN                            
              ERROR "���O�欰�뵹�I�A���A�Φ����I�覡!" ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           ELSE
              LET f_dummy_flag="ok"
           END IF
        ELSE
           IF p_data_s1.cp_disb_type = '6' THEN
              ERROR "���i��ܦ^�y!!"
                 ATTRIBUTE (RED)
           ELSE
              ERROR "���I�覡��J���~!!"
                 ATTRIBUTE (RED)
           END IF
           NEXT FIELD cp_disb_type
        END IF

        IF p_data_s1.cp_disb_type="1" THEN
           CALL psc01m_disb_type_1(f_serivce_agt_name
                                  ,f_agt_deptbelong
                                  ) RETURNING f_rcode
           LET f_rcode=0
           IF LENGTH(p_data_s1.cp_pay_name CLIPPED)=0 OR
              LENGTH(p_data_s1.cp_pay_id   CLIPPED)=0 OR
              LENGTH(p_dept_code   CLIPPED)=0 THEN
              ERROR "�d�O�@�~,����H��ƥ�����J !!"
              NEXT FIELD cp_disb_type
           END IF
        ELSE
           LET p_data_s1.cp_pay_name=""
           LET p_data_s1.cp_pay_id  =""
           LET p_dept_code          =""
           LET p_data_s1.dept_name  =""
        END IF

        DISPLAY p_data_s1.cp_pay_name,p_data_s1.cp_pay_id
               ,p_data_s1.dept_name
        TO      cp_pay_name,cp_pay_id,dept_name

        -- ���I�覡:��ú�O�O --
        IF p_data_s1.cp_disb_type="2" THEN
{--101/09 �������ˮ� yirong
           IF f_expired_sw ="Y" THEN
              ERROR  "�������O�椣�i��ܩ�ú�O�O !!"
              NEXT FIELD cp_disb_type
           END IF
}
{--101/09 �������ˮ� yirong           
           IF  p_data_s1.po_sts_code MATCHES "4[346]" THEN                 ----095/12�ݨDPS95I99S by yirong
               DISPLAY  "���O��w����ú������O�O�A���A�Ω�ú�O�O !!" AT 22,1 ATTRIBUTE (RED)
               NEXT FIELD cp_disb_type
           END IF 
}
--           LET f_disb_ind = ""
           LET f_ask_error = ""
           IF  g_polf.paid_to_date > p_tran_date THEN
   
               LET f_ask_error = "���i�O����ú�O�鬰",g_polf.paid_to_date,"�A�O�_���i��ú�O�O"
   
               IF  error_asker(f_ask_error) THEN 
   
               ELSE 
                   NEXT FIELD cp_disb_type
               END IF
   
           END IF       

           -- �����ú�O�O��J�L�i�O��{��,�\��Ѯe�ڴ���,�{����b p9610.4gl --
           INITIALIZE p_pc961_data.* TO NULL
           LET p_pc961_data.policy_no    =p_data_s1.policy_no
           LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
           LET p_pc961_data.prss_code    ="EDIT"
           LET p_pc961_data.tran_date    =p_tran_date
           LET p_pc961_data.cp_pay_amt   =0
           LET p_pc961_sw=TRUE
           LET p_pc961_msg=""
           CALL pc961_process(p_pc961_data.*,p_benf_relation)
                RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
           IF p_pc961_sw=FALSE THEN
              ERROR p_pc961_msg
              NEXT FIELD cp_disb_type
           END IF
           IF p_pc961_msg = '���O��w�L��ú�O,�п�J���i�O��Ω��' THEN
              ERROR p_pc961_msg
              NEXT FIELD cp_disb_type
           END IF


        END IF
{--102/10����     
        IF p_data_s1.cp_disb_type="6" THEN     --098/03 yirong --
           IF p_tran_date > p_data_s1.cp_anniv_date THEN            
              ERROR "�^�Ф���j��@�~����٥��g�~�餣�A�Φ��ﶵ!!"
                 ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           END IF 
                  
--           IF p_data_s1.policy_no MATCHES '181*' THEN
--              ERROR "�ȫO�q�����A�Φ��ﶵ!!"
--                 ATTRIBUTE (RED)
--              NEXT FIELD cp_disb_type
--           END IF
   

           IF f_expired_sw = "Y" THEN
              LET p_relation = 'M'
           ELSE
              LET p_relation = 'L'
           END IF
           LET p_benf_cnt1 = 0
          
           SELECT COUNT(*)
             INTO p_benf_cnt1
             FROM benf
            WHERE policy_no = p_data_s1.policy_no
              AND relation = p_relation  
                     
           IF p_benf_cnt1 > 1 THEN
              ERROR "���O�欰�h���q�H���o��^�y!!"
                 ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           END IF
        END IF
}

    BEFORE FIELD mail_addr_ind
        DISPLAY "                                                                " AT 22,1
        DISPLAY "�Y�a�}���ܪť�,�ѦҫO�檺���O�a�} !!"
                AT 22,1 
                ATTRIBUTE (RED)

    AFTER FIELD mail_addr_ind
        IF p_data_s1.mail_addr_ind !=" " THEN
           IF p_data_s1.mail_addr_ind MATCHES "[Qq]"  --
              and p_data_s1.cp_disb_type="0" THEN
              CALL ins_psc3()
           ELSE
              SELECT tel_1,tel_2 INTO p_tel_1,p_tel_2
              FROM   addr
              WHERE  client_id = p_applicant_id
              AND    addr_ind  = p_data_s1.mail_addr_ind
              IF STATUS = NOTFOUND THEN
                 ERROR "�l�H���ܤ��s�b!!"
                      ATTRIBUTE (RED)
                 NEXT FIELD mail_addr_ind
              END IF
           END IF
        END IF
        DISPLAY "" AT 22,1 

    AFTER FIELD disb_special_ind
        IF length(p_data_s1.disb_special_ind CLIPPED)=0 THEN
           LET p_data_s1.disb_special_ind="0"
           DISPLAY p_data_s1.disb_special_ind TO disb_special_ind
        END IF

        IF p_data_s1.disb_special_ind ="0" OR
           p_data_s1.disb_special_ind ="1" THEN
           LET f_dummy_flag="OK"
        ELSE
           ERROR "�q�׫��ܿ��~!!"
                 ATTRIBUTE (RED)
           NEXT FIELD disb_special_ind
        END IF

    BEFORE FIELD cp_rtn_sw
	IF f_cp_sw="3"
	OR f_cp_sw="7" THEN
	   LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
	   DISPLAY BY NAME p_data_s1.cp_rtn_sw
	END IF

    AFTER FIELD cp_rtn_sw
	IF length(p_data_s1.cp_rtn_sw CLIPPED)=0 THEN
	   ERROR "�ٴګ��ܿ��~!!" ATTRIBUTE(RED)
	   NEXT FIELD cp_rtn_sw
	ELSE
	   IF f_cp_sw="3"
	   OR f_cp_sw="7" THEN
	      IF p_data_s1.cp_rtn_sw != p_pscb.cp_rtn_sw THEN
		 ERROR "�O��w�@���M�b, ���i�ק��ٴګ���!!" ATTRIBUTE(RED)
		 LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
		 DISPLAY BY NAME p_data_s1.cp_rtn_sw
		 NEXT FIELD cp_rtn_sw
	      END IF
	   ELSE
	      IF p_data_s1.cp_rtn_sw = "0" THEN
{--101/09�������ˮ�yirong
	         IF p_benf_relation = "M" THEN
		    ERROR "�����O��, ���i��ܤ��ٴ�!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
}
	         IF p_pscb.overloan_sw = "1" THEN
		    ERROR "���O��| OverLoan, ���i��ܤ��ٴ�!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
	      ELSE
	         IF p_data_s1.cp_rtn_sw = "1" THEN
		    LET f_dummy_flag = "OK"
	         ELSE
		    ERROR "�ٴګ��ܿ��~!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
	      END IF
	   END IF
           IF p_pscb.guarantee_sw = 'Y' OR  p_pscb.guarantee_sw = 'N' THEN
              IF p_data_s1.cp_rtn_sw != '1' THEN
                 ERROR "�w�i�J�O�Ҵ����j���ٴ�!!" ATTRIBUTE(RED)
                 NEXT FIELD cp_rtn_sw
              END IF
           END IF

              
	END IF
    ON KEY (F2)
       LET f_rece = display_rece_no()
       LET p_data_s1.po_chg_rece_no = p_po_chg[f_rece].po_chg_rece_no
       DISPLAY p_data_s1.po_chg_rece_no TO po_chg_rece_no

    ON KEY (F5) -- �a�}����,�e�ڴ��ѥ\�� --
    	 -- 100/03/31 MODIFY �~���L���\��
    	 IF g_polf.currency = 'TWD' THEN
            LET  p_data_s1.mail_addr_ind = ' '
            CALL disp_addr(p_applicant_id) RETURNING p_data_s1.mail_addr_ind
            DISPLAY p_data_s1.mail_addr_ind TO mail_addr_ind

            IF INT_FLAG = TRUE THEN
               LET INT_FLAG = FALSE
            END IF    
         
         
{
          LET  p_pce_param="1"
          LET  f_addr_cmd="pce01m.4ge "
                         ,p_pce_param
                         ," "
                         ,p_data_s1.policy_no
                         ," "
                         ,p_applicant_id," ","R0"
          
          RUN f_addr_cmd
}
          MESSAGE f_hotkey_msg CLIPPED
       END IF
       -- 100/03/31 END
       
    ON KEY (F6) -- ���q�H�@�~ --
       IF p_benf_cnt !=0 THEN
          CALL psc01m_edit_benf()
               RETURNING f_rcode
         
          MESSAGE f_hotkey_msg CLIPPED
          IF f_rcode !=0 THEN
             LET INT_FLAG=FALSE
             NEXT FIELD cp_disb_type
          ELSE 
             FOR f_i=1 to 2
                 DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*                         ATTRIBUTE (YELLOW)
             END FOR
             NEXT FIELD cp_disb_type
          END IF
       ELSE
          ERROR "���O��L���q�H���,���i�� F6"
                ATTRIBUTE (RED)
          NEXT FIELD cp_disb_type         
       END IF

    ON KEY (F8) -- ���w�q�ק@�~ --
       IF p_data_s1.disb_special_ind="1" THEN
       	  --100/03/31 MODIFY
       	  IF g_polf.currency = 'TWD' THEN
             CALL psc01m_edit_pscs()
                  RETURNING f_rcode
          ELSE
          	 CALL psc01m_edit_pscy()
                  RETURNING f_rcode
          END IF
          --100/03/31 END
          
          MESSAGE f_hotkey_msg CLIPPED
          IF f_rcode !=0 THEN
             LET INT_FLAG=FALSE
             NEXT FIELD disb_special_ind
          ELSE
             NEXT FIELD disb_special_ind
          END IF
       END IF

    ON KEY (F9) -- ���O�d�� --
       CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
            RETURNING f_pscninq_sw
       MESSAGE f_hotkey_msg CLIPPED

    ON KEY (F7) -- �Ȧ��ƺ��@�@�~ --
    	 --100/03/31 MODIFY
       IF g_polf.currency = 'TWD' THEN
          LET f_bank_cmd = "pd121m.4ge"	 
       ELSE
          LET f_bank_cmd = "db020m.4ge"	  	
       END IF
       --100/03/31 END
         
       RUN f_bank_cmd
       MESSAGE f_hotkey_msg CLIPPED

    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       -- �^�Ч@�~  --
       IF p_sel_sw="1" THEN
          IF p_cp_notice_code="2"  THEN  -- ���^��� --
             IF p_data_s1.cp_disb_type !="4" THEN
                ERROR "�O���^�Х�B�z,���i��ܨ�L�I�ڤ覡!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF
          IF p_data_s1.cp_disb_type ="4" THEN
             IF p_cp_notice_code !="2" THEN
                ERROR "�D���^�Х�B�z,���i��� 4 �I�ڤ覡!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF 
       END IF

       -- �浧���^�i�J����@�~ --
       IF p_sel_sw="2" THEN
          IF p_data_s1.cp_disb_type !="4" THEN
             ERROR "�浧���^�Ч@�~,����覡���� 4 !!"
             NEXT FIELD cp_disb_type
          END IF
          LET p_data_s1.cp_disb_type="4"
       END IF

       -- ���I�覡:��ú�O�O --
       IF p_data_s1.cp_disb_type="2" THEN
{-----101/11yirong�������ˮ�
          IF f_expired_sw ="Y" THEN
             ERROR  "�������O�椣�i��ܩ�ú�O�O !!"
             NEXT FIELD cp_disb_type
          END IF
}
          -- after input ���b����@����ú�s�� --
          IF p_pc961_sw=FALSE THEN
             ERROR p_pc961_msg
             NEXT FIELD cp_disb_type
          END IF

       END IF

       IF p_data_s1.cp_disb_type="4" THEN
          LET p_data_s1.disb_special_ind="0"
          LET p_data_s1.cp_pay_name	=""
          LET p_data_s1.cp_pay_id	=""
          LET p_dept_code		=""
          LET p_data_s1.dept_name	=""
       END IF

       -- �I�ڬ��d�O���ˮ� --
       IF p_data_s1.cp_disb_type !="1" THEN
          LET p_data_s1.cp_pay_name	=""
          LET p_data_s1.cp_pay_id	=""
          LET p_dept_code		=""
          LET p_data_s1.dept_name	=""
          LET p_tel_3                   =""
       ELSE
          IF length(p_data_s1.cp_pay_name CLIPPED) =0 OR
             length(p_data_s1.cp_pay_id   CLIPPED) =0 OR
             length(p_dept_code   CLIPPED) =0 THEN
             ERROR "�I�ڤ覡���d�O,������J������ !!"
                    ATTRIBUTE (RED)
                    NEXT FIELD cp_disb_type
          END IF

          IF p_dept_code="90000"  OR
             p_dept_code="91000"  OR
             p_dept_code="93000"  OR
             p_dept_code="94000"  OR
             p_dept_code="95000"  OR
             p_dept_code="96000"  OR
             p_dept_code="97000"  OR
             p_dept_code="98000"  OR    
             p_dept_code="92000"  OR
             p_dept_code="9A000"  OR
             p_dept_code="9B000"  THEN
             LET f_dummy_flag="OK"
          ELSE
             ERROR "����a�Ͽ��~!!"
                    ATTRIBUTE (RED)
                    NEXT FIELD cp_disb_type
          END IF
       END IF

       IF p_data_s1.cp_disb_type !="3" AND
          p_data_s1.disb_special_ind="1" THEN
          ERROR "���I�D�q��,�q�׫��ܶ��� 0 !!"
          NEXT FIELD cp_disb_type
       END IF

       -- �L���q�H��� --
       IF f_benf_cnt=0 THEN
          IF p_data_s1.cp_disb_type="3" THEN
             IF p_data_s1.disb_special_ind !="1" THEN
                ERROR "���O��L���q�H���,�q�ץ����O���w�q��!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF
       END IF

       -- ����ˬd   --

       IF p_data_s1.cp_disb_type="3" THEN

          -- 100/03/31 MODIFY
          IF g_polf.currency = 'TWD' THEN
             IF p_data_s1.disb_special_ind="1" THEN
          	 
                SELECT * 
                FROM  pscs
                WHERE policy_no=p_data_s1.policy_no
                AND   cp_anniv_date=p_data_s1.cp_anniv_date

                IF STATUS = NOTFOUND THEN
                   ERROR "�q�׫��ܡA���w�q�׵L���!!"
                         ATTRIBUTE (RED)
                   NEXT FIELD cp_disb_type
                END IF
             ELSE
                DECLARE benf_cur_1 CURSOR FOR
                        SELECT client_id
                              ,benf_ratio
                              ,remit_bank
                              ,remit_branch
                              ,remit_account
                              ,benf_order
                              ,names
                        FROM  benf
                        WHERE policy_no  =p_data_s1.policy_no
                        AND   relation   =p_benf_relation
                
                LET f_j = 1
                LET f_disb_err = 0
                FOREACH benf_cur_1 INTO p_data_s2[f_j].*
                  --  ���q�H��ƭY�O�� id �h�� clnt ���W�r --
                  IF LENGTH(p_data_s2[f_j].client_id CLIPPED) !=0 THEN
                     SELECT names INTO p_data_s2[f_j].names
                     FROM   clnt
                     WHERE  client_id=p_data_s2[f_j].client_id
                  END IF
               
                  IF p_data_s2[f_j].remit_bank IS NULL OR
                     p_data_s2[f_j].remit_bank=" "     THEN
                     ERROR "���q�H���״ڻȦ楲������!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  IF p_data_s2[f_j].remit_branch IS NULL  OR
                     p_data_s2[f_j].remit_branch =" "     THEN
                     ERROR "���q�H���״ڤ��楲������!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                     
                  IF p_data_s2[f_j].remit_account IS NULL OR
                     p_data_s2[f_j].remit_account=" "     THEN
                     ERROR "���q�H���״ڱb����������!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  -- 090/05/02 JC �ק� --
                  CALL chkRemitAcct(p_data_s2[f_j].remit_bank
                                   ,p_data_s2[f_j].remit_branch
                                   ,p_data_s2[f_j].remit_account
                                  )
                       RETURNING f_chk_remit_err,f_chk_remit_msg
                  IF f_chk_remit_err !="0" THEN
                     ERROR f_chk_remit_msg  ATTRIBUTE(RED)
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  IF f_j=1 OR
                     f_j=2 THEN
                     DISPLAY p_data_s2[f_j].*
                     TO      psc01_s1[f_j].*
                             ATTRIBUTE (YELLOW)
                  END IF
                  LET f_j = f_j + 1
               
                END FOREACH
                
                FREE benf_cur_1
          
                IF f_disb_err=1 THEN
                   NEXT FIELD cp_disb_type
                END IF
                LET f_j=f_j-1
             END IF -- disb_special_ind="1" --
          ELSE
          	 IF p_data_s1.disb_special_ind="1" THEN
                SELECT * 
                FROM  pscy
                WHERE policy_no=p_data_s1.policy_no
                AND   cp_anniv_date=p_data_s1.cp_anniv_date

                IF STATUS = NOTFOUND THEN
                   ERROR "�q�׫��ܡA���w�q�׵L���!!"
                         ATTRIBUTE (RED)
                   NEXT FIELD cp_disb_type
                END IF
             ELSE
             	  LET f_client_id =''
             	  DECLARE benf_cur_2 CURSOR FOR
                        SELECT client_id
                        FROM  benf
                        WHERE policy_no  =p_data_s1.policy_no
                        AND   relation   =p_benf_relation

                LET f_disb_err = 0
                FOREACH benf_cur_2 INTO f_client_id
                  
                  LET f_swift_code     = ''
                  LET f_bank_account_e = ''
                             
                  
             	    -- �n�ˬd�~���b���n�إ�(��l�ӳ��ˮ֥�payforeign�B�z)
                  LET p_cp_pay_amt = 0
                  LET p_cp_pay_amt = p_cp_amt - g_polf.apl_amt - g_polf.apl_int_balance
                                    - g_polf.loan_amt - g_polf.loan_int_balance
                  IF p_cp_pay_amt <= 0 AND p_data_s1.cp_rtn_sw = '1' THEN
                     PROMPT "��I���B��0,�O�_���إ~���b�� Y/N" FOR CHAR f_ans_sw
                     IF UPSHIFT(f_ans_sw) ="Y" OR
                        f_ans_sw IS NULL        THEN
                     ELSE
                        ERROR "���q�H���״ڻȦ�SWIFT��������!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
                  ELSE
                     SELECT swift_code, bank_account_e
                       INTO f_swift_code, f_bank_account_e
                       FROM benp
                      WHERE policy_no  = p_data_s1.policy_no
                        AND relation   = p_benf_relation
                        AND client_id  = f_client_id

                     IF f_swift_code IS NULL OR
                        f_swift_code=" "     THEN
                        ERROR "���q�H���״ڻȦ�SWIFT��������!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
       
                     IF f_bank_account_e IS NULL OR
                        f_bank_account_e=" "     THEN
                        ERROR "���q�H���~���״ڱb����������!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
                  END IF
               END FOREACH
               IF f_disb_err=1 THEN
                   NEXT FIELD cp_disb_type
                END IF
             END IF
          END IF -- g_polf.currency = 'TWD' --
       END IF -- cp_disb_type="3" --
       
       IF p_data_s1.mail_addr_ind !=" "THEN
          IF p_data_s1.mail_addr_ind MATCHES "[Qq]" THEN
          ELSE
  
             SELECT tel_1,tel_2 INTO p_tel_1,p_tel_2
             FROM   addr
             WHERE  client_id = p_applicant_id
             AND    addr_ind  = p_data_s1.mail_addr_ind
             IF STATUS = NOTFOUND THEN
                ERROR "�l�H���ܤ��s�b!!"
                     ATTRIBUTE (RED)
                NEXT FIELD mail_addr_ind
             END IF
          END IF
       END IF

       IF length(p_data_s1.cp_rtn_sw CLIPPED)=0 THEN
	  ERROR "�ٴګ��ܿ��~!!" ATTRIBUTE(RED)
          NEXT FIELD cp_rtn_sw
       ELSE
	  IF f_cp_sw="3"
	  OR f_cp_sw="7" THEN
	     IF p_data_s1.cp_rtn_sw != p_pscb.cp_rtn_sw THEN
                ERROR "�O��w�@���M�b, ���i�ק��ٴګ���!!" ATTRIBUTE(RED)
                LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
                DISPLAY BY NAME p_data_s1.cp_rtn_sw
                NEXT FIELD cp_rtn_sw
             END IF
          ELSE
             IF p_data_s1.cp_rtn_sw = "0" THEN
	        IF p_benf_relation = "M" THEN
		   ERROR "�����O��, ���i��ܤ��ٴ�!!" ATTRIBUTE(RED)
		   NEXT FIELD cp_rtn_sw
	        END IF
                IF p_pscb.overloan_sw = "1" THEN
                   ERROR "���O��| OverLoan, ���i��ܤ��ٴ�!!" ATTRIBUTE(RED)
                   NEXT FIELD cp_rtn_sw
                END IF
             ELSE
                IF p_data_s1.cp_rtn_sw = "1" THEN
                   LET f_dummy_flag = "OK"
                ELSE
                   ERROR "�ٴګ��ܿ��~!!" ATTRIBUTE(RED)
                   NEXT FIELD cp_rtn_sw
                END IF
             END IF
	  END IF
       END IF
  
       ------�O�ҵ��I��ĵ�T------
       IF p_pscb.guarantee_sw = 'Y' THEN
          ERROR "�����ͦs�����O�ҵ��I���A�Яd�N�I"
       END IF

       ------�L�O�Ҵ��A���T�{------
       IF psc_after_gee_chk(p_data_s1.policy_no,p_data_s1.cp_anniv_date) THEN
          PROMPT "�����ͦs�����D�O�ҵ��I���A�а��Q�O�I�H���ͦs�{��(Y/N)" FOR CHAR f_ans_sw
          IF UPSHIFT(f_ans_sw) !="Y" OR
             f_ans_sw IS NULL        THEN
             NEXT FIELD cp_disb_type
          END IF
       END IF  


       LET f_ans_sw=""
       LET f_ans_sw1=""
       LET p_online_prc = "0"
       PROMPT "�T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD cp_disb_type
       ELSE
          IF g_polf.currency = 'USD' THEN
             IF usd_notify(p_data_s1.cp_anniv_date) THEN 
                ERROR "�|���٥��g�~�饼�^�СI�I"
{
                LET f_ans_sw=""
                PROMPT "�|���٥��g�~�饼�^��" FOR CHAR f_ans_sw
                IF UPSHIFT(f_ans_sw) !="Y" OR
                   f_ans_sw IS NULL        THEN
                   NEXT FIELD cp_disb_type
                END IF
}
             END IF
          END IF
          IF p_data_s1.cp_disb_type="1" THEN
             IF p_tran_date >= p_data_s1.cp_anniv_date THEN
                PROMPT "�w���O��P�~��A�O�_����L�b(Y/N)" FOR CHAR f_ans_sw1
                IF UPSHIFT(f_ans_sw1) !="Y" OR
                   f_ans_sw1 IS NULL        THEN
                ELSE
display 'into pscw'
                   LET p_online_prc = "1"
                   CALL ins_pscw() RETURNING f_rcode 
                   IF NOT f_rcode THEN
display "insert pscw error !!"
                   END IF
                END IF 
             END IF
             IF LENGTH(p_tel_3 CLIPPED) > 0 THEN
display 'INSERT psc4=',p_tel_3
                SELECT count(*)
                  INTO f_psc4_cnt 
                  FROM psc4
                 WHERE policy_no = p_data_s1.policy_no
                   AND cp_anniv_date = p_data_s1.cp_anniv_date
                   AND psc_type = '2' 
                IF f_psc4_cnt > 0 THEN
                   DELETE FROM psc4
                    WHERE policy_no=p_data_s1.policy_no
                      AND cp_anniv_date = p_data_s1.cp_anniv_date
                      AND psc_type='2'
                END IF

 
                INSERT INTO psc4 VALUES(
                       p_data_s1.policy_no,
                       p_data_s1.cp_anniv_date,
                       '',
                       '2',
                       p_tel_3,
                       g_user,
                       p_dept_code,
                       p_tran_date)
             
             END IF          
          END IF 
       END IF

    END INPUT

    -- ���_�@�~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       ERROR "����@�~���"
             ATTRIBUTE (RED)
       RETURN f_rcode
    END IF

    LET f_mail_addr_ind=p_data_s1.mail_addr_ind

    -- ��s�ɮ� --
    CALL psc01m_save_data() 
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "update pscb error !!"
            ATTRIBUTE (RED)       
       LET f_rcode=1
    END IF

    -- 100/03/31 ADD �~���n�����t�~�@��FORM
    IF g_polf.currency <> 'TWD' THEN
    	 CLOSE FORM psc00m11
    ELSE
    	 CLOSE FORM psc00m00  -- 101/02/20 ADD �^�Юɤ����~��/�x���O��A������FORM 
    END IF
    -- 100/03/31 ADD
    
    MESSAGE " "
    RETURN f_rcode
END FUNCTION   -- psc01m_query --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_query_pt
--  �@    ��: kurt
--  ��    ��: 094/05/26
--  �B�z���n: SIPA�d�ߧ@�~,�d�ߵe��
--  ���n�禡:
------------------------------------------------------------------------------

FUNCTION psc01m_query_pt()
    
    DEFINE f_rcode              INTEGER
          ,f_dummy_flag         CHAR(2)
          ,f_ans_sw             CHAR(1)   -- prompt ���^�� --
          ,f_expired_sw         CHAR(1)
          ,f_psck_sw            CHAR(1)
          ,f_psck_cnt           INTEGER
          ,f_pscninq_sw         INTEGER

    DEFINE f_po                 CHAR(255) -- ���o po ��T�� prepare --
    DEFINE f_addr_cmd           CHAR(255) -- ����a�}���ק�s�W�@�~ --
    DEFINE f_bank_cmd		CHAR(255) -- ����Ȧ��ƺ��@�@�~ --
    DEFINE f_i                  INTEGER   -- array �p�ƾ� --
          ,f_benf_cnt           INTEGER   -- ���q�H�p�ƾ� --
          ,f_arr_cur            INTEGER   -- ���q�H��J���p�� --
          ,f_scr_cur            INTEGER   -- ���q�H�e�����p�� --
          ,f_disb_err           INTEGER   -- ���q�H�Ȧ�b������ --
          ,f_chk_remit_err      INTEGER 
          ,f_chk_remit_msg      CHAR(255)

    DEFINE f_pscb_cnt           INTEGER   -- ���� perpare ���O���O��i���� --
          ,f_polf_cnt           INTEGER   -- polf �O�_�s�b input �O�� --
          ,f_right_or_fault     INTEGER   -- ����ˬd t or f --
          ,f_formated_date      CHAR(9)   -- ����榡�� 999/99/99 --
          ,f_benf_relation      CHAR(1)   -- ����/�ͦs ���q�H --
          ,f_serivce_agt_name   CHAR(40)  -- �A�ȷ~�ȭ�_name --
          ,f_agt_deptbelong     CHAR(6)   -- agent ���ݤ����q --

    DEFINE f_cp_anniv_date      LIKE    pscb.cp_anniv_date
          ,f_cp_sw              LIKE    pscb.cp_sw
          ,f_cp_disb_type       LIKE    pscb.cp_disb_type
          ,f_mail_addr_ind      LIKE    pscb.mail_addr_ind
          ,f_disb_special_ind   LIKE    pscb.disb_special_ind
          ,f_pay_ind            CHAR(1)
          ,f_cp_pay_name        CHAR(12)
          ,f_cp_pay_id          LIKE    pscb.cp_pay_id
          ,f_cp_dept_code       LIKE    pscb.dept_code

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype
          ,f_chk_sw             LIKE pscr.cp_chk_sw
          ,f_chk_date           LIKE pscr.cp_chk_date

    DEFINE f_arr                INTEGER
          ,f_dtl_cp_ann         LIKE    pscb.cp_anniv_date

    DEFINE f_client_ident       LIKE    colf.client_ident
          ,f_applicant_id       LIKE    clnt.client_id
          ,f_insured_id         LIKE    clnt.client_id
          ,f_addr_id            LIKE    clnt.client_id
          ,f_addr_ind           LIKE    addr.addr_ind
          ,f_zip_code           LIKE    addr.zip_code
          ,f_address            LIKE    addr.address
          ,f_app_name           LIKE    clnt.names
          ,f_insured_name       LIKE    clnt.names


    MESSAGE " END:����"

    LET INT_FLAG      =FALSE
    LET f_client_ident=" "
    LET f_applicant_id=" "
    LET f_app_name    =" "
    LET f_insured_id  =" "
    LET f_insured_name=" "
    LET f_addr_id     =" "
    LET f_addr_ind    ="0"
    LET f_zip_code    =" "
    LET f_address     =" "
    LET f_chk_date    =" "
    LET f_chk_sw      =" "
    LET f_psck_sw     =" "

    LET f_psck_cnt    =0
    LET f_pscb_cnt    =0
    LET f_polf_cnt    =0
    LET f_benf_cnt    =0
    LET p_data_s1.policy_no=p_policy_no
    LET p_data_s1.cp_anniv_date=p_cp_anniv_date
    -- ����ˬd --


    -- ���� or �ͦs --
    IF g_poia.expired_date <= p_data_s1.cp_anniv_date THEN
       LET f_expired_sw="Y"
    ELSE
       LET f_expired_sw="N"
    END IF

    SELECT count(*) INTO f_pscb_cnt
    FROM   ptpr
    WHERE  policy_no  = p_data_s1.policy_no
    AND    payout_due = p_data_s1.cp_anniv_date
--    AND    cp_sw  in ("1","3","4","7","8")

    IF f_pscb_cnt is null OR
       f_pscb_cnt =0      THEN
       ERROR "���i�O��L���I���!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- �٥����O --
    SELECT count(*) INTO f_psck_cnt
    FROM   psck
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    IF f_psck_cnt=0 THEN
       LET f_psck_sw="N"
    ELSE
       LET f_psck_sw="Y"
    END IF


    LET f_pscb_cnt=0
    LET f_polf_cnt=0
    LET f_benf_cnt=0
    LET p_benf_cnt=0

    SELECT * INTO g_ptpr.*
    FROM   ptpr
    WHERE  policy_no    =p_policy_no
    AND    payout_due   =p_data_s1.cp_anniv_date

    LET f_cp_sw             = '1'
--  LET f_cp_disb_type      = '3'----�qptpc���o
--  LET f_mail_addr_ind     = g_ptpc.mail_addr_ind
    LET f_disb_special_ind  = '0'
    LET f_cp_pay_name       = ''
    LET f_cp_pay_id         = ''
    LET f_cp_dept_code      = ''

    -- �e���@���ĤT����� --
        LET p_data_s3.psck_sw       = f_psck_sw
        LET p_data_s3.overloan_desc = "N"
	IF g_ptpr.live_certi_ind = "Y" THEN
	   LET p_data_s3.notice_resp_desc = "Y"
	ELSE
           LET p_data_s3.notice_resp_desc = "N"
	END IF

        -- �n�O�HID,�m�W --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

        -- �Q�O�HID,�m�W --
        LET f_chk_sw = 'Y'
        LET f_chk_date = ''
        LET p_coverage_no=1
        LET f_client_ident='I1'

        SELECT client_ident
        INTO   f_client_ident
        FROM   coia
        WHERE  policy_no=p_data_s1.policy_no
        AND    coverage_no=1

        CALL getNames(p_data_s1.policy_no,f_client_ident)
             RETURNING f_insured_id,f_insured_name

        LET p_data_s3.app_name    =p_applicant_name[1,12] CLIPPED
        LET p_data_s3.app_id	  =p_applicant_id
        LET p_data_s3.insured_name=f_insured_name[1,12]   CLIPPED
        LET p_data_s3.insured_id  =f_insured_id

    -- �e���@���ĤG�����,���q�H��� --

       SELECT count(*)
       INTO   f_benf_cnt
       FROM   ptpc
       WHERE  policy_no = p_data_s1.policy_no
       AND    active_sw = '1'

       IF f_benf_cnt !=0 THEN

          LET f_i=1
          DECLARE ptpc_cur CURSOR FOR
                  SELECT client_id
                        ,pay_dividend
                        ,remit_bank
                        ,remit_branch
                        ,remit_account
                        ,''
                        ,names
                        ,mail_addr_ind
                        ,pay_method
                  FROM  ptpc
                  WHERE policy_no  = p_data_s1.policy_no
                  AND   active_sw  = '1'

          LET p_benf_cnt = 1

          FOREACH ptpc_cur INTO p_data_s2[p_benf_cnt].*,p_data_s21[p_benf_cnt].*

             --  ���q�H��ƭY�O�� id �h�� clnt ���W�r --
             IF LENGTH(p_data_s2[p_benf_cnt].client_id CLIPPED) !=0 THEN
                SELECT names INTO p_data_s2[p_benf_cnt].names
                FROM   clnt
                WHERE  client_id=p_data_s2[p_benf_cnt].client_id
             END IF
             LET f_mail_addr_ind=p_data_s21[p_benf_cnt].mail_addr_ind
             IF  p_data_s21[p_benf_cnt].pay_method = '1' THEN  --�״�
                 LET f_cp_disb_type = '3'
             ELSE
                 LET f_cp_disb_type = '0'
             END IF
             LET p_benf_cnt = p_benf_cnt + 1
          END FOREACH
          FREE benf_cur
          LET p_benf_cnt=p_benf_cnt-1
       END IF

    -- ��ܨ��o�����(�e���@�ĤT����) --
    DISPLAY BY NAME p_data_s3.*
       ATTRIBUTE (YELLOW)

    -- ��ܨ��o�����(�e���@�ĤG����) --
    IF f_benf_cnt !=0 THEN
       FOR f_i=1 TO 2
           IF f_i > p_benf_cnt THEN
              EXIT FOR
           END IF
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*
                   ATTRIBUTE (YELLOW)
       END FOR
    ELSE
       FOR f_i=1 TO 2
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*
                   ATTRIBUTE (YELLOW)
       END FOR 
    END IF

    -- ��ܨ��o�����(�e���@�Ĥ@����) --
    LET p_old_cp_disb_type        =f_cp_disb_type
    LET p_cp_sw                   =f_cp_sw
    LET p_data_s1.cp_disb_type    =f_cp_disb_type
    LET p_data_s1.mail_addr_ind   =f_mail_addr_ind
    LET p_data_s1.disb_special_ind=f_disb_special_ind
    LET p_data_s1.cp_rtn_sw       ='0'
    LET p_data_s1.cp_pay_name     =f_cp_pay_name
    LET p_data_s1.cp_pay_id       =f_cp_pay_id
--    LET p_data_s1.dept_code       =f_cp_dept_code
    LET p_data_s1.po_sts_code     =g_poia.po_sts_code
    LET p_dept_code		  =f_cp_dept_code
    SELECT dept_name
    INTO   p_data_s1.dept_name
    FROM   dept
    WHERE  dept_code=p_dept_code
    LET p_data_s1.dept_name=p_data_s1.dept_name[1,18]


    LET INT_FLAG=FALSE

    MESSAGE "END:���,F9:���O,F7:�Ȧ��ƺ��@�@�~"

    DISPLAY BY NAME p_data_s1.*
       ATTRIBUTE (YELLOW)

    INPUT p_data_s1.cp_disb_type
--         ,p_data_s1.mail_addr_ind
    WITHOUT DEFAULTS
    FROM  cp_disb_type
--         ,mail_addr_ind

    BEFORE FIELD cp_disb_type
        DISPLAY "���I�^�Ф��ݭn��ܡA�Ъ����� ESC �~��!!"
                AT 22,1 
                ATTRIBUTE (RED)
	-- SR151200331
    AFTER FIELD cp_disb_type
        DISPLAY "                                                   "  AT 22,1
		IF p_benf_cnt = 0 OR chk_benf_data() = FALSE THEN
			PROMPT "���q�H�ťթ�ID�ť�,�Щ���q�H�ɫ��ɫ�A�^��!(Y/N)" FOR CHAR f_ans_sw
			IF UPSHIFT(f_ans_sw) !="Y" OR
				f_ans_sw IS NULL        THEN
				NEXT FIELD cp_disb_type
			END IF
			-- ERROR "���q�H�ťթ�ID�ť�,�Щ���q�H�ɫ��ɫ�A�^��!"
			-- NEXT FIELD cp_disb_type �R�ǻ��i�H��USER�~��KEY
		END IF

    ON KEY (F9) -- ���O�d�� --
       CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
            RETURNING f_pscninq_sw
       MESSAGE "END:���,F9:���O,F7:�Ȧ��ƺ��@�@�~"

    ON KEY (F7) -- �Ȧ��ƺ��@�@�~ --
       LET f_bank_cmd = "pd121m.4ge"	 
       RUN f_bank_cmd
       MESSAGE "END:���,F9:���O,F7:�Ȧ��ƺ��@�@�~"

    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET f_ans_sw=""
       PROMPT "�T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD cp_disb_type
       END IF

    END INPUT

    -- ���_�@�~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       ERROR "����@�~���"
             ATTRIBUTE (RED)
       RETURN f_rcode
    END IF

    LET f_mail_addr_ind = p_data_s1.mail_addr_ind
--    LET p_data_s1.mail_addr_ind = f_mail_addr_ind

    -- ��s�ɮ� --
    CALL psc01m_save_data_pt()
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "update pscb error !!"
            ATTRIBUTE (RED)       
       LET f_rcode=1
    END IF

    MESSAGE " "
    RETURN f_rcode
END FUNCTION   -- psc01m_query_pt --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_save_data_pt
--  �@    ��: kurt
--  ��    ��: 094/05/27
--  �B�z���n: ���I�^�Ч@�~,�T�{
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc01m_save_data_pt()
    DEFINE f_rcode   INTEGER
    DEFINE f_pscs_sw INTEGER
    DEFINE f_cp_notice_sw CHAR(1)
    DEFINE f_pscs    RECORD LIKE pscs.*
    DEFINE f_due_date CHAR(9)

    LET f_rcode=0
    LET f_pscs_sw=0

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    IF length(p_cp_notice_code CLIPPED)=0 THEN
       LET f_cp_notice_sw=p_pscb.cp_notice_sw
    END IF

    IF p_cp_notice_code="0" OR     ----�������A�ӷ|�^�ФJ���I
       p_cp_notice_code="3" THEN
       LET f_cp_notice_sw="2"      ----�w�^��, �i�J������I
    END IF

    IF p_cp_notice_code="1" THEN    ----��󤣻���
       IF p_cp_notice_sub_code="0" THEN
          LET f_cp_notice_sw="2"
       END IF
    END IF

----�P�B��sptpm.mail_ptpr_ind �l�H�q�����ܡA���^�ФU���~�|�H�X�{�ҫH
    UPDATE ptpm
    SET    mail_ptpr_ind  = 'Y'
    WHERE  policy_no      = p_data_s1.policy_no
--      AND  payout_seq    != 'N'
    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
display 'err update ptpm'
       RETURN f_rcode
    END IF
----
    UPDATE ptpd
    SET    opt_notice_sw  = '2'
          ,payout_ind     = 'Y'
          ,process_date   = p_tx_date
          ,process_user   = g_user
    WHERE  policy_no      = p_data_s1.policy_no
      AND  payout_due     = p_data_s1.cp_anniv_date
      AND  payout_ind       != 'N'
    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
display 'err update ptpd'
       RETURN f_rcode
    END IF
    ----�P�B��s�{�Ҧ^�СA�p��^�Ф骺�{��
    IF  p_tx_date < p_data_s1.cp_anniv_date THEN
        LET f_due_date = p_data_s1.cp_anniv_date
    ELSE
        LET f_due_date = p_tx_date
    END IF
    UPDATE ptpd
    SET    opt_notice_sw  = '2'
          ,payout_ind     = 'Y'
          ,process_date   = p_tx_date
          ,process_user   = g_user
    WHERE  policy_no      = p_data_s1.policy_no
      AND  payout_due     < f_due_date
      AND  payout_ind       != 'N'
      AND  opt_notice_sw  = '1'
    IF SQLCA.SQLCODE !=0 THEN
    ELSE
display '�P�B��s�{�Ҧ^�е���=',SQLCA.SQLERRD[3],'�{�Ҥ�p��',f_due_date
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psd01m_save_data_pt --
------------------------------------------------------------------------------
--  �禡�W��: psc01m_save_data
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��^�Ч@�~,�T�{
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc01m_save_data()
    DEFINE f_rcode   INTEGER
    DEFINE f_pscs_sw INTEGER
          ,f_cp_notice_sw CHAR(1)
    DEFINE f_pscs    RECORD LIKE pscs.*
    DEFINE f_i       INTEGER
    DEFINE f_msg     CHAR(100)
    DEFINE f_nonresp_cnt INTEGER 
    DEFINE f_prompt_ans  CHAR(1)

    LET f_rcode=0
    LET f_pscs_sw=0

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    -- 100/03/31 MODIFY
    IF p_data_s1.disb_special_ind="0" THEN
       IF g_polf.currency = 'TWD' THEN 
           SELECT * INTO f_pscs.*
           FROM   pscs
           WHERE  policy_no    =p_data_s1.policy_no
           AND    cp_anniv_date=p_data_s1.cp_anniv_date
           
           IF STATUS = NOTFOUND THEN
              LET f_pscs_sw="0"
           ELSE
              DELETE FROM pscs
              WHERE  policy_no    =p_data_s1.policy_no
              AND    cp_anniv_date=p_data_s1.cp_anniv_date
              IF SQLCA.SQLCODE !=0 THEN
                 ROLLBACK WORK
                 LET f_rcode=1
                 RETURN f_rcode
              END IF
           END IF
       ELSE
           SELECT * 
           FROM   pscy
           WHERE  policy_no    =p_data_s1.policy_no
           AND    cp_anniv_date=p_data_s1.cp_anniv_date
           
           IF STATUS = NOTFOUND THEN
              LET f_pscs_sw="0"
           ELSE
              DELETE FROM pscy
              WHERE  policy_no    =p_data_s1.policy_no
              AND    cp_anniv_date=p_data_s1.cp_anniv_date
              IF SQLCA.SQLCODE !=0 THEN
                 ROLLBACK WORK
                 LET f_rcode=1
                 RETURN f_rcode
              END IF
           END IF
       END IF
    END IF -- disb_special_ind="0" --
    -- 100/03/31 END
    
    -- 100/03/31 COMMENT OUT 
    -- ���e�{�����J����ơA�w�g�ˬd�Lcp_disb_type !="3"�ɡAdisb_special_ind������0
    -- �ҥH�@�w�|���J�W�@�q(IF disb_special_ind="0")������
    -- �H�U�o�@�q�ΦP��]�A�G�������C
{
    IF p_data_s1.cp_disb_type !="3" and 
       p_data_s1.disb_special_ind !="1" THEN

       SELECT * INTO f_pscs.*
       FROM   pscs
       WHERE  policy_no    =p_data_s1.policy_no
       AND    cp_anniv_date=p_data_s1.cp_anniv_date

       IF STATUS = NOTFOUND THEN
          LET f_pscs_sw="0"
       ELSE
          DELETE FROM pscs
          WHERE  policy_no    =p_data_s1.policy_no
          AND    cp_anniv_date=p_data_s1.cp_anniv_date
          IF SQLCA.SQLCODE !=0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END IF
       END IF
    END IF
}
    -- �µ��I����ú�O�O,�s���I != ��ú �B�z --
    IF p_old_cp_disb_type ="2"      AND
       p_data_s1.cp_disb_type !="2" THEN

       -- �R�����g��ܩ�ú����� --
       -- �����ú�O�O��J�L�i�O��{��,�\��Ѯe�ڴ���,�{����b p9610.4gl --
       LET p_pc961_data.policy_no    =p_data_s1.policy_no
       LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pc961_data.prss_code    ="DELE"
       LET p_pc961_data.tran_date    =p_tran_date
       LET p_pc961_data.cp_pay_amt   =0
       LET p_pc961_sw=TRUE
       LET p_pc961_msg=""
       CALL pc961_process(p_pc961_data.*,p_benf_relation)
            RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
       IF p_pc961_sw=FALSE THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF

       {
       UPDATE pcps    
       SET    process_ind="0"
             ,tran_date  =p_tx_date  
             ,process_date=p_tx_date
       WHERE  policy_no=p_data_s1.policy_no
       AND    cp_anniv_date=p_data_s1.cp_anniv_date

       IF SQLCA.SQLCODE !=0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
       }

    END IF
 
    IF p_data_s1.cp_disb_type ="2"   THEN
       -- ��ú��Ʀs�� --
       -- �����ú�O�O��J�L�i�O��{��,�\��Ѯe�ڴ���,�{����b p9610.4gl --
       LET p_pc961_data.policy_no    =p_data_s1.policy_no
       LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pc961_data.prss_code    ="SAVE"
       LET p_pc961_data.tran_date    =p_tran_date
       LET p_pc961_data.cp_pay_amt   =0
       LET p_pc961_sw=TRUE
       LET p_pc961_msg=""
       CALL pc961_process(p_pc961_data.*,p_benf_relation)
            RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
       IF p_pc961_sw=FALSE THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF

       {

       LET p_pcps.policy_no    =p_data_s1.policy_no
       LET p_pcps.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pcps.cp_sw        =p_cp_sw
       LET p_pcps.cp_prem      =0
       LET p_pcps.process_ind  =" "
       LET p_pcps.tran_date    =p_tx_date
       LET p_pcps.process_date =p_tx_date

       INSERT INTO pcps
       VALUES (p_pcps.*)

       IF SQLCA.SQLCODE !=0 THEN
          ROLLBACK WORK
          LET  f_rcode=1
          RETURN f_rcode
       END IF
       }

    END IF

    IF length(p_cp_notice_code CLIPPED)=0 THEN
       LET f_cp_notice_sw=p_pscb.cp_notice_sw
    END IF

    IF p_cp_notice_code="0" OR
       p_cp_notice_code="3" THEN
       LET f_cp_notice_sw="2"
    END IF

    IF p_cp_notice_code="2" THEN
       LET f_cp_notice_sw="3"
    END IF

    IF p_cp_notice_code="1" THEN
       IF p_cp_notice_sub_code="0" THEN
          LET f_cp_notice_sw="2"
       END IF
    END IF

    UPDATE pscb
    SET    cp_disb_type    =p_data_s1.cp_disb_type
          ,mail_addr_ind   =p_data_s1.mail_addr_ind
          ,disb_special_ind=p_data_s1.disb_special_ind
	  ,cp_rtn_sw	   =p_data_s1.cp_rtn_sw
          ,change_date     =p_tx_date       
          ,process_date    =p_tx_date
          ,process_user    =g_user
          ,cp_notice_sw    =f_cp_notice_sw
          ,cp_pay_name     =p_data_s1.cp_pay_name
          ,cp_pay_id       =p_data_s1.cp_pay_id
          ,dept_code       =p_dept_code
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    END IF
 
   --cmwang SR130800093 ADD
   IF p_data_s1.cp_disb_type = "4" THEN
      CALL nonresp_sw_add()  RETURNING f_rcode 
      IF f_rcode THEN 
         display " nonresp_sw_add() ���~"
	 LET f_rcode = 1 
	 RETURN f_rcode 
      END IF 
   END IF 
   
   --cmwang END 

   --yirong 102/10�M�ת��A���L��,�ðe�XBPM
   IF p_psbh_cnt > 0 THEN

      SELECT *
        INTO g_psbh.*
        FROM psbh
       WHERE policy_no    =p_data_s1.policy_no
         AND cp_anniv_date=p_data_s1.cp_anniv_date
         AND cp_rtn_sts = '0'  
         AND cp_rtn_type = '2'    --�Ⱥ����ݭn��窱�A
      
      IF STATUS = NOTFOUND THEN
      ELSE 
      
         LET g_nbbk_cnt = 0
         FOR f_i = 1 TO 3
             INITIALIZE      g_nbbk_arr[f_i].*        TO      NULL
         END FOR
         LET f_i = 1
         DECLARE nbbk_cur CURSOR WITH HOLD FOR
            SELECT *
              FROM nbbk
             WHERE divback_type = '3'
               AND close_ind = '0'
               AND join_policy_no = g_psbh.policy_no
               AND cp_anniv_date = g_psbh.cp_anniv_date
             ORDER BY policy_no
         FOREACH  nbbk_cur INTO g_nbbk_arr[f_i].*
             LET f_i = f_i + 1
         END FOREACH
         LET g_nbbk_cnt = f_i - 1
     
         CALL upd_sts_psbh('0')
         FOR f_i = 1 TO g_nbbk_cnt
             CALL upd_sts_nbbk('0',f_i,p_tx_date)

             CALL psl01s3_bpm_comment(g_nbbk_arr[f_i].policy_no,p_tran_date,g_psbh.*,'�ܧ󵹥I�覡(�L��)')
                  RETURNING f_rcode,f_msg

             IF NOT f_rcode THEN
                ERROR 'error sent Fail to BPM' ATTRIBUTE(RED ,REVERSE)
--              ROLLBACK WORK
             END IF

         END FOR
      END IF
   END IF
   
--display p_data_s1.cp_disb_type,'===',p_online_prc
    IF p_data_s1.cp_disb_type ="1" AND p_online_prc = '1'  THEN
--display  'psc30s01'
       LET g_online_sw = '1'   
       CALL psc30s01(p_tran_date,p_tran_date,p_tran_date
                    ,p_data_s1.policy_no,p_data_s1.cp_anniv_date)
       RETURNING f_rcode
       IF f_rcode  THEN
display "ONLINE�L�b���~!!"
       ELSE
--display "OK"
       END IF
    END IF
 
    --SR140800458
    IF p_upd_psck="Y" THEN
       IF psca01s_promptSave( "�H���^����覡�^�ЬO�_�����i*�j?" ) THEN
          UPDATE  psck
          SET     nonresp_sw = " "
          WHERE   policy_no = p_policy_no
          AND     cp_anniv_date = p_cp_anniv_date
          IF SQLCA.SQLCODE != 0 THEN
             ROLLBACK WORK
             CALL err_touch("�������O����")
          END IF
       END IF
    END IF

--    IF p_upd_psck != "Y" THEN
    SELECT  COUNT(*)
    INTO    f_nonresp_cnt 
    FROM    psck
    WHERE   policy_no = p_data_s1.policy_no 
    AND     nonresp_sw = "Y"
    LET f_prompt_ans = "Y"
    IF f_nonresp_cnt = 0 THEN
       CALL ap905_update_sts(p_data_s1.po_chg_rece_no,'5')
    END IF 
    IF f_nonresp_cnt > 0 THEN
       PROMPT "���ɧ����A���z�y�{�O�_����?(Y/N)" FOR CHAR f_prompt_ans
       IF UPSHIFT( f_prompt_ans ) = "Y" THEN 
          CALL ap905_update_sts(p_data_s1.po_chg_rece_no,'5')
       END IF
    END IF
       
--    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psd01m_save_data --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_benf
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��^�Ч@�~,���q�H�T�{
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benf()
    DEFINE f_rcode    INTEGER
          ,f_i        INTEGER

    LET INT_FLAG=FALSE
    LET f_rcode=0

    IF  p_data_s1.cp_disb_type !="3" THEN
        LET f_rcode=0
        RETURN f_rcode
    END IF

    -- 100/03/31 MODIFY
    IF g_polf.currency = 'TWD' THEN
       MESSAGE " END(F7):�����@�~!!"
    ELSE
       MESSAGE " (F6)�s��~���״ڱb��  (F7):�����@�~  (ESC)�s��"       
    END IF
    -- 100/03/31 END
    
    OPEN WINDOW psc01m_benf AT 6,01 WITH FORM "psc01m03"
    ATTRIBUTE (GREEN, FORM LINE FIRST,PROMPT LINE LAST)

    DISPLAY p_policy_no      TO policy_no
            ATTRIBUTE (YELLOW)

    -- 100/03/31 MODIFY
    IF g_polf.currency = 'TWD' THEN
       CALL psc01m_edit_benf_dsp()
            RETURNING f_rcode
    ELSE
       CALL psc01m_edit_benp_dsp()    
            RETURNING f_rcode      
    END IF
    -- 100/03/31 END

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "����J!!"
       WHEN f_rcode = 0
          ERROR "���q�H�@�~����!!"
       WHEN f_rcode = 1
          ERROR "benf �R������ !!"
       WHEN f_rcode = 2
          ERROR "benf �s�W���� !!"
    END CASE

    CLOSE WINDOW psc01m_benf

    RETURN f_rcode
END FUNCTION -- psc01m_edit_benf --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_benf_dsp
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��^�Ч@�~,�T�{
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benf_dsp()

    DEFINE f_rcode         INTEGER
          ,f_i             INTEGER
          ,f_coverage_no   INTEGER
          ,f_arr_cur       INTEGER
          ,f_scr_cur       INTEGER
          ,f_remit_bank    CHAR(3)
          ,f_chk_remit_err CHAR(1)
          ,f_chk_remit_msg CHAR(255)
 	
    DEFINE f_bank_code  LIKE    bank.bank_code
    DEFINE f_data_length INT

    LET f_rcode = 0
    LET f_chk_remit_err="0"
    LET f_chk_remit_msg=""

    FOR f_i=1 TO 99
        LET  p_benf[f_i].client_id      =" "
        LET  p_benf[f_i].benf_ratio     =0
        LET  p_benf[f_i].remit_bank     =" "
        LET  p_benf[f_i].remit_branch   =" "
        LET  p_benf[f_i].remit_account  =" "
        LET  p_benf[f_i].benf_order     =" "
        LET  p_benf[f_i].names          =" "
    END FOR

    FOR f_i=1 TO p_benf_cnt
        LET  p_benf[f_i].client_id      =p_data_s2[f_i].client_id
        LET  p_benf[f_i].benf_ratio     =p_data_s2[f_i].benf_ratio
        LET  p_benf[f_i].remit_bank     =p_data_s2[f_i].remit_bank
        LET  p_benf[f_i].remit_branch   =p_data_s2[f_i].remit_branch
        LET  p_benf[f_i].remit_account  =p_data_s2[f_i].remit_account
        LET  p_benf[f_i].benf_order     =p_data_s2[f_i].benf_order
        LET  p_benf[f_i].names          =p_data_s2[f_i].names
        LET  p_benf[f_i].bank_name      =p_data_s2_b[f_i].bank_name
    END FOR

    CALL SET_COUNT(p_benf_cnt)

    INPUT ARRAY p_benf WITHOUT DEFAULTS
    FROM  psbenf.*
    BEFORE ROW
           LET f_arr_cur = ARR_CURR()
           LET f_scr_cur = SCR_LINE()
    AFTER FIELD remit_bank
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_bank=" " THEN
                ERROR "�״ڻȦ楲����J!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END IF
             SELECT DISTINCT bank_code[1,3]
             INTO   f_remit_bank
             FROM   bank
             WHERE  bank_code[1,3]= p_benf[f_arr_cur].remit_bank

             IF STATUS = NOTFOUND THEN
                ERROR "�п�J���T�Ȧ�N�X !!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END IF
             LET f_data_length = 0 
             SELECT data_length
               INTO f_data_length
               FROM dbac
              WHERE remit_bank = f_remit_bank
             IF STATUS = NOTFOUND THEN
                LET f_data_length = 0
             END IF  

          ELSE
            NEXT FIELD remit_branch
          END IF

    AFTER FIELD remit_branch
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_branch=" " THEN
                ERROR "�״ڤ��楲����J!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_branch
             END IF

          ELSE
             NEXT FIELD remit_account
          END IF

          LET f_bank_code=p_benf[f_arr_cur].remit_bank,p_benf[f_arr_cur].remit_branch

          SELECT bank_name INTO p_benf[f_arr_cur].bank_name
          FROM   bank
          WHERE  bank_code=f_bank_code

          LET p_benf[f_arr_cur].bank_name=p_benf[f_scr_cur].bank_name CLIPPED
          DISPLAY p_benf[f_arr_cur].bank_name to psbenf[f_scr_cur].bank_name


    AFTER FIELD remit_account
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_account=" " THEN
                ERROR "�״ڱb��������J!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_account
             END IF

             CALL chkRemitAcct (p_benf[f_arr_cur].remit_bank
                               ,p_benf[f_arr_cur].remit_branch
                               ,p_benf[f_arr_cur].remit_account
                               )
                  RETURNING f_chk_remit_err,f_chk_remit_msg
             IF f_chk_remit_err !="0" THEN
                ERROR f_chk_remit_msg
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END If
             IF f_data_length > 0 THEN
                IF LENGTH(p_benf[f_arr_cur].remit_account) != f_data_length THEN
                   ERROR "�״ڱb�����צ��~!!"
                   ATTRIBUTE (RED)
                   NEXT FIELD remit_account
                END IF
             END IF  
          END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT

    AFTER ROW

       IF (p_benf[f_arr_cur].client_id =" "   AND
           p_benf[f_arr_cur].names     =" " ) AND
          (p_benf[f_arr_cur].remit_bank !=" "     OR
           p_benf[f_arr_cur].remit_branch  !=" "  OR
           p_benf[f_arr_cur].remit_account !=" ") THEN
                ERROR "�״ڻȦ�,�״ڤ���,�״ڱb����������J!!"
                      ATTRIBUTE (RED)
       END IF
       IF p_benf[f_arr_cur].remit_bank !=" "    OR
          p_benf[f_arr_cur].remit_branch !=" "  OR
          p_benf[f_arr_cur].remit_account !=" " THEN

          CALL chkRemitAcct (p_benf[f_arr_cur].remit_bank
                            ,p_benf[f_arr_cur].remit_branch
                            ,p_benf[f_arr_cur].remit_account
                            )
               RETURNING f_chk_remit_err,f_chk_remit_msg
          IF f_chk_remit_err !="0" THEN
             ERROR f_chk_remit_msg
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF
       END IF

    END INPUT

    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF


 #  LET p_benf_cnt = ARR_COUNT()


    BEGIN WORK
    WHENEVER ERROR CONTINUE

    DELETE FROM benf
    WHERE  policy_no   = p_policy_no
    AND    relation    = p_benf_relation

    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    END IF

    LET f_coverage_no=0
    FOR f_i = 1 TO p_benf_cnt
        IF p_benf[f_i].client_id <> " " THEN
           INSERT INTO benf VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,""
                                  ,p_benf[f_i].benf_order
                                  ,p_benf[f_i].benf_ratio
                                  ,p_benf[f_i].remit_bank
                                  ,p_benf[f_i].remit_branch
                                  ,p_benf[f_i].remit_account
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,"" 
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
        ELSE
           INSERT INTO benf VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,p_benf[f_i].names
                                  ,p_benf[f_i].benf_order
                                  ,p_benf[f_i].benf_ratio
                                  ,p_benf[f_i].remit_bank
                                  ,p_benf[f_i].remit_branch
                                  ,p_benf[f_i].remit_account
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,"" 
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
        END IF
    END FOR

    COMMIT WORK

    FOR f_i=1 TO p_benf_cnt
        LET  p_data_s2[f_i].client_id      =p_benf[f_i].client_id
        LET  p_data_s2[f_i].benf_ratio     =p_benf[f_i].benf_ratio
        LET  p_data_s2[f_i].remit_bank     =p_benf[f_i].remit_bank
        LET  p_data_s2[f_i].remit_branch   =p_benf[f_i].remit_branch
        LET  p_data_s2[f_i].remit_account  =p_benf[f_i].remit_account
        LET  p_data_s2[f_i].benf_order     =p_benf[f_i].benf_order
        LET  p_data_s2[f_i].names          =p_benf[f_i].names

    END FOR

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_benf_dsp --

-- 100/03/31 ADD
------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_benp_dsp
--  �B�z���n: �٥��^�Ч@�~,�s��~�����q�H�״ڸ��
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benp_dsp()

    DEFINE f_rcode            INTEGER
          ,f_i                INTEGER
          ,f_coverage_no      INTEGER
          ,f_arr_cur          INTEGER
          ,f_cancel           INTEGER   -- �����@�~
          ,f_ans_sw           CHAR(1)   -- prompt ���^�� --
          ,f_bank_code        LIKE benp.bank_code
          ,f_bank_name        LIKE bank.bank_name
          ,f_chk_account_sw   CHAR(1)   -- �ˬd�״ڱb������
	  ,f_scr_cur          INTEGER 
              
    LET f_rcode          = 0
    LET f_cancel         = 0      
    LET f_ans_sw         = ''
    
    
    FOR f_i=1 TO 99
        LET  p_benf[f_i].client_id                =" "
        LET  p_benf[f_i].benf_ratio               =0
        LET  p_benf[f_i].remit_bank               =" "
        LET  p_benf[f_i].remit_branch             =" "
        LET  p_benf[f_i].remit_account            =" "
        LET  p_benf[f_i].benf_order               =" "
        LET  p_benf[f_i].names                    =" "
        LET  p_benf[f_i].bank_name                =" "
        
        LET  p_benp_ext[f_i].payee                =" "
        LET  p_benp_ext[f_i].remit_swift_code     =" "
        LET  p_benp_ext[f_i].remit_bank_name      =" "
        LET  p_benp_ext[f_i].remit_bank_address   =" "
    END FOR

    FOR f_i=1 TO p_benf_cnt

        LET  p_benf[f_i].client_id                =p_data_s2[f_i].client_id
        LET  p_benf[f_i].benf_ratio               =p_data_s2[f_i].benf_ratio
        LET  p_benf[f_i].remit_bank               =p_data_s2[f_i].remit_bank
        LET  p_benf[f_i].remit_branch             =p_data_s2[f_i].remit_branch
        LET  p_benf[f_i].remit_account            =p_data_s2[f_i].remit_account
        LET  p_benf[f_i].benf_order               =p_data_s2[f_i].benf_order
        LET  p_benf[f_i].names                    =p_data_s2[f_i].names
        LET  p_benf[f_i].bank_name                =p_data_s2_b[f_i].bank_name
        
        LET  p_benp_ext[f_i].payee                =p_data_s2_c[f_i].payee
        LET  p_benp_ext[f_i].remit_swift_code     =p_data_s2_c[f_i].remit_swift_code
        LET  p_benp_ext[f_i].remit_bank_name      =p_data_s2_c[f_i].remit_bank_name
        LET  p_benp_ext[f_i].remit_bank_address   =p_data_s2_c[f_i].remit_bank_address

    END FOR

    CALL SET_COUNT(p_benf_cnt)

    WHILE(TRUE)
      DISPLAY ARRAY p_benf TO  psbenf.*
      
      ON KEY (F6) -- �s��~���״ڱb��
      
         LET f_arr_cur = ARR_CURR()
	 LET f_scr_cur = SCR_LINE()

         -- ��l��
         INITIALIZE g_dbdd.* TO NULL  
         LET g_dbdd.disb_fee_ind        = '1'                             -- ����O��1:�I�ڤH�t��
         LET g_dbdd.payee_id            = p_benf[f_arr_cur].client_id     -- �n�]�wg_dbdd��ID�A�_�h����O�|�w�]��2
         -- �s��~���b�� -- 
         CALL payforeign(p_policy_no, p_benf[f_arr_cur].client_id, "1", "1", 6, 6)
         -- �b�s��~���b�᪺�L�{���A�Q�Τ��Ψ禡�i��~���b���ˮ֡A�N�̫��J���T�X�k���b���ưO����g_dbdd.*��
         -- ���O�Y���~�����A�ӵ���Ʒ|�Q�M�šA����{�����|�i���ˮ֥~���b��A�|�y���b��ťիo�s�J�ɮ�benp��
         -- �ҥH�W�[�@�ӱ���O:�Y�ϥΪ̨����s�����@�����q�H�~���״ڱb���A�h�N�n�����Ҧ��s��
         -- �קK�i��y���Y�Ө��q�H�~���״ڱb�����ťժ��|�}
         IF INT_FLAG = TRUE THEN
         	  LET f_cancel = 1
            EXIT DISPLAY
         END IF
         
         -- �ˬd:���i�H�ק�client_id
         IF g_dbdd.payee_id <> p_benf[f_arr_cur].client_id THEN
            ERROR "���i�H�ק���q�HID�A�Э��s��J!"
            
         ELSE
            -- �ˬd:���i�H�ק����O����
            IF g_dbdd.disb_fee_ind <> '1' THEN
               ERROR "���i�H�ק����O���ܡA�Э��s��J!"
            ELSE
               -- ��swift_code������״ڻȦ�/����/�Ȧ椤��W��
               SELECT bksw.bank_code, bank.bank_name
                 INTO f_bank_code, f_bank_name
                 FROM bksw , OUTER bank
                WHERE bksw.swift_code   = g_dbdd.remit_swift_code
                  AND bksw.bank_use_ind = "Y"
                  AND bksw.bank_code    = bank.bank_code
                  
               IF STATUS = NOTFOUND THEN
               	  ERROR "swift_code�L�����״ڦ�A�Э��s��J!"
               ELSE
               	  -- �N�ӵ��~�������ܨ�e���W
               	  LET p_benf[f_arr_cur].remit_bank     = f_bank_code[1,3]
               	  LET p_benf[f_arr_cur].remit_branch   = f_bank_code[4,7]
                  LET p_benf[f_arr_cur].remit_account  = g_dbdd.remit_account
                  LET p_benf[f_arr_cur].names          = g_dbdd.payee_cht
                  LET p_benf[f_arr_cur].bank_name      = f_bank_name   

                  DISPLAY p_benf[f_arr_cur].remit_bank     TO psbenf[f_scr_cur].remit_bank        
                  DISPLAY p_benf[f_arr_cur].remit_branch   TO psbenf[f_scr_cur].remit_branch              
                  DISPLAY p_benf[f_arr_cur].remit_account  TO psbenf[f_scr_cur].remit_account
                  DISPLAY p_benf[f_arr_cur].names          TO psbenf[f_scr_cur].names
                  DISPLAY p_benf[f_arr_cur].bank_name      TO psbenf[f_scr_cur].bank_name   

                  -- �x�s�״ڱb�����
                  LET p_benp_ext[f_arr_cur].payee         �@�@ = g_dbdd.payee         �@�@�@      
                  LET p_benp_ext[f_arr_cur].remit_swift_code   = g_dbdd.remit_swift_code
                  LET p_benp_ext[f_arr_cur].remit_bank_name    = g_dbdd.remit_bank_name     
                  LET p_benp_ext[f_arr_cur].remit_bank_address = g_dbdd.remit_bank_address
               END IF
            END IF
         END IF
         
      ON KEY (F7) -- �����@�~
         LET INT_FLAG = TRUE
         LET f_cancel = 1
         EXIT DISPLAY
         
      ON KEY (ESC) -- �s�ɧ@�~
      	 
      	 -- �ˬd�״ڱb�����
      	 LET f_chk_account_sw = 1
         FOR f_i = 1 TO p_benf_cnt
            IF LENGTH(p_benf[f_i].remit_account)= 0 THEN
               ERROR "�b��ťդ��i�H�s��!" 
               LET f_chk_account_sw = 0
               EXIT FOR
            END IF
         END FOR
         
         -- �״ڱb����Ƥ����ťդ~�i�H�s��
         IF f_chk_account_sw = 1 THEN
            LET INT_FLAG = TRUE
            EXIT DISPLAY
         END IF
      END DISPLAY

      -- �P�_�O�_�n�~����ܵe��
      IF INT_FLAG = TRUE THEN    -- ���}����
         IF f_cancel = 0 THEN    -- �Y�D�����@�~�A�h�n�T�{�O�_�s��
            LET f_ans_sw=" "
            PROMPT "�T�{�s�ɽЫ� Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
                   ATTRIBUTE (YELLOW)
            IF UPSHIFT(f_ans_sw) ="Y" THEN
               LET INT_FLAG = FALSE
            END IF
    	   END IF 
    	   EXIT WHILE             
      END IF   
    END WHILE

    -- �ϥΪ̨���
    IF INT_FLAG = TRUE THEN
       RETURN f_rcode
    ELSE
       -- ��sbenp�ɮ�
       BEGIN WORK
       WHENEVER ERROR CONTINUE
       
       DELETE FROM benp
       WHERE  policy_no   = p_policy_no
       AND    relation    = p_benf_relation
       
       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
       
       LET f_coverage_no=0
       FOR f_i = 1 TO p_benf_cnt
           
           LET f_bank_code = p_benf[f_i].remit_bank,p_benf[f_i].remit_branch
           
           INSERT INTO benp VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,p_benf[f_i].names
                                  ,f_bank_code
                                  ,p_benp_ext[f_i].remit_swift_code
                                  ,p_benp_ext[f_i].remit_bank_name
                                  ,p_benf[f_i].remit_account
                                  ,p_benp_ext[f_i].payee 
                                  ,p_benp_ext[f_i].remit_bank_address
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
           
       END FOR
       
       COMMIT WORK
       
       FOR f_i=1 TO p_benf_cnt
       
           -- ��sbenp��ƨ�e��
           LET  p_data_s2[f_i].client_id      =p_benf[f_i].client_id
           LET  p_data_s2[f_i].benf_ratio     =p_benf[f_i].benf_ratio
           LET  p_data_s2[f_i].remit_bank     =p_benf[f_i].remit_bank
           LET  p_data_s2[f_i].remit_branch   =p_benf[f_i].remit_branch
           LET  p_data_s2[f_i].remit_account  =p_benf[f_i].remit_account
           LET  p_data_s2[f_i].benf_order     =p_benf[f_i].benf_order
           LET  p_data_s2[f_i].names          =p_benf[f_i].names
           LET  p_data_s2_b[f_i].bank_name    =p_benf[f_i].bank_name
           
           -- �x�s�״ڱb�����
           LET  p_data_s2_c[f_i].payee              = p_benp_ext[f_i].payee              
           LET  p_data_s2_c[f_i].remit_swift_code   = p_benp_ext[f_i].remit_swift_code 
           LET  p_data_s2_c[f_i].remit_bank_name    = p_benp_ext[f_i].remit_bank_name     
           LET  p_data_s2_c[f_i].remit_bank_address = p_benp_ext[f_i].remit_bank_address 
       END FOR
       
       
       RETURN f_rcode
       WHENEVER ERROR STOP
       
    END IF
END FUNCTION -- psc01m_edit_benp_dsp --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_pscy
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscy()
 DEFINE f_rcode  INTEGER

    LET f_rcode=0

    MESSAGE " END:�����@�~" ATTRIBUTE (WHITE)

    OPEN WINDOW psc00m_pscy AT 9,01 WITH FORM "psc00m12"
    ATTRIBUTE (GREEN,FORM LINE FIRST,PROMPT LINE LAST,MESSAGE LINE LAST)

    CALL psc01m_edit_pscy_dsp()
         RETURNING f_rcode

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "����J!!"
       WHEN f_rcode = 0
          ERROR "�q�׫��ܧ@�~����!!"
      WHEN f_rcode = 1
          ERROR "pscy ��s���� !!"
       WHEN f_rcode = 2
          ERROR "pscy �s�W���� !!"
    END CASE

    CLOSE WINDOW psc00m_pscy
    RETURN f_rcode
 
END FUNCTION -- psc01m_edit_pscy --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_pscy_dsp
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscy_dsp()

    DEFINE f_rcode      INTEGER
          ,f_ans_sw     CHAR(1)   -- prompt ���^�� --

    DEFINE f_pscy       RECORD  
                        payee                LIKE pscy.payee           
                       ,client_id            LIKE pscy.client_id       
                       ,swift_code           LIKE pscy.swift_code
                       ,bank_name            CHAR(30)  
                       ,bank_code            LIKE pscy. bank_code     
                       ,bank_name_e          LIKE pscy.bank_name_e     
                       ,bank_account_e       LIKE pscy.bank_account_e  
                       ,payee_e              LIKE pscy.payee_e         
                       ,bank_address_e       LIKE pscy.bank_address_e  
                       ,ed                   CHAR(2)
                         END RECORD


    LET f_rcode     =0
    INITIALIZE f_pscy.* TO NULL
    
    -- ����X��Ӫ�pscy
    SELECT pscy.payee, 
           pscy.client_id,
           pscy.swift_code,
           pscy.bank_code,
           pscy.bank_name_e,
           pscy.bank_account_e,
           pscy.payee_e,
           pscy.bank_address_e,
           bank.bank_name[1,30]
      INTO f_pscy.payee, 
           f_pscy.client_id, 
           f_pscy.swift_code,
           f_pscy.bank_code, 
           f_pscy.bank_name_e,
           f_pscy.bank_account_e, 
           f_pscy.payee_e, 
           f_pscy.bank_address_e,
           f_pscy.bank_name
    FROM   pscy, OUTER bank
    WHERE  pscy.policy_no     = p_data_s1.policy_no
    AND    pscy.cp_anniv_date = p_data_s1.cp_anniv_date
    AND    pscy.bank_code     = bank.bank_code
    
    LET f_pscy.ed='F8'
    INPUT BY NAME f_pscy.*  WITHOUT DEFAULTS
    	    
    ON KEY (F8)
    	     -- ��l��
           INITIALIZE g_dbdd.* TO NULL  
              
           -- �s��~���b�� -- 
           CALL payforeign(p_policy_no, '', "1", "1", 6, 6)
      
           -- �Y�ϥΪ̧����~���b��s��A�N�ӵ��~�������ܨ�e���W
           IF INT_FLAG = FALSE THEN      
              LET f_pscy.payee            =   g_dbdd.payee_cht  
              LET f_pscy.client_id        =   g_dbdd.payee_id       
              LET f_pscy.swift_code       =   g_dbdd.remit_swift_code
              LET f_pscy.bank_name_e      =   g_dbdd.remit_bank_name   
              LET f_pscy.bank_account_e   =   g_dbdd.remit_account
              LET f_pscy.payee_e          =   g_dbdd.payee
              LET f_pscy.bank_address_e   =   g_dbdd.remit_bank_address
              
              -- ��swift_code������bank_code
              SELECT bksw.bank_code, bank.bank_name[1,30]
                INTO f_pscy.bank_code, f_pscy.bank_name 
                FROM bksw , bank
               WHERE bksw.swift_code   = g_dbdd.remit_swift_code
                 AND bksw.bank_use_ind = "Y"
                 AND bksw.bank_code    = bank.bank_code
                 
              IF STATUS = NOTFOUND THEN 
                 LET f_pscy.bank_code= " "
                 LET f_pscy.bank_name= " "
              END IF    
          END IF
           
           
    AFTER INPUT
       IF INT_FLAG = TRUE THEN
          EXIT INPUT
       END IF

       -- �ˬd�~���b���n����
    	 IF LENGTH(f_pscy.bank_account_e CLIPPED)= 0 THEN
    	 	  ERROR "�~���b���n���ȡA�Ы�F8���s��J!"
    	 	  LET INT_FLAG = TRUE
    	 	  EXIT INPUT
    	 END IF
    	 
    	 -- �T�{�s��
       LET f_ans_sw=" "
       PROMPT "�T�{�s�ɽЫ� Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
              ATTRIBUTE (YELLOW)
       IF UPSHIFT(f_ans_sw) !="Y" THEN
          LET INT_FLAG = TRUE
    	 	  EXIT INPUT
       END IF

    END INPUT

    -- �ϥΪ̨���
    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF

    -- ��sbenp�ɮ�    
    BEGIN WORK
    WHENEVER ERROR CONTINUE

    DELETE FROM pscy
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
       
    INSERT INTO pscy VALUES( p_data_s1.policy_no
                            ,p_data_s1.cp_anniv_date       
                            ,f_pscy.payee             
                            ,f_pscy.client_id         
                            ,f_pscy.bank_code
                            ,f_pscy.swift_code        
                            ,f_pscy.bank_name_e       
                            ,f_pscy.bank_account_e    
                            ,f_pscy.payee_e           
                            ,f_pscy.bank_address_e  
                            )  
    
    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=2
       RETURN f_rcode
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_pscy_dsp() --

-- 100/03/31 END

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_pscs
--  �@    ��: jessica Chang
--  ��    ��: 87/09/09
--  �B�z���n: �٥��q�ׯS����w
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscs()
    DEFINE f_rcode  INTEGER

    LET f_rcode=0

    MESSAGE " END:�����@�~" ATTRIBUTE (WHITE)

    OPEN WINDOW psc01m_pscs AT 10,01 WITH FORM "psc01m04"
    ATTRIBUTE (GREEN,FORM LINE FIRST,PROMPT LINE LAST,MESSAGE LINE LAST)

--    DISPLAY p_data_s1.policy_no ,p_data_s1.cp_anniv_date
--         TO policy_no           ,cp_anniv_date
--            ATTRIBUTE (YELLOW)

    CALL psc01m_edit_pscs_dsp()
         RETURNING f_rcode

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "����J!!"
       WHEN f_rcode = 0
          ERROR "�q�׫��ܧ@�~����!!"
      WHEN f_rcode = 1
          ERROR "pscs ��s���� !!"
       WHEN f_rcode = 2
          ERROR "pscs �s�W���� !!"
    END CASE

    CLOSE WINDOW psc01m_pscs

    RETURN f_rcode

END FUNCTION -- psc01m_edit_pscs --

------------------------------------------------------------------------------
--  �禡�W��: psc01m_edit_pscs_dsp
--  �@    ��: jessica Chang
--  ��    ��: 87/08/04
--  �B�z���n: �٥��^�Ч@�~,�q�ׯS�����
--  ���n�禡:
------------------------------------------------------------------------------

FUNCTION psc01m_edit_pscs_dsp()

    DEFINE f_i          INTEGER
          ,f_rcode      INTEGER
          ,f_pscs_sw    INTEGER
          ,f_ans_sw     CHAR(1)   -- prompt ���^�� --

    DEFINE f_remit_bank CHAR(3)
    DEFINE f_pscs       RECORD  LIKE pscs.*
    DEFINE f_bank_name  LIKE    bank.bank_name
          ,f_bank_code  LIKE    bank.bank_code

    DEFINE f_chk_remit_err CHAR(1)
          ,f_chk_remit_msg CHAR(255)

    DEFINE f_dummy_flag CHAR(2)


    LET f_rcode     =0
    LET f_pscs_sw   ="0"
    LET f_dummy_flag=""
    LET f_bank_name =""
    LET f_bank_code =""
    LET f_chk_remit_err="0"
    LET f_chk_remit_msg=""

    SELECT * INTO f_pscs.*
    FROM   pscs
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    IF STATUS = NOTFOUND THEN
       LET f_pscs_sw="0"
       LET f_pscs.policy_no    =p_data_s1.policy_no
       LET f_pscs.cp_anniv_date=p_data_s1.cp_anniv_date
       LET f_pscs.payee        =""
       LET f_pscs.client_id    =""
       LET f_pscs.remit_bank   =""
       LET f_pscs.remit_branch =""
       LET f_pscs.remit_account=""
    ELSE
       LET f_pscs_sw="1"
       LET f_bank_code=f_pscs.remit_bank,f_pscs.remit_branch

       SELECT bank_name INTO f_bank_name
       FROM   bank
       WHERE  bank_code=f_bank_code

       LET f_bank_name=f_bank_name 
       DISPLAY f_bank_name to bank_name

    END IF

    INPUT f_pscs.client_id
         ,f_pscs.payee
         ,f_pscs.remit_bank
         ,f_pscs.remit_branch
         ,f_pscs.remit_account
    WITHOUT DEFAULTS
    FROM  client_id
         ,payee
         ,remit_bank
         ,remit_branch
         ,remit_account
    ATTRIBUTE (YELLOW,UNDERLINE)

    AFTER FIELD client_id
          LET f_pscs.client_id=UPSHIFT(f_pscs.client_id)
          IF length(f_pscs.client_id	CLIPPED )=0 THEN
             ERROR "���ڤH������J!!"
                   ATTRIBUTE (RED)
             NEXT FIELD client_id
          ELSE
             SELECT names
             INTO   f_pscs.payee
             FROM   clnt
             WHERE  client_id=f_pscs.client_id
             IF STATUS = NOTFOUND THEN
                LET f_pscs.payee=""
             ELSE
                LET f_pscs.payee=f_pscs.payee CLIPPED
             END IF
             DISPLAY f_pscs.client_id TO client_id
             DISPLAY f_pscs.payee TO payee
          END IF

    AFTER FIELD payee
          IF f_pscs.payee =" "     OR
             f_pscs.payee IS NULL  THEN
             ERROR "���ڤH������J!!"
                   ATTRIBUTE (RED)
             NEXT FIELD payee
          ELSE
              LET f_pscs.payee=f_pscs.payee CLIPPED
          END IF

    AFTER FIELD remit_bank
          IF f_pscs.remit_bank=" "     OR
             f_pscs.remit_bank IS NULL  THEN
             ERROR "�q�׻Ȧ楲����J!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF

          SELECT DISTINCT bank_code[1,3]
          INTO   f_remit_bank
          FROM   bank
          WHERE  bank_code[1,3]= f_pscs.remit_bank

          IF STATUS = NOTFOUND THEN
             ERROR "�п�J���T�Ȧ�N�X !!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF
--          NEXT FIELD remit_branch

    AFTER FIELD remit_branch
          IF f_pscs.remit_branch=" "      OR
             f_pscs.remit_branch=""       THEN
             ERROR "�q�פ��楲����J!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_branch
          END IF

          LET f_bank_code=f_pscs.remit_bank,f_pscs.remit_branch
          
          SELECT bank_name INTO f_bank_name
          FROM   bank
          WHERE  bank_code=f_bank_code

          LET f_bank_name=f_bank_name CLIPPED
          DISPLAY f_bank_name to bank_name
--          NEXT FIELD remit_account

    AFTER FIELD remit_account
          IF f_pscs.remit_account=" "     OR
             f_pscs.remit_account IS NULL  THEN
             ERROR "�q�ױb��������J!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_account
          END IF

          CALL chkRemitAcct (f_pscs.remit_bank
                            ,f_pscs.remit_branch
                            ,f_pscs.remit_account
                            )
               RETURNING f_chk_remit_err,f_chk_remit_msg
          IF f_chk_remit_err="0" THEN
             LET f_dummy_flag="ok"
          ELSE
             ERROR f_chk_remit_msg ATTRIBUTE(RED)
             NEXT FIELD remit_bank
          END IF

    AFTER INPUT
       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET f_ans_sw=" "
       PROMPT "�T�{�s�ɽЫ� Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
              ATTRIBUTE (YELLOW)
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD payee
       END IF

    END INPUT

    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    -- �s�W --
    IF f_pscs_sw="0" THEN

       INSERT INTO pscs VALUES(f_pscs.*)

       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=2
          RETURN f_rcode
       END IF
    END IF

    -- ��s --
    IF f_pscs_sw="1" THEN
       UPDATE pscs
       SET    payee        =f_pscs.payee
             ,client_id    =f_pscs.client_id
             ,remit_bank   =f_pscs.remit_bank
             ,remit_branch =f_pscs.remit_branch
             ,remit_account=f_pscs.remit_account
       WHERE  policy_no    =f_pscs.policy_no
       AND    cp_anniv_date=f_pscs.cp_anniv_date

       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_pscs_dsp() --

------------------------------------------------------------------------------
--  �禡�W��: psc00m_sel_2
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: ��ܳB�z�٥��B�z�浧���^�Ъ����
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_2()
    DEFINE f_rcode INTEGER
    DEFINE f_polf_exist      INTEGER  -- �O���ˮ� --
          ,f_pscb_exist      INTEGER  -- �٥����ˮ� --
          ,f_chkdate_sw      INTEGER  -- ����ˮ� --
          ,f_format_date     CHAR(9)  -- �榡�ƪ���� --

    DEFINE f_ins_pscn        CHAR(1)  --  N:���� pscn ���@
          ,f_call_psc00m00   CHAR(1)  --  N:�i�J���
          ,f_psc00m00_rcode  CHAR(1)

    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""

    MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date TO policy_no,cp_anniv_date

    INPUT p_policy_no,p_cp_anniv_date FROM
          policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7")

                IF f_pscb_exist =0 THEN
                   ERROR "�٥��ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "�浧���^�Ч@�~��� !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m01
       RETURN
    END IF

    CLOSE WINDOW w_psc00m01

    LET p_act_return_date=p_tran_date
    LET p_cp_notice_code="2"
    LET p_data_s1.cp_disb_type="4"

    CALL psc00m00_input() RETURNING f_rcode
    -- ����^�Ъ���Ƥ��s,���} --
    IF f_rcode =1 THEN
       ERROR "�^�и��,�����Ʃ��@�~ !!"
       LET f_rcode=0
       RETURN
    ELSE
       ERROR "�浧���^�Ч@�~���� !!"
    END IF

    RETURN
END FUNCTION -- psc00m_sel_2 --

------------------------------------------------------------------------------
--  �禡�W��: psc00m_sel_3
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: ���^�и�ƾ��B�z
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_3()
    DEFINE f_rcode           INTEGER
	  ,f_upd_psck_sw     INTEGER
          ,f_ans_sw          CHAR(1)
    DEFINE f_total_cnt       INTEGER  -- �X����󪺸�Ƶ��� --
          ,f_input_date      CHAR(9)  -- ��J����� --
          ,f_chkdate_sw      INTEGER  -- ����ˮ� --
          ,f_format_date     CHAR(9)  -- �榡�ƪ���� --
    DEFINE f_pscb   RECORD LIKE  pscb.*
    DEFINE f_currency CHAR(3)
    DEFINE DateTest CHAR(9)
    DEFINE f_today   CHAR(9)
    DEFINE f_time    CHAR(8)

    LET f_rcode=0
    LET f_upd_psck_sw=0
    LET f_chkdate_sw=true
    LET f_format_date=""
    LET f_total_cnt=0
    LET f_input_date=""
    LET f_ans_sw="N"

    MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m07 AT 10,11 WITH FORM "psc00m07"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    LET f_rcode         =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""

    INPUT f_input_date WITHOUT DEFAULTS FROM
          inp_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD inp_date
                CALL CheckDate(f_input_date   ) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD inp_date
                END IF
                LET f_input_date=f_format_date
            --    DISPLAY "f_format_date:",f_format_date
                CALL AddYear(GetDate(TODAY),-1) RETURNING DateTest
            --    DISPLAY "DateTest:",DateTest
                IF f_format_date >= AddYear(GetDate(TODAY),-1) THEN 
                	ERROR "��J������p��@�~"
                	NEXT FIELD inp_date
                END IF
                
                -- 100/03/31 MODIFY �ư��~���O��A����i���奼�^��
                SELECT count(*) INTO f_total_cnt
                FROM   pscb a,polf b
                WHERE  a.cp_notice_sw="4"
                AND    a.cp_sw in ("1","3","7","8")
                AND    a.cp_anniv_date <= f_input_date
                AND    a.policy_no = b.policy_no
                AND    b.currency ='TWD'
                -- 100/03/31 END
                
                DISPLAY f_total_cnt TO total_cnt

                IF f_total_cnt=0 THEN
                   ERROR "�L�X�G����� !!"
                   NEXT  FIELD inp_date
                END IF

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                CALL CheckDate(f_input_date   ) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD inp_date
                END IF
                LET f_input_date=f_format_date

                -- 100/03/31 MODIFY �ư��~���O��A����i���奼�^��
                SELECT count(*) INTO f_total_cnt
                FROM   pscb a,polf b
                WHERE  a.cp_notice_sw="4"
                AND    a.cp_sw in ("1","3","7","8")
                AND    a.cp_anniv_date <= f_input_date
                AND    a.policy_no = b.policy_no
                AND    b.currency ='TWD'
                -- 100/03/31 END
                
                DISPLAY f_total_cnt TO total_cnt

                IF f_total_cnt=0 THEN
                   ERROR "�L�X�G����� !!"
                   NEXT  FIELD inp_date
                END IF

                LET f_ans_sw=""
                PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
                IF UPSHIFT(f_ans_sw) !="Y" OR
                   f_ans_sw IS NULL        THEN
                   NEXT FIELD inp_date
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "��奼�^�Ч@�~��� !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m07
       RETURN
    END IF

    CLOSE WINDOW w_psc00m07

    ERROR  "��ƳB�z��,�Э@�ߵ��� ........."
           ATTRIBUTE  (RED)

    WHENEVER ERROR CONTINUE

    DECLARE pscb_crs CURSOR WITH HOLD FOR
    	      -- 100/03/31 MODIFY �ư��~���O��A����i���奼�^��
            SELECT a.*
            FROM   pscb a, polf b
            WHERE  a.cp_notice_sw="4"
            AND    a.cp_sw in ("1","3","7","8")
            AND    a.cp_anniv_date <= f_input_date
            AND    a.policy_no = b.policy_no
            AND    b.currency ='TWD'
            -- 100/03/31 END
                
    FOREACH pscb_crs INTO f_pscb.*

        BEGIN WORK
  
	IF upd_psck(f_pscb.policy_no, f_pscb.cp_anniv_date) THEN
	   ROLLBACK WORK
	   EXIT FOREACH
	END IF

        LET f_today = GetDate(TODAY)
        LET f_time = CURRENT HOUR TO SECOND 
        INSERT INTO pscba  VALUES ( f_pscb.policy_no       ,
                                    f_pscb.cp_anniv_date   ,
                                    f_today                ,
                                    f_time                 ,
                                    g_user                 ,
                                    "0"
                                  )
        IF SQLCA.SQLCODE != 0 THEN
           ROLLBACK WORK
           ERROR "insert pscba error on psc00m_sel_3 !!"
           LET f_rcode=1
           EXIT FOREACH 
        END IF 

        UPDATE pscb
        SET    cp_notice_sw="3"
              ,change_date =p_tran_date
              ,process_date=p_tran_date
              ,process_user=g_user
        WHERE  policy_no    =f_pscb.policy_no
        AND    cp_anniv_date=f_pscb.cp_anniv_date

        IF SQLCA.SQLCODE != 0 THEN
           ROLLBACK WORK
           ERROR "update pscb error on psc00m_sel_3 !!"
           LET f_rcode=1
           EXIT FOREACH
        ELSE
           COMMIT WORK
        END  IF
    END FOREACH

    ERROR "��奼�^�л���B�z���� !!"
    RETURN
END FUNCTION -- psc00m_sel_3 --

------------------------------------------------------------------------------
--  �禡�W��: upd_psck
--  �@    ��: Kobe
--  ��    ��: 091/11/11
--  �B�z���n: ����O�ɬ�����奼�^���
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION upd_psck(f_policy_no, f_cp_anniv_date)

    DEFINE f_policy_no		LIKE pscb.policy_no
	  ,f_cp_anniv_date	LIKE pscb.cp_anniv_date

    DEFINE f_psck		RECORD LIKE psck.*

    DEFINE f_upd_psck_sw	INTEGER

    DEFINE f_process_date       CHAR(9)
    	  ,f_process_time       CHAR(8)
          ,f_process_user       CHAR(8)

    DEFINE f_user_code          LIKE edp_base:usrdat.user_code
          ,f_user_id            LIKE edp_base:usrdat.id_code
          ,f_user_name          LIKE edp_base:usrdat.user_name
          ,f_dept_code          LIKE edp_base:usrdat.dept_code


    LET f_process_date = GetDate(TODAY)
    LET f_process_time = TIME
    LET f_process_user = g_user

    CALL GetUserData(g_user)
         RETURNING f_user_code
                  ,f_user_id
                  ,f_user_name
                  ,f_dept_code

    UPDATE pscb
    SET    cp_remark_sw  = "Y"
    WHERE  policy_no     = f_policy_no
    AND    cp_anniv_date = f_cp_anniv_date

    IF SQLCA.SQLCODE != 0 THEN
       ERROR "error :update pscb ",f_policy_no
       RETURN TRUE
    END IF

    SELECT *
    INTO   f_psck.*
    FROM   psck
    WHERE  policy_no     = f_policy_no
    AND    cp_anniv_date = f_cp_anniv_date

    IF  STATUS = NOTFOUND THEN
	LET f_psck.policy_no            =f_policy_no
	LET f_psck.cp_anniv_date        =f_cp_anniv_date
	LET f_psck.cp_remark_desc_1     =f_process_date,
					 "�٥����O�����^�л���A�}���ݻ⤤�C�]", f_user_name CLIPPED, "�^"
	LET f_psck.cp_remark_desc_2     =" "
	LET f_psck.cp_remark_desc_3     =" "
	LET f_psck.cp_remark_desc_4     =" "
	LET f_psck.cp_remark_desc_5     =" "
	LET f_psck.process_date         =f_process_date
	LET f_psck.process_time         =f_process_time
	LET f_psck.process_user         =f_process_user

        LET f_psck.nonresp_sw           = "Y" 

	INSERT INTO psck VALUES (f_psck.*)
	IF SQLCA.SQLCODE != 0 THEN
	   ERROR "error :insert psck ",f_policy_no
	   RETURN TRUE
	END IF
	RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_2 CLIPPED) = 0 THEN
	LET f_psck.cp_remark_desc_2 = f_process_date,
				      "�٥����O�����^�л���A�}���ݻ⤤�C�]", f_user_name CLIPPED,"�^"

	UPDATE psck
	SET    cp_remark_desc_2 = f_psck.cp_remark_desc_2
	      ,process_date	= f_process_date
	      ,process_time	= f_process_time
	      ,process_user	= f_process_user
              ,nonresp_sw       = "Y" 
	WHERE  policy_no	= f_policy_no
	AND    cp_anniv_date	= f_cp_anniv_date

	IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_3 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_3 = f_process_date,
                                      "�٥����O�����^�л���A�}���ݻ⤤�C�]", f_user_name CLIPPED,"�^"

        UPDATE psck
        SET    cp_remark_desc_3 = f_psck.cp_remark_desc_3
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_4 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_4 = f_process_date,
                                      "�٥����O�����^�л���A�}���ݻ⤤�C�]", f_user_name CLIPPED,"�^"

        UPDATE psck
        SET    cp_remark_desc_4 = f_psck.cp_remark_desc_4
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_5 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_5 = f_process_date,
                                      "�٥����O�����^�л���A�}���ݻ⤤�C�]", f_user_name CLIPPED,"�^"

        UPDATE psck
        SET    cp_remark_desc_5 = f_psck.cp_remark_desc_5
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    ERROR "error :psck no space ",f_policy_no
    RETURN TRUE

END FUNCTION

------------------------------------------------------------------------------
--  �禡�W��: psc00m_sel_4
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: ��ܳB�z�٥��B�z,���I�@�~�ק�
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_4()
    DEFINE f_rcode INTEGER
    DEFINE f_polf_exist      INTEGER  -- �O���ˮ� --
          ,f_pscb_exist      INTEGER  -- �٥����ˮ� --
          ,f_chkdate_sw      INTEGER  -- ����ˮ� --
          ,f_format_date     CHAR(9)  -- �榡�ƪ���� --

    DEFINE f_ins_pscn        CHAR(1)  --  N:���� pscn ���@
          ,f_call_psc00m00   CHAR(1)  --  N:�i�J���
          ,f_psc00m00_rcode  CHAR(1)


    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""

    MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date TO policy_no,cp_anniv_date

    INPUT p_policy_no,p_cp_anniv_date FROM
          policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7")

                IF f_pscb_exist =0 THEN
                   ERROR "�٥��ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "���I�ק��� !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m01
       RETURN
    END IF

    CLOSE WINDOW w_psc00m01

    LET p_act_return_date=p_tran_date

    CALL psc01m_init()
    CALL psc01m_query() RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "���I���,���ק� !!"
    ELSE
       ERROR "���I�ק粒�� !!"
    END IF

    RETURN
END FUNCTION -- psc00m_sel_4 --

------------------------------------------------------------------------------
--  �禡�W��: psc00m_sel_5
--  �@    ��: jessica Chang
--  ��    ��: 089/01/06
--  �B�z���n: ��ܷӷ|�檺�C�L--�浧
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_5()

    DEFINE f_rcode           INTEGER
          ,f_copies          INTEGER
          ,f_rpt_name_1      CHAR(30)
          ,f_rpt_code_1      CHAR(20)
          ,f_rpt_cmd         CHAR(1024)
    DEFINE f_polf_exist      INTEGER  -- �O���ˮ� --
          ,f_pscb_exist      INTEGER  -- �٥����ˮ� --
          ,f_chkdate_sw      INTEGER  -- ����ˮ� --
          ,f_format_date     CHAR(9)  -- �榡�ƪ���� --

    DEFINE f_ins_pscn        CHAR(1)  --  N:���� pscn ���@
          ,f_call_psc00m00   CHAR(1)  --  N:�i�J���
          ,f_psc00m00_rcode  CHAR(1)


    MESSAGE " �п�J����CEsc: �����AEnd: ���C" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m09 AT 10,11 WITH FORM "psc00m09"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code
	 TO policy_no,cp_anniv_date,cp_notice_sub_code

    INPUT p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code FROM
          policy_no,cp_anniv_date,cp_notice_sub_code
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-���`; 1-���~
                   IF f_rtn = 1 THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

	  AFTER FIELD cp_notice_sub_code
		IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
		   ERROR "�B�z�覡������J   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
		IF p_cp_notice_sub_code NOT MATCHES "[1-2]" THEN
		   ERROR "�B�z�覡��J���~   !!"
		   NEXT FIELD cp_notice_sub_code
		END IF

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-���`; 1-���~
                   IF f_rtn = 1 THEN
                   ERROR "�O�椣�s�b!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "�����J���~!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

             IF p_pt_sw = '1' THEN ----���I�O��
                SELECT count(*) INTO f_pscb_exist
                FROM   ptpd
                WHERE  policy_no      = p_policy_no
                AND    payout_due     = p_cp_anniv_date
--                AND    live_certi_ind = 'Y'
                AND    opt_notice_sw  in ( '1','2')----�^�Ъ��A 1.���ݦ^�� 2.�w�g�^��
                AND    process_sw     = '0'        ----��l��   1.�w�g���I
                IF f_pscb_exist = 0 THEN
                   ERROR "���I�ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF
                IF  g_poia.po_sts_code !='53' THEN 
                    ERROR '�~���O�檬�A���šA���ݦ^��'
                   NEXT  FIELD policy_no
                END IF

                IF  p_cp_anniv_date > AddDay(p_tx_date,45) OR g_poia.po_sts_code !='53' THEN 
                   ERROR '���O����D�^�д����A���ݦ^��'
                   NEXT  FIELD policy_no
                END IF

             ELSE
                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7","8")

                IF f_pscb_exist =0 THEN
                   ERROR "�٥��ɤ��L������� !!"
                   NEXT  FIELD policy_no
                END IF
             END IF
    END INPUT

    IF INT_FLAG THEN
       ERROR "���ӷ|�檺�C�L!!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m09
       RETURN
    END IF

    CLOSE WINDOW w_psc00m09

    -- �ӷ|������� --
    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code_1    ="psc00m01"
    ELSE
       LET f_rpt_code_1	   ="psc00m02"
    END IF

    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code_1    ="psc00m01"
    ELSE
       LET f_rpt_code_1    ="psc00m02"
    END IF

    LET ans = '1'
    IF p_cp_notice_sub_code = "1" THEN
    PROMPT " �п�ܦC�L�覡 : 0.IDMS �C�L  1:�u�W�C�L  ", p_bell
    ATTRIBUTE (YELLOW)
    FOR CHAR ans
    IF ans NOT MATCHES "[0]" THEN
       LET ans = '1'
    END IF
    IF ans IS NULL OR ans = ' ' THEN
       LET ans = '1'
    END IF
    END IF

    IF ans = '0' and p_cp_notice_sub_code = "1" THEN   -- �e�� PSM ���x
       CALL PSManagerName(f_rpt_code_1) RETURNING f_rpt_name_1
    ELSE                     -- Local
       CALL ReportName(f_rpt_code_1) RETURNING f_rpt_name_1
    END IF

    IF p_cp_notice_sub_code = "1" THEN
      IF p_pt_sw = '1' THEN
       START REPORT print_notice_pt TO f_rpt_name_1
           CALL psc_pt_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O")
	    RETURNING f_rcode
       FINISH REPORT print_notice_pt
       ELSE

       START REPORT print_notice  TO f_rpt_name_1

CALL psc_print_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O",ans,p_po_chg_rece_no)
            RETURNING f_rcode
       FINISH REPORT print_notice
      END IF
    ELSE
          IF p_pt_sw = '1' THEN
          START REPORT print_insure_pt TO f_rpt_name_1
	  CALL psc_ptins_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure_pt
          ELSE
       START REPORT print_insure  TO f_rpt_name_1

       CALL psc_insure_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
            RETURNING f_rcode
       FINISH REPORT print_insure
          END IF
    END IF
    IF f_rcode =0 THEN
       IF ans = '0' and p_cp_notice_sub_code = "1" THEN   --  PSM
          LET f_rpt_cmd = "psmanager ",f_rpt_name_1  -- PSM
          RUN f_rpt_cmd
          ERROR "�ӷ|��C�L���� !!"
       ELSE                     -- Local �C�L
          LET f_copies=SelectPrinter (f_rpt_name_1)
          IF (f_copies ) THEN
             LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                           ,f_rpt_name_1 CLIPPED
             RUN f_rpt_cmd
             ERROR "�ӷ|��C�L���� !!"
          END IF
       END IF
    END IF

    RETURN
END FUNCTION -- psc00m_sel_5 --
-------------------------------------------------------------------------------------
FUNCTION psc01m_disb_type_1(f_serivce_agt_name
                           ,f_agt_deptbelong
                           )
    DEFINE f_serivce_agt_name  CHAR(40)
          ,f_agt_deptbelong    CHAR(6)
          ,f_sel_dept_code     CHAR(6)
          ,f_sel_dept_name     CHAR(18)

    DEFINE f_rcode INTEGER
          ,f_ans_sw CHAR(1)
          ,f_dept_name CHAR(18)
    DEFINE f_pay_ind CHAR(1)
          ,f_pay_name CHAR(30)
          ,f_pay_id   CHAR(10)
          ,f_tel_1		CHAR(11)
          ,f_dept_code CHAR(6)
	  ,f_dept_name_1 CHAR(18)

    LET f_rcode=0
    LET f_ans_sw="N"

    LET f_pay_ind=""
    LET f_pay_name=""
    LET f_pay_id=""
    LET f_dept_code=""
    LET f_dept_name_1=""
    LET f_tel_1 = ""

    SELECT dept_name INTO f_dept_name
    FROM   dept
    WHERE  dept_code=f_agt_deptbelong
		
		SELECT tel_1 
		INTO f_tel_1
		FROM addr 
		WHERE client_id = f_pay_id
			AND addr_ind = "E"

		
    IF length(f_dept_name CLIPPED)=0 THEN
       LET f_dept_name=""
    END IF

    OPEN WINDOW w_psc00m05 AT 10,11 WITH FORM "psc00m05"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

--    DISPLAY p_data_s1.policy_no,p_data_s1.cp_anniv_date
--    TO      policy_no,cp_anniv_date

    INPUT   f_pay_ind,f_pay_id,f_pay_name,f_tel_1
    FROM    pay_ind,cp_pay_id,cp_pay_name,tel_1 

            AFTER FIELD pay_ind
              IF f_pay_ind="0" THEN
                 LET f_pay_name   	= f_serivce_agt_name
                 LET f_pay_id     	= p_agent_code
                 LET f_dept_code  	= f_agt_deptbelong
                 LET f_dept_name_1	= f_dept_name
                 LET f_tel_1            = ''
{
                 SELECT tel_1
                 INTO f_tel_1
                 FROM addr 
                 WHERE client_id = f_pay_id
                 AND addr_ind = "E"
}
                 DISPLAY f_serivce_agt_name,p_agent_code
                        ,f_tel_1,f_agt_deptbelong,f_dept_name
                 TO      cp_pay_name,cp_pay_id,tel_1,dept_code,dept_name
              END IF

            AFTER FIELD cp_pay_id
              LET f_pay_id=UPSHIFT(f_pay_id)
              IF length(f_pay_id   CLIPPED )=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD cp_pay_id  
              ELSE
                 SELECT names
                 INTO   f_pay_name
                 FROM   clnt
                 WHERE  client_id=f_pay_id
                 IF STATUS = NOTFOUND THEN
                    LET f_pay_name=""
                 ELSE
                    LET f_pay_name=f_pay_name[1,20]
                 END IF
                 SELECT tel_1
                 INTO f_tel_1
                 FROM addr 
                 WHERE client_id = f_pay_id
                 AND addr_ind = "E"
		 DISPLAY f_pay_id   TO cp_pay_id
                 DISPLAY f_pay_name TO cp_pay_name
		 DISPLAY f_tel_1 TO tel_1             
              END IF

            AFTER FIELD cp_pay_name
              IF length(f_pay_name CLIPPED )=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD cp_pay_name
              END IF

              CALL psc01m_dept_code()
                   RETURNING f_rcode
                            ,f_sel_dept_code
                            ,f_sel_dept_name
              LET f_rcode=0
              LET f_dept_code = f_sel_dept_code
              LET f_dept_name_1=f_sel_dept_name
              DISPLAY f_sel_dept_code,f_sel_dept_name
              TO dept_code,dept_name

            AFTER INPUT
              IF INT_FLAG=TRUE THEN
                 EXIT INPUT
              END IF

              IF length(f_pay_ind CLIPPED)=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD pay_ind
              END IF

              IF length(f_dept_code CLIPPED)=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD pay_ind
              END IF

              IF length(f_pay_name  CLIPPED)=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD cp_pay_name
              END IF

              LET f_pay_id=UPSHIFT(f_pay_id) 
              IF length(f_pay_id  CLIPPED)=0 THEN
                 ERROR "�����ƥ�����J !!"
                 NEXT FIELD cp_pay_id  
              END IF

              LET f_ans_sw=""
              PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
              IF UPSHIFT(f_ans_sw) !="Y" OR
                 f_ans_sw IS NULL        THEN
                 NEXT FIELD pay_ind
              END IF
    END INPUT

    IF INT_FLAG=TRUE THEN
       LET INT_FLAG=FALSE
       LET p_data_s1.cp_pay_name=""
       LET p_data_s1.cp_pay_id  =""
       LET p_dept_code 		=""
       LET p_data_s1.dept_name	=""
       LET p_tel_3 = ""
       LET f_rcode=1
       CLOSE WINDOW w_psc00m05
       RETURN f_rcode
    END IF

    LET p_data_s1.cp_pay_name=f_pay_name
    LET p_data_s1.cp_pay_id  =f_pay_id
    LET p_dept_code	     =f_dept_code
    LET p_data_s1.dept_name  =f_dept_name_1
    LET p_tel_3              =f_tel_1 CLIPPED

    CLOSE WINDOW w_psc00m05
    RETURN f_rcode

END FUNCTION -- psc01m_disb_type_1 --

FUNCTION psc01m_dept_code()
    DEFINE f_rcode    CHAR(1)
    DEFINE f_dept_code CHAR(6)
          ,f_dept_name CHAR(18)
    DEFINE f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
    DEFINE f_dept ARRAY[11] OF RECORD
           dept_code CHAR(6)
          ,dept_name CHAR(18)
                  END RECORD

--089/11/21�s�W�O���B���Ʀ�F����
    LET f_dept[1].dept_code="90000"
    LET f_dept[1].dept_name="�`���q"
    LET f_dept[2].dept_code="91000"
    LET f_dept[2].dept_name="�x�_�����q"
    LET f_dept[3].dept_code="92000"
    LET f_dept[3].dept_name="�O����F����"
    LET f_dept[4].dept_code="93000"
    LET f_dept[4].dept_name="���c��F����"
    LET f_dept[5].dept_code="94000"
    LET f_dept[5].dept_name="�x�������q"
    LET f_dept[6].dept_code="95000"
    LET f_dept[6].dept_name="�Ÿq�����q"
    LET f_dept[7].dept_code="96000"
    LET f_dept[7].dept_name="�x�n�����q"
    LET f_dept[8].dept_code="97000"
    LET f_dept[8].dept_name="���������q"
    LET f_dept[9].dept_code="98000"
    LET f_dept[9].dept_name="�̪F��F����"
    LET f_dept[10].dept_code="9A000"
    LET f_dept[10].dept_name="���Ʀ�F����"
    LET f_dept[11].dept_code="9B000"
    LET f_dept[11].dept_name="���������q"
    
    LET f_rcode=0
    LET f_x=10
    LET f_y=31

    OPEN WINDOW w_psc00m06 AT f_x, f_y WITH FORM "psc00m06"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    CALL SET_COUNT(11)
    LET f_dept_code=""
    LET f_dept_name=""
    LET INT_FLAG=FALSE

    DISPLAY ARRAY f_dept TO psc00m06.* ATTRIBUTE (BLUE ,REVERSE)

    IF (INT_FLAG = FALSE) THEN
        LET f_i    = ARR_CURR()
        LET f_dept_code         =f_dept[f_i].dept_code
        LET f_dept_name         =f_dept[f_i].dept_name
    ELSE
        LET f_rcode=2
        LET INT_FLAG = FALSE
        LET f_dept_code=""
        LET f_dept_name=""
    END IF

    CLOSE WINDOW w_psc00m06

    RETURN f_rcode,f_dept_code,f_dept_name

END FUNCTION -- psc01m_dept_code --

------------------------------------------------------------------------------
--  �禡�W��: notice_print
--  �@    ��: kobe
--  ��    ��: 092/01/22
--  �B�z���n: �ӷ|��C�L
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION notice_print()

    DEFINE f_rpt_name		CHAR(30)
	  ,f_rpt_code		CHAR(20)
	  ,f_rpt_cmd		CHAR(1024)

    DEFINE f_copies		INTEGER
    DEFINE f_rcode		INTEGER

    LET f_rcode = 0

    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code = "psc00m01"
    ELSE
       IF p_cp_notice_sub_code = "2" THEN
	  LET f_rpt_code = "psc00m02"
       END IF
    END IF

    LET ans = '1'
    IF p_cp_notice_sub_code = "1" THEN
    PROMPT " �п�ܦC�L�覡 : 0.IDMS �C�L  1:�u�W�C�L  ", p_bell
    ATTRIBUTE (YELLOW)
    FOR CHAR ans
    IF ans NOT MATCHES "[0]" THEN
       LET ans = '1'
    END IF
    IF ans IS NULL OR ans = ' ' THEN
       LET ans = '1'
    END IF
    END IF

    IF ans = '0' and p_cp_notice_sub_code = "1" THEN   -- �e�� PSM ���x
       CALL PSManagerName(f_rpt_code) RETURNING f_rpt_name
    ELSE                     -- Local
       CALL ReportName(f_rpt_code) RETURNING f_rpt_name
    END IF

    IF p_cp_notice_sub_code = "1" THEN
       IF p_pt_sw = '1' THEN
       START REPORT print_notice_pt TO f_rpt_name
       CALL psc_pt_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O")
	    RETURNING f_rcode
       FINISH REPORT print_notice_pt
       ELSE
       START REPORT print_notice TO f_rpt_name
CALL psc_print_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O",ans,p_po_chg_rece_no)
	    RETURNING f_rcode
       FINISH REPORT print_notice
       END IF
    ELSE
       IF p_cp_notice_sub_code = "2" THEN
          IF p_pt_sw = '1' THEN
          START REPORT print_insure_pt TO f_rpt_name
	  CALL psc_ptins_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure_pt
          ELSE
          START REPORT print_insure TO f_rpt_name
	  CALL psc_insure_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure
          END IF
       END IF
    END IF


    IF f_rcode =0 THEN
       IF ans = '0' and p_cp_notice_sub_code = "1" THEN   --  PSM
          LET f_rpt_cmd = "psmanager ",f_rpt_name  -- PSM
          RUN f_rpt_cmd
          ERROR "�ӷ|��C�L���� !!"
             SLEEP 1
       ELSE                     -- Local �C�L
          LET f_copies=SelectPrinter (f_rpt_name)
          IF (f_copies ) THEN
             LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                           ,f_rpt_name CLIPPED
             RUN f_rpt_cmd
             ERROR "�ӷ|��C�L���� !!"
             SLEEP 1
          END IF
       END IF
    END IF

    RETURN f_rcode
END FUNCTION

------------------------------------------------------------------------------
--  �禡�W��: dummy
--  �@    ��: jessica Chang
--  ��    ��: 87/04/08
--  �B�z���n: �٥��d�ߧ@�~,�\��|������
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION dummy()
    ERROR "FUNCTION not yet  implemented."
END FUNCTION
-------------------------------------------------------------------------------
--  �禡�W��:
--  �B�z���n:
--  ��J�Ѽ�: (no)
--  ��X�Ѽ�: TRUE -> o.k.    FALSE -> give up
-------------------------------------------------------------------------------
FUNCTION display_rece_no()
DEFINE f_rw     SMALLINT

   OPEN WINDOW psc00m10 AT 12,21 WITH FORM "psc00m10"
--   WHILE TRUE

     CALL SET_COUNT( p_po_chg_cnt )
     DISPLAY ARRAY p_po_chg TO s_psc00m10.*
         LET f_rw =  ARR_CURR()
--     END DISPLAY
--   END WHILE

   CLOSE WINDOW psc00m10

--display p_po_chg[f_rw].po_chg_rece_no
--call touch()

   RETURN f_rw
END FUNCTION
-------------------------------------------------------------------------------
--  �禡�W��:rece_no_show()
--  �B�z���n:��X���z�s�����
--  ��J�Ѽ�: (no)
--  ��X�Ѽ�: (no)
-------------------------------------------------------------------------------
FUNCTION rece_no_show()
    DEFINE rece_no_arr_curr INTEGER
    DEFINE f_po_chg_rece_no   LIKE apdt.po_chg_rece_no 
    DEFINE f_po_chg_rece_date LIKE apdt.po_chg_rece_date
    DEFINE f_po_chg_sts_code LIKE aplg.po_chg_sts_code
    DEFINE f_cnt  INTEGER
    LET f_cnt = 100
    SELECT COUNT(*)
      INTO f_cnt 
      FROM apdt ,apit  
     WHERE apdt.policy_no = p_policy_no
       AND apdt.po_chg_rece_no = apit.po_chg_rece_no
       AND apit.po_chg_code = '89'
       AND apdt.po_chg_sts_code IN ('2','4','A')    
    IF f_cnt = 0 THEN 
       INITIALIZE  p_po_chg_rece_no TO NULL
       LET p_po_chg_rece_no = ""
       ERROR "�ӫO�渹�X�d�L���A(2,4,A)�U�����z���X�A�Ьd��!" ATTRIBUTE(RED ,REVERSE)
       RETURN 
    END IF 
    LET f_cnt = 1
    INITIALIZE p_po_chg[1].* TO NULL

    DECLARE p_key_apdt CURSOR FOR
        SELECT a.po_chg_rece_no,a.po_chg_rece_date,a.po_chg_sts_code
          FROM apdt a,apit b
         WHERE a.policy_no = p_policy_no
           AND a.po_chg_rece_no = b.po_chg_rece_no
           AND b.po_chg_code = '89'
           AND a.po_chg_sts_code IN ("2","4","A")
         ORDER BY a.po_chg_rece_no DESC
    FOREACH p_key_apdt INTO f_po_chg_rece_no,f_po_chg_rece_date,f_po_chg_sts_code 
         LET p_po_chg[f_cnt].po_chg_rece_no = f_po_chg_rece_no
         LET p_po_chg[f_cnt].po_chg_rece_date = f_po_chg_rece_date 
         LET p_po_chg[f_cnt].po_chg_sts_code = f_po_chg_sts_code
         LET f_cnt = f_cnt + 1
    END FOREACH
    LET f_cnt = f_cnt - 1
    IF f_cnt > 20 THEN 
       DISPLAY "���z�s���W�L�G�Q���A�Ь���T��" AT 24,1 ATTRIBUTE (RED ,REVERSE)
       RETURN
    END IF
    
        
    OPEN    WINDOW w_psc00m13 AT 7,19 WITH FORM "pa502s01" ATTRIBUTE( CYAN )
     CALL    SET_COUNT( f_cnt  )
     DISPLAY ARRAY p_po_chg TO sc_pa502s01.*
          ON KEY( INTERRUPT )
             EXIT DISPLAY
          ON KEY( ESC, ACCEPT ,RETURN )
             LET rece_no_arr_curr     = ARR_CURR()
             LET p_po_chg_rece_no = p_po_chg[ rece_no_arr_curr ].po_chg_rece_no
             EXIT DISPLAY
     END     DISPLAY
     CLOSE   WINDOW w_psc00m13
     
    RETURN
END FUNCTION 
-------------------------------------------------------------------------------
--  �禡�W��:cmd_run()
--  �B�z���n:�s���ܫ��w�{��
--  ��J�Ѽ�: cmd
--  ��X�Ѽ�: (no)
-------------------------------------------------------------------------------
FUNCTION cmd_run(cmd)
    DEFINE cmd  CHAR(100)
    LET cmd = cmd CLIPPED
    RUN cmd 
END FUNCTION

-------------------------------------------------------------------------------
--  �禡�W��:ins_pscw()
--  �B�z���n:��Jpscw�H�K����online�L�b
--  ��J�Ѽ�: 
--  ��X�Ѽ�:
-------------------------------------------------------------------------------
FUNCTION ins_pscw()
    DEFINE f_pscw_cnt  SMALLINT
    LET f_pscw_cnt = 0
    SELECT count(*)
      INTO f_pscw_cnt 
      FROM pscw
     WHERE policy_no = p_data_s1.policy_no
       AND cp_anniv_date = p_data_s1.cp_anniv_date
display 'pscw cnt=',f_pscw_cnt
    IF f_pscw_cnt > 0 THEN
       DELETE FROM pscw
        WHERE policy_no = p_data_s1.policy_no
          AND cp_anniv_date = p_data_s1.cp_anniv_date
    END IF
display 'insert pscw'
    INSERT INTO pscw VALUES
                          (p_data_s1.policy_no,
                           p_data_s1.cp_anniv_date,
                           '1',
                           ' ',
                           '0',
                           '')
    IF SQLCA.SQLCODE != 0 THEN
       RETURN 0
    END IF
    RETURN 1
END FUNCTION  
    
-------------------------------------------------------------------------------
--  �禡�W��:disp_addr()
--  �B�z���n:�Ѧ�psg01m22���addr
--  ��J�Ѽ�: client_id
--  ��X�Ѽ�: addr_ind
-------------------------------------------------------------------------------
FUNCTION disp_addr(f_client_id)
    DEFINE f_client_id CHAR(10)
    DEFINE f_addr    RECORD LIKE addr.*    
    DEFINE
        p_edit_rsdr_show  ARRAY[30] OF RECORD
        function_ind          LIKE rsdr.function_ind     , --
        addr_ind              LIKE rsdr.addr_ind         , --
        address               LIKE rsdr.address          , --
        zip_code              LIKE rsdr.zip_code         , --
        tel_1                 LIKE rsdr.tel_1            , --
        tel_2                 LIKE rsdr.tel_2            , --
        fax                   LIKE rsdr.fax                --
    END RECORD

    DEFINE
        i                         SMALLINT                   , --
        idx                       SMALLINT                   , --
        f_arr_curr                SMALLINT                   , --
        f_addr_ind                CHAR                         --

    INITIALIZE p_edit_rsdr_show TO NULL
    LET idx = 1
    DECLARE p_key_addr CURSOR FOR
        SELECT *
          FROM addr
         WHERE client_id = f_client_id
         ORDER BY addr_ind
    FOREACH p_key_addr INTO f_addr.*
        LET p_edit_rsdr_show[idx].addr_ind = f_addr.addr_ind
        LET p_edit_rsdr_show[idx].address  = f_addr.address
        LET p_edit_rsdr_show[idx].zip_code = f_addr.zip_code
        LET p_edit_rsdr_show[idx].tel_1    = f_addr.tel_1
        LET p_edit_rsdr_show[idx].tel_2    = f_addr.tel_2
        LET p_edit_rsdr_show[idx].fax      = f_addr.fax
        LET idx = idx + 1
    END FOREACH
    OPTIONS FORM LINE FIRST

    OPEN WINDOW psg01m22 AT 5, 1 WITH FORM "psg01m22" ATTRIBUTE( CYAN )

    CALL SET_COUNT( idx - 1 )

    DISPLAY ARRAY p_edit_rsdr_show TO s_g01m220.* ATTRIBUTE( CYAN )

        ON KEY ( INTERRUPT )
            EXIT DISPLAY

        ON KEY ( RETURN, ACCEPT ,ESC)
            LET f_arr_curr = ARR_CURR()
            LET f_addr_ind = p_edit_rsdr_show[f_arr_curr].addr_ind
            EXIT DISPLAY
    END DISPLAY

    CLOSE WINDOW psg01m22

    OPTIONS FORM LINE FIRST + 2
    RETURN f_addr_ind 

END FUNCTION        ----- get_app_addr_ind -----
 
-------------------------------------------------------------------------------
--  �禡�W��:ins_psc3()
--  �B�z���n:�N�a�}�d�s��psc3
--  ��J�Ѽ�: client_id
--  ��X�Ѽ�: 
-------------------------------------------------------------------------------
FUNCTION ins_psc3()
    DEFINE f_psc3  RECORD LIKE psc3.*
    DEFINE f_address LIKE addr.address   
    DEFINE f_ans_sw  CHAR(1) 
    DEFINE f_zip_code LIKE psc3.zip_code
    DEFINE f_err INTEGER
    SELECT *
      INTO f_psc3.*
      FROM psc3
     WHERE policy_no = p_data_s1.policy_no
       AND cp_anniv_date = p_data_s1.cp_anniv_date
       AND addr_ind = 'Q'  
    IF STATUS = NOTFOUND THEN
       LET f_address = '' 
       LET f_zip_code = ''
    ELSE
       LET f_address = f_psc3.address
       LET f_zip_code = f_psc3.zip_code
       DELETE FROM psc3
       WHERE policy_no = p_data_s1.policy_no
         AND cp_anniv_date = p_data_s1.cp_anniv_date
         AND addr_ind = 'Q'
    END IF

    OPTIONS FORM LINE FIRST

    OPEN WINDOW psc00m13 AT 11,1 WITH FORM "psc00m13" 
       ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

--102/01/10 cmwang modify 
{ 
    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date,f_zip_code
          ,f_address without defaults FROM psc00m13.*
}
    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date
          ,f_address without defaults FROM psc00m13.*
    
    AFTER FIELD address
      CALL get_zip_code(f_address,length(f_address))
           RETURNING f_err,f_zip_code
      IF f_zip_code IS NULL THEN
         LET f_zip_code = " "
      END IF
      DISPLAY f_zip_code TO psc00m_zip.* ATTRIBUTE (BLUE,REVERSE,UNDERLINE)

    AFTER INPUT
        PROMPT "  �T�{�s�ɽЫ� Y" FOR CHAR f_ans_sw
        IF UPSHIFT(f_ans_sw) !="Y" OR
           f_ans_sw IS NULL        THEN
           NEXT FIELD address
        ELSE
           INSERT INTO psc3 VALUES (
                                    p_data_s1.policy_no,
                                    p_data_s1.cp_anniv_date,
                                    p_applicant_id,
                                    'Q',
                                    f_zip_code,
                                    f_address,
                                    p_tran_date,
                                    g_user)
                                      
                                    
        END IF

        
        ON KEY ( INTERRUPT )
            EXIT INPUT

    END INPUT

    CLOSE WINDOW psc00m13

    OPTIONS FORM LINE FIRST + 2
END FUNCTION

FUNCTION nonresp_sw_add()
  DEFINE f_psck_cnt	           SMALLINT
  DEFINE f_psck    RECORD LIKE psck.* 
  DEFINE f_rcode INTEGER

  LET f_rcode = 0

  SELECT   COUNT(*)
    INTO    f_psck_cnt 
    FROM    psck
    WHERE   policy_no = p_data_s1.policy_no 
     AND    cp_anniv_date = p_data_s1.cp_anniv_date 
      
  IF f_psck_cnt = 0 THEN 
     LET f_psck.policy_no = p_data_s1.policy_no 
     LET f_psck.cp_anniv_date = p_data_s1.cp_anniv_date
     LET f_psck.cp_remark_desc_1 = " "
     LET f_psck.cp_remark_desc_2 = " "  
     LET f_psck.cp_remark_desc_3 = " "
     LET f_psck.cp_remark_desc_4 = " "
     LET f_psck.cp_remark_desc_5 = " "
     LET f_psck.nonresp_sw = "Y"
     LET f_psck.process_date = GetDate(Today)
     LET f_psck.process_time = TIME 
     LET f_psck.process_user = g_user
     INSERT INTO psck VALUES(f_psck.*)
     IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
     END IF
  ELSE
     UPDATE psck
     SET nonresp_sw = "Y"
     WHERE policy_no = p_data_s1.policy_no
     AND   cp_anniv_date = p_data_s1.cp_anniv_date
     IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
     END IF
  END IF  

  UPDATE pscb 
  SET cp_remark_sw  = "Y"
  WHERE policy_no = p_data_s1.policy_no 
    AND cp_anniv_date = p_data_s1.cp_anniv_date 
  IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
  END IF 
   
END FUNCTION 
FUNCTION usd_notify(f_notify_cp_anniv_date)
    DEFINE f_notify_cp_anniv_date LIKE pscb.cp_anniv_date
    DEFINE f_notify_cp_sw         LIKE pscb.cp_sw
    DEFINE f_notify_cp_notice_sw  LIKE pscb.cp_notice_sw
        
    LET f_notify_cp_sw = ''
    LET f_notify_cp_notice_sw = '' 

    DECLARE p_usd_notify CURSOR FOR
        SELECT cp_sw , cp_notice_sw
          FROM pscb 
         WHERE policy_no = g_polf.policy_no
           AND cp_anniv_date != f_notify_cp_anniv_date
         ORDER BY cp_anniv_date
    FOREACH p_usd_notify INTO f_notify_cp_sw,f_notify_cp_notice_sw
        IF f_notify_cp_sw = '7' THEN
           IF f_notify_cp_notice_sw = '1' OR f_notify_cp_notice_sw = '4' OR --"B1�ӷ|��"
              f_notify_cp_notice_sw = '0' THEN   --"C1���^��"
              RETURN 1
           END IF
        END IF
        IF f_notify_cp_sw = '1' OR f_notify_cp_sw = '4' OR
           f_notify_cp_sw = '8' THEN
           IF f_notify_cp_notice_sw = '1' OR f_notify_cp_notice_sw = '4' OR --"B1�ӷ|��"
              f_notify_cp_notice_sw = '0' THEN  --"B3�q����"
              RETURN 1
           END IF
        END IF   
    END FOREACH
    RETURN 0
END FUNCTION  

------------------------------------------------------------------------------
-- �禡�W��: chk_benf_data()
-- �ݨD�渹: SR151200331
-- �B�z�ԭz: �ˬd���q�H���(���q�H���u�nid�Ωm�W�S��ƴN�^��FALSE)
-- ��J�Ѽ�: �L
-- ��X�Ѽ�: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION chk_benf_data()
	DEFINE f_benf_arr_cnt     SMALLINT
	DEFINE f_i                SMALLINT
	DEFINE f_client_id_len    SMALLINT
	DEFINE f_client_names_len SMALLINT
	DEFINE f_chk_ind          CHAR(1)
	DEFINE f_id_ind           CHAR(1)
	-- DEFINE f_cmd              CHAR(1200) --���ե�
	
	LET f_chk_ind = TRUE
-- let f_cmd = "echo '","test","' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
	
	-- ���A��p_benf�o��RECORD�S�b��
	FOR f_i = 0 TO 99
		LET f_client_id_len    = 0
		LET f_client_names_len = 0
		LET f_client_id_len    = LENGTH( p_data_s2[ f_i ].client_id CLIPPED )
		LET f_client_names_len = LENGTH( p_data_s2[ f_i ].names CLIPPED )
		-- ���q�H��ID���S�m�W�����p
		IF f_client_id_len > 0 AND f_client_names_len = 0 THEN
			-- ���q�H��ID���S�m�W�BID�������Ҧr���hFALSE
			LET f_id_ind = get_id_ind( p_data_s2[ f_i ].client_id )
			IF f_id_ind = "1" THEN
				LET f_chk_ind = FALSE
			END IF
		END IF
		-- ���q�H�SID�����m�W�����p
		IF f_client_id_len = 0 AND f_client_names_len > 0 THEN
			LET f_chk_ind = FALSE
		END IF
-- let f_cmd = "echo '",p_data_s2[ f_i ].client_id CLIPPED,"' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
-- let f_cmd = "echo '",p_data_s2[ f_i ].names CLIPPED,"' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
	END FOR

	RETURN f_chk_ind
	
END FUNCTION -- chk_benf_data()

------------------------------------------------------------------------------
-- �禡�W��: get_id_ind( f_client_id )
-- �ݨD�渹: SR151200331
-- �B�z�ԭz: ���id����
-- ��J�Ѽ�: �L
-- ��X�Ѽ�: id_ind[1234569]
------------------------------------------------------------------------------
FUNCTION get_id_ind( f_client_id )
	DEFINE f_client_id LIKE clnt.client_id
	DEFINE f_id_ind    LIKE clnt.id_ind
	
	LET f_id_ind = "X"
	SELECT id_ind
	INTO   f_id_ind
	FROM   clnt
	WHERE  client_id = f_client_id
	
	RETURN f_id_ind
	
END FUNCTION -- get_id_ind