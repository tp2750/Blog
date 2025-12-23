# from https://www.version2.dk/holdning/hjemmearbejde-vibecoding

function ranges_vector(numbers)
    a1 = sort(numbers)
    d1 = diff(a1)
    j1 = findall(d1 .> 1)
    @debug a1
    @debug j1
    Pair.([a1[1];a1[j1 .+ 1]], [a1[j1];a1[end]])
end

function ranges_asjo(numbers)
    res = Pair{Int}[]
    sorted_numbers = sort(numbers)
    start = prev = popfirst!(sorted_numbers)  # first interval
    for number in sorted_numbers
        if number <= (prev + 1)  # belongs to same interval
            prev = number       # update end
            continue
        else
            push!(res, Pair(start, prev))      # interval ended
            start = prev = number  # start new
            continue
        end
        push!(res, Pair(start, prev))  # last interval
    end
    push!(res, Pair(start, prev))  # last interval
    res
end

v1 = rand(1:999,2000)

ranges_vector(v1); ranges_asjo(v1);

@time ranges_vector(v1);
@time ranges_asjo(v1);
# julia> @time ranges_vector(v1);
#   0.000044 seconds (43 allocations: 48.070 KiB)

# julia> @time ranges_asjo(v1);
#   0.000030 seconds (128 allocations: 29.203 KiB)

