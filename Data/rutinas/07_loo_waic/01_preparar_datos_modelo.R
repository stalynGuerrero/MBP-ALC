#########################################################
# Libro MBP-ALC - Capítulo 7, LOO/WAIC con datos reales    #
# Reconstruye data_model / list_par exactamente como en    #
# ../2024BRB/Rcodes/03_model_bayes_poisson.R (líneas       #
# 35-179), leyendo los insumos crudos SOLO desde el        #
# proyecto de origen (fuera de este repo, de solo lectura) #
# y sin copiar microdata a MBP-ALC: únicamente se guarda   #
# aquí list_par (covariables agregadas por ED), del mismo  #
# tipo que ya usa el ajuste de producción documentado en   #
# Data/ejemplos_reales/README.md.                          #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)

# Proyecto de origen (fuera de MBP-ALC, no versionado, solo lectura)
ruta_origen <- "V:/DAT/SAECEPAL/PopulationModels/2024BRB"

pop_2021 <- readRDS(file.path(ruta_origen, "Data/censo/dat_cesus_agg.rds")) %>%
  mutate(ED_number_value = as.character(ED_number_value))

data_cov <- readRDS(file.path(ruta_origen, "Data/DBases/dat_cova.rds"))

dat_temp <- readRDS(file.path(ruta_origen, "Data/DBases/2024-07-09_GL_DBase.rds")) %>%
  transmute(ED_number_value = as.character(edid),
            cont_Building = bb,
            domestic_electricity_clients = bel_domestic)

dat_connt <- read.csv(file.path(ruta_origen, "Data/DBases/brb_connect.csv")) %>%
  transmute(ED_number_value = as.factor(edid),
            parish_value   = pr_id,
            parish_label   = par_name)

data_model <-
  full_join(pop_2021 %>% select(ED_number_value, parish_value, hh_2021, cont_pers),
            dat_connt) %>%
  inner_join(data_cov) %>%
  inner_join(dat_temp) %>%
  mutate(per_com = ifelse(per_com >= 100, 100, per_com),
         hh_2021 = ifelse(is.na(hh_2021), 0, hh_2021),
         hh_2021_imp = ifelse(per_com < 90,
                               domestic_electricity_clients, hh_2021),
         per_com_ajus = ifelse(hh_2021 / hh_2021_imp * 100 < per_com,
                                hh_2021 / hh_2021_imp * 100, per_com))

################################################################################
## Selección de variables (idéntica a 03_model_bayes_poisson.R)
################################################################################
variable_sel <- c(
  "acc_hf_mean", "bb", "bb_dens", "bb_mean_barea", "bb_mean_bperim",
  "bb_mean_heig", "bb_mean_floor", "bel_domestic", "bwm_all", "dem_mean",
  "gb_mean_barea", "gb_mean_bperim", "gb_b1_dens", "ghsl_built_s_mean",
  "ghsl_smod_f_10", "ghsl_smod_f_11", "ghsl_smod_f_12", "ghsl_smod_f_13",
  "ghsl_smod_f_21", "ghsl_smod_f_23", "ghsl_smod_f_30",
  "lcover_simp_1", "lcover_simp_2", "lcover_simp_3", "lcover_simp_4",
  "lcover_simp_5", "lcover_simp_6", "lcover_simp_8",
  "lcover_90", "lcover_80", "lcover_60", "lcover_50", "lcover_40",
  "lcover_30", "lcover_200", "lcover_20", "lcover_126", "lcover_122",
  "lcover_116", "lcover_114", "lcover_112",
  "nl_mean", "length_0", "length_1", "length_2", "length_3"
)

variable_sel <- grep(pattern = "bwm", x = variable_sel, value = TRUE, invert = TRUE)

variable_sel <- setdiff(
  variable_sel,
  c("bel_all", "bel_all_ratio", "ghsl_smod_f_23", "lcover_114",
    "lcover_simp_NaN", "lcover_simp_6", "length", "length_ratio",
    "p_name", "bb_mean_floor", "lcover_simp_2")
)

sel_max <- data_cov %>% summarise_at(variable_sel, function(x) max(abs(x), na.rm = TRUE))
variable_sel <- names(sel_max)[sel_max < 5]

################################################################################
## Construcción de list_par
################################################################################
data_model_obs <- data_model %>% filter(!is.na(cont_pers))

D_obs <- nrow(data_model_obs)
D_tot <- nrow(data_model)
P     <- length(variable_sel)
Q     <- n_distinct(data_model$parish_value)
Y_obs <- data_model_obs$cont_pers
V_obs <- data_model_obs$hh_2021
V_tot <- data_model$hh_2021_imp
X_obs <- as.matrix(data_model_obs[, variable_sel])
X_tot <- as.matrix(data_model[, variable_sel])

Z_obs <- model.matrix(ED_number_value ~ -1 + parish_value,
                       data = data_model_obs %>% mutate(parish_value = as.factor(parish_value))) %>%
  as.matrix()
Z_tot <- model.matrix(ED_number_value ~ -1 + parish_value,
                       data = data_model %>% mutate(parish_value = as.factor(parish_value))) %>%
  as.matrix()

list_par <- list(
  D_obs = D_obs, D_tot = D_tot, P = P, Q = Q,
  Y_obs = Y_obs, V_obs = V_obs, V_tot = V_tot,
  X_obs = X_obs, X_tot = X_tot, Z_obs = Z_obs, Z_tot = Z_tot
)

cat("D_obs =", D_obs, " D_tot =", D_tot, " P =", P, " Q =", Q, "\n")
cat("NA en X_obs:", sum(is.na(X_obs)), " NA en X_tot:", sum(is.na(X_tot)), "\n")

saveRDS(list_par, "Data/rutinas/07_loo_waic/Output/list_par.rds")
