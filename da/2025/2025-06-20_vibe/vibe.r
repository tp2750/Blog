ranges <- function(numbers) {
    a1 = sort(numbers)
    d1 = diff(a1)
    j1 = (d1 > 1)
    c(cat(a1[1],a1[j1 + 1]), cat(a1[j1],a1[length(a1)]))

}
