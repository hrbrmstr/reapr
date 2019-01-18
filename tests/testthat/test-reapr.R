context("URL reapig works")
test_that("we can do something", {

  x <- reap_url("https://httpbin.org/")
  testthat::expect_equal(length(x), 11)

})

context("Node extraction & table reaping works")
test_that("we can do something", {

  x <- reap_url("https://en.wikipedia.org/wiki/List_of_Asian_countries_by_area")

  y <- reap_node(x, ".//table[contains(., 'including European part')]")
  testthat::expect_is(y, "xml_node")

  z <- reap_table(y)
  testthat::expect_is(z, "data.frame")

  a <- reap_table(x)
  testthat::expect_true(length(a) > 3)

})

