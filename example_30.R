# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
suppressMessages(library(pirouette))
suppressMessages(library(ggplot2))
suppressMessages(library(pryr))
testthat::expect_true(mcbette::can_run_mcbette())

root_folder <- "/home/richel/GitHubs/pirouette_example_30"
root_folder <- "/home/richel/temp/temp/pirouette_example_30"
if (is_on_travis()) {
  root_folder <- getwd()
}
example_no <- 30
rng_seed <- 314
example_folder <- file.path(root_folder, paste0("example_", example_no, "_", rng_seed))

crown_age <- 10
set.seed(rng_seed)
phylogeny <- create_dd_tree(n_taxa = 6, crown_age = crown_age)

alignment_params <- create_alignment_params(
  sim_tral_fun = get_sim_tral_with_std_nsm_fun(
    mutation_rate = 1.0 / crown_age
  ),
  root_sequence = create_blocked_dna(length = 1000)
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

# Shorter on Travis
if (is_on_travis()) {
  experiments <- shorten_experiments(experiments)
}

twinning_params <- create_twinning_params(
  sim_twin_tree_fun = get_sim_bd_twin_tree_fun(),
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

# Rename filenames
pir_params <- pir_rename_to_std(
  pir_params = pir_params,
  folder_name = example_folder
)

# Set the RNG seeds
pir_params <- renum_rng_seeds(
  pir_paramses = list(pir_params),
  rng_seeds = c(314)
)[[1]]

errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)

# Need to create this folder for the newick file
#dir.create(example_folder, showWarnings = FALSE, recursive = TRUE)
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
