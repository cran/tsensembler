% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metrics.r
\name{se}
\alias{se}
\title{Computing the squared error}
\usage{
se(y, y_hat)
}
\arguments{
\item{y}{A numeric vector representing the actual values.}

\item{y_hat}{A numeric vector representing the forecasted values.}
}
\value{
squared error of forecasted values.
}
\description{
Utility function to compute pointwise squared error (SE)
}
\seealso{
Other error/performance functions: 
\code{\link{ae}()},
\code{\link{mse}()}
}
\concept{error/performance functions}
\keyword{internal}
