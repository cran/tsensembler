% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/base-models.r
\name{bm_glm}
\alias{bm_glm}
\title{Fit Generalized Linear Models}
\usage{
bm_glm(form, data, lpars)
}
\arguments{
\item{form}{formula}

\item{data}{training data for building the predictive
model}

\item{lpars}{a list containing the learning parameters}
}
\description{
Learning a Generalized Linear Model
from training data. Parameter setting
can vary in \strong{alpha}.
See \code{\link[glmnet]{glmnet}} for a comprehensive description.
}
\details{
Imports learning procedure from \strong{glmnet} package.
}
\seealso{
other learning models: \code{\link{bm_mars}};
\code{\link{bm_ppr}}; \code{\link{bm_gbm}};
\code{\link{bm_gaussianprocess}}; \code{\link{bm_cubist}};
\code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
\code{\link{bm_ffnn}}; \code{\link{bm_svr}}

Other base learning models: 
\code{\link{bm_cubist}()},
\code{\link{bm_ffnn}()},
\code{\link{bm_gaussianprocess}()},
\code{\link{bm_gbm}()},
\code{\link{bm_mars}()},
\code{\link{bm_pls_pcr}()},
\code{\link{bm_ppr}()},
\code{\link{bm_randomforest}()},
\code{\link{bm_svr}()}
}
\concept{base learning models}
\keyword{internal}
