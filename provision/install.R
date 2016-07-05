# Install frequently used R packages.

install.packages("ggplot2", repos = "http://cran.us.r-project.org")
install.packages("knitr", repos = "http://cran.us.r-project.org")
install.packages("glmnet", repos = "http://cran.us.r-project.org")
install.packages("pROC", repos = "http://cran.us.r-project.org")
install.packages("data.table", repos = "http://cran.us.r-project.org")
install.packages("caret", repos = "http://cran.us.r-project.org")
install.packages("sqldf", repos = "http://cran.us.r-project.org")
install.packages("wordcloud", repos = "http://cran.us.r-project.org")
install.packages(c('devtools','mplot', 'googleVis'), repos = 'http://cran.us.r-project.org');
require(devtools);
install_github('ramnathv/rCharts')
