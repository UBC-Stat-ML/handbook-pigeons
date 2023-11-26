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

function toy()
    pigeons(;
        target = toy_mvn_target(2),
        record = [traces; round_trip; record_default()],
        checkpoint = true,
        on = ChildProcess(
                dependencies = [BridgeStan])
        )
end

function make_plots(r)
    pt = load(r)
    samples = Chains(pt)

    CairoMakie.save(
        "$(r.exec_folder)/pair_plot.pdf", 
        PairPlots.pairplot(samples))

    StatsPlots.savefig(
        StatsPlots.plot(samples), 
        "$(r.exec_folder)/posterior_densities_and_traces.pdf")

    params, internals = MCMCChains.get_sections(samples)

    StatsPlots.savefig(
        StatsPlots.plot(internals), 
        "$(r.exec_folder)/logdensity.pdf");

    StatsPlots.savefig(
        meanplot(samples), 
        "$(r.exec_folder)/meanplot.pdf")

    StatsPlots.savefig(
        autocorplot(samples), 
        "$(r.exec_folder)/autocorplot.pdf")
end
