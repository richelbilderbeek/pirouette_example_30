# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
library(pirouette)

# Constants
example_no <- 30
folder_name <- file.path(paste0("example_", example_no))
crown_age <- 10
n_taxa <- 6
rng_seed <- 314

# Create phylogenies
set.seed(rng_seed)

# Nice, but does not match example 30
phylogeny <- create_exemplary_dd_tree(n_taxa = n_taxa, crown_age = crown_age)

# Create simulation function like example 28
sim_dd_tree_fun <- function(crown_age) {
  extinction_rate <- 0.1
  n_taxa <- 6
  n_0 <- 2 # Initial number of species at stem/crown of tree
  diff <- (log(n_taxa) - log(n_0)) / crown_age
  speciation_rate <- 3.0 * (diff + extinction_rate)
  carrying_capacity <- n_taxa # clade-level
  dd_parameters <- c(speciation_rate, extinction_rate, carrying_capacity)
  ddmodel <- 1 # linear dependence in speciation rate with parameter K
  dd_sim_result <- DDD::dd_sim(pars = dd_parameters, age  = crown_age, ddmodel = ddmodel)
  phylogeny <- dd_sim_result$tes # Only extant species
  phylogeny
}
sim_tree_fun <- pryr::partial(
  sim_dd_tree_fun,
  crown_age = crown_age
)
phylogeny <- sim_tree_fun()


# Setup pirouette
pir_params <- create_std_pir_params(folder_name = folder_name)
if (is_on_ci()) {
  pir_params <- shorten_pir_params(pir_params)
}

# Generative experiment
pir_params$experiments[[1]]$inference_model$tree_prior <- create_yule_tree_prior()
pir_params$experiments[[1]]$inference_model$site_model <- create_jc69_site_model()
pir_params$experiments[[1]]$inference_model$clock_model <- create_strict_clock_model()

# Simulate a twin tree using BD
pir_params$twinning_params$sim_twin_tree_fun <- get_sim_bd_twin_tree_fun()

check_pir_params(pir_params)


# Do the runs
pir_out <- pir_run(
  phylogeny,
  pir_params = pir_params
)

# Save data
pir_save(
  phylogeny = phylogeny,
  pir_params = pir_params,
  pir_out = pir_out,
  folder_name = folder_name
)

# Save plot
library(ggplot2)
pir_plot(pir_out) +
  ggtitle(paste0("pirouette example ", example_no)) +
  ggsave("errors.png", width = 7, height = 7)

