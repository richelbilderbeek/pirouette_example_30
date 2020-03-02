# Works under Linux and MacOS only
# pirouette example 30:
# create one exemplary DD tree, as used in the pirouette article
library(pirouette)
library(beautier)

# Constants
example_no <- 30
folder_name <- file.path(paste0("example_", example_no))
crown_age <- 10
n_taxa <- 6
rng_seed <- 314
is_testing <- is_on_travis()

# Create phylogenies
set.seed(rng_seed)
phylogeny <- create_dd_tree(n_taxa = n_taxa, crown_age = crown_age)

# Setup pirouette
pir_params <- create_std_pir_params(folder_name = folder_name)
if (is_testing) {
  pir_params <- shorten_pir_params(pir_params)
}

# Do the runs
pir_out <- pir_run(
  phylogeny,
  pir_params = pir_params
)

# Save results
pir_save(
  phylogeny = phylogeny,
  pir_params = pir_params,
  pir_out = pir_out,
  folder_name = folder_name
)

