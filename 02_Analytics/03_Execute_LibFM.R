#' OBJECTIVE:  
#'   * Execute LibFM against our nicely made datasets.
#'   
#' DEVELOPER NOTES:
#'   * Assumes the user copied the libFM.exe file into dir.temp on their own due to license restrictions.

dir.proj <- 'E:/GitHub/ISTEP/'
dir.temp <- 'E:/ISTEP_Data/'

shell(paste(
  paste0(dir.temp,'libFM.exe')
  ,'-task c'
  ,"-dim '1,1,16'"
  ,'-train',paste0(dir.temp,'Student_Sparse.txt')
  ,'-test',paste0(dir.temp,'Aggregate_Sparse.txt')
  ,'-meta',paste0(dir.temp,'groups.txt')
  ,'-rlog',paste0(dir.temp,'Log_LibFM.txt')
  ,'-out',paste0(dir.temp,'Pred_LibFM.txt')
  ,'-verbosity 1'
  ,'-iter 5000'
  ))

df.post <- readRDS(file=paste0(dir.temp,'Aggregate_Sparse_Matched.RDS'))
df.post$pred <- scan(paste0(dir.temp,'Pred_LibFM.txt'))

head(df.post[order(-df.post$n_attempt),],n=10)

plot(x=df.post$pct_pass,y=df.post$pred,pch='.')
saveRDS(df.post,paste0(dir.temp,'Pred_LibFM.RDS'))
