__precompile__()
module Metaheuristics

# ECA algorithm
export eca, diffEvolution, pso, ecaConstrained, WOA, GOA, GSA, CGSA, SA, CMAES_AEP
export CFO

include("tools.jl")

# ECA algorithm
include("eca.jl")
include("ecaConstrained.jl")

# Differential algorithm
include("diffEvolution.jl")

# PSO algorithm
include("pso.jl")

# The whale optimization algorithm
# S Mirjalili, A Lewis - Advances in Engineering Software, 2016
include("WOA.jl")

# Grasshopper optimisation algorithm: Theory and application
# S Saremi, S Mirjalili, A Lewis - Advances in Engineering Software, 2017
include("GOA.jl")

# GSA: a gravitational search algorithm
# E Rashedi, H Nezamabadi-Pour, S Saryazdi - Information sciences, 2009
include("GSA.jl")

# Mirjalili, Seyedali, and Amir H. Gandomi. 
# "Chaotic gravitational constants for the gravitational search algorithm." 
# Applied Soft Computing 53 (2017): 407-419.
include("CGSA.jl")

# SA: Simulated Annealing
# Kirkpatrick, S., Gelatt, C.D., & Vecchi, M.P. (1983). Optimization by
# Simulated Annealing. _Science, 220_, 671-680.
include("SA.jl")

# Li, Zhenhua, and Qingfu Zhang. 
# "An efficient rank-1 update for Cholesky CMA-ES using auxiliary evolution path." 
# Evolutionary Computation (CEC), 2017 IEEE Congress on. IEEE, 2017.
include("CMAES_AEP.jl")

# R.A. Formato Central force optimization:
# a new metaheuristic with applications in applied electromagnetics
# Progress in Electromagnetics Research, PIER 77 (2007), pp. 425-491, 10.2528/PIER07082403
include("CFO.jl")


end # module
