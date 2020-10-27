#' Dynamic Ensembles for Time Series Forecasting
#'
#' This package implements ensemble methods for time series
#' forecasting tasks. Dynamically combining different forecasting models
#' is a common approach to tackle these problems.
#'
#' The main methods in \strong{tsensembler} are in \code{\link{ADE-class}} and
#' \code{\link{DETS-class}}:
#' \describe{
#'   \item{\strong{ADE}}{Arbitrated Dynamic Ensemble (ADE) is an ensemble
#'   approach for dynamically combining forecasting models using
#'   a metalearning strategy called arbitrating. A meta model is
#'   trained for each base model in the ensemble. Each meta-learner is
#'   specifically designed to model the error of its associate
#'   across the time series. At forecasting time, the base models
#'   are weighted according to their degree of competence in the
#'   input observation, estimated by the predictions of the meta models}
#'   \item{\strong{DETS}}{Dynamic Ensemble for Time Series (DETS) is
#'   similar to \strong{ADE} in the sense that it adaptively combines
#'   the base models in an ensemble for time series forecasting. DETS
#'   follows a more traditional approach for forecaster combination. It
#'   pre-trains a set of heterogeneous base models, and at run-time
#'   weights them dynamically according to recent performance. Like \strong{ADE},
#'   the ensemble includes a committee, which dynamically selects a
#'   subset of base models that are weighted with a non-linear function}
#' }
#'
#' The ensemble methods can be used to \code{predict} new observations
#' or \code{forecast} future values of a time series. They can also be
#' updated using generic functions (check see also section).
#'
#' @seealso \code{\link{ADE-class}} for setting up an \strong{ADE} model;
#' and \code{\link{DETS-class}} for setting up an \strong{DETS} model;
#' see also \code{\link{update_weights}} and \code{\link{update_base_models}}
#' to check the generic function for updating the predictive models in
#' an ensemble.
#'
#' @references Cerqueira, Vitor; Torgo, Luis; Pinto, Fabio; and
#' Soares, Carlos. "Arbitrated Ensemble for Time Series Forecasting"
#' to appear at: Joint European Conference on Machine Learning and
#' Knowledge Discovery in Databases. Springer International
#' Publishing, 2017.
#'
#' V. Cerqueira, L. Torgo, and C. Soares, “Arbitrated ensemble for
#' solar radiation forecasting,” in International Work-Conference
#' on Artificial Neural Networks. Springer, 2017, pp. 720–732
#'
#' Cerqueira, Vitor; Torgo, Luis; Oliveira, Mariana, and Bernhard
#' Pfahringer. "Dynamic and Heterogeneous Ensembles for Time Series
#' Forecasting." Data Science and Advanced Analytics (DSAA), 2017
#' IEEE International Conference on. IEEE, 2017.
#'
#' @examples
#'
#' \dontrun{
#'
#' data("water_consumption")
#' # embedding time series into a matrix
#' dataset <- embed_timeseries(water_consumption, 5)
#'
#' # splitting data into train/test
#' train <- dataset[1:1000,]
#' test <- dataset[1001:1020, ]
#'
#' # setting up base model parameters
#' specs <- model_specs(
#'   learner = c("bm_ppr","bm_glm","bm_svr","bm_mars"),
#'   learner_pars = list(
#'     bm_glm = list(alpha = c(0, .5, 1)),
#'     bm_svr = list(kernel = c("rbfdot", "polydot"),
#'                   C = c(1,3)),
#'     bm_ppr = list(nterms = 4)
#'   ))
#'
#' # building the ensemble
#' model <- ADE(target ~., train, specs)
#'
#'
#' # forecast next value and update base and meta models
#' # every three points;
#' # in the other points, only the weights are updated
#' predictions <- numeric(nrow(test))
#' for (i in seq_along(predictions)) {
#'   predictions[i] <- predict(model, test[i, ])@y_hat
#'   if (i %% 3 == 0) {
#'     model <-
#'       update_base_models(model,
#'                          rbind.data.frame(train, test[seq_len(i), ]))
#'
#'     model <- update_ade_meta(model, rbind.data.frame(train, test[seq_len(i), ]))
#'   }
#'   else
#'     model <- update_weights(model, test[i, ])
#' }
#'
#' point_forecast <- forecast(model, h = 5)
#'
#' # setting up an ensemble of support vector machines
#' specs2 <-
#'   model_specs(learner = c("bm_svr"),
#'               learner_pars = list(
#'                 bm_svr = list(kernel = c("vanilladot", "polydot",
#'                                          "rbfdot"),
#'                               C = c(1,3,6))
#'               ))
#'
#' model <- DETS(target ~., train, specs2)
#' preds <- predict(model, test)@y_hat
#'
#' }
#'
#'
#' @docType package
#' @name tsensembler
NULL
