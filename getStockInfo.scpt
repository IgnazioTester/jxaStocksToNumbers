JsOsaDAS1.001.00bplist00�Vscript_8var debug = false
var log = false

var AppleScript = Application.currentApplication()

var yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
var yahooQueryParam = "?modules=price"
var coinbaseURL = "https://api.coinbase.com/v2/exchange-rates?currency="
var coingeckoURL = "https://api.coingecko.com/api/v3/simple/price?vs_currencies=eur&ids="

var rows

var stockRow = "A"
var shouldProcessRow = "K"
var currentPriceRow = "L"

var first = true

function run(argv) {
	let start = new Date();

	AppleScript.includeStandardAdditions = true

	let table = checkNumbers(AppleScript)	

	if (!table)
		return
		
	rows = table.rowCount(), headerRows = table.headerRowCount(), footerRows = table.footerRowCount()
	var marketState

	for (i = headerRows + 1; i <= rows - footerRows; i++) {
		let stock = table.cells.byName(`${stockRow}${i}`).value()
		prettyLog(stock)
		prettyLog(table.cells.byName(`${shouldProcessRow}${i}`).value())
		
		if (table.cells.byName(`${shouldProcessRow}${i}`).value() === 1)
			yahooFinance(table, stock)
		else if (table.cells.byName(`${shouldProcessRow}${i}`).value() === 2)
			coinbase(table, stock)
		else if (table.cells.byName(`${shouldProcessRow}${i}`).value() === 3)
			coinmarketcap(table, stock)
		else if (table.cells.byName(`${shouldProcessRow}${i}`).value() === 4)
			coingecko(table, stock)
	}

	console.log((new Date() - start) / 1000 + " secs")
}

function checkNumbers(app) {
	if (!Application('Numbers').running()) {
		app.displayAlert("Numbers is not running.")
		return null
	}
	
	let Numbers = Application('Numbers')
	Numbers.includeStandardAdditions = true

	let table = Numbers.documents.byName("Money").sheets.byName("Trading").tables.byName("Investment Summary")

	try {
		table()
	} catch (err) {
		Numbers.displayAlert("Error finding table. Is the document opened?")
		return null
	}

	return table
}

function yahooFinance(table, stock) {
	let response = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
		
	let json = JSON.parse(response).quoteSummary.result[0]
	let price = json.price
			
	marketState = price.marketState
		
	if (first) {
		writeToCell(table, `${currentPriceRow}${rows}`, marketState, false)
		first = false
	}
		
	let currentPriceCell = `${currentPriceRow}${i}`
	let currentPrice
	if ((marketState === "POST" || marketState === "CLOSED"  || marketState === "PREPRE") && price.postMarketPrice.raw) {
		prettyLog(`${stock}: ${marketState}, postMarketValue `)
		currentPrice = price.postMarketPrice.raw
	} else if (marketState === "PRE" && price.preMarketPrice.raw) {
		prettyLog(`${stock}: ${marketState}, preMarketValue `)
		currentPrice = price.preMarketPrice.raw
	} else {
		prettyLog(`${stock}: ${marketState}, currentPrice`)
		currentPrice = price.regularMarketPrice.raw
	}
		
	writeToCell(table, currentPriceCell, currentPrice)
}

function coinbase(table, stock) {
	let response = AppleScript.doShellScript(`curl -s ${coinbaseURL + stock}`)
		
	let json = JSON.parse(response)
	let price = json.data.rates.EUR
	let currentPriceCell = `${currentPriceRow}${i}`
	
	writeToCell(table, currentPriceCell, price)
}

function coinmarketcap(table, stock) {
	let response = AppleScript.doShellScript(`curl -H "X-CMC_PRO_API_KEY: 61107043-5af3-4dd5-b70f-e7dc813ea2e0" -H "Accept: application/json" -d "convert=EUR&symbol=${stock}" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest`)
	
	let json = JSON.parse(response)
	let price = json.data[stock].quote.EUR.price	
	let currentPriceCell = `${currentPriceRow}${i}`

	writeToCell(table, currentPriceCell, price)
}

function coingecko(table, stock) {
	let response = AppleScript.doShellScript(`curl -X GET -H "Accept: application/json" "${coingeckoURL + stock}"`)
	
	let json = JSON.parse(response)
	prettyLog(stock.toLowerCase())
	prettyLog(json)
	prettyLog(json[stock.toLowerCase()]['eur'])
	let price = json[stock.toLowerCase()]['eur']
	let currentPriceCell = `${currentPriceRow}${i}`

	writeToCell(table, currentPriceCell, price)
}

function writeToCell(table, cellName, value, isFormula = true) {
	prettyLog(`${cellName}: ${value}`)
	if (!debug && (value || value === 0) && (table.cells.byName(cellName).value() !== value)) {
		prettyLog(`Writting Value`)
		table.cells.byName(cellName).value = `${isFormula ? "=" : ""}${value}`
	}
}

function prettyLog(object) {
	if (log)
	    console.log(Automation.getDisplayString(object))
}                              Njscr  ��ޭ