# Zendesk Quality Assurance script

This script helps support teams set up Zendesk ticket peer reviews. It pulls some number of random tickets for each support agent from the past week and assigns them to random support agents to review. The default is three tickets, but that can be changed by changing the `review_pool_size` variable in the `zd-qa.rb` file.

The output is a CSV file containing the agent's name, a link to the Zendesk ticket, and the assigned reviewer's name for each ticket pulled. This can then be imported into the spreadsheet of your choice (I like to use Google Sheets for this) for creating weekly peer review sheets.

This script does _not_ include a grading rubric. Teams and/or team leads are responsible for defining their own scoring system (categories, scores, rubrics, etc.). The data provided by this script is used to assign random tickets for review.

## Configuring the script

Before running this script for the first time, you'll need to configure it with your team's information. To clone and configure it, use these commands in the terminal:

```
git clone https://github.com/balevine/zendesk-qa
cd zendesk-qa
touch .env
echo "ZD_URL=your_url" > .env
echo "ZD_USERNAME=your_username" > .env
echo "ZD_PASSWORD=your_password" > .env
```

where:
`your_url` is your Zendesk account URL (for example, `https://company.zendesk.com`)
`your_username` is your Zendesk username, or the username of the authorized account used to run this script
`your_password` is the Zendesk password for the Zendesk username used above

Lastly, you'll need to edit the `staff.rb` file to include the names and Zendesk user IDs of all the support agents you want included in your peer reviews. Open your text editor of choice and fill in the names and IDs as shown in the placeholder examples in the file. You can find the names and IDs for your team in your Zendesk account, though you might need a Zendesk administrator to access all of them. Don't forget to delete the placeholder values from the file before saving it.

## Running the script

To run the script, you'll need to have Ruby on your local computer. To see if you have it, you can use this commmand in the terminal:

```
ruby -v
```

If that command isn't recognized, you need to install Ruby. The official Ruby site has [instructions for that](https://www.ruby-lang.org/en/documentation/installation/).

Once Ruby is installed, you can run this script by navigating to the directory in a terminal (usually `cd ~/zendesk-qa` but it depends where you saved the directory) and running `ruby zd-qa.rb`. The script should run for a little while (possibly a couple of minutes) before writing the CSV output file to the directory. The command line will show how long the process took and how many lines were written—usually three for each support agent, by default.

## Things to keep in mind

A support agent may not have responded to three tickets during the previous week. Maybe they were on vacation or out sick. If they responded to ANY tickets, those will be selected and output for review. If not, they will not be included in the peer review for that week. Each agent will only be assigned to review a number of tickets equal to the number of tickets of theirs that were selected for review that week. So, for example, if an agent only answered two tickets during the week, those two tickets will be assigned to other agents to review, and the agent will only be assigned two of their teammates' tickets to review that week.

## Contribute

This script is imperfect. If you'd like to contribute, please open an issue or pull request. Some things this needs, off the top of my head:

- Tests
- Rate limit safeguards
- Better configuration options
- Better output options (maybe output directly to Google sheets)