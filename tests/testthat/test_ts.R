context("Time Series")

# Set params
Pde <- deviceevent(
  maude,
  time="date_received",
  device_hierarchy=c("device_name", "device_class"),
  event_hierarchy=c("event_type", "medical_specialty_description"),
  key="report_number",
  covariates="region",
  descriptors="_all_")
Pexp <- exposure(
  sales,
  time="sales_month",
  device_hierarchy="device_name",
  match_levels="region",
  count="sales_volume"
)
Pda <- define_analyses(
  Pde, "device_name",
  exposure=Pexp,
  covariates="region")

# Reference examples
a1 <- time_series(Pda[1:3], Pde, Pexp)
a2 <- time_series(Pda[[1]], Pde, Pexp)

expect_error(time_series(list(), Pde, Pexp))

# Basic
# -----

# Return behavior
test_that("function returns the correct class", {
  expect_is(a1, "list")
  expect_is(a1, "mds_das")
})
test_that("parameter requirements as expected", {
  expect_error(define_analyses())
  expect_error(define_analyses(Pde))
  expect_error(define_analyses(foo))
  expect_error(define_analyses(Pde, foo))
  expect_error(define_analyses(foo, foo))
  expect_is(define_analyses(Pde, Pdevice_level), "mds_das")
})
test_that("event_level accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, event_level="foo"))
  expect_error(define_analyses(Pde, Pdevice_level, event_level="device_1"))
  expect_error(define_analyses(Pde, Pdevice_level, event_level="event_1"))
  expect_error(define_analyses(Pde, Pdevice_level, event_level="lot_number"))
  expect_is(define_analyses(Pde, Pdevice_level, event_level="event_type"),
            "mds_das")
})
test_that("exposure accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, exposure="foo"))
  expect_error(define_analyses(Pde, Pdevice_level, exposure="device_1"))
  expect_error(define_analyses(Pde, Pdevice_level, exposure="event_1"))
  expect_error(define_analyses(Pde, Pdevice_level, exposure="lot_number"))
  expect_is(define_analyses(Pde, Pdevice_level, exposure=Pexp),
            "mds_das")
})
test_that("date_level accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, date_level="month"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level="day"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level="years"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level="device_1"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level="event_1"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level="lot_number"))
  expect_is(define_analyses(Pde, Pdevice_level, date_level="days"),
            "mds_das")
})
test_that("date_level_n accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, date_level_n="foo"))
  expect_error(define_analyses(Pde, Pdevice_level, date_level_n=1.5))
  expect_error(define_analyses(Pde, Pdevice_level, date_level_n=0))
  expect_error(define_analyses(Pde, Pdevice_level, date_level_n=-1))
  expect_is(define_analyses(Pde, Pdevice_level, date_level_n=2),
            "mds_das")
})
test_that("covariates accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, covariates="foo"))
  expect_error(define_analyses(Pde, Pdevice_level, covariates="device_1"))
  expect_error(define_analyses(Pde, Pdevice_level, covariates="event_1"))
  expect_error(define_analyses(Pde, Pdevice_level, covariates="lot_number"))
  expect_is(define_analyses(Pde, Pdevice_level, covariates=Pcovariates),
            "mds_das")
  expect_is(define_analyses(Pde, Pdevice_level, covariates="_all_"),
            "mds_das")
})
test_that("times_to_calc accepts only legal values", {
  expect_error(define_analyses(Pde, Pdevice_level, times_to_calc="foo"))
  expect_error(define_analyses(Pde, Pdevice_level, times_to_calc=1.5))
  expect_error(define_analyses(Pde, Pdevice_level, times_to_calc=0))
  expect_error(define_analyses(Pde, Pdevice_level, times_to_calc=-1))
  expect_is(define_analyses(Pde, Pdevice_level, times_to_calc=2),
            "mds_das")
})

# Attribute check
test_that("attributes are fully described and consistent", {
  expect_equal(names(attributes(a1)), c("date_level",
                                        "date_level_n",
                                        "device_level",
                                        "prior_used",
                                        "timestamp",
                                        "class"))
  expect_equal(attributes(a1)$date_level, "months")
  expect_equal(attributes(a1)$date_level_n, 1)
  expect_equal(attributes(a1)$device_level, Pdevice_level)
  expect_equal(attributes(a1)$prior_used, F)
  expect_is(attributes(a1)$timestamp, "POSIXct")
})


# Fully specified behavior
# ------------------------

test_that("individual analysis is specified as expected", {
  expect_is(a1[[1]], "mds_da")
  expect_equal(a1[[1]]$device_level_source, Pdevice_level)
  expect_equal(a1[[1]]$covariate, Pcovariates)
  expect_equal(sum(is.na(a1[[1]]$date_range_exposure)), 0)
  expect_equal(length(a1[[1]]$exp_covariate_level), 1)
  expect_is(a1[[length(a1)]], "mds_da")
  expect_equal(a1[[length(a1)]]$device_level_source, Pdevice_level)
  expect_equal(a1[[length(a1)]]$covariate, "Data")
  expect_equal(sum(is.na(a1[[length(a1)]]$date_range_exposure)), 0)
  expect_equal(length(a1[[length(a1)]]$exp_covariate_level), 1)
})


# Barebones behavior
# ------------------

# Reference example
a1 <- define_analyses(Pde, Pdevice_level)

test_that("barebones individual analysis is specified as expected", {
  expect_is(a1[[1]], "mds_da")
  expect_equal(a1[[1]]$device_level_source, Pdevice_level)
  expect_equal(a1[[1]]$covariate, "Data")
  expect_equal(a1[[1]]$date_range_exposure, as.Date(c(NA, NA)))
  expect_equal(a1[[1]]$exp_covariate_level, setNames(NA, NA))
})

# Attribute check
test_that("barebones attributes are fully described and consistent", {
  expect_equal(names(attributes(a1)), c("date_level",
                                        "date_level_n",
                                        "device_level",
                                        "prior_used",
                                        "timestamp",
                                        "class"))
  expect_equal(attributes(a1)$date_level, "months")
  expect_equal(attributes(a1)$date_level_n, 1)
  expect_equal(attributes(a1)$device_level, Pdevice_level)
  expect_equal(attributes(a1)$prior_used, F)
  expect_is(attributes(a1)$timestamp, "POSIXct")
})


# Time Change behavior
# --------------------

# Reference example
a1 <- define_analyses(
  Pde, Pdevice_level,
  date_level="days",
  date_level_n=7)

# Attribute check
test_that("time change attributes are consistent", {
  expect_equal(attributes(a1)$date_level, "days")
  expect_equal(attributes(a1)$date_level_n, 7)
})