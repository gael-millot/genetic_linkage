

Do not remove single_path_with_regex_fun, but since this function is also present in bash main function, test that the two are the same in term of codes

1) Add in the workflow that if "--best" selected, then check that at least 3 common indivs per group, else 2 common indiv per group

2) For chromo 23, pedstats does not work (in pre_merlin.sh), as it returns: Cannot handle first line of data file, the reason why I wrote "optional:true" in the return of the output file.

3)
http://csg.sph.umich.edu/abecasis/merlin/reference.html
The --rankFamilies option is interesting:
Rank families according to their expected informativeness. This information can help focus genotyping efforts.
But is only available using the regression model:
http://csg.sph.umich.edu/abecasis/merlin/tour/regress.html

