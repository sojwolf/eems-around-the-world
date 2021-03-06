source("scripts/load_pop_meta.R") #load raw
source("scripts/ggeems/ggeems_main.R")
source("scripts/config.R")
source("scripts/annotation.R")


WIDTH=7
HEIGHT=7

nruns <- as.numeric(snakemake@wildcards$nruns)
name <- snakemake@wildcards$name


eems_opt <- snakemake@config$eems[[name]]


mcmcpath <- sprintf('eemsout/%d/%s/', 0:(nruns-1), name)
if("continues" %in% names(eems_opt)){
    n2 <- eems_opt[['continue']]
    mcmcpath2 <- sprintf('eemsout/%d/%s/', 0:(nruns-1), n2)
    mcmcpath <- c(mcmcpath, mcmcpath2)
    print(mcmcpath)
}


pop_display <- snakemake@input$pop_display
pop_geo <- snakemake@input$pop_geo
indiv_label <- snakemake@input$indiv_label

C <- get_config(snakemake, 'eemssig')
RES <- C$RES

alpha_limits <- c(C$min_alpha, C$max_alpha)
alpha_null <- ifelse(C$fancy, 0.9, 0.6)


null_theme <- theme(axis.line=element_blank(),axis.text.x=element_blank(),
                                  axis.text.y=element_blank(),axis.ticks=element_blank(),
                                            axis.title.x=element_blank(),
                                            axis.title.y=element_blank(),
                                            #legend.position="bottom",
                                            legend.position="none",
                                            legend.key.width=unit(1, "in"),
                                          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
                                              panel.grid.minor=element_blank(),plot.background=element_blank())

g <- read.output.graph(mcmcpath[1])

m = make_map(mcmcpath, C$zoom, is.mrates=T, fancy_proj=C$fancy, 
     alpha_limits=alpha_limits, fancy_proj_pars=C$fancy_proj_pars,
     signplot=T, alpha_null=alpha_null)
m2 <- m + null_theme
if(C$sign_add_graph) m2 <- m2 +ggadd.graph(g, "#eeeeee49")
if(C$sign_add_pts) m2 <- m2 + ggadd.pts(g, "#eeeeee99")
if(C$sign_add_pts_color) m2 <- m2 + ggadd.pts.color(g)
if(C$sign_add_label) m2 <- gg_add_samples_true(m2, pop_geo, pop_display, size=C$textsize)


ggsave(sprintf("eemsout_gg/%s_nruns%s-mrates01.png", name, nruns), m2,
   width=C$width, height=C$height)
saveRDS(m2,sprintf("eemsout_gg/%s_nruns%s-mrates01.rds", name, nruns))
#ggsave(sprintf("eemsout_gg/%s_nruns%s-mrates01.pdf", name, nruns), m2,
#       width=WIDTH, height=HEIGHT)

if(C$do_q_plots){
m = make_map(mcmcpath, C$zoom, is.mrates=F, fancy_proj=C$fancy,
	     alpha_limits)
m2 = gg_add_samples_true(m, pop_geo, pop_display)
ggsave(sprintf("eemsout_gg/%s_nruns%s-qrates01.png", name, nruns), m2,
       width=WIDTH, height=HEIGHT)
#ggsave(sprintf("eemsout_gg/%s_nruns%s-qrates01.pdf", name, nruns), m2,
#       width=WIDTH, height=HEIGHT)
warnings()
}

