#' Fit Gaussian Process models
#'
#' Learning a Gaussian Process model from training
#' data. Parameter setting can vary in \strong{kernel}
#' and \strong{tolerance}. See \code{\link[kernlab]{gausspr}}
#' for a comprehensive description.
#'
#' Imports learning procedure from \strong{kernlab} package.
#'
#' @param form formula
#' @param data training data for building the predictive
#' model
#' @param lpars a list containing the learning parameters
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @import kernlab
#'
#' @return A list containing Gaussian Processes models
#'
#' @export
bm_gaussianprocess <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_gaussianprocess))
      lpars$bm_gaussianprocess <- list()

    if (is.null(lpars$bm_gaussianprocess$kernel))
      lpars$bm_gaussianprocess$kernel <- "rbfdot"
    if (is.null(lpars$bm_gaussianprocess$tol))
      lpars$bm_gaussianprocess$tol <- 0.001

    nmodels <-
      length(lpars$bm_gaussianprocess$kernel) *
      length(lpars$bm_gaussianprocess$tol)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (kernel in lpars$bm_gaussianprocess$kernel) {
      for (tolerance in lpars$bm_gaussianprocess$tol) {
        j <- j + 1L

        mnames[j] <- paste("gp", kernel, "krnl", tolerance, "tl", sep = "_")
        cat(mnames[j],"\n")
        if (!is.null(lpars$rm_ids)) {
          if (mnames[j] %in% names(lpars$rm_ids)) {
            rm_ids <- lpars$rm_ids[[mnames[j]]]
            data <- data[-rm_ids, ]
          }
        }

        ensemble[[j]] <-
          gausspr(form,
                  data,
                  type = "regression",
                  kernel = kernel,
                  tol = tolerance)

      }
    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Projection Pursuit Regression models
#'
#' Learning a Projection Pursuit Regression
#' model from training data. Parameter setting
#' can vary in \strong{nterms} and \strong{sm.method}
#' parameters. See \code{\link[stats]{ppr}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{stats} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_gaussianprocess}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @importFrom stats ppr
#'
#' @export
bm_ppr <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_ppr))
      lpars$bm_ppr <- list()

    if (is.null(lpars$bm_ppr$nterms))
      lpars$bm_ppr$nterms <- 3
    if (is.null(lpars$bm_ppr$sm.method))
      lpars$bm_ppr$sm.method <- "supsmu"

    nmodels <-
      length(lpars$bm_ppr$nterms) * length(lpars$bm_ppr$sm.method)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (nterm in lpars$bm_ppr$nterms) {
      for (smoother in lpars$bm_ppr$sm.method) {
        j <- j + 1L
        mnames[j] <- paste0("ppr_", nterm, "nterms_", smoother)
        cat(mnames[j],"\n")
        if (!is.null(lpars$rm_ids)) {
          if (mnames[j] %in% names(lpars$rm_ids)) {
            rm_ids <- lpars$rm_ids[[mnames[j]]]
            data <- data[-rm_ids, ]
          }
        }


        ensemble[[j]] <-
          ppr(form,
              data,
              nterms = nterm,
              sm.method = smoother)

      }
    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Generalized Linear Models
#'
#' Learning a Generalized Linear Model
#' from training data. Parameter setting
#' can vary in \strong{alpha}.
#' See \code{\link[glmnet]{glmnet}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{glmnet} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_gaussianprocess}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @import glmnet
#'
#' @export
bm_glm <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_glm))
      lpars$bm_glm <- list()

    if (is.null(lpars$bm_glm$alpha))
      lpars$bm_glm$alpha <- c(0, 1)

    X <- stats::model.matrix(form, data)
    Y <- get_y(data, form)

    nmodels <- length(lpars$bm_glm$alpha)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (alpha in lpars$bm_glm$alpha) {
      j <- j + 1L

      if (alpha == 0) {
        mnames[j] <- "glm_ridge"
      } else if (alpha == 1) {
        mnames[j] <- "glm_lasso"
      } else {
        mnames[j] <- paste("glm_enet", alpha, sep = "_")
      }
      cat(mnames[j],"\n")

      if (!is.null(lpars$rm_ids)) {
        if (mnames[j] %in% names(lpars$rm_ids)) {
          cat("ss")
          rm_ids <- lpars$rm_ids[[mnames[j]]]
          X <- X[-rm_ids, ]
          Y <- Y[-rm_ids]
        }
      }

      m.all <- glmnet(X, Y, alpha = alpha)
      ensemble[[j]] <-
        glmnet(X,
               Y,
               alpha = alpha,
               lambda = min(m.all$lambda))

    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Generalized Boosted Regression models
#'
#' Learning a Boosted Tree Model
#' from training data. Parameter setting
#' can vary in \strong{interaction.depth},
#' \strong{n.trees}, and \strong{shrinkage}
#' parameters.
#'
#' See \code{\link[gbm]{gbm}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{gbm} package.
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gaussianprocess}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @inheritParams bm_gaussianprocess
#'
#' @import gbm
#'
#' @export
bm_gbm <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_gbm))
      lpars$bm_gbm <- list()

    if (is.null(lpars$bm_gbm$interaction.depth))
      lpars$bm_gbm$interaction.depth <- 1
    if (is.null(lpars$bm_gbm$shrinkage))
      lpars$bm_gbm$shrinkage <- 0.001
    if (is.null(lpars$bm_gbm$n.trees))
      lpars$bm_gbm$n.trees <- 500
    if (is.null(lpars$bm_gbm$dist))
      lpars$bm_gbm$dist <- "gaussian"

    gbm_p <- lpars$bm_gbm
    nmodels <-
      length(gbm_p$interaction.depth) *
      length(gbm_p$shrinkage) *
      length(gbm_p$n.trees) * 
      length(gbm_p$dist)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (id in lpars$bm_gbm$interaction.depth) {
      for (mdist in lpars$bm_gbm$dist) {
        for (shrinkage in lpars$bm_gbm$shrinkage) {
          for (n.trees in lpars$bm_gbm$n.trees) {
            j <- j + 1L

            mnames[j] <-
              paste("gbm", mdist, n.trees, "t", id, "id", shrinkage, "sh", sep = "_")

            cat(mnames[j],"\n")
            if (!is.null(lpars$rm_ids)) {
              if (mnames[j] %in% names(lpars$rm_ids)) {
                rm_ids <- lpars$rm_ids[[mnames[j]]]
                data <- data[-rm_ids, ]
              }
            }

            ensemble[[j]] <-
              gbm(
                form,
                data,
                distribution = mdist,
                interaction.depth = id,
                shrinkage = shrinkage,
                n.trees = n.trees
              )

          }
        }
      }
    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Random Forest models
#'
#' Learning a Random Forest Model
#' from training data. Parameter setting
#' can vary in \strong{num.trees} and \strong{mtry}
#' parameters.
#'
#' See \code{\link[ranger]{ranger}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{ranger} package.
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_gaussianprocess}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @inheritParams bm_gaussianprocess
#'
#' @import ranger
#'
#' @export
bm_randomforest <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_randomforest))
      lpars$bm_randomforest <- list()

    if (is.null(lpars$bm_randomforest$num.trees))
      lpars$bm_randomforest$num.trees <- 500
    if (is.null(lpars$bm_randomforest$mtry))
      lpars$bm_randomforest$mtry <- ceiling(ncol(data) / 3)

    bad_mtry <- lpars$bm_randomforest$mtry > (ncol(data) - 1)

    if (any(bad_mtry)) {
      b_id <- which(bad_mtry)
      lpars$bm_randomforest$mtry[b_id] <- ceiling(ncol(data) / 3)
    }

    nmodels <-
      length(lpars$bm_randomforest$num.trees) *
      length(lpars$bm_randomforest$mtry)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (num.trees in lpars$bm_randomforest$num.trees) {
      for (mtry in lpars$bm_randomforest$mtry) {
        j <- j + 1L

        mnames[j] <- paste0("rf_n", num.trees, "m", mtry)
        cat(mnames[j],"\n")
        if (!is.null(lpars$rm_ids)) {
          if (mnames[j] %in% names(lpars$rm_ids)) {
            rm_ids <- lpars$rm_ids[[mnames[j]]]
            data <- data[-rm_ids, ]
          }
        }


        ensemble[[j]] <-
          ranger(
            form,
            data,
            num.trees = num.trees,
            mtry = mtry,
            write.forest = TRUE)
      }
    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Cubist models (M5)
#'
#' Learning a M5 model from training data
#' Parameter setting can vary in \strong{committees}
#' and \strong{neighbors} parameters.
#'
#' See \code{\link[Cubist]{cubist}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{Cubist} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_gaussianprocess}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @importFrom Cubist cubist
#'
#' @export
bm_cubist <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_cubist))
      lpars$bm_cubist <- list()

    if (is.null(lpars$bm_cubist$committees))
      lpars$bm_cubist$committees <- 50
    if (is.null(lpars$bm_cubist$neighbors))
      lpars$bm_cubist$neighbors <- 0

    form <- stats::as.formula(paste(deparse(form), "-1"))

    nmodels <-
      length(lpars$bm_cubist$committees) *
      length(lpars$bm_cubist$neighbors)

    X <- stats::model.matrix(form, data)
    Y <- get_y(data, form)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (ncom in lpars$bm_cubist$committees) {
      for (neighbors in lpars$bm_cubist$neighbors) {
        j <- j + 1L

        mnames[j] <- paste0("cub_", ncom, "it", neighbors, "nn")
        cat(mnames[j],"\n")

        if (!is.null(lpars$rm_ids)) {
          if (mnames[j] %in% names(lpars$rm_ids)) {
            rm_ids <- lpars$rm_ids[[mnames[j]]]
            X <- X[-rm_ids, ]
            Y <- Y[-rm_ids]
          }
        }


        ensemble[[j]] <-
          cubist(X, Y, committees = ncom, neighbors = neighbors)

      }
    }
    names(ensemble) <- mnames

    ensemble
  }

#' Fit Multivariate Adaptive Regression Splines models
#'
#' Learning a Multivariate Adaptive Regression Splines
#' model from training data.
#'
#' Parameter setting can vary in \strong{nk},
#' \strong{degree}, and \strong{thresh} parameters.
#'
#' See \code{\link[earth]{earth}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{earth} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_gaussianprocess}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @importFrom earth earth
#'
#' @export
bm_mars <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_mars))
      lpars$bm_mars <- list()

    if (is.null(lpars$bm_mars$nk))
      lpars$bm_mars$nk <- 10
    if (is.null(lpars$bm_mars$degree))
      lpars$bm_mars$degree <- 3
    if (is.null(lpars$bm_mars$thresh))
      lpars$bm_mars$thresh <- 0.001

    nmodels <-
      length(lpars$bm_mars$nk) *
      length(lpars$bm_mars$degree) *
      length(lpars$bm_mars$thresh)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (nk in lpars$bm_mars$nk) {
      for (degree in lpars$bm_mars$degree) {
        for (thresh in lpars$bm_mars$thresh) {
          j <- j + 1L

          mnames[j] <- paste0("mars_nk", nk, "_d", degree, "t", thresh)
          cat(mnames[j],"\n")
          if (!is.null(lpars$rm_ids)) {
            if (mnames[j] %in% names(lpars$rm_ids)) {
              rm_ids <- lpars$rm_ids[[mnames[j]]]
              data <- data[-rm_ids, ]
            }
          }


          ensemble[[j]] <-
            earth(form,
                  data,
                  nk = nk,
                  degree = degree,
                  thresh = thresh)

        }
      }
    }
    names(ensemble) <- mnames

    ensemble
  }


#' Fit Support Vector Regression models
#'
#' Learning a Support Vector Regression
#' model from training data.
#'
#' Parameter setting can vary in \strong{kernel},
#' \strong{C}, and \strong{epsilon} parameters.
#'
#' See \code{\link[kernlab]{ksvm}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{kernlab} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_gaussianprocess}}
#'
#' @import kernlab
#'
#' @export
bm_svr <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_svr))
      lpars$bm_svr <- list()

    if (is.null(lpars$bm_svr$scale))
      lpars$bm_svr$scale <- FALSE
    if (is.null(lpars$bm_svr$type))
      lpars$bm_svr$type <- "eps-svr"
    if (is.null(lpars$bm_svr$kernel))
      lpars$bm_svr$kernel <- "vanilladot"
    if (is.null(lpars$bm_svr$epsilon))
      lpars$bm_svr$epsilon <- 0.1
    if (is.null(lpars$bm_svr$C))
      lpars$bm_svr$C <- 1

    nmodels <-
      length(lpars$bm_svr$kernel) *
      length(lpars$bm_svr$epsilon) *
      length(lpars$bm_svr$C)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (kernel in lpars$bm_svr$kernel) {
      for (epsilon in lpars$bm_svr$epsilon) {
        for (C in lpars$bm_svr$C) {
          j <- j + 1L

          mnames[j] <- paste0("svm_", kernel, "g", epsilon, "c", C)
          cat(mnames[j],"\n")
          if (!is.null(lpars$rm_ids)) {
            if (mnames[j] %in% names(lpars$rm_ids)) {
              rm_ids <- lpars$rm_ids[[mnames[j]]]
              data <- data[-rm_ids, ]
            }
          }


          ensemble[[j]] <-
            ksvm(
              form,
              data,
              scale = lpars$bm_svr$scale,
              kernel = kernel,
              type = lpars$bm_svr$type,
              epsilon = epsilon,
              C = C)

        }
      }
    }
    names(ensemble) <- mnames

    ensemble
  }


#' Fit Feedforward Neural Networks models
#'
#' Learning a Feedforward Neural Network
#' model from training data.
#'
#' Parameter setting can vary in \strong{size}, \strong{maxit},
#' and \strong{decay} parameters.
#'
#' See \code{\link[nnet]{nnet}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{nnet} package.
#'
#' @inheritParams bm_gaussianprocess
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_pls_pcr}};
#' \code{\link{bm_gaussianprocess}}; \code{\link{bm_svr}}
#'
#' @import nnet
#'
#' @export
bm_ffnn <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_ffnn))
      lpars$bm_ffnn <- list()

    if (is.null(lpars$bm_ffnn$trace))
      lpars$bm_ffnn$trace <- FALSE
    if (is.null(lpars$bm_ffnn$linout))
      lpars$bm_ffnn$linout <- TRUE
    if (is.null(lpars$bm_ffnn$size))
      lpars$bm_ffnn$size <- 30
    if (is.null(lpars$bm_ffnn$decay))
      lpars$bm_ffnn$decay <- 0.01
    if (is.null(lpars$bm_ffnn$maxit))
      lpars$bm_ffnn$maxit <- 750

    nmodels <-
      length(lpars$bm_ffnn$maxit) *
      length(lpars$bm_ffnn$size) *
      length(lpars$bm_ffnn$decay)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (maxit in lpars$bm_ffnn$maxit) {
      for (size in lpars$bm_ffnn$size) {
        for (decay in lpars$bm_ffnn$decay) {
          j <- j + 1L

          mnames[j] <- paste0("nnet_s", size, "_d", decay, "m", maxit)
          cat(mnames[j],"\n")
          if (!is.null(lpars$rm_ids)) {
            if (mnames[j] %in% names(lpars$rm_ids)) {
              rm_ids <- lpars$rm_ids[[mnames[j]]]
              data <- data[-rm_ids, ]
            }
          }

          ensemble[[j]] <-
            nnet(
              form,
              data,
              linout = lpars$bm_ffnn$linout,
              size = size,
              maxit = maxit,
              decay = decay,
              trace = lpars$bm_ffnn$trace,
              MaxNWts = 1000000
            )

        }
      }
    }
    names(ensemble) <- mnames

    ensemble
  }


#' Fit PLS/PCR regression models
#'
#' Learning aPartial Least Squares or
#' Principal Components Regression from training data
#'
#' Parameter setting can vary in \strong{method}
#'
#' See \code{\link[pls]{mvr}} for a comprehensive description.
#'
#' Imports learning procedure from \strong{pls} package.
#'
#' @param form formula
#' @param data data to train the model
#' @param lpars parameter setting: For this multivariate regression
#' model the main parameter is "method". The available options are
#' "kernelpls", "svdpc", "cppls", "widekernelpls", and "simpls"
#'
#' @importFrom pls mvr
#'
#' @family base learning models
#'
#' @seealso other learning models: \code{\link{bm_mars}};
#' \code{\link{bm_ppr}}; \code{\link{bm_gbm}};
#' \code{\link{bm_glm}}; \code{\link{bm_cubist}};
#' \code{\link{bm_randomforest}}; \code{\link{bm_gaussianprocess}};
#' \code{\link{bm_ffnn}}; \code{\link{bm_svr}}
#'
#' @export
bm_pls_pcr <-
  function(form, data, lpars) {
    if (is.null(lpars$bm_pls_pcr))
      lpars$bm_pls_pcr <- list()

    if (is.null(lpars$bm_pls_pcr$method))
      lpars$bm_pls_pcr$method <- "kernelpls"

    nmodels <-
      length(lpars$bm_pls_pcr$method)

    j <- 0
    ensemble <- vector("list", nmodels)
    mnames <- character(nmodels)
    for (method in lpars$bm_pls_pcr$method) {
      j <- j + 1L

      mnames[j] <- paste("mvr", method, sep = "_")
      cat(mnames[j],"\n")

      if (!is.null(lpars$rm_ids)) {
        if (mnames[j] %in% names(lpars$rm_ids)) {
          rm_ids <- lpars$rm_ids[[mnames[j]]]
          data <- data[-rm_ids, ]
        }
      }

      model <-
        tryCatch(mvr(formula = form,
                     data = data,
                     method = method), error = function(e) NULL)

      if (!is.null(model)) {
        model$best_comp_train <- best_mvr(model, form, data)
      } else {
        mnames[j] <- NA_character_
      }
      ensemble[[j]] <- model
    }
    mnames <- mnames[!is.na(mnames)]
    ## se nalgum ensemble existe modelo, mete nomes...
    all_null <- all(sapply(ensemble, is.null))
    if (!all_null) { ### ensemble
      names(ensemble) <- mnames
    }

    ensemble
  }

#' Get best PLS/PCR model
#'
#' @param obj PLS/PCR model object
#' @param form formula
#' @param validation_data validation data used for
#' predicting performances of the model by number
#' of principal components
#'
#' @keywords internal
#'
#' @export
best_mvr <-
  function(obj, form, validation_data) {
    val_hat <- predict(obj, validation_data)

    target_var <- get_target(form)
    Y <- get_y(validation_data, form)

    val_hat <- as.data.frame(val_hat)

    err_by_comp <-
      sapply(val_hat,
             function(o)
               rmse(Y, o),
             USE.NAMES = FALSE)

    which.min(err_by_comp)
  }


#' pre dsss
#'
#' @param model model
#' @param newdata dn
#'
#' @export
predict_pls_pcr <-
  function(model, newdata) {
    bcomp <- model$best_comp_train
    as.data.frame(predict(model, newdata))[,bcomp]
  }


#' sadadadadasdadas
#' @param model model
#' @param newdata dn
#'
#' @import forecast
#' @export
arima_offline_forecast <-
  function(model, newdata) {
    form <- model$form
    train <- model$trainset
    xreg_cols <- model$cols_xrg
    model$cols_xrg <- NULL

    Y_tr <- get_y(train, form)
    Y_ts <- get_y(newdata, form)
    Y <- c(Y_tr, Y_ts)

    N <- nrow(train)

    all_data <- rbind.data.frame(train, newdata)

    if (length(xreg_cols) > 0) {
      xregm <- as.matrix(all_data[, xreg_cols])
      colnames(xregm) <- colnames(newdata)[xreg_cols]
    } else {
      xregm <- NULL
    }

    arima_m <-
      Arima(y = Y,
            xreg = xregm,
            model = model)

    arima_hat <- stats::fitted(arima_m)[-seq_len(N)]

    arima_hat
  }

#' sadasasadd
#'
#' @param model model
#' @param newdata nd
#'
#'
#' @import forecast
#' @export
arima_online_forecast <-
  function(model, newdata) {
    form <- model$form
    train <- model$trainset
    xreg_cols <- model$cols_xrg
    model$cols_xrg <- NULL

    Y_tr <- get_y(train, form)
    Y_ts <- get_y(newdata, form)

    N <- nrow(train)

    all_data <- rbind.data.frame(train, newdata)

    if (length(xreg_cols) > 0) {
      xregm_c <- as.matrix(all_data[, xreg_cols])
      colnames(xregm_c) <- colnames(newdata)[xreg_cols]
    } else {
      xregm_c <- NULL
    }

    arima_hat <- numeric(nrow(newdata))
    for (j in seq_along(arima_hat)) {
      xregm <- xregm_c[N+j,]

      arima_hat[j] <- forecast::forecast(model, h = 1)$mean

      Y <- c(Y_tr, Y_ts[seq_len(j)])

      model <- auto.arima(y = Y, xreg = xregm_c[seq_len(N+j), ])
    }

    arima_hat
  }


#' auto arima bm
#' @param form form
#' @param data data
#' @param lpars ls
#'
#' @export
bm_auto_arima <-
  function(form, data, lpars) {
    Y <- get_y(data, form)

    tgt_col <- colnames(data) %in% get_target(form)
    xreg_cols <- which(!(get_embedcols(data) | tgt_col))

    if (length(xreg_cols) > 0) {
      xregm <- as.matrix(data[,xreg_cols])
      colnames(xregm) <- colnames(data)[xreg_cols]
    } else
      xregm <- NULL

    auto_arima <- tryCatch(forecast::auto.arima(y = Y, xreg = xregm), error = function(e) NULL)
    if (is.null(auto_arima)) {
      auto_arima <- forecast::Arima(Y, order = c(0,0,0))
    }
    auto_arima$trainset <- data
    auto_arima$form <- form
    auto_arima$cols_xrg <- xreg_cols

    mcoefs <- auto_arima$arma[c(1,5,2)]
    mcoefs <- paste0(mcoefs, collapse = "")

    auto_arima <- list(auto_arima)

    #names(auto_arima) <- paste("arima", mcoefs, sep = "_")
    names(auto_arima) <- "arima_auto"

    auto_arima
  }
