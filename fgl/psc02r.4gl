------------------------------------------------------------------------------
-- �{���W��:psc02r.4gl
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:�٥� ���I���ӦC�L(���Ӫ�,�������)
-- table   :pscb,pscp
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
-- �ק�ت�:�s�W����覡
-- �ק��  :jessica Chang
-- �ݨD�渹:
-- �ק���:088/12/14
-- �\��X�S���� �l�H�䲼: R1-����        R2-�ͦs
--                ��ú�O�O: R3-����        R4-�ͦs
--                ���^���: R5-����        R6-�ͦs
--                �q    ��: R7-����_�@��   R8-����_����
--                �q    ��: R9-�ͦs_�@��   RA-�ͦs_����
--                �d�x���: RB-����        RC-�ͦs
--                �٥��^�y: RJ-����        RK-�ͦs
-------------------------------------------------------------------------------
--  �ק��:JC
--  090/04/25:�ק���q�H�W�r����k,��id ��clnt,�_�h��� benf �� names
-------------------------------------------------------------------------------
--  ��  ��:JC 090/07/20 SR:PS90655S �t�X�٥��ץ�
--           "���I����",�אּ "��b�����",������ڤHñ�����r�y
-------------------------------------------------------------------------------
--  ��  ��:�s�WFEL���P�_�I�� by yirong 96/01
-------------------------------------------------------------------------------
--  ��  ��:SR120800390 EB�[�K�M��-����վ�B�s�W�n�O�H�m�WID��� cmwang 101/09
-------------------------------------------------------------------------------
--  ��  ��:105/04/01 �s�W�뵹�I�I��
--  1.�u���S�C�뵹�I���B�A�����S�Ӧ~�ת��ٴڸ�T
--  2.��qpscu�쵹�I���
--  3.�ھڶg���P�_����
--  4.�뵹�I�u�|���S�b����cp_pay_dtl_col() cp_pay_unnormal()
--    100�U�H�W/�^�y/�~������|���[�W�뵹�I
-------------------------------------------------------------------------------

--GLOBALS "/devp/def/common.4gl"   --���ե�
--GLOBALS "/devp/def/lf.4gl"       --���ե�
--GLOBALS "/devp/def/report.4gl"   --���ե�


GLOBALS "../def/common.4gl"   --�W�u��}
GLOBALS "../def/lf.4gl"       --�W�u��}��
GLOBALS "../def/report.4gl"   --�W�u��}��
--SR120800390 cmwang 101/09 �q�l�q��e_bill�榡���e
GLOBALS "../def/omsg.4gl"
------------------------------------
DATABASE life

   DEFINE p_rpt_code_1     CHAR(8) -- �ͦs���I���Ӫ�N�X --
   DEFINE p_rpt_code_2     CHAR(8) -- �ͦs�������N�X   --
   DEFINE p_rpt_code_3     CHAR(8) -- �j�v����,�l�H�䲼  --
   DEFINE p_rpt_code_4     CHAR(8) -- �ͦs���I�����_����q�� --
   DEFINE p_rpt_code_5     CHAR(8) -- �ͦs���I�����_����q�� A4 --
   DEFINE p_rpt_code_7     CHAR(8)
   DEFINE p_rpt_code_8     CHAR(8)
   DEFINE p_rpt_code_9     CHAR(8)
   DEFINE p_rpt_code_10    CHAR(8) -- �٥����I�@���Be-billing�B�Ȱ��l�H���Ӫ�
   DEFINE p_rpt_code_11    CHAR(8)
   DEFINE p_rpt_code_12    CHAR(8)
   DEFINE p_rpt_code_13    CHAR(8)


   DEFINE p_rpt_beg_date   CHAR(9) -- �C�L����_��   --
   DEFINE p_rpt_end_date   CHAR(9) -- �C�L������   --
   DEFINE p_rpt_name_1     CHAR(40) -- �ͦs���I���Ӫ���Y --
         ,p_rpt_name_2     CHAR(40) -- �ͦs���I�������Y --
         ,p_rpt_name_3     CHAR(40) -- �j�v�������Y,�l�H�䲼 --
         ,p_rpt_name_4     CHAR(40) -- �ͦs���I�����_����q�� --
         ,p_rpt_name_5     CHAR(40) -- �ͦs���I�����_����q�� A4 --
         ,p_rpt_name_7     CHAR(40) -- �^�y���𱱨���� --
         ,p_rpt_name_8     CHAR(40)
         ,p_rpt_name_9     CHAR(40)
         ,p_rpt_name_10    CHAR(40) -- �٥����I�@���Be-billing�B�Ȱ��l�H���Ӫ�
         ,p_rpt_name_11    CHAR(40)
         ,p_rpt_name_12    CHAR(40)
         ,p_rpt_name_13    CHAR(40)


   DEFINE p_name                CHAR(14)
   DEFINE p_pscb           RECORD LIKE pscb.*
   DEFINE p_pscp           RECORD LIKE pscp.*
   DEFINE p_cp_pay_detail  RECORD
          process_date            LIKE pscb.change_date
         ,policy_no               LIKE polf.policy_no
         ,cp_anniv_date           LIKE pscb.cp_anniv_date
         ,cp_sw                   LIKE pscb.cp_sw
         ,cp_pay_form_type        LIKE pscp.cp_pay_form_type
         ,plan_code               LIKE pscp.plan_code
         ,rate_scale              LIKE pscp.rate_scale
         ,coverage_no             LIKE pscp.coverage_no
         ,face_amt                LIKE pscp.face_amt
         ,paid_to_date            LIKE pscp.paid_to_date
         ,po_issue_date           LIKE pscp.po_issue_date
         ,minus_prem_susp         LIKE pscp.minus_prem_susp
         ,loan_amt                LIKE pscp.loan_amt
         ,loan_int_balance        LIKE pscp.loan_int_balance
         ,loan_int                LIKE pscp.loan_int
         ,apl_amt                 LIKE pscp.apl_amt
         ,apl_int_balance         LIKE pscp.apl_int_balance
         ,apl_int                 LIKE pscp.apl_int
         ,rtn_minus_premsusp      LIKE pscp.rtn_minus_premsusp
         ,rtn_loan_amt            LIKE pscp.rtn_loan_amt
         ,rtn_loan_int            LIKE pscp.rtn_loan_int
         ,rtn_apl_amt             LIKE pscp.rtn_apl_amt
         ,rtn_apl_int             LIKE pscp.rtn_apl_int
         ,prem_susp               LIKE pscp.prem_susp
         ,accumulated_div         LIKE pscp.accumulated_div
         ,div_int_balance         LIKE pscp.div_int_balance
         ,div_int                 LIKE pscp.div_int
         ,cp_amt                  LIKE pscp.cp_amt
         ,cp_chk_date             LIKE pscp.cp_chk_date
         ,rtn_rece_no             LIKE pscp.rtn_rece_no
         ,cp_pay_amt              LIKE pscp.cp_pay_amt
         ,cp_disb_type            LIKE pscb.cp_disb_type
         ,mail_addr_ind           LIKE polf.mail_addr_ind
         ,dept_code               LIKE dept.dept_code
         ,agent_code              LIKE agnt.agent_code
         ,address                 LIKE addr.address
         ,zip_code                LIKE addr.zip_code
         ,currency                LIKE pscp.currency
                           END RECORD

    DEFINE p_pscd_r ARRAY [99] OF RECORD LIKE pscd.*
    DEFINE p_pscx_r ARRAY [99] OF RECORD LIKE pscx.*

    DEFINE p_payform_5            CHAR(100) -- ���I���Ӫ��Y�w�ͦs   --
          ,p_payform_51           CHAR(100) -- ���I���Ӫ��Y�w���d�ˬd   --
          ,p_payform_52           CHAR(100)
          ,p_payform_6            CHAR(100) -- ���I���Ӫ��Y�w����   --
          ,p_payform_7            CHAR(100) -- �j�v�����Ū���� --
          ,p_payform_8            CHAR(100) -- �j�v�����Ū���� --
          ,p_payform_init         CHAR(100)
          ,p_payform_end_5        CHAR(100) -- �ӿ�����q�w�ͦs     --
          ,p_payform_end_6        CHAR(100) -- �ӿ�����q�w����     --

    DEFINE p_payform_0 ARRAY [11] OF  CHAR(100) -- ���I���Ӫ��榡���Y   --
    DEFINE p_payform_1 ARRAY [11] OF  CHAR(100) -- ���I���Ӣw�ͦs��     --
    DEFINE p_payform_2 ARRAY [13] OF  CHAR(100) -- ���I���Ӣw������     --
    DEFINE p_payform_3 ARRAY [20] OF  CHAR(100) -- �j�v����             --
    DEFINE p_payform_d ARRAY [3]  OF  CHAR(100) -- ���I���Ӣw���q�H���� --
    DEFINE p_payform_e ARRAY [9]  OF  CHAR(100) -- ���I���Ӣw����       --

    DEFINE p_pmms                  RECORD LIKE pmms.*    ----�j�v�����ݨD by yirong 95/01
    DEFINE p_batch_no_pm           LIKE pmms.batch_no_pm ----�j�v�����ݨD by yirong 95/01
    DEFINE p_cmd                   CHAR(100)             ----�j�v�����ݨD by yirong 95/01
    DEFINE  run_cmd1 CHAR(80)
    DEFINE  run_cmd2 CHAR(80)
MAIN

    DEFINE f_rcode INTEGER

    -- Job Control beg --
    CALL JobControl()

    LET f_rcode       =0
    LET p_rpt_beg_date=ARG_VAL(1)
    LET p_rpt_end_date=ARG_VAL(2)
    LET g_program_id = "psc02r"

    CALL get_pm_batch_no() RETURNING p_batch_no_pm       ----�j�v�����ݨD by yirong 95/01
    IF p_batch_no_pm = 0 THEN
       DISPLAY "ñ���渹���ͥ��� !!"
    END IF

    -- ���I���Ӫ� --
    CALL GetDocLname( '2') RETURNING p_name
    CALL psc02r01_init_array()  RETURNING f_rcode
    CALL psc02r01() RETURNING f_rcode
    IF f_rcode !=0 THEN
       DISPLAY "call psc02r01 error !!"
    END IF
{    
    IF p_batch_no_pm > 0 THEN                            ----�j�v�����ݨD by yirong 95/01
       LET p_cmd = "/prod/run/pm011r.4ge ",p_batch_no_pm," ",report_name4
       RUN p_cmd
    END IF
}    
    
    -- Job Control end --
    CALL JobControl()

END MAIN
-------------------------------------------------------------------------------
-- �{���W��:psc02r01
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӻP�������
-- table   :pscb,pscp
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
FUNCTION psc02r01 ()

    DEFINE f_rcode            INTEGER
          ,f_2141_have_data   CHAR(1)    -- �l�H�䲼 --
          ,f_2143_have_data   CHAR(1)    -- ���`�q�� --
          ,f_2825_have_data   CHAR(1)    -- ��ú�O�O --
          ,f_agnt_have_data   CHAR(1)    -- ���^��� --
          ,f_2143_unnormal    CHAR(1)    -- �q�ש��� --
          ,f_0027_have_data   CHAR(1)    -- �٥��^�y --
          ,f_0027_unnormal    CHAR(1)    -- �٥����� --
          ,f_2143_have_data_50   CHAR(1) -- ���`�q��<100�U  --    
          ,f_2143_unnormal_50    CHAR(1) -- �q�ש���>=100�U --
          ,f_cp5_have_data       CHAR(1) -- �D�ʹq�ץ��`<100�U  --
          ,f_cp5_have_data_50    CHAR(1) -- �D�ʹq�ץ��`>=100�U --
          ,f_cp5_unnormal        CHAR(1) -- �D�ʹq�ש���<100�U  --
          ,f_cp5_unnormal_50     CHAR(1) -- �D�ʹq�ש���>=100�U -- 
          ,f_have_data        CHAR(1)
          ,f_pmia_sw          LIKE pmia.pmia_sw  -- �P�_�O�_�l�H
          ,f_have_data_usd   CHAR(1)
          ,f_data_col_usd    CHAR(1)

    DEFINE f_rpt_name_1       CHAR(30)   -- �٥����I���ӳ���   --
    DEFINE f_rpt_name_2       CHAR(30)   -- �٥����I�������   --
    DEFINE f_rpt_name_3       CHAR(30)   -- �j�v����,�l�H�䲼  --
    DEFINE f_rpt_name_4       CHAR(30)   -- �٥����I����q��   --
    DEFINE f_rpt_name_5       CHAR(30)   -- �٥����I����q��_A5 --
    DEFINE f_rpt_name_6       CHAR(30)   -- �j�v�����ݨD by yirong 95/01
    DEFINE f_rpt_name_7       CHAR(30)   -- �^�y���𱱨���� --
    DEFINE f_rpt_name_8       CHAR(30)   -- �٥����I������� >=100�U --
    DEFINE f_rpt_name_9       CHAR(30)   -- �٥����I����q�� >=100�U --
    DEFINE f_rpt_name_10      CHAR(30)   -- �٥����I�@���Be-billing�B�Ȱ��l�H���Ӫ�
    DEFINE f_rpt_name_11      CHAR(30)   -- �ͦs���I�έp����
    DEFINE f_rpt_name_12      CHAR(30)   -- �٥����I���ӳ���~��   --
    DEFINE f_rpt_name_13      CHAR(30)   -- �٥����I�������~��   --
  
    DEFINE f_i                INTEGER    -- ���I���Ӫ���� --
 --   DEFINE f_j                INTEGER    -- ���I���Ӫ���� --
    DEFINE f_pscd_cnt         INTEGER    -- ���I���Ӫ����� --
    DEFINE f_cp_pay_detail_sw CHAR(1)    -- �O�_�����I���� --

    DEFINE f_po_issue_date   LIKE polf.po_issue_date   -- �O��ͮĤ�  --
          ,f_expired_date    LIKE polf.expired_date    -- ������ --
          ,f_expired_sw      CHAR(1)                   -- ���� sw --
          ,f_po_sts_code     LIKE polf.po_sts_code
          ,f_modx            LIKE polf.modx
          ,f_method          LIKE polf.method
          ,f_relation        LIKE benf.relation
          ,f_polf_mail_addr_ind LIKE polf.mail_addr_ind -- SR:PS88217S --
 
    DEFINE f_agent_code      LIKE poag.agent_code      -- �~�ȭ�-ID   --
          ,f_agent_name      LIKE clnt.names           -- �~�ȭ�-name --

    DEFINE f_dept_code       LIKE agnt.dept_code       -- ��~�B�N��  --
          ,f_dept_name       LIKE dept.dept_name       -- ��~�B�W��  --
          ,f_dept_mail       LIKE dept.dept_mail       -- ���q�T�N�X --

    DEFINE f_applicant_id    LIKE pocl.client_id       -- �n�O�H-ID   --
          ,f_applicant_name  LIKE clnt.names           -- �n�O�H-name --
          ,f_client_ident    LIKE pocl.client_ident    -- ���Y�H�ѧO�X --
          ,f_insured_id      LIKE pocl.client_id       -- �Q�O�H-ID   --
          ,f_insured_name    LIKE clnt.names           -- �Q�O�H-name --

    DEFINE f_benf_id         ARRAY[10] OF LIKE pocl.client_id       -- ���q�H-ID   --
          ,f_benf_name       ARRAY[10] OF LIKE clnt.names           -- ���q�H-name --
    DEFINE f_benf_name_all   CHAR(50)

    DEFINE f_zip_code        LIKE addr.zip_code        -- �l���ϸ�    --
          ,f_address         LIKE addr.address         -- �a�}        --
          ,f_tel_1           LIKE addr.tel_1           -- �q�ܸ��X-1  --

    DEFINE f_plan_desc          LIKE pldf.plan_desc    -- �I�شy�z    --
          ,f_cp_chk_sw          LIKE pscr.cp_chk_sw    -- �䲼�I�{�_  --
          ,f_cp_notice_print_sw LIKE pscr.cp_notice_print_sw -- �q���L�_ --
          ,f_cp_form_desc       CHAR(6)

    DEFINE f_t_f                INTEGER
          ,f_dept_adm_no        LIKE dept.dept_code
          ,f_dept_adm_name      LIKE dept.dept_name

    DEFINE f_note_recv_name     LIKE clnt.names   -- ���Ӧ���� --
          ,f_pay_desc           CHAR(10)
          ,f_var_date           INTEGER
          ,f_R3_min_date        CHAR(9)
          ,f_function_code      CHAR(2)   -- ����ƥ����i�J�S��q�� --

    DEFINE f_benf_cmd           CHAR(254) 
    DEFINE f_pscd_cmd           CHAR(254)
    DEFINE f_pscx_cmd           CHAR(254) 
    DEFINE f_item_no            INTEGER     ----�j�v�����ݨD by yirong 95/01
    DEFINE f_j                  INTEGER
    DEFINE f_plan_abbr_code     CHAR(8)     ----�s�WFEL���P�_�I�� by yirong 96/01  
    DEFINE f_ebill_email        LIKE addr.address
    DEFINE f_ebill_zip_ind      CHAR(1)
    DEFINE f_ebill_ind          CHAR(1)
    DEFINE f_mobile_o1          LIKE addr.tel_1
    DEFINE f_email_len          INT
    DEFINE f_sub_stat           CHAR(2)
    DEFINE f_fn_code_desc       CHAR(14) 
    DEFINE f_pay_modx           LIKE arpm.pay_modx   -- 12:�~���I   1:�뵹�I
          ,f_pscu               RECORD LIKE pscu.* 
          ,f_source             CHAR(4)              -- ��ƨӷ�
          ,f_payout_date_from   CHAR(9)
          
    LET f_rcode=0
    LET f_2141_have_data   ="N"
    LET f_2143_have_data   ="N"
    LET f_2143_have_data_50="N"
    LET f_2825_have_data   ="N"
    LET f_0027_have_data   ="N"
    LET f_agnt_have_data   ="N"
    LET f_have_data        ="N"
    LET f_2143_unnormal    ="N"
    LET f_2143_unnormal_50 ="N"
    LET f_0027_unnormal    ="N"
    LET f_var_date         =4
    LET f_plan_abbr_code   =""
    LET f_cp5_have_data    ="N"
    LET f_cp5_have_data_50 ="N"
    LET f_cp5_unnormal     ="N"
    LET f_cp5_unnormal_50  ="N"    
    LET f_have_data_usd        ="N"
    LET f_data_col_usd     ="N"
    LET f_pay_modx         = 0
    LET f_source           =" "
    LET f_payout_date_from =" "
    INITIALIZE f_pscu.* TO NULL

    -- �ͦs�����I���Ӫ� --
    LET p_rpt_code_1    ="psc02r01"
 -- LET f_rpt_name_1    =ReportName(p_rpt_code_1)
    CALL GetReportTitle( p_rpt_code_1, TRUE )
    LET p_rpt_name_1    =g_report_name
--    LET f_rpt_name_1    = PSManagerName('psc02r01')
    LET f_rpt_name_1    = "psc02r01.",p_rpt_end_date[8,9]
 --   LET f_rpt_name_1    ="psc02r01.lst"
    

    -- �ͦs�����I����� --
    LET p_rpt_code_2    ="psc02r02"
 -- LET f_rpt_name_2    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_2, TRUE )
    LET p_rpt_name_2    =g_report_name
    LET f_rpt_name_2    ="psc02r02.lst"

{
    -- �ͦs�����I,�l�H�䲼�j�v������ --
    LET p_rpt_code_3    ="psc02r03"
 -- LET f_rpt_name_3    =ReportName(p_rpt_code_3)
    CALL GetReportTitle( p_rpt_code_3, TRUE )
    LET p_rpt_name_3    =g_report_name
    LET f_rpt_name_3    ="psc02r03.lst"
} 
    LET f_rpt_name_6    = "psc02r06.lst"      ---�j�v�����ݨD by yirong 95/01

    -- �ͦs�����I���Ӫ�_�q�ׯS��@�~ --
    LET p_rpt_code_4    ="psc02r04"
 -- LET f_rpt_name_4    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_4    =g_report_name
    LET f_rpt_name_4    ="psc02r04.lst"

    -- �ͦs�����I���Ӫ�_�q�ׯS��@�~���I���� A4 --
    LET p_rpt_code_5    ="psc02r05"
 -- LET f_rpt_name_5    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_5, TRUE )
    LET p_rpt_name_5    =g_report_name
 --   LET f_rpt_name_5    =PSManagerName('psc02r05')
    LET f_rpt_name_5    = "psc02r05.",p_rpt_end_date[8,9]
 --   LET f_rpt_name_5    ="psc02r05.lst"

    -- �^�y���𱱨���� ---
    LET p_rpt_code_7    ="psc02r07"
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_7    =g_report_name
    LET f_rpt_name_7    ="psc02r07.",p_rpt_end_date[8,9]

        -- �ͦs�����I����� >= 100�U--
    LET p_rpt_code_8    ="psc02r08"
    CALL GetReportTitle( p_rpt_code_2, TRUE )
    LET p_rpt_name_8    =g_report_name
    LET f_rpt_name_8    ="psc02r08.lst"

    -- �ͦs�����I���Ӫ�_�q�ׯS��@�~ >= 100�U--
    LET p_rpt_code_9    ="psc02r09"
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_9    =g_report_name
    LET f_rpt_name_9    ="psc02r09.lst"

    -- �٥����I �@���Be-billing�B�Ȱ��l�H���Ӫ�
    LET p_rpt_code_10    ="psc02r10"
    CALL GetReportTitle( p_rpt_code_10, TRUE )
    LET p_rpt_name_10    =g_report_name
    LET f_rpt_name_10    = "psc02r10.",p_rpt_end_date[8,9]

    -- �ͦs���I�έp����
    LET p_rpt_code_11    ="psc02r11"
    CALL GetReportTitle( p_rpt_code_11, TRUE )
    LET p_rpt_name_11    =g_report_name
    LET f_rpt_name_11    = "psc02r11.",p_rpt_end_date[8,9]

    -- 
    LET p_rpt_code_12    ="psc02r12"
    CALL GetReportTitle( p_rpt_code_12, TRUE )
    LET p_rpt_name_12    =g_report_name
    LET f_rpt_name_12    = "psc02r12.",p_rpt_end_date[8,9]
   
    -- 
    LET p_rpt_code_13    ="psc02r13"
    CALL GetReportTitle( p_rpt_code_13, TRUE )
    LET p_rpt_name_13    =g_report_name
    LET f_rpt_name_13    = "psc02r13.",p_rpt_end_date[8,9]





    LET f_item_no = 0                          ----�j�v�����ݨD by yirong 95/01
    
    -- 105/04/01 �뵹�I�I�ظ�ƨӷ���pscu,�çQ��f_source�Ϥ���ƨӷ�
    --           �]���뵹�I�Ĥ@���]�|��pscb�i�J����A�n������S�ӵ�pscp 
    DECLARE f_s1 CURSOR FOR
            SELECT a.change_date
                  ,a.policy_no
                  ,a.cp_anniv_date
                  ,a.cp_sw
                  ,b.cp_pay_form_type
                  ,b.plan_code
                  ,b.rate_scale
                  ,b.coverage_no
                  ,b.face_amt
                  ,b.paid_to_date
                  ,b.po_issue_date
                  ,b.minus_prem_susp
                  ,b.loan_amt
                  ,b.loan_int_balance
                  ,b.loan_int
                  ,b.apl_amt
                  ,b.apl_int_balance
                  ,b.apl_int
                  ,b.rtn_minus_premsusp
                  ,b.rtn_loan_amt
                  ,b.rtn_loan_int
                  ,b.rtn_apl_amt
                  ,b.rtn_apl_int
                  ,b.prem_susp
                  ,b.accumulated_div
                  ,b.div_int_balance
                  ,b.div_int
                  ,b.cp_amt
                  ,b.cp_chk_date
                  ,b.rtn_rece_no
                  ,b.cp_pay_amt
                  ,a.cp_disb_type
                  ,a.mail_addr_ind
                  ,b.dept_code
                  ,b.agent_code
                  ,a.address
                  ,a.zip_code
                  ,b.currency
                  ,"pscp"
                  ," "
            FROM  pscb a,pscp b
            WHERE change_date  BETWEEN p_rpt_beg_date AND p_rpt_end_date
            AND   a.policy_no    =b.policy_no
            AND   a.cp_anniv_date=b.cp_anniv_date
            AND   a.cp_disb_type in ("0","2","3","4","5","6")
            AND   a.cp_sw in ("2","5")
            AND   b.cp_pay_form_type in ("5","5.1")
       UNION
            SELECT c.change_date
                  ,c.policy_no
                  ,c.cp_anniv_date
                  ,a.cp_sw
                  ,b.cp_pay_form_type
                  ,b.plan_code
                  ,b.rate_scale
                  ,b.coverage_no
                  ,b.face_amt
                  ,b.paid_to_date
                  ,b.po_issue_date
                  ,0                      -- minus_prem_susp
                  ,0                      -- loan_amt
                  ,0                      -- loan_int_balance
                  ,0                      -- loan_int
                  ,0                      -- apl_amt
                  ,0                      -- apl_int_balance
                  ,0                      -- apl_int
                  ,0                      -- rtn_minus_premsusp
                  ,0                      -- rtn_loan_amt
                  ,0                      -- rtn_loan_int
                  ,0                      -- rtn_apl_amt
                  ,0                      -- rtn_apl_int
                  ,0                      -- prem_susp
                  ,0                      -- accumulated_div
                  ,0                      -- div_int_balance
                  ,0                      -- div_int
                  ,c.cp_pay_amt           -- �Ӥ�w�p���I���B
                  ,b.cp_chk_date            
                  ," "                    -- rtn_rece_no 
                  ,c.cp_pay_amt           -- �Ӥ��ڵ��I���B
                  ,a.cp_disb_type
                  ,a.mail_addr_ind
                  ,b.dept_code
                  ,b.agent_code
                  ,a.address
                  ,a.zip_code
                  ,b.currency
                  ,"pscu"
                  ,c.payout_date_from    -- �뵹�I���
            FROM  pscu c,pscb a,pscp b
            WHERE c.change_date  BETWEEN p_rpt_beg_date AND p_rpt_end_date
            AND   c.process_sw   ='1'     -- �w���I 
            AND   c.cp_pay_seq   =1       -- �H�Ĥ@�����H��Ʒ��N��
            AND   c.policy_no    =a.policy_no
            AND   c.cp_anniv_date=a.cp_anniv_date
            AND   a.policy_no    =b.policy_no
            AND   a.cp_anniv_date=b.cp_anniv_date
            AND   a.cp_disb_type in ("0","2","3","4","5","6")
            AND   a.cp_sw in ("2","5")
            AND   b.cp_pay_form_type in ("5","5.1")
      ORDER BY a.cp_disb_type,a.policy_no,a.cp_anniv_date       


    START REPORT cp_pay_dtl      TO f_rpt_name_1
    START REPORT cp_pay_dtl_col  TO f_rpt_name_2
    START REPORT cp_pay_unnormal TO f_rpt_name_4
    START REPORT cp_pay_dtl_un   TO f_rpt_name_5
  --  START REPORT cp_pay_post     TO f_rpt_name_3    --100/11�����²������� by yirong
    START REPORT cp_pay_dtl_col_un  TO f_rpt_name_7
    START REPORT cp_pay_dtl_col_50  TO f_rpt_name_8
    START REPORT cp_pay_unnormal_50 TO f_rpt_name_9
    START REPORT cp_pay_dtl_all TO f_rpt_name_10
    START REPORT cp_pay_dtl_stat TO f_rpt_name_11
    START REPORT cp_pay_dtl_col_usd TO f_rpt_name_12
    START REPORT cp_pay_dtl_usd TO f_rpt_name_13

    FOREACH f_s1 INTO p_cp_pay_detail.*,f_source, f_payout_date_from
--display p_cp_pay_detail.policy_no,'   ',p_cp_pay_detail.currency



       

       LET f_have_data      ="Y"
       LET f_po_issue_date  ="         "

       LET f_agent_code     =" "
       LET f_agent_name     =" "

       LET f_dept_code      =" "
       LET f_dept_name      =" "
       LET f_dept_mail      =" "

       LET f_applicant_id   =" "
       LET f_applicant_name =" "
       LET f_insured_id     =" "
       LET f_insured_name   =" "

       LET f_zip_code       =" "
       LET f_address        =" "
       LET f_tel_1          =" "

       LET f_plan_desc          =" "
       LET f_cp_chk_sw          =" "
       LET f_cp_notice_print_sw =" "
       LET f_cp_form_desc       ="�ͦs��"
       LET f_plan_abbr_code     = "" 

       -- 105/04/01 �뵹�I�I�إu���S�C�뵹�I���B�A�����S�Ӧ~�ת��ٴڸ�T
       LET f_pay_modx = psc99s01_pay_modx(p_cp_pay_detail.policy_no)
       IF f_source = "pscp" AND f_pay_modx = 1 THEN
          CONTINUE FOREACH
       END IF

       -- 105/04/01 �뵹�I�I�خھڶg���P�_����  
       IF f_pay_modx = 1 THEN
       	  LET f_R3_min_date=SubtractDay(f_payout_date_from,f_var_date)
       ELSE
          LET f_R3_min_date=SubtractDay(p_cp_pay_detail.cp_anniv_date,f_var_date)
       END IF
                   
       -- �O��ͮĤ� --
       SELECT  po_issue_date,expired_date,po_sts_code,modx,method
              ,mail_addr_ind
       INTO    f_po_issue_date,f_expired_date,f_po_sts_code
              ,f_modx,f_method
              ,f_polf_mail_addr_ind
       FROM    polf
       WHERE   policy_no=p_cp_pay_detail.policy_no

       ---------------------------------------------------------------
       -- SR:PS88217S pscb ���l�H�� �ťե����Ѧ� polf.mail_addr_ind --
       ---------------------------------------------------------------
       IF p_cp_pay_detail.mail_addr_ind=" " THEN
          LET p_cp_pay_detail.mail_addr_ind=f_polf_mail_addr_ind
       END IF 

       -- �~�ȭ� --
       SELECT  names
       INTO    f_agent_name
       FROM    clnt
       WHERE   client_id=p_cp_pay_detail.agent_code

       -- �n�O�HID,�m�W --
       CALL getNames(p_cp_pay_detail.policy_no,'O1') 
            RETURNING f_applicant_id,f_applicant_name

       -- �Q�O�H --
       SELECT  client_ident
       INTO    f_client_ident
       FROM    colf
       WHERE   policy_no   =p_cp_pay_detail.policy_no
       AND     coverage_no =p_cp_pay_detail.coverage_no

       CALL getNames(p_cp_pay_detail.policy_no,f_client_ident) 
            RETURNING f_insured_id,f_insured_name
       
       -- ��~�B --
       SELECT dept_name  ,dept_mail
       INTO   f_dept_name,f_dept_mail
       FROM   dept
       WHERE  dept_code=p_cp_pay_detail.dept_code

       -- �����q --
       CALL getDBranchoffice(p_cp_pay_detail.dept_code) 
            RETURNING f_t_f
                     ,f_dept_adm_no
                     ,f_dept_adm_name

       IF f_t_f=FALSE THEN
          LET f_dept_adm_no  =" "
          LET f_dept_adm_name=" "
       END IF

       -- �I�ئW�� --
       SELECT plan_desc,plan_abbr_code
       INTO   f_plan_desc,f_plan_abbr_code
       FROM   pldf
       WHERE  plan_code =p_cp_pay_detail.plan_code
       AND    rate_scale=p_cp_pay_detail.rate_scale

       -- �n�O�H�q��    --
       SELECT tel_1
       INTO   f_tel_1
       FROM   addr
       WHERE  client_id=f_applicant_id
       AND    addr_ind =p_cp_pay_detail.mail_addr_ind
 
       IF f_tel_1 IS NULL OR
          f_tel_1 =" "    THEN
          LET f_tel_1="not_found"
       END IF

       LET f_address       =p_cp_pay_detail.address
       LET f_zip_code      =p_cp_pay_detail.zip_code

       -- �n�O�Hemail��T--

       LET f_ebill_email = ''
       LET f_ebill_zip_ind = ''
       LET f_mobile_o1 = ''
       LET f_ebill_ind = '1'

       SELECT�@zip_code[2,2],address,tel_1
       INTO    f_ebill_zip_ind,f_ebill_email,f_mobile_o1
       FROM    addr
       WHERE   client_id=f_applicant_id
       AND     addr_ind = 'E'
       
       IF  STATUS=NOTFOUND THEN   
           LET f_ebill_ind = '1'
       END IF

       LET f_email_len = 0        

       LET f_email_len = LENGTH(f_ebill_email) 
       IF  f_ebill_email IS NULL OR f_ebill_email = '' THEN
    --       OR f_email_len = 0 THEN
           LET f_ebill_ind = '1'
       ELSE 
           IF  f_ebill_zip_ind = '1' THEN
               LET f_ebill_ind = '1'  -- �@��l�H
           ELSE 
               LET f_ebill_ind = '0'  -- e-mail
           END IF   
       END IF   
    

display p_cp_pay_detail.policy_no,p_cp_pay_detail.currency,'--',f_ebill_ind,f_ebill_email
       IF f_expired_date <= p_cp_pay_detail.cp_anniv_date THEN
          LET f_expired_sw="Y"
       ELSE
          LET f_expired_sw="N"
       END IF

       -- �\��X���P�_  --
       IF f_expired_sw="Y" THEN
          -- ������ --
          LET f_pay_desc="�����I�b�B"
          CASE
              WHEN p_cp_pay_detail.cp_disb_type="0"   -- �l�H�䲼 --
                  LET f_function_code="R1"
              WHEN p_cp_pay_detail.cp_disb_type="1"   -- �d�x��� --
                  LET f_function_code="RB"
              WHEN p_cp_pay_detail.cp_disb_type="2"   -- ��ú�O�O --
                  LET f_function_code="R3"
              WHEN p_cp_pay_detail.cp_disb_type="3"   -- �q    �� --
                  IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                     LET f_function_code="R8"
                  ELSE
                     LET f_function_code="R7"
                  END IF
              WHEN p_cp_pay_detail.cp_disb_type="4"   -- ���^��� --
                  LET f_function_code="R5"
              WHEN p_cp_pay_detail.cp_disb_type="6"   -- �٥��^�y --
                  LET f_function_code="RJ"

          END CASE
       ELSE
          -- �ͦs�� --
          CASE
              WHEN p_cp_pay_detail.cp_disb_type="0"   -- �l�H�䲼 --
                  LET f_2141_have_data="Y"
                  LET f_function_code="R2"
                  LET f_pay_desc="�����I�b�B"
              WHEN p_cp_pay_detail.cp_disb_type="1"   -- �d�x��� --
                  LET f_function_code="RC"
                  LET f_pay_desc="�����I�b�B"
              WHEN p_cp_pay_detail.cp_disb_type="2"   -- ��ú�O�O --
                  LET f_2825_have_data="Y"
                  LET f_pay_desc="  ��ú���B"
                  LET f_function_code="R4"
              WHEN p_cp_pay_detail.cp_disb_type="3"   -- �q    �� --
                  LET f_pay_desc="  �q�ת��B"
                  IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                     LET f_function_code="RA"
                  ELSE
                     LET f_function_code="R9"
                  END IF
              WHEN p_cp_pay_detail.cp_disb_type="4"   -- ���^��� --
                  LET f_agnt_have_data="Y"
                  LET f_pay_desc="�����I�b�B"
                  LET f_function_code="R6"
                    WHEN p_cp_pay_detail.cp_disb_type="5"   -- �D�ʹq�� --
                          LET f_pay_desc="  �D�ʹq��"
                          IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                             LET f_function_code="RE"
                          ELSE
                             LET f_function_code="RD"
                          END IF
              WHEN p_cp_pay_detail.cp_disb_type="6"   -- �٥��^�y --
--                  LET f_0027_have_data="Y"
                  LET f_pay_desc="  �٥��^�y"
                  LET f_function_code="RK"
                  IF p_cp_pay_detail.process_date > 
                     p_cp_pay_detail.cp_anniv_date THEN
                     LET f_0027_unnormal="Y"
                  ELSE
                     LET f_0027_have_data="Y" 
                  END IF
          END CASE
       END IF -- �\��X���P�_ --
       {
       -- �l���ϸ�,�a�} --
       IF p_cp_pay_detail.cp_disb_type="1" THEN -- �~�ȭ��N�� --

          SELECT dept_mail INTO f_dept_mail
          FROM   dept
          WHERE  dept_code=f_dept_code

          SELECT address,zip_code
          INTO   f_address,f_zip_code
          FROM   addr
          WHERE  client_id=f_dept_mail
          AND    addr_ind="0"

          LET f_note_recv_name=f_agent_name

       ELSE

          LET f_note_recv_name=f_applicant_name

          -- �O��n�O�H�a�} --
          SELECT address,zip_code
          INTO   f_address,f_zip_code
          FROM   addr
          WHERE  client_id=f_applicant_id
          AND    addr_ind =p_cp_pay_detail.mail_addr_ind

          IF f_address IS NULL OR
             f_address =" "    THEN
             LET f_address="�䤣������a�}"
             LET f_zip_code="non"
          END IF 

       END IF  -- �~�ȭ��N�� --
       }

       -- ���q�H --
       IF f_expired_sw="Y" THEN
          LET f_relation="M"
       ELSE
          LET f_relation="L"
       END IF
       
       FOR f_i = 1 TO 10
           LET f_benf_id[f_i]    = NULL
           LET f_benf_name[f_i]  = NULL
       END FOR
       LET f_benf_name_all = NULL
       LET f_i = 1
       
       -- 105/04/01 �뵹�I��qpscu����
       IF f_pay_modx = 1 THEN
       	  DECLARE pscu_cur_1 CURSOR FOR
             SELECT client_id, names
             FROM   pscu
             WHERE  policy_no        = p_cp_pay_detail.policy_no
             AND    cp_anniv_date    = p_cp_pay_detail.cp_anniv_date
             AND    payout_date_from = f_payout_date_from
             ORDER BY cp_pay_seq
          FOREACH pscu_cur_1 INTO f_benf_id[f_i],f_benf_name[f_i]
       	     IF f_i=1 THEN
                LET f_benf_name_all=f_benf_name[f_i]
             ELSE
                LET f_benf_name_all=f_benf_name_all CLIPPED," ",f_benf_name[f_i]
             END IF
             LET f_i = f_i + 1
          END FOREACH
       ELSE
          DECLARE benf_cur CURSOR FOR
             SELECT client_id, names
             FROM   benf
             WHERE  policy_no   = p_cp_pay_detail.policy_no
             AND    coverage_no = 0
             AND    relation    = f_relation
          FOREACH benf_cur INTO f_benf_id[f_i]
                               ,f_benf_name[f_i]
             IF length(f_benf_id[f_i] CLIPPED) !=0 THEN
                SELECT names INTO f_benf_name[f_i]
                FROM   clnt
                WHERE  client_id=f_benf_id[f_i]
             END IF
             IF f_i=1 THEN
                LET f_benf_name_all=f_benf_name[f_i]
             ELSE
                LET f_benf_name_all=f_benf_name_all CLIPPED," ",f_benf_name[f_i]
             END IF
             LET f_i = f_i + 1
          END FOREACH
       END IF
       
       IF f_benf_name[1] IS NULL THEN
          IF f_benf_id[1] IS NULL THEN
             LET f_benf_name[1] =f_applicant_name
             LET f_benf_name_all=f_applicant_name
          ELSE
             SELECT names
             INTO   f_benf_name[1]
             FROM   clnt
             WHERE  client_id=f_benf_id[1]

             LET f_benf_name_all=f_benf_name[1]
          END IF
       END IF

       IF p_cp_pay_detail.cp_disb_type="0" THEN
          LET f_note_recv_name=f_benf_name[1]
       ELSE
          LET f_note_recv_name=f_applicant_name
       END IF

       IF p_cp_pay_detail.cp_pay_form_type="5"   OR
          p_cp_pay_detail.cp_pay_form_type="5.1" THEN
          LET f_cp_form_desc="�ͦs��"
       ELSE
          LET f_cp_form_desc="������"
       END IF

{
       LET f_pscd_cmd="SELECT  * FROM pscd "
                     ,"WHERE policy_no= ?  "
                     ,"AND   cp_anniv_date= ?"
                     ,"ORDER BY cp_pay_seq"

       PREPARE pscd_pre FROM f_pscd_cmd
       DECLARE pscd_cur CURSOR FOR pscd_pre

       LET f_pscx_cmd="SELECT  * FROM pscx "
                     ,"WHERE policy_no= ?  "
                     ,"AND   cp_anniv_date= ?"
                     ,"ORDER BY cp_pay_seq"

       PREPARE pscx_pre FROM f_pscx_cmd
       DECLARE pscx_cur CURSOR FOR pscx_pre
}

       FOR f_i=1 TO 99
           LET p_pscd_r[f_i].policy_no     =" "
           LET p_pscd_r[f_i].cp_anniv_date ="   /  /  "
           LET p_pscd_r[f_i].cp_pay_cnt    =0
           LET p_pscd_r[f_i].cp_pay_seq    =0
           LET p_pscd_r[f_i].cp_pay_amt    =0
           LET p_pscd_r[f_i].names         =" "
           LEt p_pscd_r[f_i].benf_ratio    =0
           LET p_pscd_r[f_i].cp_real_payamt=0
           LET p_pscd_r[f_i].remit_bank    =" "
           LET p_pscd_r[f_i].remit_branch  =" "
           LET p_pscd_r[f_i].remit_account =" "
           LET p_pscd_r[f_i].disb_no       =" "

           LET p_pscx_r[f_i].policy_no     =" "
           LET p_pscx_r[f_i].cp_anniv_date ="   /  /  "
           LET p_pscx_r[f_i].cp_pay_cnt    =0
           LET p_pscx_r[f_i].cp_pay_seq    =0
           LET p_pscx_r[f_i].cp_pay_amt    =0
           LET p_pscx_r[f_i].names         =" "
           LEt p_pscx_r[f_i].benf_ratio    =0
           LET p_pscx_r[f_i].cp_real_payamt=0
           LET p_pscx_r[f_i].bank_code     =" "
           LET p_pscx_r[f_i].bank_account_e  =" "
           LET p_pscx_r[f_i].payee_e       =" "
           LET p_pscx_r[f_i].disb_no       =" "

       END FOR

       LET f_i=0
       LET f_j=0
       LET f_pscd_cnt=0
 
       -- 105/04/01 �뵹�I��qpscu����
       IF f_pay_modx = 1 THEN
       	  DECLARE pscu_cur_2 CURSOR FOR
             SELECT *
             FROM   pscu
             WHERE  policy_no        = p_cp_pay_detail.policy_no
             AND    cp_anniv_date    = p_cp_pay_detail.cp_anniv_date
             AND    payout_date_from = f_payout_date_from
             ORDER BY cp_pay_seq     
          FOREACH pscu_cur_2 INTO f_pscu.*
          	
          	 LET f_i=f_i+1
          	 
          	 IF f_pscu.currency = 'TWD' THEN
                LET p_pscd_r[f_i].policy_no           = f_pscu.policy_no        
                LET p_pscd_r[f_i].cp_anniv_date       = f_pscu.cp_anniv_date    
                LET p_pscd_r[f_i].cp_pay_cnt          = f_pscu.cp_pay_cnt       
                LET p_pscd_r[f_i].cp_pay_seq          = f_pscu.cp_pay_seq       
                LET p_pscd_r[f_i].currency            = f_pscu.currency         
                LET p_pscd_r[f_i].cp_pay_amt          = f_pscu.cp_pay_amt       
                LET p_pscd_r[f_i].names               = f_pscu.names            
                LET p_pscd_r[f_i].benf_ratio          = f_pscu.benf_ratio       
                LET p_pscd_r[f_i].cp_real_payamt      = f_pscu.cp_real_payamt   
                LET p_pscd_r[f_i].remit_bank          = f_pscu.remit_bank       
                LET p_pscd_r[f_i].remit_branch        = f_pscu.remit_branch     
                LET p_pscd_r[f_i].remit_account       = f_pscu.remit_account    
                LET p_pscd_r[f_i].disb_no             = f_pscu.disb_no          
                LET p_pscd_r[f_i].client_id           = f_pscu.client_id        
             ELSE                       
                LET p_pscx_r[f_i].policy_no           = f_pscu.policy_no       
                LET p_pscx_r[f_i].cp_anniv_date       = f_pscu.cp_anniv_date   
                LET p_pscx_r[f_i].cp_pay_cnt          = f_pscu.cp_pay_cnt      
                LET p_pscx_r[f_i].cp_pay_seq          = f_pscu.cp_pay_seq      
                LET p_pscx_r[f_i].currency            = f_pscu.currency        
                LET p_pscx_r[f_i].cp_pay_amt          = f_pscu.cp_pay_amt      
                LET p_pscx_r[f_i].client_id           = f_pscu.client_id       
                LET p_pscx_r[f_i].names               = f_pscu.names           
                LET p_pscx_r[f_i].benf_ratio          = f_pscu.benf_ratio      
                LET p_pscx_r[f_i].cp_real_payamt      = f_pscu.cp_real_payamt  
                LET p_pscx_r[f_i].bank_code           = f_pscu.bank_code       
                LET p_pscx_r[f_i].swift_code          = f_pscu.swift_code      
                LET p_pscx_r[f_i].bank_name_e         = f_pscu.bank_name_e     
                LET p_pscx_r[f_i].bank_account_e      = f_pscu.bank_account_e  
                LET p_pscx_r[f_i].payee_e             = f_pscu.payee_e         
                LET p_pscx_r[f_i].bank_address_e      = f_pscu.bank_address_e  
                LET p_pscx_r[f_i].disb_no             = f_pscu.disb_no         
             END IF
          	 
             INITIALIZE f_pscu.* TO NULL
          END FOREACH
          
          IF f_i=0 THEN -- �L���q�H 
             LET f_cp_pay_detail_sw="0"
          ELSE
             LET f_cp_pay_detail_sw="1"
          END IF
          LET f_pscd_cnt=f_i
       ELSE
          IF p_cp_pay_detail.currency = 'TWD' THEN
          
             LET f_pscd_cmd="SELECT  * FROM pscd "
                        ,"WHERE policy_no= ?  "
                        ,"AND   cp_anniv_date= ?"
                        ,"ORDER BY cp_pay_seq"
          
             PREPARE pscd_pre FROM f_pscd_cmd
             DECLARE pscd_cur CURSOR FOR pscd_pre
          
             OPEN pscd_cur USING p_cp_pay_detail.policy_no
                      ,p_cp_pay_detail.cp_anniv_date
          
             WHILE 1=1
                 LET f_i=f_i+1
                 FETCH pscd_cur INTO p_pscd_r[f_i].*
                 IF STATUS=NOTFOUND THEN
                    EXIT WHILE
                 END IF
             END WHILE
             CLOSE pscd_cur
          
             IF f_i=1 THEN
                LET f_cp_pay_detail_sw="0"
             ELSE
                LET f_cp_pay_detail_sw="1"
                LET f_pscd_cnt=f_i-1
             END IF
          
          ELSE
          
             LET f_pscx_cmd="SELECT  * FROM pscx "
                        ,"WHERE policy_no= ?  "
                        ,"AND   cp_anniv_date= ?"
                        ,"ORDER BY cp_pay_seq"
          
             PREPARE pscx_pre FROM f_pscx_cmd
             DECLARE pscx_cur CURSOR FOR pscx_pre
          
          
             OPEN pscx_cur USING p_cp_pay_detail.policy_no
                             ,p_cp_pay_detail.cp_anniv_date
          
             WHILE 1=1
                 LET f_j=f_j+1
                 FETCH pscx_cur INTO p_pscx_r[f_j].*
                 IF STATUS=NOTFOUND THEN
                    EXIT WHILE
                 END IF
             END WHILE
             CLOSE pscx_cur
          
             IF f_j=1 THEN
                LET f_cp_pay_detail_sw="0"
             ELSE
                LET f_cp_pay_detail_sw="1"
                LET f_pscd_cnt=f_j-1
             END IF
DISPLAY p_pscx_r[1].policy_no,'   ',p_pscx_r[1].disb_no
          END IF
       END IF
display 'f_pscd_cnt= ',f_pscd_cnt
       IF ill_addr(p_cp_pay_detail.policy_no, f_applicant_id, f_polf_mail_addr_ind, 2, g_program_id, p_rpt_beg_date, p_rpt_end_date ) THEN
          LET f_pmia_sw = "Y"
  --      display 'policy_no=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia_y=', f_pmia_sw
       ELSE
          LET f_pmia_sw = " "
  --      display 'policy_no=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia_n=', f_pmia_sw
       END IF
       --------------
       OUTPUT TO REPORT cp_pay_dtl_all (
                                 p_cp_pay_detail.policy_no
                                ,f_benf_name_all
                                ,p_cp_pay_detail.cp_anniv_date
                                ,p_cp_pay_detail.plan_code
                                ,p_cp_pay_detail.face_amt
                                ,p_cp_pay_detail.cp_amt
                                ,p_cp_pay_detail.cp_pay_amt
                                ,f_ebill_ind                     -- ebill����
                                ,f_pmia_sw                       -- �L�Ħa�}����
                                )
      IF f_function_code = 'R2' OR
         f_function_code = 'R4' OR
         f_function_code = 'R6' THEN
         LET f_fn_code_desc = f_function_code
         LET f_sub_stat = 'S1'
      ELSE
         IF f_function_code = 'R9' THEN
            IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN  
               LET f_fn_code_desc = 'R9<100�U'
            ELSE
               LET f_fn_code_desc = 'R9>=100�U'
            END IF
            LET f_sub_stat = 'S2'
         ELSE
            IF f_function_code = 'RA' THEN
               IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                  LET f_fn_code_desc = 'RA<100�U'
               ELSE
                  LET f_fn_code_desc = 'RA>=100�U'
               END IF
               LET f_sub_stat = 'S3'
            ELSE
               IF f_function_code = 'RD' THEN
                  IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                     LET f_fn_code_desc = 'RD<100�U'
                  ELSE
                     LET f_fn_code_desc = 'RD>=100�U'
                  END IF
                  LET f_sub_stat = 'S4'
               ELSE
                  IF f_function_code = 'RE' THEN
               	     IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                        LET f_fn_code_desc = 'RE<100�U'
                     ELSE
                        LET f_fn_code_desc = 'RE>=100�U'
                     END IF
                     LET f_sub_stat = 'S5'
                  ELSE
                     IF f_function_code='RK' THEN
                        LET f_fn_code_desc = 'RK-�^�y' 
                        LET f_sub_stat = 'S6'
                     ELSE
                        LET f_fn_code_desc = 'OTH'
                        LET f_sub_stat = 'S7'
                     END IF
                  END IF
               END IF
            END IF
         END IF
      END IF   




      OUTPUT TO REPORT cp_pay_dtl_stat (
                                p_cp_pay_detail.currency,
                                f_fn_code_desc,
                                f_sub_stat,
                                p_cp_pay_detail.cp_amt
                                )

      
     IF p_cp_pay_detail.currency != 'TWD' THEN
        IF f_function_code NOT MATCHES 'R[JK]' THEN 
           IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
           ELSE
           	  --SR120800390 cmwang 101/09 �Ne_bill �榡���e��bg_ebill_format�ܼƤ�
              CALL oms_ebill_format(f_dept_code,f_mobile_o1,f_ebill_email[1,50]
                            ,f_ebill_ind,f_applicant_name,f_applicant_id
                            ,p_cp_pay_detail.policy_no) 
              OUTPUT TO REPORT cp_pay_dtl_usd    (p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_zip_code
                                             ,f_address
                                             ,f_applicant_name
                                             ,f_insured_name
                                             ,f_tel_1
                                             ,f_dept_name
                                             ,f_plan_desc
                                             ,f_cp_pay_detail_sw
                                             ,f_benf_name_all
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_pay_desc
                                             ,f_note_recv_name
                                             ,f_dept_adm_name
                                             ,f_pscd_cnt
                                             ,f_plan_abbr_code          --�s�WFEL
                                             ,p_cp_pay_detail.dept_code
                                             ,f_mobile_o1
                                             ,f_ebill_ind
                                             ,f_ebill_email
                                             )                             
           END IF
        END IF
        LET f_data_col_usd = "Y"   
display p_cp_pay_detail.policy_no,'|',f_function_code
        OUTPUT TO REPORT cp_pay_dtl_col_usd (f_have_data
                                             ,p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_applicant_name
                                             ,f_dept_name
                                             ,f_cp_pay_detail_sw
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_note_recv_name
                                             ,f_agent_name
                                             ,f_pscd_cnt
                                             ,f_po_sts_code
                                             ,f_modx
                                             ,f_method
                                             ,f_function_code
                                             ,p_cp_pay_detail.* 
                                             )
                
     ELSE
       IF f_function_code="RA"
       OR f_function_code="RE" THEN
             IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
             ELSE
             --SR120800390 cmwang 101/09 �Ne_bill �榡���e��bg_ebill_format�ܼƤ�
               CALL oms_ebill_format(f_dept_code,f_mobile_o1,f_ebill_email[1,50]
                            ,f_ebill_ind,f_applicant_name,f_applicant_id
                            ,p_cp_pay_detail.policy_no)        
                 OUTPUT TO REPORT cp_pay_dtl_un (p_cp_pay_detail.cp_pay_form_type
                                                ,p_cp_pay_detail.policy_no
                                                ,p_cp_pay_detail.cp_anniv_date
                                                ,f_zip_code
                                                ,f_address
                                                ,f_applicant_name
                                                ,f_insured_name
                                                ,f_tel_1
                                                ,f_dept_name
                                                ,f_plan_desc
                                                ,f_cp_pay_detail_sw
                                                ,f_benf_name_all
                                                ,p_cp_pay_detail.cp_disb_type
                                                ,f_pay_desc
                                                ,f_note_recv_name
                                                ,f_dept_adm_name
                                                ,f_pscd_cnt
                                                ,f_plan_abbr_code
                                                ,p_cp_pay_detail.dept_code
                                                ,f_mobile_o1
                                                ,f_ebill_ind
                                                ,f_ebill_email
                                                )
   
               --    display 'address_RARE�n�l�H5=', f_address, ' pmia_n=', f_pmia_sw
             END IF

               IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN

                   IF p_cp_pay_detail.cp_disb_type = '3' THEN
                     LET  f_2143_unnormal = "Y"
                   END IF

                   IF p_cp_pay_detail.cp_disb_type = '5' THEN
                      LET  f_cp5_unnormal = "Y"
                   END IF

                   OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                           ,p_cp_pay_detail.cp_pay_form_type
                                           ,p_cp_pay_detail.policy_no
                                           ,p_cp_pay_detail.cp_anniv_date
                                           ,f_applicant_name
                                           ,f_dept_name
                                           ,f_cp_pay_detail_sw
                                           ,p_cp_pay_detail.cp_disb_type
                                           ,f_note_recv_name
                                           ,f_agent_name
                                           ,f_pscd_cnt
                                           ,f_po_sts_code
                                           ,f_modx
                                           ,f_method
                                           ,f_function_code
                                           ,f_payout_date_from
                                           )
                                              
                ELSE
             
                   IF p_cp_pay_detail.cp_disb_type = '3' THEN
                      LET  f_2143_unnormal_50 = "Y"
                   END IF

                   IF p_cp_pay_detail.cp_disb_type = '5' THEN
                      LET  f_cp5_unnormal_50 = "Y"
                   END IF
             
                   OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                           ,p_cp_pay_detail.cp_pay_form_type
                                           ,p_cp_pay_detail.policy_no
                                           ,p_cp_pay_detail.cp_anniv_date
                                           ,f_applicant_name
                                           ,f_dept_name
                                           ,f_cp_pay_detail_sw
                                           ,p_cp_pay_detail.cp_disb_type
                                           ,f_note_recv_name
                                           ,f_agent_name
                                           ,f_pscd_cnt
                                           ,f_po_sts_code
                                           ,f_modx
                                           ,f_method
                                           ,f_function_code
                                           )
                                        
                END IF

          ELSE


                IF f_function_code MATCHES 'R[JK]' AND
                   p_cp_pay_detail.cp_anniv_date < p_cp_pay_detail.process_date THEN
                   OUTPUT TO REPORT cp_pay_dtl_col_un (f_have_data
                                          ,p_cp_pay_detail.cp_pay_form_type
                                          ,p_cp_pay_detail.policy_no
                                          ,p_cp_pay_detail.cp_anniv_date
                                          ,f_applicant_name
                                          ,f_dept_name
                                          ,f_cp_pay_detail_sw
                                          ,p_cp_pay_detail.cp_disb_type
                                          ,f_note_recv_name
                                          ,f_agent_name
                                          ,f_pscd_cnt
                                          ,f_po_sts_code
                                          ,f_modx
                                          ,f_method
                                          ,f_function_code
                                          )
                                                 
                ELSE

                   IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN

                      IF p_cp_pay_detail.cp_disb_type = '3' THEN
                         LET f_2143_have_data = "Y"
                      END IF
    
                      IF p_cp_pay_detail.cp_disb_type = '5' THEN
                         LET  f_cp5_have_data = "Y"
                      END IF

                      OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                             ,p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_applicant_name
                                             ,f_dept_name
                                             ,f_cp_pay_detail_sw
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_note_recv_name
                                             ,f_agent_name
                                             ,f_pscd_cnt
                                             ,f_po_sts_code
                                             ,f_modx
                                             ,f_method
                                             ,f_function_code
                                             ,f_payout_date_from
                                             )
                    
                   ELSE

                      IF p_cp_pay_detail.cp_disb_type = '3' THEN
                         LET f_2143_have_data_50 = "Y"
                      END IF

                      IF p_cp_pay_detail.cp_disb_type = '5' THEN
                         LET  f_cp5_have_data_50 = "Y"
                      END IF

                      OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                             ,p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_applicant_name
                                             ,f_dept_name
                                             ,f_cp_pay_detail_sw
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_note_recv_name
                                             ,f_agent_name
                                             ,f_pscd_cnt
                                             ,f_po_sts_code
                                             ,f_modx
                                             ,f_method
                                             ,f_function_code
                                             )                           

                  END IF

            END IF

             IF f_function_code NOT MATCHES 'R[JK26]' THEN
                 IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
                 ELSE
                 --SR120800390 cmwang 101/09 �Ne_bill �榡���e��bg_ebill_format�ܼƤ�
                 CALL oms_ebill_format(f_dept_code,f_mobile_o1,f_ebill_email[1,50]
                            ,f_ebill_ind,f_applicant_name,f_applicant_id
                            ,p_cp_pay_detail.policy_no) 
                    OUTPUT TO REPORT cp_pay_dtl    (p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_zip_code
                                             ,f_address
                                             ,f_applicant_name
                                             ,f_insured_name
                                             ,f_tel_1
                                             ,f_dept_name
                                             ,f_plan_desc
                                             ,f_cp_pay_detail_sw
                                             ,f_benf_name_all
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_pay_desc
                                             ,f_note_recv_name
                                             ,f_dept_adm_name
                                             ,f_pscd_cnt
                                             ,f_plan_abbr_code          --�s�WFEL�I�����O by yirong
                                             ,p_cp_pay_detail.dept_code
                                             ,f_mobile_o1
                                             ,f_ebill_ind
                                             ,f_ebill_email
                                             )
         
                 END IF

             END IF
       END IF
       -- �j�v����,�l�H�䲼  --
       IF p_cp_pay_detail.cp_disb_type ="0"  OR
          p_cp_pay_detail.cp_disb_type ="4"  THEN


          IF f_cp_pay_detail_sw="1" THEN
             IF  p_batch_no_pm > 0 THEN
                 FOR f_j = 1 TO f_pscd_cnt
                      
                     IF  p_pscd_r[f_j].cp_real_payamt !=0 AND p_cp_pay_detail.cp_disb_type != "4" THEN
                         LET p_pmms.recipient_type = "3"
                         LET p_pmms.addr_type_pm = "4"
                         LET f_item_no = f_item_no + 1
                         LET p_pmms.batch_no_pm = p_batch_no_pm
                         LET p_pmms.docu_item_no = f_item_no
                         LET p_pmms.mail_reg_no = " "
                         LET p_pmms.policy_no = p_cp_pay_detail.policy_no
                         LET p_pmms.recipient = f_benf_name[f_j]
                         LET p_pmms.zip_code = f_zip_code
                         LET p_pmms.address  = f_address
                         LET p_pmms.mail_type = "1"
                         LET p_pmms.docu_type_pm = "015"
                         LET p_pmms.dept_code = '90000'
                         LET p_pmms.access_user = "oper"
                         LET p_pmms.input_date = p_rpt_end_date 
                         LET p_pmms.mail_user = " "
                         LET p_pmms.mail_date = " " 
                         LET p_pmms.pmms_sts_code = "1"
                         LET p_pmms.process_date = GetDate(TODAY)
                         LET p_pmms.process_time = TIME

                         INSERT INTO pmms VALUES(p_pmms.*)
                         IF  SQLCA.SQLCODE != 0 THEN
                             DISPLAY "pmms insert ���� !!"
                         END IF
                         INITIALIZE p_pmms.* TO NULL
                     END IF
                 END FOR
             END IF
 
 { 
             OUTPUT TO REPORT cp_pay_post (p_cp_pay_detail.cp_pay_form_type
                                          ,p_cp_pay_detail.policy_no
                                          ,p_cp_pay_detail.cp_anniv_date
                                          ,f_zip_code
                                          ,f_address
                                          ,f_applicant_name
                                          ,p_cp_pay_detail.cp_disb_type
                                          ,f_benf_name[1]
                                          ,f_benf_name[2]
                                          ,f_benf_name[3]
                                          ,f_benf_name[4]
                                          ,f_pscd_cnt
                                          )
                                          
  }
          END IF
       END IF

       IF p_batch_no_pm > 0 THEN                            ----�j�v�����ݨD by yirong 95/01
          LET p_cmd = "/prod/run/pm011r.4ge ",p_batch_no_pm," ",f_rpt_name_6  --�W�u��}��
--          LET p_cmd = "/devp/run/pm011r.4ge ",p_batch_no_pm," ",f_rpt_name_6  --���ե�
          RUN p_cmd
       END IF
    END IF

    END FOREACH



--------------------------------------------------



    FREE f_s1
    
    -- �L�l�H�䲼 --
    IF f_2141_have_data="N" THEN
       LET f_function_code="R2"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="0"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

    END IF

    -- �L���^��� --
    IF f_agnt_have_data="N" THEN
       LET f_function_code="R6"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="4"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

    END IF

    -- �L��ú�O�O --
    IF f_2825_have_data="N" THEN
       LET f_function_code="R4"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="2"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

    END IF

    -- �L�q��,�@�� --
    IF f_2143_have_data="N" THEN
       LET f_function_code="R9"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

       
    END IF

    IF f_2143_have_data_50 ="N" THEN
       LET f_function_code="R9"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       )

    END IF

    -- �L�D�ʹq��,�@�� --
    IF f_cp5_have_data="N" THEN
       LET f_function_code="RD"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

    END IF

    IF f_cp5_have_data_50 ="N" THEN
       LET f_function_code="RD"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       )

    END IF


    -- �L�٥��^�y --
    IF f_0027_have_data="N" THEN
       LET f_function_code="RK"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="6"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

    END IF


    -- �L�q��,���� --
    IF f_2143_unnormal ="N" THEN
       LET f_function_code="RA"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        ,f_payout_date_from
                                        )

    END IF
    IF f_2143_unnormal_50 ="N" THEN
       LET f_function_code="RA"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        )


    END IF

    -- �L�D�ʹq��,���� --
    IF f_cp5_unnormal ="N" THEN
       LET f_function_code="RE"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        ,f_payout_date_from
                                        )

    END IF
    IF f_cp5_unnormal_50 ="N" THEN
       LET f_function_code="RE"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        )

    END IF



    -- �L�^�y,���� --
    IF f_0027_unnormal ="N" THEN
       LET f_function_code="RK"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="6"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_un (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        )



    END IF

    -- �L�^�y,���� --
    IF f_data_col_usd ="N" THEN
       LET f_function_code=""
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type=""
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_usd (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        ,p_cp_pay_detail.*
                                        )



    END IF


    FINISH REPORT cp_pay_dtl
    FINISH REPORT cp_pay_dtl_un
    FINISH REPORT cp_pay_dtl_col
    FINISH REPORT cp_pay_unnormal
 --   FINISH REPORT cp_pay_post
    FINISH REPORT cp_pay_dtl_col_un
    FINISH REPORT cp_pay_dtl_col_50
    FINISH REPORT cp_pay_unnormal_50
    FINISH REPORT cp_pay_dtl_all
    FINISH REPORT cp_pay_dtl_stat
    FINISH REPORT cp_pay_dtl_usd
    FINISH REPORT cp_pay_dtl_col_usd
    
    LET     run_cmd1 = "psmanager ", f_rpt_name_1
        RUn     run_cmd1
    LET     run_cmd1 = "psmanager ", f_rpt_name_5
        RUn     run_cmd1
    LET     run_cmd1 = "psmanager ", f_rpt_name_13
        RUn     run_cmd1


    RETURN f_rcode


END FUNCTION
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӦC�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl    (r_cp_pay_form_type -- ���I�榡 --
                     ,r_policy_no        -- �O�渹�X --
                     ,r_cp_anniv_date    -- �٥��g�~�� --
                     ,r_zip_code         -- �l���ϸ� --
                     ,r_address          -- �l�H�a�} --
                     ,r_applicant_name   -- �n�O�H   --
                     ,r_insured_name     -- �Q�O�I�H --
                     ,r_tel_1            -- �n�O�H�p���q�� --
                     ,r_dept_name        -- ��~�B   --
                     ,r_plan_desc        -- �I�ػ��� --
                     ,r_cp_pay_detail_sw -- �C�L���q�H���� --
                     ,r_benf_name_all    -- ���q�H�m�W --
                     ,r_cp_disb_type     -- ���I�覡   --
                     ,r_pay_desc         -- ���I����   --
                     ,r_recv_note_name   -- ����H�m�W --
                     ,r_dept_adm_name    -- �����q�W�� --
                     ,r_pscd_cnt         -- ���q�H���ӵ��� --
                     ,r_plan_abbr_code   -- �I��²��
                     ,r_dept_code        -- �����N�X
                     ,r_mobile_o1        -- �n�O�H��� 
                     ,r_ebill_ind        -- ebill����
                     ,r_ebill_email      -- �n�O�Hemail 
                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- ���q�H���ӵ��� --
           ,r_plan_abbr_code      LIKE pldf.plan_abbr_code
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address
           ,r_pmia_sw            LIKE pmia.pmia_sw

    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
        --SR120800390 cmwang 101/09 
--              PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|"
              PRINT g_ebill_format
        -----------------------------------------------------------     
--              PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
--                    ASCII 27,"90033",ASCII 27,"80060"
              PRINT ASCII 126,"IT26G2;"
              SKIP 10 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  �g�˱�"

              SKIP  5 LINES

        BEFORE GROUP OF r_cp_disb_type 
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no         
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           --  �ͦs ���I���Ӱ򥻸�ƦC�L p_payform_0 --

           IF  r_plan_abbr_code = 'FEL' THEN 
               LET p_payform_0[2]=p_payform_51
           ELSE
               LET p_payform_0[2]=p_payform_5
           END IF
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt 
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
              --    PRINT ASCII 27,"612"
                    PRINT ASCII 126,"IX1W2Z2FK;" 
               ELSE
                  IF r_i=3 THEN
                --     PRINT ASCII 27,"611",ASCII 27,"90036"
                --         ,ASCII 27,"80067"
                     PRINT ASCII 126,"IX9G2;"
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           -- �C�L���I���e --
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_1[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[2] 
           IF  r_plan_abbr_code = "FEL" THEN
               LET r_payform_var[12,35] = "���I���d�ˬd�O�I���p�U�G"
           ELSE
               LET r_payform_var[12,35] = "���I�ͦs�O�I���p�U�G    "
           END IF
--           display r_policy_no,r_payform_var
           LET p_payform_1[2]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[4]

           IF  r_plan_abbr_code = "FEL" THEN
               LET r_payform_var[17,24] = "���d�ˬd"
           ELSE
               LET r_payform_var[17,24] = "    �ͦs"
           END IF
           LET r_payform_var[50,60]=p_cp_pay_detail.cp_amt
                                    USING "###,###,###"
           LET p_payform_1[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[5]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "###,###,###"
           LET p_payform_1[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[6]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "###,###,###"
           LET p_payform_1[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[7]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "###,###,###"
           LET p_payform_1[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[8]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "###,###,###"
           LET p_payform_1[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[9]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "###,###,###"
           LET p_payform_1[9] =r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[10]
           LET r_payform_var[21,30]=r_pay_desc
           LET r_payform_var[40,48]="        "
           LET r_payform_var[50,60]=p_cp_pay_detail.cp_pay_amt
                                    USING "###,###,##&"
           LET p_payform_1[10]=r_payform_var
           LET r_payform_var =p_payform_init

           FOR r_i =1 TO 11
               PRINT COLUMN  1,p_payform_1[r_i] CLIPPED
           END FOR

           -- �C�L���q�H���I���� --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                     PRINT COLUMN  6,p_pscd_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscd_r[r_i].names[1,20]   ,
                           COLUMN 33,p_pscd_r[r_i].benf_ratio
                                     USING "##&",
                           COLUMN 38,p_pscd_r[r_i].cp_real_payamt
                                     USING "----,---,--&",
                           COLUMN 50,"��",
                           COLUMN 53,p_pscd_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account[1,7], 'xxx',
                                        p_pscd_r[r_i].remit_account[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- �C�L���Ӫ��� --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var
           LET p_payform_e[5]=p_payform_init

           FOR r_i =1 TO 9
  --             IF r_i=9  THEN
  --                PRINT ASCII 27,"E"
  --             ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
  --             END IF
           END FOR
        
         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl �ͦs/�������I����  --
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_un
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӦC�L,�q�ש�����Ӫ�
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_un (r_cp_pay_form_type -- ���I�榡 --
                     ,r_policy_no        -- �O�渹�X --
                     ,r_cp_anniv_date    -- �٥��g�~�� --
                     ,r_zip_code         -- �l���ϸ� --
                     ,r_address          -- �l�H�a�} --
                     ,r_applicant_name   -- �n�O�H   --
                     ,r_insured_name     -- �Q�O�I�H --
                     ,r_tel_1            -- �n�O�H�p���q�� --
                     ,r_dept_name        -- ��~�B   --
                     ,r_plan_desc        -- �I�ػ��� --
                     ,r_cp_pay_detail_sw -- �C�L���q�H���� --
                     ,r_benf_name_all    -- ���q�H�m�W --
                     ,r_cp_disb_type     -- ���I�覡   --
                     ,r_pay_desc         -- ���I����   --
                     ,r_recv_note_name   -- ����H�m�W --
                     ,r_dept_adm_name    -- �����q�W�� --
                     ,r_pscd_cnt         -- ���q�H���ӵ��� --
                     ,r_plan_abbr_code   -- 96/01�s�WFEL���d�ˬd--
                     ,r_dept_code        -- �����N�X
                     ,r_mobile_o1        -- �n�O�H���
                     ,r_ebill_ind        -- ebill����
                     ,r_ebill_email      -- �n�O�Hemail

                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- ���q�H���ӵ��� --
           ,r_plan_abbr_code      LIKE pldf.plan_abbr_code
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address


    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
         --SR120800390 cmwang 101/09
  --            PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|"
                PRINT g_ebill_format
                -----------------------------------------------------------   
    --          PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
    --                ASCII 27,"90033",ASCII 27,"80060"
                PRINT ASCII 126,"IT26G2;"
              SKIP 10 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  �g�˱�"

              SKIP  5 LINES

        BEFORE GROUP OF r_cp_disb_type 
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no         
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           --  �ͦs ���I���Ӱ򥻸�ƦC�L p_payform_0 --
           IF  r_plan_abbr_code = 'FEL' THEN
               LET p_payform_0[2]=p_payform_51
           ELSE
               LET p_payform_0[2]=p_payform_5
           END IF
 

--           LET p_payform_0[2]=p_payform_5
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
          --        PRINT ASCII 27,"612"
                  PRINT ASCII 126,"IX1W2Z2FK;"
               ELSE
                  IF r_i=3 THEN
          --           PRINT ASCII 27,"611",ASCII 27,"90036"
          --                ,ASCII 27,"80067"
                  PRINT ASCII 126,"IX9G2;"   
 
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           -- �C�L���I���e --
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_1[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[2]
           IF  r_plan_abbr_code = "FEL" THEN
               LET r_payform_var[12,35] = "���I���d�ˬd�O�I���p�U�G"
           ELSE
               LET r_payform_var[12,35] = "���I�ͦs�O�I���p�U�G    "
           END IF
--          display r_policy_no,r_payform_var
           LET p_payform_1[2]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[4]

           IF  r_plan_abbr_code = "FEL" THEN
               LET r_payform_var[17,24] = "���d�ˬd"
           ELSE
               LET r_payform_var[17,24] = "    �ͦs"
           END IF

           LET r_payform_var[50,60]=p_cp_pay_detail.cp_amt
                                    USING "###,###,###"
           LET p_payform_1[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[5]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "###,###,###"
           LET p_payform_1[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[6]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "###,###,###"
           LET p_payform_1[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[7]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "###,###,###"
           LET p_payform_1[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[8]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "###,###,###"
           LET p_payform_1[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[9]
           LET r_payform_var[50,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "###,###,###"
           LET p_payform_1[9] =r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[10]
           LET r_payform_var[21,30]=r_pay_desc
           LET r_payform_var[40,48]="        "
           LET r_payform_var[50,60]=p_cp_pay_detail.cp_pay_amt
                                    USING "###,###,##&"
           LET p_payform_1[10]=r_payform_var
           LET r_payform_var =p_payform_init

           FOR r_i =1 TO 11
               PRINT COLUMN  1,p_payform_1[r_i] CLIPPED
           END FOR

           -- �C�L���q�H���I���� --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                     PRINT COLUMN  6,p_pscd_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscd_r[r_i].names[1,20]   ,
                           COLUMN 33,p_pscd_r[r_i].benf_ratio
                                     USING "##&",
                           COLUMN 38,p_pscd_r[r_i].cp_real_payamt
                                     USING "----,---,--&",
                           COLUMN 50,"��",
                           COLUMN 53,p_pscd_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account[1,7], 'xxx',
                                        p_pscd_r[r_i].remit_account[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- �C�L���Ӫ��� --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var
           LET p_payform_e[5]=p_payform_init

           FOR r_i =1 TO 9
       --        IF r_i=9  THEN
       --           PRINT ASCII 27,"E"
       --        ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
       --        END IF
           END FOR
        
         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_un �ͦs/�������I����,�q�ש���  --
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_col
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӱ����C�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_function_code
                      ,r_payout_date_from           
                      )
    
    DEFINE  r_have_data           CHAR(1) 
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)
           ,r_payout_date_from    CHAR(9)

    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        INTEGER -- ���I��    --
          ,r_total_supprem       INTEGER -- ��ú      --
          ,r_total_divamt        INTEGER -- ���Q      --
          ,r_disb_cnt            INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       INTEGER -- �U��      --
          ,r_total_aplamt        INTEGER -- ��ú      --
          ,r_total_minus_supprem INTEGER -- ��ú      --
          ,r_total_realamt       INTEGER -- ��I      --
          ,r_total_cpamt         INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
    
    DEFINE for_100w              VARCHAR(10)
    
    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''

            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                     LET for_100w=''
                            WHEN r_cp_disb_type="5"
                                 LET r_acct_no="21430000"
                                 LET r_disb_desc="�D�ʹq��"
                                 LET for_100w="��100�U"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"
                     LET for_100w=''

            END CASE

        --  LET g_report_corp="�T �� �� �� �H �� �O �I �� �� �� �� �� �q"
            LET g_report_name=p_rpt_name_2
{

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
}
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:�x��",
                  COLUMN 111, "�N    ��:GC60"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN   1, "�뵹�I"      ,  -- 105/04/01
                  COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type 
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE


        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                             +p_cp_pay_detail.rtn_loan_int
               LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                             +p_cp_pay_detail.rtn_apl_int
               LET r_div_amt =p_cp_pay_detail.accumulated_div
                             +p_cp_pay_detail.div_int_balance
                             +p_cp_pay_detail.div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +p_cp_pay_detail.cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +p_cp_pay_detail.prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +p_cp_pay_detail.rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +p_cp_pay_detail.cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,p_cp_pay_detail.po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,p_cp_pay_detail.paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count=r_row_count +1
               
               PRINT COLUMN   1,r_payout_date_from       , -- �뵹�I   -- 105/04/01
                     COLUMN  14,p_cp_pay_detail.plan_code,'-',
                                p_cp_pay_detail.rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                         ,  -- �O�B       --
                     COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                         ,  -- ���I���B   --
                     COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,###,###"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,###,###"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,###,###"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                         USING "###,###,###"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,p_cp_pay_detail.cp_pay_amt USING "###,###,###"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,p_cp_pay_detail.dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1

               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO r_pscd_cnt
                      IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1
--                       LET r_total_realamt=r_total_realamt
--                                          +p_pscd_r[r_i].cp_real_payamt

                         PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- ���q�H --

                               COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����   --
                               COLUMN   46,p_pscd_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t�v --
                               COLUMN   54,p_pscd_r[r_i].cp_real_payamt
                                           USING "###,###,###"          , -- ���t���B --
                               COLUMN   68,p_pscd_r[r_i].remit_bank,'-'
                                          ,p_pscd_r[r_i].remit_branch   , -- �Ȧ�     --
                               COLUMN   78,p_pscd_r[r_i].remit_account  , -- �b��     --
                               COLUMN  112,p_pscd_r[r_i].disb_no          -- �I�ڸ��X --
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30 
               OR r_row_count ==10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count   --�����ӭ��L�X�X�����
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"��U��",SetLine("-",62)
                  PRINT COLUMN 92,"������Ƶ��ơG",r_row_cnt USING "<<<<","��"
                  SKIP TO TOP OF PAGE
               END IF
           END IF

        AFTER GROUP OF r_cp_disb_type

           IF r_acct_no ="28250001" THEN
              LET r_disb_cnt=r_total_cnt
           END IF 

           PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
                 COLUMN  24,"���I��:"   ,r_total_payamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "#,###,###,##&"," ��",
                 COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "#,###,###,##&"," ��"

           PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
                 COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "#,###,###,##&"," ��",
                 COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "#,###,###,##&"," ��",
                 COLUMN 104,"(=)��I:"  ,r_total_realamt USING "#,###,###,##&"," ��"
           SKIP  4 LINE

           PRINT COLUMN   3,"(��)�`�g�z:_____________________",
                 COLUMN  37,  "�����D��:_____________________",
                 COLUMN  68,  "���D��:_____________________",
                 COLUMN  99,    "�дڤH:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col �ͦs���ӱ������ --

-------------------------------------------------------------------------------
-- ����W��:cp_pay_unnormal
-- �@    ��:jessica Chang
-- ��    ��:088/12/14
-- �B�z���n:����/�٥����I���ӱ����C�L
--          �]�䲼���I�{�ϱo���I���᪺���,�q�׸�ƯS��@�~
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_unnormal (r_have_data
                       ,r_cp_pay_form_type
                       ,r_policy_no
                       ,r_cp_anniv_date
                       ,r_applicant_name
                       ,r_dept_name
                       ,r_cp_pay_detail_sw
                       ,r_cp_disb_type
                       ,r_recv_note_name
                       ,r_agent_name
                       ,r_pscd_cnt
                       ,r_po_sts_code
                       ,r_modx
                       ,r_method
                       ,r_function_code
                       ,r_payout_date_from
                       )
    
    DEFINE  r_have_data           CHAR(1) 
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)
           ,r_payout_date_from    CHAR(9)

    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        INTEGER -- ���I��    --
          ,r_total_supprem       INTEGER -- ��ú      --
          ,r_total_divamt        INTEGER -- ���Q      --
          ,r_disb_cnt            INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       INTEGER -- �U��      --
          ,r_total_aplamt        INTEGER -- ��ú      --
          ,r_total_minus_supprem INTEGER -- ��ú      --
          ,r_total_realamt       INTEGER -- ��I      --
          ,r_total_cpamt         INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          
    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''
            
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                     LET for_100w=''
                            WHEN r_cp_disb_type="5"
                                 LET r_acct_no="21430000"
                                 LET r_disb_desc="�D�ʹq��"
                                 LET for_100w="��100�U"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"
                     LET for_100w=''
            END CASE

        --  LET g_report_corp="�T �� �� �� �H �� �O �I �� �� �� �� �� �q"
            LET g_report_name=p_rpt_name_4

{
            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
}
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:�x��",
                  COLUMN 111, "�N    ��:GC62"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN   1, "�뵹�I"      ,  -- 105/04/01
                  COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type 
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE


        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                             +p_cp_pay_detail.rtn_loan_int
               LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                             +p_cp_pay_detail.rtn_apl_int
               LET r_div_amt =p_cp_pay_detail.accumulated_div
                             +p_cp_pay_detail.div_int_balance
                             +p_cp_pay_detail.div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +p_cp_pay_detail.cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +p_cp_pay_detail.prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +p_cp_pay_detail.rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +p_cp_pay_detail.cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,p_cp_pay_detail.po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,p_cp_pay_detail.paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count=r_row_count+1
               PRINT COLUMN   1,r_payout_date_from       , -- �뵹�I   -- 105/04/01
                     COLUMN  14,p_cp_pay_detail.plan_code,'-',
                                p_cp_pay_detail.rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                         ,  -- �O�B       --
                     COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                         ,  -- ���I���B   --
                     COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,###,###"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,###,###"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,###,###"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                         USING "###,###,###"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,p_cp_pay_detail.cp_pay_amt USING "###,###,###"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,p_cp_pay_detail.dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1
               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO r_pscd_cnt
                      IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1
--                       LET r_total_realamt=r_total_realamt
--                                          +p_pscd_r[r_i].cp_real_payamt

                         PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- ���q�H --

                               COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����   --
                               COLUMN   46,p_pscd_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t�v --
                               COLUMN   54,p_pscd_r[r_i].cp_real_payamt
                                           USING "###,###,###"          , -- ���t���B --
                               COLUMN   68,p_pscd_r[r_i].remit_bank,'-'
                                          ,p_pscd_r[r_i].remit_branch   , -- �Ȧ�     --
                               COLUMN   78,p_pscd_r[r_i].remit_account  , -- �b��     --
                               COLUMN  112,p_pscd_r[r_i].disb_no          -- �I�ڸ��X --
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30 
               OR r_row_count  == 10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count   --�����ӭ��L�X�X�����
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"��U��",SetLine("-",62)
                  PRINT COLUMN 92,"������Ƶ��ơG",r_row_cnt USING "<<<<","��"
                  SKIP TO TOP OF PAGE
               END IF
           END IF

        AFTER GROUP OF r_cp_disb_type

           IF r_acct_no ="28250001" THEN
              LET r_disb_cnt=r_total_cnt
           END IF 

           PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
                 COLUMN  24,"���I��:"   ,r_total_payamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "#,###,###,##&"," ��",
                 COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "#,###,###,##&"," ��"

           PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
                 COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "#,###,###,##&"," ��",
                 COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "#,###,###,##&"," ��",
                 COLUMN 104,"(=)��I:"  ,r_total_realamt USING "#,###,###,##&"," ��"
           SKIP  4 LINE

           PRINT COLUMN   3,"(��)�`�g�z:_____________________",
                 COLUMN  37,  "�����D��:_____________________",
                 COLUMN  68,  "���D��:_____________________",
                 COLUMN  99,    "�дڤH:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_unnormal �ͦs���ӱ������ --
{
-------------------------------------------------------------------------------
-- ����W��:cp_pay_post
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:�٥����I���Ӥj�v������C�L-�l�H�䲼
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_post     (r_cp_pay_form_type -- ���I�榡 --
                       ,r_policy_no        -- �O�渹�X --
                       ,r_cp_anniv_date    -- �٥��g�~�� --
                       ,r_zip_code         -- �l���ϸ� --
                       ,r_address          -- �l�H�a�} --
                       ,r_applicant_name   -- �n�O�H   --
                       ,r_cp_disb_type     -- ���I�覡   --
                       ,r_benf_name_1      -- ���q�H�m�W1 --
                       ,r_benf_name_2      -- ���q�H�m�W2 --
                       ,r_benf_name_3      -- ���q�H�m�W3 --
                       ,r_benf_name_4      -- ���q�H�m�W4 --
                       ,r_pscd_cnt         -- ���q�H���� --
                       )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_benf_name_1         LIKE clnt.names
           ,r_benf_name_2         LIKE clnt.names
           ,r_benf_name_3         LIKE clnt.names
           ,r_benf_name_4         LIKE clnt.names
           ,r_pscd_cnt            INTEGER

    DEFINE  r_pageno              INTEGER
    DEFINE  r_addr_1              CHAR(36)
           ,r_addr_2              CHAR(36)

    DEFINE  r_print_sw            CHAR(1)
           ,r_page_count          INTEGER
           ,r_disb_desc           CHAR(8)
           ,r_i                   INTEGER
           ,r_j                   INTEGER
           ,r_last_count          INTEGER
           ,r_payform_var         CHAR(100)
           ,r_print_head_sw       CHAR(1)
           ,r_print_first         CHAR(1)
           ,r_last_row            CHAR(1)
           ,r_recv_note_name      LIKE clnt.names

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

       PAGE HEADER
            IF PAGENO=1 THEN
               LET r_pageno=0
               LET r_page_count=0
            END IF

            CASE
               WHEN r_cp_disb_type="0" -- �l�H�䲼 --
                    LET r_disb_desc="�l�H�䲼"
               WHEN r_cp_disb_type="4" -- �~�ȥN�� --
                    LET r_disb_desc="���^���"
               WHEN r_cp_disb_type="3" -- �q    �� --
                    LET r_disb_desc="�q    ��"
            END CASE

            PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
                  ASCII 27,"90033",ASCII 27,"80060"

            SKIP 4 LINES

            PRINT ASCII 27,"611"

            LET r_pageno=r_pageno+1

            LET r_payform_var=p_payform_init
            LET r_payform_var=p_payform_3[2]
            LET r_payform_var[ 8,20]=r_disb_desc,"-�ͦs"
            LET r_payform_var[80,83]=r_pageno USING "###&"
            LET p_payform_3[2]=r_payform_var
            LET r_payform_var=p_payform_init

            LET r_payform_var=p_payform_3[7]
            LET r_payform_var[70,72]=p_rpt_beg_date[1,3]
            LET r_payform_var[75,76]=p_rpt_beg_date[5,6]
            LET r_payform_var[79,80]=p_rpt_beg_date[8,9]
            LET p_payform_3[7]=r_payform_var

            PRINT COLUMN 1,p_payform_3[1]  CLIPPED
            PRINT COLUMN 1,p_payform_3[2]  CLIPPED
            PRINT COLUMN 1,p_payform_3[3]  CLIPPED
            PRINT COLUMN 1,p_payform_3[4]  CLIPPED
            PRINT COLUMN 1,p_payform_3[5]  CLIPPED
            PRINT COLUMN 1,p_payform_3[6]  CLIPPED
            PRINT COLUMN 1,p_payform_3[7]  CLIPPED
            PRINT COLUMN 1,p_payform_3[8]  CLIPPED
            PRINT COLUMN 1,p_payform_3[9]  CLIPPED
            PRINT COLUMN 1,p_payform_3[10] CLIPPED
            PRINT COLUMN 1,p_payform_3[11] CLIPPED
            PRINT COLUMN 1,p_payform_3[12] CLIPPED
            PRINT COLUMN 1,p_payform_3[13] CLIPPED

       BEFORE GROUP OF r_cp_disb_type 
              LET r_page_count=0
              SKIP TO TOP OF PAGE
 
       ON EVERY ROW

          FOR r_i=1 TO r_pscd_cnt
              IF p_pscd_r[r_i].cp_real_payamt !=0 THEN

                  CASE r_i
                  WHEN 1
                       LET r_recv_note_name = r_benf_name_1
                  WHEN 2
                       LET r_recv_note_name = r_benf_name_2
                  WHEN 3
                       LET r_recv_note_name = r_benf_name_3
                  WHEN 4
                       LET r_recv_note_name = r_benf_name_4
                  END CASE

                 -- �C 20 ���������� --

                  IF r_page_count >= 20 THEN
                     LET r_payform_var=p_payform_init
                     LET r_payform_var=p_payform_3[18]
                     LET r_payform_var[69,71]=r_page_count USING "###"
                     LET p_payform_3[18]=r_payform_var
                     FOR r_j=16 TO 20
                         PRINT COLUMN 1,p_payform_3[r_j] CLIPPED
                     END FOR
                     LET r_page_count=0
                     SKIP TO TOP OF PAGE
                  END IF

                  LET r_page_count=r_page_count+1

                  CALL cut_string (r_address,LENGTH(r_address),36)
                  RETURNING r_addr_1,r_addr_2

                  LET r_payform_var=p_payform_init
                  LET r_payform_var=p_payform_3[14]
                  LET r_payform_var[18,37]=r_recv_note_name
                  LET r_payform_var[40,75]=r_addr_1 
                  LET p_payform_3[14]=r_payform_var

                  LET r_payform_var=p_payform_init
                  LET r_payform_var=p_payform_3[15]
                  LET r_payform_var[18,29]=r_policy_no
                  LET r_payform_var[40,75]=r_addr_2        
                  LET p_payform_3[15]=r_payform_var

                  PRINT COLUMN 1,p_payform_3[14] CLIPPED
                  PRINT COLUMN 1,p_payform_3[15] CLIPPED

              END IF -- p_pscd_r[r_i].cp_real_payamt !=0 --

          END FOR  -- ���i�O����q�H���Ƶ��� --


      AFTER GROUP OF r_cp_disb_type

          -- �Ū����� --

          LET r_last_count=20-r_page_count

          FOR r_i=1 TO r_last_count
              PRINT COLUMN 1,p_payform_7 CLIPPED
              PRINT COLUMN 1,p_payform_7 CLIPPED
          END FOR

          -- �C������ --
          LET r_payform_var=p_payform_init
          LET r_payform_var=p_payform_3[18]
          LET r_payform_var[69,71]=r_page_count USING "###"
          LET p_payform_3[18]=r_payform_var

          FOR r_i=16 TO 20
              PRINT COLUMN 1,p_payform_3[r_i] CLIPPED
          END FOR

          PRINT COLUMN 39,"�С�END�С�"
          LET r_pageno=0

--    ON LAST ROW
--          LET r_last_row="Y"
--          IF r_last_row="Y" THEN
--             PRINT COLUMN 39,"�С�END�С�"
--          END IF

END REPORT -- cp_pay_post     �j�v���� --
}
-------------------------------------------------------------------------------
-- �{���W��:psc02r01_init_array
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӦC�L
--         :���I���Ӯ榡
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
FUNCTION psc02r01_init_array()
    DEFINE f_rcode INTEGER

LET p_payform_5    ="            ��  �s  �O  �I  ��  ��  �b  ��  ��  ��"
LET p_payform_51   ="    ��  �d  ��  �d  �O  �I  ��  ��  �b  ��  ��  ��"
LET p_payform_52   ="                �O  �I  ��  ��  �b  ��  ��  ��    "
LET p_payform_6    ="            ��  ��  �O  �I  ��  ��  �b  ��  ��  ��"
LET p_payform_7    ="     �x        �x                    �x                                            �x"
LET p_payform_init ="                                                  "
                   ,"                                                  "
LET p_payform_0[1] ="ASC II","612"
LET p_payform_0[2] =p_payform_init
LET p_payform_0[3] ="ASC II","611 ","ASC II","90036 ","ASC II","80067"
LET p_payform_0[4] ="     �O�渹�X:xxxxxxxxxxxx         �Q�O�I�H:xxxxxxxxxxxxxxxxxxxx          CPFORM:xxx"
LET p_payform_0[5] ="     �� �q �H:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ���: xxx�~xx��xx��"
LET p_payform_0[6] ="     �O�I���B:x,xxx,xxx,xxx ��     �O�I����:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
LET p_payform_0[7] =p_payform_init
LET p_payform_0[8] ="     �˷R���O��A�z�n�I                                                             "
LET p_payform_0[9] =p_payform_init
LET p_payform_0[10]="     �@  �P�±z��O�T�Ӭ����H�ثO�I�A�Ʊ�ڭ̸ۼ����A�ȯ���o�z�̤j�����N�C         "
LET p_payform_0[11]=p_payform_init

LET p_payform_1[1] ="      �@ �ѩ�z�ҧ�O���O��� xxx �~ xx �� xx ��w�����O��g�~��A�����q�̾ګO�����"
LET p_payform_1[2] ="     ���w�A                                                                         "
LET p_payform_1[3] =p_payform_init
LET p_payform_1[4] ="                        �O�I��                   xxx,xxx,xxx ��                     "
LET p_payform_1[5] ="                          ����:�e����ú          xxx,xxx,xxx ��                     "
LET p_payform_1[6] ="                              :�۰ʹ�ú�O�O�Q��  xxx,xxx,xxx ��                     "
LET p_payform_1[7] ="                              :�۰ʹ�ú�O�O����  xxx,xxx,xxx ��                     "
LET p_payform_1[8] ="                              :�O��ɴڧQ��      xxx,xxx,xxx ��                     "
LET p_payform_1[9] ="                              :�O��ɴڥ���      xxx,xxx,xxx ��                     "
LET p_payform_1[10]="                    xxxxxxxxxx                   xxx,xxx,xxx ��                     "
LET p_payform_1[11]=p_payform_init

LET p_payform_2[1] ="    �@�@ �ѩ�z�ҧ�O���O��� xxx �~ xx �� xx ��O�I���������A�����q�̾ګO����ڬ�  "
LET p_payform_2[2] ="     �w�A���I�����O�I���p�U�G                                                       "
LET p_payform_2[3] =p_payform_init
LET p_payform_2[4] ="                   �����O�I��                    xxx,xxx,xxx ��                     "
LET p_payform_2[5] ="                           �[:�O����Q           xxx,xxx,xxx ��                     "
LET p_payform_2[6] ="                              ��ú               xxx,xxx,xxx ��                     "
LET p_payform_2[7] ="                         ����:�e����ú           xxx,xxx,xxx ��                     "
LET p_payform_2[8] ="                             :�۰ʹ�ú�O�O�Q��   xxx,xxx,xxx ��                     "
LET p_payform_2[9] ="                             :�۰ʹ�ú�O�O����   xxx,xxx,xxx ��                     "
LET p_payform_2[10]="                             :�O��ɴڧQ��       xxx,xxx,xxx ��                     "
LET p_payform_2[11]="                             :�O��ɴڥ���       xxx,xxx,xxx ��                     "
LET p_payform_2[12]="                   �����I�b�B                    xxx,xxx,xxx ��                     "
LET p_payform_2[13]=p_payform_init

LET p_payform_d[1] ="     ���I����:                                                                      "
LET p_payform_d[2] ="     �Ǹ� ���q�H              ��v�H     ���I���B  �I�ڸ��X �״ڻȦ�P�b��          "
LET p_payform_d[3] ="     ---- -------------------- ----- ------------- -------- ------------------------"
{
LET p_payform_d[4] ="     xxxx xxxxxxxxxxxxxxxxxxxx  xxx  xxxx,xxx,xxx�� xxxxxxx xxxxxxx-xxxxxxxxxxxxxxxx"
}
LET p_payform_e[1] ="      �q�|     �� �R                                                                "
LET p_payform_e[2] ="                                                �T�Ӭ����H�ثO�I�ѥ��������q  �Ա�  "
LET p_payform_e[3] ="      �ٴڦ��ڡGxxxxxxxxxx                                                          "
LET p_payform_e[4] ="      �q�T���Gxxxxxxxxxxxxxxxxxxxx                                                "
LET p_payform_e[5] ="      �� �� �q�Gxxxxxxxxxxxxxxxxxxxx                                                "
LET p_payform_e[6] =p_payform_init
LET p_payform_e[7] =p_payform_init
LET p_payform_e[8] =p_payform_init
LET p_payform_e[9] =p_payform_init

-- �j�v���� --
LET p_payform_3[1] ="     �z�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_payform_3[2] ="     �xxxxxxxxx-xxxx           ��  ��  ��  ��  �l  �F                     ���X:xxxx�x"
LET p_payform_3[3] ="     �x                                                                            �x"
LET p_payform_3[4] ="     �x����/�٥� �q���ѱM��                                                        �x"
LET p_payform_3[5] ="     �x                     �j �v �� �q �� �� �� �� �� �� �p                       �x"
LET p_payform_3[6] ="     �x                                                                            �x"
LET p_payform_3[7] ="     �x���إ���          �~     ��     ��                   �@�~���:xxx�~xx��xx�� �x"
LET p_payform_3[8] ="     �x                                                                            �x"
LET p_payform_3[9] ="     �x�H��H�W��:  �T�Ӭ����H�ثO�I���q   �ԲӦa�}: �x�_���H�q�����q150��2��6��   �x"
LET p_payform_3[10]="     �|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"
LET p_payform_3[11]="     �z�w�w�w�w�s�w�w�w�w�w�w�w�w�w�w�s�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_payform_3[12]="     �x�������X�x �� �� �H �m �W     �x    �H          �F            �a            �x"
LET p_payform_3[13]="     ��������������������������������������������������������������������������������"
LET p_payform_3[14]="     �x        �xxxxxxxxxxxxxxxxxxxxx�xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        �x"
LET p_payform_3[15]="     �x        �xxxxxxxxxxxxx        �xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        �x"
LET p_payform_3[16]="     �u�w�w�w�w�r�w�w�w�w�w�w�w�w�w�w�r�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�t"
LET p_payform_3[17]="     �x                                                                            �x"
LET p_payform_3[18]="     �x                                         �W�}���q������/�@   xxx  ��Ӧ��L�~�x"
LET p_payform_3[19]="     �x                                                                            �x"
LET p_payform_3[20]="     �|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"
LET f_rcode=0
RETURN f_rcode
END FUNCTION -- psc02r_init_array --
{
0        1         2         3         4         5         6         7         8         9         a         b         c         d
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
Ez090028800547005
                                     �T  ��  �H  ��  �O  �I  ��  ��  ��  ��  ��  �q
                                  <<<           �ͦs�O�I�����I���ӱ������         >>>
�L���� :  87/07/27                                                                                          �N    ��: GC60
�@�~��� :  87/09/05                        ���I�覡: �l�H�䲼-214101000                                      ��    ��: xxxx
------------------------------------------------------------------------------------------------------------------------------------
�O�渹�X     �n�O�H               PO-�ͮĤ� �g�~��  PO_ST ú�k ���O�覡 �I�{  �䲼���  ú�O�פ�  �ٴڦ���   �~�ȭ�
             �I��                �O�B    ���I���B     (+)��ú     (+)���Q (-)�U�ڥ��Q (-)��ú���Q     (-)��ú  (=)��I���B  �q�T���
             ���q�H                ����   ���q���      ���t���B   �Ȧ�      �b��              �I�ڸ��X
------------------------------------------------------------------------------------------------------------------------------------
xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxx xxx/xx/xx xxx/xx/xx xx    x      x      x   xxx/xx/xx xxx/xx/xx xxxxxxxxxx xxxxxxxxxxxxxxxxxxxxx
             xxxxxxxx-x x,xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx  xxx,xxx,xxx  xxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx

xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxx xxx/xx/xx  xxx/xx/xx   xx     x       x       x    xxx/xx/xx  xxx/xx/xx          xxxxxxxxxx
             xxxxxxxx-x   x,xxx,xxx,xxx  xxx,xxx,xxx  xxx,xxx,xxx  xxx,xxx,xxx   xxx,xxx,xxx   xxx,xxx,xxx  xxx,xxx,xxx xxx,xxx,xxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx-xxxx  xxxxxxxxxxxxxxxx  xxxxxxxx


    �X�p:zzz,zzz ��    ���I��: x,xxx,xxx,xxx ��  (+)��ú: x,xxx,xxx,xxx ��  (+)���Q: x,xxx,xxx,xxx ��
xxxxxxxx:xxx,xxx �� (-)�U  ��: x,xxx,xxx,xxx ��  (-)��ú: x,xxx,xxx,xxx ��  (-)��ú: x,xxx,xxx,xxx ��  (=)��I: x,xxx,xxx,xxx ��

       (��)�`�g�z:______________________ �����D��:___________________���D��:____________________�дڤH:____________________

Ez090028800547005
                                     �T  ��  �H  ��  �O  �I  ��  ��  ��  ��  ��  �q
                                 <<<   �� �s �O �I �� �� �I �� �� �� �� - 21410100  >>>
�L���� :  87/09/08                                                                                          �N ��:GC60
�@�~��� :  87/09/07                        ��J���:[ 87/09/07]                                              ��    1 ��
------------------------------------------------------------------------------------------------------------------------------------
�O�渹�X     �n�O�H                 �O��ͮĤ�    �� �q �H                 �O��g�~��   PO_ST       �I�{        �䲼���
             ���I�I��     �O      �B       ���I��       �U�ڥ��Q      ��ú���Q           ��ú       ��I���B     �ٴڦ���
             ���I�覡  ���ڤH               ���ڤHID   �Ȧ�    �b��           �q�T���     �~�ȭ�            PTD  ���O�覡  ú�k
------------------------------------------------------------------------------------------------------------------------------------
111900010515 �f�Ӵ�                   85/09/20    �f�Ӵ�                     87/09/20     42          Y          00/00/00
             20FED20         500,000       50,000                                                     50,000     000000000
             �l�H�䲼                                                                                    00/00/00              
 

             �X�p:     59��       ���I��:    2,896,007 ��    �U��:            0 ��
         21410100:     59��         ��ú:            0 ��    ��ú:           31 ��        ��I:    2,895,976 ��
 
 
 

(��)�`�g�z:�šššššššššš� �����D��:�ššššššššš� ���D��:�šššššššššš� �дڤH:�ššššššššššš�
Ez090028800547005
                                     �T  ��  �H  ��  �O  �I  ��  ��  ��  ��  ��  �q
                                 <<< �� �� �O �I �� �� �I �� �� �� �� - ���ڤw�I�{  >>>
�L���� :  87/09/08                        ��J���:[ 87/09/07]                                                         �N ��:GC70
�@�~��� : 000/00/00                        ��    ��:[                    ]                                              ��    1 ��
------------------------------------------------------------------------------------------------------------------------------------
�O�渹�X      �n�O�H                �O��ͮĤ�   �� �q �H               �O��g�~��           �I�{     �䲼���
          ���I�I��    �O      �B      ���I��      ��ú      �wú      ���Q    �U�ڥ��Q    ��ú���Q      ��ú    ��I���B   �ٴڦ���
------------------------------------------------------------------------------------------------------------------------------------
  �L���
------------------------------------------------------------------------------------------------------------------------------------

E A z1 90033 80060





                                                                                         �v�v�v�v
                                                                                         �v�v�v�v
                                                                                         �v�v�v�v


          70942

          �O�n���w�n�Ϧw�M���G�q�������Ѣ�����        

                                                      

          �i�Q�f               �g�˱�
                           




612
                            ��  �s  �O  �I  ��  ��  �I  ��  ��
611 90036 80067
     �O�渹�X:174710006282         �Q�O�I�H:�i�Q�f                       CPFORM:5.1 
     �� �q �H:�i�Q�f               �O�I����:�G�Q�~ú�O�պ־i�ѫO�I                  
     �O�I���B:    500,000 ��       �p���q��:06-2566650         ���:  87�~ 9�� 7��

    �@�˷R���O��A�z�n�I

      �@  �P�±z��O�T�ӤH�ثO�I�A�Ʊ�ڭ̸ۼ����A�ȯ���o�z�̤j�����N�C

     �@�@ �ѩ�z�ҧ�O���O���  87 �~  9 ��  4 ��w�����O��g�~��A�����q�̾ګO���
      �ڬ��w�A���I�ͦs�O�I���p�U�G

                        �ͦs�O�I�����I                50,000 ��

                          ����:�e����ú                    0 ��
                              :�۰ʹ�ú�O�O�Q��            0 ��
                              :�۰ʹ�ú�O�O����            0 ��
                              :�O��ɴڧQ��                0 ��
                              :�O��ɴڥ���                0 ��

                      �䲼���B                        50,000 ��


      �q�|     �� �R

                                                    �T�ӤH�ثO�I�ѥ��������q  �Ա�

      �ٴڦ���No: 000000000
      �q�T���  �G����17471�B



      ��ڤHñ��:                          ��  ��:
                 __________________               ___________________
      �䲼���X  :                          �ӿ�H:
                 __________________               ___________________
E

E A z1 90033 80060






611
LET p_payform_3[1] ="     �z�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_payform_3[2] ="     �xxxx                     ��  ��  ��  ��  �l  �F                     ���X:xxxx�x"
LET p_payform_3[3] ="     �x                                                                            �x"
LET p_payform_3[4] ="     �x����/�٥� �q���ѱM��                                                        �x"
LET p_payform_3[5] ="     �x                     �j �v �� �q �� �� �� �� �� �� �p                       �x"
LET p_payform_3[6] ="     �x                                                                            �x"
LET p_payform_3[7] ="     �x���إ���          �~     ��     ��                   �@�~���:xxx�~xx��xx�� �x"
LET p_payform_3[8] ="     �x                                                                            �x"
LET p_payform_3[9] ="     �x�H��H�W��:  �T�ӤH�ثO�I���q   �ԲӦa�}: �x�_���H�q�����q150��2��6��       �x"
LET p_payform_3[10]="     �|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"
LET p_payform_3[11]="     �z�w�w�w�w�s�w�w�w�w�w�w�w�w�w�w�s�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_payform_3[12]="     �x�������X�x �� �� �H �m �W     �x    �H          �F            �a            �x"
LET p_payform_3[13]="     ��������������������������������������������������������������������������������"
LET p_payfrom_3[14]="     �x        �xxxxxxxxxxxxxxxxxxxxx�xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        �x"
LET p_payform_3[15]="     �x        �xxxxxxxxxxxxx        �xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        �x"
LET p_payform_3[16]="     �u�w�w�w�w�r�w�w�w�w�w�w�w�w�w�w�r�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�t"
LET p_payform_3[17]="     �x                                                                            �x"
LET p_payform_3[18]="     �x                                         �W�}���q������/�@   xxx  ��Ӧ��L�~�x"
LET p_payform_3[19]="     �x                                                                            �x"
LET p_payform_3[20]="     �|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"
}
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_col_un
-- �@    ��:yirong
-- ��    ��:098/04/25
-- �B�z���n:�^�y���𱱨��C�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_un (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_function_code
                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)


    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        INTEGER -- ���I��    --
          ,r_total_supprem       INTEGER -- ��ú      --
          ,r_total_divamt        INTEGER -- ���Q      --
          ,r_disb_cnt            INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       INTEGER -- �U��      --
          ,r_total_aplamt        INTEGER -- ��ú      --
          ,r_total_minus_supprem INTEGER -- ��ú      --
          ,r_total_realamt       INTEGER -- ��I      --
          ,r_total_cpamt         INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

            END IF

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�D�ʹq��"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"

            END CASE

        --  LET g_report_corp="�T �� �� �� �H �� �O �I �� �� �� �� �� �q"
            LET g_report_name=p_rpt_name_2
{

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
}
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( '�^�y�P�N/����ŦX��汱�����',132 ),
                          '�^�y�P�N/����ŦX��汱�����' CLIPPED
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:�x��",
                  COLUMN 111, "�N    ��:GC102"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               SKIP TO TOP OF PAGE


        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                             +p_cp_pay_detail.rtn_loan_int
               LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                             +p_cp_pay_detail.rtn_apl_int
               LET r_div_amt =p_cp_pay_detail.accumulated_div
                             +p_cp_pay_detail.div_int_balance
                             +p_cp_pay_detail.div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +p_cp_pay_detail.cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +p_cp_pay_detail.prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +p_cp_pay_detail.rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +p_cp_pay_detail.cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,p_cp_pay_detail.po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,p_cp_pay_detail.paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                                p_cp_pay_detail.rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                         ,  -- �O�B       --
                     COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                         ,  -- ���I���B   --
                     COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,###,###"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,###,###"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,###,###"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                         USING "###,###,###"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,p_cp_pay_detail.cp_pay_amt USING "###,###,###"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,p_cp_pay_detail.dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1

               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO r_pscd_cnt
                      IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1
--                       LET r_total_realamt=r_total_realamt
--                                          +p_pscd_r[r_i].cp_real_payamt

                         PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- ���q

                               COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����
                               COLUMN   46,p_pscd_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t
                               COLUMN   54,p_pscd_r[r_i].cp_real_payamt
                                           USING "###,###,###"          , -- ���t
                               COLUMN   68,p_pscd_r[r_i].remit_bank,'-'
                                          ,p_pscd_r[r_i].remit_branch   , -- �Ȧ�
                               COLUMN   78,p_pscd_r[r_i].remit_account  , -- �b��
                               COLUMN   96,p_pscd_r[r_i].disb_no          -- �I��
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30 THEN
                  LET r_page_count = 0
                  SKIP TO TOP OF PAGE
               END IF
           END IF

        AFTER GROUP OF r_cp_disb_type

           IF r_acct_no ="28250001" THEN
              LET r_disb_cnt=r_total_cnt
           END IF

           PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
                 COLUMN  24,"���I��:"   ,r_total_payamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "#,###,###,##&"," ��",
                 COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "#,###,###,##&"," ��"

           PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
                 COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "#,###,###,##&"," ��",
                 COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "#,###,###,##&"," ��",
                 COLUMN 104,"(=)��I:"  ,r_total_realamt USING "#,###,###,##&"," ��"
           SKIP  4 LINE

           PRINT COLUMN   3,"(��)�`�g�z:_____________________",
                 COLUMN  37,  "�����D��:_____________________",
                 COLUMN  68,  "���D��:_____________________",
                 COLUMN  99,    "�дڤH:_____________________"

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col_un  --
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_col_50
-- �@    ��:yirong
-- ��    ��:098/12/24
-- �B�z���n:����/�٥����I���ӱ����C�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_50 (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_function_code
                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)


    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        INTEGER -- ���I��    --
          ,r_total_supprem       INTEGER -- ��ú      --
          ,r_total_divamt        INTEGER -- ���Q      --
          ,r_disb_cnt            INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       INTEGER -- �U��      --
          ,r_total_aplamt        INTEGER -- ��ú      --
          ,r_total_minus_supprem INTEGER -- ��ú      --
          ,r_total_realamt       INTEGER -- ��I      --
          ,r_total_cpamt         INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
    
    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''

            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�D�ʹq��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"
                     LET for_100w=''

            END CASE

        --  LET g_report_corp="�T �� �� �� �H �� �O �I �� �� �� �� �� �q"
            LET g_report_name=p_rpt_name_2
{

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
}
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:�x��",
                  COLUMN 111, "�N    ��:GC60"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE


        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                             +p_cp_pay_detail.rtn_loan_int
               LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                             +p_cp_pay_detail.rtn_apl_int
               LET r_div_amt =p_cp_pay_detail.accumulated_div
                             +p_cp_pay_detail.div_int_balance
                             +p_cp_pay_detail.div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +p_cp_pay_detail.cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +p_cp_pay_detail.prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +p_cp_pay_detail.rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +p_cp_pay_detail.cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,p_cp_pay_detail.po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,p_cp_pay_detail.paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count =r_row_count+1

               PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                                p_cp_pay_detail.rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                         ,  -- �O�B       --
                     COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                         ,  -- ���I���B   --
                     COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,###,###"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,###,###"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,###,###"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                         USING "###,###,###"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,p_cp_pay_detail.cp_pay_amt USING "###,###,###"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,p_cp_pay_detail.dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1

               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO r_pscd_cnt
                      IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1
--                       LET r_total_realamt=r_total_realamt
--                                          +p_pscd_r[r_i].cp_real_payamt

                         PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- ���q

                               COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����
                               COLUMN   46,p_pscd_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t
                               COLUMN   54,p_pscd_r[r_i].cp_real_payamt
                                           USING "###,###,###"          , -- ���t
                               COLUMN   68,p_pscd_r[r_i].remit_bank,'-'
                                          ,p_pscd_r[r_i].remit_branch   , -- �Ȧ�
                               COLUMN   78,p_pscd_r[r_i].remit_account  , -- �b��
                               COLUMN  112,p_pscd_r[r_i].disb_no          -- �I��
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30 
               OR r_row_count  == 10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count   --�����ӭ��L�X�X�����
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"��U��",SetLine("-",62)
                  PRINT COLUMN 92,"������Ƶ��ơG",r_row_cnt USING "<<<<","��"
                  SKIP TO TOP OF PAGE
               END IF
           END IF

        AFTER GROUP OF r_cp_disb_type

           IF r_acct_no ="28250001" THEN
              LET r_disb_cnt=r_total_cnt
           END IF

           PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
                 COLUMN  24,"���I��:"   ,r_total_payamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "#,###,###,##&"," ��",
                 COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "#,###,###,##&"," ��"

           PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
                 COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "#,###,###,##&"," ��",
                 COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "#,###,###,##&"," ��",
                 COLUMN 104,"(=)��I:"  ,r_total_realamt USING "#,###,###,##&"," ��"
           SKIP  4 LINE

           PRINT COLUMN   3,"(��)�`�g�z:_____________________",
                 COLUMN  37,  "�����D��:_____________________",
                 COLUMN  68,  "���D��:_____________________",
                 COLUMN  99,    "�дڤH:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col �ͦs���ӱ������ --
-------------------------------------------------------------------------------
-- ����W��:cp_pay_unnormal_50
-- �@    ��:jessica Chang
-- ��    ��:088/12/14
-- �B�z���n:����/�٥����I���ӱ����C�L
--          �]�䲼���I�{�ϱo���I���᪺���,�q�׸�ƯS��@�~
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_unnormal_50 (r_have_data
                       ,r_cp_pay_form_type
                       ,r_policy_no
                       ,r_cp_anniv_date
                       ,r_applicant_name
                       ,r_dept_name
                       ,r_cp_pay_detail_sw
                       ,r_cp_disb_type
                       ,r_recv_note_name
                       ,r_agent_name
                       ,r_pscd_cnt
                       ,r_po_sts_code
                       ,r_modx
                       ,r_method
                       ,r_function_code
                       )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)


    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        INTEGER -- ���I��    --
          ,r_total_supprem       INTEGER -- ��ú      --
          ,r_total_divamt        INTEGER -- ���Q      --
          ,r_disb_cnt            INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       INTEGER -- �U��      --
          ,r_total_aplamt        INTEGER -- ��ú      --
          ,r_total_minus_supprem INTEGER -- ��ú      --
          ,r_total_realamt       INTEGER -- ��I      --
          ,r_total_cpamt         INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          
    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�D�ʹq��"
                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"
                     LET for_100w=''
            END CASE

        --  LET g_report_corp="�T �� �� �� �H �� �O �I �� �� �� �� �� �q"
            LET g_report_name=p_rpt_name_4

{
            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
}
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:�x��",
                  COLUMN 111, "�N    ��:GC62"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE


        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                             +p_cp_pay_detail.rtn_loan_int
               LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                             +p_cp_pay_detail.rtn_apl_int
               LET r_div_amt =p_cp_pay_detail.accumulated_div
                             +p_cp_pay_detail.div_int_balance
                             +p_cp_pay_detail.div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +p_cp_pay_detail.cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +p_cp_pay_detail.prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +p_cp_pay_detail.rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +p_cp_pay_detail.cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,p_cp_pay_detail.po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,p_cp_pay_detail.paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count =r_row_count+1
               
               PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                                p_cp_pay_detail.rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                         ,  -- �O�B       --
                     COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                         ,  -- ���I���B   --
                     COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,###,###"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,###,###"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,###,###"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                         USING "###,###,###"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,p_cp_pay_detail.cp_pay_amt USING "###,###,###"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,p_cp_pay_detail.dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1

               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO r_pscd_cnt
                      IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1
--                       LET r_total_realamt=r_total_realamt
--                                          +p_pscd_r[r_i].cp_real_payamt

                         PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- ���q

                               COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����
                               COLUMN   46,p_pscd_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t
                               COLUMN   54,p_pscd_r[r_i].cp_real_payamt
                                           USING "###,###,###"          , -- ���t
                               COLUMN   68,p_pscd_r[r_i].remit_bank,'-'
                                          ,p_pscd_r[r_i].remit_branch   , -- �Ȧ�
                               COLUMN   78,p_pscd_r[r_i].remit_account  , -- �b��
                               COLUMN  112,p_pscd_r[r_i].disb_no          -- �I��
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30 
               OR r_row_count ==  10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count  --�����ӭ��L�X�X�����
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"��U��",SetLine("-",62)
                  PRINT COLUMN 92,"������Ƶ��ơG",r_row_cnt USING "<<<<","��"
                  SKIP TO TOP OF PAGE
               END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           IF r_acct_no ="28250001" THEN
              LET r_disb_cnt=r_total_cnt
           END IF

           PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
                 COLUMN  24,"���I��:"   ,r_total_payamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "#,###,###,##&"," ��",
                 COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "#,###,###,##&"," ��"

           PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
                 COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "#,###,###,##&"," ��",
                 COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "#,###,###,##&"," ��",
                 COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "#,###,###,##&"," ��",
                 COLUMN 104,"(=)��I:"  ,r_total_realamt USING "#,###,###,##&"," ��"
           SKIP  4 LINE

           PRINT COLUMN   3,"(��)�`�g�z:_____________________",
                 COLUMN  37,  "�����D��:_____________________",
                 COLUMN  68,  "���D��:_____________________",
                 COLUMN  99,    "�дڤH:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_unnormal �ͦs���ӱ������ --


-- �٥����I�@���Be-billing�B�Ȱ��l�H���Ӫ�
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_all
-- �@    ��:yihua
-- ��    ��:100/01/10
-- �B�z���n:����/�٥����I���ӱ����C�L
--          �٥����I�@���Be-billing�B�Ȱ��l�H���Ӫ�
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_all (
          r_policy_no                    -- �O�渹�X
         ,r_benf_name_all                -- ���q�H
         ,r_cp_anniv_date                -- �g�~��
         ,r_plan_code                    -- �I��
         ,r_face_amt                     -- �O�B
         ,r_cp_amt                       -- �٥����B
         ,r_cp_pay_amt                   -- ���I���B
         ,r_ebill_ind                    -- ebill����
         ,r_pmia_sw                      -- �L�Ħa�}����
         )

DEFINE  r_policy_no              LIKE polf.policy_no
       ,r_benf_name_all          CHAR(10)
       ,r_cp_anniv_date          LIKE pscp.cp_anniv_date
       ,r_plan_code              LIKE pscp.plan_code
       ,r_face_amt               LIKE pscp.face_amt
       ,r_cp_amt                 LIKE pscp.cp_amt
       ,r_cp_pay_amt             LIKE pscp.cp_pay_amt
       ,r_ebill_ind              CHAR(1)
       ,r_pmia_sw                LIKE pmia.pmia_sw


DEFINE  r_stop_mail               CHAR(1)                       -- �Ȱ��l�H
       ,r_normal                  CHAR(1)                       -- �@���
       ,r_e_mail                  CHAR(1)                       -- e-billing
       ,r_total                   INTEGER                       -- �X�p���
     --  ,r_sub_total               INTEGER                       -- �X�p���B
       ,r_rpt_name                  CHAR(54)

OUTPUT
      TOP OF PAGE "^L"
      PAGE   LENGTH  40
      LEFT   MARGIN   0
      TOP    MARGIN   0
      BOTTOM MARGIN   0

ORDER BY r_policy_no, r_benf_name_all, r_benf_name_all

FORMAT


PAGE HEADER
   PRINT
   CALL GetReportTitle("", TRUE)
   PRINT COLUMN CenterPosition(g_report_corp CLIPPED,120), g_report_corp CLIPPED;
   PRINT COLUMN 114, "[ ���K��T ]"

   PRINT ""
   LET r_rpt_name = "�� �s �O �I �� �� �b �� �� �� ��"
   PRINT COLUMN CenterPosition(r_rpt_name,120), r_rpt_name CLIPPED,
   COLUMN 124, "psc02r10"

           PRINT ""
           PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                 COLUMN 119, "�N    ��:GC50-1"
           PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                 COLUMN 119, "��    ��:", PAGENO USING "####"
           PRINT SetLine( "-",140 ) CLIPPED

           PRINT COLUMN   3 , "�O�渹�X",
                 COLUMN  16 , "���q�H"  ,
                 COLUMN  27 , "�g �~ ��",
                 COLUMN  38 , "�I    ��",
                 COLUMN  56 , "�O    �B",
                 COLUMN  81 , "�٥����B",
                 COLUMN  94 , "���I���B",
                 COLUMN 106 , "�@���",
                 COLUMN 116 , "e-billing",
                 COLUMN 128 , "�Ȱ��l�H"
           PRINT SetLine( "-",140 ) CLIPPED

       ON EVERY ROW
       IF r_ebill_ind = '1' AND r_pmia_sw = ' ' THEN
         LET r_normal = 'Y'
       ELSE
         LET r_normal = ' '
       END IF

       IF r_ebill_ind = '0' THEN
         LET r_e_mail = 'Y'
       ELSE
         LET r_e_mail = ' '
       END IF

       IF r_ebill_ind = '1' AND r_pmia_sw = 'Y' THEN
         LET r_stop_mail = 'Y'
       ELSE
         LET r_stop_mail = ' '
       END IF

       display 'ebill����3=', r_ebill_ind , ' �L�Ħa�}����=', r_pmia_sw
       display '�@���3=', r_normal, ' mail=',r_e_mail, ' �Ȱ��l�H=', r_stop_mail

           PRINT COLUMN   1 , r_policy_no,
                 COLUMN  16 , r_benf_name_all,
                 COLUMN  25 , r_cp_anniv_date,
                 COLUMN  38 , r_plan_code,
                 COLUMN  50 , r_face_amt
                              USING "#,###,###,##&.&&",
                 COLUMN  70 , r_cp_amt
                              USING "#,###,###,##&.&&",
                 COLUMN  84 , r_cp_pay_amt
                              USING "#,###,###,##&.&&",
                 COLUMN 108 , r_normal,
                 COLUMN 119 , r_e_mail,
                 COLUMN 132 , r_stop_mail

       LET r_total = r_total + 1                            -- �X�p���
     --  LET r_sub_total = r_sub_total + r_cp_amt             -- �X�p���B

       ON LAST ROW
           PRINT SetLine( "-",140 ) CLIPPED
           PRINT COLUMN  3 , "�X     �p:",
                 COLUMN  9 , r_total  USING "###,##&","��"
                -- COLUMN 50 , "��     �B:",
                -- COLUMN 60 , r_sub_total  USING "###,###,###,##&"


          PRINT ASCII 12
END REPORT

-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_stat
-- �@    ��:yirong
-- ��    ��:100/03
-- �B�z���n:�ͦs���Ӳέp
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_stat (r_currency,r_fn_code_desc,r_sub_stat,r_cp_pay_amt)
    DEFINE r_currency CHAR(3)
    DEFINE r_fn_code_desc  CHAR(14)
    DEFINE r_sub_stat CHAR(2)
    DEFINE r_cp_pay_amt LIKE pscp.cp_pay_amt
    DEFINE r_rpt_name                  CHAR(54)
    DEFINE r_fn_cnt   INT
    DEFINE r_fn_payamt FLOAT
    DEFINE r_sub_cnt   INT 
    DEFINE r_sub_payamt FLOAT
    DEFINE r_cur_cnt INT
    DEFINE r_cur_payamt FLOAT


 OUTPUT
      TOP OF PAGE "^L"
      PAGE   LENGTH  40
      LEFT   MARGIN   0
      TOP    MARGIN   0
      BOTTOM MARGIN   0

ORDER BY r_currency,r_sub_stat,r_fn_code_desc

FORMAT


PAGE HEADER
   PRINT
   CALL GetReportTitle("", TRUE)
   PRINT COLUMN CenterPosition(g_report_corp CLIPPED,120), g_report_corp CLIPPED;
   PRINT COLUMN 114, "[ ���K��T ]"

   PRINT ""
   LET r_rpt_name = "�� �s �� �b �� �p �� ��"
   PRINT COLUMN CenterPosition(r_rpt_name,120), r_rpt_name CLIPPED,
   COLUMN 124, "psc02r11"
   PRINT ""
           PRINT COLUMN   1, "�L����:", GetDate(TODAY),--,"���O:",r_currency
                 COLUMN 119, "�N    ��:GC65-1"
           PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                 COLUMN 119, "��    ��:", PAGENO USING "####"
           PRINT SetLine( "-",140 ) CLIPPED

           PRINT COLUMN   3 , "���O",
                 COLUMN  10 , "�ͦs"  ,
                 COLUMN  30 , "����",
                 COLUMN  46 , "���B"

           PRINT SetLine( "-",140 ) CLIPPED
   BEFORE GROUP OF r_fn_code_desc
               LET r_fn_cnt           =0
               LET r_fn_payamt        =0
   BEFORE GROUP OF r_sub_stat  
               LET r_sub_cnt      =0
               LET r_sub_payamt        =0
   BEFORE GROUP OF r_currency
               LET r_cur_cnt            =0
               LET r_cur_payamt       =0
--               SKIP TO TOP OF PAGE 
   ON EVERY ROW
      LET r_fn_cnt = r_fn_cnt + 1
      LET r_fn_payamt = r_fn_payamt + r_cp_pay_amt
   AFTER GROUP OF r_fn_code_desc
      PRINT COLUMN   3,r_currency,
            COLUMN  10,r_fn_code_desc,
            COLUMN  20,r_fn_cnt USING "###,##&"," ��",
            COLUMN  30,r_fn_payamt USING "#,###,###,##&.&&"," ��"
      LET r_sub_cnt = r_sub_cnt + r_fn_cnt
      LET r_sub_payamt = r_sub_payamt + r_fn_payamt


   AFTER GROUP OF r_sub_stat
      PRINT COLUMN   3,r_currency,
            COLUMN  10,"�p�p:   ",
            COLUMN  24,r_sub_cnt USING "###,##&"," ��",
            COLUMN  34,r_sub_payamt USING "#,###,###,##&.&&"," ��"
      PRINT " "
      LET r_cur_cnt = r_cur_cnt + r_sub_cnt
      LET r_cur_payamt = r_cur_payamt + r_sub_payamt
        
   AFTER GROUP OF r_currency
     
      PRINT COLUMN   3,r_currency,
            COLUMN  10,"Total:    ",
            COLUMN  24,r_cur_cnt USING "###,##&"," ��",
            COLUMN  34,r_cur_payamt USING "#,###,###,##&.&&"," ��"
      PRINT " "
      PRINT " "
        
      ON LAST ROW
           PRINT ASCII 12

END REPORT
                 
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_col_usd
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӱ����C�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_usd (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_function_code
                      ,r_cp_pay_detail_process_date
,r_cp_pay_detail_policy_no          
,r_cp_pay_detail_cp_anniv_date      
,r_cp_pay_detail_cp_sw              
,r_cp_pay_detail_cp_pay_form_type   
,r_cp_pay_detail_plan_code          
,r_cp_pay_detail_rate_scale         
,r_cp_pay_detail_coverage_no        
,r_cp_pay_detail_face_amt           
,r_cp_pay_detail_paid_to_date       
,r_cp_pay_detail_po_issue_date      
,r_cp_pay_detail_minus_prem_susp    
,r_cp_pay_detail_loan_amt           
,r_cp_pay_detail_loan_int_balance   
,r_cp_pay_detail_loan_int           
,r_cp_pay_detail_apl_amt            
,r_cp_pay_detail_apl_int_balance    
,r_cp_pay_detail_apl_int            
,r_cp_pay_detail_rtn_minus_premsusp 
,r_cp_pay_detail_rtn_loan_amt       
,r_cp_pay_detail_rtn_loan_int       
,r_cp_pay_detail_rtn_apl_amt        
,r_cp_pay_detail_rtn_apl_int        
,r_cp_pay_detail_prem_susp          
,r_cp_pay_detail_accumulated_div    
,r_cp_pay_detail_div_int_balance    
,r_cp_pay_detail_div_int            
,r_cp_pay_detail_cp_amt             
,r_cp_pay_detail_cp_chk_date        
,r_cp_pay_detail_rtn_rece_no        
,r_cp_pay_detail_cp_pay_amt         
,r_cp_pay_detail_cp_disb_type       
,r_cp_pay_detail_mail_addr_ind      
,r_cp_pay_detail_dept_code          
,r_cp_pay_detail_agent_code         
,r_cp_pay_detail_address            
,r_cp_pay_detail_zip_code           
,r_cp_pay_detail_currency           
                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)


    DEFINE r_acct_no             CHAR(8)  -- ���I��� --
          ,r_disb_desc           CHAR(8)  -- ���I�覡���� --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            FLOAT--INTEGER
          ,r_apl_amt             FLOAT--INTEGER
          ,r_div_amt             FLOAT--INTEGER

    DEFINE r_total_cnt           INTEGER -- �X�p:��� --
          ,r_total_payamt        FLOAT--INTEGER -- ���I��    --
          ,r_total_supprem       FLOAT--INTEGER -- ��ú      --
          ,r_total_divamt        FLOAT--INTEGER -- ���Q      --
          ,r_disb_cnt            FLOAT--INTEGER -- �I�ڦX�p  --
          ,r_total_loanamt       FLOAT--INTEGER -- �U��      --
          ,r_total_aplamt        FLOAT--INTEGER -- ��ú      --
          ,r_total_minus_supprem FLOAT--INTEGER -- ��ú      --
          ,r_total_realamt       FLOAT--INTEGER -- ��I      --
          ,r_total_cpamt         FLOAT--INTEGER -- ���I���B  --
          ,r_page_count          INTEGER -- �C������  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_j                   INTEGER
          
    DEFINE for_100w              VARCHAR(10)
    DEFINE r_cp_pay_detail_process_date            LIKE pscb.change_date
         DEFINE r_cp_pay_detail_policy_no           LIKE polf.policy_no
         DEFINE r_cp_pay_detail_cp_anniv_date           LIKE pscb.cp_anniv_date
         DEFINE r_cp_pay_detail_cp_sw                   LIKE pscb.cp_sw
         DEFINE r_cp_pay_detail_cp_pay_form_type        LIKE pscp.cp_pay_form_type
         DEFINE r_cp_pay_detail_plan_code               LIKE pscp.plan_code
         DEFINE r_cp_pay_detail_rate_scale       LIKE pscp.rate_scale
         DEFINE r_cp_pay_detail_coverage_no             LIKE pscp.coverage_no
         DEFINE r_cp_pay_detail_face_amt                LIKE pscp.face_amt
         DEFINE r_cp_pay_detail_paid_to_date            LIKE pscp.paid_to_date
         DEFINE r_cp_pay_detail_po_issue_date           LIKE pscp.po_issue_date
         DEFINE r_cp_pay_detail_minus_prem_susp         LIKE pscp.minus_prem_susp
       DEFINE r_cp_pay_detail_loan_amt              LIKE pscp.loan_amt
       DEFINE r_cp_pay_detail_loan_int_balance        LIKE pscp.loan_int_balance
       DEFINE r_cp_pay_detail_loan_int              LIKE pscp.loan_int
         DEFINE r_cp_pay_detail_apl_amt                 LIKE pscp.apl_amt
         DEFINE r_cp_pay_detail_apl_int_balance         LIKE pscp.apl_int_balance
         DEFINE r_cp_pay_detail_apl_int                 LIKE pscp.apl_int
         DEFINE r_cp_pay_detail_rtn_minus_premsusp      LIKE pscp.rtn_minus_premsusp
         DEFINE r_cp_pay_detail_rtn_loan_amt            LIKE pscp.rtn_loan_amt
         DEFINE r_cp_pay_detail_rtn_loan_int            LIKE pscp.rtn_loan_int
         DEFINE r_cp_pay_detail_rtn_apl_amt             LIKE pscp.rtn_apl_amt
         DEFINE r_cp_pay_detail_rtn_apl_int             LIKE pscp.rtn_apl_int
         DEFINE r_cp_pay_detail_prem_susp               LIKE pscp.prem_susp
         DEFINE r_cp_pay_detail_accumulated_div         LIKE pscp.accumulated_div
         DEFINE r_cp_pay_detail_div_int_balance         LIKE pscp.div_int_balance
         DEFINE r_cp_pay_detail_div_int                 LIKE pscp.div_int
         DEFINE r_cp_pay_detail_cp_amt                  LIKE pscp.cp_amt
         DEFINE r_cp_pay_detail_cp_chk_date             LIKE pscp.cp_chk_date
         DEFINE r_cp_pay_detail_rtn_rece_no             LIKE pscp.rtn_rece_no
         DEFINE r_cp_pay_detail_cp_pay_amt              LIKE pscp.cp_pay_amt
         DEFINE r_cp_pay_detail_cp_disb_type            LIKE pscb.cp_disb_type
         DEFINE r_cp_pay_detail_mail_addr_ind           LIKE polf.mail_addr_ind
         DEFINE r_cp_pay_detail_dept_code               LIKE dept.dept_code
         DEFINE r_cp_pay_detail_agent_code              LIKE agnt.agent_code
         DEFINE r_cp_pay_detail_address                 LIKE addr.address
         DEFINE r_cp_pay_detail_zip_code                LIKE addr.zip_code
         DEFINE r_cp_pay_detail_currency                LIKE pscp.currency
         DEFINE r_pscx_r ARRAY [99] OF RECORD LIKE pscx.*
         DEFINE r_pscx_cmd           CHAR(254)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER BY r_function_code
--            ,r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''

            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�l�H�䲼"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="��ú�O�O"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�q    ��"                        
--                     LET for_100w="��100�U"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="���^���"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="�D�ʹq��"
--                   LET for_100w="��100�U"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="�٥��^�y"
                     LET for_100w=''

            END CASE

            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,"�~��"
            PRINT COLUMN   1, "�L����:", GetDate(TODAY),
                  COLUMN  62, "���O:����",
                  COLUMN 111, "�N    ��:GC60-1"
            PRINT COLUMN   1, "�@�~���:", p_rpt_beg_date,
                  COLUMN  45, "���I�覡:",r_disb_desc,"-",r_acct_no
                                         ,"�I�ڥ\��X:",r_function_code,
                  COLUMN 111, "��    ��:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "�O�渹�X"    ,
                  COLUMN  14, "�n�O�H"      ,
                  COLUMN  35, "PO-�ͮĤ�"   ,
                  COLUMN  45, "�g�~��"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "ú�k"        ,
                  COLUMN  64, "���O�覡"    ,
                  COLUMN  73, "�I�{"        ,
                  COLUMN  79, "�䲼���"    ,
                  COLUMN  89, "ú�O�פ�"    ,
                  COLUMN  99, "�ٴڦ���"    ,
                  COLUMN 110, "�~�ȭ�"

            PRINT COLUMN  14, "�I��"        ,
                  COLUMN  34, "�O�B"        ,
                  COLUMN  42, "���I���B"    ,
                  COLUMN  55, "(+)��ú"     ,
                  COLUMN  67, "(+)���Q"     ,
                  COLUMN  75, "(-)�U�ڥ��Q" ,
                  COLUMN  87, "(-)��ú���Q" ,
                  COLUMN 103, "(-)��ú"     ,
                  COLUMN 112, "(=)��I���B" ,
                  COLUMN 125, "�q�T���"

            PRINT COLUMN  14, "���q�H"      ,
                  COLUMN  36, "����"        ,
                  COLUMN  43, "���q��v%"   ,
                  COLUMN  57, "���t���B"    ,
                  COLUMN  68, "�Ȧ�"        ,
                  COLUMN  78, "�b��"        ,
                  COLUMN 112, "�I�ڸ��X"

            PRINT SetLine( "-",132 ) CLIPPED
         BEFORE GROUP OF r_function_code
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

{
        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE
}

        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=r_cp_pay_detail_rtn_loan_amt
                             +r_cp_pay_detail_rtn_loan_int
               LET r_apl_amt =r_cp_pay_detail_rtn_apl_amt
                             +r_cp_pay_detail_rtn_apl_int
               LET r_div_amt =r_cp_pay_detail_accumulated_div
                             +r_cp_pay_detail_div_int_balance
                             +r_cp_pay_detail_div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +r_cp_pay_detail_cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +r_cp_pay_detail_prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +r_cp_pay_detail_rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +r_cp_pay_detail_cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- �O�渹�X   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- �n�O�H     --
                     COLUMN  35,r_cp_pay_detail_po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,r_cp_pay_detail_cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,r_cp_pay_detail_paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,r_cp_pay_detail_rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count=r_row_count +1

               PRINT COLUMN  14,r_cp_pay_detail_plan_code,'-',
                                r_cp_pay_detail_rate_scale
                                                         ,  -- �I��       --
                     COLUMN  25,r_cp_pay_detail_face_amt USING "#,###,##&.&&"
                                                         ,  -- �O�B       --
                     COLUMN  39,r_cp_pay_detail_cp_amt   USING "#,###,##&.&&"
                                                         ,  -- ���I���B   --
                     COLUMN  51,r_cp_pay_detail_prem_susp USING "###,##&.&&"
                                                         ,  -- (+)��ú    --
                     COLUMN  63,r_div_amt                USING "###,##&.&&"
                                                         ,  -- (+)���Q    --
                     COLUMN  75,r_loan_amt               USING "###,##&.&&"
                                                         ,  -- (-)�U�ڥ���--
                     COLUMN  87,r_apl_amt                USING "###,##&.&&"
                                                         ,  -- (-)��ú����--
                     COLUMN  99,r_cp_pay_detail_rtn_minus_premsusp
                                                         USING "###,##&.&&"
                                                         ,  -- (-)��ú    --
                     COLUMN 112,r_cp_pay_detail_cp_pay_amt USING "#,###,##&.&&"
                                                         ,  -- (=)��I���B--
                     COLUMN 125,r_cp_pay_detail_dept_code  -- �q�T��� --

               LET r_page_count=r_page_count+1
               IF r_cp_pay_detail_sw ="1" THEN -- �L���q�H��� --
                  FOR r_i=1 TO 99
                      LET r_pscx_r[r_i].policy_no     =" "
                      LET r_pscx_r[r_i].cp_anniv_date ="   /  /  "
                      LET r_pscx_r[r_i].cp_pay_cnt    =0
                      LET r_pscx_r[r_i].cp_pay_seq    =0
                      LET r_pscx_r[r_i].cp_pay_amt    =0
                      LET r_pscx_r[r_i].names         =" "
                      LEt r_pscx_r[r_i].benf_ratio    =0
                      LET r_pscx_r[r_i].cp_real_payamt=0
                      LET r_pscx_r[r_i].bank_code     =" "
                      LET r_pscx_r[r_i].bank_account_e  =" "
                      LET r_pscx_r[r_i].payee_e       =" "
                      LET r_pscx_r[r_i].disb_no       =" "

                  END FOR

                  LET r_j = 1
                  DECLARE pscx_cur1 CURSOR FOR 
                      SELECT  * 
                        FROM pscx 
                       WHERE policy_no=r_cp_pay_detail_policy_no
                         AND cp_anniv_date= r_cp_pay_detail_cp_anniv_date
                       ORDER BY cp_pay_seq
 

                  FOREACH pscx_cur1 INTO r_pscx_r[r_j].*

                      LET r_j=r_j+1
                  END FOREACH  
                  FOR r_i=1 TO r_pscd_cnt
                      IF r_pscx_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1

                         PRINT COLUMN   14,r_pscx_r[r_i].names[1,20]    , -- ���q

                               COLUMN   36,r_pscx_r[r_i].cp_pay_seq
                                           USING "####"                 , -- ����
                               COLUMN   46,r_pscx_r[r_i].benf_ratio
                                           USING "###"                  , -- ���t
                               COLUMN   54,r_pscx_r[r_i].cp_real_payamt
                                           USING "#,###,##&.&&"          , -- ���t
                               COLUMN   68,r_pscx_r[r_i].bank_code   ,
                               COLUMN   78,r_pscx_r[r_i].bank_account_e  , -- �b��
                               COLUMN  112,r_pscx_r[r_i].disb_no          -- �I��
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30
               OR r_row_count ==10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count   --�����ӭ��L�X�X�����
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"��U��",SetLine("-",62)
              PRINT COLUMN 92,"������Ƶ��ơG",r_row_cnt USING "<<<<","��"
              SKIP TO TOP OF PAGE
           END IF
       END IF

    AFTER GROUP OF r_function_code --r_cp_disb_type

       IF r_acct_no ="28250001" THEN
          LET r_disb_cnt=r_total_cnt
       END IF

       PRINT COLUMN   1,"�X    �p: " ,r_total_cnt USING "###,##&"," ��",
             COLUMN  24,"���I��:"   ,r_total_payamt USING "##,###,##&.&&"," ��",
             COLUMN  50,"(+)��ú:"  ,r_total_supprem USING "##,###,##&.&&"," ��",
             COLUMN  77,"(+)���Q:"  ,r_total_divamt USING "##,###,##&.&&"," ��"

       PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," ��",
             COLUMN  21,"(-)�U  ��:",r_total_loanamt USING "##,###,##&.&&"," ��",
             COLUMN  50,"(-)��ú:"  ,r_total_aplamt  USING "##,###,##&.&&"," ��",
             COLUMN  77,"(-)��ú:"  ,r_total_minus_supprem USING "##,###,##&.&&",
             COLUMN 104,"(=)��I:"  ,r_total_realamt USING "##,###,##&.&&"," ��"
       SKIP  4 LINE

       PRINT COLUMN   3,"(��)�`�g�z:_____________________",
             COLUMN  37,  "�����D��:_____________________",
             COLUMN  68,  "���D��:_____________________",
             COLUMN  99,    "�дڤH:_____________________"

    LET r_row_count=0

    ON LAST ROW
       PRINT ASCII 12

END REPORT -- cp_pay_dtl_col_usd �ͦs���ӱ������ --
-------------------------------------------------------------------------------
-- ����W��:cp_pay_dtl_usd
-- �@    ��:jessica Chang
-- ��    ��:087/02/03
-- �B�z���n:����/�٥����I���ӦC�L
-- table   :pscr
-- inp para:�C�L��
-- return ���Ѽ�:
-- ���n�禡:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_usd  (r_cp_pay_form_type -- ���I�榡 --
                     ,r_policy_no        -- �O�渹�X --
                     ,r_cp_anniv_date    -- �٥��g�~�� --
                     ,r_zip_code         -- �l���ϸ� --
                     ,r_address          -- �l�H�a�} --
                     ,r_applicant_name   -- �n�O�H   --
                     ,r_insured_name     -- �Q�O�I�H --
                     ,r_tel_1            -- �n�O�H�p���q�� --
                     ,r_dept_name        -- ��~�B   --
                     ,r_plan_desc        -- �I�ػ��� --
                     ,r_cp_pay_detail_sw -- �C�L���q�H���� --
                     ,r_benf_name_all    -- ���q�H�m�W --
                     ,r_cp_disb_type     -- ���I�覡   --
                     ,r_pay_desc         -- ���I����   --
                     ,r_recv_note_name   -- ����H�m�W --
                     ,r_dept_adm_name    -- �����q�W�� --
                     ,r_pscd_cnt         -- ���q�H���ӵ��� --
                     ,r_plan_abbr_code   -- �I��²��
                     ,r_dept_code        -- �����N�X
                     ,r_mobile_o1        -- �n�O�H���
                     ,r_ebill_ind        -- ebill����
                     ,r_ebill_email      -- �n�O�Hemail
                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- ���q�H���ӵ��� --
           ,r_plan_abbr_code      LIKE pldf.plan_abbr_code
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address
           ,r_pmia_sw            LIKE pmia.pmia_sw

    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT
       --SR120800390 cmwang 101/09
        PAGE HEADER
--            PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|"
              PRINT g_ebill_format
----------------------------------------------------------- 
--              PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
--                    ASCII 27,"90033",ASCII 27,"80060"
              PRINT ASCII 126,"IT26G2;"
              SKIP 10 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  �g�˱�"

              SKIP  5 LINES

        BEFORE GROUP OF r_cp_disb_type
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           --  �ͦs ���I���Ӱ򥻸�ƦC�L p_payform_0 --

           LET p_payform_0[2]=p_payform_52
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
              --    PRINT ASCII 27,"612"
                    PRINT ASCII 126,"IX1W2Z2FK;"
               ELSE
                  IF r_i=3 THEN
                --     PRINT ASCII 27,"611",ASCII 27,"90036"
                --         ,ASCII 27,"80067"
                     PRINT ASCII 126,"IX9G2;"
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           -- �C�L���I���e --
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_1[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[2]
           LET r_payform_var[12,35] = "���I�O�I���p�U�G    "
           LET p_payform_1[2]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[4]
           LET r_payform_var[17,24] = "        "
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[5]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "#,###,##&.&&"
           LET p_payform_1[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[6]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "#,###,##&.&&"
           LET p_payform_1[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[7]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[8]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "#,###,##&.&&"
           LET p_payform_1[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[9]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[9] =r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[10]
           LET r_payform_var[21,30]=r_pay_desc
           LET r_payform_var[40,48]="��  ���G"
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_pay_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[10]=r_payform_var
           LET r_payform_var =p_payform_init

           FOR r_i =1 TO 11
               PRINT COLUMN  1,p_payform_1[r_i] CLIPPED
           END FOR

           -- �C�L���q�H���I���� --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
display 'cnt=',r_pscd_cnt
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscx_r[r_i].cp_real_payamt !=0 THEN
                     PRINT COLUMN  6,p_pscx_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscx_r[r_i].names[1,20]   ,
                           COLUMN 33,p_pscx_r[r_i].benf_ratio
                                     USING "##&",
                           COLUMN 38,p_pscx_r[r_i].cp_real_payamt
                                     USING "-,---,--&.&&",
                           COLUMN 50,"��",
                           COLUMN 53,p_pscx_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscx_r[r_i].bank_code,'-',
                                        p_pscx_r[r_i].bank_account_e[1,7], 'xxx',
                                        p_pscx_r[r_i].bank_account_e[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscx_r[r_i].bank_code,'-',
                                        p_pscx_r[r_i].bank_account_e
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- �C�L���Ӫ��� --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var
           LET p_payform_e[5]=p_payform_init

           FOR r_i =1 TO 9
  --             IF r_i=9  THEN
  --                PRINT ASCII 27,"E"
  --             ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
  --             END IF
           END FOR

         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_usd �ͦs/�������I����  --
