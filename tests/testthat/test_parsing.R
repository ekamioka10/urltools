context("URL parsing tests")

test_that("Check parsing identifies each RfC element", {
  
  data <- url_parse("https://www.google.com:80/foo.php?api_params=turnip#ending")
  expect_that(ncol(data), equals(6))
  expect_that(names(data), equals(c("scheme","domain","port","path","parameter","fragment")))
  expect_that(data$scheme[1], equals("https"))
  expect_that(data$domain[1], equals("www.google.com"))
  expect_that(data$port[1], equals("80"))
  expect_that(data$path[1], equals("foo.php"))
  expect_that(data$parameter[1], equals("api_params=turnip"))
  expect_that(data$fragment[1], equals("ending"))
})

test_that("Check parsing can handle missing elements", {
  
  data <- url_parse("https://www.google.com/foo.php?api_params=turnip#ending")
  expect_that(ncol(data), equals(6))
  expect_that(names(data), equals(c("scheme","domain","port","path","parameter","fragment")))
  expect_that(data$scheme[1], equals("https"))
  expect_that(data$domain[1], equals("www.google.com"))
  expect_true(is.na(data$port[1]))
  expect_that(data$path[1], equals("foo.php"))
  expect_that(data$parameter[1], equals("api_params=turnip"))
  expect_that(data$fragment[1], equals("ending"))
})

test_that("Parsing does not up and die and misplace the fragment",{
  data <- url_parse("http://www.yeastgenome.org/locus/S000005366/overview#protein")
  expect_that(data$fragment[1], equals("protein"))
})

test_that("Composing works",{
  url <- c("http://foo.bar.baz/qux/", "https://en.wikipedia.org:4000/wiki/api.php")
  amended_url <- url_compose(url_parse(url))
  expect_that(url, equals(amended_url))
})

test_that("Port handling works", {
  url <- "https://en.wikipedia.org:4000/wiki/api.php"
  expect_that(port(url), equals("4000"))
  expect_that(path(url), equals("wiki/api.php"))
  url <- "https://en.wikipedia.org:4000"
  expect_that(port(url), equals("4000"))
  expect_true(is.na(path(url)))
  url <- "https://en.wikipedia.org:4000/"
  expect_that(port(url), equals("4000"))
  expect_true(is.na(path(url)))
  url <- "https://en.wikipedia.org:4000?foo=bar"
  expect_that(port(url), equals("4000"))
  expect_true(is.na(path(url)))
  expect_that(parameters(url), equals("foo=bar"))
})

test_that("Port handling does not break path handling", {
  url <- "https://en.wikipedia.org/wiki/File:Vice_City_Public_Radio_(logo).jpg"
  expect_true(is.na(port(url)))
  expect_that(path(url), equals("wiki/File:Vice_City_Public_Radio_(logo).jpg"))
})

test_that("URLs with parameters but no paths work", {
  url <- url_parse("http://www.nextpedition.com?inav=menu_travel_nextpedition")
  expect_true(url$domain[1] == "www.nextpedition.com")
  expect_true(is.na(url$port[1]))
  expect_true(is.na(url$path[1]))
  expect_true(url$parameter[1] == "inav=menu_travel_nextpedition")
})

test_that("URLs with user credentials drop said credentials when parsing", {
  out <- urltools::url_parse("http://foo:bar@97.77.104.22:3128")
  testthat::expect_identical(out$domain, "97.77.104.22")
})

test_that("IPv6 URLs can be handled", {
  url <- url_parse("tcp://[2607:5300:61:44f::]:8333")
  expect_true(url$domain[1] == "2607:5300:61:44f::")
  expect_true(url$port[1] == "8333")
})

test_that("URLs with @ in path", {
  out <- urltools::url_parse("https://medium.com/@mkhezr/plastic-fashion-a-data-story-4c65ff6efc36")
  testthat::expect_identical(out$domain, "medium.com")
})
