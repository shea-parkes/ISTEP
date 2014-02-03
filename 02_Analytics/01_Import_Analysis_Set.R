#' OBJECTIVE:  
#'   * Replicate data to recreate one observation per child.
#'   
#' DEVELOPER NOTES:
#'   * Something fishy is going on with the "pct_pass" from older years.


dir.proj <- 'E:/GitHub/ISTEP/'
dir.temp <- 'E:/ISTEP_Data/'

df.raw <- read.table(
  paste0(dir.proj,'01_Data_Munging/IStep_Passes_2007-2013-SKP.xlsm.txt')
  ,header=TRUE
  ,sep="|"
  ,quote=""
  ,colClasses=c(rep('factor',5),'integer','numeric')
  )
str(df.raw)
summary(df.raw)
sum(df.raw$n_pass<=0)
sum(df.raw$pct_pass>0.9999)

## Drop those with no passes due to rarity and inability to determine number who sat
df.effective <- subset(df.raw,n_pass > 0)

## (n_pass / pct_pass) is nowhere near a whole number, but just round it and move on for now.
df.effective$n_attempt <- as.integer(round(df.effective$n_pass / df.effective$pct_pass))
df.effective$n_fail <- df.effective$n_attempt - df.effective$n_pass
df.effective$year <- factor(df.effective$year,levels=sort(levels(df.effective$year),decreasing=TRUE))
str(df.effective)
summary(df.effective)
sum(df.effective$n_attempt)
saveRDS(df.effective,file=paste0(dir.temp,'Aggregate_Level.RDS'))

expand.pass <- rep(1:nrow(df.effective),times=df.effective$n_pass)
expand.fail <- rep(1:nrow(df.effective),times=df.effective$n_fail)
cols.keep <- c('district','school','year','grade','subject')

df.expand <- rbind(
  df.effective[expand.pass,cols.keep]
  ,df.effective[expand.fail,cols.keep]
  )

df.expand$pass <- rep(c(1L,0L),times=c(sum(df.effective$n_pass),sum(df.effective$n_fail)))
str(df.expand)

saveRDS(df.expand,file=paste0(dir.temp,'Student_Level.RDS'))
