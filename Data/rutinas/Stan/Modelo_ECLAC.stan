data {
  int<lower=1> D_obs;                  // Segmentos observados en el censo
  int<lower=1> D_tot;                  // Total de segmentos en el país
  int<lower=1> P;                      // Número de covariables
  int<lower=1> Q;                      // Número de efectos aleatorios
  array[D_obs] int<lower=0> Y_obs;     // Conteos poblacionales observados
  array[D_obs] int<lower=0> V_obs;     // Estructuras en segmentos observados
  array[D_tot] int<lower=0> V_tot;     // Estructuras en todos los segmentos
  matrix[D_obs, P] X_obs;              // Covariables en segmentos observados
  matrix[D_tot, P] X_tot;              // Covariables en todos los segmentos
  matrix[D_obs, Q] Z_obs;              // Indicadores de efectos aleatorios (observadas)
  matrix[D_tot, Q] Z_tot;              // Indicadores de efectos aleatorios (todas)
}

parameters {
  vector[P]           beta;     // Coeficientes de efectos fijos
  vector[Q]           gamma;    // Coeficientes de efectos aleatorios
  real<lower=0>       sigma;    // Escala de la distribución log-normal
  real<lower=0>       sigmaU;   // Escala de los efectos aleatorios
  vector<lower=0>[D_obs] densidad; // Densidades latentes en segmentos observados
}

transformed parameters {
  vector[D_obs]        lp;      // Predictor lineal
  vector<lower=0>[D_obs] lambda; // Parámetro Poisson

  lp = X_obs * beta + Z_obs * gamma;

  for (d in 1:D_obs)
    lambda[d] = fmin(fmax(1, densidad[d] * V_obs[d]), 10000000);
}

model {
  // Distribuciones previas
  beta   ~ normal(0, 100);
  gamma  ~ normal(0, sigmaU);
  sigma  ~ cauchy(0, 2.5);
  sigmaU ~ normal(0, 1);

  // Verosimilitud
  Y_obs    ~ poisson(lambda);
  densidad ~ lognormal(lp, sigma);
}

generated quantities {
  vector[D_tot]           lp_tot;
  array[D_tot] real<lower=0> densidad_hat;
  vector<lower=0>[D_tot]  lambda2;
  array[D_tot] int<lower=0> Y_tot;
  vector[D_obs]           log_lik;      // Log-verosimilitud puntual (LOO/WAIC)

  lp_tot = X_tot * beta + Z_tot * gamma;

  for (d in 1:D_tot) {
    densidad_hat[d] = lognormal_rng(lp_tot[d], sigma);
    lambda2[d]      = fmin(fmax(1, densidad_hat[d] * V_tot[d]), 10000000);
    Y_tot[d]        = poisson_rng(lambda2[d]);
  }

  for (d in 1:D_obs)
    log_lik[d] = poisson_lpmf(Y_obs[d] | lambda[d]);
}


