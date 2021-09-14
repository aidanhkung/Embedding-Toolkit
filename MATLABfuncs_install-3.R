
sink("~/Desktop/install_log.txt", split = TRUE)

devtools::install_github("kbrulois/MATLABfuncs")

#help files

?MATLABfuncs::run_tSpace
?MATLABfuncs::runWanderlust

#test tSpace with default paramters

test_data <- readRDS(url("http://web.stanford.edu/group/butcherlab/PLN1.rds"))

tsp_out <- MATLABfuncs::run_tSpace(data = test_data)

write.csv(do.call(cbind, tsp_out[c(1,4)]), "~/Desktop/tsp_out.csv")

head(tsp_out$tPCs)

#test with different parameters

tsp_out <- MATLABfuncs::run_tSpace(data = test_data, 
                                      trajectories = 50,
                                      k = c(20, 30, 50, 100),
                                      l = c(10,15,20,40),
                                      metric = "cosine",
                                      graphs = 5, 
                                      landmarks = 20)
head(tsp_out$tPCs)


#test wanderlust with default parameters

wl_out <- MATLABfuncs::runWanderlust(data = test_data, s = "CCGTGGAAGCCACGCT_PLN1")
head(wl_out)
comment(wl_out)
####run tspace using clipboard i/o####

#select the cells in JMP and select "Copy With Column Names" from the edit drop down menu.
#run the two lines of code below

#clipr::write_clip(do.call(cbind, MATLABfuncs::run_tSpace(data = clipr::read_clip_tbl())[c(1,4)]))
#system("say done")

#in the meantime, create 40 new numeric columns in JMP
#when the computer says done, select "Paste With Column Names" in JMP

