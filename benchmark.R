imputation.benchmark.random = function(numRow = 100, numCol = 100, numMissing = 50,
    imputation.fn = NULL, ...) {

    if(is.null(imputation.fn)) { 
        stop("A handler to an imputation function should be passed in as an argument") 
    }

    missingX = sample(1:numRow, numMissing, replace=T)
    missingY = sample(1:numCol, numMissing, replace=T)

    x.missing = x = matrix(rnorm(numRow * numCol), numRow, numCol)
    for (i in 1:numMissing) {
        x.missing[missingX[i], missingY[i]] = NA
    }
    x.imputed = imputation.fn(x.missing, ...)

    SE = mapply(function(missingx,missingy) {
        ((x[missingx, missingy] - x.imputed[missingx, missingy]) / x[missingx, missingy])^2
    }, missingX, missingY)
    return (
        list(
            data = x,
            missing = x.missing,
            imputed = x.imputed,
            rmse = sqrt(mean(SE))
        )
    )
}

imputation.benchmark.ts = function(numTS = 100, TSlength = 100, numMissing = 50,
    imputation.fn = NULL, ...) {

    if(is.null(imputation.fn)) { 
        stop("A handler to an imputation function should be passed in as an argument") 
    }

    missingX = sample(1:numTS, numMissing, replace=T)
    missingY = sample(1:TSlength, numMissing, replace=T)

    x.missing = x = t(sapply(1:numTS, function(i) {
        rand = rnorm(1)
        #Need to be careful to only generate time series that are stationary
        if(rand <= 0) {
            series = arima.sim(n = TSlength, list(ar = c(0.8, -0.5), ma=c(-0.23, 0.25)) )
        } else if(rand > 0) {
            series = arima.sim(n = TSlength, list(ar = c(1, -0.5), ma=c(-.4)) )
        }
        return (as.vector(series))
    }))
    for (i in 1:numMissing) {
        x.missing[missingX[i], missingY[i]] = NA
    }
    x.imputed = imputation.fn(x.missing, ...)

    SE = mapply(function(missingx,missingy) {
        ((x[missingx, missingy] - x.imputed[missingx, missingy]) / x[missingx, missingy])^2
    }, missingX, missingY) 
    return (
        list(
            data = x,
            missing = x.missing,
            imputed = x.imputed,
            rmse = sqrt(mean(SE))
        )
    )
}
