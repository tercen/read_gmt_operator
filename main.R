library(tercen)
library(dplyr)
library(tidyr)
library(GSA)

doc_to_data = function(df){
  filename = tempfile()
  writeBin(ctx$client$fileService$download(df$documentId[1]), filename)
  on.exit(unlink(filename))
  
  dat <- GSA::GSA.read.gmt(filename)
  dat$genesets <- lapply(dat$genesets, paste, collapse = ",")
  
  df_out <- data.frame(
    set_name = dat$geneset.names,
    set_description = dat$geneset.descriptions,
    set_genes = unlist(dat$genesets)
  ) %>% 
    mutate(set_genes = strsplit(as.character(set_genes), ",")) %>%
    unnest(set_genes) %>%
    mutate(.ci= rep_len(df$.ci[1], nrow(.)))
  
  return(df_out)
}

ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

df <- ctx$cselect() %>% 
  mutate(.ci= 1:nrow(.)-1L) %>%
  split(.$.ci) %>%
  lapply(doc_to_data) %>%
  bind_rows() %>%
  ctx$addNamespace() %>%
  ctx$save()
