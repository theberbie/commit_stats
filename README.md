#Commit Checker 

This tool runs through commits made over the past year(by default) and returns
the average commit per day, and total.

#How to run it 

###Clone the repo 

Run ```bundle install``` or `bundle` to install dependencies

From your command line, run ```ruby script.rb``` to start the script

You can pass it the following flags:

`-w` or `--weeks` + number of weeks desired to print 

Example: 

`ruby script.rb -w 20` will print commits made in the past 20 days along with daily average 

`-r` or `--repo` + the name of the owner of the github repository and the actual repository
 
 If no weeks flag is specified, it defaults to 52 weeks(1 year)
 
 Example: 
 
 `ruby script.rb -r kubernetes/kubernetes` 
 
 If no repo is passed, it defaults to the kubernetes repository
 
`-max` is a boolean. When true, itreturns only the busiest day and the total commits made over the year for that particular days
 
`-asc` returns all commits made for each day over the past year in ascending order

`desc` returns all commits made for each day over the past year in descending order

###When in doubt about the flags, run `-h ` for more detail

