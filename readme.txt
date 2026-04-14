Readme for: "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India"
Authors: Sugat Chaturvedi, Sabyasachi Das, Kanika Mahajan
Updated: December 11, 2023

This document provides a guide to replicate the results and analyses in Chaturvedi, Das & Mahajan (2023) "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India". See the paper for details on data and variable construction. The files are divided into: code, data, and output folders. Please direct any questions about these files to Sugat Chaturvedi at sugat.chaturvedi@gmail.com.

Note: Personally identifiable information (pii) such as individual names have been removed from these replication files.

Software used: Stata/MP 17.0 for Windows (64-bit x86-64; Revision 14 Jun 2021). The Stata scripts have been run on Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz x64-based processor with 16.0 GB RAM, 1 TB SSD running Windows 10 system. 

Note: For the replication code to work, it is important to download all the data files from the dataverse in their original file formats and maintain the directory structure. The following is the directory tree structure for the replication folder with details:

##############
# CODE FILES #
##############

---------------------------------------------------------------------------------
TABLES AND FIGURES CODE:
---------------------------------------------------------------------------------
+---code

Executes the entire replication code:
|       main.do

The following are the do files that generate the respective tables and figures. The file names are self-explanatory:
|       table_1_3_5_c6_c8_c9_c13_c14_c17_c18.do
|       table_2.do
|       table_4.do
|       table_c1.do
|       table_c2.do
|       table_c3_col3_4.do
|       table_c4_summary_stats.do
|       table_c5_c15_c19_covariates_balance_main_nrega.do
|       table_c7.do
|       table_c10_muslimshare_correlates.do
|       table_c11_covariates_balance_interaction.do
|       table_c12_mshare_controls.do
|       table_c20_c22_close_election.do
|       table_c21_cov_balance_close.do

|       fig_1_a_mccrary.do
|       fig_1_b_firststageoverall.do
|       fig_2_a_rd_plots_overall.do
|       fig_2_b_rd_plots_overall_quadratic.do
|       figure_c1_table_c3col1_2_c16.do
|       figure_c2.do
|       figure_c3.do
|       figure_c4_a_b_rdheterogeneity.do
|       figure_c4_c_d_rdheterogeneityquad.do
|       figure_c5ai_rd_plots_hetero20.do
|       figure_c5bj_rd_plots_hetero30.do
|       figure_c5ck_rd_plots_hetero40.do
|       figure_c5dl_rd_plots_hetero50.do
|       figure_c5em_rd_plots_hetero20_quad.do
|       figure_c5fn_rd_plots_hetero30_quad.do
|       figure_c5go_rd_plots_hetero40_quad.do
|       figure_c5hp_rd_plots_hetero50_quad.do
|       figure_c6_coefplot_mshare.do
|       figure_c7.do
|       figure_c8_fhh_muslimshare.do
|       figure_c9_coefplot_fhh.do
|       figure_c10_mccrary_close.do

##############
# DATA FILES #
##############
         
+---data

Swachh Bharat Mission (SBM) data merged with elections data: 
- Anonymized data from the SBM website maintained by the Ministry of Drinking Water and Sanitation (MDWS), Government of India
- This is merged with 2015 GP Sarpanch elections data provided by the State Election Commission of Uttar Pradesh

The file below contains information on around 27 million households in rural U.P.:
|       SBM beneficiaries with gp details compressed.dta

Converted to panel format for the sample of households who did not have toilets before 2015: 
|       SBM_panel_full.dta

Further reduced to the final sample within the specified bandwidth for computational reasons:
|       SBM_panel.dta

Aggregated to the Gram Panchayat (GP) level and further merged with Census 2011 village population and amenities data and NREGS data:
|       final election caste sbm.dta

Tehsil level religion composition data from Census 2011:
|       census 2011 tehsil level religion.dta

Crosswalk between Census Tehsils and SBM data:
|       district tehsil block matching.dta

2015–16 National Family and Health Survey (NFHS) data:
|       IAHR71FL.DTA
|       IAIR71FL.DTA
|       matching_district_nfhs_admin.xlsx
|       data_toilet_nfhs.xlsx

Rural Economic and Demographic Survey 2006 (REDS) data with the relevant variables:
|       reds_femalehead_mechanism.dta
|       reds_femalehead_polparticipation.dta

SQUAT survey (2014):
|       survey_sanitation_2014.dta 

################
# OUTPUT FILES #
################
---------------------------------------------------------------------------------
FIGURES and TABLES
---------------------------------------------------------------------------------

The following folder stores the output figures and tables, we also list the output files separately:

\---output
        balance.out
        balance.tex
        balance.txt
        balance_het.out
        balance_het.tex
        balance_het.txt
        close_balance.tex
        close_balance.txt
        close_election.tex
        close_election.txt
        close_robust.tex
        close_robust.txt
        coefplot_heterogeneity_muslim.eps
        coefplot_heterogeneity_muslim_fhh.eps
        coefplot_heterogeneity_nonmuslim.eps
        coefplot_heterogeneity_nonmuslim_fhh.eps
        decision_making_het_main.tex
        decision_making_het_main.txt
        decision_making_main.tex
        decision_making_main.txt
        estimated_and_true_muslim_share_tehsil_lfit.eps
        femalehead_polparticipation.tex
        femalehead_polparticipation.txt
        female_head_2.tex
        female_head_2.txt
        female_head_2_mus.tex
        female_head_2_mus.txt
        fhh_mshare.eps
        firststage.tex
        firststage.txt
        firststage_hetero.tex
        firststage_hetero.txt
        firststage_hetero_mshare.tex
        firststage_hetero_mshare.txt
        mcrary_plot_dcdensity.eps
        mcrary_plot_dcdensity_hindumuslim.eps
        mechanism_women.tex
        mechanism_women.txt
        muslimeshare_correlates.txt
        muslimeshare_correlates.xls
        muslimsarpanch_muslimshare.png
        muslim_share_hist.eps
        nfhs_admin_data_scatter_fit_UP.pdf
        NREGA gp het_diff.tex
        NREGA gp het_diff.txt
        NREGA gp.tex
        NREGA gp.txt
        overall.tex
        overall.txt
        overall_femalehh.tex
        overall_femalehh.txt
        overall_femalehh_panel.tex
        overall_femalehh_panel.txt
        overall_mshare.tex
        overall_mshare.txt
        overall_mshare_control.tex
        overall_mshare_control.txt
        overall_mshare_diff.tex
        overall_mshare_diff.txt
        overall_mshare_quadratic.tex
        overall_mshare_quadratic.txt
        overall_muslimsarpanch_mshare.tex
        overall_muslimsarpanch_mshare.txt
        overall_sc.tex
        overall_sc.txt
        pretreatmentoutcome.tex
        pretreatmentoutcome.txt
        pretreatmentoutcome_het.tex
        pretreatmentoutcome_het.txt
        rd_plotfirst10.eps
        rd_plot_second10.eps
        rd_plot_second10_msharehigh.eps
        rd_plot_second10_msharehigh_20threshold.eps
        rd_plot_second10_msharehigh_20threshold_quad.eps
        rd_plot_second10_msharehigh_30threshold.eps
        rd_plot_second10_msharehigh_30threshold_quad.eps
        rd_plot_second10_msharehigh_40threshold.eps
        rd_plot_second10_msharehigh_40threshold_quad.eps
        rd_plot_second10_msharehigh_50threshold.eps
        rd_plot_second10_msharehigh_50threshold_quad.eps
        rd_plot_second10_msharehigh_quadratic.eps
        rd_plot_second10_msharelow.eps
        rd_plot_second10_msharelow_20threshold.eps
        rd_plot_second10_msharelow_20threshold_quad.eps
        rd_plot_second10_msharelow_30threshold.eps
        rd_plot_second10_msharelow_30threshold_quad.eps
        rd_plot_second10_msharelow_40threshold.eps
        rd_plot_second10_msharelow_40threshold_quad.eps
        rd_plot_second10_msharelow_50threshold.eps
        rd_plot_second10_msharelow_50threshold_quad.eps
        rd_plot_second10_msharelow_quadratic.eps
        rd_plot_second10_quadratic.eps
        toiletpref_muslimshare.tex
        toiletpref_muslimshare.txt
        toiletpref_muslimshare_hindu.tex
        toiletpref_muslimshare_hindu.txt
        toilterpref_hasdaughter_SQUAT.tex
        toilterpref_hasdaughter_SQUAT.txt
        toilterpref_muslim_SQUAT.tex
        toilterpref_muslim_SQUAT.txt
        toilterpref_SQUAT.tex
        toilterpref_SQUAT.txt