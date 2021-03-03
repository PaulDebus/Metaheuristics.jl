include("operators.jl")
include("dominated_sort_crowding.jl")

mutable struct NSGA2 <: AbstractParameters
    N::Int
    η_cr::Float64
    p_cr::Float64
    η_m::Float64
    p_m::Float64
    ε::Float64
end

"""
    function NSGA2(;
        N = 100,
        η_cr = 20,
        p_cr = 0.9,
        η_m = 20,
        p_m = 1.0 / D,
        ε = eps(),
        information = Information(),
        options = Options(),
    )

Parameters for the metaheuristic NSGA-II.

Parameters:

- `N` Population size.
- `η_cr`  η for the crossover.
- `p_cr` Crossover probability.
- `η_m`  η for the mutation operator.
- `p_m` Mutation probability (1/D for D-dimensional problem by default).

To use NSGA2, the output from the objective function should be a 3-touple
`(f::Vector, g::Vector, h::Vector)`, where `f` contains the objective functions,
`g` and `h` are the equality and inequality constraints respectively.

A feasible solution is such that `g_i(x) ≤ 0 and h_j(x) = 0`.


```julia
using Metaheuristics

# Dimension
D = 2

# Objective function
f(x) = ( x, [sum(x.^2) - 1], [0.0] ) 

# bounds
bounds = [-1 -1;
           1  1.0
        ]

# define the parameters (use `NSGA2()` for using default parameters)
nsga2 = NSGA2(N = 100, p_cr = 0.85)

# optimize
status = optimize(f, bounds, nsga2)

# show results
display(status)
```

"""
function NSGA2(;
    N = 100,
    η_cr = 20,
    p_cr = 0.9,
    η_m = 20,
    p_m = -1,
    ε = eps(),
    information = Information(),
    options = Options(),
)

    parameters = NSGA2(N, promote( Float64(η_cr), p_cr, η_m, p_m, ε )...)
    Algorithm(
        parameters,
        information = information,
        options = options,
    )

end



function update_state!(
    status::State,
    parameters::NSGA2,
    problem::AbstractProblem,
    information::Information,
    options::Options,
    args...;
    kargs...
    )


    I = randperm(parameters.N)
    J = randperm(parameters.N)
    for i = 1:2:parameters.N

        pa = tournament_selection(status.population, I[i], is_better)
        pb = tournament_selection(status.population, J[i], is_better)

        # crossover
        c1, c2 = SBX_crossover( get_position(pa), get_position(pb), problem.bounds,
                              parameters.η_cr, parameters.p_cr)
       
        # mutation
        polynomial_mutation!(c1,problem.bounds,parameters.η_m, parameters.p_m)
        polynomial_mutation!(c2,problem.bounds,parameters.η_m, parameters.p_m)
       
        # rapair solutions if necesary
        replace_with_random_in_bounds!(c1, problem.bounds)
        replace_with_random_in_bounds!(c2, problem.bounds)

        # evaluate children
        child1 = generateChild(c1, problem.f(c1))
        child1.sum_violations = violationsSum(child1.g, child1.h, ε = parameters.ε)

        child2 = generateChild(c2, problem.f(c2)) 
        child2.sum_violations = violationsSum(child2.g, child2.h, ε = parameters.ε)
        status.f_calls += 2
       
        # save children
        push!(status.population, child1)
        push!(status.population, child2)
    end
    
    # non-dominated sort, crowding distance, elitist removing
    sort!(status.population, by = x -> x.rank, alg = Base.Sort.QuickSort)
    truncate_population!(status.population, parameters.N, is_better)

    stop_criteria!(status, parameters, problem, information, options)
end


function initialize!(
    status::State,
    parameters::NSGA2,
    problem::AbstractProblem,
    information::Information,
    options::Options,
    args...;
    kargs...
)
    D = size(problem.bounds, 2)

    if parameters.p_m < 0.0
        parameters.p_m = 1.0 / D
    end

    if options.iterations == 0
        options.iterations = 500
    end

    if options.f_calls_limit == 0
        options.f_calls_limit = options.iterations * parameters.N + 1
    end

    initialize!(problem, nothing, parameters, status, information, options)
    fast_non_dominated_sort!(status.population, is_better)

    indiv_type = typeof(status.population[1])
    if indiv_type <: xfgh_indiv || indiv_type <: xFgh_indiv
        for sol in status.population
            sol.sum_violations = violationsSum(sol.g, sol.h, ε = parameters.ε)
        end
    end


end

function final_stage!(
    status::State,
    parameters::NSGA2,
    problem::AbstractProblem,
    information::Information,
    options::Options,
    args...;
    kargs...
    )
    status.final_time = time()

    status.best_sol = get_pareto_front(status.population, is_better)

end





function is_better_nsga2(
    New::xFgh_indiv,
    Old::xFgh_indiv;
    searchType = :minimize,
    ε = 0.0,
)

    old_vio = Old.sum_violations
    new_vio = New.sum_violations

    if new_vio < old_vio
        return true
    elseif new_vio > old_vio
        return false
    end

    if searchType == :minimize
        for i in 1:length(Old.f)
            if Old.f[i] < New.f[i]
                return false
            end
        end
        return true
    end

    for i in 1:length(Old.f)
        if Old.f[i] > New.f[i]
            return false
        end
    end

    return true
end