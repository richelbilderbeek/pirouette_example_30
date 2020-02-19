# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
suppressMessages(library(pirouette))
suppressMessages(library(ggplot2))

root_folder <- "~/GitHubs/pirouette_example_30"
example_no <- 30
rng_seed <- 314
example_folder <- file.path(root_folder, paste0("example_", example_no, "_", rng_seed))
dir.create(example_folder, showWarnings = FALSE, recursive = TRUE)
set.seed(rng_seed)
testit::assert(is_beast2_installed())

crown_age <- 10
phylogeny <- create_dd_tree(n_taxa = 6, crown_age = crown_age)

# Save tree to files
ape::write.tree(phylogeny, file = file.path(example_folder, "true_tree.newick"))

# Cannot do this on Peregrine
# png(filename = "true_tree.png", width = 7, height = 7)
# ape::plot.phylo(phylogeny)
# dev.off()

alignment_params <- create_alignment_params(
  sim_tral_fun = get_sim_tral_with_std_nsm_fun(
    mutation_rate = 1.0 / crown_age,
    site_model = create_jc69_site_model() # Explicit, same as default
  ),
  root_sequence = create_blocked_dna(length = 1000),
  rng_seed = rng_seed
)

# Hand-pick a generating model
# JC69, strict, Yule
generative_experiment <- create_gen_experiment()
# generative_experiment$beast2_options$input_filename <- "true_alignment_gen.xml"
# generative_experiment$beast2_options$output_state_filename <- "true_alignment_gen.xml.state"
# generative_experiment$inference_model$mcmc$tracelog$filename <- "true_alignment_gen.log"
# generative_experiment$inference_model$mcmc$treelog$filename <- "true_alignment_gen.trees"
# generative_experiment$inference_model$mcmc$screenlog$filename <- "true_alignment_gen.csv"
# generative_experiment$errors_filename <- "true_errors_gen.csv"
check_experiment(generative_experiment)

# Create the set of candidate birth-death experiments
candidate_experiments <- create_all_bd_experiments(
  exclude_model = generative_experiment$inference_model
)
# for (i in seq_along(candidate_experiments)) {
#   candidate_experiments[[i]]$beast2_options$input_filename <- "true_alignment_best.xml"
#   candidate_experiments[[i]]$beast2_options$output_state_filename <- "true_alignment_best.xml.state"
#   candidate_experiments[[i]]$inference_model$mcmc$tracelog$filename <- "true_alignment_best.log"
#   candidate_experiments[[i]]$inference_model$mcmc$treelog$filename <- "true_alignment_best.trees"
#   candidate_experiments[[i]]$inference_model$mcmc$screenlog$filename <- "true_alignment_best.csv"
#   candidate_experiments[[i]]$errors_filename <- "true_errors_best.csv"
# }

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
  # twin_tree_filename = "twin_tree.newick",
  # twin_alignment_filename = "twin_alignment.fas",
  # twin_evidence_filename = "twin_evidence.csv"
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

filenames <- get_pir_params_filenames(pir_params)

skip("Gotcha")
testthat::expect_true(
  all(
    stringr::str_detect(
      string = filenames,
      pattern = ".*/pirouette_example_30/.*"
    )
  )
)

rm_pir_param_files(pir_params)


if (1 == 2) {
  filenames_old <- get_pir_params_filenames(pir_params)

}

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
