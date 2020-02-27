# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
suppressMessages(library(pirouette))
suppressMessages(library(ggplot2))
suppressMessages(library(pryr))
library(testthat)
expect_true(mcbette::can_run_mcbette())

################################################################################
# Constants
################################################################################
example_no <- 30
folder_name <- file.path(paste0("example_", example_no))
crown_age <- 10
n_taxa <- 6
rng_seed <- 314
is_testing <- is_on_travis()

if (is_testing) {
  folder_name <- rappdirs::user_cache_dir()
}

################################################################################
# Create phylogenies
################################################################################
set.seed(rng_seed)
phylogeny <- create_dd_tree(n_taxa = n_taxa, crown_age = crown_age)

################################################################################
# Create pirouette parameter sets
################################################################################
pir_params <- create_std_pir_params(folder_name = folder_name)

################################################################################
# Shorter run on Travis
################################################################################
if (is_testing) {
  pir_params$experiments <- shorten_experiments(pir_params$experiments)
}

################################################################################
# Save tree to files
################################################################################
# Need to create this folder for the newick file
dir.create(folder_name, showWarnings = FALSE, recursive = TRUE)
# Save tree to files
ape::write.tree(phylogeny, file = file.path(folder_name, "true_tree.newick"))

################################################################################
# Do the runs
################################################################################
errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)
check_pir_out(errors)

################################################################################
# Save
################################################################################
utils::write.csv(
  x = errors,
  file = file.path(folder_name, "errors.csv"),
  row.names = FALSE
)

pir_plot(errors) +
  ggsave(file.path(folder_name, "errors.png"), width = 7, height = 7)

pir_to_pics(
  phylogeny = phylogeny,
  pir_params = pir_params,
  folder = folder_name
)

pir_to_tables(
  pir_params = pir_params,
  folder = folder_name
)
