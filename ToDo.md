* Seems like there is no TerminateSteadyState working atm
* add aw and au to phaseplot for outcome plots. Same for incomes?
* Add periodicity detection and averaging
* Clean up dudt function from comments
* make branch and move model over to ComponentArrays
* check if we can easily add new resource using the institutions framework
* check why sim! does not seem to terminate at steady state?!
* fix the scaling of the vector field in phaseplots
* have phaseplot! return legend-elements and labels to makeing legend simple!
* make tradable quotas work!
* implement highst incomes first for tradable quotas!
* fix indexed is correct for incomes!
* make sure revenues works correctly for trade
* assign institution either as s.institions=Market() or s.instution=[Market()]
* all instutions with constructors
* Insightful and understandable institutions documentation
* better/more robust check in revenues! part of refactoring instiuttions as Array or not
* make a figure that shows the incentive switch, for linear and for non-linear, i.e. double switch. Also one that illustrates how increased q without increased w can cause incentive shifts