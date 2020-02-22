# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
testthat::expect_true(mcbette::can_run_mcbette())

suppressMessages(library(pirouette))
suppressMessages(library(ggplot2))

root_folder <- "~/temp314/GitHubs/pirouette_example_30"
example_no <- 30
rng_seed <- 314
example_folder <- file.path(root_folder, paste0("example_", example_no, "_", rng_seed))

set.seed(rng_seed)

crown_age <- 10
phylogeny <- create_dd_tree(n_taxa = 6, crown_age = crown_age)

alignment_params <- create_alignment_params(
  sim_tral_fun = get_sim_tral_with_std_nsm_fun(
    mutation_rate = 1.0 / crown_age,
    site_model = create_jc69_site_model() # Explicit, same as default
  ),
  root_sequence = create_blocked_dna(length = 1000),
  rng_seed = rng_seed
)

# Hand-pick a generating model
# By default, this is JC69, strict, Yule
generative_experiment <- create_gen_experiment()
# Create the set of candidate birth-death experiments
candidate_experiments <- create_all_bd_experiments(
  exclude_model = generative_experiment$inference_model
)
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
  )
)

pir_params <- create_pir_params(
  alignment_params = alignment_params,
  experiments = experiments,
  twinning_params = twinning_params
)

pir_params <- pir_rename(
  pir_params = pir_params,
  rename_fun = get_replace_dir_fun(example_folder)
)

errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)

# Need to create this folder for the newick file
dir.create(example_folder, showWarnings = FALSE, recursive = TRUE)
# Save tree to files
ape::write.tree(phylogeny, file = file.path(example_folder, "true_tree.newick"))

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
