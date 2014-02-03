#' OBJECTIVE:  
#'   * Make school inferences via generalized linear mixed models.
#'   
#' DEVELOPER NOTES:
#'   * Dataset is just too large for this level of inference


dir.proj <- 'E:/GitHub/ISTEP/'
require(lme4)


df.student <- readRDS(paste0(dir.proj,'02_Analytics/Data/Student_Level.RDS'))
str(df.student)
idx.sample <- sample.int(nrow(df.student),100000)


fit.simple <- glmer(
  pass ~ 1 + (1|year) + (1|grade)
  ,data=df.student
  ,subset=idx.sample
  ,family=binomial(link='logit')
  ,verbose=1
  ,control=glmerControl(optCtrl=list(maxfun=200))
  )
fit.simple
dotplot(ranef(fit.simple,condVar=TRUE))
