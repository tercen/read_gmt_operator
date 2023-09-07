suppressPackageStartupMessages({
  library(tercen)
  library(dplyr)
  library(tidyr)
  library(GSA)
})

ctx = tercenCtx()

if(!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

docId <- ctx$cselect()["documentId"][[1]]

filename = tempfile()
writeBin(ctx$client$fileService$download(docId), filename)
on.exit(unlink(filename))

dat <- GSA::GSA.read.gmt(filename)

table_1 <- dat$genesets %>%
  purrr::map(~ as_tibble(.)) %>%
  bind_rows(.id = "set_id") %>%
  mutate(set_id = as.double(set_id)) %>%
  rename(set_genes = value) %>%
  filter(set_genes != "") %>% 
  ctx$addNamespace() %>%
  as_relation()

table_2 <- tibble(
  set_id = seq_along(dat$geneset.names),
  set_name = dat$geneset.names,
  set_description = dat$geneset.descriptions
) %>% 
  mutate(set_id = as.double(set_id)) %>%
  ctx$addNamespace() %>%
  as_relation()

id_col <- paste0(ctx$namespace, ".set_id")

table_1 %>%
  left_join_relation(table_2, id_col, id_col) %>%
  as_join_operator(list(), list()) %>%
  save_relation(ctx)
