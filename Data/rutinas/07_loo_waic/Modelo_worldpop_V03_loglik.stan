// Copia de Data/ejemplos_reales/BRB_2024/Modelo_worldpop_V03.stan (el programa
// Stan real y efectivamente ajustado, documentado en Data/ejemplos_reales/README.md)
// con una única adición: el vector log_lik en generated quantities, requerido
// por loo::extract_log_lik() para calcular los criterios LOO-CV y WAIC del
// Código \@ref(exr:cod-loo-waic). El resto del programa (data, parameters,
// transformed parameters, model) es idéntico al original; no se modifica el
// archivo original.

data {
  int<lower=1> D_obs; // Número de UGMs observadas en el censo
  int<lower=1> D_tot; // Número de UGMs en el pais
  int<lower=1> P; // Cantidad de regresores en los efectos fijos
  int<lower=1> Q; // Cantidad de efectos aleatorios
  int<lower=0> Y_obs[D_obs]; // Conteos de poblacion observada por UGM
  int<lower=0> V_obs[D_obs]; // Número de estructuras observadas en la UGM
  int<lower=0> V_tot[D_tot]; // Número de estructuras en la covariable satelital
  matrix[D_obs, P] X_obs; // Matriz de covariables en las UGMs observadas
  matrix[D_tot, P] X_tot; // Matriz de covariables en todas las UGMs del pais
  matrix[D_obs, Q] Z_obs; // Matriz de dummies para los efectos aleatorios en las UGMs observadas
  matrix[D_tot, Q] Z_tot; // Matriz de dummies para los efectos aleatorios en todas las UGMs del pais
}

parameters {
  vector[P] beta; // Vector de coeficientes de regresión de los efectos fijos
  vector[Q] gamma; // Vector de coeficientes de los efectos aleatorios
  real<lower=0> sigma; // Desviación estándar para la distribución log-normal
  real<lower=0> sigmaU; // Desviación estándar para los efectos aleatorios
  vector<lower=0>[D_obs] densidad; // Densidad poblacional para las UGMs observadas
}

transformed parameters {
  vector<lower=0>[D_obs] lambda; // Parámetro de la distribución Poisson
  vector[D_obs] lp; // Parámetro lineal de la distribución log-normal

  lp = X_obs * beta + Z_obs * gamma;

  for (d in 1:D_obs) {
    lambda[d] = densidad[d] * V_obs[d];
  }

}

model {
  // Priors
  gamma ~ normal(0, sigmaU);
  beta ~ normal(0, 1);
  sigma ~ cauchy(0, 2.5);
  sigmaU ~ normal(0, 1);
  // Likelihood
  Y_obs ~ poisson(lambda);

  // Log-normal distribution for densidad
  densidad ~ lognormal(lp, sigma);
}

generated quantities {
  vector[D_tot] lp_tot;
  real<lower=0> densidad_hat[D_tot]; // Predicción de la densidad de todas las UGMs del país
  int<lower=0> Y_tot[D_tot]; // Conteos de población observada por UGM en todo el país
  vector[D_obs] log_lik; // Log-verosimilitud puntual (LOO/WAIC), ausente en el original

  lp_tot = X_tot * beta + Z_tot * gamma;

  for (d in 1:D_tot) {
    densidad_hat[d] = lognormal_rng(lp_tot[d], sigma);
    densidad_hat[d] = fmin(densidad_hat[d], 20);
    Y_tot[d] = poisson_rng(densidad_hat[d] * V_tot[d]);
    }

  for (d in 1:D_obs)
    log_lik[d] = poisson_lpmf(Y_obs[d] | lambda[d]);
}
