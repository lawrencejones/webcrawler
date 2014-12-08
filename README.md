# webcrawler

![Web Output, Dependency Graph](/lib/web/public/web_screen.png "Screenshot of Web Interface")

This is a very simple tool designed to crawl websites, producing data on what each page links to and
what static assets they depend on.

The tool can be used as either a command line interface, to produce JSON formatted results, or via
the web interface that can graph the dependencies between all internal pages and their assets from
the target website.

It's worth noting that this tool works best on sites with few broken links, and that output can get
rather large if the site has many pages.

## Geting Setup

Ensure your machine has node installed, along with node's package manager npm.

Once node & npm are installed, clone this repo and run `npm install` from the project root. This will
install all the required dependencies, and run tests to ensure everything is configured correctly.

To run the binary, you also need coffee-script to be installed globally. Running `npm install -g coffee-script`
will complete this step.

## Usage

Once installed, you can run `webcrawler` by executing `./webcrawler` from the project root. A usage
script will be printed if you run `webcrawler` with no arguments.

### `crawl <target> <jsonFile>`

The `crawl` command can be used to recursively crawl the supplied target. If no JSON file target
is provided, then the result to be outputted to standard out. Otherwise the data is dumped to the
file provided as the `jsonFile` argument.

### `serve`

To access the web interface, run webcrawler with the argument `serve`. This will boot a server on
port 3000 that is then accessible at `http://localhost:3000`. From here, you can enter the target
URL and the results will be graphed onscreen.

# Development

Log levels are set via the environment variable `LOG_LEVEL`. To run with debug output, try
`LOG_LEVEL=debug ./webcrawler <cmd>...`.

# Contact

Lawrence Jones - lmj112@ic.ac.uk
