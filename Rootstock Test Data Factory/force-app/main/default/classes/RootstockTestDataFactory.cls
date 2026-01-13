public class RootstockTestDataFactory {
    
    public static void createTestSyConfig() {        
        try{
            
            
            // Creating a new rstk__syconfig__c record in Apex
            rstk__syconfig__c syConfig = new rstk__syconfig__c(
                rstk__syconfig_password__c = '12345',
                rstk__SYCONFIG_USESYDATA__c = false,
                rstk__syconfig_acctgpackage__c = '0',
                rstk__syconfig_allocations__c = true,
                rstk__syconfig_arenaint__c = false,
                rstk__syconfig_authfinusers__c = 28,
                rstk__syconfig_autocadint__c = false,
                rstk__syconfig_bypassafv__c = false,
                rstk__syconfig_configsoe__c = true,
                rstk__syconfig_costacctdtl__c = false,
                rstk__syconfig_dedicatesoapibatch__c = false,
                rstk__syconfig_delicitemprojon0qty__c = false,
                rstk__syconfig_delicitemsiteprojon0qty__c = false,
                rstk__syconfig_diminventory__c = false,
                rstk__syconfig_disassembly__c = true,
                rstk__syconfig_divnumbers__c = 1,
                rstk__syconfig_drawloop__c = false,
                rstk__syconfig_drpnetchange__c = false,
                rstk__syconfig_entitlements__c = false,
                rstk__syconfig_estimating__c = false,
                rstk__syconfig_expandedsfuser__c = false,
                rstk__syconfig_ffajebatchmode__c = false,
                rstk__syconfig_ffint__c = false,
                rstk__syconfig_ffinvoice__c = false,
                rstk__syconfig_ffprojidfld__c = 'RS_PROJECT_ID__C',
                rstk__syconfig_financials__c = 'NONE',
                rstk__syconfig_frghtothlnd__c = false,
                rstk__syconfig_gradelvl__c = 999,
                rstk__syconfig_helpurl__c = 'https://rootstock.my.site.com/Trailblazer/',
                rstk__syconfig_heroku__c = true,
                rstk__syconfig_icipsactive__c = false,
                rstk__syconfig_intrdivplng__c = true,
                rstk__syconfig_intrsiteplng__c = true,
                rstk__syconfig_inventory__c = true,
                rstk__syconfig_jobcodeact__c = false,
                rstk__syconfig_jobshopmrp__c = false,
                rstk__syconfig_labonlywo__c = false,
                rstk__syconfig_maxpoloader__c = 0,
                rstk__syconfig_maxsoapi__c = 0,
                rstk__syconfig_maxsydata__c = 0,
                rstk__syconfig_menutype__c = '1 - Standard Manufacturing',
                rstk__syconfig_mrp__c = true,
                rstk__syconfig_mrpnetchange__c = false,
                rstk__syconfig_multicmp__c = true,
                rstk__syconfig_multidiv__c = true,
                rstk__syconfig_multimach__c = false,
                rstk__syconfig_novendacct__c = false,
                rstk__syconfig_numbauthusers__c = 28,
                rstk__syconfig_numblaboronlyusers__c = 0,
                rstk__syconfig_numbpayusers__c = 35,
                rstk__syconfig_outsideops__c = false,
                rstk__syconfig_physinventory__c = false,
                rstk__syconfig_poloader__c = true,
                rstk__syconfig_proditem_bom__c = true,
                rstk__syconfig_purchase__c = true,
                rstk__syconfig_quickbooks__c = false,
                rstk__syconfig_rcvginsp__c = false,
                rstk__syconfig_recurrsvc__c = false,
                rstk__syconfig_restrictdates__c = false,
                rstk__syconfig_revenova__c = false,
                rstk__syconfig_revinv__c = false,
                rstk__syconfig_rootdox__c = true,
                rstk__syconfig_sales__c = true,
                rstk__syconfig_scheduling__c = true,
                rstk__syconfig_selectissue__c = false,
                rstk__syconfig_sfrootscan__c = 0,
                rstk__syconfig_solidworksint__c = false,
                rstk__syconfig_solinemarkupopt__c = false,
                rstk__syconfig_solineseract__c = false,
                rstk__syconfig_srllocchange__c = false,
                rstk__syconfig_stdrootscan__c = 18,
                rstk__syconfig_subcontract__c = true,
                rstk__syconfig_sysrevlvl__c = 2,
                rstk__syconfig_timeattend__c = false,
                rstk__syconfig_toolinventory__c = false,
                rstk__syconfig_wbs__c = false,
                rstk__syconfig_wht__c = false,
                rstk__syconfig_workorder__c = true,
                rstk__syconfig_xigactive__c = false,
                rstk__triggeroptions__c = 'UT',
                rstk__syconfig_currfulusers__c = 20,
                rstk__syconfig_currlabusers__c = 0,
                rstk__syconfig_currlimusers__c = 26,
                rstk__syconfig_currmobusers__c = 17,
                rstk__syconfig_definelimited__c = 'Expanded Shop Floor;Purchase Order Maintenance',
                rstk__syconfig_numblimitedusers__c = 30,
                rstk__syconfig_numbmobile__c = 18,
                rstk__syconfig_numlimitedcats__c = 2,
                rstk__syconfig_peac__c = false,
                rstk__syconfig_wooverrcpt__c = true,
                rstk__syconfig_manualsched__c = false,
                rstk__syconfig_currfslusers__c = 0,
                rstk__SYCONFIG_ALLOWCONTROLJE__c = false,
                rstk__syconfig_hksydataprocessorenabled__c = false,
                rstk__syconfig_hvpeenabled__c = true,
                rstk__syconfig_supportuserok__c = true,
                rstk__syconfig_suppressgltxn__c = false,
                rstk__syconfig_unsecuretriggeroptions__c = true,
                rstk__syconfig_vendorrfq__c = false,
                rstk__syconfig_bankintegration__c = false,
                rstk__syconfig_currflexusers__c = 0,
                rstk__syconfig_nodecimals__c = false,
                rstk__syconfig_allowallchars__c = false
            );
            
            // Insert or process as needed
            insert syConfig;
        } catch(DmlException e){
            system.debug('Error: ' + e.getMessage());
            throw new CustomException('Error: ' + e.getMessage());
        }
        
        
    }
    public static Response createTestData() {
        Response res = new Response();
        
        try{
            rstk__syconfig__c syconfig = [SELECT Id, rstk__syconfig_disassembly__c FROM rstk__syconfig__c LIMIT 1];
            system.debug(syconfig);
            // Create a User record
            Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'testuser@example.com',
                Username = 'testuser' + DateTime.now().getTime() + '@example.com',
                ProfileId = userProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true
            );
            insert testUser;
            
            rstk__sycurr__c syCurr = new rstk__sycurr__c(
                rstk__sycurr_currency__c = 'GBP',
                rstk__sycurr_exchrate__c = 1,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syCurr;
            
            rstk__sycmp__c sycmpRecord = new rstk__sycmp__c(
                rstk__sycmp_cmpno__c = '100',
                rstk__sycmp_descr__c = 'Company One',
                rstk__sycmp_homecurr__c = syCurr.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert sycmpRecord;
            
            rstk__sydiv__c syDiv = new rstk__sydiv__c(
                rstk__sydiv_div__c = '101',
                rstk__sydiv_descr__c = 'Division One',
                rstk__sydiv_cmpno__c = sycmpRecord.Id,
                rstk__sydiv_initpeitemrevstatus_pl__c = 'Pending',
                rstk__sydiv_costtype_pl__c = 'Standard Cost',
                rstk__sydiv_itemprojacctsrcind_pl__c = 'Item',
                rstk__sydiv_projact__c = true,
                rstk__sydiv_multisiteind__c = true,
                rstk__sydiv_invdivappl__c = true,
                rstk__sydiv_alloc_active__c = true,
                rstk__sydiv_disslotserdflt__c = true,
                rstk__sydiv_polotautometh__c = 'Use Next in Sequence (with Prefix)',
                rstk__sydiv_polotprefix__c = 'C',
                rstk__sydiv_routing_active__c = true,
                rstk__sydiv_revcntlact__c = true,
                rstk__sydiv_revformat_pl__c = 'Alpha-Numeric',
                Auto_Create_Independent_WO_Project__c = true,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syDiv;
            
            rstk__syusr__c syUser = new rstk__syusr__c(
                rstk__syusr_clockno__c = 1,
                rstk__syusr_employee__c = testUser.Id,
                rstk__syusr_dfltcmpno__c = sycmpRecord.Id,
                rstk__syusr_dfltdiv__c = syDiv.Id,
                rstk__syusr_salesdiv__c = syDiv.Id,
                rstk__syusr_multicompany__c = true,
                rstk__syusr_multidiv__c = true,
                rstk__syusr_licreq__c = true,
                rstk__syusr_respengind__c = true,
                rstk__syusr_respbuyerind__c = true,
                rstk__syusr_respinvind__c = true,
                rstk__syusr_allowlaborbooking__c = true,
                rstk__syusr_allowqtybooking__c = true,
                rstk__syusr_lastcmpno__c = sycmpRecord.Id,
                rstk__syusr_lastdiv__c = syDiv.Id,
                rstk__syusr_lastsalesdiv__c = syDiv.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syUser;
            
            rstk__sysite__c sySite = new rstk__sysite__c(
                rstk__sysite_div__c = syDiv.Id,
                rstk__sysite_site__c = 'S1',
                rstk__sysite_descr__c = 'Site One',
                rstk__sysite_address1__c = 'Test Address',
                rstk__sysite_city__c = 'Test City',
                rstk__sysite_country__c = 'Test Country',
                rstk__sysite_zip__c = 'AB12 3CD',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert sySite;
            
            syDiv = [SELECT Id, rstk__sydiv_mainsite__c FROM rstk__sydiv__c WHERE Id = :syDiv.Id];
            syDiv.rstk__sydiv_mainsite__c = sySite.Id;
            update syDiv;
            
            rstk__syuom__c syUom = new rstk__syuom__c(
                rstk__syuom_uom__c = 'Ea',
                rstk__syuom_descr__c = 'Each',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syUom;
            
            // Create a new rstk__sydefault__c record
            rstk__sydefault__c syDefaultRecord = new rstk__sydefault__c(
                rstk__sydefault_abortonerror__c = false,
                rstk__sydefault_addrpolicycust__c = false,
                rstk__sydefault_addrpolicyvend__c = false,
                rstk__sydefault_addsfaccount__c = true,
                rstk__sydefault_allowfifochg__c = false,
                rstk__sydefault_aspostap__c = false,
                rstk__sydefault_aspostar__c = false,
                rstk__sydefault_aspostje__c = false,
                rstk__sydefault_autocontactrs__c = true,
                rstk__sydefault_autocontactrsf__c = true,
                rstk__sydefault_autonumbercust__c = true,
                rstk__sydefault_autonumbervend__c = true,
                rstk__sydefault_autormacase__c = true,
                rstk__sydefault_autorunfulfillsearch__c = true,
                rstk__sydefault_autovcontactrs__c = true,
                rstk__sydefault_autovcontactsf__c = true,
                rstk__sydefault_barcodeactive__c = false,
                rstk__sydefault_barcodeheight__c = 40,
                rstk__sydefault_barcodetextsize__c = 8,
                rstk__sydefault_defuom__c = syUom.Id,
                rstk__sydefault_dfltcustclass__c = null,
                rstk__sydefault_emailerrors__c = false,
                rstk__sydefault_etemploptack__c = 'Attachment',
                rstk__sydefault_etemploptbol__c = 'Attachment',
                rstk__sydefault_etemploptinv__c = 'Attachment',
                rstk__sydefault_etemploptpack__c = 'Attachment',
                rstk__sydefault_etemploptpick__c = 'Attachment',
                rstk__sydefault_etemploptpo__c = 'Attachment',
                rstk__sydefault_etemploptrma__c = 'Attachment',
                rstk__sydefault_featuresactive__c = false,
                rstk__sydefault_formovr_bol__c = 'Email Template',
                rstk__sydefault_formovr_qot__c = 'Email Template',
                rstk__sydefault_formovr_rma__c = 'Email Template',
                rstk__sydefault_formovr_spk__c = 'Email Template',
                rstk__sydefault_hvsoentry__c = false,
                rstk__sydefault_imagerowsize__c = 20,
                rstk__sydefault_lastcustnumber__c = 1000,
                rstk__sydefault_lastvendnumber__c = 1000,
                rstk__sydefault_numlinesfulfill__c = 150,
                rstk__sydefault_povclass__c = null,
                rstk__sydefault_scheduledateype__c = 'Shop Calendar',
                rstk__sydefault_soprodaddopt__c = 'B',
                rstk__sydefault_syncitemdesc__c = true,
                rstk__sydefault_updaterscontact__c = true,
                rstk__sydefault_updatersvcontact__c = true,
                rstk__sydefault_updatesfcontact__c = true,
                rstk__sydefault_updatesfvcontact__c = true,
                rstk__sydefault_vatactive__c = true,
                rstk__sydefault_vatrecognition__c = 'Upon Invoice'
            );
            
            insert syDefaultRecord;
            
            rstk__sylocid__c syLocId = new rstk__sylocid__c(
                rstk__sylocid_div__c = syDiv.Id,
                rstk__sylocid_site__c = sySite.Id,
                rstk__sylocid_locid__c = 'A1',
                rstk__sylocid_descr__c = 'Available Site One',
                rstk__sylocid_loctype_pl__c = 'On Hand',
                rstk__sylocid_dfltavailind__c = true,
                rstk__sylocid_backflushlocind__c = false,
                rstk__sylocid_inspection__c	 = false,
                rstk__sylocid_vendlocind__c = false,
                rstk__sylocid_nodelete__c = false,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syLocId;
            
            rstk__sylocnum__c syLocNum = new rstk__sylocnum__c(
                rstk__sylocnum_div__c = syDiv.Id,
                rstk__sylocnum_locid__c = syLocId.Id,
                rstk__sylocnum_locnum__c = 'S1FLOOR',
                rstk__sylocnum_descr__c = 'S1FLOOR',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syLocNum;
            
            rstk__iccomcod__c disComCod = new rstk__iccomcod__c(
                rstk__iccomcod_div__c = syDiv.Id,
                rstk__iccomcod_comcod__c = 'DIS',
                rstk__iccomcod_descr__c = 'Disassembly Item',
                rstk__iccomcod_engstatus_pl__c = 'Active',
                rstk__iccomcod_engtype_pl__c = 'Standard',
                rstk__iccomcod_src_pl__c = 'Manufactured',
                rstk__iccomcod_dfltinvuom__c = syUom.Id,
                rstk__iccomcod_dfltenguom__c = syUom.Id,
                rstk__iccomcod_dflttracklot_pl__c = 'Yes',
                rstk__iccomcod_dflttracksrl_pl__c = 'No',
                rstk__iccomcod_overrcptind_po__c = true,
                rstk__iccomcod_disassmind__c = true,
                rstk__iccomcod_disyieldfctr__c = 1,
                rstk__iccomcod_rcptlocid__c = syLocId.Id,
                rstk__iccomcod_rcptlocnum__c = 'S1FLOOR',
                rstk__iccomcod_disgoodlocid__c = syLocId.Id,
                rstk__iccomcod_disgoodlocnum__c = 'S1FLOOR',
                rstk__iccomcod_disrcvlocid__c = syLocId.Id,
                rstk__iccomcod_disrcvlocnum__c = 'S1FLOOR',
                rstk__iccomcod_abc__c = 'A',
                rstk__iccomcod_mrpplanpol_pl__c = 'No MRP Planning',
                rstk__iccomcod_respeng__c = syUser.Id,
                rstk__iccomcod_respinv__c = syUser.Id,
                rstk__iccomcod_dflthomeprojind_pl__c = 'Not Home',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disComCod;
            
            // Create the account records first
            List<rstk__syacc__c> accountsToInsert = new List<rstk__syacc__c>();
            
            // Create accounts and assign them to the relevant types
            rstk__syacc__c syAcc1 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10001', // Example mfg account for Inv Adjust
                rstk__syacc_descr__c = 'Account, Inv Adjust',
                rstk__syacc_gltype_pl__c = 'Inventory Adjustment',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc2 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10002', // Example mfg account for Inventory
                rstk__syacc_descr__c = 'Account, Inventory',
                rstk__syacc_gltype_pl__c = 'Inventory',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc3 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10003', // Example mfg account for Negative Variance
                rstk__syacc_descr__c = 'Account, Negative Variance',
                rstk__syacc_gltype_pl__c = 'Inventory Negative Variance',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc4 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10004', // Example mfg account for Non Nettable Inventory
                rstk__syacc_descr__c = 'Account, Non Nettable Inventory',
                rstk__syacc_gltype_pl__c = 'Non Nettable',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc5 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10005', // Example mfg account for Inventory Scrap
                rstk__syacc_descr__c = 'Account, Inventory Scrap',
                rstk__syacc_gltype_pl__c = 'General Scrap',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc6 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10006', // Example mfg account for Material Ohd Variance
                rstk__syacc_descr__c = 'Account, Material Ohd Variance',
                rstk__syacc_gltype_pl__c = 'Variance',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc7 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10007', // Example mfg account for Subcontract PO WIP
                rstk__syacc_descr__c = 'Account, Subcontract PO WIP',
                rstk__syacc_gltype_pl__c = 'POSUBWIP',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc8 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10008', // Example mfg account for PPV
                rstk__syacc_descr__c = 'Account, PPV',
                rstk__syacc_gltype_pl__c = 'PPV',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc9 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10009', // Example mfg account for Rework WO WIP
                rstk__syacc_descr__c = 'Account, Rework WO WIP',
                rstk__syacc_gltype_pl__c = 'WIP',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc10 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10010', // Example mfg account for Rework WO Variance
                rstk__syacc_descr__c = 'Account, Rework WO Variance',
                rstk__syacc_gltype_pl__c = 'Variance',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc11 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10011', // Example mfg account for WO WIP
                rstk__syacc_descr__c = 'Account, WO WIP',
                rstk__syacc_gltype_pl__c = 'WIP',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc12 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10012', // Example mfg account for WIP Disassembly
                rstk__syacc_descr__c = 'Account, WIP Disassembly',
                rstk__syacc_gltype_pl__c = 'WIP',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc13 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10013', // Example mfg account for WO Scrap
                rstk__syacc_descr__c = 'Account, WO Scrap',
                rstk__syacc_gltype_pl__c = 'General Scrap',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc14 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '10014', // Example mfg account for WO/Subc PO Variance
                rstk__syacc_descr__c = 'Account, WO/Subc PO Variance',
                rstk__syacc_gltype_pl__c = 'WO/Subc PO Variance',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc15 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '50000',
                rstk__syacc_descr__c = 'Cost of Sales',
                rstk__syacc_gltype_pl__c = 'Cost of Sales',
                rstk__triggeroptions__c = 'UT'
            );
            
            rstk__syacc__c syAcc16 = new rstk__syacc__c(
                rstk__syacc_div__c = syDiv.Id,
                rstk__syacc_mfgacct__c = '40100', // Example mfg account for WO/Subc PO Variance
                rstk__syacc_descr__c = 'Contract Packing Sales',
                rstk__syacc_gltype_pl__c = 'Revenue',
                rstk__triggeroptions__c = 'UT'
            );
            
            // Add all accounts to the insert list
            accountsToInsert.add(syAcc1);
            accountsToInsert.add(syAcc2);
            accountsToInsert.add(syAcc3);
            accountsToInsert.add(syAcc4);
            accountsToInsert.add(syAcc5);
            accountsToInsert.add(syAcc6);
            accountsToInsert.add(syAcc7);
            accountsToInsert.add(syAcc8);
            accountsToInsert.add(syAcc9);
            accountsToInsert.add(syAcc10);
            accountsToInsert.add(syAcc11);
            accountsToInsert.add(syAcc12);
            accountsToInsert.add(syAcc13);
            accountsToInsert.add(syAcc14);
            accountsToInsert.add(syAcc15);
            accountsToInsert.add(syAcc16);
            
            // Insert all accounts in one DML operation
            insert accountsToInsert;
            
            // Now create the rstk__iccomcodacc__c record and associate the correct accounts
            rstk__iccomcodacc__c disComCodAcc = new rstk__iccomcodacc__c(
                rstk__externalid__c = syDiv.Id + '_' + disComCod.rstk__iccomcod_comcod__c,
                rstk__iccomcodacc_adjclracct__c = syAcc1.Id,  // Account, Inv Adjust
                rstk__iccomcodacc_iccomcod__c = disComCod.Id, // Inventory Commodity Code
                rstk__iccomcodacc_inddmdacct__c = null,       // Account, Ind Demand (Future)
                rstk__iccomcodacc_intrdivtxfracct__c = null,  // Account, Inter-Div Transfer
                rstk__iccomcodacc_intrsitetxfracct__c = null, // Account, Inter-Site Transfer (Future)
                rstk__iccomcodacc_invacct__c = syAcc2.Id,     // Account, Inventory
                rstk__iccomcodacc_invnegvaracct__c = syAcc3.Id, // Account, Negative Variance
                rstk__iccomcodacc_invnnacct__c = syAcc4.Id,   // Account, Non Nettable Inventory
                rstk__iccomcodacc_invscrpacct__c = syAcc5.Id, // Account, Inventory Scrap
                rstk__iccomcodacc_mtlohdvaracct__c = syAcc6.Id, // Account, Material Ohd Variance
                rstk__iccomcodacc_posubwipacct__c = syAcc7.Id, // Account, Subcontract PO WIP
                rstk__iccomcodacc_povaracct__c = syAcc8.Id,    // Account, PPV
                rstk__iccomcodacc_rwkwipacct__c = syAcc9.Id,   // Account, Rework WO WIP
                rstk__iccomcodacc_rwkwovaracct__c = syAcc10.Id, // Account, Rework WO Variance
                rstk__iccomcodacc_subpovaracct__c = null,      // Account, Subcontract PO Variance
                rstk__iccomcodacc_wipacct__c = syAcc11.Id,      // Account, WO WIP
                rstk__iccomcodacc_wipdisacct__c = syAcc12.Id,   // Account, WIP Disassembly
                rstk__iccomcodacc_woscrapacct__c = syAcc13.Id,  // Account, WO Scrap
                rstk__iccomcodacc_wovaracct__c = syAcc14.Id,     // Account, WO/Subc PO Variance
                rstk__triggeroptions__c = 'UT'
            );
            
            // Insert the disComCodAcc record
            upsert disComCodAcc rstk__externalid__c;
            
            rstk__peitem__c disPeItem = new rstk__peitem__c(
                rstk__peitem_div__c = syDiv.Id,
                rstk__peitem_invdiv__c = syDiv.Id,
                rstk__peitem_item__c = 'EXAMPLEITEM',
                rstk__peitem_descr__c = 'EXAMPLE ITEM',
                rstk__peitem_iccomcod__c = disComCod.Id,
                rstk__peitem_src_pl__c = 'Purchased',
                rstk__peitem_disassmind__c = true,
                rstk__peitem_tracklot_pl__c = 'Yes',
                rstk__peitem_tracksrl_pl__c = 'No',
                rstk__peitem_status_pl__c = 'Active',
                rstk__peitem_type_pl__c = 'Standard',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disPeItem;
            
            rstk__icitem__c disIcItem = new rstk__icitem__c(
            	rstk__icitem_allocpolind__c = true,
                rstk__icitem_buydiv__c = syDiv.Id,
                rstk__icitem_descr__c = 'EXAMPLE ITEM',
                rstk__icitem_dfltconclassind__c = true,
                rstk__icitem_dfltcontqtyind__c = true,
                rstk__icitem_disgoodlocidind__c = true,
                rstk__icitem_disncmlocidind__c = true,
                rstk__icitem_disrcvlocidind__c = true,
                rstk__icitem_disrcvlocnumind__c = false,
                rstk__icitem_disscraplocidind__c = true,
                rstk__icitem_disyieldfctrind__c = true,
                rstk__icitem_rcptlocidind__c = true,
                rstk__icitem_div__c = syDiv.Id,
                rstk__icitem_engdivovr__c = syDiv.Id,
                rstk__icitem_expdatereqdind__c = true,
                rstk__icitem_homeprojindind__c = true,
                rstk__icitem_iccomcod__c = disComCod.Id,
                rstk__icitem_item__c = disPeItem.Id,
                rstk__icitem_src_pl__c = 'Manufactured',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disIcItem;
            
            rstk__peitem__c disRecPeItem = new rstk__peitem__c(
                rstk__peitem_div__c = syDiv.Id,
                rstk__peitem_invdiv__c = syDiv.Id,
                rstk__peitem_item__c = 'EXAMPLEDISITEM',
                rstk__peitem_descr__c = 'EXAMPLE DIS ITEM',
                rstk__peitem_iccomcod__c = disComCod.Id,
                rstk__peitem_src_pl__c = 'Manufactured',
                rstk__peitem_disassmind__c = true,
                rstk__peitem_tracklot_pl__c = 'Yes',
                rstk__peitem_tracksrl_pl__c = 'No',
                rstk__peitem_status_pl__c = 'Active',
                rstk__peitem_type_pl__c = 'Standard',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disRecPeItem;
            
            rstk__icitem__c disRecIcItem = new rstk__icitem__c(
            	rstk__icitem_allocpolind__c = true,
                rstk__icitem_buydiv__c = syDiv.Id,
                rstk__icitem_descr__c = 'EXAMPLE DIS ITEM',
                rstk__icitem_dfltconclassind__c = true,
                rstk__icitem_dfltcontqtyind__c = true,
                rstk__icitem_disgoodlocidind__c = true,
                rstk__icitem_disncmlocidind__c = true,
                rstk__icitem_disrcvlocidind__c = true,
                rstk__icitem_disrcvlocnumind__c = false,
                rstk__icitem_disscraplocidind__c = true,
                rstk__icitem_disyieldfctrind__c = true,
                rstk__icitem_rcptlocidind__c = true,
                rstk__icitem_div__c = syDiv.Id,
                rstk__icitem_engdivovr__c = syDiv.Id,
                rstk__icitem_expdatereqdind__c = true,
                rstk__icitem_homeprojindind__c = true,
                rstk__icitem_iccomcod__c = disComCod.Id,
                rstk__icitem_item__c = disRecPeItem.Id,
                rstk__icitem_src_pl__c = 'Purchased',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disRecIcItem;
            
            rstk__socomm__c soComm = new rstk__socomm__c(
                rstk__socomm_div__c = syDiv.Id,
            	rstk__socomm_comcod__c = 'DIS',
                rstk__socomm_prodtype__c = 'Stock',
                rstk__socomm_slsuom__c = syUom.Id,
                rstk__socomm_descr__c = 'Disassembly',
                rstk__socomm_oresp__c = syUser.Id,
                rstk__socomm_presp__c = syUser.Id,
                rstk__socomm_cosacct__c = syAcc15.Id,
                rstk__socomm_salesacct__c = syAcc16.Id,
                rstk__socomm_shipdiv__c = syDiv.Id,
                rstk__socomm_shipsite__c = sySite.Id,
                rstk__socomm_shiplocid__c = syLocId.Id,
                rstk__socomm_shiplocnum__c = syLocNum.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert soComm;
            
            rstk__soprod__c disRecSoProd = new rstk__soprod__c(
                rstk__soprod_div__c = syDiv.Id,
            	rstk__soprod_comcod__c = soComm.Id,
                rstk__soprod_prod__c = 'EXAMPLEDISITEM',
                rstk__soprod_descr__c = 'EXAMPLE DIS ITEM',
                rstk__soprod_slsuom__c = syUom.Id,
                rstk__soprod_prodtype__c = 'Stock',
                rstk__soprod_icitem__c = disRecIcItem.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert disRecSoProd;
            
            rstk__sopdiv__c soProdDiv = new rstk__sopdiv__c(
                rstk__sopdiv_soprod__c = disRecSoProd.Id,
                rstk__sopdiv_active__c = true,
            	rstk__sopdiv_rmasite__c = sySite.Id,
                rstk__sopdiv_shipsite__c = sySite.Id,
                rstk__sopdiv_shipdiv__c = syDiv.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert soProdDiv;
            
            rstk__socclass__c soCClass = new rstk__socclass__c(
            	rstk__socclass_cclass__c = 'UK-STD',
                rstk__socclass_custcurr__c = syCurr.Id,
                rstk__socclass_desc__c = 'UK Invoices Standard',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert soCClass;
            
            rstk__sycarrier__c syCarr = new rstk__sycarrier__c(
            	rstk__sycarrier_id__c = 'CPCarrier',
                rstk__sycarrier_descr__c = 'Example Carrier',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syCarr;
            
            rstk__syfob__c syFob = new rstk__syfob__c(
            	rstk__syfob_id__c = 'FOB',
                rstk__syfob_descr__c = 'Free on board'
            );
            
            insert syFob;
            
            rstk__syshipviatype__c syShipType = new rstk__syshipviatype__c(
            	rstk__syshipviatype_id__c = 'CPV',
                rstk__syshipviatype_descr__c = 'Example Vehicle',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syShipType;
            
            rstk__syfrghtrm__c syFrght = new rstk__syfrghtrm__c(
            	rstk__syfrghtrm_id__c = 'Default',
                rstk__syfrghtrm_descr__c = 'Default',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syFrght;
            
            rstk__syterms__c syTerms = new rstk__syterms__c(
            	rstk__syterms_id__c = '30NET',
                rstk__syterms_descr__c = '30 days from invoice date',
                rstk__triggeroptions__c = 'UT'
            );
            
            insert syTerms;
            
            rstk__socust__c soCust = new rstk__socust__c(
            	rstk__socust_custno__c = '9999',
                rstk__socust_sf_account_name__c = 'TestCust',
                rstk__socust_cclass__c = soCClass.Id,
                rstk__socust_carrier__c = syCarr.Id,
                rstk__socust_fob__c = syFob.Id,
                rstk__socust_shipviatype__c = syShipType.Id,
                rstk__socust_frghtrm__c = syFrght.Id,
                rstk__socust_terms__c = syTerms.Id,
                rstk__triggeroptions__c = 'UT'
            );
            
            insert soCust;
            
            rstk__socaddr__c soCAddr = new rstk__socaddr__c(
            	rstk__socaddr_custno__c = soCust.Id,
                rstk__socaddr_seq__c = 1,
                rstk__socaddr_name__c = 'TestAddress',
                rstk__socaddr_address1__c = 'TestAddress',
                rstk__socaddr_city__c = 'TestCity',
                rstk__socaddr_country__c = 'TestCountry',
                rstk__socaddr_zip__c = 'TE57 7IP',
                rstk__socaddr_useasack__c = true,
                rstk__socaddr_useasbillto__c = true,
                rstk__socaddr_useasinstall__c = true,
                rstk__socaddr_useasshipto__c = true,
                rstk__socaddr_defaultack__c = true,
                rstk__socaddr_defaultbillto__c = true,
                rstk__socaddr_defaultinstall__c = true,
                rstk__socaddr_defaultshipto__c = true
            );
            
            insert soCAddr;
            
            res.syCurr = syCurr;
            res.sycmpRecord = sycmpRecord;
            res.syDiv = syDiv;
            res.syUser = syUser;
            res.sySite = sySite;
            res.syUom = syUom;
            res.syLocId = syLocId;
            res.syLocNum = syLocNum;
            res.disComCod = disComCod;
            res.disPeItem = disPeItem;
            res.disRecPeItem = disRecPeItem;
            
        } catch(DmlException e){
            system.debug('Error: ' + e.getMessage());
            throw new CustomException('Error: ' + e.getMessage());
        }
        
        return res;
    }
    
    public class Response {
        public rstk__sycurr__c syCurr;
        public rstk__sycmp__c sycmpRecord;
        public rstk__sydiv__c syDiv;
        public rstk__syusr__c syUser;
        public rstk__sysite__c sySite;
        public rstk__syuom__c syUom;
        public rstk__sylocid__c syLocId;
        public rstk__sylocnum__c syLocNum;
        public rstk__iccomcod__c disComCod;
        public rstk__peitem__c disPeItem;
        public rstk__peitem__c disRecPeItem;
    }
    
    public class CustomException extends Exception {}
}