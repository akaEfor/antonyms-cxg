source("CxnsCoreDataSets.R")

library(glmmTMB)
library(lme4)
library(DHARMa)
library(emmeans)
library(ggeffects)
library(brms)
library(ordinal)
library(lmtest)
library(ordbetareg)
library(transformr)
library(bayesplot)
library(patchwork)
library(marginaleffects)


##################################################################################################################
# binomial model to predict reciprocity with random slope for pair_id, given seed_position

m_recip <- glmmTMB(
  is_reciprocal ~ pair_set * cxn + seed_position + POS + (1 + seed_position | pair_id),
  data   = cxnpairSingleCfgRecip,
  family = binomial(link = "logit")
)
# to print model summary
#sink(file = "m_recip_output.txt")
#summary(m_recip)
#sink(file = NULL)

# create a corresponding main effects model & compare efficacy vs. with random pair effect model using lrtest

m_recip_main <- glmmTMB(
  is_reciprocal ~ pair_set + cxn + seed_position + POS,
  data   = cxnpairSingleCfgRecip,
  family = binomial(link = "logit")
)

lrtest(m_recip_main, m_recip)

# Look for uniform QQ residuals, no obvious pattern in residuals-vs-predicted, and no significant over/under-dispersion. 
sim_recip <- simulateResiduals(m_recip)
# check that plot window is big enough to accommodate the plot if it reports an error about figure margins too large
plot(sim_recip)
testDispersion(sim_recip)

##################################################################################################################
# beta regression model to predict expected word probability

# expected_prob_sq squeezes any exact 0s/1s in expected_prob into the open interval, per Smithson & Verkuilen (2006) 
# this would be needed for standard beta regression but ordered beta regression (used later), doesn't require it
# also: 
# the probability values that we're dealing with are softmax outputs from the PLM and are rarely exactly 0 or 1
# however, a rounding to four decimal places of probability values before being written to the results file may
# have introduced 0 values for what were actually near-zero values (subsequent runs should aim to fix this)
# on ordered beta regression: https://stats.andrewheiss.com/compassionate-clam/notebook/ordbeta.html

cxnpairSingleCfgPrb <- cxnpairSingleCfgRecip
n <- nrow(cxnpairSingleCfgPrb)
cxnpairSingleCfgPrb$expected_prob_sq <- (cxnpairSingleCfgPrb$expected_prob * (n - 1) + 0.5) / n

# initial beta model using glmmTMB 
m_prob <- glmmTMB(
  expected_prob_sq ~ pair_set * cxn + seed_position + POS + (1 | pair_id),
  data   = cxnpairSingleCfgPrb,
  family = beta_family(link = "logit")
)

# this model had issues with dispersion / non-uniform residuals
sim_prob <- simulateResiduals(m_prob)
plot(sim_prob, quantreg = T)
testDispersion(sim_prob)

# so ordbetareg used instead (which is designed explicitly for outcomes with genuine mass at the 0/1 boundary)
obrFormula <- bf(expected_prob_sq ~ pair_set * cxn + seed_position + POS + (1 | pair_id), phi ~ pair_set * cxn)

# FINAL ordbetareg model 
# ***** this takes a long time to run (on the order of 16 hours on a MacBook Pro M3 chip) *****

#m_prob_ordbeta_phi <- ordbetareg(
#  obrFormula,
#  phi_reg = "both", 
#  data = cxnpairSingleCfgPrb,
#  chains = 4,
#  iter   = 10000,   # up from 2000
#  warmup = 2000,
#  control = list(max_treedepth = 12)
#)
# to print model summary
#sink(file = "m_prob_output_ordbetareg_phi.txt")
#summary(m_prob_ordbeta_phi)
#sink(file = NULL)

#check between-group diffs in raw data
cxnpairSingleCfgPrb %>% dplyr::group_by(pair_set) %>% dplyr::summarise(mean(expected_prob_sq), median(expected_prob_sq))
cxnpairSingleCfgPrb %>% dplyr::group_by(cxn) %>% dplyr::summarise(mean(expected_prob_sq), median(expected_prob_sq))

# plot overall model outcome vs. actual
#out_plots_phi <- pp_check_ordbeta(m_prob_ordbeta_phi, ndraws = 200, outcome_label = "Expected Probability")
#out_plots_phi$continuous

# plot outcome vs. actual for individual pairs / constructions 
yrep_phi <- posterior_predict(m_prob_ordbeta_phi, ndraws = 500)
ppc_dens_overlay_grouped(y = cxnpairSingleCfgPrb$expected_prob_sq, yrep  = yrep_phi, group = cxnpairSingleCfgPrb$pair_set)
ppc_dens_overlay_grouped(y = cxnpairSingleCfgPrb$expected_prob_sq, yrep  = yrep_phi, group = cxnpairSingleCfgPrb$cxn)

# plots outcome vs. actual for a single construction
plot_cxn_check <- function(cxn_name, ordbetamodel) {
  d    <- subset(cxnpairSingleCfgPrb, cxn == cxn_name)
  yrep <- posterior_predict(ordbetamodel, newdata = d, ndraws = 500)
  ppc_dens_overlay(y = d$expected_prob_sq, yrep = yrep) +
    ggtitle(cxn_name) + xlab("expected probability") + 
    theme(plot.margin = margin(10, 10, 10, 15), axis.title.x = element_text(size=10), legend.position="none")
}

# combine plots for selected constructions
#plot_cxn_check("and", m_prob_ordbeta_phi) + plot_cxn_check("morethan", m_prob_ordbeta_phi) + plot_cxn_check("whether", m_prob_ordbeta_phi)

##################################################################################################################
# Estimated Marginal Means: emmeans gives estimated marginal means with confidence intervals and 
# Tukey-adjusted p-values on the response scale 

########################################
# reciprocity model

# pairwise construction contrasts
emm_recip_construction <- emmeans(m_recip, pairwise ~ cxn, type = "response")
emm_recip_construction$contrasts

# pairwise pair_set contrasts
emm_recip_pairset <- emmeans(m_recip, pairwise ~ pair_set, type = "response")
emm_recip_pairset$contrasts
emm_recip_pairset_cxn <- emmeans(m_recip, pairwise ~ pair_set | cxn, type = "response")
emm_recip_pairset_cxn$contrasts

# POS contrasts
emm_recip_POS <- emmeans(m_recip, pairwise ~ POS)
emm_recip_POS$contrasts
emm_recip_POS_pairs <- emmeans(m_recip, pairwise ~ POS | pair_set)
emm_recip_POS_pairs$contrasts


########################################
# expected probability model

# pairwise pair_set contrasts
emm_prob_pairset <- emmeans(m_prob_ordbeta_phi, pairwise ~ pair_set, type = "response")
emm_prob_pairset$contrasts
emm_prob_pairset_cxn <- emmeans(m_prob_ordbeta_phi, pairwise ~ pair_set | cxn, type = "response")
emm_prob_pairset_cxn$contrasts

# POS contrasts
emm_prob_POS <- emmeans(m_prob_ordbeta_phi, pairwise ~ POS)
emm_prob_POS$contrasts
emm_prob_POS_pairs <- emmeans(m_prob_ordbeta_phi, pairwise ~ POS | pair_set)
emm_prob_POS_pairs$contrasts

