#' OBJECTIVE:  
#'   * Output data back into flat sparse format.
#'   
#' DEVELOPER NOTES:
#'   * This should result in files suitable for libsvm/libfm/liblinear
#'   * The long package list is preferrable to the custom code that would otherwise be needed
#'   * Some code snippets inspired by here: http://stackoverflow.com/questions/17375056/r-sparse-matrix-conversion

dir.proj <- 'E:/GitHub/ISTEP/'
dir.temp <- 'E:/ISTEP_Data/'
exe.libfm <- 'E:/libfm-1.40.windows/libfm.exe'
require(Matrix)
require(SparseM)
require(e1071)
require(plyr)


###Want less than full rank (AKA full dummy coding) for any penalized work
orig.contrasts <- options('contrasts')[[1]]
contr.dummy <- function(...,contrasts=captured) contr.treatment(...,contrasts=FALSE)
cust.contrasts <- c('contr.dummy','contr.poly')
names(cust.contrasts) <- names(orig.contrasts)
options(contrasts=cust.contrasts);options('contrasts')


WriteSparseFlat <- function(i.df,name.out,i.feat=c('district','school','year','grade','subject')) {
  
  ## Ease into a sparse matrix with a helper function from the Matrix package
  ##  - There is no equivalent in the SparseM package
  i.Matrix.csc <- sparse.model.matrix(
    as.formula(paste(c('~0',i.feat),collapse='+'))
    ,data=i.df
    ,row.names=FALSE
  )
  
  ## Swap to a same structured matrix from the SparseM package
  i.SparseM.csc <- new(
    "matrix.csc"
    ,ra = i.Matrix.csc@x
    ,ja = i.Matrix.csc@i + 1L
    ,ia = i.Matrix.csc@p + 1L
    ,dimension = i.Matrix.csc@Dim
  )
  
  ## Change our structure while in the SparseM framework
  i.SparseM.csr <- as.matrix.csr(i.SparseM.csc)
  
  ## Figure out if we have a true response
  if('pass' %in% colnames(i.df)){
    i.resp <- i.df$pass
  } else {
    i.resp <- rep(0L,nrow(i.df))
  }
  
  ## Use the nice (but slow) write out function from e1071 package
  ##  - This only works (~well) on SparseM based matricies
  write.matrix.csr(
    x=i.SparseM.csr
    ,y=i.resp
    ,file=paste0(dir.temp,name.out)
  )
  
  return(TRUE)
}

df.student <- readRDS(paste0(dir.temp,'Student_Level.RDS'))
WriteSparseFlat(df.student,'Student_Sparse.txt')

df.source <- readRDS(paste0(dir.temp,'Aggregate_Level.RDS'))
## Since the imputed totals weren't integers but we made them be, re-evaluate this proportion
df.source$pct_pass <- df.source$n_pass/df.source$n_attempt
WriteSparseFlat(df.source,'Source_Sparse.txt')


ReduceSource <- function(i.feat) {
  return(ddply(
    df.source
    ,i.feat
    ,summarise
    ,n_pass=sum(n_pass)
    ,pct_pass=sum(n_pass)/sum(n_attempt)
    ,n_attempt=sum(n_attempt)
    ,n_fail=sum(n_fail)
    ))}

## Do just the most sensical drill-down hierarchy
##  - This lets us stay in the confines of the nice e1071 helper function
df.district <- ReduceSource(c('district'))
WriteSparseFlat(df.district,'District_Sparse.txt',c('district'))

df.school <- ReduceSource(c('district','school'))
WriteSparseFlat(df.school,'School_Sparse.txt',c('district','school'))

df.year <- ReduceSource(c('district','school','year'))
WriteSparseFlat(df.year,'Year_Sparse.txt',c('district','school','year'))

df.grade <- ReduceSource(c('district','school','year','grade'))
WriteSparseFlat(df.grade,'Grade_Sparse.txt',c('district','school','year','grade'))

## Do the stacking of the text files and data.frames
shell(paste(paste0(dir.proj,'02_Analytics/02b_Stack_Aggregate_Sparse.bat'),dir.temp))
df.aggs <- rbind.fill(df.source,df.district,df.school,df.year,df.grade)
df.aggs$agg.level <- factor(
  rep(
    c('subject','district','school','year','grade')
    ,times=c(nrow(df.source),nrow(df.district),nrow(df.school),nrow(df.year),nrow(df.grade))
    )
  ,levels=c('district','school','year','grade','subject')
  )
saveRDS(df.aggs,file=paste0(dir.temp,'Aggregate_Sparse_Matched.RDS'))

## The convenient write.matrix.csr doesn't start at zero, so just give that parameter a group of its own
groups.size <- sapply(df.source[,c('district','school','year','grade','subject')],function(x) length(levels(x)))
groups.indicies <- c(0L,rep((1:length(groups.size)),times=groups.size))
write(groups.indicies,file=paste0(dir.temp,'groups.txt'),ncolumns=1)
