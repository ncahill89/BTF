#' Create Species Response Curves
#'
#' @param obj An object of class \code{BTF} from \code{\link{run_modern}}
#' @param species_select a vector of species names for which you want to create response curves
#'
#' @return Response curve data files (empirical and model) and SRC plots
#' @export
#' @import ggplot2 magrittr
#' @importFrom tidyr 'gather'
#' @examples
#' responsecurves()

response_curves <- function(obj,
                            species_select) {

    # Data
    y <- modern_mod$data$y
    n <- nrow(y)
    m <- ncol(y)
    grid_size = 50
    SWLI_grid = seq(modern_mod$elevation_min, modern_mod$elevation_max, length = grid_size)
    N_count <- apply(y, 1, sum)
    species_names <- modern_mod$species_names
    begin0 <- modern_mod$data$begin0
    # Get empirical probabilities
    # ----------------------------------------------------

    Pmat <- matrix(NA, n, m)
    for (i in 1:n) {
        Pmat[i, ] <- y[i, ]/N_count[i]
    }

    empirical_dat = data.frame(modern_mod$data$x * 100, Pmat)
    colnames(empirical_dat) = c("SWLI", species_names)

    # Plot of empirical probabilities
    # ------------------------------------------------

    empirical_data_long = empirical_dat %>% tidyr::pivot_longer(names_to = "taxa",
        values_to = "proportion", -SWLI) %>%
        dplyr::filter(taxa %in% species_select)

    src_dat <- modern_mod$src_dat %>% dplyr::filter(taxa %in% species_select)

    p = ggplot(data = empirical_data_long) + geom_point(aes(x = SWLI, y = proportion,
        colour = "Observed Data"), alpha = 0.5) + geom_line(data = src_dat,
        aes(x = SWLI, y = proportion, colour = "Model Estimates"), linetype = "dashed") +
        geom_line(data = src_dat, aes(x = SWLI, y = proportion_lwr, colour = "Model Estimates"),
            linetype = "dashed") + geom_line(data = src_dat, aes(x = SWLI,
        y = proportion_upr, colour = "Model Estimates"), linetype = "dashed") +
        scale_colour_manual(name = "", values = c("red", "grey"), guide = guide_legend(override.aes = list(linetype = c("dashed",
            "blank"), shape = c(NA, 16)))) + theme_minimal() + ylim(0,
        1) + ggtitle("Species Response Curves") + facet_wrap(~taxa, ncol = 2,
        scales = "free")


    return(list(src_plot = p, src_empirical_dat = empirical_data_long,
        src_model_dat = src_dat))

}

