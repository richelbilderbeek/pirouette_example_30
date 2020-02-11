# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
suppressMessages(library(pirouette))
suppressMessages(library(ggplot2))

if (1 == 2) {
  setwd("~/GitHubs/pirouette_example_30")
}
root_folder <- getwd()
example_no <- 30
rng_seed <- 314
example_folder <- file.path(root_folder, paste0("example_", example_no, "_", rng_seed))
dir.create(example_folder, showWarnings = FALSE, recursive = TRUE)
setwd(example_folder)
set.seed(rng_seed)
testit::assert(is_beast2_installed())

crown_age <- 10
phylogeny <- create_dd_tree(n_taxa = 6, crown_age = crown_age)
ape::plot.phylo(phylogeny)
ape::write.tree(phylogeny, file = "true_tree.newick")

alignment_params <- create_alignment_params(
  sim_tral_fun = get_sim_tral_with_std_nsm_fun(
    mutation_rate = 1.0 / crown_age,
    site_model = create_jc69_site_model() # Explicit, same as default
  ),
  root_sequence = create_blocked_dna(length = 1000),
  rng_seed = rng_seed,
  fasta_filename = "true_alignment.fas"
)

# Hand-pick a generating model
# JC69, strict, Yule
generative_experiment <- create_gen_experiment()
generative_experiment$beast2_options$input_filename <- "true_alignment_gen.xml"
generative_experiment$beast2_options$output_state_filename <- "true_alignment_gen.xml.state"
generative_experiment$inference_model$mcmc$tracelog$filename <- "true_alignment_gen.log"
generative_experiment$inference_model$mcmc$treelog$filename <- "true_alignment_gen.trees"
generative_experiment$inference_model$mcmc$screenlog$filename <- "true_alignment_gen.csv"
generative_experiment$errors_filename <- "true_errors_gen.csv"
check_experiment(generative_experiment)

# Create the set of candidate experiments
# Use 2 different site models, 1 clock model and 2 tree priors
site_models <- list()
site_models[[1]] <- create_jc69_site_model()
site_models[[2]] <- create_hky_site_model()
clock_models <- list()
clock_models[[1]] <- create_strict_clock_model()
tree_priors <- list()
tree_priors[[1]] <- create_yule_tree_prior()
tree_priors[[2]] <- create_bd_tree_prior()
candidate_experiments <- create_all_experiments(
  site_models = site_models,
  clock_models = clock_models,
  tree_priors = tree_priors,
  exclude_model = generative_experiment$inference_model
)
for (i in seq_along(candidate_experiments)) {
  candidate_experiments[[i]]$beast2_options$input_filename <- "true_alignment_best.xml"
  candidate_experiments[[i]]$beast2_options$output_state_filename <- "true_alignment_best.xml.state"
  candidate_experiments[[i]]$inference_model$mcmc$tracelog$filename <- "true_alignment_best.log"
  candidate_experiments[[i]]$inference_model$mcmc$treelog$filename <- "true_alignment_best.trees"
  candidate_experiments[[i]]$inference_model$mcmc$screenlog$filename <- "true_alignment_best.csv"
  candidate_experiments[[i]]$errors_filename <- "true_errors_best.csv"
}

# Combine all experiments
experiments <- c(list(generative_experiment), candidate_experiments)

# Set the RNG seed
for (i in seq_along(experiments)) {
  experiments[[i]]$beast2_options$rng_seed <- rng_seed
}

# Shorter on Travis
if (is_on_travis()) {
  for (i in seq_along(experiments)) {
    experiments[[i]]$inference_model$mcmc$chain_length <- 3000
    experiments[[i]]$inference_model$mcmc$store_every <- 1000
    experiments[[i]]$est_evidence_mcmc$chain_length <- 3000
    experiments[[i]]$est_evidence_mcmc$store_every <- 1000
    experiments[[i]]$est_evidence_mcmc$epsilon <- 100.0
  }
}

twinning_params <- create_twinning_params(
  rng_seed_twin_tree = rng_seed,
  sim_twin_tree_fun = get_sim_bd_twin_tree_fun(),
  rng_seed_twin_alignment = rng_seed,
  sim_twal_fun = get_sim_twal_same_n_muts_fun(
    mutation_rate = 1.0 / crown_age,
    max_n_tries = 1000
  ),
  twin_tree_filename = "twin_tree.newick",
  twin_alignment_filename = "twin_alignment.fas",
  twin_evidence_filename = "twin_evidence.csv"
)

pir_params <- create_pir_params(
  alignment_params = alignment_params,
  experiments = experiments,
  twinning_params = twinning_params
)

rm_pir_param_files(pir_params)

errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)

utils::write.csv(
  x = errors,
  file = file.path(example_folder, "errors.csv"),
  row.names = FALSE
)

pir_plot(errors) +
  ggsave(file.path(example_folder, "errors.png"), width = 7, height = 7)

pir_to_pics(
  phylogeny = phylogeny,
  pir_params = pir_params,
  folder = example_folder
)

pir_to_tables(
  pir_params = pir_params,
  folder = example_folder
)
