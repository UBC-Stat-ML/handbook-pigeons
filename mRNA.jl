using BridgeStan 
using MCMCChains 
using Pigeons
using Plots 
using StatsPlots 
using CairoMakie 
using PairPlots 


function start_job(; n_chains, n_rounds)
    # hack(n_chains)
    post_prior = Pigeons.stan_mRNA_post_prior_pair()
    pigeons(;
        target = post_prior.posterior,
        reference = post_prior.prior,
        n_rounds,
        n_chains,
        record = [traces; round_trip; record_default()],
        checkpoint = true,
        on = MPI(
                n_mpi_processes = n_chains,
                dependencies = [BridgeStan])
        )
end

function make_pp(r)
    pt = load(r)
    samples = Chains(pt)
    my_plot = PairPlots.pairplot(samples) 
    CairoMakie.save("pair_plot.pdf", my_plot)
end

# function hack(n_chains)
#     setup_mpi(
#         submission_system = :slurm,
#         environment_modules = ["gcc", "openmpi", "git"],
#         add_to_submission = [
#             "#SBATCH -A st-alexbou-1",
#             "#SBATCH --nodes=1-10000"
#         ], 
#         library_name = "/arc/software/spack-2023/opt/spack/linux-centos7-skylake_avx512/gcc-9.4.0/openmpi-4.1.1-d7o6cdvp67ngi5c5wdcw2qyjyseq3l3o/lib/libmpi"
#     )
# end

nothing