#' OBJECTIVE:  
#'   * Look through the results of the predictive modeling
#'   
#' DEVELOPER NOTES:
#'   * 

dir.temp <- 'E:/ISTEP_Data/'
preds <- readRDS(paste0(dir.temp,'Pred_LibFM.RDS'))
require(RSQLite)
temp.db <- dbConnect("SQLite",dbname=paste0(dir.temp,'preds.sqlite'))
dbWriteTable(temp.db,"preds",preds)
dbDisconnect(temp.db)
