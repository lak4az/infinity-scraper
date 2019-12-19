# infinity-scraper
Remote driver to scrape data from 247sports recruiting database.

The purpose of this project is to create a simple way to extract data for high school football recruits into an organized, workable format. This will make keeping track of recruits easier for both coaches and area recruiters and allow for consistency in recruit data while also ensuring that no data for any recruit is excluded from the output.

In the 247 player rankings, the only recruits that are visible are top recruits who have received an offer or expressed interest in a school. The only way to access all recorded recruits in a given state is via the 247 player search tool. The player search tool is very inefficient, as it requires scrolling through the entire list of recruits to view all available player data. Furthermore, there is no simple way to extract this data. This tool removes the need for manual data entry and the accompanying human error. 

The infinity scraper, appropriately named for its function, scrolls through the player search tool until data for all players has been revealed. Following this, data is scraped for all recruits shown and then stored in a .csv file. This tool ensures that data for all recruits within the requested criteria will be gathered, so that no single prospect will be excluded from the spreadsheet output. 

See the accompanying attachments for more information. 
